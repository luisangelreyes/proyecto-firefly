extends Control

func _on_modo_historia_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/menus/menu_principal.tscn")

func _on_modo_arcade_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/modos_de_juego/modo_arcade.tscn")


func _on_logros_pressed() -> void:
	pass # Replace with function body.


func _on_salir_pressed() -> void:
	get_tree().quit()
