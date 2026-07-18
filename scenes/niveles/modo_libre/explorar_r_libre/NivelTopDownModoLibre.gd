extends "res://scenes/niveles/bases/NivelTopDownBase.gd"

func _ready():
	escena_nivel_actual = "res://scenes/niveles/NivelTopDownModoLibre.tscn"

	sprite_sheet = preload(
        "res://entities/basura/sprites/basura_in_or_pelirgo.png"
	)

	var base_catalogo = SesionGlobal.datos_residuos.get("topdown_catalogo", [])
	catalogo_basura = []
	for item in base_catalogo:
		var rect = item["region"]
		catalogo_basura.append({
			"tipo": item["tipo"],
			"nombre": item["nombre"],
			"region": Rect2(rect[0], rect[1], rect[2], rect[3])
		})

	# ── Leer config del modo libre ────────────────────────────────────────
	var config = SesionGlobal.modo_libre_config

	# Tiempo límite
	tiempo_limite = float(config.get("tiempo_limite", 60))

	# Densidad de residuos
	match config.get("densidad", "normal"):
		"pocos":
			cantidad_normales   = 6
			cantidad_peligrosos = 15
		"normal":
			cantidad_normales   = 10
			cantidad_peligrosos = 50
		"muchos":
			cantidad_normales   = 20
			cantidad_peligrosos = 150

	# Dificultad — afecta velocidad de los residuos
	match config.get("dificultad", "normal"):
		"facil":
			# Peligrosos más lentos, más tiempo de reacción
			catalogo_basura = catalogo_basura.map(func(item):
				var nuevo = item.duplicate()
				if nuevo["tipo"] == SesionGlobal.Categorias.PELIGROSO:
					nuevo["velocidad"] = 60.0
				return nuevo
			)
		"dificil":
			catalogo_basura = catalogo_basura.map(func(item):
				var nuevo = item.duplicate()
				if nuevo["tipo"] == SesionGlobal.Categorias.PELIGROSO:
					nuevo["velocidad"] = 160.0
				return nuevo
			)

	super()

func _victoria():
	juego_activo = false
	timer_activo = false
	SesionGlobal.guardar_sesion()
	_activar_iman_contencion()
	await get_tree().create_timer(1.5).timeout
	if is_inside_tree():
		_mostrar_resultado(true)

func _reiniciar():
	Engine.get_main_loop().change_scene_to_file(
		"res://scenes/niveles/modo_libre/NivelTopDownModoLibre.tscn"
	)

func _ir_menu():
	Engine.get_main_loop().change_scene_to_file(
        "res://ui/menu/ModoLibre.tscn"
	
	)
