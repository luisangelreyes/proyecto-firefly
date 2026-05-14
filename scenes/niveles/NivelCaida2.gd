extends "res://scripts/nivel.gd"

func _ready():
	SesionGlobal.vidas = 3
	SesionGlobal.puntaje = 0

	# ── Identidad del nivel ───────────────────────────────────────────────
	# Nivel 1-3: Caída Media — introduce peligrosos, más velocidad
	oleadas = [7, 8, 8, 7]              # 30 residuos total
	tiempo_entre_residuos = 1.55
	probabilidad_peligroso = 0.12       # peligrosos empiezan a aparecer
# Cada entrada corresponde a una oleada: [velocidad_caida, intervalo_spawn, prob_peligroso]
	DIFICULTAD_OLEADAS = [
		[100.0, 1.55, 0.02],   # Oleada 1 — primer contacto con peligrosos
		[240.0, 1.47, 0.08],   # Oleada 2 — más frecuentes
		[275.0, 1.40, 0.02],   # Oleada 3 — presión real
		[310.0, 1.34, 0.06],   # Oleada 4 — desafío del mundo 1
	]

	super()

	# ── Música específica de este nivel ───────────────────────────────────
	$MusicaFondo.stream = preload("res://assets/audio/music/musica_2.ogg")
	$MusicaFondo.play()


func _mostrar_pantalla_crash():
	nivel_activo = false
	$Timer.stop()
	$MusicaFondo.stop()
	SesionGlobal.completar_nivel(1, 3)
	nivel_completado.emit(residuos_atrapados, residuos_escapados, total_residuos)
