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
	$LabelMundo.text = "ZONA 2 — Las Calles de la Ciudad"

	for i in range(CLAVES.size()):
		var clave = CLAVES[i]
		var btn   = nodos[clave].get_node("BtnNodo")
		btn.pressed.connect(_on_nivel_presionado.bind(clave))
		btn.focus_entered.connect(_on_nodo_enfocado.bind(i))
		

	$BotonVolver.pressed.connect(_on_volver)
	$BotonVolver.focus_entered.connect(_on_volver_enfocado)
	
	_aplicar_estilos_labels()
	_iniciar_animacion_cursor()

	_actualizar_mapa()
	_seleccionar_nivel_activo()
	_verificar_mundo_completado()

func _aplicar_estilos_labels():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.15, 0.85)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	
	for clave in CLAVES:
		nodos[clave].get_node("LabelNombre").add_theme_stylebox_override("normal", style)
	
	var header_style = style.duplicate()
	header_style.bg_color = Color(0, 0, 0, 0.7)
	$LabelMundo.add_theme_stylebox_override("normal", header_style)
	lbl_descripcion.add_theme_stylebox_override("normal", header_style)

var bounce_tween: Tween
var move_tween: Tween

func _iniciar_animacion_cursor():
	if bounce_tween and bounce_tween.is_running():
		bounce_tween.kill()
		
	var base_y = icono.position.y
	bounce_tween = create_tween().set_loops()
	bounce_tween.tween_property(icono, "position:y", base_y - 10.0, 1.0).set_trans(Tween.TRANS_SINE)
	bounce_tween.tween_property(icono, "position:y", base_y, 1.0).set_trans(Tween.TRANS_SINE)
	
func _on_volver_enfocado():
	icono.visible = false
	lbl_descripcion.text = "Regresar al menú principal."
	_resaltar_nodo(-1) 
	
func _verificar_mundo_completado():
	if not SesionGlobal.recien_completado:
		return
	SesionGlobal.recien_completado = false  # resetear inmediatamente
	var todos_completados = true
	for i in range(CLAVES.size() - 1):
		var sig = CLAVES[i + 1]
		if not SesionGlobal.nivel_disponible(
			int(sig.split("-")[0]), int(sig.split("-")[1])
		):
			todos_completados = false
			break

	var ultima = CLAVES[-1]
	if todos_completados and SesionGlobal.nivel_disponible(
		int(ultima.split("-")[0]), int(ultima.split("-")[1])
	):
		await get_tree().create_timer(1.5).timeout
		if is_inside_tree():
			get_tree().change_scene_to_file("res://ui/menu/SelectorMundos.tscn")
	

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
			btn.focus_mode = Control.FOCUS_ALL
		else:
			btn.modulate = COLOR_BLOQUEADO
			lbl_n.text   = "🔒"
			btn.disabled = true
			btn.focus_mode = Control.FOCUS_NONE

func _seleccionar_nivel_activo():
	var idx_activo = 0
	for i in range(CLAVES.size()):
		var clave  = CLAVES[i]
		var mundo  = int(clave.split("-")[0])
		var nivel  = int(clave.split("-")[1])
		if SesionGlobal.nivel_disponible(mundo, nivel):
			idx_activo = i
			# Verificar si está completado
			var idx_sig = i + 1
			if idx_sig < CLAVES.size():
				var sig   = CLAVES[idx_sig]
				var m2    = int(sig.split("-")[0])
				var n2    = int(sig.split("-")[1])
				var completado = SesionGlobal.nivel_disponible(m2, n2)
				if not completado:
					break  # este es el siguiente a jugar
	
	indice_actual = idx_activo
	var clave_activa = CLAVES[idx_activo]
	nodos[clave_activa].get_node("BtnNodo").grab_focus()
	lbl_descripcion.text = DESCRIPCIONES[clave_activa]
	_mover_icono_a(idx_activo)
	_resaltar_nodo(idx_activo)

# REEMPLAZA TU FUNCIÓN ACTUAL POR ESTA:
func _on_nodo_enfocado(indice: int):
	icono.visible = true # Nos aseguramos de que el icono regrese
	indice_actual = indice
	lbl_descripcion.text = DESCRIPCIONES[CLAVES[indice]]
	
	# Le quitamos el foco al botón de regresar si lo tenía
	var foco = get_viewport().gui_get_focus_owner()
	if foco == $BotonVolver:
		$BotonVolver.release_focus()
		
	# Si el nivel no está bloqueado, le damos el foco real
	var btn = nodos[CLAVES[indice]].get_node("BtnNodo")
	if not btn.disabled and foco != btn:
		btn.grab_focus()
		
	_resaltar_nodo(indice)
	_mover_icono_a(indice)

func _resaltar_nodo(indice: int):
	for i in range(CLAVES.size()):
		var nodo_parent = nodos[CLAVES[i]]
		var btn = nodo_parent.get_node("BtnNodo")
		
		# Reset scale
		nodo_parent.scale = Vector2(1.0, 1.0)
		
		if not btn.disabled:
			nodo_parent.modulate = Color(1, 1, 1, 1) # Reset fade
			var clave  = CLAVES[i]
			var _mundo  = int(clave.split("-")[0])
			var _nivel  = int(clave.split("-")[1])
			var idx_sig = i + 1
			var completado = false
			if idx_sig < CLAVES.size():
				var sig = CLAVES[idx_sig]
				completado = SesionGlobal.nivel_disponible(
					int(sig.split("-")[0]), int(sig.split("-")[1])
				)
			btn.modulate = COLOR_COMPLETADO if completado else COLOR_DISPONIBLE
		else:
			nodo_parent.modulate = Color(0.6, 0.6, 0.6, 0.8) # Fade out locked
		
		if i == indice and not btn.disabled:
			btn.modulate = COLOR_SELECCION

func _on_nivel_presionado(clave: String):
	# Verificar que el nivel no esté bloqueado
	var btn = nodos[clave].get_node("BtnNodo")
	if btn.disabled:
		return

	var ruta = SesionGlobal.get_ruta_nivel(
		int(clave.split("-")[0]),
		int(clave.split("-")[1])
	)
	if ruta != "":
		get_tree().change_scene_to_file(ruta)

func _mover_icono_a(indice: int):
	var nodo_destino = nodos[CLAVES[indice]]
	var pos_destino = nodo_destino.position - icono.size / 2 + Vector2(40, -50)
	icono.visible = true
	
	if move_tween and move_tween.is_running():
		move_tween.kill()
	if bounce_tween and bounce_tween.is_running():
		bounce_tween.kill()
		
	move_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(icono, "position", pos_destino, 0.4)
	move_tween.finished.connect(_iniciar_animacion_cursor)

func _on_volver():
	get_tree().change_scene_to_file("res://ui/menu/SelectorMundos.tscn")


var ultimo_movimiento: int = 0

func _unhandled_input(event):
	if not (event is InputEventKey or event is InputEventJoypadButton or
			event is InputEventJoypadMotion):
		return
	if event.is_echo():
		return

	var foco = get_viewport().gui_get_focus_owner()
	var tiempo_actual = Time.get_ticks_msec()

	# 1. Movimiento Izquierda
	if event.is_action_pressed("mover_izquierda") or event.is_action_pressed("ui_left"):
		if tiempo_actual - ultimo_movimiento > 200:
			var nuevo = max(0, indice_actual - 1)
			if nuevo != indice_actual and not nodos[CLAVES[nuevo]].get_node("BtnNodo").disabled:
				indice_actual = nuevo
				_on_nodo_enfocado(indice_actual)
			ultimo_movimiento = tiempo_actual
		get_viewport().set_input_as_handled()

	# 2. Movimiento Derecha
	elif event.is_action_pressed("mover_derecha") or event.is_action_pressed("ui_right"):
		if tiempo_actual - ultimo_movimiento > 200:
			var nuevo = min(CLAVES.size() - 1, indice_actual + 1)
			if nuevo != indice_actual and not nodos[CLAVES[nuevo]].get_node("BtnNodo").disabled:
				indice_actual = nuevo
				_on_nodo_enfocado(indice_actual)
			ultimo_movimiento = tiempo_actual
		get_viewport().set_input_as_handled()


	elif event.is_action_pressed("confirmar") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled() 
		if foco == $BotonVolver:
			_on_volver()
		else:
			_on_nivel_presionado(CLAVES[indice_actual])

	else:
		var cancelar = false
		if event.is_action_pressed("ui_cancel"):
			cancelar = true
		elif event is InputEventKey and event.keycode == KEY_ESCAPE:
			cancelar = true
		elif event is InputEventJoypadButton and event.button_index == JOY_BUTTON_B:
			cancelar = true

		if cancelar:
			get_viewport().set_input_as_handled()
			
			_on_volver()
