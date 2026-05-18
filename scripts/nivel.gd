extends Node2D

signal oleada_terminada(oleada_actual: int, total_oleadas: int)
signal nivel_completado(atrapados: int, escapados: int, total: int, desglose: Dictionary, peligrosos: int)

# Agrega estas variables junto a las métricas existentes
var desglose_atrapados: Dictionary = {
	"Organico":   0,
	"Inorganico": 0,
}
var peligrosos_esquivados: int = 0
@export var lista_canciones: Array[AudioStream] = [	
]
# ── CONFIGURACIÓN DE DIFICULTAD POR OLEADA ───────────────────────────────
# Cada entrada corresponde a una oleada: [velocidad_caida, intervalo_spawn, prob_peligroso]
var DIFICULTAD_OLEADAS = [
		[200.0, 1, 0.02],   # Oleada 1 — primer contacto con peligrosos
		[240.0, 1, 0.08],   # Oleada 2 — más frecuentes
		[275.0, 1, 0.02],   # Oleada 3 — presión real
		[310.0, 1, 0.06],   # Oleada 4 — desafío del mundo 1
]
var escena_basura = preload("res://entities/basura/basura.tscn")

# Cada número es la cantidad de residuos de esa oleada
# Sobreescribe esta variable en niveles hijos para cambiar la dificultad
var oleadas: Array = [2,30,8]
var oleada_actual: int = 0
var residuos_en_oleada: int = 0      # cuántos spawneó esta oleada
var residuos_pendientes: int = 0     # cuántos siguen vivos en pantalla

# ── MÉTRICAS DE NIVEL ─────────────────────────────────────────────────────
var total_residuos: int = 0
var residuos_atrapados: int = 0
var residuos_escapados: int = 0

# ── ESTADO ───────────────────────────────────────────────────────────────
var nivel_activo: bool = false
var tiempo_entre_residuos: float = 2.0

func _ready():
	SesionGlobal.vidas = 3    # ← agregar esta línea
	SesionGlobal.puntaje = 0  # ← opcional: también resetear puntos por nivel
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
	

	
	

	
	_iniciar_oleada()
	$Barbara.combo_actualizado.connect(_on_combo_actualizado)
	oleada_terminada.connect(_on_oleada_terminada)


func _on_combo_actualizado(racha: int, multiplicador: int):
	# HitCounter
	if racha > 0:
		$HitCounter.registrar_acierto(racha)
	else:
		$HitCounter.registrar_fallo()

	# Label de multiplicador — solo si hay x2 o más
	if multiplicador > 1:
		$TextoCombo.text = "x%d" % multiplicador
		$TextoCombo.visible = true
		match multiplicador:
			2: $TextoCombo.add_theme_color_override("font_color", Color("#fbbf24"))
			3: $TextoCombo.add_theme_color_override("font_color", Color("#f97316"))
			4: $TextoCombo.add_theme_color_override("font_color", Color("#ef4444"))
	else:
		$TextoCombo.visible = false
		
func _on_residuo_clasificado(acierto: bool, tipo: String):
	if tipo == "Peligroso":
		return  # los peligrosos no cuentan como clasificables
	if acierto:
		residuos_atrapados += 1
		desglose_atrapados[tipo] = desglose_atrapados.get(tipo, 0) + 1
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
	if oleadas.is_empty():
		return
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
	if posicion_eli <= 0 or posicion_eli >= 1440:
		posicion_eli = 720

	var nuevo_x = posicion_eli + randf_range(-400, 400)
	nuevo_x = clamp(nuevo_x, 50, 1390)

	var basura = escena_basura.instantiate()
	basura.position = Vector2(nuevo_x, -50)
	basura.prob_peligroso = probabilidad_peligroso

	var config = DIFICULTAD_OLEADAS[min(oleada_actual, DIFICULTAD_OLEADAS.size()-1)]
	basura.velocidad_caida = config[0]

	basura.tree_exited.connect(_on_residuo_salio)
	basura.residuo_escapado.connect(_on_residuo_escapado)
	add_child(basura)

	# Contar solo no-peligrosos en el total
	if basura.categoria != "Peligroso":
		total_residuos += 1
# ── NUEVA: residuo que cayó al suelo sin ser tocado ──
func _on_residuo_escapado(categoria: String):
	if categoria == "Peligroso":
		peligrosos_esquivados += 1
		return  # esquivar peligrosos no es un error
	residuos_escapados += 1
	
func _on_residuo_salio():
	if oleadas.is_empty():
		return
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
	if oleadas.is_empty():
		return
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
	nivel_completado.emit(        residuos_atrapados,
		residuos_escapados,
		total_residuos,
		desglose_atrapados,
		peligrosos_esquivados)
	SesionGlobal.guardar_sesion()
	nivel_completado.emit(        residuos_atrapados,
		residuos_escapados,
		total_residuos,
		desglose_atrapados,
		peligrosos_esquivados)
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
	$GameOver.visible = true
	$GameOver/TextoGameOver.visible = true
	
	$Timer.stop()
	SesionGlobal.guardar_sesion()
	$Barbara.queue_free()
	# Cuando detectes que el jugador ganó el nivel:
	

func _process(_delta):
	if $GameOver/TextoGameOver.visible:
		print("es visible")
		if Input.is_action_just_pressed("reiniciar"):
			SesionGlobal.vidas = 3
			SesionGlobal.puntaje = 0
			get_tree().reload_current_scene()
		return
	
	if $PantallaResultados.visible:
		if Input.is_action_just_pressed("confirmar"):
			$PantallaResultados._on_boton_siguiente_pressed()
		return
	
func _on_oleada_terminada(oleada: int, _total: int):
	if oleada >= DIFICULTAD_OLEADAS.size():
		return
	
	if not is_inside_tree():
		return
		
	var config = DIFICULTAD_OLEADAS[oleada]
	tiempo_entre_residuos  = config[1]
	probabilidad_peligroso = config[2]

	for basura in get_tree().get_nodes_in_group("basura_caida"):
		basura.velocidad_caida = config[0]

	_mostrar_aviso_oleada(oleada + 1)
func _mostrar_aviso_oleada(numero: int):
	if not has_node("TextoOleada"):
		return
	$TextoOleada.text = "Oleada %d" % numero
	$TextoOleada.visible = true
	$TextoOleada.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_interval(1.2)
	tween.tween_property($TextoOleada, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): $TextoOleada.visible = false)
