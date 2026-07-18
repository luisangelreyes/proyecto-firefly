extends "res://scenes/niveles/bases/NivelTopDownBase.gd"

func _ready():
	escena_nivel_actual = "res://scenes/niveles/NivelTopDownModoLibre.tscn"

	sprite_sheet = preload(
        "res://entities/basura/sprites/basura_in_or_pelirgo.png"
	)

	catalogo_basura = [
		{"tipo":"inorganico","nombre":"lata_aplastada",   "region":Rect2(0,    0,    800,800)},
		{"tipo":"inorganico","nombre":"botella_plastico", "region":Rect2(800,  0,    800,800)},
		{"tipo":"inorganico","nombre":"caja_leche",       "region":Rect2(1600, 0,    800,800)},
		{"tipo":"inorganico","nombre":"bolsa_basura",     "region":Rect2(2400, 0,    800,800)},
		{"tipo":"inorganico","nombre":"periodico",        "region":Rect2(4000, 0,    800,800)},
		{"tipo":"inorganico","nombre":"caja_carton",      "region":Rect2(4800, 0,    800,800)},
		{"tipo":"organico",  "nombre":"manzana",          "region":Rect2(2400, 2400, 800,800)},
		{"tipo":"organico",  "nombre":"platano",          "region":Rect2(1600, 3200, 800,800)},
		{"tipo":"organico",  "nombre":"hueso",            "region":Rect2(3200, 3200, 800,800)},
		{"tipo":"organico",  "nombre":"elote",            "region":Rect2(0,    2400, 800,800)},
		{"tipo":"organico",  "nombre":"naranja",          "region":Rect2(4800, 2400, 800,800)},
		{"tipo":"peligroso", "nombre":"bateria",          "region":Rect2(4000, 4000, 800,800)},
		{"tipo":"peligroso", "nombre":"jeringa",          "region":Rect2(4800, 4000, 800,800)},
		{"tipo":"peligroso", "nombre":"cigarro",          "region":Rect2(0,    4800, 800,800)},
		{"tipo":"peligroso", "nombre":"lata_aerosol",     "region":Rect2(1600, 4800, 800,800)},
		{"tipo":"peligroso", "nombre":"cristal_roto",     "region":Rect2(3200, 4800, 800,800)},
	]

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
				if nuevo["tipo"] == "peligroso":
					nuevo["velocidad"] = 60.0
				return nuevo
			)
		"dificil":
			catalogo_basura = catalogo_basura.map(func(item):
				var nuevo = item.duplicate()
				if nuevo["tipo"] == "peligroso":
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
