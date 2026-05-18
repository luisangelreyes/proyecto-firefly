extends "res://scripts/NivelClasificacionBase.gd"

const SHEET_N2 = preload("res://entities/basura/sprites/basura_nivel2.png")

func _ready():
	# ── Botes ────────────────────────────────────────────────────────────
	config_botes = [
		{"nodo": "BotePAPEL",    "tipo": "papel",    "nombre": "Papel"},
		{"nodo": "BoteVIDRIO",   "tipo": "vidrio",   "nombre": "Vidrio"},
		{"nodo": "BotePLASTICO", "tipo": "plastico", "nombre": "Plástico"},
	]

	# ── Catálogo ─────────────────────────────────────────────────────────
	catalogo_objetos = [
		{"frame":0,  "sheet":SHEET_N2, "cols":9, "tipo":"papel",
		 "nombre":"Periódico",    "explicacion":"El periódico es papel reciclable."},
		{"frame":2,  "sheet":SHEET_N2, "cols":9, "tipo":"papel",
		 "nombre":"Caja cartón",  "explicacion":"El cartón va en el contenedor de Papel."},
		{"frame":10, "sheet":SHEET_N2, "cols":9, "tipo":"vidrio",
		 "nombre":"Botella",      "explicacion":"Las botellas de vidrio van en Vidrio."},
		{"frame":11, "sheet":SHEET_N2, "cols":9, "tipo":"vidrio",
		 "nombre":"Frasco",       "explicacion":"Los frascos de vidrio van en Vidrio."},
		{"frame":22, "sheet":SHEET_N2, "cols":9, "tipo":"plastico",
		 "nombre":"Botella PET",  "explicacion":"Las botellas de plástico van en Plástico."},
		{"frame":23, "sheet":SHEET_N2, "cols":9, "tipo":"plastico",
		 "nombre":"Yogur",        "explicacion":"Los envases de yogur son plástico reciclable."},
	]
	
	# ── Tutorial ─────────────────────────────────────────────────────────
	mensajes_tutorial = [
	"¡Mija, escucha bien! Aquí tienes tres contenedores:\nuno para [color=#F4D03F]PAPEL[/color], uno para [color=#2ECC71]VIDRIO[/color] y uno para [color=#3498DB]PLÁSTICO[/color].",
	"Cada objeto que salga de tu morral lo tienes\nque arrastrar al contenedor correcto.",
	"Si lo pones en el lugar equivocado, te voy\na explicar dónde va. ¡No te apures, así se aprende!",
	"Tienes %d segundos para clasificar cada objeto\nantes de que se acabe el tiempo. ¡Ándale!" % int(tiempo_limite),
	"¿Listo? ¡Vamos a limpiar esto!",
]

	super()
