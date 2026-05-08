extends "res://scripts/nivel.gd"

var paso_tutorial = 0
var basura_actual = null
var tutorial_activo = true
var _intento_peligroso = 0  # cancela timers viejos del paso peligroso

func _ready():
	super()
	$Timer.stop()
	%TutorialUI.visible = false
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	%TutorialUI.process_mode = Node.PROCESS_MODE_ALWAYS
	%BotonEntendido.process_mode = Node.PROCESS_MODE_ALWAYS
	
	$Barbara.resultado_tutorial.connect(_evaluar_resultado_jugador)
	
	await get_tree().create_timer(1.0).timeout
	lanzar_basura_tutorial()

func lanzar_basura_tutorial():
	# Solo reseteamos vidas en el tutorial, no entre reintentos del mismo paso
	if paso_tutorial == 0:
		SesionGlobal.vidas = 3
		$Barbara.actualizar_interfaz()
	
	basura_actual = escena_basura.instantiate()
	basura_actual.position = Vector2(720, 250)
	add_child(basura_actual)
	
	var material = basura_actual.get_node("Sprite2D").material
	
	if paso_tutorial == 0:
		basura_actual.categoria = "Organico"
		basura_actual.get_node("Sprite2D").frame = 30
		material.set_shader_parameter("color_borde", Color(0, 1, 0, 1))
		%TextoTutorial.text = "¡Mira! Un residuo ORGÁNICO.\nUsa el bote VERDE."
		# Congelamos basura y Barbara: solo tienen que cambiar bote y esperar
		basura_actual.process_mode = Node.PROCESS_MODE_DISABLED
		$Barbara.process_mode = Node.PROCESS_MODE_DISABLED
		
	elif paso_tutorial == 1:
		basura_actual.categoria = "Inorganico"
		basura_actual.get_node("Sprite2D").frame = 3
		material.set_shader_parameter("color_borde", Color(0, 0.5, 1, 1))
		%TextoTutorial.text = "¡Cuidado! Esto es INORGÁNICO.\nCambia al bote AZUL."
		basura_actual.process_mode = Node.PROCESS_MODE_DISABLED
		$Barbara.process_mode = Node.PROCESS_MODE_DISABLED
		
	elif paso_tutorial == 2:
		basura_actual.categoria = "Peligroso"
		basura_actual.get_node("Sprite2D").frame = 42
		material.set_shader_parameter("color_borde", Color(1, 0, 0, 1))
		%TextoTutorial.text = "¡PELIGRO!\n¡Esquiva esto a toda costa!"
		# Barbara se mueve, la basura cae de verdad
		basura_actual.process_mode = Node.PROCESS_MODE_DISABLED
		$Barbara.process_mode = Node.PROCESS_MODE_DISABLED
		# Iniciamos el timer con el número de intento actual
		_intento_peligroso += 1
		_esperar_esquive_peligroso(_intento_peligroso)
	
	%TutorialUI.visible = true
	%BotonEntendido.grab_focus()    # ← agregar después de cada visible = true


func _esperar_esquive_peligroso(intento: int):
	await get_tree().create_timer(4.0).timeout
	# Solo avanzamos si este timer es el más reciente Y seguimos en paso 2
	if tutorial_activo and paso_tutorial == 2 and _intento_peligroso == intento:
		avanzar_tutorial()

func _on_boton_entendido_pressed():
	if paso_tutorial == 3:
		_finalizar_tutorial()
		return
	
	%TutorialUI.visible = false
	
	if is_instance_valid(basura_actual):
		basura_actual.process_mode = Node.PROCESS_MODE_INHERIT
	$Barbara.process_mode = Node.PROCESS_MODE_INHERIT

func _evaluar_resultado_jugador(acierto: bool):
	# Si el tutorial ya terminó, ignoramos cualquier señal del juego normal
	if not tutorial_activo:
		return
	
	if paso_tutorial == 2:
		if not acierto:
			%TextoTutorial.text = "¡Te golpeaste!\nInténtalo de nuevo: ¡Esquívalo!"
			%TutorialUI.visible = true
			await get_tree().create_timer(1.5).timeout
			if tutorial_activo and paso_tutorial == 2:
				lanzar_basura_tutorial()
		else:
			avanzar_tutorial()
	else:
		if acierto:
			avanzar_tutorial()
		else:
			%TextoTutorial.text = "¡Ese no era el bote!\nInténtalo otra vez."
			%TutorialUI.visible = true
			await get_tree().create_timer(1.5).timeout
			if tutorial_activo:
				lanzar_basura_tutorial()

func avanzar_tutorial():
	paso_tutorial += 1
	if paso_tutorial < 3:
		await get_tree().create_timer(1.0).timeout
		lanzar_basura_tutorial()
	else:
		%TextoTutorial.text = "¡LISTO!\n¡A limpiar	!"
		%TutorialUI.visible = true

func _finalizar_tutorial():
	tutorial_activo = false
	# Desconectamos la señal para que el juego normal no la dispare
	if $Barbara.resultado_tutorial.is_connected(_evaluar_resultado_jugador):
		$Barbara.resultado_tutorial.disconnect(_evaluar_resultado_jugador)
	%TutorialUI.visible = false
	SesionGlobal.completar_nivel(1, 1)  # mundo 1, nivel 1 — desbloquea 1-2
	SesionGlobal.vidas = 3
	$Barbara.actualizar_interfaz()
	$Timer.start()
	
func _process(_delta):
	if %TutorialUI.visible and Input.is_action_just_pressed("confirmar"):
		_on_boton_entendido_pressed()
