extends Control

const CLAVES = ["2-1","2-2","2-3","2-4","2-5","2-6"]

const NOMBRES = {
	"2-1": "Caída Urbana",
	"2-2": "Clasificación",
	"2-3": "Las Calles",
	"2-4": "Caída Nocturna",
	"2-5": "Clasificación 2",
	"2-6": "El Callejón",
}

const DESCRIPCIONES = {
	"2-1": "Los residuos caen en las calles de la ciudad.",
	"2-2": "Clasifica los residuos del día en sus contenedores.",
	"2-3": "Recorre las calles y recoge todo lo que encuentres.",
	"2-4": "La ciudad de noche — más rápido y más peligroso.",
	"2-5": "Una segunda ronda de clasificación más exigente.",
	"2-6": "El callejón final. Limpia todo antes de que se acabe el tiempo.",
}

const COLOR_COMPLETADO = Color("#4fb87a")
const COLOR_DISPONIBLE = Color("#e8c428")
const COLOR_BLOQUEADO  = Color("#3a3a3a")
const COLOR_SELECCION  = Color("#ffffff")

@onready var nodos = {
	"2-1": $Nodo1,
	"2-2": $Nodo2,
	"2-3": $Nodo3,
	"2-4": $Nodo4,
	"2-5": $Nodo5,
	"2-6": $Nodo6,
}
@onready var lbl_descripcion = $LabelDescripcion
@onready var icono           = $IconoJugador

var indice_actual: int = 0

func _ready():
	$LabelMundo.text = "MUNDO 2 — Las Calles de la Ciudad"

	for i in range(CLAVES.size()):
		var clave = CLAVES[i]
		var btn   = nodos[clave].get_node("BtnNodo")
		btn.pressed.connect(_on_nivel_presionado.bind(clave))
		btn.focus_entered.connect(_on_nodo_enfocado.bind(i))
		btn.mouse_entered.connect(_on_nodo_enfocado.bind(i))

	$BotonVolver.pressed.connect(_on_volver)
	_actualizar_mapa()
	_seleccionar_primer_disponible()

func _actualizar_mapa():
	for i in range(CLAVES.size()):
		var clave  = CLAVES[i]
		var mundo  = int(clave.split("-")[0])
		var nivel  = int(clave.split("-")[1])
		var nodo   = nodos[clave]
		var btn    = nodo.get_node("BtnNodo")
		var lbl_n  = nodo.get_node("LabelNumero")
		var lbl_nm = nodo.get_node("LabelNombre")
		var disp   = SesionGlobal.nivel_disponible(mundo, nivel)
		lbl_nm.text = NOMBRES[clave]

		if disp:
			var idx_sig    = i + 1
			var completado = false
			if idx_sig < CLAVES.size():
				var sig = CLAVES[idx_sig]
				completado = SesionGlobal.nivel_disponible(
					int(sig.split("-")[0]),
					int(sig.split("-")[1])
				)
			else:
				completado = SesionGlobal.nivel_actual > nivel

			btn.modulate   = COLOR_COMPLETADO if completado else COLOR_DISPONIBLE
			lbl_n.text     = "✓" if completado else str(nivel)
			btn.disabled   = false
		else:
			btn.modulate = COLOR_BLOQUEADO
			lbl_n.text   = "🔒"
			btn.disabled = true

func _seleccionar_primer_disponible():
	for i in range(CLAVES.size()):
		var clave = CLAVES[i]
		var mundo = int(clave.split("-")[0])
		var nivel = int(clave.split("-")[1])
		if SesionGlobal.nivel_disponible(mundo, nivel):
			indice_actual = i
			nodos[clave].get_node("BtnNodo").grab_focus()
			lbl_descripcion.text = DESCRIPCIONES[clave]
			_mover_icono_a(i)
			break

func _on_nodo_enfocado(indice: int):
	indice_actual = indice
	lbl_descripcion.text = DESCRIPCIONES[CLAVES[indice]]
	_resaltar_nodo(indice)
	_mover_icono_a(indice)

func _resaltar_nodo(indice: int):
	for i in range(CLAVES.size()):
		var btn = nodos[CLAVES[i]].get_node("BtnNodo")
		if not btn.disabled:
			var idx_sig = i + 1
			var completado = false
			if idx_sig < CLAVES.size():
				var sig = CLAVES[idx_sig]
				completado = SesionGlobal.nivel_disponible(
					int(sig.split("-")[0]), int(sig.split("-")[1])
				)
			btn.modulate = COLOR_COMPLETADO if completado else COLOR_DISPONIBLE
		if i == indice and not btn.disabled:
			btn.modulate = COLOR_SELECCION

func _on_nivel_presionado(clave: String):
	var ruta = SesionGlobal.get_ruta_nivel(
		int(clave.split("-")[0]),
		int(clave.split("-")[1])
	)
	if ruta != "":
		get_tree().change_scene_to_file(ruta)

func _mover_icono_a(indice: int):
	var nodo_destino = nodos[CLAVES[indice]]
	icono.position   = nodo_destino.position - icono.size / 2 + Vector2(40, -50)

func _on_volver():
	get_tree().change_scene_to_file("res://scenes/menu/SelectorMundos.tscn")

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
			_on_nodo_enfocado(nuevo)
	elif event.is_action_pressed("mover_derecha") or event.is_action_pressed("ui_right"):
		var nuevo = min(CLAVES.size() - 1, indice_actual + 1)
		if nuevo != indice_actual:
			indice_actual = nuevo
			_on_nodo_enfocado(nuevo)
	elif event.is_action_pressed("confirmar") or event.is_action_pressed("ui_accept"):
		_on_nivel_presionado(CLAVES[indice_actual])
	elif event.is_action_pressed("ui_cancel"):
		_on_volver()
