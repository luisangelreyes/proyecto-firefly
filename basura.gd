extends Area2D

var velocidad_caida = 590 
var tipo_basura = 0 # 0 = Orgánico, 1 = Inorgánico, 2 = Peligroso
# --- NUEVO: Cargamos las imágenes en la memoria ---
var texturas_organicas = [
	preload("res://trash_apple.png"),
	preload("res://trash_bone.png"),
	preload("res://trash_bread.png"),
	preload("res://trash_chese.png"),
	preload("res://trash_leaf.png")
]

var texturas_inorganicas = [
	preload("res://trash_bottle.png"),
	preload("res://trash_box.png"),
	preload("res://trash_cup.png"),
	preload("res://trash_plastic.png"),
	preload("res://trash_nail.png")
]
func _ready():
	tipo_basura = randi() % 3
	
	if tipo_basura == 0:
		$Sprite2D.modulate = Color(0.2, 1.0, 0.2) # Verde (Orgánico)
	elif tipo_basura == 1:
		$Sprite2D.modulate = Color(0.2, 0.4, 1.0) # Azul (Inorgánico)
	else:
		$Sprite2D.modulate = Color(1.0, 0.2, 0.2) # Rojo (Peligroso)

func _process(delta):
	position.y += velocidad_caida * delta
	
	if position.y > 800:
		queue_free()
		
func configurar_textura():
	# Primero, nos aseguramos de quitar cualquier color tintado que hayamos usado antes
	$Sprite2D.modulate = Color(1, 1, 1, 1) # Blanco puro (sin tinte)
	
	if tipo_basura == 0:
		# pick_random() elige uno al azar de la lista (Godot 4)
		$Sprite2D.texture = texturas_organicas.pick_random() 
	else:
		$Sprite2D.texture = texturas_inorganicas.pick_random()
