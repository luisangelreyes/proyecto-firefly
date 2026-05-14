extends Node2D

# ── CONFIGURACIÓN DEL TABLERO ─────────────────────────────────────────────
const COLS       = 8
const FILAS      = 16
const TAM_BLOQUE = 64   # píxeles por celda
const ORIGEN     = Vector2(208, 64)  # esquina superior izquierda del grid

# ── TIPOS Y COLORES ───────────────────────────────────────────────────────
const TIPOS = ["papel", "vidrio", "plastico", "aluminio"]
const COLORES = {
	"papel":    Color("#F4D03F"),  # amarillo
	"vidrio":   Color("#2ECC71"),  # verde
	"plastico": Color("#3498DB"),  # azul
	"aluminio": Color("#95A5A6"),  # gris
}
const COLOR_VACIO = Color(0.1, 0.1, 0.1, 0.5)

# ── ESTADO DEL TABLERO ────────────────────────────────────────────────────
# grid[fila][col] = "" si vacío, o nombre del tipo si ocupado
var grid: Array = []

# ── ESTADO DE LA PÍLDORA ──────────────────────────────────────────────────
var pildora_tipo_a: String = ""   # bloque izquierdo/arriba
var pildora_tipo_b: String = ""   # bloque derecho/abajo
var pildora_col: int = 3          # columna del bloque A
var pildora_fila: int = 0         # fila del bloque A
var pildora_horizontal: bool = true  # true=horizontal, false=vertical

# ── PROGRESO ─────────────────────────────────────────────────────────────
var botes_llenos: Dictionary = {
	"papel": 0, "vidrio": 0, "plastico": 0, "aluminio": 0
}
const BOTES_POR_TIPO = 4   # cuántos botes hay que llenar por tipo
const BLOQUES_POR_BOTE = 4  # cuántos bloques llena un bote

# ── ESTADO DEL JUEGO ──────────────────────────────────────────────────────
var juego_activo: bool = false
var velocidad_caida: float = 0.8   # segundos entre cada paso hacia abajo
var timer_caida: float = 0.0

func _ready():
	_inicializar_grid()
	_nueva_pildora()
	juego_activo = true
	_dibujar_todo()

# ── INICIALIZACIÓN ────────────────────────────────────────────────────────
func _inicializar_grid():
	grid.clear()
	for f in range(FILAS):
		var fila = []
		for c in range(COLS):
			fila.append("")
		grid.append(fila)

func _nueva_pildora():
	pildora_tipo_a = TIPOS[randi() % TIPOS.size()]
	pildora_tipo_b = TIPOS[randi() % TIPOS.size()]
	pildora_col    = COLS / 2 - 1
	pildora_fila   = 0
	pildora_horizontal = true

	# Verificar game over — si la posición inicial está ocupada
	if not _posicion_valida(pildora_fila, pildora_col, pildora_horizontal):
		_game_over()

# ── LOOP PRINCIPAL ────────────────────────────────────────────────────────
func _process(delta):
	if not juego_activo:
		return

	timer_caida += delta
	if timer_caida >= velocidad_caida:
		timer_caida = 0.0
		_bajar_pildora()

	queue_redraw()

func _input(event):
	if not juego_activo:
		return
	
	if not (event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion):
		return
	
	if event.is_echo():
		return

	if event.is_action_pressed("mover_izquierda"):
		_mover(-1)
	elif event.is_action_pressed("mover_derecha"):
		_mover(1)
	elif event.is_action_pressed("mover_abajo"):
		_bajar_pildora()
	elif event.is_action_pressed("correr"):
		_rotar_pildora()
	elif event.is_action_pressed("mover_arriba"):
		_caida_rapida()
		
# ── MOVIMIENTO ────────────────────────────────────────────────────────────
func _mover(direccion: int):
	var nueva_col = pildora_col + direccion
	if _posicion_valida(pildora_fila, nueva_col, pildora_horizontal):
		pildora_col = nueva_col

func _rotar_pildora():
	var nueva_horizontal = not pildora_horizontal
	if _posicion_valida(pildora_fila, pildora_col, nueva_horizontal):
		pildora_horizontal = nueva_horizontal

func _bajar_pildora():
	if _posicion_valida(pildora_fila + 1, pildora_col, pildora_horizontal):
		pildora_fila += 1
	else:
		_fijar_pildora()

func _caida_rapida():
	while _posicion_valida(pildora_fila + 1, pildora_col, pildora_horizontal):
		pildora_fila += 1
	_fijar_pildora()

# ── VALIDACIÓN DE POSICIÓN ────────────────────────────────────────────────
func _posicion_valida(fila: int, col: int, horizontal: bool) -> bool:
	# Posición del bloque A
	if not _celda_libre(fila, col):
		return false

	# Posición del bloque B
	var fila_b = fila + (0 if horizontal else 1)
	var col_b  = col  + (1 if horizontal else 0)
	if not _celda_libre(fila_b, col_b):
		return false

	return true

func _celda_libre(fila: int, col: int) -> bool:
	if col < 0 or col >= COLS:
		return false
	if fila < 0 or fila >= FILAS:
		return false
	return grid[fila][col] == ""

# ── FIJAR PÍLDORA EN EL GRID ──────────────────────────────────────────────
func _fijar_pildora():
	grid[pildora_fila][pildora_col] = pildora_tipo_a

	var fila_b = pildora_fila + (0 if pildora_horizontal else 1)
	var col_b  = pildora_col  + (1 if pildora_horizontal else 0)
	grid[fila_b][col_b] = pildora_tipo_b

	# Buscar y eliminar grupos de 4+
	var eliminados = _buscar_grupos()

	if eliminados > 0:
		SesionGlobal.puntaje += eliminados * 10
		_verificar_victoria()

	_nueva_pildora()

# ── DETECCIÓN DE GRUPOS DE 4 ──────────────────────────────────────────────
func _buscar_grupos() -> int:
	var a_eliminar: Array = []

	for tipo in TIPOS:
		# Buscar horizontales
		for f in range(FILAS):
			var racha = 0
			var inicio = 0
			for c in range(COLS):
				if grid[f][c] == tipo:
					if racha == 0:
						inicio = c
					racha += 1
				else:
					if racha >= 4:
						for i in range(inicio, c):
							a_eliminar.append(Vector2i(f, i))
					racha = 0
			if racha >= 4:
				for i in range(inicio, COLS):
					a_eliminar.append(Vector2i(f, i))

		# Buscar verticales
		for c in range(COLS):
			var racha = 0
			var inicio = 0
			for f in range(FILAS):
				if grid[f][c] == tipo:
					if racha == 0:
						inicio = f
					racha += 1
				else:
					if racha >= 4:
						for i in range(inicio, f):
							a_eliminar.append(Vector2i(i, c))
					racha = 0
			if racha >= 4:
				for i in range(inicio, FILAS):
					a_eliminar.append(Vector2i(i, c))

	if a_eliminar.is_empty():
		return 0

	# Contabilizar botes por tipo antes de eliminar
	var conteo_tipos: Dictionary = {}
	for pos in a_eliminar:
		var t = grid[pos.x][pos.y]
		if t != "":
			conteo_tipos[t] = conteo_tipos.get(t, 0) + 1

	for tipo in conteo_tipos:
		var bloques = conteo_tipos[tipo]
		var botes_ganados = bloques / BLOQUES_POR_BOTE
		botes_llenos[tipo] = min(
			botes_llenos[tipo] + botes_ganados,
			BOTES_POR_TIPO
		)

	# Eliminar celdas
	for pos in a_eliminar:
		grid[pos.x][pos.y] = ""

	# Aplicar gravedad — los bloques caen al quedar huecos
	_aplicar_gravedad()

	return a_eliminar.size()

# ── GRAVEDAD POST-ELIMINACIÓN ─────────────────────────────────────────────
func _aplicar_gravedad():
	for c in range(COLS):
		for f in range(FILAS - 2, -1, -1):
			if grid[f][c] != "":
				var f_dest = f
				while f_dest + 1 < FILAS and grid[f_dest + 1][c] == "":
					f_dest += 1
				if f_dest != f:
					grid[f_dest][c] = grid[f][c]
					grid[f][c] = ""

# ── GAME OVER Y VICTORIA ──────────────────────────────────────────────────
func _game_over():
	juego_activo = false
	SesionGlobal.guardar_sesion()
	$PantallaGameOver.visible = true
	$PantallaGameOver/Fondo/LabelTitulo.text = "¡GAME OVER!\n%d puntos" % SesionGlobal.puntaje
	$PantallaGameOver/Fondo/BotonReiniciar.grab_focus()

func _verificar_victoria():
	for tipo in TIPOS:
		if botes_llenos[tipo] < BOTES_POR_TIPO:
			return
	# Todos los botes llenos
	juego_activo = false
	SesionGlobal.completar_nivel(1, 3)
	$PantallaVictoria.visible = true
	$PantallaVictoria/Fondo/LabelTitulo.text = "¡NIVEL COMPLETADO!\n%d puntos" % SesionGlobal.puntaje
	$PantallaVictoria/Fondo/BotonSiguiente.grab_focus()

func _on_boton_reiniciar_pressed():
	SesionGlobal.vidas   = 3
	SesionGlobal.puntaje = 0
	get_tree().reload_current_scene()

func _on_boton_siguiente_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/modo_aventura.tscn")

# ── DIBUJO ────────────────────────────────────────────────────────────────
func _draw():
	_dibujar_fondo_grid()
	_dibujar_bloques_fijos()
	_dibujar_pildora_activa()
	_dibujar_sombra()
	_dibujar_botes()

func _dibujar_todo():
	queue_redraw()

func _dibujar_fondo_grid():
	for f in range(FILAS):
		for c in range(COLS):
			var pos = ORIGEN + Vector2(c * TAM_BLOQUE, f * TAM_BLOQUE)
			draw_rect(Rect2(pos, Vector2(TAM_BLOQUE - 2, TAM_BLOQUE - 2)), COLOR_VACIO)

func _dibujar_bloques_fijos():
	for f in range(FILAS):
		for c in range(COLS):
			if grid[f][c] != "":
				_dibujar_bloque(f, c, COLORES[grid[f][c]])

func _dibujar_pildora_activa():
	if not juego_activo and pildora_tipo_a == "":
		return
	_dibujar_bloque(pildora_fila, pildora_col, COLORES[pildora_tipo_a])
	var fila_b = pildora_fila + (0 if pildora_horizontal else 1)
	var col_b  = pildora_col  + (1 if pildora_horizontal else 0)
	_dibujar_bloque(fila_b, col_b, COLORES[pildora_tipo_b])

func _dibujar_sombra():
	# Mostrar dónde caerá la píldora
	var fila_sombra = pildora_fila
	while _posicion_valida(fila_sombra + 1, pildora_col, pildora_horizontal):
		fila_sombra += 1
	if fila_sombra == pildora_fila:
		return
	var col_a = pildora_col
	var col_b = pildora_col + (1 if pildora_horizontal else 0)
	var fila_b = fila_sombra + (0 if pildora_horizontal else 1)
	var pos_a = ORIGEN + Vector2(col_a * TAM_BLOQUE, fila_sombra * TAM_BLOQUE)
	var pos_b = ORIGEN + Vector2(col_b * TAM_BLOQUE, fila_b * TAM_BLOQUE)
	var c_sombra_a = COLORES[pildora_tipo_a]
	var c_sombra_b = COLORES[pildora_tipo_b]
	c_sombra_a.a = 0.25
	c_sombra_b.a = 0.25
	draw_rect(Rect2(pos_a, Vector2(TAM_BLOQUE - 2, TAM_BLOQUE - 2)), c_sombra_a)
	draw_rect(Rect2(pos_b, Vector2(TAM_BLOQUE - 2, TAM_BLOQUE - 2)), c_sombra_b)

func _dibujar_bloque(fila: int, col: int, color: Color):
	var pos = ORIGEN + Vector2(col * TAM_BLOQUE, fila * TAM_BLOQUE)
	var rect = Rect2(pos, Vector2(TAM_BLOQUE - 2, TAM_BLOQUE - 2))
	draw_rect(rect, color)
	# Borde más claro para dar volumen
	var color_borde = color.lightened(0.3)
	draw_rect(rect, color_borde, false, 2.0)

func _dibujar_botes():
	var tipos_ordenados = ["papel", "vidrio", "plastico", "aluminio"]
	var x_inicio = ORIGEN.x + COLS * TAM_BLOQUE + 32
	var y_inicio = ORIGEN.y

	for i in range(tipos_ordenados.size()):
		var tipo = tipos_ordenados[i]
		var x = x_inicio
		var y = y_inicio + i * (BOTES_POR_TIPO * 36 + 24)

		# Etiqueta del tipo
		# (el texto se maneja desde Labels en el HUD, aquí solo los rectángulos)
		for b in range(BOTES_POR_TIPO):
			var bote_rect = Rect2(Vector2(x + b * 44, y), Vector2(36, 28))
			var lleno = b < botes_llenos[tipo]
			draw_rect(bote_rect, COLORES[tipo] if lleno else COLOR_VACIO)
			draw_rect(bote_rect, COLORES[tipo].lightened(0.2), false, 1.5)
