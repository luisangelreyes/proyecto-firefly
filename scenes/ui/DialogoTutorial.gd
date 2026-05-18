extends CanvasLayer

signal dialogo_terminado

var mensajes: Array = []
var indice_actual: int = 0
var escribiendo: bool = false
var texto_completo: String = ""
var velocidad_escritura: float = 0.035

@onready var lbl_texto     = $PanelDialogo/LabelTexto
@onready var lbl_continuar = $PanelDialogo/LabelContinuar
@onready var lbl_nombre    = $PanelDialogo/LabelNombre

func _ready():
	visible = false
	lbl_continuar.visible = false
	lbl_nombre.text = "Don Sergio"

func iniciar(lista_mensajes: Array):
	mensajes      = lista_mensajes
	indice_actual = 0
	visible       = true
	get_tree().paused = true
	_mostrar_mensaje(0)

func _mostrar_mensaje(indice: int):
	texto_completo = mensajes[indice]
	lbl_texto.text = ""
	lbl_continuar.visible = false
	escribiendo = true
	_escribir_texto()

func _escribir_texto():
	for i in range(texto_completo.length()):
		lbl_texto.text = texto_completo.substr(0, i + 1)
		await get_tree().create_timer(velocidad_escritura).timeout
		if not escribiendo:
			break
	lbl_texto.text    = texto_completo
	escribiendo       = false
	lbl_continuar.visible = true
	_animar_continuar()

func _animar_continuar():
	var tween = create_tween().set_loops()
	tween.tween_property(lbl_continuar, "modulate:a", 0.2, 0.5)
	tween.tween_property(lbl_continuar, "modulate:a", 1.0, 0.5)

func _input(event):
	if not visible:
		return
	var confirmar = (
		(event is InputEventKey and event.pressed and not event.is_echo()) or
		(event is InputEventJoypadButton and event.pressed and
		 event.button_index == JOY_BUTTON_A) or
		(event is InputEventMouseButton and event.pressed and
		 event.button_index == MOUSE_BUTTON_LEFT)
	)
	if not confirmar:
		return

	if escribiendo:
		# Saltar escritura — mostrar texto completo de golpe
		escribiendo = false
		lbl_texto.text = texto_completo
		lbl_continuar.visible = true
		return

	indice_actual += 1
	if indice_actual < mensajes.size():
		_mostrar_mensaje(indice_actual)
	else:
		_terminar()

func _terminar():
	visible = false
	get_tree().paused = false
	dialogo_terminado.emit()
