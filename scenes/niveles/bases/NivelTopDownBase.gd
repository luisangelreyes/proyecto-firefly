extends Node2D

# ── CONFIGURACIÓN (sobreescribible por hijos) ─────────────────────────────
var tiempo_limite: float = 90.0
var cantidad_normales: int = 10
var cantidad_peligrosos: int = 40
var catalogo_basura: Array = []
var sprite_sheet: Texture2D = null
var escena_nivel_actual: String = ""  # ruta para reiniciar

# ── ESTADO ────────────────────────────────────────────────────────────────
var tiempo_restante: float = 0.0
var timer_activo: bool = false
var juego_activo: bool = false
var total_residuos: int = 0
var recogidos: int = 0
var racha_actual: int = 0
var racha_maxima: int = 0
var timer_juego: Timer

signal tiempo_actualizado(tiempo: float)
signal bote_cambiado(bote_id: int)
signal residuos_actualizados(recogidos: int, total: int)
signal max_tiempo_configurado(tiempo_max: float)

var escena_residuo: PackedScene = preload("res://entities/basura/ResiduoTopDown.tscn")

@onready var eli               = $Mundo/Eli
@onready var contenedor_res    = $Mundo/Residuos
@onready var contenedor_zonas  = $Mundo/ZonasSpawn
@onready var bote_no_reciclables = $BoteNoReciclables
@onready var camara            = $Mundo/Eli/Camera2D
@onready var hit_counter       = $HitCounter

const NOMBRES_BOTE = ["Orgánico", "Inorgánico"]
const COLOR_BOTE   = [Color("00f969ff"), Color("0e95ffff")]

func _ready():
	SesionGlobal.vidas   = 1
	SesionGlobal.puntaje = 0

	var hud_script = load("res://ui/general/hud_topdown.gd")
	$HUD.set_script(hud_script)
	$HUD.setup()
	self.tiempo_actualizado.connect($HUD._on_tiempo_actualizado)
	self.bote_cambiado.connect($HUD._on_bote_cambiado)
	self.residuos_actualizados.connect($HUD._on_residuos_actualizados)
	self.max_tiempo_configurado.connect($HUD._on_max_tiempo_configurado)

	tiempo_restante = tiempo_limite
	max_tiempo_configurado.emit(tiempo_limite)

	_generar_residuos_aleatorios(cantidad_normales, "normal")
	_generar_residuos_aleatorios(cantidad_peligrosos, SesionGlobal.Categorias.PELIGROSO)

	for residuo in contenedor_res.get_children():
		if residuo.is_in_group(SesionGlobal.Grupos.RESIDUO_TD):
			if residuo.tipo != SesionGlobal.Categorias.PELIGROSO:
				total_residuos += 1
			residuo.recogido_correcto.connect(_on_residuo_correcto)
			residuo.recogido_incorrecto.connect(_on_residuo_incorrecto)
			residuo.peligroso_tocado.connect(_on_peligroso_tocado)

	eli.recogida_intentada.connect(_on_recogida_intentada)

	$PantallaPausa.reiniciar_presionado.connect(_reiniciar)
	$PantallaPausa.menu_presionado.connect(_ir_menu)
	$PantallaGameOver.reintentar_presionado.connect(_reiniciar)
	$PantallaGameOver.menu_presionado.connect(_ir_menu)

	residuos_actualizados.emit(0, total_residuos)
	_actualizar_bote()
	
	timer_juego = Timer.new()
	timer_juego.wait_time = 0.1
	timer_juego.autostart = false
	timer_juego.timeout.connect(_on_timer_tick)
	add_child(timer_juego)

	await get_tree().create_timer(0.5).timeout
	if is_inside_tree():
		juego_activo = true
		timer_activo = true
		timer_juego.start()

func _on_timer_tick():
	if not juego_activo or not timer_activo:
		return
	
	tiempo_restante -= 0.1
	tiempo_restante = max(0, tiempo_restante)
	tiempo_actualizado.emit(tiempo_restante)

	if tiempo_restante <= 0:
		timer_juego.stop()
		_tiempo_agotado()

func _process(_delta):
	if not juego_activo:
		return
	_actualizar_bote()

func _actualizar_bote():
	bote_cambiado.emit(eli.bote_activo)

func _on_recogida_intentada(_tipo: String, _bote: int):
	pass

func _on_residuo_correcto(_tipo: String):
	recogidos += 1
	racha_actual += 1
	if racha_actual > racha_maxima:
		racha_maxima = racha_actual
	SesionGlobal.puntaje += 10
	residuos_actualizados.emit(recogidos, total_residuos)
	hit_counter.registrar_acierto(racha_actual)
	if recogidos >= total_residuos:
		_victoria()

func _on_residuo_incorrecto(_tipo: String):
	racha_actual = 0
	hit_counter.registrar_fallo()
	_game_over("clasificacion_incorrecta")

func _on_peligroso_tocado():
	racha_actual = 0
	hit_counter.registrar_fallo()
	_game_over("residuo_peligroso")

func _tiempo_agotado():
	_game_over("tiempo_agotado")

func _game_over(causa: String):
	juego_activo = false
	timer_activo = false
	SesionGlobal.guardar_sesion()
	await get_tree().create_timer(0.8).timeout
	if not is_inside_tree():
		return
	if causa == "tiempo_agotado" and recogidos > 0:
		_mostrar_resultado(false)
	else:
		$PantallaGameOver.mostrar(causa)

func _victoria():
	juego_activo = false
	timer_activo = false
	SesionGlobal.completar_nivel(
		SesionGlobal.mundo_actual,
		SesionGlobal.nivel_actual
	)
	SesionGlobal.guardar_sesion()
	_activar_iman_contencion()
	await get_tree().create_timer(1.5).timeout
	if is_inside_tree():
		_mostrar_resultado(true)

func _activar_iman_contencion():
	$BoteNoReciclables.visible = true
	var centro = bote_no_reciclables.get_node("PuntoDeEntrada").global_position
	var tween  = create_tween()
	tween.tween_property(camara, "global_position", centro, 0.8)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for residuo in contenedor_res.get_children():
		if residuo.tipo == SesionGlobal.Categorias.PELIGROSO:
			residuo.ser_succionado(centro)
	await get_tree().create_timer(1.6).timeout

func _mostrar_resultado(victoria: bool):
	$PantallaResultadosTopDown.mostrar_resultados(
		victoria, recogidos, total_residuos,
		tiempo_restante, racha_maxima
	)

func _reiniciar():
	Engine.get_main_loop().change_scene_to_file(escena_nivel_actual)

func _ir_menu():
	Engine.get_main_loop().change_scene_to_file("res://ui/menu/menu.tscn")

func _generar_residuos_aleatorios(cantidad: int, filtro: String = "todos"):
	if catalogo_basura.is_empty() or sprite_sheet == null:
		push_error("NivelTopDownBase: catalogo_basura o sprite_sheet no configurados")
		return

	var generados      = 0
	var space_state    = get_world_2d().direct_space_state
	var zonas          = contenedor_zonas.get_children()
	if zonas.is_empty():
		return

	var catalogo_filtrado = catalogo_basura.filter(func(item):
		if filtro == "todos":        return true
		if filtro == SesionGlobal.Categorias.PELIGROSO:    return item["tipo"] == SesionGlobal.Categorias.PELIGROSO
		if filtro == "normal":       return item["tipo"] != SesionGlobal.Categorias.PELIGROSO
		return true
	)
	if catalogo_filtrado.is_empty():
		return

	var query  = PhysicsShapeQueryParameters2D.new()
	var shape  = CircleShape2D.new()
	shape.radius = 25.0
	query.shape  = shape

	var intentos_maximos  = cantidad * 50
	var intentos          = 0
	var posiciones_usadas: Array[Vector2] = []
	var distancia_minima  = 90.0
	var radio_zona_segura = 200.0

	while generados < cantidad and intentos < intentos_maximos:
		intentos += 1
		var zona   = zonas.pick_random()
		var rect   = zona.get_global_rect()
		var punto  = Vector2(
			randf_range(rect.position.x, rect.end.x),
			randf_range(rect.position.y, rect.end.y)
		)

		if punto.distance_to(eli.global_position) < radio_zona_segura:
			continue

		var muy_cerca = false
		for pos in posiciones_usadas:
			if punto.distance_to(pos) < distancia_minima:
				muy_cerca = true
				break
		if muy_cerca:
			continue

		query.transform = Transform2D(0, punto)
		if not space_state.intersect_shape(query).is_empty():
			continue

		var residuo = escena_residuo.instantiate()
		residuo.global_position = punto
		residuo.scale = Vector2(0.3, 0.3)

		var data = catalogo_filtrado.pick_random()
		residuo.tipo   = data["tipo"]
		residuo.nombre = data["nombre"]

		var atlas        = AtlasTexture.new()
		atlas.atlas      = sprite_sheet
		atlas.region     = data["region"]
		residuo.icono    = atlas

		contenedor_res.add_child(residuo)
		posiciones_usadas.append(punto)
		generados += 1
