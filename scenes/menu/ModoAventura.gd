extends Control

const CLAVES  = ["1-1", "1-2", "1-3", "1-4"]
@onready var icono = $IconoJugador
const NOMBRES = {
	"1-1": "Tutorial",
	"1-2": "Caída Fácil",
	"1-3": "Caída Media",
	"1-4": "Clasificación",
}

const DESCRIPCIONES = {
	"1-1": "Aprende a clasificar residuos con Don Sergio.",
	"1-2": "Clasifica orgánicos e inorgánicos. Sin peligrosos.",
	"1-3": "Cuidado — los residuos peligrosos empiezan a caer.",
	"1-4": "Arrastra cada residuo al contenedor correcto.",
}

const COLOR_COMPLETADO = Color("#4fb87a")
const COLOR_DISPONIBLE = Color("#e8c428")
const COLOR_BLOQUEADO  = Color("#3a3a3a")
const COLOR_SELECCION  = Color("#ffffff")

# Referencias a los nodos del mapa
@onready var nodos = {
	"1-1": $Nodo1,
	"1-2": $Nodo2,
	"1-3": $Nodo3,
	"1-4": $Nodo4,
}
@onready var lbl_descripcion = $LabelDescripcion
@onready var lbl_mundo       = $LabelMundo
@onready var camino          = $Camino

var indice_actual: int = 0   # índice en CLAVES del nodo seleccionado

func _ready():
	lbl_mundo.text = "MUNDO 1 — Las Vías del Tren"

	# Conectar botones y hover
	for i in range(CLAVES.size()):
		var clave = CLAVES[i]
		var btn   = nodos[clave].get_node("BtnNodo")
		btn.pressed.connect(_on_nivel_presionado.bind(clave))
		btn.focus_entered.connect(_on_nodo_enfocado.bind(i))
		btn.mouse_entered.connect(_on_nodo_enfocado.bind(i))

	$BotonVolver.pressed.connect(_on_volver)

	_actualizar_mapa()
	_seleccionar_primer_disponible()
	_posicionar_icono_inicial()


func _posicionar_icono_inicial():
	var ultimo_idx = 0
	for i in range(CLAVES.size()):
		var clave = CLAVES[i]
		var mundo = int(clave.split("-")[0])
		var nivel = int(clave.split("-")[1])
		if SesionGlobal.nivel_disponible(mundo, nivel):
			ultimo_idx = i
	indice_actual = ultimo_idx
	_mover_icono_a(ultimo_idx)
	
func _actualizar_mapa():
	print("--- ESTADO NIVELES ---")
	for clave in CLAVES:
		print(clave, ": ", SesionGlobal.niveles_desbloqueados.get(clave, "NO EXISTE"))
	print("nivel_actual: ", SesionGlobal.nivel_actual)
	print("----------------------")
	for clave in CLAVES:
		var mundo  = int(clave.split("-")[0])
		var nivel  = int(clave.split("-")[1])
		var nodo   = nodos[clave]
		var btn    = nodo.get_node("BtnNodo")
		var lbl_n  = nodo.get_node("LabelNumero")
		var lbl_nm = nodo.get_node("LabelNombre")
		var disp   = SesionGlobal.nivel_disponible(mundo, nivel)

		lbl_nm.text = NOMBRES[clave]

		if disp:
			# Verificar si está completado — el siguiente está desbloqueado
			var idx_siguiente = CLAVES.find(clave) + 1
			var completado = false
			if idx_siguiente < CLAVES.size():
				var sig = CLAVES[idx_siguiente]
				var m2  = int(sig.split("-")[0])
				var n2  = int(sig.split("-")[1])
				completado = SesionGlobal.nivel_disponible(m2, n2)
			else:
				# Es el último nivel — completado si nivel_actual lo superó
				completado = SesionGlobal.nivel_actual > nivel
			if completado:
				btn.modulate   = COLOR_COMPLETADO
				lbl_n.text     = "✅"
			else:
				btn.modulate   = COLOR_DISPONIBLE
				lbl_n.text     = str(nivel)
			btn.disabled = false
		else:
			btn.modulate   = COLOR_BLOQUEADO
			lbl_n.text     = "🔒"
			btn.disabled   = true

func _seleccionar_primer_disponible():
	for i in range(CLAVES.size()):
		var clave  = CLAVES[i]
		var mundo  = int(clave.split("-")[0])
		var nivel  = int(clave.split("-")[1])
		if SesionGlobal.nivel_disponible(mundo, nivel):
			indice_actual = i
			nodos[clave].get_node("BtnNodo").grab_focus()
			lbl_descripcion.text = DESCRIPCIONES[clave]
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
			var clave  = CLAVES[i]
			var mundo  = int(clave.split("-")[0])
			var nivel  = int(clave.split("-")[1])
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
			_on_nodo_enfocado(indice_actual)
			_mover_icono_a(indice_actual)

	elif event.is_action_pressed("mover_derecha") or event.is_action_pressed("ui_right"):
		var nuevo = min(CLAVES.size() - 1, indice_actual + 1)
		if nuevo != indice_actual:
			indice_actual = nuevo
			_on_nodo_enfocado(indice_actual)
			_mover_icono_a(indice_actual)
		elif event.is_action_pressed("confirmar") or event.is_action_pressed("ui_accept"):
			_on_nivel_presionado(CLAVES[indice_actual])
		elif event.is_action_pressed("ui_cancel"):
			_on_volver()
		
func _mover_icono_a(indice: int):
	var nodo_destino = nodos[CLAVES[indice]]
	icono.position = nodo_destino.position - icono.size / 2 + Vector2(40, -50)
