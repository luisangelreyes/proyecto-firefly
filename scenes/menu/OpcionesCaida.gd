extends Control

var dificultad: String = "normal"
var velocidad: int = 100
var modo_infinito: bool = false
var timer_minutos: int = 0   # 0 = sin límite



@onready var btns_dif     = [
	$ContenedorOpciones/FilaDificultad/HBoxDificultad/BtnFacil,
	$ContenedorOpciones/FilaDificultad/HBoxDificultad/BtnNormal,
	$ContenedorOpciones/FilaDificultad/HBoxDificultad/BtnDificil]
@onready var btns_vel     = [
	$ContenedorOpciones/FilaVelocidad/HBoxVelocidad/Btn75,
	$ContenedorOpciones/FilaVelocidad/HBoxVelocidad/Btn100, 
	$ContenedorOpciones/FilaVelocidad/HBoxVelocidad/Btn125]
@onready var btns_timer   = [
	$ContenedorOpciones/FilaTimer/HBoxVelocidad/BtnTimer1,
	$ContenedorOpciones/FilaTimer/HBoxVelocidad/BtnTimer2,
	$ContenedorOpciones/FilaTimer/HBoxVelocidad/BtnTimer3,
	$ContenedorOpciones/FilaTimer/HBoxVelocidad/BtnSinTimer]
@onready var check_inf    = $ContenedorOpciones/FilaInfinito/CheckInfinito

func _ready():
	$BtnJugar.pressed.connect(_on_jugar)
	$BtnVolver.pressed.connect(_on_volver)

	$ContenedorOpciones/FilaDificultad/HBoxDificultad/BtnFacil.pressed.connect(func(): _set_dificultad("facil"))
	$ContenedorOpciones/FilaDificultad/HBoxDificultad/BtnNormal.pressed.connect(func(): _set_dificultad("normal"))
	$ContenedorOpciones/FilaDificultad/HBoxDificultad/BtnDificil.pressed.connect(func(): _set_dificultad("dificil"))

	$ContenedorOpciones/FilaVelocidad/HBoxVelocidad/Btn75.pressed.connect(func(): _set_velocidad(75))
	$ContenedorOpciones/FilaVelocidad/HBoxVelocidad/Btn100.pressed.connect(func(): _set_velocidad(100))
	$ContenedorOpciones/FilaVelocidad/HBoxVelocidad/Btn125.pressed.connect(func(): _set_velocidad(125))

	$ContenedorOpciones/FilaTimer/HBoxVelocidad/BtnTimer1.pressed.connect(func(): _set_timer(1))
	$ContenedorOpciones/FilaTimer/HBoxVelocidad/BtnTimer2.pressed.connect(func(): _set_timer(2))
	$ContenedorOpciones/FilaTimer/HBoxVelocidad/BtnTimer3.pressed.connect(func(): _set_timer(3))
	$ContenedorOpciones/FilaTimer/HBoxVelocidad/BtnSinTimer.pressed.connect(func(): _set_timer(0))

	check_inf.toggled.connect(func(v): modo_infinito = v)

	_actualizar_botones()

func _set_dificultad(d: String):
	dificultad = d
	_actualizar_botones()

func _set_velocidad(v: int):
	velocidad = v
	_actualizar_botones()

func _set_timer(t: int):
	timer_minutos = t
	_actualizar_botones()

func _actualizar_botones():
	var difs   = ["facil", "normal", "dificil"]
	var vels   = [75, 100, 125]
	var timers = [1, 2, 3, 0]

	for i in range(btns_dif.size()):
		btns_dif[i].modulate = Color.WHITE if dificultad == difs[i] \
			else Color(0.5, 0.5, 0.5)
	for i in range(btns_vel.size()):
		btns_vel[i].modulate = Color.WHITE if velocidad == vels[i] \
			else Color(0.5, 0.5, 0.5)
	for i in range(btns_timer.size()):
		btns_timer[i].modulate = Color.WHITE if timer_minutos == timers[i] \
			else Color(0.5, 0.5, 0.5)

func _on_jugar():
	# Guardar config en SesionGlobal antes de cargar el nivel
	SesionGlobal.modo_libre_config = {
		"tipo":          "caida",
		"dificultad":    dificultad,
		"velocidad":     velocidad,
		"modo_infinito": modo_infinito,
		"timer_minutos": timer_minutos,
	}
	get_tree().change_scene_to_file("res://scenes/niveles/NivelBase.tscn")

func _on_volver():
	get_tree().change_scene_to_file("res://scenes/menu/ModoLibre.tscn")
