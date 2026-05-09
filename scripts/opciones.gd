extends Control

@onready var label_tamaño_actual = $LabelTamañoActual  # Muestra "Normal", "Mediano", "Grande"
@onready var boton_normal = $BotonNormal
@onready var boton_mediano = $BotonMediano
@onready var boton_grande = $BotonGrande

func _ready():
	# Conectar botones
	boton_normal.pressed.connect(func(): _cambiar_tamaño(Configuracion.TamañoFuente.NORMAL))
	boton_mediano.pressed.connect(func(): _cambiar_tamaño(Configuracion.TamañoFuente.MEDIANO))
	boton_grande.pressed.connect(func(): _cambiar_tamaño(Configuracion.TamañoFuente.GRANDE))
	
	# Conectar la señal para actualizar cuando cambie el tamaño
	# ¡IMPORTANTE! Conectar ANTES de mostrar el valor inicial
	if not Configuracion.tamaño_cambiado.is_connected(_on_tamaño_cambiado):
		Configuracion.tamaño_cambiado.connect(_on_tamaño_cambiado)
	
	# Mostrar tamaño actual y resaltar botón activo
	_actualizar_ui_tamaño()

func _cambiar_tamaño(nuevo_tamaño: int):
	Configuracion.set_tamaño_fuente(nuevo_tamaño)
	# La UI se actualizará automáticamente cuando la señal "tamaño_cambiado" se emita

func _on_tamaño_cambiado(nombre: String, activo: int, inactivo: int):
	# Esta función se llama cuando cambia el tamaño en cualquier lugar
	_actualizar_ui_tamaño()

func _actualizar_ui_tamaño():
	# Actualizar el texto del label
	label_tamaño_actual.text = "Tamaño actual: " + Configuracion.get_nombre_tamaño()
	
	# Resaltar el botón activo
	var tamaño_actual = Configuracion.tamaño_actual
	boton_normal.modulate = Color.WHITE if tamaño_actual == Configuracion.TamañoFuente.NORMAL else Color.DIM_GRAY
	boton_mediano.modulate = Color.WHITE if tamaño_actual == Configuracion.TamañoFuente.MEDIANO else Color.DIM_GRAY
	boton_grande.modulate = Color.WHITE if tamaño_actual == Configuracion.TamañoFuente.GRANDE else Color.DIM_GRAY

#regresa al menu principal
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
