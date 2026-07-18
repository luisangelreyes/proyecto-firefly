extends Node2D

const ItemScene = preload("res://entities/basura/ItemMorral.tscn")
const SPRITESHEET_N2    = preload("res://entities/basura/sprites/basura_nivel2.png")
const SPRITESHEET_TELA  = preload("res://entities/basura/sprites/basura_tela6.png")
const SPRITESHEET_METAL = preload("res://entities/basura/sprites/basura_metalica3.png")
const SPRITESHEET_INORG = preload("res://entities/basura/sprites/basura_in_or_pelirgo.png")

# ── CATÁLOGO COMPLETO 6 TIPOS ─────────────────────────────────────────────
const CATALOGO = [
	# PAPEL
	{"frame":0,  "tipo":"papel","escala":.35, "nombre":"Periódico",       "explicacion":"El periódico es papel reciclable, va en el contenedor de Papel."},
	{"frame":1,  "tipo":"papel","escala":.35, "nombre":"Cuaderno",        "explicacion":"El cuaderno es papel, recíclalo en el contenedor de Papel."},
	{"frame":2,  "tipo":"papel","escala":.35, "nombre":"Caja de cartón",  "explicacion":"El cartón se recicla junto con el papel."},
	{"frame":3,  "tipo":"papel","escala":.35, "nombre":"Revista",         "explicacion":"Las revistas son papel reciclable."},
	{"frame":4,  "tipo":"papel","escala":.35, "nombre":"Bolsa de papel",  "explicacion":"Las bolsas de papel van en el contenedor de Papel."},
	{"frame":5,  "tipo":"papel","escala":.35, "nombre":"Tubo de cartón",  "explicacion":"Los tubos de cartón son reciclables como papel."},
	{"frame":6,  "tipo":"papel","escala":.35, "nombre":"Caja de leche",   "explicacion":"Las cajas de leche de cartón van en Papel."},
	{"frame":7,  "tipo":"papel","escala":.35, "nombre":"Periódicos",      "explicacion":"Los periódicos apilados son papel reciclable."},
	{"frame":8,  "tipo":"papel","escala":.35, "nombre":"Cartón",          "explicacion":"El cartón corrugado va en el contenedor de Papel."},
	# ── VIDRIO ──
	{"frame":10, "tipo":"vidrio","escala":.35,"nombre":"Botella de vidrio","explicacion":"Las botellas de vidrio van en el contenedor de Vidrio."},
	{"frame":11, "tipo":"vidrio","escala":.35,"nombre":"Frasco",           "explicacion":"Los frascos de vidrio se reciclan en el contenedor de Vidrio."},
	{"frame":12, "tipo":"vidrio","escala":.35,"nombre":"Botella acostada", "explicacion":"Toda botella de vidrio va en el contenedor de Vidrio."},
	{"frame":13, "tipo":"vidrio","escala":.35,"nombre":"Frasco con tapa",  "explicacion":"Los frascos de vidrio van en Vidrio, aunque tengan tapa."},
	{"frame":14, "tipo":"vidrio","escala":.35,"nombre":"Tubo de ensayo",   "explicacion":"El vidrio de laboratorio va en el contenedor de Vidrio."},
	{"frame":15, "tipo":"vidrio","escala":.35,"nombre":"Vaso de vidrio",   "explicacion":"Los vasos de vidrio se reciclan en el contenedor de Vidrio."},
	{"frame":16, "tipo":"vidrio","escala":.35,"nombre":"Vaso pequeño",     "explicacion":"Los vasos de vidrio van en el contenedor de Vidrio."},
	{"frame":17, "tipo":"vidrio","escala":.35,"nombre":"Botellita",        "explicacion":"Las botellitas de vidrio van en el contenedor de Vidrio."},
	# ── PLÁSTICO ──
	{"frame":22, "tipo":"plastico","escala":.35,"nombre":"Botella aplastada","explicacion":"Las botellas de plástico van en el contenedor de Plástico."},
	{"frame":23, "tipo":"plastico","escala":.35,"nombre":"Yogur",            "explicacion":"Los envases de yogur son plástico reciclable."},
	{"frame":24, "tipo":"plastico","escala":.35,"nombre":"Tapa de plástico", "explicacion":"Las tapas de plástico van en el contenedor de Plástico."},
	{"frame":25, "tipo":"plastico","escala":.35,"nombre":"Caja reciclaje",   "explicacion":"Esta caja de plástico va en el contenedor de Plástico."},
	{"frame":26, "tipo":"plastico","escala":.35,"nombre":"Bolsa de plástico","explicacion":"Las bolsas de plástico van en el contenedor de Plástico."},
	{"frame":27, "tipo":"plastico","escala":.35,"nombre":"Tubo de plástico", "explicacion":"Los tubos de plástico van en el contenedor de Plástico."},
	{"frame":31, "tipo":"plastico","escala":.35,"nombre":"Popote",           "explicacion":"Los popotes son plástico, van en el contenedor de Plástico."},
	# ORGÁNICO
	{"frame":26, "sheet":SPRITESHEET_INORG,"cols":7,"filas":6,
	 "tipo":"organico","escala":.2, "nombre":"Restos comida",
	 "explicacion":"Los restos de comida son orgánicos."},
	{"frame":27, "sheet":SPRITESHEET_INORG,"cols":7,"filas":6,
	 "tipo":"organico","escala":.2, "nombre":"Fruta",
	 "explicacion":"Las frutas son residuos orgánicos."},
	{"frame":28, "sheet":SPRITESHEET_INORG,"cols":7,"filas":6,
	 "tipo":"organico","escala":.2, "nombre":"Vegetal",
	 "explicacion":"Los vegetales son residuos orgánicos."},
	# METAL
	{"frame":0, "sheet":SPRITESHEET_METAL,"cols":4,"filas":4,
	 "tipo":"metal", "escala":1.5,   "nombre":"Clavo",
	 "explicacion":"Los metales van en el contenedor de Metal."},
	{"frame":1, "sheet":SPRITESHEET_METAL,"cols":4,"filas":4,
	 "tipo":"metal","escala":1.5,    "nombre":"Tubo metal",
	 "explicacion":"Los tubos metálicos van en Metal."},
	{"frame":2, "sheet":SPRITESHEET_METAL,"cols":4,"filas":4,
	 "tipo":"metal","escala":1.5,    "nombre":"Pieza metal",
	 "explicacion":"Las piezas metálicas van en Metal."},
	# TELA
	{"frame":0, "sheet":SPRITESHEET_TELA, "cols":4,"filas":4,
	 "tipo":"tela","escala":1.5,     "nombre":"Ropa",
	 "explicacion":"La ropa va en el contenedor de Tela."},
	{"frame":1, "sheet":SPRITESHEET_TELA, "cols":4,"filas":4,
	 "tipo":"tela","escala":1.5,     "nombre":"Trapo",
	 "explicacion":"Los trapos van en el contenedor de Tela."},
	{"frame":2, "sheet":SPRITESHEET_TELA, "cols":4,"filas":4,
	 "tipo":"tela","escala":1.5,     "nombre":"Retazo",
	 "explicacion":"Los retazos de tela van en Tela."},
]

# ── CONFIG MODO LIBRE ─────────────────────────────────────────────────────
var dificultad: String     = "normal"
var tiempo_objeto: float   = 8.0
var es_infinito: bool      = true
var timer_sesion: float    = 30.0
var timer_sesion_activo: bool = true

# ── ESTADO ────────────────────────────────────────────────────────────────
var cola_objetos: Array    = []
var objeto_actual          = null
var clasificados: int      = 0
var fallos: int            = 0
var racha_actual: int      = 0
var racha_maxima: int      = 0
var juego_activo: bool     = true
var item_pausado           = null
var fb_timer: float        = 0.0

# ── TEMPORIZADOR RECARGABLE (modo infinito) ───────────────────────────────
var timer_recargable: float  = 30.0
var timer_recargable_max: float = 30.0
var SEGUNDOS_POR_ACIERTO: float = 2.0

# ── TEMPORIZADOR GENERAL (modo normal) ───────────────────────────────────
var tiempo_restante: float = 60.0
var timer_activo: bool     = false

# ── BOTES ─────────────────────────────────────────────────────────────────
const CONFIG_BOTES = [
	{"nodo":"FilaBotes1/BotePAPEL",    "tipo":"papel",    "color":Color("#F4D03F")},
	{"nodo":"FilaBotes1/BoteVIDRIO",   "tipo":"vidrio",   "color":Color("#2ECC71")},
	{"nodo":"FilaBotes1/BotePLASTICO", "tipo":"plastico", "color":Color("#3498DB")},
	{"nodo":"FilaBotes2/BoteORGANICO", "tipo":"organico", "color":Color("#4fb87a")},
	{"nodo":"FilaBotes2/BoteMETAL",    "tipo":"metal",    "color":Color("#95A5A6")},
	{"nodo":"FilaBotes2/BoteTELA",     "tipo":"tela",     "color":Color("#E74C3C")},
]

@onready var lbl_puntos    = $HUD/LabelPuntos
@onready var lbl_residuos  = $HUD/LabelResiduos
@onready var lbl_timer     = $HUD/LabelTimer
@onready var barra_tiempo  = $HUD/BarraTiempo
@onready var lbl_combo     = $HUD/LabelCombo
@onready var popup         = $InterfazUI/PopUpAyuda
@onready var lbl_explic    = $InterfazUI/PopUpAyuda/VBoxContainer/LblExplicacion

const GRID_ORIGEN = Vector2(100, 320)

func _ready():
	SesionGlobal.detener_musica_menu()
	$MusicaFondo.play()
	SesionGlobal.vidas   = 3
	SesionGlobal.puntaje = 0
	popup.visible        = false
	lbl_combo.visible    = false

	var config = SesionGlobal.modo_libre_config
	dificultad  = config.get("dificultad", "normal")
	tiempo_objeto = config.get("tiempo_objeto", 8.0)
	es_infinito = config.get("modo_infinito", false)
	var minutos = config.get("timer_minutos", 0)

	# Aplicar dificultad
	match dificultad:
		"facil":   tiempo_objeto = max(tiempo_objeto, 12.0)
		"dificil": tiempo_objeto = min(tiempo_objeto, 5.0)

	# Configurar botes
	for cfg in CONFIG_BOTES:
		var bote = get_node_or_null(cfg["nodo"])
		if bote:
			bote.set_meta("tipo", cfg["tipo"])

	# Preparar cola
	if es_infinito:
		_preparar_cola_infinita()
		timer_recargable = timer_recargable_max
		barra_tiempo.max_value = timer_recargable_max
		barra_tiempo.value     = timer_recargable_max
		timer_activo = true
	else:
		_preparar_cola_normal()
		if minutos > 0:
			timer_sesion        = float(minutos * 60)
			timer_sesion_activo = true
			barra_tiempo.max_value = timer_sesion
			barra_tiempo.value     = timer_sesion
		timer_activo = true

	# Conectar pausa y game over
	$PantallaPausa.reiniciar_presionado.connect(_reiniciar)
	$PantallaPausa.menu_presionado.connect(_ir_menu)
	$PantallaGameOver.reintentar_presionado.connect(_reiniciar)
	$PantallaGameOver.menu_presionado.connect(_ir_menu)

	_actualizar_hud()
	_siguiente_objeto()
	timer_activo = true
	juego_activo = true

func _preparar_cola_normal():
	cola_objetos = CATALOGO.duplicate()
	cola_objetos.shuffle()

func _preparar_cola_infinita():
	cola_objetos = CATALOGO.duplicate()
	cola_objetos.shuffle()

# ── PROCESS ───────────────────────────────────────────────────────────────
func _process(delta):
	if fb_timer > 0:
		fb_timer -= delta
		if fb_timer <= 0:
			lbl_combo.visible = false

	if not juego_activo or not timer_activo:
		return

	if es_infinito:
		# Timer recargable
		timer_recargable -= delta
		timer_recargable  = max(0, timer_recargable)
		barra_tiempo.value = timer_recargable
		lbl_timer.text     = "%.0f" % ceil(timer_recargable)

		# Color urgencia
		if timer_recargable <= 8:
			barra_tiempo.modulate = Color("#f87171")
		elif timer_recargable <= 15:
			barra_tiempo.modulate = Color("#fbbf24")
		else:
			barra_tiempo.modulate = Color("#86efac")

		if timer_recargable <= 0:
			_game_over("tiempo_agotado")
	else:
		if timer_sesion_activo:
			timer_sesion -= delta
			timer_sesion  = max(0, timer_sesion)
			barra_tiempo.value = timer_sesion
			lbl_timer.text     = "%d" % ceil(timer_sesion)
			if timer_sesion <= 0:
				_terminar_por_tiempo()

# ── SIGUIENTE OBJETO ──────────────────────────────────────────────────────
func _siguiente_objeto():
	if not juego_activo:
		return

	if is_instance_valid(objeto_actual):
		objeto_actual.queue_free()
		objeto_actual = null

	# Recargar cola en modo infinito
	if cola_objetos.is_empty():
		if es_infinito:
			_preparar_cola_infinita()
		else:
			_victoria()
			return

	var datos = cola_objetos.pop_front()
	objeto_actual = ItemScene.instantiate()
	add_child(objeto_actual)
	objeto_actual.global_position = GRID_ORIGEN
	objeto_actual.pos_origen       = GRID_ORIGEN
	objeto_actual.inicializar(datos, self)

func intentar_clasificar(item, pos_soltar: Vector2 = Vector2.ZERO):
	if not juego_activo:
		item.volver_origen()
		return
	var pos        = pos_soltar if pos_soltar != Vector2.ZERO else item.global_position
	var bote_target = _get_bote_en(pos)
	if bote_target == null:
		item.volver_origen()
		return
	if bote_target.get_meta("tipo") == item.tipo:
		_correcto(item)
	else:
		_incorrecto(item, item.tipo)
		
func _get_bote_en(pos: Vector2):
	for cfg in CONFIG_BOTES:
		var bote = get_node_or_null(cfg["nodo"])
		if not bote:
			continue
		var shape_node = bote.get_node_or_null("CollisionShape2D")
		if not shape_node:
			continue
		var rect = shape_node.shape
		if rect is RectangleShape2D:
			# Restamos el offset del CollisionShape2D dentro del Area2D
			var local = bote.to_local(pos) - shape_node.position
			var half  = rect.size / 2.0
			if abs(local.x) <= half.x and abs(local.y) <= half.y:
				return bote
	return null

# ── CORRECTO ──────────────────────────────────────────────────────────────
func _correcto(_item):
	$AudioAcierto.play()
	clasificados += 1
	racha_actual  += 1
	if racha_actual > racha_maxima:
		racha_maxima = racha_actual
	SesionGlobal.puntaje += 10

	if es_infinito:
		timer_recargable = min(
			timer_recargable + SEGUNDOS_POR_ACIERTO,
			timer_recargable_max
		)
		barra_tiempo.modulate = Color("#86efac")

	_mostrar_combo()
	_actualizar_hud()

	await get_tree().create_timer(0.4).timeout
	if is_inside_tree() and juego_activo:
		_siguiente_objeto()

# ── INCORRECTO ────────────────────────────────────────────────────────────
func _incorrecto(item, tipo_correcto: String):
	$AudioError.play()
	fallos       += 1
	racha_actual  = 0
	juego_activo  = false
	item_pausado  = item

	var nombres = {
		"papel":"Papel","vidrio":"Vidrio","plastico":"Plástico",
		"organico":"Orgánico","metal":"Metal","tela":"Tela"
	}
	lbl_explic.text = "¡Casi! %s va en:\n%s\n\n%s" % [
		item.nombre,
		nombres.get(tipo_correcto, tipo_correcto),
		item.explicacion if "explicacion" in item else ""
	]
	popup.visible = true

func _on_popup_entendido_pressed():
	popup.visible = false
	juego_activo  = true
	if item_pausado and is_instance_valid(item_pausado):
		item_pausado.volver_origen()
		item_pausado.set_process_input(true)
		item_pausado = null

# ── COMBO VISUAL ──────────────────────────────────────────────────────────
func _mostrar_combo():
	if racha_actual >= 2:
		lbl_combo.text = "🔥 x%d" % racha_actual
		lbl_combo.visible = true
		fb_timer = 1.5

# ── HUD ───────────────────────────────────────────────────────────────────
func _actualizar_hud():
	lbl_puntos.text   = "Puntos: %d" % SesionGlobal.puntaje
	lbl_residuos.text = "Clasificados: %d" % clasificados

# ── GAME OVER / VICTORIA ──────────────────────────────────────────────────
func _game_over(causa: String):
	$MusicaFondo.stop()
	juego_activo = false
	timer_activo = false
	lbl_timer.visible = false
	SesionGlobal.guardar_sesion()
	await get_tree().create_timer(0.8).timeout
	if is_inside_tree():
		$PantallaGameOver.mostrar(causa)

func _terminar_por_tiempo():
	timer_activo = false
	juego_activo = false
	SesionGlobal.guardar_sesion()
	_mostrar_resultados()

func _victoria():
	timer_activo = false
	juego_activo = false
	SesionGlobal.guardar_sesion()
	_mostrar_resultados()

func _mostrar_resultados():
	$MusicaFondo.stop()
	$AudioVictoria.play()
	$PantallaResultadosClasificacion.mostrar_resultados(
		clasificados,
		clasificados,   # primera vez — simplificado para modo libre
		racha_maxima,
		fallos,
		{},             # sin desglose por categoría en modo libre
		clasificados + cola_objetos.size(),
		0
	)

func _reiniciar():
	Engine.time_scale = 1.0
	Engine.get_main_loop().change_scene_to_file(
        "res://scenes/niveles/NivelClasificacionModoLibre.tscn"
	)

func _ir_menu():
	Engine.time_scale = 1.0
	Engine.get_main_loop().change_scene_to_file(
        "res://ui/menu/ModoLibre.tscn"
	)





func _on_button_pressed() -> void:
	_on_popup_entendido_pressed()
