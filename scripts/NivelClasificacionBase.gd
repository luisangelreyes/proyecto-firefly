extends "res://scripts/Nivel2.gd"

var mensajes_tutorial: Array = []
var tutorial_completado: bool = false


@onready var dialogo = $DialogoTutorial

func _ready():
	popup.visible = false
	$PantallaGameOver.reintentar_presionado.connect(_on_reintentar)
	$PantallaGameOver.menu_presionado.connect(_on_menu_gameover)
	if not mensajes_tutorial.is_empty():
		$PanelMorral2.visible = false
		$PanelMorral.visible = false
		$LblTituloMorral.visible = false
		$BarraTiempo.visible = false
		$LabelTimer.visible = false
		dialogo.dialogo_terminado.connect(_on_tutorial_terminado)
		await get_tree().process_frame
		dialogo.iniciar(mensajes_tutorial)
	else:
		_iniciar_nivel()

func _on_tutorial_terminado():
	tutorial_completado = true
	_iniciar_nivel()

func _iniciar_nivel():
	$PanelMorral2.visible = true
	$PanelMorral.visible = true
	$LblTituloMorral.visible = true
	$BarraTiempo.visible = true
	$LabelTimer.visible = true
	# Llama la lógica de _ready() de Nivel2.gd manualmente
	lbl_feedback.visible = false
	popup.visible = false
	_configurar_botes()
	if catalogo_objetos.is_empty():
		catalogo_objetos = OBJETOS.duplicate()
	_preparar_cola()
	_actualizar_hud()
	tiempo_restante = tiempo_limite
	timer_activo = true
	_siguiente_objeto()
