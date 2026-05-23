extends "res://scripts/nivel.gd"

func _ready():

	SesionGlobal.vidas = 3
	SesionGlobal.puntaje = 0

	# ── Identidad del nivel ───────────────────────────────────────────────
	# Nivel 1-3: Caída Media — introduce peligrosos, más velocidad
	oleadas = [7, 8, 8, 7,10]              # 30 residuos total
	tiempo_entre_residuos = 1.85
	probabilidad_peligroso = 0.38       # peligrosos empiezan a aparecer
# Cada entrada corresponde a una oleada: [velocidad_caida, intervalo_spawn, prob_peligroso]
	DIFICULTAD_OLEADAS = [
		[500.0, 1.55, 0.32],   # Oleada 1 — primer contacto con peligrosos
		[540.0, 1.87, 0.28],   # Oleada 2 — más frecuentes
		[675.0, 1.80, 0.22],   # Oleada 3 — presión real
		[610.0, 1.84, 0.26],
		[610.0, 1.84, 0.26],   # Oleada 4 — desafío del mundo 1
	]

	super()

	# ── Música específica de este nivel ───────────────────────────────────

func _mostrar_pantalla_crash():
	if SesionGlobal.vidas <= 0:
		return
	nivel_activo = false
	$Timer.stop()
	$MusicaFondo.stop()
	SesionGlobal.completar_nivel(2, 2)

	SesionGlobal.guardar_sesion()
	nivel_completado.emit(        residuos_atrapados,
		residuos_escapados,
		total_residuos,
		desglose_atrapados,
		peligrosos_esquivados)
	var nodo_liz = get_node_or_null("Barbara") 
	if nodo_liz != null:
		nodo_liz.celebrar_victoria()
