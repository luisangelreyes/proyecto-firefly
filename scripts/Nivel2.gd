extends Node2D

const OBJETOS = [
	# ── PET ──
	{"nombre": "Botella",  "tipo": "pet", "explicacion": "Las botellas son de plástico PET, se reciclan en el contenedor azul.",
	 "textura": preload("res://entities/basura/sprites/trash_bottle.png")},
	{"nombre": "Vaso",     "tipo": "pet", "explicacion": "Los vasos son de plástico por ello van en el contenedor de PET.",
	 "textura": preload("res://entities/basura/sprites/trash_cup.png")},
	{"nombre": "Plástico", "tipo": "pet", "explicacion": "Las bolsas y envases plásticos son PET reciclable.",
	 "textura": preload("res://entities/basura/sprites/trash_plastic.png")},
	{"nombre": "Botella","tipo": "pet", "explicacion": "Toda botella de plastico va en el contenedor de plastico.",
	 "textura": preload("res://entities/basura/sprites/trash_bottle.png")},
	# ── ALUMINIO ──
	{"nombre": "Clavo",    "tipo": "alu", "explicacion": "Los clavos son de metal, van en el contenedor de Metales.",
	 "textura": preload("res://entities/basura/sprites/trash_nail.png")},
	{"nombre": "Clavo",  "tipo": "alu", "explicacion": "Los metales como clavos se reciclan en el contenedor gris de Metales.",
	 "textura": preload("res://entities/basura/sprites/trash_nail.png")},
	{"nombre": "Metal",    "tipo": "alu", "explicacion": "Las piezas metálicas van siempre en el contenedor de Metal.",
	 "textura": preload("res://entities/basura/sprites/trash_nail.png")},
	# ── ORGÁNICO ──
	{"nombre": "Manzana",  "tipo": "org", "explicacion": "Las frutas son residuos orgánicos, por eso van en el contenedor Verde.",
	 "textura": preload("res://entities/basura/sprites/trash_apple.png")},
	{"nombre": "Hueso",    "tipo": "org", "explicacion": "Los huesos son materia orgánica y van en el contenedor verde.",
	 "textura": preload("res://entities/basura/sprites/trash_bone.png")},
	{"nombre": "Pan",      "tipo": "org", "explicacion": "Los alimentos como el pan son residuos orgánicos.",
	 "textura": preload("res://entities/basura/sprites/trash_bread.png")},
	{"nombre": "Hoja",     "tipo": "org", "explicacion": "Las hojas y plantas son residuos orgánicos naturales.",
	 "textura": preload("res://entities/basura/sprites/trash_leaf.png")},
]

const ItemScene = preload("res://entities/basura/ItemMorral.tscn")

@onready var bote_pet     = $BotePET
@onready var bote_alu     = $BoteALU
@onready var bote_carton  = $BoteCARTON
@onready var lbl_puntos   = $Labelpuntos
# @onready var lbl_vidas  = $LabelVidas   # descomenta para reactivar vidas
@onready var lbl_feedback = $LabelFeedBack
@onready var cnt_pet      = $BotePET/ContadorPET
@onready var cnt_alu      = $BoteALU/ContadorALU
@onready var cnt_carton   = $BoteCARTON/ContadorCarton
@onready var popup          = $InterfazUI/PopUpAyuda
@onready var lbl_explicacion = $InterfazUI/PopUpAyuda/VBoxContainer/LblExplicacion
@onready var icono_bote     = $InterfazUI/PopUpAyuda/VBoxContainer/IconoBote

var puntos       : int   = 0
# var vidas      : int   = 3   # descomenta para reactivar vidas
var total        : int   = 11
var clasificados : int   = 0
var fb_timer     : float = 0.0
var juego_activo : bool  = true
var item_pausado = null   # guarda el item mientras el popup está abierto

const GRID_ORIGEN  = Vector2(55, 280)
const GRID_COL_SEP = 130
const GRID_ROW_SEP = 155


func _ready():
	lbl_feedback.visible = false
	_poblar_morral()
	_actualizar_hud()
	popup.visible = false


func _poblar_morral():
	for item in get_tree().get_nodes_in_group("items_morral"):
		item.queue_free()
	var lista = OBJETOS.duplicate()
	lista.shuffle()
	for i in range(lista.size()):
		var item = ItemScene.instantiate()
		add_child(item)
		item.add_to_group("items_morral")
		var col : int = i % 3
		var row : int = i / 3
		item.global_position = GRID_ORIGEN + Vector2(col * GRID_COL_SEP, row * GRID_ROW_SEP)
		item.inicializar(lista[i], self)


func intentar_clasificar(item, pos_soltar: Vector2 = Vector2.ZERO):
	if not juego_activo:
		item.volver_origen()
		return
	var pos = pos_soltar if pos_soltar != Vector2.ZERO else item.global_position
	var bote_target = _get_bote_en(pos)
	if bote_target == null:
		item.volver_origen()
		return
	if bote_target.get_meta("tipo") == item.tipo:
		_correcto(item, bote_target.get_meta("tipo"))
	else:
		_incorrecto(item, item.tipo)


func _get_bote_en(pos: Vector2) -> Area2D:
	for bote in [bote_pet, bote_alu, bote_carton]:
		var rect = Rect2(
			bote.global_position + Vector2(-130, -160),
			Vector2(260, 320)
		)
		if rect.has_point(pos):
			return bote
	return null


func _correcto(item, tipo: String):
	puntos       += 10
	clasificados += 1
	match tipo:
		"pet": cnt_pet.text    = str(int(cnt_pet.text)    + 1)
		"alu": cnt_alu.text    = str(int(cnt_alu.text)    + 1)
		"org": cnt_carton.text = str(int(cnt_carton.text) + 1)
	item.remove_from_group("items_morral")
	item.queue_free()
	_actualizar_hud()
	_feedback("Correcto! +10 pts", Color("#86efac"))
	if clasificados >= total:
		await get_tree().create_timer(0.8).timeout
		_victoria()


func _incorrecto(item, tipo_correcto: String):
	# Pausar el juego mientras se muestra la explicación
	juego_activo  = false
	item_pausado  = item

	# Texto explicativo personalizado del objeto
	var nombre_obj = item.nombre if "nombre" in item else "Este objeto"
	var explicacion = item.explicacion if "explicacion" in item else ""

	var nombres_botes = {"pet": "Plástico 🔵", "alu": "Metal ⚙️", "org": "Orgánico 🌿"}
	lbl_explicacion.text = "¡Casi! %s va en el contenedor de: %s\n\n%s" % [
		nombre_obj,
		nombres_botes[tipo_correcto],
		explicacion
	]

	# Mostrar popup
	popup.visible = true


	



func _actualizar_hud():
	lbl_puntos.text = "Puntos: %d" % puntos
	# ── descomenta para mostrar vidas ──
	# var c = ""
	# for i in 3:
	# 	c += "vida" if i < vidas else "sin vida"
	# lbl_vidas.text = c


func _feedback(msg: String, color: Color):
	lbl_feedback.text = msg
	lbl_feedback.add_theme_color_override("font_color", color)
	lbl_feedback.visible = true
	fb_timer = 2.5


func _process(delta):
	if fb_timer > 0:
		fb_timer -= delta
		if fb_timer <= 0:
			lbl_feedback.visible = false


func _victoria():
	juego_activo = false
	for item in get_tree().get_nodes_in_group("items_morral"):
		item.set_process_input(false)
	lbl_feedback.text = "NIVEL COMPLETADO!\n%d puntos\n\nPresiona R para reiniciar" % puntos
	# ── descomenta cuando reactives vidas ──
	# lbl_feedback.text = "NIVEL COMPLETADO!\n%d puntos | %d errores\n\nPresiona R para reiniciar" % [puntos, 3 - vidas]
	lbl_feedback.add_theme_color_override("font_color", Color("#fbbf24"))
	lbl_feedback.visible = true


# ── descomenta esta funcion completa cuando reactives vidas ──
# func _game_over():
# 	juego_activo = false
# 	for item in get_tree().get_nodes_in_group("items_morral"):
# 		item.set_process_input(false)
# 	lbl_feedback.text = "GAME OVER\n%d puntos\n\nPresiona R para reiniciar" % puntos
# 	lbl_feedback.add_theme_color_override("font_color", Color("#fca5a5"))
# 	lbl_feedback.visible = true


func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R and not juego_activo:
			get_tree().reload_current_scene()

func _on_popup_entendido_pressed():
	popup.visible = false
	juego_activo  = true

	# Devolver el item al morral
	if item_pausado and is_instance_valid(item_pausado):
		item_pausado.volver_origen()
		item_pausado.set_process_input(true)
		item_pausado = null
