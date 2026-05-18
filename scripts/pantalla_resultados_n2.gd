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

	# ── DESGLOSE DINÁMICO POR CATEGORÍA ──
	$Fondo/LabelDesglose.text = "Desglose por categoría:"
	
	# Agrupamos tus nodos de interfaz en un Array para manejarlos secuencialmente
	var slots_labels = [$Fondo/LabelPapel, $Fondo/LabelVidrio, $Fondo/LabelPlastico]
	
	# Diccionario de iconos temáticos para todos tus niveles
	var iconos = {
		"papel": "📄",
		"vidrio": "🟢",
		"plastico": "🔵",
		"organico": "🍎",
		"inorganico": "🥫",
		"tela": "👕"
	}
	
	# 1. Ocultamos todos los slots primero por seguridad
	for lbl in slots_labels:
		lbl.visible = false
		
	# 2. Asignamos los datos reales del diccionario 'desglose' a los labels
	var categorias = desglose.keys()
	for i in range(categorias.size()):
		if i < slots_labels.size():
			var llave_cat = categorias[i]
			var cantidad = desglose[llave_cat]
			var icono = iconos.get(llave_cat, "📦") # Icono genérico por si creas otra categoría
			
			# capitalize() cambia "organico" a "Organico"
			slots_labels[i].text = "  %s %s: %d" % [icono, llave_cat.capitalize(), cantidad]
			slots_labels[i].visible = true

	# Puntos
	$Fondo/LabelPuntos.text = "Puntos totales: %d" % SesionGlobal.puntaje

	$Fondo/BotonSiguiente.grab_focus()

func _on_boton_siguiente():
	SesionGlobal.vidas   = 3
	SesionGlobal.puntaje = 0
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
