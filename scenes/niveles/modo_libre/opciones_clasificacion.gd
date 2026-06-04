extends Control

var dificultad: String   = "normal"
var tiempo_objeto: float = 8.0
var modo_infinito: bool  = false
var timer_minutos: int   = 0

@onready var btns_dif   = [
	$ContenedorOpciones/FilaDificultad/HBoxDificultad/BtnFacil,
	$ContenedorOpciones/FilaDificultad/HBoxDificultad/BtnNormal,
	$ContenedorOpciones/FilaDificultad/HBoxDificultad/BtnDificil
]
@onready var btns_tiempo = [
	$ContenedorOpciones/FilaTiempoObjeto/HBoxTiempo/Btn5s,
	$ContenedorOpciones/FilaTiempoObjeto/HBoxTiempo/Btn8s,
	$ContenedorOpciones/FilaTiempoObjeto/HBoxTiempo/Btn12s
]
@onready var btns_timer = [
	$ContenedorOpciones/FilaTimer/HBoxTimer/BtnTimer1,
	$ContenedorOpciones/FilaTimer/HBoxTimer/BtnTimer2,
	$ContenedorOpciones/FilaTimer/HBoxTimer/BtnTimer3
]
@onready var check_inf  = $ContenedorOpciones/FilaInfinito/CheckInfinito
@onready var fila_timer = $ContenedorOpciones/FilaTimer

func _ready():
	$BtnJugar.pressed.connect(_on_jugar)
	$BtnVolver.pressed.connect(_on_volver)

	btns_dif[0].pressed.connect(func(): _set_dificultad("facil"))
	btns_dif[1].pressed.connect(func(): _set_dificultad("normal"))
	btns_dif[2].pressed.connect(func(): _set_dificultad("dificil"))

	btns_tiempo[0].pressed.connect(func(): _set_tiempo(5.0))
	btns_tiempo[1].pressed.connect(func(): _set_tiempo(8.0))
	btns_tiempo[2].pressed.connect(func(): _set_tiempo(12.0))

	btns_timer[0].pressed.connect(func(): _set_timer(1))
	btns_timer[1].pressed.connect(func(): _set_timer(2))
	btns_timer[2].pressed.connect(func(): _set_timer(3))

	check_inf.toggled.connect(_on_infinito_toggled)

	_actualizar_botones()

func _set_dificultad(d: String):
	dificultad = d
	_actualizar_botones()

func _set_tiempo(t: float):
	tiempo_objeto = t
	_actualizar_botones()

func _set_timer(t: int):
	timer_minutos = t
	_actualizar_botones()

func _on_infinito_toggled(activo: bool):
	modo_infinito = activo
	fila_timer.visible = not activo
	if activo:
		timer_minutos = 0
	_actualizar_botones()

func _actualizar_botones():
	var difs   = ["facil", "normal", "dificil"]
	var tiemp  = [5.0, 8.0, 12.0]
	var timers = [1, 2, 3]

	for i in range(btns_dif.size()):
		btns_dif[i].modulate = Color.WHITE if dificultad == difs[i] \
			else Color(0.5, 0.5, 0.5)
	for i in range(btns_tiempo.size()):
		btns_tiempo[i].modulate = Color.WHITE if tiempo_objeto == tiemp[i] \
			else Color(0.5, 0.5, 0.5)
	for i in range(btns_timer.size()):
		btns_timer[i].modulate = Color.WHITE if timer_minutos == timers[i] \
			else Color(0.5, 0.5, 0.5)

func _on_jugar():
	SesionGlobal.es_modo_libre = true
	SesionGlobal.modo_libre_config = {
		"tipo":          "clasificacion",
		"dificultad":    dificultad,
		"tiempo_objeto": tiempo_objeto,
		"modo_infinito": modo_infinito,
		"timer_minutos": timer_minutos,
	}
	get_tree().change_scene_to_file(
        "res://scenes/niveles/modo_libre/NivelClasificacionModoLibre.tscn"
	)

func _on_volver():
	get_tree().change_scene_to_file("res://scenes/menu/ModoLibre.tscn")
