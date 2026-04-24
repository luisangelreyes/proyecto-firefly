extends Control

# La variable que ya tenías en el inspector
@export var escena_nivel: PackedScene

func _ready():
	# 1. Buscamos la "pantalla" del televisor
	var pantalla = $SubViewportContainer/SubViewport
	
	# 2. Limpiamos cualquier cosa vieja que pudiera haber adentro
	for hijo in pantalla.get_children():
		hijo.queue_free()
		
	# 3. Metemos el nivel 1 directamente a la pantalla
	if escena_nivel:
		var nivel_instanciado = escena_nivel.instantiate()
		pantalla.add_child(nivel_instanciado)
