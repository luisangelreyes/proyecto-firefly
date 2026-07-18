# NivelTopDown2_3.gd — Mundo 2, nivel top-down
extends "res://scenes/niveles/bases/NivelTopDownBase.gd"

func _ready():
	tiempo_limite       = 120.0   # más tiempo para el mundo 2
	cantidad_normales   = 15
	cantidad_peligrosos = 50
	escena_nivel_actual = "res://scenes/niveles/Mundo2/NivelTopDown2_3.tscn"
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

	super()
