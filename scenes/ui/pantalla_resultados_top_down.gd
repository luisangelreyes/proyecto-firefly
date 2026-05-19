extends CanvasLayer

func _ready():
	$AnimatedSprite2D.play("victoria")
	visible = false
	$Fondo/BotonSiguiente.pressed.connect(_on_boton_siguiente)

func mostrar_resultados(
	victoria: bool,
	recogidos: int,
	total: int,
	tiempo_restante: float,
	racha_maxima: int
):
	visible = true

	if victoria:
		$Fondo/LabelTitulo.text = "¡Zona Limpia!"
		$Fondo/LabelTitulo.add_theme_color_override("font_color", Color("#4fb87a"))
		$Fondo/BotonSiguiente.text = "Continuar"
	else:
		$Fondo/LabelTitulo.text = "Tiempo Agotado"
		$Fondo/LabelTitulo.add_theme_color_override("font_color", Color("#f87171"))
		$Fondo/BotonSiguiente.text = "Reintentar"

	$Fondo/LabelResiduos.text = "Residuos recogidos: %d / %d" % [recogidos, total]

	if victoria:
		$Fondo/LabelTiempo.text = "Tiempo restante: %d s" % int(tiempo_restante)
		$Fondo/LabelTiempo.add_theme_color_override("font_color", Color("#86efac"))
	else:
		$Fondo/LabelTiempo.text = "Sin tiempo restante"
		$Fondo/LabelTiempo.add_theme_color_override("font_color", Color("#f87171"))

	$Fondo/LabelRacha.text = "Mejor racha: %d seguidos" % racha_maxima

	$Fondo/LabelPuntos.text = "Puntos totales: %d" % SesionGlobal.puntaje

	$Fondo/BotonSiguiente.grab_focus()

func _unhandled_input(event):
	if not visible:
		return
	if not (event is InputEventKey or event is InputEventJoypadButton):
		return
	if event.is_echo():
		return
	if event.is_action_pressed("confirmar") or event.is_action_pressed("ui_accept"):
		_on_boton_siguiente()

func _on_boton_siguiente():
	if SesionGlobal.es_modo_libre:
		SesionGlobal.es_modo_libre = false
		SesionGlobal.modo_libre_config = {}
		Engine.get_main_loop().change_scene_to_file(
            "res://scenes/menu/ModoLibre.tscn"
		)
		return

	match SesionGlobal.mundo_actual:
		1: Engine.get_main_loop().change_scene_to_file(
			"res://scenes/menu/ModoAventura.tscn")
		2: Engine.get_main_loop().change_scene_to_file(
			"res://scenes/menu/ModoAventura2.tscn")
		_: Engine.get_main_loop().change_scene_to_file(
			"res://scenes/menu/SelectorMundos.tscn")
