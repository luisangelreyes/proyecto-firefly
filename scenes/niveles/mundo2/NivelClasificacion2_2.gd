extends "res://scenes/niveles/bases/NivelClasificacionBase.gd"

const SHEET_INORG = preload("res://entities/basura/sprites/basura_inorganica8.png")
const SHEET_TELA  = preload("res://entities/basura/sprites/basura_tela6.png")
const SHEET_N2    = preload("res://entities/basura/sprites/basura_in_or_pelirgo.png")


func _ready():
	config_botes = [
		{"nodo": "BotePAPEL",    "tipo": SesionGlobal.Categorias.ORGANICO,   "nombre": "Orgánico"},
		{"nodo": "BoteVIDRIO",   "tipo": SesionGlobal.Categorias.INORGANICO, "nombre": "Inorgánico"},
		{"nodo": "BotePLASTICO", "tipo": SesionGlobal.Categorias.TELA,       "nombre": SesionGlobal.Categorias.TELA},
	]
	
	catalogo_objetos = [
		{"frame":26, "sheet":SHEET_N2,    "cols":7,"filas": 6,"escala":0.2, "tipo":SesionGlobal.Categorias.ORGANICO,
		 "nombre":"Restos de Piña",  "explicacion":"Las frutas son residuos orgánicos."},
		{"frame":27, "sheet":SHEET_N2,    "cols":7,"filas": 6,"escala":0.2, "tipo":SesionGlobal.Categorias.ORGANICO,
		 "nombre":"Naranja",    "explicacion":"Los restos de comida son orgánicos."},
		{"frame":0, "sheet":SHEET_INORG, "cols":3,"filas": 4,"escala":0.5, "tipo":SesionGlobal.Categorias.INORGANICO,
		 "nombre":"Lata",     "explicacion":"Las latas van en el contenedor Inorgánico."},
		{"frame":1, "sheet":SHEET_INORG, "cols":3,"filas": 4,"escala":0.5, "tipo":SesionGlobal.Categorias.INORGANICO,
		 "nombre":"Envase",   "explicacion":"Los envases van en Inorgánico."},
		{"frame":0, "sheet":SHEET_TELA,  "cols":4,"filas": 4,"escala":1.5, "tipo":SesionGlobal.Categorias.TELA,
		 "nombre":"Ropa",     "explicacion":"La ropa y tela van en el contenedor de Tela."},
		{"frame":1, "sheet":SHEET_TELA,  "cols":4,"filas": 4,"escala":1.5, "tipo":SesionGlobal.Categorias.TELA,
		 "nombre":"Trapo",    "explicacion":"Los trapos van en el contenedor de Tela."},
	]

	mensajes_tutorial = [
		"Ahora estamos en el mercado, mija. Aquí la\nbasura es muy variada — hay que separar bien.",
		"Tenemos tres contenedores: ORGÁNICO para\nresiduos de comida, INORGÁNICO para envases\ny latas, y TELA para ropa y trapos.",
		"¡Cuidado! No todos los residuos son iguales.\nFíjate bien antes de soltar cada objeto.",
	]
	
	super ()
