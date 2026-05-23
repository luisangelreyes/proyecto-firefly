extends "res://scripts/nivel.gd"

enum EstadoBoss {
	INTRO,
	FASE_ATAQUE,
	VULNERABILIDAD,
	TRANSICION,
	VICTORIA
}
var estado_boss: EstadoBoss = EstadoBoss.INTRO

const ACIERTOS_PARA_CARGAR = 10
var cargador_actual: int = 0

const VENTANA_FASE_1_2 = 4.0   # segundos
const VENTANA_FASE_3   = 2.5
var _timer_vulnerabilidad: SceneTreeTimer = null
var _ventana_abierta: bool = false

@onready var alien = $Alien

var label_cargador: Label

# ──────────────────────────────────────────────────────────────────────────────
func _ready():
	oleadas = []
	nivel_activo = false

	# Conectar señales del alien
	alien.patron_completado.connect(_on_patron_completado)
	alien.golpeado.connect(_on_alien_golpeado)
	alien._residuo_spawneado.connect(_on_residuo_spawneado)

	# Llamar al _ready del padre (conecta Barbara, HUD, GameOver, etc.)
	super()

	# Detener el timer del padre — el alien controla cuándo spawnear
	$Timer.stop()

	# Reemplazar el handler de residuo_clasificado del padre por el del boss
	# para que los aciertos alimenten el cargador en vez de solo las métricas
	if $Barbara.residuo_clasificado.is_connected(_on_residuo_clasificado):
		$Barbara.residuo_clasificado.disconnect(_on_residuo_clasificado)
	$Barbara.residuo_clasificado.connect(_on_residuo_clasificado_boss)

	# Crear label de cargador en el HUD
	_crear_hud_cargador()

	# Iniciar intro con pequeña pausa
	await get_tree().create_timer(1.2).timeout
	_iniciar_intro()

# ── INTRO ─────────────────────────────────────────────────────────────────────
func _iniciar_intro():
	# Mostrar aviso narrativo usando TextoOleada
	$TextoOleada.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1, 1.0))
	$TextoOleada.text = "¡¡EL ALIEN!!"
	$TextoOleada.visible = true
	$TextoOleada.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property($TextoOleada, "modulate:a", 0.0, 0.8)
	tween.tween_callback(func():
		$TextoOleada.visible = false
		_iniciar_fase(1)
	)

# ── GESTIÓN DE FASES ──────────────────────────────────────────────────────────
func _iniciar_fase(n: int):
	estado_boss = EstadoBoss.FASE_ATAQUE
	cargador_actual = 0
	_actualizar_hud_cargador()
	alien.iniciar_fase(n)

func _on_patron_completado():

	if estado_boss != EstadoBoss.FASE_ATAQUE:
		return
	if cargador_actual < ACIERTOS_PARA_CARGAR:
		# Pequeña pausa y repite
		await get_tree().create_timer(1.0).timeout
		alien.iniciar_fase(alien.fase_actual)

# ── CARGADOR ──────────────────────────────────────────────────────────────────
func _on_residuo_clasificado_boss(acierto: bool, _tipo: String):
	if estado_boss != EstadoBoss.FASE_ATAQUE:
		return

	if acierto:
		cargador_actual = min(cargador_actual + 1, ACIERTOS_PARA_CARGAR)
	else:
		cargador_actual = max(cargador_actual - 1, 0)

	_actualizar_hud_cargador()

	if cargador_actual >= ACIERTOS_PARA_CARGAR:
		_activar_vulnerabilidad()

# ── VULNERABILIDAD ────────────────────────────────────────────────────────────
func _activar_vulnerabilidad():
	estado_boss = EstadoBoss.VULNERABILIDAD
	_ventana_abierta = true
	cargador_actual = 0
	_actualizar_hud_cargador()

	# Aviso visual
	$TextoOleada.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
	$TextoOleada.text = "¡¡AHORA!!"
	$TextoOleada.visible = true
	$TextoOleada.modulate.a = 1.0
	var tw = create_tween()
	tw.tween_interval(0.8)
	tw.tween_property($TextoOleada, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func(): $TextoOleada.visible = false)

	# El alien baja
	alien.bajar()
	await alien.animacion_lista

	# Iniciar cuenta regresiva
	var duracion = VENTANA_FASE_3 if alien.fase_actual == 3 else VENTANA_FASE_1_2
	_timer_vulnerabilidad = get_tree().create_timer(duracion)
	await _timer_vulnerabilidad.timeout

	if _ventana_abierta:
		_ventana_expirada()

func _ventana_expirada():
	_ventana_abierta = false
	estado_boss = EstadoBoss.TRANSICION
	alien.subir()
	await alien.animacion_lista
	# Reinicia la misma fase
	await get_tree().create_timer(0.8).timeout
	_iniciar_fase(alien.fase_actual)

func _on_alien_golpeado():
	_ventana_abierta = false
	estado_boss = EstadoBoss.TRANSICION

	# Subir el alien antes de la transición
	alien.subir()
	await alien.animacion_lista

	match alien.hp:
		2:
			await get_tree().create_timer(1.0).timeout
			_mostrar_transicion("FASE 2", Color(1.0, 0.85, 0.3))
			await get_tree().create_timer(1.5).timeout
			_iniciar_fase(2)
		1:
			await get_tree().create_timer(1.0).timeout
			_mostrar_transicion("FASE 3 — ¡ÚLTIMO ATAQUE!", Color(1.0, 0.4, 0.1))
			await get_tree().create_timer(1.5).timeout
			_iniciar_fase(3)
		0:
			_iniciar_victoria()

func _mostrar_transicion(texto: String, color: Color):
	$TextoOleada.add_theme_color_override("font_color", color)
	$TextoOleada.text = texto
	$TextoOleada.visible = true
	$TextoOleada.modulate.a = 1.0
	var tw = create_tween()
	tw.tween_interval(1.2)
	tw.tween_property($TextoOleada, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func(): $TextoOleada.visible = false)

# ── DETECCIÓN DE GOLPE EN _PROCESS ────────────────────────────────────────────
func _process(delta):
	# Llamamos al _process del padre para HUD y PantallaResultados
	super(delta)

	if estado_boss == EstadoBoss.VULNERABILIDAD and _ventana_abierta:
		var barbara = get_node_or_null("Barbara")
		if barbara and alien.verificar_golpe(barbara.position.x):
			pass
# ── VICTORIA ──────────────────────────────────────────────────────────────────
func _iniciar_victoria():
	estado_boss = EstadoBoss.VICTORIA
	nivel_activo = false
	$Timer.stop()
	$MusicaFondo.stop()

	# Limpiar toda la basura en pantalla
	for b in get_tree().get_nodes_in_group("basura_caida"):
		b.queue_free()

	# Cutscene: alien cae, Barbara celebra
	alien.ejecutar_derrota()
	$Barbara.celebrar_victoria()

	# Esperar que terminen las animaciones
	await get_tree().create_timer(3.2).timeout

	# Mostrar resultados
	nivel_completado.emit(
		residuos_atrapados,
		residuos_escapados,
		total_residuos,
		desglose_atrapados,
		peligrosos_esquivados
	)

# ── CONECTAR RESIDUOS SPAWNEADOS POR EL ALIEN ─────────────────────────────────
func _on_residuo_spawneado(residuo):
	# Conectar las mismas señales que usa nivel.gd con basura normal
	if residuo.has_signal("tree_exited"):
		residuo.tree_exited.connect(_on_residuo_salio)
	if residuo.has_signal("residuo_escapado"):
		residuo.residuo_escapado.connect(_on_residuo_escapado)
	if residuo.categoria != "Peligroso":
		total_residuos += 1

# ── HUD CARGADOR ──────────────────────────────────────────────────────────────
func _crear_hud_cargador():
	label_cargador = Label.new()
	label_cargador.add_theme_font_size_override("font_size", 36)
	label_cargador.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))
	label_cargador.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	label_cargador.add_theme_constant_override("shadow_offset_x", 3)
	label_cargador.add_theme_constant_override("shadow_offset_y", 3)
	label_cargador.position = Vector2(700, 20)
	add_child(label_cargador)
	_actualizar_hud_cargador()

func _actualizar_hud_cargador():
	if not is_instance_valid(label_cargador):
		return
	var llenos   = cargador_actual
	var vacios   = ACIERTOS_PARA_CARGAR - cargador_actual
	var barra    = "⬛".repeat(vacios) + "🟩".repeat(llenos) if llenos > 0 else "⬛".repeat(vacios)
	# Fallback con caracteres ASCII si los emojis no renderizan bien en Godot
	barra = "[%s%s]" % ["|".repeat(llenos), " ".repeat(vacios)]
	label_cargador.text = "CARGADOR %s %d/%d" % [barra, llenos, ACIERTOS_PARA_CARGAR]

	# Color según llenado
	if cargador_actual >= ACIERTOS_PARA_CARGAR:
		label_cargador.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3, 1.0))
	elif cargador_actual >= ACIERTOS_PARA_CARGAR * 0.6:
		label_cargador.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2, 1.0))
	else:
		label_cargador.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
