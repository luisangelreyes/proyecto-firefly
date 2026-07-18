extends CanvasLayer

signal dialogo_terminado

var mensajes: Array = []
var indice_actual: int = 0
var escribiendo: bool = false
var texto_completo: String = ""
var velocidad_escritura: float = 0.015

@onready var lbl_texto     = $PanelDialogo/LabelTexto
@onready var lbl_continuar = $PanelDialogo/LabelContinuar
@onready var lbl_nombre    = $PanelDialogo/LabelNombre

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	$PanelDialogo.process_mode = Node.PROCESS_MODE_ALWAYS
	$PanelDialogo/LabelTexto.process_mode = Node.PROCESS_MODE_ALWAYS
	$PanelDialogo/LabelContinuar.process_mode = Node.PROCESS_MODE_ALWAYS
	lbl_continuar.visible = false
	lbl_nombre.text = "Don Sergio"
func iniciar(lista_mensajes: Array):
	mensajes      = lista_mensajes
	indice_actual = 0
	visible       = true
	get_tree().paused = true
	
	# NUEVO: Busca la música del nivel y la hace inmune SOLO durante el diálogo
	var musica = get_tree().current_scene.get_node_or_null("MusicaFondo")
	if musica:
		musica.process_mode = Node.PROCESS_MODE_ALWAYS
		
	_mostrar_mensaje(0)

func _mostrar_mensaje(indice: int):
	texto_completo = mensajes[indice]
	lbl_texto.text = ""
	lbl_continuar.visible = false
	escribiendo = true
	_escribir_texto()

func _escribir_texto():
	lbl_texto.text = ""
	var texto_visible = ""
	var i = 0
	var dentro_etiqueta = false

	while i < texto_completo.length():
		var caracter = texto_completo[i]

		if caracter == "[":
			dentro_etiqueta = true

		if dentro_etiqueta:
			texto_visible += caracter
			if caracter == "]":
				dentro_etiqueta = false
			i += 1
			continue

		texto_visible += caracter
		lbl_texto.text = texto_visible
		i += 1

		await get_tree().create_timer(velocidad_escritura).timeout
		if not escribiendo:
			break

	lbl_texto.text = texto_completo
	escribiendo = false
	lbl_continuar.visible = true
	_animar_continuar()
func _animar_continuar():
	var tween = create_tween().set_loops()
	tween.tween_property(lbl_continuar, "modulate:a", 0.2, 0.5)
	tween.tween_property(lbl_continuar, "modulate:a", 1.0, 0.5)

func _input(event):
	if not visible:
		return
		
	var confirmar = false
	
	# Verificamos que el botón/tecla haya sido presionado (y no mantenido)
	if event.is_pressed() and not event.is_echo():
		if event is InputEventKey:
			# Solo aceptamos Espacio o Enter
			if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
				confirmar = true
		elif event is InputEventJoypadButton:
			# Solo aceptamos el botón A (índice 0 en la mayoría de mandos)
			if event.button_index == JOY_BUTTON_A:
				confirmar = true

	if not confirmar:
		return

	if escribiendo:
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
	
	var musica = get_tree().current_scene.get_node_or_null("MusicaFondo")
	if musica:
		musica.process_mode = Node.PROCESS_MODE_INHERIT
		
	dialogo_terminado.emit()
