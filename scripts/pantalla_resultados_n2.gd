extends CanvasLayer

func _ready():
	visible = false
	$Fondo/BotonSiguiente.pressed.connect(_on_boton_siguiente)

func mostrar_resultados(
	clasificados: int,
	primera: int,
	racha: int,
	fallos: int,
	desglose: Dictionary,
	total: int,
	faltaron: int 
):
	visible = true



	if faltaron == 0:
		$Fondo/LabelTitulo.text = "¡Jornada terminada!"
		$Fondo/LabelTitulo.add_theme_color_override("font_color", Color("#86efac"))
	else:
		$Fondo/LabelTitulo.text = "¡Se acabó el tiempo!"
		$Fondo/LabelTitulo.add_theme_color_override("font_color", Color("#f87171"))

	$Fondo/LabelClasificados.text = "✓ Clasificados: %d / %d" % [clasificados, total]

	# Faltaron — solo si se acabó el tiempo
	if faltaron > 0:
		$Fondo/LabelFaltaron.text = "✗ Sin clasificar: %d objeto%s" % [
			faltaron,
			"s" if faltaron > 1 else ""
		]
		$Fondo/LabelFaltaron.visible = true
	else:
		$Fondo/LabelFaltaron.visible = false
		
	$Fondo/LabelClasificados.text = "✓ Clasificados correctamente: %d / %d" % [clasificados, total]

	# Primera vez
	if primera == total:
		$Fondo/LabelPrimera.text = "⭐ ¡Todos a la primera!"
		$Fondo/LabelPrimera.add_theme_color_override("font_color", Color("#fbbf24"))
	else:
		$Fondo/LabelPrimera.text = "A la primera: %d / %d" % [primera, total]
		$Fondo/LabelPrimera.add_theme_color_override("font_color", Color("#ffffff"))

	# Racha
	$Fondo/LabelRacha.text = "🔥 Mejor racha: %d seguidos" % racha

	# Fallos
	if fallos == 0:
		$Fondo/LabelFallos.text = "✓ Sin fallos ni tiempos agotados"
		$Fondo/LabelFallos.add_theme_color_override("font_color", Color("#86efac"))
	else:
		$Fondo/LabelFallos.text = "Fallos y tiempos agotados: %d" % fallos
		$Fondo/LabelFallos.add_theme_color_override("font_color", Color("#f87171"))

	# Desglose por categoría
	$Fondo/LabelDesglose.text = "Desglose por categoría:"
	$Fondo/LabelPapel.text    = "  📄 Papel:    %d" % desglose.get("papel", 0)
	$Fondo/LabelVidrio.text   = "  🟢 Vidrio:   %d" % desglose.get("vidrio", 0)
	$Fondo/LabelPlastico.text = "  🔵 Plástico: %d" % desglose.get("plastico", 0)

	# Puntos
	$Fondo/LabelPuntos.text = "Puntos totales: %d" % SesionGlobal.puntaje

	$Fondo/BotonSiguiente.grab_focus()

func _on_boton_siguiente():
	SesionGlobal.vidas   = 3
	SesionGlobal.puntaje = 0
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
