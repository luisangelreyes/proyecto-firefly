extends Node2D

signal oleada_terminada(oleada_actual: int, total_oleadas: int)
signal nivel_completado(atrapados: int, escapados: int, total: int)

@export var lista_canciones: Array[AudioStream] = [
	
]

var escena_basura = preload("res://entities/basura/basura.tscn")

# Cada número es la cantidad de residuos de esa oleada
# Sobreescribe esta variable en niveles hijos para cambiar la dificultad
var oleadas: Array = [2, 6,8,8]
var oleada_actual: int = 0
var residuos_en_oleada: int = 0      # cuántos spawneó esta oleada
var residuos_pendientes: int = 0     # cuántos siguen vivos en pantalla

# ── MÉTRICAS DE NIVEL ─────────────────────────────────────────────────────
var total_residuos: int = 0
var residuos_atrapados: int = 0
var residuos_escapados: int = 0

# ── ESTADO ───────────────────────────────────────────────────────────────
var nivel_activo: bool = false
var tiempo_entre_residuos: float = 1.0

func _ready():
	$MusicaFondo.pitch_scale = 1.0
	if lista_canciones.size() > 0:
		var indice = randi() % lista_canciones.size()
		$MusicaFondo.stream = lista_canciones[indice]
		$MusicaFondo.play()

	$Barbara.juego_terminado.connect(_on_juego_terminado)
	$Barbara.interfaz_actualizada.connect(_on_interfaz_actualizada)
	$Barbara.tension_musical.connect(_on_tension_musical)
	nivel_completado.connect($PantallaResultados.mostrar_resultados)
	$Barbara.residuo_clasificado.connect(_on_residuo_clasificado)  

	
	

	# Calculamos el total real sumando todas las oleadas
	total_residuos = 0
	for cantidad in oleadas:
		total_residuos += cantidad
	
	_iniciar_oleada()
func _on_residuo_clasificado(acierto: bool):
	if acierto:
		residuos_atrapados += 1
	else:
		residuos_escapados += 1
# ── LÓGICA DE OLEADAS ─────────────────────────────────────────────────────
func _iniciar_oleada():
	if oleada_actual >= oleadas.size():
		return  
	nivel_activo = true
	residuos_en_oleada = 0
	residuos_pendientes = oleadas[oleada_actual]
	$Timer.wait_time = tiempo_entre_residuos
	$Timer.start()

func _on_timer_timeout():
	var cantidad_esta_oleada = oleadas[oleada_actual]

	if residuos_en_oleada < cantidad_esta_oleada:
		lanzar_basura_normal()
		residuos_en_oleada += 1

		if residuos_en_oleada >= cantidad_esta_oleada:
			$Timer.stop()

var probabilidad_peligroso: float = 0.10

func lanzar_basura_normal():
	if not has_node("Barbara"):
		return

	var posicion_eli = $Barbara.position.x
	var nuevo_x = posicion_eli + randf_range(-400, 400)
	nuevo_x = clamp(nuevo_x, 50, 1390)

	var basura = escena_basura.instantiate()
	basura.position = Vector2(nuevo_x, -50)
	basura.prob_peligroso = probabilidad_peligroso  # ← asignamos antes de add_child
	basura.tree_exited.connect(_on_residuo_salio)
	basura.residuo_escapado.connect(_on_residuo_escapado)
	add_child(basura)
# ── NUEVA: residuo que cayó al suelo sin ser tocado ──
func _on_residuo_escapado():
	residuos_escapados += 1
	
func _on_residuo_salio():
	# Este callback se dispara cuando un residuo hace queue_free()
	# ya sea porque fue atrapado o porque cayó al suelo
	residuos_pendientes -= 1
	_verificar_oleada_completa()

func registrar_atrape(acierto: bool):
	# Barbara llama esta función cuando atrapa un residuo
	# La conectaremos con una señal nueva de Barbara en el siguiente paso
	if acierto:
		residuos_atrapados += 1
	else:
		residuos_escapados += 1

func _verificar_oleada_completa():
	if residuos_pendientes > 0:
		return

	oleada_actual += 1
	oleada_terminada.emit(oleada_actual, oleadas.size())

	if oleada_actual >= oleadas.size():
		_mostrar_pantalla_crash()
	else:
		# Verificamos que el nodo sigue en el árbol antes del await
		if not is_inside_tree():
			return
			
		await get_tree().create_timer(2.0).timeout
		
		# Verificamos de nuevo después del await porque el juego
		# pudo haber terminado durante esos 2 segundos
		if not is_inside_tree():
			return
		if not nivel_activo:
			return
			
		_iniciar_oleada()

func _mostrar_pantalla_crash():
	if SesionGlobal.vidas <= 0:
		return
	nivel_activo = false
	$Timer.stop()
	$MusicaFondo.stop()
	SesionGlobal.completar_nivel(1, 2)  # mundo 1, nivel 2
	nivel_completado.emit(residuos_atrapados, residuos_escapados, total_residuos)
	SesionGlobal.guardar_sesion()
	nivel_completado.emit(residuos_atrapados, residuos_escapados, total_residuos)
	var nodo_liz = get_node_or_null("Barbara") 
	if nodo_liz != null:
		nodo_liz.celebrar_victoria()

# ── SEÑALES DE BARBARA ────────────────────────────────────────────────────
func _on_interfaz_actualizada(puntos: int, vidas: int):
	$TextoPuntos.text = "Puntos: " + str(puntos)
	$TextoVidas.text = "Vidas: " + str(vidas)

func _on_tension_musical(activa: bool):
	if activa:
		$MusicaFondo.pitch_scale = 1.15
	else:
		$MusicaFondo.pitch_scale = 1.0

func _on_juego_terminado():
	nivel_activo = false
	
	$MusicaFondo.stop()
	$SonidoGameOver.play()
	$TextoGameOver.visible = true
	$Timer.stop()
	SesionGlobal.guardar_sesion()
	$Barbara.queue_free()
	# Cuando detectes que el jugador ganó el nivel:
	

func _process(_delta):
	if $TextoGameOver.visible:
		if Input.is_action_just_pressed("reiniciar"):
			SesionGlobal.vidas = 3
			SesionGlobal.puntaje = 0
			get_tree().reload_current_scene()
	
	if $PantallaResultados.visible:
		if Input.is_action_just_pressed("reiniciar"):
			$PantallaResultados._on_boton_siguiente_pressed()
