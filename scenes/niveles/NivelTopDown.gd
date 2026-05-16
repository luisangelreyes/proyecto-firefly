extends Node2D

const TIEMPO_LIMITE: float = 90.0

var tiempo_restante: float = TIEMPO_LIMITE
var timer_activo: bool = false
var juego_activo: bool = false
var total_residuos: int = 0
var recogidos: int = 0
@export var escena_residuo: PackedScene  # Aquí arrastraremos ResiduoTopDown.tscn en el inspector
@onready var contenedor_zonas = $Mundo/ZonasSpawn
var sprite_sheet_residuos = preload("res://entities/basura/sprites/basura_in_or_pelirgo.png") # <-- Pon tu ruta real
# Lista de basuras posibles con las rutas de tus iconos (ajusta las rutas a tus archivos reales)
var catalogo_basura = [
	# --- INORGÁNICOS (Azul) ---
	{"tipo": "inorganico", "nombre": "lata_aplastada",  "region": Rect2(0, 0, 800, 800)},       # Fila 1, Col 1
	{"tipo": "inorganico", "nombre": "botella_plastico","region": Rect2(800, 0, 800, 800)},     # Fila 1, Col 2
	{"tipo": "inorganico", "nombre": "caja_leche",      "region": Rect2(1600, 0, 800, 800)},    # Fila 1, Col 3
	{"tipo": "inorganico", "nombre": "bolsa_basura",    "region": Rect2(2400, 0, 800, 800)},    # Fila 1, Col 4
	{"tipo": "inorganico", "nombre": "periodico",       "region": Rect2(4000, 0, 800, 800)},    # Fila 1, Col 6
	{"tipo": "inorganico", "nombre": "caja_carton",     "region": Rect2(4800, 0, 800, 800)},    # Fila 1, Col 7
	{"tipo": "inorganico", "nombre": "cd_viejo",        "region": Rect2(2400, 800, 800, 800)},  # Fila 2, Col 4
	
	# --- ORGÁNICOS (Verde) ---
	{"tipo": "organico",   "nombre": "manzana",         "region": Rect2(2400, 2400, 800, 800)}, # Fila 4, Col 4
	{"tipo": "organico",   "nombre": "platano",         "region": Rect2(1600, 3200, 800, 800)}, # Fila 5, Col 3
	{"tipo": "organico",   "nombre": "hueso",           "region": Rect2(3200, 3200, 800, 800)}, # Fila 5, Col 5
	{"tipo": "organico",   "nombre": "sandia",          "region": Rect2(4800, 1600, 800, 800)}, # Fila 3, Col 7
	{"tipo": "organico",   "nombre": "elote",           "region": Rect2(0, 2400, 800, 800)},    # Fila 4, Col 1
	{"tipo": "organico",   "nombre": "naranja",         "region": Rect2(4800, 2400, 800, 800)}, # Fila 4, Col 7
	{"tipo": "organico",   "nombre": "cascara_huevo",   "region": Rect2(4000, 3200, 800, 800)}, # Fila 5, Col 6
	{"tipo": "organico",   "nombre": "espinas_pez",     "region": Rect2(1600, 4000, 800, 800)}, # Fila 6, Col 3
	
	# --- PELIGROSOS (Rojo / Enemigos) ---
	{"tipo": "peligroso",  "nombre": "bateria",         "region": Rect2(4000, 4000, 800, 800)}, # Fila 6, Col 6
	{"tipo": "peligroso",  "nombre": "jeringa",         "region": Rect2(4800, 4000, 800, 800)}, # Fila 6, Col 7
	{"tipo": "peligroso",  "nombre": "foco_roto",       "region": Rect2(800, 4800, 800, 800)},  # Fila 7, Col 2
	{"tipo": "peligroso",  "nombre": "cigarro",         "region": Rect2(0, 4800, 800, 800)},    # Fila 7, Col 1
	{"tipo": "peligroso",  "nombre": "lata_aerosol",    "region": Rect2(1600, 4800, 800, 800)}, # Fila 7, Col 3
	{"tipo": "peligroso",  "nombre": "bidon_veneno",    "region": Rect2(2400, 4800, 800, 800)}, # Fila 7, Col 4
	{"tipo": "peligroso",  "nombre": "cristal_roto",    "region": Rect2(3200, 4800, 800, 800)}, # Fila 7, Col 5
	{"tipo": "peligroso",  "nombre": "clavo_oxidado",   "region": Rect2(4800, 4800, 800, 800)}  # Fila 7, Col 7
]

@onready var eli              = $Mundo/Eli
@onready var barra_tiempo     = $HUD/BarraTiempo
@onready var lbl_tiempo       = $HUD/LabelTiempo
@onready var lbl_bote         = $HUD/LabelBote
@onready var lbl_residuos     = $HUD/LabelResiduos
@onready var pantalla_result  = $PantallaResultados
@onready var contenedor_res   = $Mundo/Residuos

const NOMBRES_BOTE = ["Orgánico", "Inorgánico"]
const COLOR_BOTE   = [Color("#4fb87a"), Color("#4a8fd4")]

func _ready():
	SesionGlobal.vidas   = 1   
	SesionGlobal.puntaje = 0

	pantalla_result.visible = false
	barra_tiempo.max_value  = TIEMPO_LIMITE
	barra_tiempo.value      = TIEMPO_LIMITE
	
	# --- AQUÍ ESTÁ LA MAGIA DEL EXPERIMENTO ---
	# Generamos solo 10 basuras normales (para ganar)
	_generar_residuos_aleatorios(10, "normal") 
	
	# ¡Y lo llenamos con 40 peligrosos patrullando!
	_generar_residuos_aleatorios(40, "peligroso")
	# Contar residuos y conectar señales
	for residuo in contenedor_res.get_children():
		if residuo.is_in_group("residuo_td"):
			if residuo.tipo != "peligroso":
				total_residuos += 1
			residuo.recogido_correcto.connect(_on_residuo_correcto)
			residuo.recogido_incorrecto.connect(_on_residuo_incorrecto)
			residuo.peligroso_tocado.connect(_on_peligroso_tocado)

	# Conectar Eli
	eli.recogida_intentada.connect(_on_recogida_intentada)

	# Conectar pausa
	$PantallaPausa.reiniciar_presionado.connect(_reiniciar)
	$PantallaPausa.menu_presionado.connect(_ir_menu)

	lbl_residuos.text = "Residuos: 0 / %d" % total_residuos
	_actualizar_bote()

	await get_tree().create_timer(0.5).timeout
	if is_inside_tree():
		juego_activo = true
		timer_activo = true

func _process(delta):
	if not juego_activo or not timer_activo:
		return

	tiempo_restante -= delta
	tiempo_restante  = max(0, tiempo_restante)

	barra_tiempo.value = tiempo_restante
	lbl_tiempo.text    = "%d" % ceil(tiempo_restante)

	# Color de barra según urgencia
	if tiempo_restante <= 10:
		barra_tiempo.modulate = Color("#f87171")
	elif tiempo_restante <= 25:
		barra_tiempo.modulate = Color("#fbbf24")
	else:
		barra_tiempo.modulate = Color("#86efac")

	# Actualizar bote en HUD
	_actualizar_bote()

	if tiempo_restante <= 0:
		_tiempo_agotado()

func _actualizar_bote():
	lbl_bote.text = "Bote: " + NOMBRES_BOTE[eli.bote_activo]
	lbl_bote.add_theme_color_override("font_color", COLOR_BOTE[eli.bote_activo])

func _on_recogida_intentada(_tipo: String, _bote: int):
	pass   # por ahora solo para debug

func _on_residuo_correcto(_tipo: String):
	recogidos += 1
	SesionGlobal.puntaje += 10
	lbl_residuos.text = "Residuos: %d / %d" % [recogidos, total_residuos]
	if recogidos >= total_residuos:
		_victoria()

func _on_residuo_incorrecto(_tipo: String):
	_game_over("¡Bote incorrecto!\nEl nivel reinicia.")

func _on_peligroso_tocado():
	_game_over("¡Residuo peligroso!\nEl nivel reinicia.")

func _tiempo_agotado():
	_game_over("¡Tiempo agotado!\nEl nivel reinicia.")

func _game_over(mensaje: String):
	juego_activo = false
	timer_activo = false
	SesionGlobal.guardar_sesion()
	
	await get_tree().create_timer(0.3).timeout 
	
	if not is_inside_tree():
		return
	_mostrar_resultado(mensaje, false)
func _victoria():
	juego_activo = false
	timer_activo = false
	SesionGlobal.completar_nivel(2, 5)
	SesionGlobal.guardar_sesion()
	_mostrar_resultado("¡Zona limpia!", true)

func _mostrar_resultado(titulo: String, victoria: bool):
	pantalla_result.visible = true
	$PantallaResultados/Fondo/LabelTitulo.text = titulo

	var color = Color("#4fb87a") if victoria else Color("#f87171")
	$PantallaResultados/Fondo/LabelTitulo.add_theme_color_override("font_color", color)

	$PantallaResultados/Fondo/LabelResiduos.text = \
		"Residuos recogidos: %d / %d" % [recogidos, total_residuos]
	$PantallaResultados/Fondo/LabelTiempo.text = \
		"Tiempo restante: %d s" % int(tiempo_restante)

	$PantallaResultados/Fondo/BotonSiguiente.text = \
		"Continuar" if victoria else "Reintentar"
	$PantallaResultados/Fondo/BotonSiguiente.grab_focus()
	$PantallaResultados/Fondo/BotonSiguiente.pressed.connect(_on_boton_resultado)

func _on_boton_resultado():
	if juego_activo == false and recogidos >= total_residuos:
		Engine.get_main_loop().change_scene_to_file(
            "res://scenes/menu/ModoAventura.tscn"
		)
	else:
		Engine.get_main_loop().change_scene_to_file(
            "res://scenes/niveles/NivelTopDown.tscn"
		)

func _reiniciar():
	Engine.get_main_loop().change_scene_to_file(
        "res://scenes/niveles/NivelTopDown.tscn"
	)

func _ir_menu():
	Engine.get_main_loop().change_scene_to_file(
        "res://scenes/menu/menu.tscn"
	)
	
func _generar_residuos_aleatorios(cantidad: int, filtro: String = "todos"):
	var generados = 0
	var space_state = get_world_2d().direct_space_state
	var zonas = contenedor_zonas.get_children() 
	
	if zonas.is_empty():
		return
		
	var catalogo_filtrado = []
	for item in catalogo_basura:
		if filtro == "todos":
			catalogo_filtrado.append(item)
		elif filtro == "peligroso" and item["tipo"] == "peligroso":
			catalogo_filtrado.append(item)
		elif filtro == "normal" and item["tipo"] != "peligroso":
			catalogo_filtrado.append(item)
		
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 25.0 
	query.shape = shape
	
	var intentos_maximos = cantidad * 50 
	var intentos = 0
	var posiciones_usadas: Array[Vector2] = []
	var distancia_minima = 90.0 
	
	# --- NUEVA VARIABLE: Radio de la zona segura ---
	# 200 píxeles a la redonda le darán a Liz suficiente espacio libre al aparecer
	var radio_zona_segura = 200.0 

	while generados < cantidad and intentos < intentos_maximos:
		intentos += 1
		
		var zona_elegida = zonas.pick_random()
		var rect = zona_elegida.get_global_rect()
		
		var pos_x = randf_range(rect.position.x, rect.end.x)
		var pos_y = randf_range(rect.position.y, rect.end.y)
		var punto_aleatorio = Vector2(pos_x, pos_y)
		
		# --- 1. NUEVO: COMPROBAR DISTANCIA CON LIZ ---
		# Usamos la referencia a tu nodo del personaje (ajusta 'eli' si tu variable se llama distinto)
		if punto_aleatorio.distance_to(eli.global_position) < radio_zona_segura:
			continue # Demasiado cerca de Liz, saltamos este intento para protegerla
		# ----------------------------------------------
		
		var choca_con_basura = false
		for pos_guardada in posiciones_usadas:
			if punto_aleatorio.distance_to(pos_guardada) < distancia_minima:
				choca_con_basura = true
				break 
				
		if choca_con_basura:
			continue 
		
		query.transform = Transform2D(0, punto_aleatorio)
		var colisiones = space_state.intersect_shape(query)
		
		if colisiones.is_empty():
			var nuevo_residuo = escena_residuo.instantiate()
			nuevo_residuo.global_position = punto_aleatorio
			nuevo_residuo.scale = Vector2(0.3, 0.3) 
			
			var data = catalogo_filtrado.pick_random()
			nuevo_residuo.tipo = data["tipo"]
			nuevo_residuo.nombre = data["nombre"]
			
			var textura_recortada = AtlasTexture.new()
			textura_recortada.atlas = sprite_sheet_residuos
			textura_recortada.region = data["region"] 
			
			nuevo_residuo.icono = textura_recortada
			
			contenedor_res.add_child(nuevo_residuo)
			posiciones_usadas.append(punto_aleatorio)
			generados += 1
