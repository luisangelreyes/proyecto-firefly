extends Control

const MUNDOS = [
	{
		"id":          1,
		"nombre":      "Las Vías del Tren",
		"descripcion": "El hogar de Eli y Don Sergio.",
		"escena":      "res://scenes/menu/ModoAventura.tscn",
		"clave_inicio":"1-1"
	},
	{
		"id":          2,
		"nombre":      "Las Calles de la Ciudad",
		"descripcion": "El mercado y las calles urbanas.",
		"escena":      "res://scenes/menu/ModoAventura2.tscn",
		"clave_inicio":"2-1"
	},
]

const COLOR_DISPONIBLE = Color("#e8c428")
const COLOR_BLOQUEADO  = Color("#3a3a3a")
const COLOR_COMPLETADO = Color("#4fb87a")
const COLOR_SELECCION  = Color("#ffffff")

var indice_actual: int = 0
var items: Array = []

@onready var lbl_descripcion = $LabelDescripcion
@onready var lbl_titulo      = $LabelTitulo

func _ready():
	lbl_titulo.text = "Selecciona un Mundo"

	items = [
		$Mundo1,
		$Mundo2,
	]

	for i in range(items.size()):
		var btn = items[i].get_node("BtnMundo")
		btn.pressed.connect(_on_mundo_presionado.bind(i))
		btn.focus_entered.connect(_on_mundo_enfocado.bind(i))
		btn.mouse_entered.connect(_on_mundo_enfocado.bind(i))

	$BotonVolver.pressed.connect(_on_volver)
	_actualizar_mundos()
	_seleccionar_primer_disponible()

func _actualizar_mundos():
	for i in range(MUNDOS.size()):
		var m      = MUNDOS[i]
		var btn    = items[i].get_node("BtnMundo")
		var lbl_n  = items[i].get_node("LabelNombre")
		var disp   = SesionGlobal.nivel_disponible(m["id"], 1)

		lbl_n.text = m["nombre"]

		if disp:
			# Verificar si está completado
			var ultimo_nivel = _ultimo_nivel_del_mundo(m["id"])
			var completado   = SesionGlobal.nivel_disponible(m["id"] + 1, 1) or \
							   SesionGlobal.nivel_actual > ultimo_nivel
			btn.modulate = COLOR_COMPLETADO if completado else COLOR_DISPONIBLE
			btn.disabled = false
		else:
			btn.modulate = COLOR_BLOQUEADO
			btn.disabled = true

func _ultimo_nivel_del_mundo(mundo: int) -> int:
	var ultimo = 0
	for clave in SesionGlobal.niveles_desbloqueados.keys():
		var partes = clave.split("-")
		if int(partes[0]) == mundo:
			ultimo = max(ultimo, int(partes[1]))
	return ultimo

func _seleccionar_primer_disponible():
	for i in range(MUNDOS.size()):
		if SesionGlobal.nivel_disponible(MUNDOS[i]["id"], 1):
			indice_actual = i
			items[i].get_node("BtnMundo").grab_focus()
			lbl_descripcion.text = MUNDOS[i]["descripcion"]
			break

func _on_mundo_enfocado(indice: int):
	indice_actual        = indice
	lbl_descripcion.text = MUNDOS[indice]["descripcion"]
	_resaltar(indice)

func _resaltar(indice: int):
	for i in range(items.size()):
		var btn = items[i].get_node("BtnMundo")
		if not btn.disabled:
			btn.modulate = COLOR_DISPONIBLE
	if not items[indice].get_node("BtnMundo").disabled:
		items[indice].get_node("BtnMundo").modulate = COLOR_SELECCION

func _on_mundo_presionado(indice: int):
	get_tree().change_scene_to_file(MUNDOS[indice]["escena"])

func _on_volver():
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")

func _unhandled_input(event):
	if not (event is InputEventKey or event is InputEventJoypadButton or
			event is InputEventJoypadMotion):
		return
	if event.is_echo():
		return

	if event.is_action_pressed("mover_izquierda") or event.is_action_pressed("ui_left"):
		var nuevo = max(0, indice_actual - 1)
		if nuevo != indice_actual:
			indice_actual = nuevo
			_on_mundo_enfocado(nuevo)
	elif event.is_action_pressed("mover_derecha") or event.is_action_pressed("ui_right"):
		var nuevo = min(items.size() - 1, indice_actual + 1)
		if nuevo != indice_actual:
			indice_actual = nuevo
			_on_mundo_enfocado(nuevo)
	elif event.is_action_pressed("confirmar") or event.is_action_pressed("ui_accept"):
		_on_mundo_presionado(indice_actual)
	elif event.is_action_pressed("ui_cancel"):
		_on_volver()
