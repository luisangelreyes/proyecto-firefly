extends Node2D
# ── CURSOR VIRTUAL PARA MANDO ─────────────────────────────────────────────
var cursor_pos: Vector2 = Vector2(720, 540)
var cursor_spd: float = 600.0
var item_agarrado = null
var usando_mando: bool = false
# ── CONFIGURACIÓN DE BOTES (sobreescribible por hijos) ───────────────────
var config_botes: Array = [
	{"nodo": "BotePAPEL",    "tipo": SesionGlobal.Categorias.PAPEL,    "nombre": SesionGlobal.Categorias.PAPEL},
	{"nodo": "BoteVIDRIO",   "tipo": SesionGlobal.Categorias.VIDRIO,   "nombre": SesionGlobal.Categorias.VIDRIO},
	{"nodo": "BotePLASTICO", "tipo": SesionGlobal.Categorias.PLASTICO, "nombre": "Plástico"},
]

# ── CATÁLOGO (sobreescribible por hijos) ──────────────────────────────────
var catalogo_objetos: Array = [
]
@onready var cursor_visual = $CursorMando  

const SPRITESHEET = preload("res://entities/basura/sprites/basura_nivel2.png")
const COLS = 9   # columnas del sheet
const FILAS = 4  # filas del sheet


var OBJETOS = []
const ItemScene = preload("res://entities/basura/ItemMorral.tscn")

	# ── UI ACTUALIZACIÓN POR SEÑALES ──────────────────────────────────────────
func _on_tiempo_actualizado(tiempo: float):
	lbl_timer.text = "%d" % ceil(tiempo)
	$BarraTiempo.value = tiempo
	if tiempo <= 10:
		$BarraTiempo.modulate = Color("#f87171")
	elif tiempo <= 20:
		$BarraTiempo.modulate = Color("#fbbf24")
	else:
		$BarraTiempo.modulate = Color("#86efac")

func _on_puntos_actualizados(puntos: int):
	lbl_puntos.text = "Puntos: %d" % puntos

func _on_vidas_actualizadas(vidas: int):
	lbl_vidas.text = "Vidas: %d" % vidas

func _on_feedback_mostrado(texto: String, color: Color):
	lbl_feedback.text = texto
	lbl_feedback.modulate = color
	lbl_feedback.visible = true
	fb_timer = 2.0
	var tween = create_tween()
	lbl_feedback.scale = Vector2(0.5, 0.5)
	tween.tween_property(lbl_feedback, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BOUNCE)

# ── FUNCIONES AUXILIARES ──────────────────────────────────────────────────────
var cola_objetos: Array = []      # objetos pendientes mezclados
var objeto_actual = null          # el que está en pantalla ahora
var clasificados: int = 0
var total: int = 0
var juego_activo: bool = true
var item_pausado = null
var fb_timer: float = 0.0
var objetos_por_partida: int = 9
@onready var hit_counter = $HitCounter

var racha_actual: int = 0
# ── MÉTRICAS PARA PANTALLA DE RESULTADOS ─────────────────────────────────
var clasificados_primera: int = 0   # correctos sin fallar ni agotar tiempo

var racha_maxima: int = 0
var fallos: int = 0                 # mal clasificados + tiempos agotados
var desglose: Dictionary = {
	SesionGlobal.Categorias.PAPEL:    0,
	SesionGlobal.Categorias.VIDRIO:   0,
	SesionGlobal.Categorias.PLASTICO: 0,
	SesionGlobal.Categorias.INORGANICO:0,
	SesionGlobal.Categorias.ORGANICO:0,
	SesionGlobal.Categorias.TELA:0,
	"madera":0,
	SesionGlobal.Categorias.METAL:0
}
var objeto_fallado: bool = false    # flag: este objeto ya tuvo un fallo/timeout

# ── TEMPORIZADOR GENERAL ──────────────────────────────────────────────────
var tiempo_limite: float = 30.0
var tiempo_restante: float = 30.0
signal tiempo_actualizado(tiempo: float)
signal puntos_actualizados(puntos: int)
signal vidas_actualizadas(vidas: int)
signal feedback_mostrado(texto: String, color: Color)

var timer_activo: bool = false
var timer_juego: Timer

@onready var bote_papel   = $BotePAPEL
@onready var bote_vidrio  = $BoteVIDRIO
@onready var bote_plastico = $BotePLASTICO
@onready var lbl_puntos   = $Labelpuntos
@onready var lbl_feedback = $LabelFeedBack
@onready var lbl_timer    = $LabelTimer        
@onready var lbl_vidas    = $LabelVidas        
@onready var popup        = $InterfazUI/PopUpAyuda
@onready var lbl_explicacion = $InterfazUI/PopUpAyuda/VBoxContainer/LblExplicacion

const GRID_ORIGEN = Vector2(150, 540)   # posición donde aparece el objeto


func _ready():
	OBJETOS = SesionGlobal.datos_residuos.get("nivel2_objetos", [])

	call_deferred("_iniciar_nivel")
	if catalogo_objetos.is_empty():
		catalogo_objetos = OBJETOS.duplicate()

	_preparar_cola()
	
	tiempo_actualizado.connect(_on_tiempo_actualizado)
	puntos_actualizados.connect(_on_puntos_actualizados)
	vidas_actualizadas.connect(_on_vidas_actualizadas)
	feedback_mostrado.connect(_on_feedback_mostrado)
	
	puntos_actualizados.emit(SesionGlobal.puntaje)
	vidas_actualizadas.emit(SesionGlobal.vidas)
	
	tiempo_restante = tiempo_limite
	timer_activo = true
	
	timer_juego = Timer.new()
	timer_juego.wait_time = 0.1
	timer_juego.autostart = true
	timer_juego.timeout.connect(_on_timer_tick)
	add_child(timer_juego)

	_siguiente_objeto()
	$PantallaGameOver.reintentar_presionado.connect(_on_reintentar)
	$PantallaGameOver.menu_presionado.connect(_on_menu_gameover)
	
	if not $PantallaGameOver.reintentar_presionado.is_connected(_on_reintentar):
		$PantallaGameOver.reintentar_presionado.connect(_on_reintentar)
		$PantallaGameOver.menu_presionado.connect(_on_menu_gameover)


func _iniciar_nivel():
	lbl_feedback.visible = false
	popup.visible = false
	_configurar_botes()
	if catalogo_objetos.is_empty():
		catalogo_objetos = OBJETOS.duplicate()
	_preparar_cola()
	puntos_actualizados.emit(SesionGlobal.puntaje)
	tiempo_restante = tiempo_limite
	timer_activo = true
	if is_instance_valid(timer_juego):
		timer_juego.start()
	_siguiente_objeto()


func _configurar_botes():
	desglose.clear() 
	
	for cfg in config_botes:
		var nodo = get_node_or_null(cfg["nodo"])
		if nodo:
			nodo.set_meta("tipo", cfg["tipo"])
			
		# ¡Aquí está la magia! 
		# Registramos dinámicamente la categoría en el diccionario
		desglose[cfg["tipo"]] = 0
func _preparar_cola():
	var todos = catalogo_objetos.duplicate()
	todos.shuffle()
	cola_objetos = todos.slice(0, objetos_por_partida)
	total = cola_objetos.size()

func _siguiente_objeto():
	if not juego_activo:
		return
	objeto_fallado = false

	if is_instance_valid(objeto_actual):
		objeto_actual.queue_free()
		objeto_actual = null

	if cola_objetos.is_empty():
		_victoria()
		return

	var datos = cola_objetos.pop_front()
	objeto_actual = ItemScene.instantiate()
	add_child(objeto_actual)
	objeto_actual.global_position = GRID_ORIGEN
	objeto_actual.pos_origen = GRID_ORIGEN
	objeto_actual.inicializar(datos, self)

func _process(delta):
	# Feedback label
	if fb_timer > 0:
		fb_timer -= delta
		if fb_timer <= 0:
			lbl_feedback.visible = false

	if not juego_activo:
		return

	# ── MANDO ─────────────────────────────────────────────────────────────────
	var joy_x = Input.get_axis("ui_left", "ui_right")
	var joy_y = Input.get_axis("ui_up", "ui_down")

	if (abs(joy_x) > 0.15) or (abs(joy_y) > 0.15):
		usando_mando = true
		cursor_visual.visible = true
	
	if usando_mando:
		cursor_pos.x += joy_x * cursor_spd * delta
		cursor_pos.y += joy_y * cursor_spd * delta
		cursor_pos.x = clamp(cursor_pos.x, 0, 1440)
		cursor_pos.y = clamp(cursor_pos.y, 0, 1080)
		cursor_visual.global_position = cursor_pos - cursor_visual.size / 2

		if item_agarrado and is_instance_valid(item_agarrado):
			item_agarrado.mover_a(cursor_pos)

	# Ocultar cursor si mueve el mouse
	if Input.get_last_mouse_velocity().length() > 10:
		usando_mando = false
		cursor_visual.visible = false
		if item_agarrado:
			item_agarrado.soltar()
			item_agarrado = null
func _on_timer_tick():
	if not timer_activo or not juego_activo:
		return
	
	tiempo_restante -= 0.1
	tiempo_restante = max(0, tiempo_restante)
	tiempo_actualizado.emit(tiempo_restante)

	if tiempo_restante <= 0:
		timer_juego.stop()
		_tiempo_agotado()



func _tiempo_agotado():
	timer_activo = false
	juego_activo = false
	# Destruir objeto actual si sigue en pantalla
	if is_instance_valid(objeto_actual):
		objeto_actual.queue_free()
		objeto_actual = null

	# Mensaje dramático
	var faltaron = cola_objetos.size() + 1  # pendientes + el actual
	# Si ya no había objeto activo, solo los de la cola
	if not is_instance_valid(objeto_actual):
		faltaron = cola_objetos.size()

	_feedback("¡TIEMPO!", Color("#f87171"))

	await get_tree().create_timer(1.8).timeout
	if not is_inside_tree():
		return

	SesionGlobal.completar_nivel(1, 4)
	
	$PantallaResultados.mostrar_resultados(
		clasificados,
		clasificados_primera,
		racha_maxima,
		fallos,
		desglose,
		total,
		faltaron
	)
	_game_over("tiempo_agotado")
	
func intentar_clasificar(item, pos_soltar: Vector2 = Vector2.ZERO):
	if not juego_activo:
		item.volver_origen()
		return
	var pos = pos_soltar if pos_soltar != Vector2.ZERO else item.global_position
	var bote_target = _get_bote_en(pos)
	if bote_target == null:
		item.volver_origen()
		return
	if bote_target.get_meta("tipo") == item.tipo:
		_correcto(item)
	else:
		_incorrecto(item, item.tipo)

func _get_bote_en(pos: Vector2):
	for cfg in config_botes:
		var bote = get_node_or_null(cfg["nodo"])
		if not bote:
			continue
		var shape = bote.get_node_or_null("CollisionShape2D")
		if shape == null:
			continue
		var rect = shape.shape
		if rect is RectangleShape2D:
			var local = bote.to_local(pos)
			var half  = rect.size / 2.0
			if abs(local.x) <= half.x and abs(local.y) <= half.y:
				return bote
	return null

func _correcto(_item):
	print("El diccionario contiene: ", _item.tipo)
	print("Intentando buscar la llave: inorganico")
	SesionGlobal.puntaje += 10
	puntos_actualizados.emit(SesionGlobal.puntaje)
	$AudioAcierto.play()
	clasificados += 1
	hit_counter.registrar_acierto(racha_actual)
	# Métricas
	desglose[_item.tipo] += 1
	racha_actual += 1
	if racha_actual > racha_maxima:
		racha_maxima = racha_actual
	if not objeto_fallado:
		clasificados_primera += 1
	objeto_fallado = false   # reset para el siguiente objeto

	_feedback("¡Correcto! +10 pts", Color("#86efac"))
	await get_tree().create_timer(0.6).timeout
	if is_inside_tree() and juego_activo:
		_siguiente_objeto()

func _incorrecto(item, tipo_correcto: String):
	SesionGlobal.vidas -= 1
	vidas_actualizadas.emit(SesionGlobal.vidas)
	$AudioError.play()
	timer_activo = false
	# Métricas
	fallos += 1
	racha_actual = 0
	objeto_fallado = true
	juego_activo = false
	item_pausado = item
	hit_counter.registrar_fallo()
	
	var nombre_obj  = item.nombre      if "nombre"      in item else "Este objeto"
	var explicacion = item.explicacion if "explicacion" in item else ""
	
	# Buscamos el nombre del contenedor dinámicamente
	var nombre_bote_correcto = "su contenedor correspondiente"
	for cfg in config_botes:
		if cfg["tipo"] == tipo_correcto:
			nombre_bote_correcto = cfg["nombre"]
			break
			
	lbl_explicacion.text = "¡Casi! %s va en:\n%s\n\n%s" % [
		nombre_obj,
		nombre_bote_correcto,
		explicacion
	]
	popup.visible = true
	$InterfazUI/PopUpAyuda/Button.grab_focus()
	if SesionGlobal.vidas <=0:
		_game_over("clasificacion_incorrecta")



func _feedback(txt: String, color: Color = Color.WHITE):
	feedback_mostrado.emit(txt, color)
	
func _victoria():
	$MusicaFondo.stop()
	$AudioVictoria.play()
	juego_activo = false
	timer_activo = false
	SesionGlobal.completar_nivel(1, 4)
	$PantallaResultados.mostrar_resultados(
		clasificados,
		clasificados_primera,
		racha_maxima,
		fallos,
		desglose,
		total,
		0   # ← faltaron = 0 porque los clasificó todos
	)
	
func _game_over(causa: String = "vidas_agotadas"):
	$MusicaFondo.stop()
	$SonidoGameOver.play()
	juego_activo = false
	timer_activo = false
	popup.visible = false
	SesionGlobal.guardar_sesion()
	await get_tree().create_timer(0.8).timeout
	if not is_inside_tree():
		return
	$PantallaGameOver.mostrar(causa)
	
func _on_reintentar():
	SesionGlobal.vidas   = 3
	SesionGlobal.puntaje = 0
	get_tree().reload_current_scene()

func _on_menu_gameover():
	SesionGlobal.vidas   = 3
	SesionGlobal.puntaje = 0
	puntos_actualizados.emit(SesionGlobal.puntaje)
	get_tree().change_scene_to_file("res://ui/menu/menu.tscn")
	

func _on_popup_entendido_pressed():
	popup.visible = false
	juego_activo = true
	timer_activo = true
	if item_pausado and is_instance_valid(item_pausado):
		item_pausado.volver_origen()
		item_pausado.set_process_input(true)
		item_pausado = null


func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R and not juego_activo:
			SesionGlobal.vidas   = 3
			SesionGlobal.puntaje = 0
			get_tree().reload_current_scene()
	
	# Control en pantalla de resultados
	if $PantallaResultados.visible:
		if event is InputEventJoypadButton and event.pressed:
			if event.button_index == JOY_BUTTON_A:
				$PantallaResultados._on_boton_siguiente()
func _unhandled_input(event):
	if not juego_activo or not usando_mando:
		return

	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_A or KEY_SPACE:
			if item_agarrado == null:
				# Intentar agarrar el objeto actual si el cursor está cerca
				if is_instance_valid(objeto_actual):
					var dist = cursor_pos.distance_to(objeto_actual.global_position)
					if dist < 120:
						item_agarrado = objeto_actual
						item_agarrado.agarrar()
			else:
				# Soltar sobre el bote
				item_agarrado.soltar()
				item_agarrado = null
		
		if event.button_index == JOY_BUTTON_B:
			# Cancelar agarre y volver al origen
			if item_agarrado and is_instance_valid(item_agarrado):
				item_agarrado.siendo_arrastrado_por_cursor = false
				item_agarrado.z_index = 0
				item_agarrado.volver_origen()
				item_agarrado = null
