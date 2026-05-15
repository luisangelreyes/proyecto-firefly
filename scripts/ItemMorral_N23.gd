# ════════════════════════════════════════════════════════
#  ItemMorral_N23.gd
# ════════════════════════════════════════════════════════
extends Node2D
 
const SHEET_TELA       = preload("res://entities/basura/sprites/basura_tela6.png")
const SHEET_MADERA     = preload("res://entities/basura/sprites/basura_madera5.png")
const SHEET_INORGANICO = preload("res://entities/basura/sprites/basura_inorganica8.png")
 
var tipo        : String  = ""
var nombre      : String  = ""
var explicacion : String  = ""
var frame_idx   : int     = 0
var nivel_ref             = null
var pos_origen  : Vector2 = Vector2.ZERO
var arrastrando : bool    = false
var offset_arrastre : Vector2 = Vector2.ZERO
var siendo_arrastrado_por_cursor : bool = false
 
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
 
func inicializar(datos: Dictionary, ref_nivel):
	nivel_ref   = ref_nivel
	tipo        = datos["tipo"]
	nombre      = datos["nombre"]
	explicacion = datos["explicacion"]
	frame_idx   = datos["frame"]
 
	var sheet  : Texture2D
	var cols   : int
	var cell_w : float
	var cell_h : float
 
	match tipo:
		"tela":
			# 512x512 — 3 cols x 4 filas — celda 128x128
			sheet  = SHEET_TELA
			cols   = 3
			cell_w = 128.0
			cell_h = 128.0
		"madera":
			# 512x512 — 3 cols x 4 filas — celda 128x128
			sheet  = SHEET_MADERA
			cols   = 3
			cell_w = 128.0
			cell_h = 128.0
		"inorganico":
			# 1024x1536 — 3 cols x 4 filas — celda ~341x384
			sheet  = SHEET_INORGANICO
			cols   = 3
			cell_w = 1024.0 / 3.0
			cell_h = 1536.0 / 4.0
 
	var col = frame_idx % cols
	var row = frame_idx / cols
 
	var atlas = AtlasTexture.new()
	atlas.atlas  = sheet
	atlas.region = Rect2(col * cell_w, row * cell_h, cell_w, cell_h)
	sprite.texture = atlas
 
	var target_h : float = 160.0
	var scale_f  : float = target_h / cell_h
	sprite.scale = Vector2(scale_f, scale_f)
 
func volver_origen():
	global_position = pos_origen
	arrastrando = false
 
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var local = to_local(get_global_mouse_position())
			if sprite.get_rect().has_point(local):
				arrastrando     = true
				offset_arrastre = global_position - get_global_mouse_position()
				z_index         = 10
		else:
			if arrastrando:
				arrastrando = false
				z_index     = 0
				nivel_ref.intentar_clasificar(self, global_position)
 
	if event is InputEventMouseMotion and arrastrando:
		global_position = get_global_mouse_position() + offset_arrastre
