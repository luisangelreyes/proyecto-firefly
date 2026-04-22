extends Area2D

# ── VELOCIDADES EN PÍXELES/SEGUNDO ──
# Tal como lo tenías en tu prototipo web (VELOCIDAD_JUGADOR)
var velocidad_caminar = 500 
var velocidad_correr = 1200 

# --- NUEVAS VAooooRIABLES DE JUEGO ---
var puntos = 0
var vidas = 3
var bote_activo = 0 # 0 = Orgánico (Verde), 1 = Inorgánico (Azul)

# Límite de la pantalla para que no se salga (480px de ancho)
var limite_pantalla_x = 960

func _ready():
	# Esta función se ejecuta una sola vez al nacer la escena.
	# Le daremos un color inicial al robot para saber qué bote trae.
	actualizar_color_bote()

func _process(delta):
	# 1. Definimos a qué velocidad nos vamos a mover este frame
	var velocidad_actual = velocidad_caminar
	
	if Input.is_action_pressed("correr"):
		velocidad_actual = velocidad_correr
		
	# 2. El movimiento horizontal de siempre, pero usando la velocidad_actual
	if Input.is_action_pressed("mover_derecha"):
		position.x += velocidad_actual * delta
	if Input.is_action_pressed("mover_izquierda"):
		position.x -= velocidad_actual * delta
		
	# Mantenemos a Eli dentro de la pantalla
	position.x = clamp(position.x, 40, limite_pantalla_x - 40)

	# 2. CAMBIAR BOTE
	# Usamos "just_pressed" para que solo cuente una vez al presionar, 
	# no 60 veces por segundo si dejamos presionada la barra espaciadora.
	if Input.is_action_just_pressed("cambiar_tacho"):
		if bote_activo == 0:
			bote_activo = 1
		else:
			bote_activo = 0
		
		actualizar_color_bote()

# Función visual de apoyo (mientras no tengamos los sprites definitivos)
func actualizar_color_bote():
	# $Sprite2D busca al hijo llamado Sprite2D y 'modulate' cambia su tinte de color.
	if bote_activo == 0:
		$Sprite2D.modulate = Color(0.2, 1.0, 0.2) # Verde fluorescente
	else:
		$Sprite2D.modulate = Color(0.2, 0.4, 1.0) # Azul vibrante
func _on_area_entered(area):
	if area.is_in_group("basura_caida"):
		var tipo_que_cayo = area.tipo_basura
		
		if tipo_que_cayo == 2: # Residuos Peligrosos
			vidas -= 1
			# Vibración fuerte y corta (Susto)
			Input.start_joy_vibration(0, 0.8, 0.0, 0.4) 
		elif bote_activo == tipo_que_cayo: # Acierto
			puntos += 10
			# Vibración muy suave (Feedback positivo)
			Input.start_joy_vibration(0, 0.2, 0.0, 0.1)
		else: # Error de bote
			vidas -= 1
			# Vibración constante (Error)
			Input.start_joy_vibration(0, 0.0, 0.5, 0.3)
			
		area.queue_free()
		actualizar_interfaz()




func actualizar_interfaz():
	# Actualizamos los textos 
	$"../TextoPuntos".text = "Puntos: " + str(puntos)
	$"../TextoVidas".text = "Vidas: " + str(vidas)
	
	# La lógica de tensión de la música que hicimos
	var musica = $"../MusicaFondo"
	if vidas == 1:
		musica.pitch_scale = 1.15 
	else:
		musica.pitch_scale = 1.0  
	
	# --- NUEVO: REPRODUCIR SONIDO AL MORIR ---
	if vidas <= 0:
		musica.stop() # Detenemos la música alegre
		
		# Le decimos al nivel que toque el sonido de derrota
		$"../SonidoGameOver".play() 
		
		$"../TextoGameOver".visible = true
		$"../Timer".stop()
		queue_free() # Eli desaparece, pero el sonido sigue sonando en el nivel
