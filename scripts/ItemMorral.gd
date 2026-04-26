extends Area2D

var tipo          : String  = ""
var nombre      : String = ""   # ← nueva
var explicacion : String = ""   # ← nueva
var arrastrando   : bool    = false
var offset_drag   : Vector2 = Vector2.ZERO
var posicion_orig : Vector2 = Vector2.ZERO
var nivel_ref     : Node    = null

@onready var sprite     = $Sprite2D
@onready var lbl_nombre = $LabelNombre


func inicializar(datos: Dictionary, p_nivel: Node):
	tipo        = datos["tipo"]
	nombre      = datos["nombre"]       # ← nueva
	explicacion = datos["explicacion"]  # ← nueva
	nivel_ref   = p_nivel
	explicacion = datos["explicacion"]   # ← nueva línea
	lbl_nombre.text = datos["nombre"]
	sprite.texture  = datos["textura"]
	if sprite.texture:
		var tam = max(sprite.texture.get_width(), sprite.texture.get_height())
		sprite.scale = Vector2(80.0 / tam, 80.0 / tam)


func _input(event: InputEvent):
	if not visible: return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var rect = Rect2(global_position - Vector2(45, 45), Vector2(90, 90))
			if rect.has_point(event.global_position):
				arrastrando   = true
				posicion_orig = global_position
				offset_drag   = event.global_position - global_position
				z_index       = 50
				modulate.a    = 0.75
		else:
			if arrastrando:
				arrastrando = false
				z_index     = 0
				modulate.a  = 1.0
				if nivel_ref:
					# Pasar el centro del item, no la esquina
					nivel_ref.intentar_clasificar(self, global_position)

	if event is InputEventMouseMotion and arrastrando:
		global_position = event.global_position - offset_drag


func volver_origen():
	var tw = create_tween()
	tw.tween_property(self, "global_position", posicion_orig, 0.35) \
	  .set_ease(Tween.EASE_OUT) \
	  .set_trans(Tween.TRANS_BACK)
