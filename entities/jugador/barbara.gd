extends Area2D
#--
# --- SEÑALES ---
signal resultado_tutorial(acierto: bool)
signal juego_terminado()
signal interfaz_actualizada(puntos: int, vidas: int)
signal tension_musical(activa: bool)
signal residuo_clasificado(acierto: bool)
@onready var audio_acierto = $AudioAcierto
@onready var audio_error = $AudioError
@onready var audio_derrota = $AudioDerrota # <--- EL NUEVO NODO
# --- NODOS ---
# Ahora usamos exclusivamente tu nuevo AnimatedSprite2D
@onready var anim_sprite = $AnimatedSprite2D
@onready var sprite_sombra = $Sombra

# --- CONFIGURACIÓN DE MOVIMIENTO ---
var velocidad_caminar = 500 
var velocidad_correr = 1200 

# --- VARIABLES DE JUEGO ---
var bote_activo = 0 # 0 = Orgánico, 1 = Inorgánico
var esta_aturdida: bool = false # Para bloquear a Liz cuando falla
var nivel_terminado: bool = false # Para bloquear a Liz cuando gana

func _ready():
	# Inicializamos a Liz con el bote verde (0 = Orgánico)
	bote_activo = 0
	anim_sprite.play("caminata_organico")
	anim_sprite.stop()
	
func _process(delta):
	if nivel_terminado:
		return
	# 1. Detectar el botón para cambiar el bote (¡ahora puede hacerlo mientras falla!)
	if Input.is_action_just_pressed("cambiar_tacho"): 
		if bote_activo == 0:
			bote_activo = 1
		else:
			bote_activo = 0

	# 2. Elegir la palabra correcta para la animación base
	var animacion_actual = ""
	if bote_activo == 0:
		animacion_actual = "caminata_organico"
	else:
		animacion_actual = "caminata_inorganico"

	# 3. Determinar velocidad
	var velocidad_actual = velocidad_caminar
	if Input.is_action_pressed("correr"):
		velocidad_actual = velocidad_correr
		
	# 4. Manejar Movimiento
	var movimiento = 0
	
	if Input.is_action_pressed("mover_derecha"):
		movimiento += 1
		anim_sprite.flip_h = false # Mira a la derecha
		sprite_sombra.flip_h = false
	if Input.is_action_pressed("mover_izquierda"):
		movimiento -= 1
		anim_sprite.flip_h = true  # Mira a la izquierda
		sprite_sombra.flip_h = true

	# 5. Aplicar Movimiento y reproducir Sprite
	if movimiento != 0:
		position.x += movimiento * velocidad_actual * delta
		
		# MAGIA: Solo cambiamos a la animación de caminar si NO está reproduciendo la de fallar
		if not esta_aturdida:
			anim_sprite.play(animacion_actual) 
	else:
		# Forzamos el reposo solo si NO está fallando
		if not esta_aturdida:
			anim_sprite.play(animacion_actual)
			anim_sprite.stop()
			anim_sprite.frame = 0 
			
	# Sincronizar la sombra con el frame actual de Liz
#	sprite_sombra.frame = anim_sprite.frame	
	
	# 6. Límite de pantalla
	var ancho_pantalla = get_viewport_rect().size.x
	position.x = clamp(position.x, 40, ancho_pantalla - 40)
		
# --- GESTIÓN DE COLISIONES ---
func _on_area_entered(area):
	if nivel_terminado:
		return
	if area.is_in_group("basura_caida"):
		area.fue_atrapado = true
		var tipo_que_cayo = area.categoria
		
	if area.is_in_group("basura_caida"):
		area.fue_atrapado = true
		var tipo_que_cayo = area.categoria
		
		if tipo_que_cayo == "Peligroso":
			SesionGlobal.vidas -= 1
			Input.start_joy_vibration(0, 0.8, 0.0, 0.4)
			resultado_tutorial.emit(false)
			residuo_clasificado.emit(false)
			recibir_dano() # <--- Activamos la animación de falla
		else:
			var acierto = false
			if (bote_activo == 0 and tipo_que_cayo == "Organico") or (bote_activo == 1 and tipo_que_cayo == "Inorganico"):
				acierto = true
				
			if acierto:
				SesionGlobal.puntaje += 10
				Input.start_joy_vibration(0, 0.2, 0.0, 0.1)
				audio_acierto.play()
				resultado_tutorial.emit(true)
				residuo_clasificado.emit(true)
			else:
				SesionGlobal.vidas -= 1
				Input.start_joy_vibration(0, 0.0, 0.5, 0.3)
				audio_error.play()
				resultado_tutorial.emit(false)
				residuo_clasificado.emit(false)
				recibir_dano() # <--- Activamos la animación de falla

		area.queue_free()
		actualizar_interfaz()

func actualizar_interfaz():
	interfaz_actualizada.emit(SesionGlobal.puntaje, SesionGlobal.vidas)
	tension_musical.emit(SesionGlobal.vidas == 1)
	
	# Si se acaban las vidas, llamamos a la caída en lugar de terminar el juego de golpe
	if SesionGlobal.vidas <= 0:
		ejecutar_derrota()

# --- NUEVA FUNCIÓN: ANIMACIÓN DE FALLA ---
func recibir_dano():
	# PROTECCIÓN: Si ya está aturdida, ignoramos el golpe para no congelar el juego
	if esta_aturdida:
		return
		
	esta_aturdida = true
	
	# Reproduce la animación de daño
	if bote_activo == 0:
		anim_sprite.play("falla_organico")
	else:
		anim_sprite.play("falla_inorganico")
		
	# Esperar a que termine la animación (los 4 frames)
	await anim_sprite.animation_finished
	
	# Regresarla a la normalidad
	esta_aturdida = false
	if bote_activo == 0:
		anim_sprite.play("caminata_organico")
	else:
		anim_sprite.play("caminata_inorganico")
	anim_sprite.stop()
# --- NUEVA FUNCIÓN: VICTORIA ---
func celebrar_victoria():
	nivel_terminado = true
	
	
	# Reproduce la animación de baile. 
	# (Si hiciste dos animaciones distintas para cada bote, usa un if/else como en recibir_dano)
	anim_sprite.play("victoria")
# --- NUEVA FUNCIÓN: DERROTA (GAME OVER) ---
func ejecutar_derrota():
	# 1. Bloqueamos los controles
	nivel_terminado = true
	esta_aturdida = true 
	
	# 2. Reproducimos EL SONIDO y la caída al mismo tiempo
	audio_derrota.play() # <--- SONIDO REPRODUCIÉNDOSE
	anim_sprite.play("derrota")
	
	# 3. Esperamos a que Liz termine de caer al suelo
	await anim_sprite.animation_finished
	
	# 4. AHORA SÍ avisamos al nivel que saque la pantalla de Game Over
	juego_terminado.emit()
