extends Area2D
signal tutorial_completado(acierto: bool)
signal residuo_escapado(categoria: String)


# La velocidad base la sigue fijando el nivel según la oleada.
# Aquí guardamos el multiplicador final que se aplica en _ready().
var velocidad_caida = 290
var categoria = ""
var velocidad_rotacion = 0.0

# Rangos de multiplicador de velocidad por categoría.
# El nivel asigna velocidad_caida antes de add_child(); _ready() la escala.
const VELOCIDAD_MULT = {
	"Organico":   [0.80, 1.00],   # ligeros — caen un poco más despacio
	"Inorganico": [1.00, 1.25],   # variado  — velocidad normal a rápida
	"Peligroso":  [1.30, 1.70],   # pesados/urgentes — siempre más rápido
}
var mostrar_ayuda_visual = true
var fue_atrapado = false

# Probabilidad de que salga peligroso (0.0 = nunca, 1.0 = siempre)
# El nivel puede cambiar este valor antes de add_child()
var prob_peligroso: float = 0

const INDICES_INORGANICO   = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
const INDICES_ORGANICO = [21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39]
const INDICES_PELIGROSO  = [40,41,42,43,45,46,47,48,49]

var CATALOGO_NIVEL_1: Dictionary = {}

func _init():
	# Este bucle recorre los números del 0 al 49
	for i in range(50):
		if i <= 19:
			CATALOGO_NIVEL_1[i] = "Inorganico"
		elif i <= 39:
			CATALOGO_NIVEL_1[i] = "Organico"
		else:
			CATALOGO_NIVEL_1[i] = "Peligroso"

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

	# Escalar velocidad según categoría
	var rango = VELOCIDAD_MULT.get(categoria, [1.0, 1.0])
	var mult  = randf_range(rango[0], rango[1])
	velocidad_caida *= mult
	
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
			residuo_escapado.emit(categoria)
		queue_free()
