extends Node2D

# ── SEÑALES ───────────────────────────────────────────────────────────────────
signal patron_completado
signal golpeado
signal animacion_lista

# ── ESTADO INTERNO ────────────────────────────────────────────────────────────
enum Estado { IDLE, MOVIENDOSE, ATACANDO, BAJANDO, EXPUESTO, SUBIENDO }
var estado: Estado = Estado.IDLE

var fase_actual: int = 1
var hp: int = 3

# ── REFERENCIAS ───────────────────────────────────────────────────────────────
@onready var sprite = $Sprite2D
@onready var pos_objetivo = Vector2(960, 80)

var escena_basura          = preload("res://entities/basura/basura.tscn")
var escena_residuo_gigante = preload("res://entities/basura/ResiduoGigante.tscn")

const Y_REPOSO      = 80.0
const Y_EXPUESTO    = 820.0
const VELOCIDAD_MOV = 420.0

signal _residuo_spawneado(nodo)

# ──────────────────────────────────────────────────────────────────────────────
func _ready():
	# Empieza abajo, fuera de la vista del jugador
	position = Vector2(960, 1000) 
	_aplicar_visual_hp()

func _process(delta):
	if estado == Estado.MOVIENDOSE:
		var dist = pos_objetivo.x - position.x
		if abs(dist) < 4.0:
			position.x = pos_objetivo.x
			estado = Estado.IDLE
			animacion_lista.emit()
		else:
			position.x += sign(dist) * VELOCIDAD_MOV * delta

# ── API PÚBLICA ────────────────────────────────────────────────────────────────
func iniciar_fase(n: int):
	fase_actual = n
	_aplicar_visual_hp()
	match n:
		1: _ejecutar_patron_1()
		2: _ejecutar_patron_2()
		3: _ejecutar_patron_3()

func bajar():
	estado = Estado.BAJANDO
	var tween = create_tween()
	tween.tween_property(self, "position:y", Y_EXPUESTO, 0.6).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		estado = Estado.EXPUESTO
		animacion_lista.emit()
	)

func subir():
	estado = Estado.SUBIENDO
	var tween = create_tween()
	tween.tween_property(self, "position:y", Y_REPOSO, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		estado = Estado.IDLE
		animacion_lista.emit()
	)

func verificar_golpe(barbara_x: float) -> bool:
	if estado != Estado.EXPUESTO:
		return false
	if abs(barbara_x - position.x) <= 160.0:
		_recibir_golpe()
		return true
	return false

# ── HELPER: mover con tween sin tocar estado ni emitir señales ────────────────
# Usado dentro de los patrones para no interferir con animacion_lista
func _mover_suave(x: float, duracion: float):
	var tw = create_tween()
	tw.tween_property(self, "position:x", x, duracion).set_ease(Tween.EASE_IN_OUT)
	await tw.finished

# ── PATRONES DE ATAQUE ────────────────────────────────────────────────────────

# FASE 1 — Lluvia en línea: cruza la pantalla de izq a der tirando basura
func _ejecutar_patron_1():
	estado = Estado.ATACANDO
	var paso = 1100.0 / 10.0
	for i in range(10):
		if estado != Estado.ATACANDO:
			return
		var x = 200.0 + i * paso
		await _mover_suave(x, 0.30)
		if estado != Estado.ATACANDO:
			return
		_spawn_basura(position.x, false)
		await get_tree().create_timer(0.45).timeout
	if estado == Estado.ATACANDO:
		patron_completado.emit()

# FASE 2 — Descarga en ráfaga: se detiene en el centro y tira abanico 3 veces
func _ejecutar_patron_2():
	estado = Estado.ATACANDO
	await _mover_suave(960.0, 0.4)
	for _i in range(3):
		if estado != Estado.ATACANDO:
			return
		await _tirar_rafaga(5)
		await get_tree().create_timer(1.1).timeout
	if estado == Estado.ATACANDO:
		patron_completado.emit()

# FASE 3 — Caos tóxico: movimiento errático + residuo gigante al final
func _ejecutar_patron_3():
	estado = Estado.ATACANDO
	for _i in range(4):
		if estado != Estado.ATACANDO:
			return
		var dest_x = randf_range(200.0, 1720.0)
		await _mover_suave(dest_x, 0.35)
		await _tirar_caos(4)
		await get_tree().create_timer(0.4).timeout
	if estado != Estado.ATACANDO:
		return
	await _tirar_residuo_gigante()
	if estado == Estado.ATACANDO:
		patron_completado.emit()

# ── HELPERS DE SPAWN ──────────────────────────────────────────────────────────

func _tirar_rafaga(cantidad: int):
	var separacion = 160.0
	var inicio_x   = position.x - separacion * (cantidad / 2.0)
	for i in range(cantidad):
		if estado != Estado.ATACANDO:
			return
		var x = inicio_x + i * separacion
		var forzar_peligroso = (i == int(cantidad / 2.0))
		_spawn_basura(clamp(x, 80.0, 1840.0), forzar_peligroso)
		await get_tree().create_timer(0.12).timeout

func _tirar_caos(cantidad: int):
	for _i in range(cantidad):
		if estado != Estado.ATACANDO:
			return
		var x = position.x + randf_range(-220.0, 220.0)
		_spawn_basura(clamp(x, 80.0, 1840.0), false, 0.40)
		await get_tree().create_timer(0.22).timeout

func _tirar_residuo_gigante():
	await get_tree().create_timer(0.5).timeout
	if estado != Estado.ATACANDO:
		return
	var gigante = escena_residuo_gigante.instantiate()
	gigante.position = Vector2(position.x, position.y + 60)
	get_parent().add_child(gigante)
	_residuo_spawneado.emit(gigante)
	await get_tree().create_timer(0.8).timeout

# ── SPAWN INDIVIDUAL ──────────────────────────────────────────────────────────
func _spawn_basura(x: float, forzar_peligroso: bool, prob_peligroso: float = 0.20):
	if estado != Estado.ATACANDO:
		return
	var basura = escena_basura.instantiate()
	basura.position = Vector2(x, position.y + 60)
	if forzar_peligroso:
		basura.prob_peligroso = 1.0
	else:
		basura.prob_peligroso = prob_peligroso
	basura.velocidad_caida = 320.0 + fase_actual * 40.0
	get_parent().add_child(basura)
	_residuo_spawneado.emit(basura)

# ── DAÑO Y VISUAL ─────────────────────────────────────────────────────────────
func _recibir_golpe():
	hp -= 1
	golpeado.emit()
	_flash_dano()

func _flash_dano():
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 0.0, 0.0, 1.0), 0.05)
	tween.tween_interval(0.3)
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25)

func _aplicar_visual_hp():
	match hp:
		3: sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		2: sprite.modulate = Color(1.0, 0.85, 0.3, 1.0)
		1: sprite.modulate = Color(1.0, 0.4, 0.1, 1.0)

# ── CUTSCENE DE DERROTA ───────────────────────────────────────────────────────
func ejecutar_derrota():
	estado = Estado.IDLE
	var suelo_y = 900.0   # ajusta si tu suelo está en otra Y

	var tween = create_tween()

	# 1. Tambaleo inicial — el platillo empieza a perder control
	tween.tween_property(self, "rotation_degrees", 25.0, 0.5).set_ease(Tween.EASE_IN)

	# 2. Caída al suelo con giro
	tween.tween_property(self, "position", Vector2(position.x + 180, suelo_y), 1.2).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "rotation_degrees", 180.0, 1.2).set_ease(Tween.EASE_IN)

	# 3. Rebote al impactar
	tween.tween_property(self, "position:y", suelo_y - 40, 0.18).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", suelo_y,      0.18).set_ease(Tween.EASE_IN)

	# 4. Rebote más pequeño
	tween.tween_property(self, "position:y", suelo_y - 16, 0.12).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", suelo_y,      0.12).set_ease(Tween.EASE_IN)

	# 5. Se queda torcido y oscuro en el suelo — sin queue_free()
	tween.tween_property(self, "rotation_degrees", 160.0, 0.3).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "modulate", Color(0.25, 0.25, 0.25, 1.0), 0.3)

	await tween.finished
	# El nodo queda en escena para que Barbara celebre sobre él
# ── CINEMÁTICA DE ENTRADA ─────────────────────────────────────────────────────
# ── CINEMÁTICA DE ENTRADA ─────────────────────────────────────────────────────
func entrada_cinematica(duracion: float):
	# 🔴 FIX: Usamos SUBIENDO para que el _process no interfiera
	estado = Estado.SUBIENDO 
	
	var tween = create_tween()
	tween.tween_property(self, "position:y", Y_REPOSO, duracion)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
		
	tween.tween_callback(func():
		estado = Estado.IDLE 
	)
