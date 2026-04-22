extends Control # (O el tipo de nodo que tengas como raíz del menú)

func _ready():
	# Conectamos la señal del botón en código (Esto se queda igual, ¡es muy buena práctica!)
	$VBoxContainer/Button.pressed.connect(_on_boton_jugar_presionado)
	$VBoxContainer/Button.grab_focus()
func _on_boton_jugar_presionado():
	# --- NUEVA LÓGICA DE CAMBIO DE ESCENA ---
	
	# Escalamos el árbol de nodos para encontrar al Director:
	# 1er get_parent() = El SubViewport (El televisor virtual)
	# 2do get_parent() = El SubViewportContainer (El mueble del televisor)
	# 3er get_parent() = El GabineteArcade (El dueño de todo)
	var director_gabinete = get_parent().get_parent().get_parent()
	
	# Programación defensiva: Verificamos que realmente hayamos encontrado al gabinete
	# y que tenga la función que necesitamos antes de llamarla.
	if director_gabinete.has_method("iniciar_juego"):
		director_gabinete.iniciar_juego()
	else:
		print("Error: No se pudo encontrar al GabineteArcade para iniciar el juego.")
