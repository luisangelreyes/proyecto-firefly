extends Label

@export var texto_teclado: String = "[Enter] Seleccionar"
@export var texto_mando: String = "[A] Seleccionar"

func _ready():
	SesionGlobal.tipo_control_cambiado.connect(_actualizar_texto)
	
	_actualizar_texto(SesionGlobal.usando_mando)

func _actualizar_texto(es_mando: bool):
	if es_mando:
		text = texto_mando
	else:
		text = texto_teclado
