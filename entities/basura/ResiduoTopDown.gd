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
		SesionGlobal.Categorias.ORGANICO:   velocidad_movimiento = 40.0  # Lentos y torpes
		SesionGlobal.Categorias.INORGANICO: velocidad_movimiento = 60.0  # Velocidad normal
		SesionGlobal.Categorias.PELIGROSO:  velocidad_movimiento = 100.0 # ¡Peligrosos y rápidos!
	
	# Iniciamos el movimiento
	_elegir_nueva_direccion()
	timer_dir.timeout.connect(_elegir_nueva_direccion)
	# ----------------------------------------------
		
	add_to_group(SesionGlobal.Grupos.RESIDUO_TD)
	body_entered.connect(_on_body_entered)
	
func mostrar_indicador(es_visible: bool):
	# Evitamos mostrar el indicador si es peligroso
	if tipo == SesionGlobal.Categorias.PELIGROSO:
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
	if body.name == "Eli" and tipo == SesionGlobal.Categorias.PELIGROSO:
		peligroso_tocado.emit()
		_flash(Color("#d44a4a"))

func intentar_recoger(bote: int):
	match tipo:
		SesionGlobal.Categorias.PELIGROSO:
			peligroso_tocado.emit()
			_flash(Color("#d44a4a"))
		SesionGlobal.Categorias.ORGANICO:
			if bote == 0:
				recogido_correcto.emit(tipo)
				queue_free()
			else:
				recogido_incorrecto.emit(tipo)
				_flash(Color("#ffffff"))
		SesionGlobal.Categorias.INORGANICO:
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
			SesionGlobal.Categorias.ORGANICO:   sprite.modulate = Color("#4fb87a")
			SesionGlobal.Categorias.INORGANICO: sprite.modulate = Color("#4a8fd4")
			SesionGlobal.Categorias.PELIGROSO:  sprite.modulate = Color("#d44a4a")
			
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


func ser_succionado(destino: Vector2):
	# 1. Apagamos su "IA" y su colisión para que no lastimen a Liz mientras vuelan
	velocidad_movimiento = 0
	$SensorPared.enabled = false
	if has_node("TimerDireccion"):
		$TimerDireccion.stop()
		
	# Desactivamos la colisión de forma segura
	$CollisionShape2D.set_deferred("disabled", true)
	
	# 2. Creamos un Tween para la animación fluida
	var tween = create_tween()
	tween.set_parallel(true) # Hace que todas las animaciones ocurran al mismo tiempo
	
	# Movemos el residuo hacia el centro en 1.5 segundos
	tween.tween_property(self, "global_position", destino, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Lo encogemos hasta que desaparezca (escala 0,0)
	tween.tween_property(self, "scale", Vector2.ZERO, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Lo hacemos girar a lo loco como un remolino
	tween.tween_property(self, "rotation", 15.0, 1.5)
	
	# 3. Cuando termina la animación paralela, eliminamos el residuo
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
