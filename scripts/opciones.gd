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

@onready var check_reducir_movimiento = $CheckButtonReducirMovimiento

@onready var label_velocidad = $LabelVelocidad
@onready var boton_75 = $Boton75
@onready var boton_100 = $Boton100
@onready var boton_125 = $Boton125

func _ready():
	check_reducir_movimiento.toggled.connect(func(valor): Configuracion.set_movimiento_reducido(valor))
	check_reducir_movimiento.button_pressed = Configuracion.movimiento_reducido
	
	if not Configuracion.movimiento_reducido_cambiado.is_connected(_on_movimiento_reducido_cambiado):
		Configuracion.movimiento_reducido_cambiado.connect(_on_movimiento_reducido_cambiado)
	
	boton_normal.pressed.connect(func(): _cambiar_tamaño(Configuracion.TamañoFuente.NORMAL))
	boton_mediano.pressed.connect(func(): _cambiar_tamaño(Configuracion.TamañoFuente.MEDIANO))
	boton_grande.pressed.connect(func(): _cambiar_tamaño(Configuracion.TamañoFuente.GRANDE))

	boton_ninguno.pressed.connect(func(): _cambiar_filtro(Configuracion.FiltroColor.NINGUNO))
	boton_deuteranopia.pressed.connect(func(): _cambiar_filtro(Configuracion.FiltroColor.DEUTERANOPIA))
	boton_protanopia.pressed.connect(func(): _cambiar_filtro(Configuracion.FiltroColor.PROTANOPIA))
	boton_tritanopia.pressed.connect(func(): _cambiar_filtro(Configuracion.FiltroColor.TRITANOPIA))

	boton_75.pressed.connect(func(): _cambiar_velocidad(Configuracion.VELOCIDAD_75))
	boton_100.pressed.connect(func(): _cambiar_velocidad(Configuracion.VELOCIDAD_100))
	boton_125.pressed.connect(func(): _cambiar_velocidad(Configuracion.VELOCIDAD_125))

	if not Configuracion.tamaño_cambiado.is_connected(_on_tamaño_cambiado):
		Configuracion.tamaño_cambiado.connect(_on_tamaño_cambiado)
	if not Configuracion.filtro_cambiado.is_connected(_on_filtro_cambiado):
		Configuracion.filtro_cambiado.connect(_on_filtro_cambiado)
	if not Configuracion.velocidad_cambiado.is_connected(_on_velocidad_cambiado):
		Configuracion.velocidad_cambiado.connect(_on_velocidad_cambiado)

	_actualizar_ui_tamaño()
	_actualizar_ui_filtro()
	_actualizar_ui_velocidad()

func _cambiar_tamaño(nuevo_tamaño: int):
	Configuracion.set_tamaño_fuente(nuevo_tamaño)

func _cambiar_filtro(nuevo_filtro: int):
	Configuracion.set_filtro_color(nuevo_filtro)

func _on_tamaño_cambiado(nombre: String, activo: int, inactivo: int):
	_actualizar_ui_tamaño()

func _on_filtro_cambiado(tipo: int):
	_actualizar_ui_filtro()

func _cambiar_velocidad(porcentaje: int):
	Configuracion.set_velocidad_juego(porcentaje)

func _on_velocidad_cambiado(valor: int):
	_actualizar_ui_velocidad()

func _actualizar_ui_velocidad():
	label_velocidad.text = "Velocidad actual: " + Configuracion.get_nombre_velocidad()
	var vel = Configuracion.velocidad_actual
	boton_75.modulate = Color.WHITE if vel == Configuracion.VELOCIDAD_75 else Color.DIM_GRAY
	boton_100.modulate = Color.WHITE if vel == Configuracion.VELOCIDAD_100 else Color.DIM_GRAY
	boton_125.modulate = Color.WHITE if vel == Configuracion.VELOCIDAD_125 else Color.DIM_GRAY

func _actualizar_ui_tamaño():
	label_tamaño_actual.text = "Tamaño actual: " + Configuracion.get_nombre_tamaño()
	var tamaño_actual = Configuracion.tamaño_actual
	boton_normal.modulate = Color.WHITE if tamaño_actual == Configuracion.TamañoFuente.NORMAL else Color.DIM_GRAY
	boton_mediano.modulate = Color.WHITE if tamaño_actual == Configuracion.TamañoFuente.MEDIANO else Color.DIM_GRAY
	boton_grande.modulate = Color.WHITE if tamaño_actual == Configuracion.TamañoFuente.GRANDE else Color.DIM_GRAY

func _on_movimiento_reducido_cambiado(valor: bool):
	check_reducir_movimiento.button_pressed = valor

func _actualizar_ui_filtro():
	label_filtro_color.text = "Filtro actual: " + Configuracion.get_nombre_filtro()
	var filtro = Configuracion.filtro_actual
	boton_ninguno.modulate = Color.WHITE if filtro == Configuracion.FiltroColor.NINGUNO else Color.DIM_GRAY
	boton_deuteranopia.modulate = Color.WHITE if filtro == Configuracion.FiltroColor.DEUTERANOPIA else Color.DIM_GRAY
	boton_protanopia.modulate = Color.WHITE if filtro == Configuracion.FiltroColor.PROTANOPIA else Color.DIM_GRAY
	boton_tritanopia.modulate = Color.WHITE if filtro == Configuracion.FiltroColor.TRITANOPIA else Color.DIM_GRAY

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
