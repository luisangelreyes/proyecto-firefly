extends Control

var dificultad: String  = "normal"
var tiempo_limite: int  = 60
var densidad: String    = "normal"

@onready var btns_dif = [
	$ContenedorOpciones/FilaDificultad/HBoxDificultad/BtnFacil,
	$ContenedorOpciones/FilaDificultad/HBoxDificultad/BtnNormal,
	$ContenedorOpciones/FilaDificultad/HBoxDificultad/BtnDificil,
]
@onready var btns_tiempo = [
	$ContenedorOpciones/FilaTiempo/HBoxTiempo/Btn30s,
	$ContenedorOpciones/FilaTiempo/HBoxTiempo/Btn60s,
	$ContenedorOpciones/FilaTiempo/HBoxTiempo/Btn90s,
]
@onready var btns_densidad = [
	$ContenedorOpciones/FilaDensidad/HBoxDensidad/BtnPocos,
	$ContenedorOpciones/FilaDensidad/HBoxDensidad/BtnNormalD,
	$ContenedorOpciones/FilaDensidad/HBoxDensidad/BtnMuchos,
]

func _ready():
	$BtnJugar.pressed.connect(_on_jugar)
	$BtnVolver.pressed.connect(_on_volver)

	btns_dif[0].pressed.connect(func(): _set_dificultad("facil"))
	btns_dif[1].pressed.connect(func(): _set_dificultad("normal"))
	btns_dif[2].pressed.connect(func(): _set_dificultad("dificil"))

	btns_tiempo[0].pressed.connect(func(): _set_tiempo(30))
	btns_tiempo[1].pressed.connect(func(): _set_tiempo(60))
	btns_tiempo[2].pressed.connect(func(): _set_tiempo(90))

	btns_densidad[0].pressed.connect(func(): _set_densidad("pocos"))
	btns_densidad[1].pressed.connect(func(): _set_densidad("normal"))
	btns_densidad[2].pressed.connect(func(): _set_densidad("muchos"))

	_actualizar_botones()

func _set_dificultad(d: String):
	dificultad = d
	_actualizar_botones()

func _set_tiempo(t: int):
	tiempo_limite = t
	_actualizar_botones()

func _set_densidad(d: String):
	densidad = d
	_actualizar_botones()

func _actualizar_botones():
	var difs      = ["facil", "normal", "dificil"]
	var tiempos   = [30, 60, 90]
	var densidades = ["pocos", "normal", "muchos"]

	for i in range(btns_dif.size()):
		btns_dif[i].modulate = Color.WHITE if dificultad == difs[i] \
			else Color(0.5, 0.5, 0.5)
	for i in range(btns_tiempo.size()):
		btns_tiempo[i].modulate = Color.WHITE if tiempo_limite == tiempos[i] \
			else Color(0.5, 0.5, 0.5)
	for i in range(btns_densidad.size()):
		btns_densidad[i].modulate = Color.WHITE if densidad == densidades[i] \
			else Color(0.5, 0.5, 0.5)

func _on_jugar():
	SesionGlobal.es_modo_libre = true
	SesionGlobal.modo_libre_config = {
		"tipo":          "topdown",
		"dificultad":    dificultad,
		"tiempo_limite": tiempo_limite,
		"densidad":      densidad,
	}
	get_tree().change_scene_to_file(
        "res://scenes/niveles/modo_libre/NivelTopDownModoLibre.tscn"
		
	)

func _on_volver():
	get_tree().change_scene_to_file("res://scenes/menu/ModoLibre.tscn")
