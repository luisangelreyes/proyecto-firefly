extends Node2D
# ── CURSOR VIRTUAL PARA MANDO ─────────────────────────────────────────────
var cursor_pos: Vector2 = Vector2(720, 540)
var cursor_spd: float = 900.0
var item_agarrado = null
var usando_mando: bool = false

@onready var cursor_visual = $CursorMando  

const SPRITESHEET = preload("res://entities/basura/sprites/basura_nivel2.png")
const COLS = 9   # columnas del sheet
const FILAS = 4  # filas del sheet


# Cada entrada: frame (fila*9+columna), tipo, nombre, explicacion
const OBJETOS = [
	# ── PAPEL / CARTÓN ──
	{"frame":0,  "tipo":"papel", "nombre":"Periódico",       "explicacion":"El periódico es papel reciclable, va en el contenedor de Papel."},
	{"frame":1,  "tipo":"papel", "nombre":"Cuaderno",        "explicacion":"El cuaderno es papel, recíclalo en el contenedor de Papel."},
	{"frame":2,  "tipo":"papel", "nombre":"Caja de cartón",  "explicacion":"El cartón se recicla junto con el papel."},
	{"frame":3,  "tipo":"papel", "nombre":"Revista",         "explicacion":"Las revistas son papel reciclable."},
	{"frame":4,  "tipo":"papel", "nombre":"Bolsa de papel",  "explicacion":"Las bolsas de papel van en el contenedor de Papel."},
	{"frame":5,  "tipo":"papel", "nombre":"Tubo de cartón",  "explicacion":"Los tubos de cartón son reciclables como papel."},
	{"frame":6,  "tipo":"papel", "nombre":"Caja de leche",   "explicacion":"Las cajas de leche de cartón van en Papel."},
	{"frame":7,  "tipo":"papel", "nombre":"Periódicos",      "explicacion":"Los periódicos apilados son papel reciclable."},
	{"frame":8,  "tipo":"papel", "nombre":"Cartón",          "explicacion":"El cartón corrugado va en el contenedor de Papel."},
	# ── VIDRIO ──
	{"frame":10, "tipo":"vidrio","nombre":"Botella de vidrio","explicacion":"Las botellas de vidrio van en el contenedor de Vidrio."},
	{"frame":11, "tipo":"vidrio","nombre":"Frasco",           "explicacion":"Los frascos de vidrio se reciclan en el contenedor de Vidrio."},
	{"frame":12, "tipo":"vidrio","nombre":"Botella acostada", "explicacion":"Toda botella de vidrio va en el contenedor de Vidrio."},
	{"frame":13, "tipo":"vidrio","nombre":"Frasco con tapa",  "explicacion":"Los frascos de vidrio van en Vidrio, aunque tengan tapa."},
	{"frame":14, "tipo":"vidrio","nombre":"Tubo de ensayo",   "explicacion":"El vidrio de laboratorio va en el contenedor de Vidrio."},
	{"frame":15, "tipo":"vidrio","nombre":"Vaso de vidrio",   "explicacion":"Los vasos de vidrio se reciclan en el contenedor de Vidrio."},
	{"frame":16, "tipo":"vidrio","nombre":"Vaso pequeño",     "explicacion":"Los vasos de vidrio van en el contenedor de Vidrio."},
	{"frame":17, "tipo":"vidrio","nombre":"Botellita",        "explicacion":"Las botellitas de vidrio van en el contenedor de Vidrio."},
	# ── PLÁSTICO ──
	{"frame":22, "tipo":"plastico","nombre":"Botella aplastada","explicacion":"Las botellas de plástico van en el contenedor de Plástico."},
	{"frame":23, "tipo":"plastico","nombre":"Yogur",            "explicacion":"Los envases de yogur son plástico reciclable."},
	{"frame":24, "tipo":"plastico","nombre":"Tapa de plástico", "explicacion":"Las tapas de plástico van en el contenedor de Plástico."},
	{"frame":25, "tipo":"plastico","nombre":"Caja reciclaje",   "explicacion":"Esta caja de plástico va en el contenedor de Plástico."},
	{"frame":26, "tipo":"plastico","nombre":"Bolsa de plástico","explicacion":"Las bolsas de plástico van en el contenedor de Plástico."},
	{"frame":27, "tipo":"plastico","nombre":"Tubo de plástico", "explicacion":"Los tubos de plástico van en el contenedor de Plástico."},
	{"frame":31, "tipo":"plastico","nombre":"Popote",           "explicacion":"Los popotes son plástico, van en el contenedor de Plástico."},
]
const ItemScene = preload("res://entities/basura/ItemMorral.tscn")

# ── ESTADO DEL NIVEL ──────────────────────────────────────────────────────
var cola_objetos: Array = []      # objetos pendientes mezclados
var objeto_actual = null          # el que está en pantalla ahora
var clasificados: int = 0
var total: int = 0
var juego_activo: bool = true
var item_pausado = null
var fb_timer: float = 0.0
var objetos_por_partida: int = 9

# ── MÉTRICAS PARA PANTALLA DE RESULTADOS ─────────────────────────────────
var clasificados_primera: int = 0   # correctos sin fallar ni agotar tiempo
var racha_actual: int = 0
var racha_maxima: int = 0
var fallos: int = 0                 # mal clasificados + tiempos agotados
var desglose: Dictionary = {
	"papel":    0,
	"vidrio":   0,
	"plastico": 0,
}
var objeto_fallado: bool = false    # flag: este objeto ya tuvo un fallo/timeout

# ── TEMPORIZADOR GENERAL ──────────────────────────────────────────────────
var tiempo_limite: float = 30.0
var tiempo_restante: float = 30.0
var timer_activo: bool = false

@onready var bote_papel   = $BotePAPEL
@onready var bote_vidrio  = $BoteVIDRIO
@onready var bote_plastico = $BotePLASTICO
@onready var lbl_puntos   = $Labelpuntos
@onready var lbl_feedback = $LabelFeedBack
@onready var lbl_timer    = $LabelTimer        # ← nodo nuevo para mostrar 8,7,6...
@onready var lbl_vidas    = $LabelVidas        # ← nodo nuevo
@onready var popup        = $InterfazUI/PopUpAyuda
@onready var lbl_explicacion = $InterfazUI/PopUpAyuda/VBoxContainer/LblExplicacion

const GRID_ORIGEN = Vector2(150, 540)   # posición donde aparece el objeto

func _ready():
	lbl_feedback.visible = false
	popup.visible = false
	_preparar_cola()
	_actualizar_hud()
	tiempo_restante = tiempo_limite
	timer_activo = true
	_siguiente_objeto()

func _preparar_cola():
	var todos = OBJETOS.duplicate()
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
	
	if timer_activo and juego_activo:
		tiempo_restante -= delta
		tiempo_restante = max(0, tiempo_restante)

		# Actualizar label numérico
		lbl_timer.text = "%d" % ceil(tiempo_restante)

		# Actualizar barra de progreso
		$BarraTiempo.value = tiempo_restante

		# Cambiar color de barra según urgencia
		if tiempo_restante <= 10:
			$BarraTiempo.modulate = Color("#f87171")  # rojo
		elif tiempo_restante <= 20:
			$BarraTiempo.modulate = Color("#fbbf24")  # amarillo
		else:
			$BarraTiempo.modulate = Color("#86efac")  # verde

		if tiempo_restante <= 0:
			_tiempo_agotado()

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

	SesionGlobal.completar_nivel(1, 2)
	$PantallaResultados.mostrar_resultados(
		clasificados,
		clasificados_primera,
		racha_maxima,
		fallos,
		desglose,
		total,
		faltaron
	)

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
	for bote in [bote_papel, bote_vidrio, bote_plastico]:
		# Usamos la CollisionShape del bote para detectar si el punto cae dentro
		var shape = bote.get_node("CollisionShape2D")
		if shape == null:
			continue
		var rect = shape.shape
		if rect is RectangleShape2D:
			# Convertimos el punto global al espacio local del bote
			var local = bote.to_local(pos)
			var half = rect.size / 2.0
			if abs(local.x) <= half.x and abs(local.y) <= half.y:
				return bote
	return null

func _correcto(_item):

	SesionGlobal.puntaje += 10
	clasificados += 1

	# Métricas
	desglose[_item.tipo] += 1
	racha_actual += 1
	if racha_actual > racha_maxima:
		racha_maxima = racha_actual
	if not objeto_fallado:
		clasificados_primera += 1
	objeto_fallado = false   # reset para el siguiente objeto

	_actualizar_hud()
	_feedback("¡Correcto! +10 pts", Color("#86efac"))
	await get_tree().create_timer(0.6).timeout
	if is_inside_tree() and juego_activo:
		_siguiente_objeto()

func _incorrecto(item, tipo_correcto: String):
	timer_activo = false
	# Métricas
	fallos += 1
	racha_actual = 0
	objeto_fallado = true
	juego_activo = false
	item_pausado = item
	var nombre_obj  = item.nombre      if "nombre"      in item else "Este objeto"
	var explicacion = item.explicacion if "explicacion" in item else ""
	var nombres_botes = {
		"papel":    "Papel 📄",
		"vidrio":   "Vidrio 🟢",
		"plastico": "Plástico 🔵"
	}
	lbl_explicacion.text = "¡Casi! %s va en:\n%s\n\n%s" % [
		nombre_obj,
		nombres_botes[tipo_correcto],
		explicacion
	]
	popup.visible = true

func _actualizar_hud():
	lbl_puntos.text = "Puntos: %d" % SesionGlobal.puntaje
	lbl_vidas.text  = "Vidas: %d" % SesionGlobal.vidas

func _feedback(msg: String, color: Color):
	lbl_feedback.text = msg
	lbl_feedback.add_theme_color_override("font_color", color)
	lbl_feedback.visible = true
	fb_timer = 2.0

func _victoria():
	juego_activo = false
	timer_activo = false
	SesionGlobal.completar_nivel(1, 2)
	$PantallaResultados.mostrar_resultados(
		clasificados,
		clasificados_primera,
		racha_maxima,
		fallos,
		desglose,
		total,
		0   # ← faltaron = 0 porque los clasificó todos
	)
	
func _game_over():
	juego_activo = false
	timer_activo = false
	SesionGlobal.guardar_sesion()
	lbl_feedback.text = "GAME OVER\n%d puntos\n\nPresiona R para reiniciar" % SesionGlobal.puntaje
	lbl_feedback.add_theme_color_override("font_color", Color("#fca5a5"))
	lbl_feedback.visible = true

func _on_popup_entendido_pressed():
	popup.visible = false
	juego_activo = true
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
		if event.button_index == JOY_BUTTON_A:
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
