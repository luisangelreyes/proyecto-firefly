extends Node2D

var lista_canciones = [
	preload("res://assets/audio/music/musica_1.ogg"), # Asegúrate de que estos nombres coincidan con los tuyos
	preload("res://assets/audio/music/musica_2.ogg"),
	preload("res://assets/audio/music/musica_3.ogg"),
	preload("res://assets/audio/music/musica_4.ogg"),
	preload("res://assets/audio/music/musica_5.ogg"),
	preload("res://assets/audio/music/musica_6.ogg"),
	preload("res://assets/audio/music/musica_C.ogg")
]

var escena_basura = preload("res://entities/basura/basura.tscn")
var tiempo_normal = 0.5
func _ready():
	$MusicaFondo.pitch_scale = 1.0
	if lista_canciones.size() > 0:
		var indice_aleatorio = randi() % lista_canciones.size()
		$MusicaFondo.stream = lista_canciones[indice_aleatorio]
		$MusicaFondo.play()

func _on_timer_timeout():
	$Timer.wait_time = tiempo_normal
	var probabilidad = randi() % 100
	
	# Cambié a < 25 para que los patrones salgan con más frecuencia, 
	# pero puedes dejarlo en 5 si quieres que sean muy raros.
	if probabilidad < 25:
		lanzar_patron_aleatorio()
	else:
		lanzar_basura_normal()

func lanzar_basura_normal():
	if not has_node("Barbara"): 
		return
		
	var posicion_eli = $Barbara.position.x
	var nuevo_x = posicion_eli + randf_range(-400, 400) # Rango un poco más amplio
	nuevo_x = clamp(nuevo_x, 50, 1390)
	
	var basura = escena_basura.instantiate()
	basura.position = Vector2(nuevo_x, -50)
	add_child(basura)
	
	# --- NUEVO: ASIGNAR TIPO Y TEXTURA ---
	basura.tipo_basura = randi() % 2 # Elige 0 o 1 al azar
	basura.configurar_textura()      # Llama a la función que hicimos en basura.gd

func lanzar_patron_aleatorio():
	patron_diagonal()
	$Timer.wait_time = tiempo_normal + 1.5
	$Timer.start()

func patron_diagonal():
	var cantidad = 5
	var tipo_elegido = randi() % 2 

	# La pantalla ahora mide 1440, podemos empezar la escalera más a la derecha
	var x_inicial = randf_range(100, 400) 

	for i in range(cantidad):
		var basura = escena_basura.instantiate()

		# Separamos un poco más los residuos para que cubran más pantalla
		var pos_x = x_inicial + (i * 200) 
		var pos_y = -50 - (i * 220) 

		basura.position = Vector2(pos_x, pos_y)
		add_child(basura)

		basura.tipo_basura = tipo_elegido
		basura.configurar_textura()
		
func _process(delta):
	if $TextoGameOver.visible == true:
		if Input.is_action_just_pressed("reiniciar"):
			get_tree().reload_current_scene()
