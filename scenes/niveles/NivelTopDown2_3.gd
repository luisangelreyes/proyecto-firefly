# NivelTopDown2_3.gd — Mundo 2, nivel top-down
extends "res://scripts/NivelTopDownBase.gd"

func _ready():
	tiempo_limite       = 120.0   # más tiempo para el mundo 2
	cantidad_normales   = 15
	cantidad_peligrosos = 50
	escena_nivel_actual = "res://scenes/niveles/Mundo2/NivelTopDown2_3.tscn"
	sprite_sheet = preload(
        "res://entities/basura/sprites/basura_in_or_pelirgo.png"
	)
	catalogo_basura = [
		# INORGÁNICOS
		{"tipo":"inorganico","nombre":"lata_aplastada",   "region":Rect2(0,    0,    800,800)},
		{"tipo":"inorganico","nombre":"botella_plastico", "region":Rect2(800,  0,    800,800)},
		{"tipo":"inorganico","nombre":"caja_leche",       "region":Rect2(1600, 0,    800,800)},
		{"tipo":"inorganico","nombre":"bolsa_basura",     "region":Rect2(2400, 0,    800,800)},
		{"tipo":"inorganico","nombre":"periodico",        "region":Rect2(4000, 0,    800,800)},
		{"tipo":"inorganico","nombre":"caja_carton",      "region":Rect2(4800, 0,    800,800)},
		{"tipo":"inorganico","nombre":"cd_viejo",         "region":Rect2(2400, 800,  800,800)},
		# ORGÁNICOS
		{"tipo":"organico",  "nombre":"manzana",          "region":Rect2(2400, 2400, 800,800)},
		{"tipo":"organico",  "nombre":"platano",          "region":Rect2(1600, 3200, 800,800)},
		{"tipo":"organico",  "nombre":"hueso",            "region":Rect2(3200, 3200, 800,800)},
		{"tipo":"organico",  "nombre":"sandia",           "region":Rect2(4800, 1600, 800,800)},
		{"tipo":"organico",  "nombre":"elote",            "region":Rect2(0,    2400, 800,800)},
		{"tipo":"organico",  "nombre":"naranja",          "region":Rect2(4800, 2400, 800,800)},
		{"tipo":"organico",  "nombre":"cascara_huevo",    "region":Rect2(4000, 3200, 800,800)},
		{"tipo":"organico",  "nombre":"espinas_pez",      "region":Rect2(1600, 4000, 800,800)},
		# PELIGROSOS
		{"tipo":"peligroso", "nombre":"bateria",          "region":Rect2(4000, 4000, 800,800)},
		{"tipo":"peligroso", "nombre":"jeringa",          "region":Rect2(4800, 4000, 800,800)},
		{"tipo":"peligroso", "nombre":"foco_roto",        "region":Rect2(800,  4800, 800,800)},
		{"tipo":"peligroso", "nombre":"cigarro",          "region":Rect2(0,    4800, 800,800)},
		{"tipo":"peligroso", "nombre":"lata_aerosol",     "region":Rect2(1600, 4800, 800,800)},
		{"tipo":"peligroso", "nombre":"bidon_veneno",     "region":Rect2(2400, 4800, 800,800)},
		{"tipo":"peligroso", "nombre":"cristal_roto",     "region":Rect2(3200, 4800, 800,800)},
		{"tipo":"peligroso", "nombre":"clavo_oxidado",    "region":Rect2(4800, 4800, 800,800)},
	]

	super()
