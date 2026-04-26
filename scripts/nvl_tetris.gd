extends Node2D

var escena_basura = preload("res://entities/basura/basura.tscn")
var tiempo_normal = 0.5

var basura_actual = null
var velocidad_caida = 200
var velocidad_movimiento = 800
var basura_fijada = false
var tween_actual = null  # Guardar referencia al tween

func _ready():
	generar_nueva_basura()

func _process(delta):
	if basura_actual and is_instance_valid(basura_actual):
		# Caída automática
		basura_actual.position.y += velocidad_caida * delta
		
		#mover hacia abajo
		if Input.is_action_pressed("mover_abajo"):
			basura_actual.position.y += velocidad_movimiento * delta
		
		# Movimiento lateral
		if Input.is_action_pressed("mover_izquierda"):
			basura_actual.position.x -= velocidad_movimiento * delta
		if Input.is_action_pressed("mover_derecha"):
			basura_actual.position.x += velocidad_movimiento * delta
		
		# Limitar dentro de la pantalla
		basura_actual.position.x = clamp(basura_actual.position.x, 50, 1390)
		
		# Verificar colisión SOLO con contenedores (T_)
		if not basura_fijada:  # Solo verifica si no está ya fijada
			verificar_colision_contenedores()
		
		# Seguridad por si se sale de pantalla
		if basura_actual.position.y > 1000:
			fijar_basura()
			generar_nueva_basura()

func verificar_colision_contenedores():
	for child in get_children():
		if child is Area2D and child.name.begins_with("T_"):
			if basura_actual and basura_actual.overlaps_area(child):
				if not basura_fijada:
					fijar_basura()
					generar_nueva_basura()
					break

func _on_timer_timeout():
	$Timer.wait_time = tiempo_normal

func generar_nueva_basura():
	var nuevo_x = randf_range(200, 1200)
	
	basura_actual = escena_basura.instantiate()
	basura_actual.position = Vector2(nuevo_x, -50)
	basura_fijada = false
	
	basura_actual.tipo_basura = randi() % 2
	basura_actual.configurar_textura()
	
	add_child(basura_actual)

func fijar_basura():
	if basura_fijada:
		return  # Evitar doble ejecución
	
	basura_fijada = true
	var basura_a_eliminar = basura_actual  # Guardar referencia
	basura_actual = null  # Liberar inmediatamente
	
	# Pequeña animación de caída dentro del contenedor
	var tween = create_tween()
	tween.tween_property(basura_a_eliminar, "position:y", basura_a_eliminar.position.y + 30, 0.2)
	tween.parallel().tween_property(basura_a_eliminar, "modulate:a", 0, 0.3)
	tween.tween_callback(basura_a_eliminar.queue_free)  # Eliminar al final

func lanzar_basura_normal():
	var nuevo_x = randf_range(50, 1390)
	var basura = escena_basura.instantiate()
	basura.position = Vector2(nuevo_x, -50)
	add_child(basura)
	basura.tipo_basura = randi() % 2
	basura.configurar_textura()
