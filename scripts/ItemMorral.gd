extends Node2D

const SPRITESHEET = preload("res://entities/basura/sprites/basura_nivel2.png")
const COLS = 9

var tipo: String = ""
var nombre: String = ""
var explicacion: String = ""
var frame_idx: int = 0
var nivel_ref = null
var pos_origen: Vector2 = Vector2.ZERO
var arrastrando: bool = false
var offset_arrastre: Vector2 = Vector2.ZERO
var siendo_arrastrado_por_cursor: bool = false  # ← arrastre por mando

func mover_a(pos: Vector2):
	if siendo_arrastrado_por_cursor:
		global_position = pos

func agarrar():
	siendo_arrastrado_por_cursor = true
	z_index = 10

func soltar():
	siendo_arrastrado_por_cursor = false
	z_index = 0
	nivel_ref.intentar_clasificar(self, global_position)

@onready var sprite = $Sprite2D
#@onready var col_shape = $Area2D/CollisionShape2D

func inicializar(datos: Dictionary, ref_nivel):
	nivel_ref   = ref_nivel
	tipo        = datos["tipo"]
	nombre      = datos["nombre"]
	explicacion = datos.get("explicacion", "")
	frame_idx   = datos["frame"]

	var sheet = datos.get("sheet", preload(
		"res://entities/basura/sprites/basura_nivel2.png"))
	var cols  = datos.get("cols", 9)

	var atlas    = AtlasTexture.new()
	atlas.atlas  = sheet
	var cell_w   = sheet.get_width()  / float(cols)
	var cell_h   = sheet.get_height() / float(sheet.get_height() / cell_w)
	# Calcular filas automáticamente
	var filas    = int(sheet.get_height() / cell_w) \
		if cell_w == (sheet.get_height() / (sheet.get_height() / cell_w)) \
		else sheet.get_height() / (sheet.get_width() / cols)
	cell_h       = sheet.get_height() / float(int(sheet.get_height() / (sheet.get_width() / cols)))

	var col      = frame_idx % cols
	var row      = frame_idx / cols
	atlas.region = Rect2(col * cell_w, row * cell_h, cell_w, cell_h)
	sprite.texture = atlas
	sprite.scale   = Vector2(0.35, 0.35)

func volver_origen():
	global_position = pos_origen
	arrastrando = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var local = to_local(get_global_mouse_position())
			if sprite.get_rect().has_point(local):
				arrastrando = true
				offset_arrastre = global_position - get_global_mouse_position()
				z_index = 10
		else:
			if arrastrando:
				arrastrando = false
				z_index = 0
				# ← usamos la posición del sprite, no del mouse
				nivel_ref.intentar_clasificar(self, global_position)
	
	if event is InputEventMouseMotion and arrastrando:
		global_position = get_global_mouse_position() + offset_arrastre
