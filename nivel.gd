extends Node2D

var lista_canciones = [
	preload("res://musica_1.ogg"), # Asegúrate de que estos nombres coincidan con los tuyos
	preload("res://musica_2.ogg"),
	preload("res://musica_3.ogg"),
	preload("res://musica_4.ogg"),
	preload("res://musica_5.ogg"),
	preload("res://musica_6.ogg"),
	preload("res://musica_C.ogg")
]

var escena_basura = preload("res://basura.tscn")
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
	var nuevo_x = posicion_eli + randf_range(-300, 300) 
	nuevo_x = clamp(nuevo_x, 50, 910) 
	
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
	var x_inicial = randf_range(50, 150) 
	
	for i in range(cantidad):
		var basura = escena_basura.instantiate()
		var pos_x = x_inicial + (i * 150)
		var pos_y = -50 - (i * 180) 
		
		basura.position = Vector2(pos_x, pos_y)
		add_child(basura)
		
		# --- ACTUALIZADO: YA NO USAMOS MODULATE (COLORES) ---
		basura.tipo_basura = tipo_elegido
		basura.configurar_textura() # Cada pieza de la escalera se disfraza solita

func _process(delta):
	if $TextoGameOver.visible == true:
		if Input.is_action_just_pressed("reiniciar"):
			get_tree().reload_current_scene()
