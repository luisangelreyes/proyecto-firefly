# Adjúntalo directamente a Labels o CheckButtons individuales

extends Control

@export var factor_tamaño: float = 1.0
@export var usar_tamaño_activo: bool = true
@export var escalar_icono: bool = false  

func _ready():
	_actualizar_tamaño()
	_conectar_configuracion()

func _conectar_configuracion():
	if has_node("/root/Configuracion"):
		if not Configuracion.tamaño_cambiado.is_connected(_on_cambio_tamaño):
			Configuracion.tamaño_cambiado.connect(_on_cambio_tamaño)

func _on_cambio_tamaño(_nombre: String, _activo: int, _inactivo: int):
	_actualizar_tamaño()

func _actualizar_tamaño():
	if not has_node("/root/Configuracion"):
		return
	
	var tamaño_base = Configuracion.get_tamaño_activo() if usar_tamaño_activo else Configuracion.get_tamaño_inactivo()
	var tamaño_fuente = int(tamaño_base * factor_tamaño)
	
	# Cambiar tamaño de fuente (funciona en Label Y CheckButton)
	add_theme_font_size_override("font_size", tamaño_fuente)
	
	# Si es un CheckButton/CheckBox y tiene activado escalar_icono
	if escalar_icono:
		var tamaño_icono = int(tamaño_base * factor_tamaño * 0.7)
		add_theme_constant_override("icon_width", tamaño_icono)
		add_theme_constant_override("icon_height", tamaño_icono)
