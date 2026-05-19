extends CanvasLayer

func _ready():
	visible = false
	$Fondo/BotonSiguiente.pressed.connect(_on_boton_siguiente_pressed)

func mostrar_resultados(
	atrapados: int,
	escapados: int,
	total: int,
	desglose: Dictionary,
	peligrosos_esquivados: int
):
	visible = true

	$Fondo/LabelTitulo.text = "¡Jornada terminada!"

	$Fondo/LabelAtrapados.text = "✓ Clasificados: %d / %d" % [atrapados, total]

	if escapados == 0:
		$Fondo/LabelEscapados.text = "¡Limpieza perfecta!\nNingún residuo escapó."
		$Fondo/LabelEscapados.add_theme_color_override("font_color", Color("#86efac"))
	elif escapados <= 5:
		$Fondo/LabelEscapados.text = "Olvidaste %d residuo%s en el suelo." % [
			escapados, "s" if escapados > 1 else ""
		]
		$Fondo/LabelEscapados.add_theme_color_override("font_color", Color("#fbbf24"))
	else:
		$Fondo/LabelEscapados.text = "¡%d residuos contaminaron el suelo!" % escapados
		$Fondo/LabelEscapados.add_theme_color_override("font_color", Color("#f87171"))

	# Desglose por tipo
	$Fondo/LabelDesglose.text = "🌿 Orgánicos:    %d\n♻  Inorgánicos: %d\n⚠  Peligrosos esquivados: %d" % [
		desglose.get("Organico", 0),
		desglose.get("Inorganico", 0),
		peligrosos_esquivados
	]

	$Fondo/LabelPuntos.text = "Puntos totales: %d" % SesionGlobal.puntaje
	$Fondo/BotonSiguiente.grab_focus()

func _on_boton_siguiente_pressed():
	Engine.time_scale = 1.0
	if SesionGlobal.es_modo_libre:
		SesionGlobal.es_modo_libre = false
		SesionGlobal.modo_libre_config = {}
		Engine.get_main_loop().change_scene_to_file(
            "res://scenes/menu/ModoLibre.tscn"
		)
		return

	# Ir al mapa del mundo correcto
	match SesionGlobal.mundo_actual:
		1: Engine.get_main_loop().change_scene_to_file(
			"res://scenes/menu/ModoAventura.tscn")
		2: Engine.get_main_loop().change_scene_to_file(
			"res://scenes/menu/ModoAventura2.tscn")
		_: Engine.get_main_loop().change_scene_to_file(
			"res://scenes/menu/SelectorMundos.tscn")
