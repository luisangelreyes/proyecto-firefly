extends Control

const MECANICAS = [
	{
		"id":          "caida",
		"nombre":      "Caída de Residuos",
		"descripcion": "Atrapa los residuos que caen y clasifícalos\nen el bote correcto antes de que toquen el suelo.",
		"color":       Color("#1a2e1a"),
		"escena":      "res://scenes/menu/OpcionesCaida.tscn",
	},
	{
		"id":          "clasificacion",
		"nombre":      "Clasificación",
		"descripcion": "Arrastra cada residuo al contenedor correcto\nantes de que se acabe el tiempo.",
		"color":       Color("#1a1a2e"),
		"escena":      "res://scenes/menu/OpcionesClasificacion.tscn",
	},
	{
		"id":          "topdown",
		"nombre":      "Exploración Top-Down",
		"descripcion": "Recorre el escenario, recoge los residuos\ny clasifícalos con el bote correcto.",
		"color":       Color("#2e1a1a"),
		"escena":      "res://scenes/menu/OpcionesTopDown.tscn",
	},
]

const COLOR_ACTIVO   = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_INACTIVO = Color(0.38, 0.38, 0.38, 1.0)
const COLOR_FONDO_ACTIVO   = Color(1.0, 1.0, 1.0, 0.08)
const COLOR_FONDO_INACTIVO = Color(0.0, 0.0, 0.0, 0.0)

var indice_actual: int = 0
var items: Array = []

@onready var preview_rect      = $PanelPreview/PreviewRect
@onready var lbl_nombre_prev   = $PanelPreview/LabelNombrePreview
@onready var lbl_desc_prev     = $PanelPreview/LabelDescPreview

func _ready():
	items = [
		$ListaMecanicas/ItemCaida,
		$ListaMecanicas/ItemClasificacion,
		$ListaMecanicas/ItemTopDown,
	]

	for i in range(items.size()):
		var item = items[i]
		var lbl  = item.get_node("LabelNombre")

		# Mouse Filter en Stop para que detecte eventos
		item.mouse_filter = Control.MOUSE_FILTER_STOP
		lbl.mouse_filter  = Control.MOUSE_FILTER_STOP

		# Hover actualiza la selección visual
		item.mouse_entered.connect(_on_hover.bind(i))
		lbl.mouse_entered.connect(_on_hover.bind(i))

		# Clic confirma
		item.gui_input.connect(_on_click.bind(i))
		lbl.gui_input.connect(_on_click.bind(i))

	_actualizar_seleccion()
func _on_hover(indice: int):
	indice_actual = indice
	_actualizar_seleccion()

func _on_click(event: InputEvent, indice: int):
	if event is InputEventMouseButton and event.pressed and \
	   event.button_index == MOUSE_BUTTON_LEFT:
		indice_actual = indice
		_confirmar_seleccion()

func _actualizar_seleccion():
	for i in range(items.size()):
		var lbl    = items[i].get_node("LabelNombre")
		var fondo  = items[i].get_node_or_null("FondoItem")
		if i == indice_actual:
			lbl.add_theme_color_override("font_color", COLOR_ACTIVO)
			lbl.add_theme_font_size_override("font_size", 30)
			if fondo:
				fondo.color = COLOR_FONDO_ACTIVO
		else:
			lbl.add_theme_color_override("font_color", COLOR_INACTIVO)
			lbl.add_theme_font_size_override("font_size", 24)
			if fondo:
				fondo.color = COLOR_FONDO_INACTIVO

	var m = MECANICAS[indice_actual]
	preview_rect.color    = m["color"]
	lbl_nombre_prev.text  = m["nombre"]
	lbl_desc_prev.text    = m["descripcion"]

func _confirmar_seleccion():
	get_tree().change_scene_to_file(MECANICAS[indice_actual]["escena"])

func _unhandled_input(event):
	if not (event is InputEventKey or event is InputEventJoypadButton or
			event is InputEventJoypadMotion):
		return
	if event.is_echo():
		return

	if event.is_action_pressed("mover_arriba") or event.is_action_pressed("ui_up"):
		indice_actual = max(0, indice_actual - 1)
		_actualizar_seleccion()
	elif event.is_action_pressed("mover_abajo") or event.is_action_pressed("ui_down"):
		indice_actual = min(items.size() - 1, indice_actual + 1)
		_actualizar_seleccion()
	elif event.is_action_pressed("confirmar") or event.is_action_pressed("ui_accept"):
		_confirmar_seleccion()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
