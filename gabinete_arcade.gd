extends Control


# Arrastra tu escena de nivel y de menú desde el panel de archivos hasta aquí
@export var escena_nivel: PackedScene
@export var escena_menu: PackedScene

# Hacemos referencia al televisor virtual
@onready var el_viewport = $SubViewportContainer/SubViewport

func _ready():
	# Al empezar, metemos el menú dentro del televisor
	if escena_menu:
		cambiar_escena_interna(escena_menu)

# Esta función la llamaremos desde el menú cuando se presione el botón
func iniciar_juego():
	if escena_nivel:
		cambiar_escena_interna(escena_nivel)

func cambiar_escena_interna(nueva_escena_packed):
	# Limpiamos lo que haya dentro (borra el menú para poner el nivel)
	for hijo in el_viewport.get_children():
		hijo.queue_free()
	
	# Instanciamos y añadimos la nueva escena al Viewport
	var instancia = nueva_escena_packed.instantiate()
	el_viewport.add_child(instancia)
