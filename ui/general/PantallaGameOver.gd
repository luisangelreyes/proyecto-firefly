extends CanvasLayer

signal reintentar_presionado
signal menu_presionado

# ── MENSAJES POR CAUSA ────────────────────────────────────────────────────
const MENSAJES = {
	"clasificacion_incorrecta": [
		"Cada residuo tiene su lugar.\nObserva bien el material antes de clasificar.",
		"No todos los plásticos son iguales.\nTómate un momento para identificar cada objeto.",
		"El reciclaje correcto empieza por conocer\nlos materiales. ¡Tú puedes aprender!",
	],
	"residuo_peligroso": [
		"Los residuos peligrosos requieren\nmanejo especial. ¡Nunca los toques directamente!",
		"Jeringas, pilas y medicamentos caducos\nson peligrosos. Mantenlos a distancia.",
		"Un residuo peligroso mal manejado\npuede dañar a personas y al medio ambiente.",
	],
	"tiempo_agotado": [
		"La práctica hace al maestro.\n¡Inténtalo de nuevo, cada vez serás más rápido!",
		"El tiempo es limitado, como en la vida real.\nPlanifica tu ruta antes de actuar.",
		"Con cada intento conoces mejor el mapa.\n¡Ánimo, ya casi lo tienes!",
	],
	"vidas_agotadas": [
		"Los errores son parte del aprendizaje.\nAnaliza qué salió mal e inténtalo de nuevo.",
		"Separar residuos correctamente toma práctica.\n¡No te rindas!",
		"Cada fallo te enseña algo nuevo.\n¡Vuelve a intentarlo con lo que aprendiste!",
	],
}

const COLOR_ACTIVO   = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_INACTIVO = Color(0.38, 0.38, 0.38, 1.0)
const SIZE_ACTIVO    = 30
const SIZE_INACTIVO  = 24

var indice_opcion: int = 0   # 0 = reintentar, 1 = menú
var opciones: Array = []

@onready var lbl_mensaje     = $LabelMensaje
@onready var lbl_reintentar  = $LabelReintentar
@onready var lbl_menu        = $LabelMenu

func _ready():
	visible  = false
	opciones = [lbl_reintentar, lbl_menu]

	# Soporte de mouse
	for i in range(opciones.size()):
		opciones[i].mouse_filter = Control.MOUSE_FILTER_STOP
		opciones[i].mouse_entered.connect(_on_hover.bind(i))
		opciones[i].gui_input.connect(_on_click.bind(i))


func mostrar(causa: String):
	visible = true

	var lista = MENSAJES.get(causa, MENSAJES["vidas_agotadas"])
	lbl_mensaje.text = lista[randi() % lista.size()]

	indice_opcion = 0
	_actualizar_seleccion()

	# Fade in a través del Overlay
	$Overlay.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property($Overlay, "modulate:a", 1.0, 0.4)

func _actualizar_seleccion():
	for i in range(opciones.size()):
		if i == indice_opcion:
			opciones[i].add_theme_color_override("font_color", COLOR_ACTIVO)
			opciones[i].add_theme_font_size_override("font_size", SIZE_ACTIVO)
		else:
			opciones[i].add_theme_color_override("font_color", COLOR_INACTIVO)
			opciones[i].add_theme_font_size_override("font_size", SIZE_INACTIVO)

func _on_hover(indice: int):
	indice_opcion = indice
	_actualizar_seleccion()

func _on_click(event: InputEvent, indice: int):
	if event is InputEventMouseButton and event.pressed and \
	   event.button_index == MOUSE_BUTTON_LEFT:
		indice_opcion = indice
		_confirmar()

func _unhandled_input(event):
	if not visible:
		return
	if not (event is InputEventKey or event is InputEventJoypadButton or
			event is InputEventJoypadMotion):
		return
	if event.is_echo():
		return

	if event.is_action_pressed("mover_arriba") or event.is_action_pressed("ui_up"):
		indice_opcion = max(0, indice_opcion - 1)
		_actualizar_seleccion()
	elif event.is_action_pressed("mover_abajo") or event.is_action_pressed("ui_down"):
		indice_opcion = min(opciones.size() - 1, indice_opcion + 1)
		_actualizar_seleccion()
	elif event.is_action_pressed("confirmar") or event.is_action_pressed("ui_accept"):
		_confirmar()
	elif event.is_action_pressed("ui_cancel"):
		indice_opcion = 1
		_confirmar()

func _confirmar():
	match indice_opcion:
		0: reintentar_presionado.emit()
		1: menu_presionado.emit()
