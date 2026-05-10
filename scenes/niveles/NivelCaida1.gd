extends "res://scripts/nivel.gd"

func _ready():
	SesionGlobal.vidas = 3
	SesionGlobal.puntaje = 0

	# ── Identidad del nivel ───────────────────────────────────────────────
	# Nivel 1-2: Caída Fácil — solo orgánico e inorgánico, sin peligrosos
	oleadas = [5, 6, 7, 7]              # 25 residuos total
	tiempo_entre_residuos = 0.65
	probabilidad_peligroso = 0.0        # sin peligrosos

	DIFICULTAD_OLEADAS = [
		[240.0, 0.65, 0.0],   # Oleada 1 — muy tranquilo
		[265.0, 0.58, 0.0],   # Oleada 2 — ligero aumento
		[285.0, 0.52, 0.0],   # Oleada 3 — ritmo constante
		[300.0, 0.46, 0.0],   # Oleada 4 — cierre sin sorpresas
	]

	super()

	# ── Música específica de este nivel ───────────────────────────────────


	# ── Fondo placeholder hasta que llegue el arte ────────────────────────
	$Fondo.color = Color("#1a2e1a")   # verde oscuro

func _mostrar_pantalla_crash():
	nivel_activo = false
	$Timer.stop()
	$MusicaFondo.stop()
	SesionGlobal.completar_nivel(1, 2)
	nivel_completado.emit(residuos_atrapados, residuos_escapados, total_residuos)
