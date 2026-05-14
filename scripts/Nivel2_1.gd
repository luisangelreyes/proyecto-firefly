extends Node2D
 
# ── CURSOR VIRTUAL PARA MANDO ─────────────────────────────────────────────
var cursor_pos  : Vector2 = Vector2(720, 540)
var cursor_spd  : float   = 900.0
var item_agarrado         = null
var usando_mando: bool    = false
 
@onready var cursor_visual = $CursorMando
 
# ── OBJETOS DEL MORRAL ────────────────────────────────────────────────────
# frame = fila * cols + columna
# TELA:       4 cols x 4 filas (frames 0-15)
# ORGANICO:   3 cols x 4 filas (frames 0-11)
# INORGANICO: 3 cols x 4 filas (frames 0-11)
 
const OBJETOS = [
	# ── TELA ──
	{"frame":0,  "tipo":"tela", "nombre":"Camiseta rota",    "explicacion":"La ropa vieja es residuo textil, puede donarse o reciclarse en el contenedor de Tela."},
	{"frame":1,  "tipo":"tela", "nombre":"Ropa arrugada",    "explicacion":"La ropa en mal estado va en el contenedor de Tela."},
	{"frame":2,  "tipo":"tela", "nombre":"Cobija roja",      "explicacion":"Las cobijas viejas son residuos textiles, van en el contenedor de Tela."},
	{"frame":3,  "tipo":"tela", "nombre":"Pantalon viejo",   "explicacion":"Los pantalones usados son residuos textiles reciclables."},
	{"frame":4,  "tipo":"tela", "nombre":"Costal",           "explicacion":"Los costales de tela van en el contenedor de Tela."},
	{"frame":5,  "tipo":"tela", "nombre":"Gorra vieja",      "explicacion":"Las gorras y sombreros viejos son residuos textiles."},
	{"frame":6,  "tipo":"tela", "nombre":"Calcetines",       "explicacion":"Los calcetines viejos son residuos textiles reciclables."},
	{"frame":7,  "tipo":"tela", "nombre":"Lona verde",       "explicacion":"Las lonas y telas gruesas son residuos textiles."},
	{"frame":8,  "tipo":"tela", "nombre":"Camiseta oscura",  "explicacion":"Toda ropa en mal estado va en el contenedor de Tela."},
	{"frame":9,  "tipo":"tela", "nombre":"Cobija vieja",     "explicacion":"Las cobijas desgastadas son residuos textiles reciclables."},
	{"frame":10, "tipo":"tela", "nombre":"Guante viejo",     "explicacion":"Los guantes usados van en el contenedor de Tela."},
	{"frame":11, "tipo":"tela", "nombre":"Ropa doblada",     "explicacion":"La ropa que ya no se usa es residuo textil reciclable."},
	# ── ORGANICO ──
	{"frame":0,  "tipo":"organico", "nombre":"Cascara de banana",  "explicacion":"Las cascaras de frutas son residuos organicos, se compostan naturalmente."},
	{"frame":1,  "tipo":"organico", "nombre":"Manzana mordida",    "explicacion":"Los restos de fruta son organicos y se descomponen naturalmente."},
	{"frame":2,  "tipo":"organico", "nombre":"Jengibre",           "explicacion":"Los vegetales y raices son residuos organicos."},
	{"frame":3,  "tipo":"organico", "nombre":"Cascara de huevo",   "explicacion":"Las cascaras de huevo son organicas y sirven para compostar."},
	{"frame":4,  "tipo":"organico", "nombre":"Bolsa de te",        "explicacion":"Las bolsas de te usadas son residuos organicos."},
	{"frame":5,  "tipo":"organico", "nombre":"Zanahoria",          "explicacion":"Los restos de verduras son residuos organicos."},
	{"frame":6,  "tipo":"organico", "nombre":"Pan mohoso",         "explicacion":"Los alimentos en mal estado son residuos organicos."},
	{"frame":7,  "tipo":"organico", "nombre":"Fruta podrida",      "explicacion":"La fruta descompuesta es residuo organico, buena para compostar."},
	{"frame":8,  "tipo":"organico", "nombre":"Espina de pescado",  "explicacion":"Los restos de comida como espinas son residuos organicos."},
	# ── INORGANICO ──
	{"frame":0,  "tipo":"inorganico", "nombre":"Lata aplastada",   "explicacion":"Las latas de aluminio son inorganicas y altamente reciclables."},
	{"frame":1,  "tipo":"inorganico", "nombre":"Botella aplastada","explicacion":"Las botellas de plastico son residuos inorganicos reciclables."},
	{"frame":2,  "tipo":"inorganico", "nombre":"Caja de leche",    "explicacion":"Los envases Tetra Pak son inorganicos, van en el contenedor gris."},
	{"frame":3,  "tipo":"inorganico", "nombre":"Vidrio roto",      "explicacion":"Los vidrios rotos son inorganicos, manéjalos con cuidado."},
	{"frame":4,  "tipo":"inorganico", "nombre":"Bolsa de basura",  "explicacion":"Las bolsas de plastico son residuos inorganicos."},
	{"frame":5,  "tipo":"inorganico", "nombre":"Vaso desechable",  "explicacion":"Los vasos desechables son inorganicos no biodegradables."},
	{"frame":6,  "tipo":"inorganico", "nombre":"Periodico",        "explicacion":"El papel periodico es inorganico reciclable."},
	{"frame":7,  "tipo":"inorganico", "nombre":"Caja de carton",   "explicacion":"El carton es inorganico y muy reciclable."},
	{"frame":8,  "tipo":"inorganico", "nombre":"Lata de atun",     "explicacion":"Las latas de conserva son inorganicas y reciclables."},
	{"frame":9,  "tipo":"inorganico", "nombre":"Periodico enrollado","explicacion":"El papel y carton son residuos inorganicos reciclables."},
	{"frame":10, "tipo":"inorganico", "nombre":"Lata abierta",     "explicacion":"Las latas metalicas son inorganicas y reciclables."},
	{"frame":11, "tipo":"inorganico", "nombre":"Tapa de refresco", "explicacion":"Las tapas metalicas son residuos inorganicos reciclables."},
]
 
const ItemScene = preload("res://entities/basura/ItemMorral_N21.tscn")
 
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
var desglose : Dictionary = {"tela":0, "organico":0, "inorganico":0}
var objeto_fallado       : bool = false
 
# ── TEMPORIZADOR ──────────────────────────────────────────────────────────
var tiempo_limite    : float = 30.0
var tiempo_restante  : float = 30.0
var timer_activo     : bool  = false
 
@onready var bote_tela       = $BoteTELA
@onready var bote_organico   = $BoteORGANICO
@onready var bote_inorganico = $BoteINORGANICO
@onready var lbl_puntos      = $Labelpuntos
@onready var lbl_feedback    = $LabelFeedBack
@onready var lbl_timer       = $LabelTimer
@onready var lbl_vidas       = $LabelVidas
@onready var popup           = $InterfazUI/PopUpAyuda
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
	# Limpiar objeto anterior
	for item in get_tree().get_nodes_in_group("items_morral"):
		item.queue_free()
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
 
	# ── MANDO ──────────────────────────────────────────────────────────────
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
	var faltaron = cola_objetos.size()
	_feedback("TIEMPO!", Color("#f87171"))
	await get_tree().create_timer(1.8).timeout
	if not is_inside_tree():
		return
	SesionGlobal.completar_nivel(1, 2)
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
	for bote in [bote_tela, bote_organico, bote_inorganico]:
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
	_actualizar_hud()
	_feedback("Correcto! +10 pts", Color("#86efac"))
	await get_tree().create_timer(0.6).timeout
	if is_inside_tree() and juego_activo:
		_siguiente_objeto()
 
 
func _incorrecto(item, tipo_correcto: String):
	# El timer se PAUSA mientras el popup está visible
	timer_activo   = false
	fallos        += 1
	racha_actual   = 0
	objeto_fallado = true
	juego_activo   = false
	item_pausado   = item
	var nombres_botes = {
		"tela":       "Tela",
		"organico":   "Organico",
		"inorganico": "Inorganico",
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
	# Reanudar el timer al cerrar el popup
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
	SesionGlobal.completar_nivel(1, 2)
	$PantallaResultados.mostrar_resultados(
		clasificados, clasificados_primera,
		racha_maxima, fallos, desglose, total, 0
	)
 
 
func _game_over():
	juego_activo = false
	timer_activo = false
	SesionGlobal.guardar_sesion()
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
 
