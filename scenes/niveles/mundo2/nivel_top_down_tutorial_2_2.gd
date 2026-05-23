extends "res://scripts/NivelTopDownBase.gd"

# ── CONFIGURACIÓN TUTORIAL ────────────────────────────────────────────────
const DURACION_OLEADA   = 20.0
const RADIO_SPAWN_CERCA = 350.0   # residuos normales cerca de Eli
const RADIO_SEGURO_PELI = 500.0   # peligrosos lejos de Eli

var oleada_actual_tut: int = 0
var timer_oleada: float = 0.0
var oleada_activa: bool = false
var tutorial_activo: bool = true
var _hint_organico_dado: bool = false
var _hint_inorganico_dado: bool = false
var _hint_peligroso_dado: bool = false

@onready var dialogo    = $DialogoTutorial
@onready var lbl_oleada = $HUD/LabelOleada   

func _ready():
	tiempo_limite       = 999.0   # sin límite real
	cantidad_normales   = 0
	cantidad_peligrosos = 0
	escena_nivel_actual = \
        "res://scenes/niveles/Mundo2/NivelTopDownTutorial2_2.tscn"

	sprite_sheet = preload(
        "res://entities/basura/sprites/basura_in_or_pelirgo.png"
	)

	catalogo_basura = [
		{"tipo":"organico",  "nombre":"manzana",
		 "region":Rect2(2400,2400,800,800)},
		{"tipo":"organico",  "nombre":"platano",
		 "region":Rect2(1600,3200,800,800)},
		{"tipo":"organico",  "nombre":"elote",
		 "region":Rect2(0,2400,800,800)},
		{"tipo":"organico",  "nombre":"naranja",
		 "region":Rect2(4800,2400,800,800)},
		{"tipo":"inorganico","nombre":"lata_aplastada",
		 "region":Rect2(0,0,800,800)},
		{"tipo":"inorganico","nombre":"botella_plastico",
		 "region":Rect2(800,0,800,800)},
		{"tipo":"inorganico","nombre":"caja_carton",
		 "region":Rect2(4800,0,800,800)},
		{"tipo":"inorganico","nombre":"periodico",
		 "region":Rect2(4000,0,800,800)},
		{"tipo":"peligroso", "nombre":"jeringa",
		 "region":Rect2(4800,4000,800,800)},
		{"tipo":"peligroso", "nombre":"bateria",
		 "region":Rect2(4000,4000,800,800)},
		{"tipo":"peligroso", "nombre":"cigarro",
		 "region":Rect2(0,4800,800,800)},
	]

	super()

	juego_activo = false
	timer_activo = false
	barra_tiempo.visible = false
	if has_node("HUD/LabelOleada"):
		lbl_oleada.visible = false

	dialogo.dialogo_terminado.connect(_on_dialogo_terminado)

	await get_tree().create_timer(0.5).timeout
	_mostrar_intro()
	barra_tiempo.visible = false
	if has_node("HUD/LabelTiempo"): 
		$HUD/LabelTiempo.visible = false

# ── INTRO ─────────────────────────────────────────────────────────────────
func _mostrar_intro():
	dialogo.iniciar([
		"¡Mija, este barrio está hecho un desastre!\nVamos a practicar antes de la jornada real.",
		"Usa [color=#e8c428]FLECHAS o WASD[/color] para moverte.\nPresiona [color=#e8c428]E o A[/color] para recoger residuos.",
		"Cambia de bote con [color=#e8c428]ESPACIO[/color] según\nel tipo de residuo. ¡Vamos!",
	])
func _on_dialogo_terminado():

	if oleada_activa:
		return
	_iniciar_oleada(oleada_actual_tut)

func _iniciar_oleada(oleada: int):
	_limpiar_residuos()
	oleada_activa = true
	timer_oleada  = DURACION_OLEADA
	juego_activo  = true
	recogidos     = 0

	match oleada:
		0:
			if has_node("HUD/LabelOleada"):
				lbl_oleada.text = "Práctica 1 — Orgánicos e Inorgánicos"
				lbl_oleada.visible = true
			_spawnear_cerca(4, "organico")
			_spawnear_cerca(4, "inorganico")
			
		1:
			if has_node("HUD/LabelOleada"):
				lbl_oleada.text = "Práctica 2 — ¡Cuidado con los peligrosos!"
			_spawnear_cerca(5, "organico")
			_spawnear_cerca(5, "inorganico")
			_spawnear_cerca(5, "peligroso") 
			
		2:
			if has_node("HUD/LabelOleada"):
				lbl_oleada.text = "Práctica 3 — Examen Final"
			_spawnear_cerca(3, "organico")
			_spawnear_cerca(3, "inorganico")
			_spawnear_cerca(3, "peligroso")
			_spawnear_lejos(3, "organico")
			_spawnear_lejos(3, "inorganico")
			_spawnear_lejos(7, "peligroso")
			
		3:
			_finalizar_tutorial()
			return

	# ── CONTADOR DINÁMICO AUTOMÁTICO ──
	# Contamos físicamente cuántos objetos reales (que no sean peligrosos) 
	# lograron aparecer con éxito en el contenedor. ¡Cero números hardcodeados!
	total_residuos = 0
	for r in contenedor_res.get_children():
		if r.tipo != "peligroso":
			total_residuos += 1
			
	lbl_residuos.text = "Residuos: 0 / %d" % total_residuos

func _process(delta):
	super(delta)
# ── SPAWN CONTROLADO ──────────────────────────────────────────────────────
func _spawnear_cerca(cantidad: int, tipo_filtro: String):
	var catalogo_f = catalogo_basura.filter(
		func(i): return i["tipo"] == tipo_filtro
	)
	var generados = 0
	var intentos  = 0

	while generados < cantidad and intentos < cantidad * 30:
		intentos += 1
		# Spawn en radio cercano a Eli
		var angulo = randf_range(0, TAU)
		var radio  = randf_range(150.0, RADIO_SPAWN_CERCA)
		var punto  = eli.global_position + Vector2(
			cos(angulo) * radio,
			sin(angulo) * radio
		)

		if not _punto_valido(punto):
			continue

		var r = _crear_residuo(catalogo_f.pick_random(), punto)
		if r:
			_conectar_residuo(r)
			generados += 1

func _spawnear_lejos(cantidad: int, tipo_filtro: String):
	var catalogo_f = catalogo_basura.filter(
		func(i): return i["tipo"] == tipo_filtro
	)
	var generados = 0
	var intentos  = 0
	var zonas     = contenedor_zonas.get_children()

	while generados < cantidad and intentos < cantidad * 30:
		intentos += 1
		var zona  = zonas.pick_random()
		var rect  = zona.get_global_rect()
		var punto = Vector2(
			randf_range(rect.position.x, rect.end.x),
			randf_range(rect.position.y, rect.end.y)
		)

		# Garantizar distancia mínima con Eli
		if punto.distance_to(eli.global_position) < RADIO_SEGURO_PELI:
			continue

		if not _punto_valido(punto):
			continue

		var r = _crear_residuo(catalogo_f.pick_random(), punto)
		if r:
			_conectar_residuo(r)
			generados += 1

func _punto_valido(punto: Vector2) -> bool:
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius  = 25.0
	query.shape   = shape
	query.transform = Transform2D(0, punto)
	return space.intersect_shape(query).is_empty()

func _crear_residuo(data: Dictionary, punto: Vector2) -> Node:
	var r = escena_residuo.instantiate()
	r.global_position = punto
	r.scale           = Vector2(0.3, 0.3)
	r.tipo            = data["tipo"]
	r.nombre          = data["nombre"]
	var atlas         = AtlasTexture.new()
	atlas.atlas       = sprite_sheet
	atlas.region      = data["region"]
	r.icono           = atlas
	contenedor_res.add_child(r)
	return r

func _conectar_residuo(r: Node):
	r.recogido_correcto.connect(_on_residuo_correcto_tut)
	r.recogido_incorrecto.connect(_on_residuo_incorrecto_tut)
	r.peligroso_tocado.connect(_on_peligroso_tut)

# ── CALLBACKS ─────────────────────────────────────────────────────────────
func _on_residuo_correcto_tut(tipo: String):
	recogidos += 1
	racha_actual += 1
	if racha_actual > racha_maxima:
		racha_maxima = racha_actual
	SesionGlobal.puntaje += 10
	lbl_residuos.text = "Residuos: %d / %d" % [recogidos, total_residuos]
	hit_counter.registrar_acierto(racha_actual)

	_revisar_victoria_oleada()


func _on_residuo_incorrecto_tut(tipo: String):
	racha_actual = 0
	hit_counter.registrar_fallo()
	
	# FIX: Reducimos el total_residuos para que no se quede bloqueado el nivel
	# si el jugador destruye un objeto por equivocarse de bote.
	total_residuos -= 1
	# Evitamos que el total baje de los que ya hemos recogido
	if total_residuos < recogidos:
		total_residuos = recogidos 
		
	lbl_residuos.text = "Residuos: %d / %d" % [recogidos, total_residuos]

	# Diálogo de error
	if tipo == "organico":
		dialogo.iniciar([
			"¡Ese era [color=#4fb87a]ORGÁNICO[/color]!\nNecesita el [color=#4fb87a]bote verde[/color]. ¡Inténtalo de nuevo!"
		])
	else:
		dialogo.iniciar([
			"¡Ese era [color=#4a8fd4]INORGÁNICO[/color]!\nNecesita el [color=#4a8fd4]bote azul[/color]. ¡Inténtalo de nuevo!"
		])
		
	_revisar_victoria_oleada()
	
func _on_peligroso_tut():
	racha_actual = 0
	hit_counter.registrar_fallo()
	# Sin game over — solo mensaje y el residuo peligroso rebota
	dialogo.iniciar([
        "[color=#d44a4a]¡Cuidado![/color] Los residuos peligrosos hacen daño.\n¡Mantente alejada de ellos!"
	])

func _terminar_oleada_exitosa():
	match oleada_actual_tut:
		0: dialogo.iniciar([
			"¡Excelente limpieza!\nAhora vamos a complicarlo: mezclaremos todo y aparecerán residuos peligrosos."
		])
		1: dialogo.iniciar([
			"¡Muy bien!\nÚltima prueba: la basura estará esparcida por todas partes. ¡Búscala!"
		])
		2: dialogo.iniciar([
			"¡Lo lograste! Ya tienes todo lo que necesitas\npara limpiar el barrio. ¡Ándale!"
		])
	oleada_actual_tut += 1

func _terminar_oleada_por_tiempo():
	oleada_activa = false
	juego_activo  = false
	_limpiar_residuos_peligrosos()
	
	match oleada_actual_tut:
		0: dialogo.iniciar([
			"Se acabó el tiempo, pero vas entendiendo.\n¡Cuidado ahora, que vienen los peligrosos!"
		])
		1: dialogo.iniciar([
			"¡Tiempo! Vamos al examen final.\nTendrás que moverte por todo el mapa."
		])
		2: dialogo.iniciar([
			"¡Tiempo! Ya practicaste suficiente.\n¡Al nivel real!"
		])
	oleada_actual_tut += 1
# ── FINALIZAR ─────────────────────────────────────────────────────────────
func _finalizar_tutorial():
	tutorial_activo = false
	_limpiar_residuos()
	SesionGlobal.completar_nivel(2, 2)
	SesionGlobal.guardar_sesion()
	Engine.get_main_loop().change_scene_to_file(
        "res://scenes/menu/ModoAventura2.tscn"
	)

# ── UTILIDADES ────────────────────────────────────────────────────────────
func _limpiar_residuos():
	for r in contenedor_res.get_children():
		r.queue_free()
	total_residuos = 0
	recogidos      = 0

func _limpiar_residuos_peligrosos():
	if not has_node("BoteNoReciclables"):
		return
	var centro = bote_no_reciclables.get_node("PuntoDeEntrada").global_position
	for r in contenedor_res.get_children():
		if is_instance_valid(r) and r.tipo == "peligroso":
			r.ser_succionado(centro)
func _revisar_victoria_oleada():
	# Si ya recogimos todo lo que quedaba en pantalla (o si el total llegó a 0)
	if recogidos >= total_residuos:
		juego_activo = false
		oleada_activa = false
		await get_tree().create_timer(0.8).timeout
		if is_inside_tree():
			_terminar_oleada_exitosa()
