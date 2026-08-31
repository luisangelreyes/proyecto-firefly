extends "res://scenes/niveles/bases/Nivel2.gd"

var mensajes_tutorial: Array = []
var tutorial_completado: bool = false


@onready var dialogo = $DialogoTutorial

func _ready():
	OBJETOS = SesionGlobal.datos_residuos.get("nivel2_objetos", [])
	cursor_spd = Configuracion.get_cursor_speed()
	
	# ── Conectar señales de UI (normalmente lo hace Nivel2._ready, pero lo sobreescribimos) ──
	tiempo_actualizado.connect(_on_tiempo_actualizado)
	puntos_actualizados.connect(_on_puntos_actualizados)
	vidas_actualizadas.connect(_on_vidas_actualizadas)
	feedback_mostrado.connect(_on_feedback_mostrado)
	
	$MusicaFondo.play()
	popup.visible = false
	$PantallaGameOver.reintentar_presionado.connect(_on_reintentar)
	$PantallaGameOver.menu_presionado.connect(_on_menu_gameover)
	
	timer_activo = false
	juego_activo = false
	
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
		tutorial_completado = true
		_iniciar_nivel()

func _on_tutorial_terminado():
	tutorial_completado = true
	_iniciar_nivel()

func _iniciar_nivel():
	if not tutorial_completado and not mensajes_tutorial.is_empty():
		return
		
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
	puntos_actualizados.emit(SesionGlobal.puntaje)
	tiempo_restante = tiempo_limite
	tiempo_actualizado.emit(tiempo_restante)
	timer_activo = true
	juego_activo = true
	_siguiente_objeto()
