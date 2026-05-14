extends Area2D
signal tutorial_completado(acierto: bool)
signal residuo_escapado()

var velocidad_caida = 290
var categoria = ""
var velocidad_rotacion = 0.0
var mostrar_ayuda_visual = true
var fue_atrapado = false

# Probabilidad de que salga peligroso (0.0 = nunca, 1.0 = siempre)
# El nivel puede cambiar este valor antes de add_child()
var prob_peligroso: float = 0

const INDICES_INORGANICO   = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
const INDICES_ORGANICO = [21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39]
const INDICES_PELIGROSO  = [40,41,42,43,45,46,47,48,49]

const CATALOGO_NIVEL_1 = {
	0: "Inorganico",    
	1: "Inorganico",
	2: "Inorganico",
	3: "Inorganico",
	4: "Inorganico",
	5: "Inorganico",
	6: "Inorganico",
	7: "Inorganico",
	8: "Inorganico",
	9: "Inorganico",
	10: "Inorganico",   
	11: "Inorganico",
	12: "Inorganico",
	13: "Inorganico",
	14: "Inorganico",
	15: "Inorganico",
	16: "Inorganico",
	17: "Inorganico",
	18: "Inorganico",
	19: "Inorganico",
	20: "Organico",
	21: "Organico",
	22: "Organico",
	23: "Organico",
	24: "Organico",
	25: "Organico",
	26: "Organico",
	27: "Organico",
	28: "Organico",
	29: "Organico",
	30: "Organico",   
	31: "Organico",
	32: "Organico",
	33: "Organico",
	34: "Organico",
	35: "Organico",
	36: "Organico",
	37: "Organico",
	38: "Organico",
	39: "Organico",
	40: "Peligroso",   
	41: "Peligroso",
	42: "Peligroso",
	43: "Peligroso",
	44: "Peligroso",
	45: "Peligroso",
	46: "Peligroso",
	47: "Peligroso",
	48: "Peligroso",
	49: "Peligroso",
	
}

func _ready():
	$Sprite2D.modulate = Color(1, 1, 1, 1)
	
	# Elegimos categoría según probabilidad, luego frame aleatorio de esa categoría
	var id_basura: int
	var tirada = randf()  # número entre 0.0 y 1.0
	
	if tirada < prob_peligroso:
		id_basura = INDICES_PELIGROSO.pick_random()
	elif tirada < prob_peligroso + 0.35:
		id_basura = INDICES_INORGANICO.pick_random()
	else:
		id_basura = INDICES_ORGANICO.pick_random()
	
	$Sprite2D.frame = id_basura
	categoria = CATALOGO_NIVEL_1[id_basura]
	velocidad_rotacion = randf_range(-60.0, 60.0)
	
	$Sprite2D.material = $Sprite2D.material.duplicate()
	var mat = $Sprite2D.material
	mat.set_shader_parameter("activar_borde", mostrar_ayuda_visual)
	
	if mostrar_ayuda_visual:
		if categoria == "Organico":
			mat.set_shader_parameter("color_borde", Color(0.0, 1.0, 0.0, 1.0))
		elif categoria == "Inorganico":
			mat.set_shader_parameter("color_borde", Color(0.0, 0.5, 1.0, 1.0))
		elif categoria == "Peligroso":
			mat.set_shader_parameter("color_borde", Color(1.0, 0.0, 0.0, 1.0))

func _process(delta):
	position.y += velocidad_caida * delta
	rotation_degrees += velocidad_rotacion * delta
	
	if position.y > 1200:
		if not fue_atrapado:
			residuo_escapado.emit()
		queue_free()
