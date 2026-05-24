extends "res://scripts/nivel.gd"

var paso_tutorial    = 0
var basura_actual    = null
var tutorial_activo  = true
var _intento_peligroso = 0
var _fase_dialogo    = ""  # "intro" | "instruccion" | "error" | "final"

@onready var dialogo = $DialogoTutorial
@onready var reproductor_musica = $MusicaFondo
func _ready():
	
	# 2. Tu lógica normal para reproducir la música
	if lista_canciones.size() > 0:
		reproductor_musica.stream = lista_canciones[0] 
		reproductor_musica.play()
	SesionGlobal.vidas   = 3
	SesionGlobal.puntaje = 0
	oleadas                = [3, 3, 3]
	tiempo_entre_residuos  = 0.8
	probabilidad_peligroso = 0.0
	DIFICULTAD_OLEADAS = [
		[200.0, 0.80, 0.0],
		[220.0, 0.75, 0.0],
		[240.0, 0.70, 0.0],
	]
	super()
	$Timer.stop()

	process_mode           = Node.PROCESS_MODE_PAUSABLE
	$Barbara.process_mode  = Node.PROCESS_MODE_PAUSABLE

	dialogo.dialogo_terminado.connect(_on_dialogo_terminado)
	$Barbara.resultado_tutorial.connect(_evaluar_resultado_jugador)

	await get_tree().create_timer(0.5).timeout
	_mostrar_intro()

# ── INTRO ─────────────────────────────────────────────────────────────────
func _mostrar_intro():
	_fase_dialogo = "intro"
	dialogo.iniciar([
		"¡Mija, bienvenida! Soy tu abuelo Sergio.\nTe voy a enseñar a separar la basura.",
		"Van a caer residuos desde arriba. Tienes que\natraparlos con el [color=#4fb87a]BOTE CORRECTO[/color].",
		"Usa las [color=#e8c428]FLECHAS[/color] para moverte y\n[color=#e8c428]ESPACIO[/color] para cambiar de bote.",
		"Hay dos tipos principales:\n[color=#4fb87a]ORGÁNICO[/color] (restos de comida y plantas)\ny [color=#4a8fd4]INORGÁNICO[/color] (plásticos, latas, vidrio).",
		"¡Vamos a practicar! Empieza con algo sencillo.",
	])

# ── INICIAR CADA PASO ─────────────────────────────────────────────────────
func _iniciar_paso():
	basura_actual = escena_basura.instantiate()
	basura_actual.position = Vector2(720, 250)
	add_child(basura_actual)

	var material = basura_actual.get_node("Sprite2D").material

	# Congelar Barbara y basura mientras Don Sergio habla
	basura_actual.process_mode = Node.PROCESS_MODE_DISABLED
	$Barbara.process_mode      = Node.PROCESS_MODE_DISABLED

	_fase_dialogo = "instruccion"

	if paso_tutorial == 0:
		basura_actual.categoria = "Organico"
		basura_actual.get_node("Sprite2D").frame = 30
		material.set_shader_parameter("color_borde", Color(0, 1, 0, 1))
		dialogo.iniciar([
			"¡Mira! Esto es un residuo [color=#4fb87a]ORGÁNICO[/color].\nSon restos de comida, frutas, verduras...",
			"Para atraparlo necesitas el [color=#4fb87a]BOTE VERDE[/color].\nAsegúrate de tenerlo activo antes de que caiga.",
			"¡Cámbialo con ESPACIO si hace falta\ny muévete para atraparlo!",
		])

	elif paso_tutorial == 1:
		basura_actual.categoria = "Inorganico"
		basura_actual.get_node("Sprite2D").frame = 3
		material.set_shader_parameter("color_borde", Color(0, 0.5, 1, 1))
		dialogo.iniciar([
			"¡Ahora viene algo diferente!\nEsto es un residuo [color=#4a8fd4]INORGÁNICO[/color].",
			"Plásticos, latas, vidrio... todo eso es inorgánico.\nNecesitas el [color=#4a8fd4]BOTE AZUL[/color].",
			"Cambia de bote con [color=#e8c428]ESPACIO[/color]\nantes de que llegue al suelo. ¡Tú puedes!",
		])

	elif paso_tutorial == 2:
		basura_actual.categoria = "Peligroso"
		basura_actual.get_node("Sprite2D").frame = 42
		material.set_shader_parameter("color_borde", Color(1, 0, 0, 1))
		dialogo.iniciar([
			"¡Cuidado! Esto es un residuo [color=#d44a4a]PELIGROSO[/color].\nJeringas, pilas, medicamentos caducos...",
			"¡[color=#d44a4a]NO lo atrapes[/color] con ningún bote!\nEsquívalo moviéndote a un lado.",
			"Si te golpea PUEDES LASTIMARTE.\n¡Aléjate de eso!",
		])

# ── DIALOGO TERMINADO ─────────────────────────────────────────────────────
func _on_dialogo_terminado():
	match _fase_dialogo:
		"intro":
			_iniciar_paso()

		"instruccion":
			# Soltar basura y Barbara — empieza la acción
			if is_instance_valid(basura_actual):
				basura_actual.process_mode = Node.PROCESS_MODE_INHERIT
			$Barbara.process_mode = Node.PROCESS_MODE_INHERIT
			if paso_tutorial == 2:
				_intento_peligroso += 1
				_esperar_esquive_peligroso(_intento_peligroso)

		"error":
			# Después de explicar el error, reintentar
			lanzar_basura_tutorial()

		"final":
			_finalizar_tutorial()

# ── EVALUACIÓN ────────────────────────────────────────────────────────────
func _evaluar_resultado_jugador(acierto: bool):
	if not tutorial_activo:
		return
	if not acierto:
		SesionGlobal.vidas = 3
		$Barbara.actualizar_interfaz()
	if paso_tutorial == 2:
		if not acierto:
			_fase_dialogo = "error"
			_intento_peligroso += 1
			dialogo.iniciar([
				"¡Te golpeaste con el residuo peligroso!\nRecuerda: [color=#d44a4a]¡No lo atrapes, esquívalo![/color]",
				"Muévete a un lado cuando lo veas caer.\n¡Inténtalo de nuevo!",
			])
		else:
			_avanzar_tutorial()
	else:
		if acierto:
			_avanzar_tutorial()
		else:
			_fase_dialogo = "error"
			if paso_tutorial == 0:
				dialogo.iniciar([
					"¡Ese no era el bote correcto!\nRecuerda: para [color=#4fb87a]ORGÁNICO[/color] usa el [color=#4fb87a]BOTE VERDE[/color].",
					"Inténtalo de nuevo. ¡Ya casi!",
				])
			else:
				dialogo.iniciar([
					"¡Eso era [color=#4a8fd4]INORGÁNICO[/color], no orgánico!\nCambia al [color=#4a8fd4]BOTE AZUL[/color] con ESPACIO.",
					"¡Vuelve a intentarlo, tú puedes!",
				])

# ── AVANZAR ───────────────────────────────────────────────────────────────
func _avanzar_tutorial():
	paso_tutorial += 1
	if paso_tutorial < 3:
		await get_tree().create_timer(0.8).timeout
		if tutorial_activo:
			_iniciar_paso()
	else:
		_fase_dialogo = "final"
		dialogo.iniciar([
			"¡Excelente trabajo! Ya sabes lo básico.",
			"Recuerda siempre:\n[color=#4fb87a]VERDE[/color] para orgánico, [color=#4a8fd4]AZUL[/color] para inorgánico\ny [color=#d44a4a]ESQUIVA[/color] los peligrosos.",
			"¡Ahora a limpiar!\n¡Vamos!",
		])

# ── REINTENTAR PASO ───────────────────────────────────────────────────────
func lanzar_basura_tutorial():
	if is_instance_valid(basura_actual):
		basura_actual.queue_free()
		basura_actual = null
		
	# SEGUNDO SEGURO: Siempre recargamos vidas al reintentar
	SesionGlobal.vidas = 3
	$Barbara.actualizar_interfaz()
	
	_iniciar_paso()

# ── ESQUIVE PELIGROSO ─────────────────────────────────────────────────────
func _esperar_esquive_peligroso(intento: int):
	await get_tree().create_timer(4.0).timeout
	if tutorial_activo and paso_tutorial == 2 and _intento_peligroso == intento:
		_avanzar_tutorial()

# ── FINALIZAR ─────────────────────────────────────────────────────────────
func _finalizar_tutorial():
	tutorial_activo = false
	if $Barbara.resultado_tutorial.is_connected(_evaluar_resultado_jugador):
		$Barbara.resultado_tutorial.disconnect(_evaluar_resultado_jugador)
	SesionGlobal.completar_nivel(1, 1)
	SesionGlobal.vidas = 3
	$Barbara.actualizar_interfaz()
	$Timer.start()
