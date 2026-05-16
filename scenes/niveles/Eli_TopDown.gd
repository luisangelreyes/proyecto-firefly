extends CharacterBody2D

signal recogida_intentada(tipo: String, bote: int)

# --- VARIABLES DE MOVIMIENTO NORMAL ---
const VELOCIDAD_MAX = 350.0  
const ACELERACION = 2500.0   
const FRICCION = 3000.0      

# --- NUEVAS VARIABLES PARA EL DASH ---
const VELOCIDAD_DASH = 1200.0 # Una ráfaga de velocidad altísima
const DURACION_DASH = 0.15    # Dura menos de un segundo
const COOLDOWN_DASH = 0.6     # Tiempo de espera para volver a usarlo
var ultima_direccion: String = "abajo"

var esta_dasheando: bool = false
var puede_dashear: bool = true
var direccion_dash: Vector2 = Vector2.ZERO

var bote_activo: int = 0   
var residuo_enfocado = null 

func _physics_process(delta):
	var dir = Vector2.ZERO

	# Solo leemos el input de movimiento si NO estamos en medio de un dash
	if not esta_dasheando:
		if Input.is_action_pressed("mover_izquierda"):  dir.x -= 1
		if Input.is_action_pressed("mover_derecha"):    dir.x += 1
		if Input.is_action_pressed("mover_arriba"):     dir.y -= 1
		if Input.is_action_pressed("mover_abajo"):      dir.y += 1

		if dir.length() > 0:
			dir = dir.normalized()
			
	# --- DETECCIÓN DEL BOTÓN DASH ---
	# Requiere presionar el botón, tener el cooldown listo y estar moviéndose hacia algún lado
	if Input.is_action_just_pressed("dash") and puede_dashear and dir != Vector2.ZERO:
		_iniciar_dash(dir)

	# --- APLICAR EL MOVIMIENTO ---
	if esta_dasheando:
		velocity = direccion_dash * VELOCIDAD_DASH
	else:
		if dir.length() > 0:
			# Movimiento y física
			velocity = velocity.move_toward(dir * VELOCIDAD_MAX, ACELERACION * delta)
			
			# Lógica de Animaciones
			# Usamos abs() para saber qué eje predomina si camina en diagonal
			if abs(dir.x) > abs(dir.y):
				# Se mueve más en horizontal
				$AnimatedSprite2D.play("caminar_lado")
				$AnimatedSprite2D.flip_h = dir.x > 0 # Voltea el sprite si va a la izquierda
				ultima_direccion = "lado"
			elif dir.y > 0:
				# Se mueve hacia abajo (Sur)
				$AnimatedSprite2D.play("caminar_abajo")
				$AnimatedSprite2D.flip_h = false
				ultima_direccion = "abajo"
			elif dir.y < 0:
				# Se mueve hacia arriba (Norte)
				$AnimatedSprite2D.play("caminar_arriba")
				$AnimatedSprite2D.flip_h = false
				ultima_direccion = "arriba"
		else:
			# Se detuvo, aplicamos fricción
			velocity = velocity.move_toward(Vector2.ZERO, FRICCION * delta)
			
			# Reproducir el idle correcto según la última dirección
			match ultima_direccion:
				"lado":   $AnimatedSprite2D.play("idle_lado")
				"abajo":  $AnimatedSprite2D.play("idle_abajo")
				"arriba": $AnimatedSprite2D.play("idle_arriba")

	move_and_slide()
	
	_actualizar_indicador()

	if Input.is_action_just_pressed("cambiar_tacho"):
		bote_activo = (bote_activo + 1) % 2

	if Input.is_action_just_pressed("recoger_objeto"):
		_intentar_recoger()

# --- NUEVA FUNCIÓN QUE CONTROLA EL TIEMPO DEL DASH ---
func _iniciar_dash(dir: Vector2):
	esta_dasheando = true
	puede_dashear = false
	direccion_dash = dir # Guardamos la dirección para no poder girar en pleno dash
	
	# Temporizador 1: Cuánto dura el impulso
	await get_tree().create_timer(DURACION_DASH).timeout
	esta_dasheando = false
	
	# Temporizador 2: Cuánto tarda en recargarse la habilidad
	await get_tree().create_timer(COOLDOWN_DASH).timeout
	puede_dashear = true

func _actualizar_indicador():
	var residuos = $AreaDeteccion.get_overlapping_areas()
	var mas_cercano = null
	var menor_dist  = INF
	
	for r in residuos:
		if not r.is_in_group("residuo_td"):
			continue
		var d = global_position.distance_to(r.global_position)
		if d < menor_dist:
			menor_dist = d
			mas_cercano = r
			
	# Si cambiamos de residuo enfocado, apagamos el anterior y encendemos el nuevo
	if residuo_enfocado != mas_cercano:
		if residuo_enfocado != null and is_instance_valid(residuo_enfocado):
			residuo_enfocado.mostrar_indicador(false)
			
		residuo_enfocado = mas_cercano
		
		if residuo_enfocado != null:
			residuo_enfocado.mostrar_indicador(true)

func _intentar_recoger():
	# Ahora solo interactuamos con el que ya tenemos enfocado
	if residuo_enfocado and is_instance_valid(residuo_enfocado):
		recogida_intentada.emit(residuo_enfocado.tipo, bote_activo)
		residuo_enfocado.intentar_recoger(bote_activo)
