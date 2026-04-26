extends Control

# --- Referencias a los nodos ---
@onready var boton_jugar = $BotonJugar
@onready var texto_nombre = $CajaBienvenida/TextoNombre
@onready var boton_cambiar = $CajaBienvenida/BotonCambiar

@onready var ventana_perfiles = $VentanaPerfiles
@onready var lista_perfiles = $VentanaPerfiles/ListaPerfiles

@onready var ventana_nuevo = $VentanaNuevo
@onready var entrada_nombre = $VentanaNuevo/EntradaNombre

var nombre_seleccionado_temporal = ""

func _ready():
	# Conectar botones principales
	boton_jugar.pressed.connect(_on_boton_jugar)
	boton_cambiar.pressed.connect(abrir_ventana_perfiles)
	
	# Conectar botones de Ventana Perfiles
	$VentanaPerfiles/CajaBotones/BotonSeleccionar.pressed.connect(_on_seleccionar_perfil)
	$VentanaPerfiles/CajaBotones/BotonNuevo.pressed.connect(abrir_ventana_nuevo)
	$VentanaPerfiles/CajaBotones/BotonCerrar.pressed.connect(cerrar_ventanas)	
	$VentanaPerfiles/CajaBotones/BotonBorrar.pressed.connect(_on_borrar_perfil)

	
	# Conectar botones de Ventana Nuevo (RF-01)
	$VentanaNuevo/CajaBotones/BotonAceptar.pressed.connect(_on_crear_nuevo_perfil)
	$VentanaNuevo/CajaBotones/BotonCancelar.pressed.connect(abrir_ventana_perfiles)
	
	# Ocultar ventanas flotantes al arrancar
	cerrar_ventanas()
	
	# Arranque PopCap: Verificamos si hay perfiles
	inicializar_sistema()

# --- Lógica de Arranque (RF-05) ---
func inicializar_sistema():
	var perfiles = SesionGlobal.cargar_todos_los_perfiles()
	
	if perfiles.is_empty():
		# Si no hay nadie, forzamos a crear el primer perfil
		texto_nombre.text = "¡Crea un perfil para jugar!"
		boton_jugar.disabled = true
		abrir_ventana_nuevo()
	else:
		# Si hay perfiles, tomamos el último usado (o el primero de la lista)
		var ultimo_perfil = perfiles.keys()[0] 
		SesionGlobal.cargar_partida(ultimo_perfil)
		actualizar_bienvenida()

func actualizar_bienvenida():
	texto_nombre.text = "¡Bienvenido de nuevo, " + SesionGlobal.perfil_actual + "!"
	boton_jugar.disabled = false
	boton_jugar.grab_focus()

# --- Gestión de Ventanas Flotantes ---
func abrir_ventana_perfiles():
	ventana_nuevo.hide()
	ventana_perfiles.show()
	
	# Limpiamos la lista y cargamos los nombres del JSON (RF-02)
	lista_perfiles.clear()
	var perfiles = SesionGlobal.cargar_todos_los_perfiles()
	
	for nombre in perfiles.keys():
		lista_perfiles.add_item(nombre)

func abrir_ventana_nuevo():
	ventana_perfiles.hide()
	ventana_nuevo.show()
	entrada_nombre.text = ""
	entrada_nombre.grab_focus()

func cerrar_ventanas():
	ventana_perfiles.hide()
	ventana_nuevo.hide()

# --- Acciones de Botones ---
func _on_crear_nuevo_perfil():
	var nuevo_nombre = entrada_nombre.text.strip_edges()
	
	if nuevo_nombre != "":
		# RF-01: Creamos el perfil y lo cargamos
		SesionGlobal.iniciar_nueva_partida(nuevo_nombre)
		cerrar_ventanas()
		actualizar_bienvenida()
func _on_borrar_perfil():
	print("--- INICIANDO PROTOCOLO DE BORRADO ---")
	
	# Sospechoso 1: ¿Seleccionaste un nombre?
	var items_seleccionados = lista_perfiles.get_selected_items()
	print("Items seleccionados: ", items_seleccionados.size())
	
	if items_seleccionados.size() > 0:
		var indice = items_seleccionados[0]
		var nombre_a_borrar = lista_perfiles.get_item_text(indice)
		print("Intentando borrar el perfil: ", nombre_a_borrar)
		
		var perfiles = SesionGlobal.cargar_todos_los_perfiles()
		
		# Sospechoso 2: ¿Existe en el diccionario?
		if perfiles.has(nombre_a_borrar):
			perfiles.erase(nombre_a_borrar)
			print("Perfil eliminado de la memoria. Guardando JSON...")
			
			var archivo = FileAccess.open(SesionGlobal.ruta_guardado, FileAccess.WRITE)
			archivo.store_string(JSON.stringify(perfiles, "\t"))
			archivo.close()
			
			print("¡JSON sobrescrito con éxito!")
			
			# Refrescamos la UI
			abrir_ventana_perfiles() 
			
			if perfiles.is_empty():
				print("Ya no quedan perfiles. Reiniciando menú...")
				cerrar_ventanas()
				inicializar_sistema()
		else:
			print("ERROR: El nombre está en la lista visual, pero no en el archivo JSON.")
	else:
		print("AVISO: Hiciste clic en Borrar, pero no habías seleccionado a nadie en la lista.")

func _on_seleccionar_perfil():
	var items_seleccionados = lista_perfiles.get_selected_items()
	
	if items_seleccionados.size() > 0:
		# Obtenemos el texto del item que el jugador seleccionó en la lista
		var indice = items_seleccionados[0]
		var nombre = lista_perfiles.get_item_text(indice)
		
		# RF-02: Cargamos la partida
		SesionGlobal.cargar_partida(nombre)
		cerrar_ventanas()
		actualizar_bienvenida()

func _on_boton_jugar():
	# El menú ahora es el jefe, así que simplemente teletransporta al jugador al Gabinete
	get_tree().change_scene_to_file("res://scenes/niveles/tetris/gabinete_tetris.tscn")
