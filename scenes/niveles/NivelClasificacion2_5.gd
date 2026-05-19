extends "res://scripts/NivelClasificacionBase.gd"

const SHEET_METAL  = preload("res://entities/basura/sprites/basura_metalica3.png")
const SHEET_MADERA = preload("res://entities/basura/sprites/basura_madera5.png")
const SHEET_N2     = preload("res://entities/basura/sprites/basura_nivel2.png")

func _ready():
	config_botes = [
		{"nodo": "BotePAPEL",    "tipo": "metal",  "nombre": "Metal"},
		{"nodo": "BoteVIDRIO",   "tipo": "madera", "nombre": "Madera"},
		{"nodo": "BotePLASTICO", "tipo": "vidrio", "nombre": "Vidrio"},
	]

	catalogo_objetos = [
		{"frame":0, "sheet":SHEET_METAL,  "cols":4, "filas":4,"escala":1.5,
		 "tipo":"metal",  "nombre":"Clavo",
		 "explicacion":"Los metales van en el contenedor de Metal."},
		{"frame":1, "sheet":SHEET_METAL,  "cols":4, "filas":4,"escala":1.5,
		 "tipo":"metal",  "nombre":"Tubo",
		 "explicacion":"Los tubos metálicos van en Metal."},
		{"frame":2, "sheet":SHEET_METAL,  "cols":4, "filas":4,"escala":1.5,
		 "tipo":"metal",  "nombre":"Pieza",
		 "explicacion":"Las piezas de metal van en el contenedor de Metal."},
		{"frame":0, "sheet":SHEET_MADERA, "cols":4, "filas":4,"escala":1.5,
		 "tipo":"madera", "nombre":"Tabla",
		 "explicacion":"La madera va en el contenedor de Madera."},
		{"frame":1, "sheet":SHEET_MADERA, "cols":4, "filas":4,"escala":1.5,
		 "tipo":"madera", "nombre":"Palo",
		 "explicacion":"Los palos de madera van en Madera."},
		{"frame":10, "sheet":SHEET_N2,    "cols":9, "filas":4,"escala":0.3,
		 "tipo":"vidrio", "nombre":"Botella",
		 "explicacion":"Las botellas de vidrio van en Vidrio."},
		{"frame":11, "sheet":SHEET_N2,    "cols":9, "filas":4,"escala":0.3,
		 "tipo":"vidrio", "nombre":"Frasco",
		 "explicacion":"Los frascos van en el contenedor de Vidrio."},
	]

	mensajes_tutorial = [
		"Este sitio tiene residuos más pesados, mija.\nMetal, madera y vidrio — hay que separarlos bien.",
		"El METAL va en su contenedor, la MADERA\nen el suyo y el VIDRIO en el tercero.",
		"Fíjate bien en el material de cada objeto\nantes de soltarlo. ¡Ándale!",
	]
	
	super()
