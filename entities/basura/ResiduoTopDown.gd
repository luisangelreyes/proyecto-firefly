extends Area2D

signal recogido_correcto(tipo: String)
signal recogido_incorrecto(tipo: String)
signal peligroso_tocado()

@export var tipo: String = ""
@export var nombre: String = ""
@export var icono: Texture2D

@onready var sprite     = $Sprite2D
@onready var indicador  = $Indicador   # Label pequeño con [E]
var velocidad_movimiento: float = 0.0
var direccion_actual: Vector2 = Vector2.ZERO

@onready var sensor = $SensorPared
@onready var timer_dir = $TimerDireccion
func _ready():
	indicador.visible = false
	if icono != null:
		sprite.texture = icono
		
	# --- NUEVO: ASIGNAR VELOCIDAD SEGÚN EL TIPO ---
	match tipo:
		"organico":   velocidad_movimiento = 40.0  # Lentos y torpes
		"inorganico": velocidad_movimiento = 60.0  # Velocidad normal
		"peligroso":  velocidad_movimiento = 100.0 # ¡Peligrosos y rápidos!
	
	# Iniciamos el movimiento
	_elegir_nueva_direccion()
	timer_dir.timeout.connect(_elegir_nueva_direccion)
	# ----------------------------------------------
		
	add_to_group("residuo_td")
	body_entered.connect(_on_body_entered)
	
func mostrar_indicador(es_visible: bool):
	# Evitamos mostrar el indicador si es peligroso
	if tipo == "peligroso":
		indicador.visible = false
	else:
		indicador.visible = es_visible
		# Opcional: mostrar el nombre del objeto
		if visible and nombre != "":
			indicador.text = "[E] " + nombre.capitalize()
		else:
			indicador.text = "[E]"

func _on_body_entered(body):
	# Si algo con físicas nos toca y somos peligrosos, explotamos/hacemos daño
	if body.name == "Eli" and tipo == "peligroso":
		peligroso_tocado.emit()
		_flash(Color("#d44a4a"))

func intentar_recoger(bote: int):
	match tipo:
		"peligroso":
			peligroso_tocado.emit()
			_flash(Color("#d44a4a"))
		"organico":
			if bote == 0:
				recogido_correcto.emit(tipo)
				queue_free()
			else:
				recogido_incorrecto.emit(tipo)
				_flash(Color("#ffffff"))
		"inorganico":
			if bote == 1:
				recogido_correcto.emit(tipo)
				queue_free()
			else:
				recogido_incorrecto.emit(tipo)
				_flash(Color("#ffffff"))

func _flash(color: Color):
	sprite.modulate = color
	await get_tree().create_timer(0.15).timeout
	if is_inside_tree():
		match tipo:
			"organico":   sprite.modulate = Color("#4fb87a")
			"inorganico": sprite.modulate = Color("#4a8fd4")
			"peligroso":  sprite.modulate = Color("#d44a4a")
			
func _process(delta):
	# 1. Apuntamos el sensor hacia donde estamos caminando (ej. 50 píxeles hacia adelante)
	# Lo multiplicamos por la escala por si redujiste el tamaño del residuo a 0.1
	sensor.target_position = direccion_actual * (50.0 / scale.x)
	
	# 2. Si el láser detecta una pared de colisión, entra en pánico y cambia de dirección
	if sensor.is_colliding():
		_elegir_nueva_direccion()
	
	# 3. Mover físicamente el residuo
	global_position += direccion_actual * velocidad_movimiento * delta

func _elegir_nueva_direccion():
	# Elegimos un ángulo aleatorio entre 0 y 360 grados (en radianes, TAU equivale a 360°)
	var angulo_aleatorio = randf_range(0, TAU)
	
	# Convertimos ese ángulo en una dirección (Vector2)
	direccion_actual = Vector2(cos(angulo_aleatorio), sin(angulo_aleatorio)).normalized()
	
	# Opcional: Le damos un tiempo aleatorio al Timer para que no todos giren a la vez
	timer_dir.wait_time = randf_range(1.0, 3.0)
