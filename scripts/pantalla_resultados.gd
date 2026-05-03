extends CanvasLayer

func _ready():
	visible = false
	# Registramos el botón como nodo único para accederlo con %
	$Fondo/BotonSiguiente.pressed.connect(_on_boton_siguiente_pressed)

func mostrar_resultados(atrapados: int, escapados: int, total: int):
	visible = true

	$Fondo/LabelTitulo.text = "¡Jornada terminada!"

	$Fondo/LabelAtrapados.text = "✓ Residuos clasificados: %d / %d" % [atrapados, total]

	if escapados == 0:
		$Fondo/LabelEscapados.text = "¡Limpieza perfecta!\nNingún residuo escapó."
		$Fondo/LabelEscapados.add_theme_color_override("font_color", Color("#86efac"))
	elif escapados <= 5:
		$Fondo/LabelEscapados.text = "Olvidaste %d residuo%s en el suelo." % [
			escapados,
			"s" if escapados > 1 else ""
		]
		$Fondo/LabelEscapados.add_theme_color_override("font_color", Color("#fbbf24"))
	else:
		$Fondo/LabelEscapados.text = "¡%d residuos contaminaron el suelo!\nPuedes hacerlo mejor." % escapados
		$Fondo/LabelEscapados.add_theme_color_override("font_color", Color("#f87171"))

	$Fondo/LabelPuntos.text = "Puntos totales: %d" % SesionGlobal.puntaje

	# Foco automático para control
	$Fondo/BotonSiguiente.grab_focus()

func _on_boton_siguiente_pressed():
	# Por ahora recarga el nivel, aquí irá la transición al siguiente mundo
	SesionGlobal.vidas = 3
	SesionGlobal.puntaje = 0
	get_tree().reload_current_scene()
