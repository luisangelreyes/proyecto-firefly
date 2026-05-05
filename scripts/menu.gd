extends Control

# ── REFERENCIAS ──────────────────────────────────────────────────────────────
@onready var label_bienvenida  = $ContenedorMenu/LabelBienvenida
@onready var label_descripcion = $LabelDescripcion

@onready var ventana_perfiles  = $VentanaPerfiles
@onready var lista_perfiles    = $VentanaPerfiles/ListaPerfiles
@onready var ventana_nuevo     = $VentanaNuevo
@onready var entrada_nombre    = $VentanaNuevo/EntradaNombre

# ── CONFIGURACIÓN DEL MENÚ TLOU ───────────────────────────────────────────
const DESCRIPCIONES = [
	"Juega la historia de Liz y su abuelo Sergio.",
	"Pon a prueba tus habilidades en los minijuegos sueltos.",
	"Consulta tus logros y estadísticas.",
	"Ajusta controles, audio y accesibilidad.",
	"Salir al escritorio.",
	"Cambia de parfil de Jugador"
]

const COLOR_ACTIVO   = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_INACTIVO = Color(0.40, 0.40, 0.40, 1.0)
const SIZE_ACTIVO    = 32
const SIZE_INACTIVO  = 26

var items: Array = []
var indice_actual: int = 0
var menu_bloqueado: bool = false  # true cuando una ventana flotante está abierta

# ── INICIALIZACIÓN ────────────────────────────────────────────────────────────
func _ready():
	items = [
		$ContenedorMenu/LabelModoAventura,
		$ContenedorMenu/LabelArcade,
		$ContenedorMenu/LabelLogros,
		$ContenedorMenu/LabelOpciones,
		$ContenedorMenu/LabelSalir,
		$ContenedorMenu/BotonCambiar
	]

	# Conectar ventana perfiles (igual que antes)
	$VentanaPerfiles/CajaBotones/BotonSeleccionar.pressed.connect(_on_seleccionar_perfil)
	$VentanaPerfiles/CajaBotones/BotonNuevo.pressed.connect(abrir_ventana_nuevo)
	$VentanaPerfiles/CajaBotones/BotonCerrar.pressed.connect(cerrar_ventanas)
	$VentanaPerfiles/CajaBotones/BotonBorrar.pressed.connect(_on_borrar_perfil)

	# Conectar ventana nuevo perfil (igual que antes)
	$VentanaNuevo/CajaBotones/BotonAceptar.pressed.connect(_on_crear_nuevo_perfil)
	$ContenedorMenu/BotonCambiar.pressed.connect(abrir_ventana_perfiles)

	cerrar_ventanas()
	inicializar_sistema()
	_actualizar_seleccion()
	for i in range(items.size()):
		var label = items[i]
		# Necesitamos pasar el índice al closure
		label.mouse_entered.connect(_on_label_hover.bind(i))
		label.gui_input.connect(_on_label_click.bind(i))

func _on_label_hover(indice: int):
	if menu_bloqueado:
		return
	indice_actual = indice
	_actualizar_seleccion()

func _on_label_click(event: InputEvent, indice: int):
	if menu_bloqueado:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		indice_actual = indice
		_confirmar_seleccion()
		
func _unhandled_input(event):
	if menu_bloqueado:
		return
	
	if not (event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion):
		return
	
	if event.is_echo():
		return

	if event.is_action_pressed("mover_arriba") or event.is_action_pressed("ui_up"):
		indice_actual = max(0, indice_actual - 1)
		_actualizar_seleccion()

	elif event.is_action_pressed("mover_abajo") or event.is_action_pressed("ui_down"):
		indice_actual = min(items.size() - 1, indice_actual + 1)
		_actualizar_seleccion()

	elif event.is_action_pressed("confirmar") or event.is_action_pressed("ui_accept"):
		_confirmar_seleccion()
		
func _actualizar_seleccion():
	for i in range(items.size()):
		if i == indice_actual:
			items[i].add_theme_color_override("font_color", COLOR_ACTIVO)
			items[i].add_theme_font_size_override("font_size", SIZE_ACTIVO)
		else:
			items[i].add_theme_color_override("font_color", COLOR_INACTIVO)
			items[i].add_theme_font_size_override("font_size", SIZE_INACTIVO)

	label_descripcion.text = DESCRIPCIONES[indice_actual]

func _confirmar_seleccion():
	match indice_actual:
		0: _iniciar_modo_aventura()
		1: _iniciar_arcade()
		2: _abrir_logros() 
		3: _abrir_opciones() 
		4: get_tree().quit()

# ── ACCIONES DEL MENÚ ────────────────────────────────────────────────────────
func _iniciar_modo_aventura():
	if SesionGlobal.perfil_actual == "":
		# No hay perfil cargado, abrimos selector antes de jugar
		abrir_ventana_perfiles()
		return
	get_tree().change_scene_to_file("res://scenes/niveles/NivelTutorial1.tscn")

func _iniciar_arcade():
	if SesionGlobal.perfil_actual == "":
		abrir_ventana_perfiles()
		return
	get_tree().change_scene_to_file("res://scenes/niveles/Nivel.tscn")

func _abrir_opciones():
	if SesionGlobal.perfil_actual == "":
		abrir_ventana_perfiles()
		return
	get_tree().change_scene_to_file("res://scenes/opciones/opciones.tscn")
	
func _abrir_logros():
	if SesionGlobal.perfil_actual == "":
		abrir_ventana_perfiles()
		return
	get_tree().change_scene_to_file("res://scenes/logros/logros.tscn")

# ── LÓGICA DE ARRANQUE (RF-05) ────────────────────────────────────────────────
func inicializar_sistema():
	var perfiles = SesionGlobal.cargar_todos_los_perfiles()

	if perfiles.is_empty():
		label_bienvenida.text = "¡Crea un perfil para empezar!" 
		abrir_ventana_nuevo()
	else:
		var ultimo_perfil = perfiles.keys()[0]
		SesionGlobal.cargar_partida(ultimo_perfil)
		_actualizar_bienvenida()

func _actualizar_bienvenida():
	label_bienvenida.text = "HOLA DE NUEVO! " + SesionGlobal.perfil_actual.to_upper()

# ── GESTIÓN DE VENTANAS FLOTANTES ────────────────────────────────────────────
func abrir_ventana_perfiles():
	menu_bloqueado = true
	ventana_nuevo.hide()
	ventana_perfiles.show()

	lista_perfiles.clear()
	var perfiles = SesionGlobal.cargar_todos_los_perfiles()
	for nombre in perfiles.keys():
		lista_perfiles.add_item(nombre)

func abrir_ventana_nuevo():
	menu_bloqueado = true
	ventana_perfiles.hide()
	ventana_nuevo.show()
	entrada_nombre.text = ""
	entrada_nombre.grab_focus()

func cerrar_ventanas():
	menu_bloqueado = false
	ventana_perfiles.hide()
	ventana_nuevo.hide()

# ── ACCIONES DE PERFILES (RF-01, RF-02, RF-03) ───────────────────────────────
func _on_crear_nuevo_perfil():
	var nuevo_nombre = entrada_nombre.text.strip_edges()
	if nuevo_nombre != "":
		SesionGlobal.iniciar_nueva_partida(nuevo_nombre)
		cerrar_ventanas()
		_actualizar_bienvenida()

func _on_seleccionar_perfil():
	var seleccionados = lista_perfiles.get_selected_items()
	if seleccionados.size() > 0:
		var nombre = lista_perfiles.get_item_text(seleccionados[0])
		SesionGlobal.cargar_partida(nombre)
		cerrar_ventanas()
		_actualizar_bienvenida()

func _on_borrar_perfil():
	var seleccionados = lista_perfiles.get_selected_items()
	if seleccionados.size() == 0:
		return

	var nombre_a_borrar = lista_perfiles.get_item_text(seleccionados[0])
	var perfiles = SesionGlobal.cargar_todos_los_perfiles()

	if perfiles.has(nombre_a_borrar):
		perfiles.erase(nombre_a_borrar)
		var archivo = FileAccess.open(SesionGlobal.ruta_guardado, FileAccess.WRITE)
		archivo.store_string(JSON.stringify(perfiles, "\t"))
		archivo.close()
		abrir_ventana_perfiles()

		if perfiles.is_empty():
			cerrar_ventanas()
			inicializar_sistema()
