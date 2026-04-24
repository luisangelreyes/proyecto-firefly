extends Control

func _ready():
	# Reproducimos la animación de inicio
	$AnimationPlayer.play("aparecer_logo")
	
	# Conectamos la señal de que la animación terminó
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_anim_name):
	# Cambiamos a la escena principal (tu GabineteArcade)
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")

# Opcional: Permitir que el jugador se salte la intro con una tecla
func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
