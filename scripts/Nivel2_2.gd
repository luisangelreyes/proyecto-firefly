extends Node2D
 
# ── CURSOR VIRTUAL PARA MANDO ─────────────────────────────────────────────
var cursor_pos  : Vector2 = Vector2(720, 540)
var cursor_spd  : float   = 900.0
var item_agarrado         = null
var usando_mando: bool    = false
 
@onready var cursor_visual = $CursorMando
 
# ── OBJETOS ───────────────────────────────────────────────────────────────
# METAL:  3 cols x 4 filas → frames 0-11
# MADERA: 4 cols x 3 filas → frames 0-11
# VIDRIO: 3 cols x 4 filas → frames 0-11
 
const OBJETOS = [
	# ── METAL ──
	{"frame":0,  "tipo":"metal", "nombre":"Lata aplastada",   "explicacion":"Las latas de aluminio son metal reciclable, van en el contenedor de Metal."},
	{"frame":1,  "tipo":"metal", "nombre":"Engrane viejo",    "explicacion":"Las piezas de engrane son metal reciclable."},
	{"frame":2,  "tipo":"metal", "nombre":"Tuerca",           "explicacion":"Las tuercas y tornillos son metal reciclable."},
	{"frame":3,  "tipo":"metal", "nombre":"Tornillo",         "explicacion":"Los tornillos son metal y van en el contenedor de Metal."},
	{"frame":4,  "tipo":"metal", "nombre":"Engrane grande",   "explicacion":"Los engranes metalicos son reciclables en el contenedor de Metal."},
	{"frame":5,  "tipo":"metal", "nombre":"Tapa corona",      "explicacion":"Las tapas de botella son metal reciclable."},
	{"frame":6,  "tipo":"metal", "nombre":"Tubo metalico",    "explicacion":"Los tubos metalicos van en el contenedor de Metal."},
	{"frame":7,  "tipo":"metal", "nombre":"Llave inglesa",    "explicacion":"Las herramientas metalicas rotas van en el contenedor de Metal."},
	{"frame":8,  "tipo":"metal", "nombre":"Lata arrugada",    "explicacion":"Las latas de cualquier tipo son metal reciclable."},
	{"frame":9,  "tipo":"metal", "nombre":"Lata abierta",     "explicacion":"Las latas abiertas son metal y van en el contenedor de Metal."},
	{"frame":10, "tipo":"metal", "nombre":"Tuerca grande",    "explicacion":"Las tuercas grandes son metal reciclable."},
	{"frame":11, "tipo":"metal", "nombre":"Tornillo grande",  "explicacion":"Los tornillos grandes son metal reciclable."},
	# ── MADERA ──
	{"frame":0,  "tipo":"madera", "nombre":"Silla rota",      "explicacion":"Los muebles de madera rotos son residuos de madera reciclable."},
	{"frame":1,  "tipo":"madera", "nombre":"Banquillo roto",  "explicacion":"Los banquillos de madera van en el contenedor de Madera."},
	{"frame":2,  "tipo":"madera", "nombre":"Rueda de madera", "explicacion":"Las piezas de madera grandes son residuos reciclables."},
	{"frame":3,  "tipo":"madera", "nombre":"Silla vieja",     "explicacion":"La madera de muebles viejos puede reciclarse o reutilizarse."},
	{"frame":4,  "tipo":"madera", "nombre":"Mesa rota",       "explicacion":"Las mesas de madera rotas van en el contenedor de Madera."},
	{"frame":5,  "tipo":"madera", "nombre":"Marco de madera", "explicacion":"Los marcos de madera son residuos reciclables."},
	{"frame":6,  "tipo":"madera", "nombre":"Caja de madera",  "explicacion":"Las cajas de madera son residuos reciclables de madera."},
	{"frame":7,  "tipo":"madera", "nombre":"Barril roto",     "explicacion":"Los barriles de madera rotos van en el contenedor de Madera."},
	{"frame":8,  "tipo":"madera", "nombre":"Escalera rota",   "explicacion":"Las escaleras de madera rotas son residuos reciclables."},
	{"frame":9,  "tipo":"madera", "nombre":"Caja pequena",    "explicacion":"Las cajas de madera van en el contenedor de Madera."},
	{"frame":10, "tipo":"madera", "nombre":"Tablas rotas",    "explicacion":"Las tablas de madera son residuos reciclables."},
	{"frame":11, "tipo":"madera", "nombre":"Madera suelta",   "explicacion":"Los trozos de madera van en el contenedor de Madera."},
	# ── VIDRIO ──
	{"frame":0,  "tipo":"vidrio", "nombre":"Botella verde",   "explicacion":"Las botellas de vidrio van en el contenedor de Vidrio."},
	{"frame":1,  "tipo":"vidrio", "nombre":"Frasco vacio",    "explicacion":"Los frascos de vidrio se reciclan en el contenedor de Vidrio."},
	{"frame":2,  "tipo":"vidrio", "nombre":"Botella acostada","explicacion":"Toda botella de vidrio va en el contenedor de Vidrio."},
	{"frame":3,  "tipo":"vidrio", "nombre":"Frasco con tapa", "explicacion":"Los frascos de vidrio van en Vidrio aunque tengan tapa."},
	{"frame":4,  "tipo":"vidrio", "nombre":"Vidrio roto",     "explicacion":"Los vidrios rotos son reciclables, manéjalos con cuidado."},
	{"frame":5,  "tipo":"vidrio", "nombre":"Tubo de ensayo",  "explicacion":"El vidrio de laboratorio va en el contenedor de Vidrio."},
	{"frame":6,  "tipo":"vidrio", "nombre":"Vaso de vidrio",  "explicacion":"Los vasos de vidrio se reciclan en el contenedor de Vidrio."},
	{"frame":7,  "tipo":"vidrio", "nombre":"Vaso pequeno",    "explicacion":"Los vasos de vidrio van en el contenedor de Vidrio."},
	{"frame":8,  "tipo":"vidrio", "nombre":"Botellita",       "explicacion":"Las botellitas de vidrio van en el contenedor de Vidrio."},
	{"frame":9,  "tipo":"vidrio", "nombre":"Foco roto",       "explicacion":"Los focos de vidrio son residuos de vidrio reciclable."},
	{"frame":10, "tipo":"vidrio", "nombre":"Esfera de vidrio","explicacion":"Las esferas y adornos de vidrio van en el contenedor de Vidrio."},
	{"frame":11, "tipo":"vidrio", "nombre":"Frasco perfume",  "explicacion":"Los frascos de perfume de vidrio van en el contenedor de Vidrio."},
]
 
const ItemScene = preload("res://entities/basura/ItemMorral_N22.tscn")
 
# ── ESTADO ────────────────────────────────────────────────────────────────
var cola_objetos        : Array = []
var objeto_actual               = null
var clasificados        : int   = 0
var total               : int   = 0
var juego_activo        : bool  = true
var item_pausado                = null
var fb_timer            : float = 0.0
var objetos_por_partida : int   = 9
 
# ── MÉTRICAS ──────────────────────────────────────────────────────────────
var clasificados_primera : int  = 0
var racha_actual         : int  = 0
var racha_maxima         : int  = 0
var fallos               : int  = 0
var desglose : Dictionary = {"metal":0, "madera":0, "vidrio":0}
var objeto_fallado       : bool = false
 
# ── TEMPORIZADOR ──────────────────────────────────────────────────────────
var tiempo_limite   : float = 30.0
var tiempo_restante : float = 30.0
var timer_activo    : bool  = false
 
@onready var bote_metal   = $BoteMETAL
@onready var bote_madera  = $BoteMADERA
@onready var bote_vidrio  = $BoteVIDRIO
@onready var lbl_puntos   = $Labelpuntos
@onready var lbl_feedback = $LabelFeedBack
@onready var lbl_timer    = $LabelTimer
@onready var lbl_vidas    = $LabelVidas
@onready var popup        = $InterfazUI/PopUpAyuda
@onready var lbl_explicacion = $InterfazUI/PopUpAyuda/VBoxContainer/LblExplicacion
 
const GRID_ORIGEN = Vector2(150, 540)
 
 
func _ready():
	SesionGlobal.vidas   = 3
	SesionGlobal.puntaje = 0
	lbl_feedback.visible = false
	popup.visible        = false
	_preparar_cola()
	_actualizar_hud()
	tiempo_restante = tiempo_limite
	timer_activo    = true
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
	
	# Eliminar inmediatamente con free() en vez de queue_free()
	for item in get_tree().get_nodes_in_group("items_morral"):
		item.free()   # ← free() es inmediato, queue_free() es diferido
	objeto_actual = null
	
	if cola_objetos.is_empty():
		_victoria()
		return

	var datos = cola_objetos.pop_front()
	objeto_actual = ItemScene.instantiate()
	add_child(objeto_actual)
	objeto_actual.add_to_group("items_morral")
	objeto_actual.global_position = GRID_ORIGEN
	objeto_actual.pos_origen      = GRID_ORIGEN
	objeto_actual.inicializar(datos, self)
 
 
func _process(delta):
	if fb_timer > 0:
		fb_timer -= delta
		if fb_timer <= 0:
			lbl_feedback.visible = false
 
	if timer_activo and juego_activo:
		tiempo_restante -= delta
		tiempo_restante  = max(0, tiempo_restante)
		lbl_timer.text   = "%d" % ceil(tiempo_restante)
		$BarraTiempo.value = tiempo_restante
		if tiempo_restante <= 10:
			$BarraTiempo.modulate = Color("#f87171")
		elif tiempo_restante <= 20:
			$BarraTiempo.modulate = Color("#fbbf24")
		else:
			$BarraTiempo.modulate = Color("#86efac")
		if tiempo_restante <= 0:
			_tiempo_agotado()
 
	var joy_x = Input.get_axis("ui_left", "ui_right")
	var joy_y = Input.get_axis("ui_up", "ui_down")
	if abs(joy_x) > 0.15 or abs(joy_y) > 0.15:
		usando_mando = true
		cursor_visual.visible = true
	if usando_mando:
		cursor_pos.x += joy_x * cursor_spd * delta
		cursor_pos.y += joy_y * cursor_spd * delta
		cursor_pos.x  = clamp(cursor_pos.x, 0, 1440)
		cursor_pos.y  = clamp(cursor_pos.y, 0, 1080)
		cursor_visual.global_position = cursor_pos - cursor_visual.size / 2
		if item_agarrado and is_instance_valid(item_agarrado):
			item_agarrado.mover_a(cursor_pos)
	if Input.get_last_mouse_velocity().length() > 10:
		usando_mando = false
		cursor_visual.visible = false
		if item_agarrado:
			item_agarrado.soltar()
			item_agarrado = null
 
 
func _tiempo_agotado():
	timer_activo = false
	juego_activo = false
	for item in get_tree().get_nodes_in_group("items_morral"):
		item.queue_free()
	objeto_actual = null
	var faltaron  = cola_objetos.size()
	_feedback("TIEMPO!", Color("#f87171"))
	await get_tree().create_timer(1.8).timeout
	if not is_inside_tree():
		return
	SesionGlobal.completar_nivel(1, 3)
	$PantallaResultados.mostrar_resultados(
		clasificados, clasificados_primera,
		racha_maxima, fallos, desglose, total, faltaron
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
	for bote in [bote_metal, bote_madera, bote_vidrio]:
		var shape = bote.get_node("CollisionShape2D")
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
	SesionGlobal.puntaje += 10
	clasificados         += 1
	desglose[_item.tipo] += 1
	racha_actual         += 1
	if racha_actual > racha_maxima:
		racha_maxima = racha_actual
	if not objeto_fallado:
		clasificados_primera += 1
	objeto_fallado = false
	_item.remove_from_group("items_morral")
	_item.free()   # ← inmediato
	objeto_actual = null
	_actualizar_hud()
	_feedback("Correcto! +10 pts", Color("#86efac"))
	await get_tree().create_timer(0.6).timeout
	if is_inside_tree() and juego_activo:
		_siguiente_objeto()
 
 
func _incorrecto(item, tipo_correcto: String):
	timer_activo   = false
	fallos        += 1
	racha_actual   = 0
	objeto_fallado = true
	juego_activo   = false
	item_pausado   = item
	var nombres_botes = {
		"metal":  "Metal",
		"madera": "Madera",
		"vidrio": "Vidrio",
	}
	lbl_explicacion.text = "Casi! %s va en:\n%s\n\n%s" % [
		item.nombre,
		nombres_botes[tipo_correcto],
		item.explicacion
	]
	popup.visible = true
 
 
func _on_popup_entendido_pressed():
	popup.visible = false
	juego_activo  = true
	timer_activo  = true
	if item_pausado and is_instance_valid(item_pausado):
		item_pausado.volver_origen()
		item_pausado.set_process_input(true)
		item_pausado = null
 
 
func _actualizar_hud():
	lbl_puntos.text = "Puntos: %d" % SesionGlobal.puntaje
	lbl_vidas.text  = "Vidas: %d"  % SesionGlobal.vidas
 
 
func _feedback(msg: String, color: Color):
	lbl_feedback.text = msg
	lbl_feedback.add_theme_color_override("font_color", color)
	lbl_feedback.visible = true
	fb_timer = 2.0
 
 
func _victoria():
	juego_activo = false
	timer_activo = false
	SesionGlobal.completar_nivel(1, 3)
	$PantallaResultados.mostrar_resultados(
		clasificados, clasificados_primera,
		racha_maxima, fallos, desglose, total, 0
	)
 
 
func _game_over():
	juego_activo = false
	timer_activo = false
	lbl_feedback.text = "GAME OVER\n%d puntos\n\nPresiona R para reiniciar" % SesionGlobal.puntaje
	lbl_feedback.add_theme_color_override("font_color", Color("#fca5a5"))
	lbl_feedback.visible = true
 
 
func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R and not juego_activo:
			SesionGlobal.vidas   = 3
			SesionGlobal.puntaje = 0
			get_tree().reload_current_scene()
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
				if is_instance_valid(objeto_actual):
					if cursor_pos.distance_to(objeto_actual.global_position) < 120:
						item_agarrado = objeto_actual
						item_agarrado.agarrar()
			else:
				item_agarrado.soltar()
				item_agarrado = null
		if event.button_index == JOY_BUTTON_B:
			if item_agarrado and is_instance_valid(item_agarrado):
				item_agarrado.siendo_arrastrado_por_cursor = false
				item_agarrado.z_index = 0
				item_agarrado.volver_origen()
				item_agarrado = null
