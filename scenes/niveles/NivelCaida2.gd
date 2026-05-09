extends "res://scripts/nivel.gd"

func _ready():
	SesionGlobal.vidas = 3
	SesionGlobal.puntaje = 0

	# ── Identidad del nivel ───────────────────────────────────────────────
	# Nivel 1-3: Caída Media — introduce peligrosos, más velocidad
	oleadas = [7, 8, 8, 7]              # 30 residuos total
	tiempo_entre_residuos = 0.55
	probabilidad_peligroso = 0.12       # peligrosos empiezan a aparecer

	DIFICULTAD_OLEADAS = [
		[300.0, 0.55, 0.12],   # Oleada 1 — primer contacto con peligrosos
		[340.0, 0.47, 0.18],   # Oleada 2 — más frecuentes
		[375.0, 0.40, 0.22],   # Oleada 3 — presión real
		[410.0, 0.34, 0.26],   # Oleada 4 — desafío del mundo 1
	]

	super()

	# ── Música específica de este nivel ───────────────────────────────────
	$MusicaFondo.stream = preload("res://assets/audio/music/musica_2.ogg")
	$MusicaFondo.play()

	# ── Fondo placeholder ─────────────────────────────────────────────────
	$Fondo.color = Color("#1a1a2e")   # azul oscuro

func _mostrar_pantalla_crash():
	nivel_activo = false
	$Timer.stop()
	$MusicaFondo.stop()
	SesionGlobal.completar_nivel(1, 3)
	nivel_completado.emit(residuos_atrapados, residuos_escapados, total_residuos)
