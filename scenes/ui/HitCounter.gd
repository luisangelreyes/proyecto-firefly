extends CanvasLayer

# ── CONFIGURACIÓN ─────────────────────────────────────────────────────────
const TIEMPO_DECAY   = 3.0   # segundos sin atrapar antes de que empiece a desaparecer
const TIEMPO_BLINK   = 1.2   # segundos de parpadeo antes de resetear

# Colores por nivel de racha — igual que SoR4
const COLORES = [
	Color("#FFFFFF"),   # 2-4    blanco
	Color("#FFD700"),   # 5-9    amarillo
	Color("#FF8C00"),   # 10-14  naranja
	Color("#FF3030"),   # 15-19  rojo
	Color("#CC44FF"),   # 20+    morado
]

# Tamaños de fuente por nivel
const TAMANIOS_NUMERO = [64, 72, 82, 92, 104]
const TAMANIOS_HITS   = [40, 46, 52, 58, 66]

# ── ESTADO ────────────────────────────────────────────────────────────────
var racha: int = 0
var decay_timer: float = 0.0
var en_decay: bool = false
var tween_pop: Tween = null
var tween_decay: Tween = null

@onready var lbl_numero = $Contenedor/LabelNumero
@onready var lbl_hits   = $Contenedor/LabelHits

func _ready():
	visible = false

func _process(delta):
	if racha < 2 or not visible:
		return

	decay_timer -= delta

	if decay_timer <= 0 and not en_decay:
		_iniciar_decay()
	elif decay_timer <= -(TIEMPO_BLINK) and en_decay:
		_resetear()

# ── API PÚBLICA ───────────────────────────────────────────────────────────
func registrar_acierto(nueva_racha: int):
	racha = nueva_racha

	if racha < 2:
		visible = false
		return

	# Cancelar decay si estaba activo
	en_decay = false
	decay_timer = TIEMPO_DECAY
	if tween_decay:
		tween_decay.kill()

	visible = true
	_actualizar_visual()
	_animar_pop()

func registrar_fallo():
	_resetear()

# ── VISUAL ────────────────────────────────────────────────────────────────
func _get_nivel() -> int:
	if racha >= 20: return 4
	if racha >= 15: return 3
	if racha >= 10: return 2
	if racha >= 5:  return 1
	return 0

func _actualizar_visual():
	var nivel = _get_nivel()
	var color = COLORES[nivel]

	lbl_numero.text = str(racha)
	lbl_hits.text   = "hits"

	lbl_numero.add_theme_color_override("font_color", color)
	lbl_hits.add_theme_color_override("font_color", color)
	lbl_numero.add_theme_font_size_override("font_size", TAMANIOS_NUMERO[nivel])
	lbl_hits.add_theme_font_size_override("font_size", TAMANIOS_HITS[nivel])

func _animar_pop():
	if tween_pop:
		tween_pop.kill()

	if Configuracion.movimiento_reducido:
		$Contenedor.scale = Vector2.ONE
		return

	# Escala rápida hacia arriba y vuelve — el "pop" de SoR4
	$Contenedor.scale = Vector2(1.3, 1.3)
	tween_pop = create_tween()
	tween_pop.tween_property($Contenedor, "scale", Vector2(1.0, 1.0), 0.12)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)

func _iniciar_decay():
	en_decay = true

	if Configuracion.movimiento_reducido:
		tween_decay = create_tween()
		tween_decay.tween_interval(TIEMPO_BLINK)
		tween_decay.tween_callback(_resetear)
		return

	# Parpadeo + encogimiento gradual
	tween_decay = create_tween().set_loops()
	tween_decay.tween_property($Contenedor, "modulate:a", 0.2, 0.18)
	tween_decay.tween_property($Contenedor, "modulate:a", 1.0, 0.18)

func _resetear():
	racha = 0
	en_decay = false
	decay_timer = 0.0
	if tween_decay:
		tween_decay.kill()
	if tween_pop:
		tween_pop.kill()
	$Contenedor.modulate.a = 1.0
	$Contenedor.scale = Vector2(1.0, 1.0)
	visible = false
