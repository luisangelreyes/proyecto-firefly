extends Control

func _ready():
	$AnimationPlayer.play("aparecer_logo")
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_anim_name):
	_cargar_perfil_y_continuar()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		$AnimationPlayer.stop()
		_cargar_perfil_y_continuar()

func _cargar_perfil_y_continuar():
	# Cargar el último perfil automáticamente antes de ir al menú
	var ultimo = SesionGlobal.cargar_ultimo_perfil()
	var perfiles = SesionGlobal.cargar_todos_los_perfiles()

	if ultimo != "" and perfiles.has(ultimo):
		SesionGlobal.cargar_partida(ultimo)

	get_tree().change_scene_to_file("res://scenes/menu/PantallaIntro.tscn")
