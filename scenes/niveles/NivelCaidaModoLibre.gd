extends "res://scripts/nivel.gd"

# ── CONFIG LEÍDA DESDE MODO LIBRE ────────────────────────────────────────
var config: Dictionary = {}
var es_infinito: bool = false
var timer_sesion: float = 0.0   # 0 = sin límite
var timer_sesion_activo: bool = false

# ── AUMENTO DE VELOCIDAD EN MODO INFINITO ────────────────────────────────
var tiempo_jugado: float = 0.0
const AUMENTO_VELOCIDAD_CADA: float = 15.0   # cada 15 segundos sube
const AUMENTO_VELOCIDAD_CANTIDAD: float = 20.0  # sube 20 px/s cada vez
const VELOCIDAD_MAXIMA: float = 700.0

@onready var lbl_timer_sesion = $LabelTimerSesion  # Label nuevo en la escena

func _ready():
	SesionGlobal.vidas   = 3
	SesionGlobal.puntaje = 0

	config = SesionGlobal.modo_libre_config

	match config.get("dificultad", "normal"):
		"facil":
			oleadas = [5, 5, 5, 5]
			DIFICULTAD_OLEADAS = [
				[220.0, 0.70, 0.0],[240.0, 0.65, 0.0],
				[260.0, 0.60, 0.0],[280.0, 0.55, 0.0],
			]
		"normal":
			oleadas = [6, 7, 8, 9]
			DIFICULTAD_OLEADAS = [
				[260.0, 0.60, 0.08],[290.0, 0.52, 0.12],
				[320.0, 0.45, 0.16],[350.0, 0.38, 0.20],
			]
		"dificil":
			oleadas = [8, 9, 10, 10]
			DIFICULTAD_OLEADAS = [
				[650.0, 0.12, 0.52],[390.0, 0.35, 0.28],
				[430.0, 0.28, 0.32],[470.0, 0.22, 0.36],
			]

	var vel = config.get("velocidad", 100)
	if vel != 100:
		Engine.time_scale = vel / 100.0

	es_infinito = config.get("modo_infinito", false)

	var minutos = config.get("timer_minutos", 0)
	if minutos > 0:
		timer_sesion        = float(minutos * 60)
		timer_sesion_activo = true

	# ← ANTES de super(): vaciar oleadas si es infinito o tiene timer
	if es_infinito or timer_sesion_activo:
		oleadas = []

	super()

	# ← DESPUÉS de super(): activar nivel si es spawn continuo
	if es_infinito or timer_sesion_activo:
		nivel_activo = true
		$Timer.stop()

	if has_node("LabelTimerSesion"):
		lbl_timer_sesion.visible = timer_sesion_activo

func _process(delta):
	super(delta)

	if not nivel_activo:
		return

	tiempo_jugado += delta

	# ── Spawn infinito ────────────────────────────────────────────────────
	if es_infinito or timer_sesion_activo:
		_manejar_spawn_infinito(delta)
		_aumentar_velocidad_progresiva()

	# ── Timer de sesión ───────────────────────────────────────────────────
	if timer_sesion_activo:
		timer_sesion -= delta
		timer_sesion  = max(0, timer_sesion)

		if has_node("LabelTimerSesion"):
			lbl_timer_sesion.text = "Tiempo: %d" % ceil(timer_sesion)

		if timer_sesion <= 0:
			_terminar_por_tiempo()

# ── SPAWN INFINITO ────────────────────────────────────────────────────────
var _spawn_timer: float = 0.0
var _intervalo_spawn: float = 0.5

func _manejar_spawn_infinito(delta):
	_spawn_timer += delta
	if _spawn_timer >= _intervalo_spawn:
		_spawn_timer = 0.0
		lanzar_basura_normal()

func _aumentar_velocidad_progresiva():
	var pasos = int(tiempo_jugado / AUMENTO_VELOCIDAD_CADA)
	_intervalo_spawn = max(0.20, 0.50 - pasos * 0.04)
	probabilidad_peligroso = min(0.35, pasos * 0.03)

	var nueva_vel = min(
		VELOCIDAD_MAXIMA,
		260.0 + pasos * AUMENTO_VELOCIDAD_CANTIDAD
	)
	# La guardamos para que lanzar_basura_normal() la use
	DIFICULTAD_OLEADAS = [[nueva_vel, _intervalo_spawn, probabilidad_peligroso]]
	oleada_actual = 0

func _terminar_por_tiempo():
	timer_sesion_activo = false
	nivel_activo = false
	$Timer.stop()
	$MusicaFondo.stop()
	Engine.time_scale = 1.0
	nivel_completado.emit(residuos_atrapados, residuos_escapados,
		residuos_atrapados + residuos_escapados)


		
func _mostrar_pantalla_crash():
	nivel_activo = false
	$Timer.stop()
	$MusicaFondo.stop()
	Engine.time_scale = 1.0
	SesionGlobal.guardar_sesion()
	nivel_completado.emit(residuos_atrapados, residuos_escapados,
		residuos_atrapados + residuos_escapados)
