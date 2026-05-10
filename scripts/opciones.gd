extends Control

@onready var label_tamaño_actual = $LabelTamañoActual
@onready var boton_normal = $BotonNormal
@onready var boton_mediano = $BotonMediano
@onready var boton_grande = $BotonGrande
@onready var label_filtro_color = $LabelFiltroColor
@onready var boton_ninguno = $BotonNinguno
@onready var boton_deuteranopia = $BotonDeuteranopia
@onready var boton_protanopia = $BotonProtanopia
@onready var boton_tritanopia = $BotonTritanopia

func _ready():
	boton_normal.pressed.connect(func(): _cambiar_tamaño(Configuracion.TamañoFuente.NORMAL))
	boton_mediano.pressed.connect(func(): _cambiar_tamaño(Configuracion.TamañoFuente.MEDIANO))
	boton_grande.pressed.connect(func(): _cambiar_tamaño(Configuracion.TamañoFuente.GRANDE))

	boton_ninguno.pressed.connect(func(): _cambiar_filtro(Configuracion.FiltroColor.NINGUNO))
	boton_deuteranopia.pressed.connect(func(): _cambiar_filtro(Configuracion.FiltroColor.DEUTERANOPIA))
	boton_protanopia.pressed.connect(func(): _cambiar_filtro(Configuracion.FiltroColor.PROTANOPIA))
	boton_tritanopia.pressed.connect(func(): _cambiar_filtro(Configuracion.FiltroColor.TRITANOPIA))

	if not Configuracion.tamaño_cambiado.is_connected(_on_tamaño_cambiado):
		Configuracion.tamaño_cambiado.connect(_on_tamaño_cambiado)
	if not Configuracion.filtro_cambiado.is_connected(_on_filtro_cambiado):
		Configuracion.filtro_cambiado.connect(_on_filtro_cambiado)

	_actualizar_ui_tamaño()
	_actualizar_ui_filtro()

func _cambiar_tamaño(nuevo_tamaño: int):
	Configuracion.set_tamaño_fuente(nuevo_tamaño)

func _cambiar_filtro(nuevo_filtro: int):
	Configuracion.set_filtro_color(nuevo_filtro)

func _on_tamaño_cambiado(nombre: String, activo: int, inactivo: int):
	_actualizar_ui_tamaño()

func _on_filtro_cambiado(tipo: int):
	_actualizar_ui_filtro()

func _actualizar_ui_tamaño():
	label_tamaño_actual.text = "Tamaño actual: " + Configuracion.get_nombre_tamaño()
	var tamaño_actual = Configuracion.tamaño_actual
	boton_normal.modulate = Color.WHITE if tamaño_actual == Configuracion.TamañoFuente.NORMAL else Color.DIM_GRAY
	boton_mediano.modulate = Color.WHITE if tamaño_actual == Configuracion.TamañoFuente.MEDIANO else Color.DIM_GRAY
	boton_grande.modulate = Color.WHITE if tamaño_actual == Configuracion.TamañoFuente.GRANDE else Color.DIM_GRAY

func _actualizar_ui_filtro():
	label_filtro_color.text = "Filtro actual: " + Configuracion.get_nombre_filtro()
	var filtro = Configuracion.filtro_actual
	boton_ninguno.modulate = Color.WHITE if filtro == Configuracion.FiltroColor.NINGUNO else Color.DIM_GRAY
	boton_deuteranopia.modulate = Color.WHITE if filtro == Configuracion.FiltroColor.DEUTERANOPIA else Color.DIM_GRAY
	boton_protanopia.modulate = Color.WHITE if filtro == Configuracion.FiltroColor.PROTANOPIA else Color.DIM_GRAY
	boton_tritanopia.modulate = Color.WHITE if filtro == Configuracion.FiltroColor.TRITANOPIA else Color.DIM_GRAY

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
