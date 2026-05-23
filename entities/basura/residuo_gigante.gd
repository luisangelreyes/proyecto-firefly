extends Area2D

signal residuo_escapado(categoria: String)

# Siempre peligroso — no clasificable
var categoria: String  = "Peligroso"
var velocidad_caida: float = 260.0   # más lento que uno normal (es grande e intimidante)
var fue_atrapado: bool = false
var prob_peligroso: float = 1.0      # por compatibilidad con NivelBoss

func _ready():
	# Escala grande — 3x el tamaño de basura normal
	scale = Vector2(3.0, 3.0)

	# Shader rojo intenso para que sea inconfundible
	$Sprite2D.modulate = Color(1, 1, 1, 1)
	$Sprite2D.material = $Sprite2D.material.duplicate()
	var mat = $Sprite2D.material
	mat.set_shader_parameter("activar_borde", true)
	mat.set_shader_parameter("color_borde", Color(1.0, 0.0, 0.0, 1.0))
	mat.set_shader_parameter("grosor", 8.0)

	# Frame fijo — usa el primer índice peligroso (jeringa)
	$Sprite2D.frame = 42

func _process(delta):
	position.y += velocidad_caida * delta
	# Sin rotación — cae derecho para que sea bien legible

	if position.y > 1300:
		if not fue_atrapado:
			residuo_escapado.emit(categoria)
		queue_free()
