extends "res://scenes/niveles/bases/NivelTopDownBase.gd"

func _ready():
	# ── Configuración de este nivel ───────────────────────────────────────
	tiempo_limite       = 90.0
	cantidad_normales   = 30
	cantidad_peligrosos = 190
	escena_nivel_actual = "res://scenes/niveles/mundo1/NivelTopDown.tscn"

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
