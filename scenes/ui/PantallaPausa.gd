extends CanvasLayer

signal reanudar_presionado
signal reiniciar_presionado
signal menu_presionado

const COLOR_ACTIVO   = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_INACTIVO = Color(0.38, 0.38, 0.38, 1.0)
const SIZE_ACTIVO    = 34
const SIZE_INACTIVO  = 28

const DESCRIPCIONES = [
	"Continuar desde donde lo dejaste.",
	"Volver a empezar el nivel desde el inicio.",
    "Salir al menú principal."
]

var items: Array = []
var indice_actual: int = 0
var pausado: bool = false
var ultimo_movimiento: int = 0
func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	items = [
		$LabelReanudar,
		$LabelReiniciar,
		$LabelMenu
	]

	for nodo in [$Overlay, $LineaDecorativa, $LabelTitulo,
				 $LabelReanudar, $LabelReiniciar, $LabelMenu, $LabelDescripcion]:
		nodo.process_mode = Node.PROCESS_MODE_ALWAYS

	# Soporte de clic en labels
	for i in range(items.size()):
		items[i].mouse_filter = Control.MOUSE_FILTER_STOP
		items[i].mouse_entered.connect(_on_hover.bind(i))
		items[i].gui_input.connect(_on_click.bind(i))

func _input(event):
	if not (event is InputEventKey or
			event is InputEventJoypadButton or
			event is InputEventJoypadMotion):
		return
	if event.is_echo():
		return

	# MAGIA AQUÍ: Le decimos que reaccione a ui_cancel O a tu nuevo botón pausar
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pausar"):
		if pausado:
			_ejecutar(0) # Esto reanuda el juego
		else:
			_activar_pausa() # Esto pone la pausa
			
		if get_viewport() != null:
			get_viewport().set_input_as_handled()  # ← bloquea propagación
		return

	# Si el juego NO está pausado, ignoramos las flechas de navegación del menú
	if not pausado:
		return

# Obtenemos la hora actual del motor en milisegundos
	var tiempo_actual = Time.get_ticks_msec()

	# --- MOVIMIENTO HACIA ARRIBA ---
	if event.is_action_pressed("mover_arriba") or event.is_action_pressed("ui_up"):
		# Solo permitimos el movimiento si han pasado 200 milisegundos desde el último
		if tiempo_actual - ultimo_movimiento > 200:
			indice_actual = max(0, indice_actual - 1)
			_actualizar_seleccion()
			ultimo_movimiento = tiempo_actual # Registramos la hora de este movimiento
			
			if get_viewport() != null:
				get_viewport().set_input_as_handled()

	# --- MOVIMIENTO HACIA ABAJO ---
	elif event.is_action_pressed("mover_abajo") or event.is_action_pressed("ui_down"):
		if tiempo_actual - ultimo_movimiento > 200:
			indice_actual = min(items.size() - 1, indice_actual + 1)
			_actualizar_seleccion()
			ultimo_movimiento = tiempo_actual 
			
			if get_viewport() != null:
				get_viewport().set_input_as_handled()

	# --- CONFIRMAR SELECCIÓN (Este se queda igual) ---
	elif event.is_action_pressed("confirmar") or event.is_action_pressed("ui_accept"):
		_ejecutar(indice_actual)
		if get_viewport() != null:
			get_viewport().set_input_as_handled()
func _activar_pausa():
	pausado = true
	visible = true
	indice_actual = 0
	_actualizar_seleccion()
	get_tree().paused = true

func _desactivar_pausa():
	pausado = false
	visible = false
	get_tree().paused = false

func _actualizar_seleccion():
	for i in range(items.size()):
		if i == indice_actual:
			items[i].add_theme_color_override("font_color", COLOR_ACTIVO)
			items[i].add_theme_font_size_override("font_size", SIZE_ACTIVO)
		else:
			items[i].add_theme_color_override("font_color", COLOR_INACTIVO)
			items[i].add_theme_font_size_override("font_size", SIZE_INACTIVO)
	$LabelDescripcion.text = DESCRIPCIONES[indice_actual]

func _ejecutar(indice: int):
	match indice:
		0: # Reanudar
			get_tree().paused = false
			visible = false
			pausado = false
		1: # Reiniciar
			# 1. Quitamos la pausa para que el juego vuelva a correr
			get_tree().paused = false
			# 2. Reseteamos las vidas y puntos globales
			SesionGlobal.reiniciar_estadisticas_nivel()
			# 3. Recargamos la escena actual (esto reinicia automáticamente tiempos y colas)
			get_tree().reload_current_scene()
			
		2: # Regresar al Menú Principal
			# 1. Quitamos la pausa
			get_tree().paused = false
			# 2. Opcional: Guardamos el progreso antes de salir
			SesionGlobal.guardar_sesion()
			# 3. Cambiamos a la escena del menú
			get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")

func _on_hover(indice: int):
	indice_actual = indice
	_actualizar_seleccion()

func _on_click(event: InputEvent, indice: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_ejecutar(indice)
func _on_menu():
	get_tree().paused = false
	Engine.time_scale = 1.0   # ← restaurar siempre al salir
	menu_presionado.emit()
