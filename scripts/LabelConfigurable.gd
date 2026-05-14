# label_configurable.gd
# Guarda este archivo en tu carpeta de scripts
extends Label

@export var factor_tamaño: float = 1.0
@export var usar_tamaño_activo: bool = true  # true = size_activo, false = size_inactivo

func _ready():
	_actualizar_tamaño()
	_conectar_configuracion()

func _conectar_configuracion():
	if has_node("/root/Configuracion"):
		if not Configuracion.tamaño_cambiado.is_connected(_on_cambio_tamaño):
			Configuracion.tamaño_cambiado.connect(_on_cambio_tamaño)

func _on_cambio_tamaño(nombre: String, activo: int, inactivo: int):
	_actualizar_tamaño()

func _actualizar_tamaño():
	if not has_node("/root/Configuracion"):
		return
	
	var tamaño_base = Configuracion.get_tamaño_activo() if usar_tamaño_activo else Configuracion.get_tamaño_inactivo()
	add_theme_font_size_override("font_size", int(tamaño_base * factor_tamaño))
