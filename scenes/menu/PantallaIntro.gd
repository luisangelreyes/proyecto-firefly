extends Control

var parpadeo_timer: float = 0.0
var parpadeo_visible: bool = true
var input_habilitado: bool = false

func _ready():
	# Cargar último perfil automáticamente
	var ultimo = SesionGlobal.cargar_ultimo_perfil()

	if ultimo != "":
		SesionGlobal.cargar_partida(ultimo)
		$LabelPerfil.text = "Continuando como: " + ultimo.to_upper()
		$LabelPerfil.visible = true
	else:
		$LabelPerfil.visible = false

	if Configuracion.movimiento_reducido:
		$LabelPresiona.modulate.a = 1.0
		input_habilitado = true
	else:
		$LabelPresiona.modulate.a = 0.0

		# Fade in del texto "Presiona cualquier botón"
		var tween = create_tween()
		tween.tween_property($LabelPresiona, "modulate:a", 1.0, 1.5)
		tween.tween_callback(func(): input_habilitado = true)

func _process(delta):
	if Configuracion.movimiento_reducido:
		return

	# Parpadeo del texto
	if input_habilitado:
		parpadeo_timer += delta
		if parpadeo_timer >= 0.7:
			parpadeo_timer = 0.0
			parpadeo_visible = not parpadeo_visible
			$LabelPresiona.modulate.a = 1.0 if parpadeo_visible else 0.3

func _input(event):
	if not input_habilitado:
		return

	# Cualquier tecla, botón o clic activa la transición
	var es_input_valido = (
		(event is InputEventKey and event.pressed and not event.is_echo()) or
		(event is InputEventJoypadButton and event.pressed) or
		(event is InputEventMouseButton and event.pressed)
	)

	if es_input_valido:
		_ir_a_menu()

func _ir_a_menu():
	input_habilitado = false
	if Configuracion.movimiento_reducido:
		get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
		return

	# Fade out antes de cambiar de escena
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
	)
