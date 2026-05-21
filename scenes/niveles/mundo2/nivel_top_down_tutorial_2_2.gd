extends "res://scripts/NivelTopDownBase.gd"

# ── ESTADO DEL TUTORIAL ───────────────────────────────────────────────────
var paso_tutorial: int = 0   # 0=organico 1=inorganico 2=peligroso 3=libre
var tutorial_activo: bool = true
var _fase_dialogo: String = ""

@onready var dialogo = $DialogoTutorial

func _ready():
	tiempo_limite       = 120.0    # sin límite durante el tutorial
	cantidad_normales   = 0      # no generamos nada al inicio
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
		{"tipo":"inorganico","nombre":"lata_aplastada",
		 "region":Rect2(0,0,800,800)},
		{"tipo":"inorganico","nombre":"botella_plastico",
		 "region":Rect2(800,0,800,800)},
		{"tipo":"inorganico","nombre":"caja_carton",
		 "region":Rect2(4800,0,800,800)},
		{"tipo":"peligroso", "nombre":"jeringa",
		 "region":Rect2(4800,4000,800,800)},
		{"tipo":"peligroso", "nombre":"bateria",
		 "region":Rect2(4000,4000,800,800)},
		{"tipo":"peligroso", "nombre":"cigarro",
		 "region":Rect2(0,4800,800,800)},
	]

	super()

	# Detener todo hasta que termine la intro
	juego_activo = false
	timer_activo = false
	barra_tiempo.visible = false

	dialogo.dialogo_terminado.connect(_on_dialogo_terminado)

	await get_tree().create_timer(0.5).timeout
	_mostrar_intro()

# ── INTRO ─────────────────────────────────────────────────────────────────
func _mostrar_intro():
	_fase_dialogo = "intro"
	dialogo.iniciar([
		"¡Mija, bienvenida al barrio!\nAquí la basura está por todos lados.",
		"Tienes que [color=#e8c428]moverte[/color] por el escenario\ny recoger los residuos con [color=#e8c428]E o el botón A[/color].",
		"Recuerda cambiar de bote con [color=#e8c428]ESPACIO[/color]\nsegún el tipo de residuo.",
		"¡Vamos a practicar paso a paso!",
	])

# ── PASO 1: ORGÁNICOS ─────────────────────────────────────────────────────
func _iniciar_paso_organico():
	_fase_dialogo = "instruccion_organico"
	_limpiar_residuos()
	dialogo.iniciar([
		"Primero los [color=#4fb87a]RESIDUOS ORGÁNICOS[/color].\nSon restos de comida — frutas, verduras...",
		"Para recogerlos necesitas el [color=#4fb87a]BOTE VERDE[/color].\nAcércate y presiona [color=#e8c428]E[/color] o [color=#e8c428]A[/color].",
		"Recoge todos los residuos verdes del escenario.\n¡Yo cuento cuántos faltan!",
	])

# ── PASO 2: INORGÁNICOS ───────────────────────────────────────────────────
func _iniciar_paso_inorganico():
	_fase_dialogo = "instruccion_inorganico"
	_limpiar_residuos()
	dialogo.iniciar([
		"¡Muy bien! Ahora los [color=#4a8fd4]RESIDUOS INORGÁNICOS[/color].\nLatas, botellas, cartón...",
		"Para estos necesitas el [color=#4a8fd4]BOTE AZUL[/color].\nCámbialo con [color=#e8c428]ESPACIO[/color] antes de recoger.",
		"¡Limpia todos los residuos azules!",
	])

# ── PASO 3: PELIGROSOS ────────────────────────────────────────────────────
func _iniciar_paso_peligroso():
	_fase_dialogo = "instruccion_peligroso"
	_limpiar_residuos()
	dialogo.iniciar([
		"¡Cuidado, mija! Ahora vienen los\n[color=#d44a4a]RESIDUOS PELIGROSOS[/color].",
		"Jeringas, baterías, cigarros...\n[color=#d44a4a]¡NO los toques![/color] Se mueven hacia ti.",
		"Esquívalos moviéndote.\nSi te tocan, pierdes. ¡Mantén distancia!",
		"Sobrevive hasta que el contenedor\nnaranaja los absorba automáticamente.",
	])

# ── DIÁLOGO TERMINADO ─────────────────────────────────────────────────────
func _on_dialogo_terminado():
	match _fase_dialogo:
		"intro":
			_iniciar_paso_organico()

		"instruccion_organico":
			_generar_paso(3, "normal", "organico")
			juego_activo = true

		"instruccion_inorganico":
			_generar_paso(3, "normal", "inorganico")
			juego_activo = true

		"instruccion_peligroso":
			_generar_paso(5, "peligroso", "peligroso")
			juego_activo = true
			# Timer para sobrevivir 10 segundos
			_esperar_fin_paso_peligroso()

		"error_bote":
			juego_activo = true

		"final":
			_finalizar_tutorial()

# ── GENERAR RESIDUOS DEL PASO ─────────────────────────────────────────────
func _generar_paso(cantidad: int, filtro: String, tipo_especifico: String):
	total_residuos = 0
	recogidos      = 0

	# Filtrar catálogo al tipo específico
	var catalogo_paso = catalogo_basura.filter(
		func(item): return item["tipo"] == tipo_especifico
	)

	var space_state   = get_world_2d().direct_space_state
	var zonas         = contenedor_zonas.get_children()
	if zonas.is_empty():
		return

	var query  = PhysicsShapeQueryParameters2D.new()
	var shape  = CircleShape2D.new()
	shape.radius = 25.0
	query.shape  = shape

	var generados         = 0
	var intentos          = 0
	var posiciones_usadas: Array[Vector2] = []

	while generados < cantidad and intentos < cantidad * 50:
		intentos += 1
		var zona  = zonas.pick_random()
		var rect  = zona.get_global_rect()
		var punto = Vector2(
			randf_range(rect.position.x, rect.end.x),
			randf_range(rect.position.y, rect.end.y)
		)

		if punto.distance_to(eli.global_position) < 200.0:
			continue

		var muy_cerca = false
		for pos in posiciones_usadas:
			if punto.distance_to(pos) < 90.0:
				muy_cerca = true
				break
		if muy_cerca:
			continue

		query.transform = Transform2D(0, punto)
		if not space_state.intersect_shape(query).is_empty():
			continue

		var residuo = escena_residuo.instantiate()
		residuo.global_position = punto
		residuo.scale           = Vector2(0.3, 0.3)

		var data         = catalogo_paso.pick_random()
		residuo.tipo     = data["tipo"]
		residuo.nombre   = data["nombre"]

		var atlas        = AtlasTexture.new()
		atlas.atlas      = sprite_sheet
		atlas.region     = data["region"]
		residuo.icono    = atlas

		residuo.recogido_correcto.connect(_on_residuo_correcto)
		residuo.recogido_incorrecto.connect(_on_residuo_tutorial_incorrecto)
		residuo.peligroso_tocado.connect(_on_peligroso_tutorial)

		contenedor_res.add_child(residuo)
		posiciones_usadas.append(punto)
		generados += 1

		if tipo_especifico != "peligroso":
			total_residuos += 1

	lbl_residuos.text = "Residuos: 0 / %d" % total_residuos

# ── OVERRIDE: cuando recoge todos los de un paso ──────────────────────────
func _on_residuo_correcto(_tipo: String):
	recogidos += 1
	racha_actual += 1
	if racha_actual > racha_maxima:
		racha_maxima = racha_actual
	SesionGlobal.puntaje += 10
	lbl_residuos.text = "Residuos: %d / %d" % [recogidos, total_residuos]
	hit_counter.registrar_acierto(racha_actual)

	if recogidos >= total_residuos and total_residuos > 0:
		juego_activo = false
		await get_tree().create_timer(0.8).timeout
		if is_inside_tree():
			_avanzar_paso()

func _on_residuo_tutorial_incorrecto(_tipo: String):
	racha_actual = 0
	hit_counter.registrar_fallo()
	_fase_dialogo = "error_bote"
	juego_activo  = false
	if paso_tutorial == 0:
		dialogo.iniciar([
			"¡Ese no era el bote correcto!\nRecuerda: [color=#4fb87a]ORGÁNICO = BOTE VERDE[/color].",
			"Cambia el bote con [color=#e8c428]ESPACIO[/color]\ny vuelve a intentarlo.",
		])
	else:
		dialogo.iniciar([
			"¡Ese no era el bote correcto!\nRecuerda: [color=#4a8fd4]INORGÁNICO = BOTE AZUL[/color].",
			"Cambia el bote con [color=#e8c428]ESPACIO[/color]\ny vuelve a intentarlo.",
		])

func _on_peligroso_tutorial():
	racha_actual = 0
	hit_counter.registrar_fallo()
	_fase_dialogo = "error_bote"
	juego_activo  = false
	dialogo.iniciar([
		"¡Te tocó un residuo peligroso!\n[color=#d44a4a]¡Mantente alejada![/color]",
		"Muévete rápido para esquivarlos.\n¡Inténtalo de nuevo!",
	])
	await get_tree().create_timer(0.5).timeout
	if is_inside_tree():
		_iniciar_paso_peligroso()

# ── AVANZAR ENTRE PASOS ───────────────────────────────────────────────────
func _avanzar_paso():
	paso_tutorial += 1
	match paso_tutorial:
		1: _iniciar_paso_inorganico()
		2: _iniciar_paso_peligroso()
		3: _mostrar_final()

func _esperar_fin_paso_peligroso():
	await get_tree().create_timer(10.0).timeout
	if is_inside_tree() and tutorial_activo and paso_tutorial == 2:
		juego_activo = false
		_limpiar_residuos_peligrosos()
		await get_tree().create_timer(0.5).timeout
		_avanzar_paso()

func _mostrar_final():
	_fase_dialogo = "final"
	dialogo.iniciar([
		"¡Excelente trabajo, mija!\nYa conoces los tres tipos de residuos.",
		"Recuerda:\n[color=#4fb87a]VERDE[/color] = Orgánico\n[color=#4a8fd4]AZUL[/color] = Inorgánico\n[color=#d44a4a]ESQUIVA[/color] los peligrosos.",
		"¡Ahora a limpiar el barrio de verdad!\n¡Ándale!",
	])

func _finalizar_tutorial():
	tutorial_activo = false
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
	var centro = bote_no_reciclables.get_node("PuntoDeEntrada").global_position
	for r in contenedor_res.get_children():
		if r.tipo == "peligroso":
			r.ser_succionado(centro)
