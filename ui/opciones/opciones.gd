extends Control

var opciones = [
	{
		"tipo": "titulo",
		"nombre": "ACCESIBILIDAD"
	},
	{
		"id": "tamano",
		"nombre": "TAMAÑO DE TEXTO",
		"valores": ["Normal", "Grande"],
		"indice": 0,
		"desc": "Ajusta el tamaño del texto para los menús, diálogos y elementos de la interfaz, mejorando la legibilidad general."
	},
	{
		"id": "filtro",
		"nombre": "FILTRO DE COLOR",
		"valores": ["Ninguno", "Deuteranopia", "Protanopia", "Tritanopia"],
		"indice": 0,
		"desc": "Aplica filtros visuales en pantalla para facilitar la diferenciación de colores según el tipo de daltonismo del jugador."
	},
	{
		"id": "movimiento",
		"nombre": "REDUCIR MOVIMIENTO",
		"valores": ["Apagado", "Encendido"],
		"indice": 0,
		"desc": "Reduce los temblores de cámara y animaciones intensas. Recomendado para jugadores propensos a mareos por movimiento."
	},
	{
		"id": "alto_contraste",
		"nombre": "ALTO CONTRASTE",
		"valores": ["Apagado", "Encendido"],
		"indice": 0,
		"desc": "Oscurece dramáticamente los fondos de la ciudad y el tren, resaltando a Eli y los residuos en colores vibrantes para una máxima visibilidad."
	},
	{
		"id": "opacidad_ui",
		"nombre": "OPACIDAD DE INTERFAZ",
		"valores": ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
		"indice": 5,
		"desc": "Ajusta qué tan sólidos se ven los paneles oscuros detrás del texto. 0 es muy transparente, 10 es completamente sólido y negro."
	},
	{
		"tipo": "titulo",
		"nombre": "JUEGO"
	},
	{
		"id": "velocidad",
		"nombre": "VELOCIDAD DEL JUEGO",
		"valores": ["75%", "100%", "125%"],
		"indice": 1,
		"desc": "Modifica la velocidad general con la que caen los residuos. Ajusta el ritmo del juego para un mayor o menor desafío."
	},
	{
		"tipo": "titulo",
		"nombre": "AUDIO Y CONTROLES"
	},
	{
		"id": "vol_general",
		"nombre": "VOLUMEN GENERAL",
		"valores": ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
		"indice": 10,
		"desc": "Ajusta el volumen maestro de todo el juego."
	},
	{
		"id": "vol_musica",
		"nombre": "VOLUMEN MÚSICA",
		"valores": ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
		"indice": 10,
		"desc": "Ajusta únicamente el volumen de la banda sonora de fondo."
	},
	{
		"id": "vol_sfx",
		"nombre": "VOLUMEN EFECTOS",
		"valores": ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
		"indice": 10,
		"desc": "Ajusta el volumen de los efectos de sonido, como los impactos de los residuos y las selecciones en el menú."
	},
	{
		"id": "vibracion",
		"nombre": "VIBRACIÓN DEL MANDO",
		"valores": ["Apagado", "Encendido"],
		"indice": 1,
		"desc": "Activa o desactiva la respuesta háptica (vibración) del control al clasificar residuos correctamente o cometer errores."
	},
	{
		"id": "sensibilidad",
		"nombre": "SENSIBILIDAD DEL PUNTERO",
		"valores": ["Baja", "Normal", "Alta"],
		"indice": 1,
		"desc": "Ajusta la velocidad del puntero virtual del mando en los niveles de clasificación. Baja es más preciso, Alta es más rápido."
	}
]

var fila_nodos = []
var indice_enfocado = 0

var lbl_titulo_desc: Label
var lbl_texto_desc: Label
var scroll_left: ScrollContainer

func _ready():
	_set_indice_opcion("tamano", Configuracion.tamaño_actual)
	_set_indice_opcion("filtro", Configuracion.filtro_actual)
	_set_indice_opcion("movimiento", 1 if Configuracion.movimiento_reducido else 0)
	_set_indice_opcion("alto_contraste", 1 if Configuracion.alto_contraste else 0)
	_set_indice_opcion("opacidad_ui", Configuracion.opacidad_interfaz)
	
	if Configuracion.velocidad_actual == 75: _set_indice_opcion("velocidad", 0)
	elif Configuracion.velocidad_actual == 100: _set_indice_opcion("velocidad", 1)
	elif Configuracion.velocidad_actual == 125: _set_indice_opcion("velocidad", 2)
	
	_set_indice_opcion("vol_general", Configuracion.volumen_general)
	_set_indice_opcion("vol_musica", Configuracion.volumen_musica)
	_set_indice_opcion("vol_sfx", Configuracion.volumen_sfx)
	_set_indice_opcion("vibracion", 1 if Configuracion.vibracion_mando else 0)
	_set_indice_opcion("sensibilidad", Configuracion.sensibilidad_mando)
	
	_construir_interfaz()
	_actualizar_ui()
	_actualizar_descripcion()
	_aplicar_opacidad_local(Configuracion.opacidad_interfaz)

func _set_indice_opcion(id: String, indice: int):
	for op in opciones:
		if op.has("id") and op.id == id:
			op.indice = indice
			return

func _construir_interfaz():
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 150)
	margin.add_theme_constant_override("margin_top", 100)
	margin.add_theme_constant_override("margin_right", 150)
	margin.add_theme_constant_override("margin_bottom", 100)
	add_child(margin)
	
	var vbox_main = VBoxContainer.new()
	margin.add_child(vbox_main)
	
	# Header
	var header = Label.new()
	header.text = "OPCIONES | AJUSTES"
	header.add_theme_font_size_override("font_size", 34)
	header.add_theme_color_override("font_color", Color.WHITE)
	vbox_main.add_child(header)
	
	var separator = ColorRect.new()
	separator.custom_minimum_size = Vector2(0, 2)
	separator.color = Color.WHITE
	vbox_main.add_child(separator)
	
	var spacer_top = Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 40)
	vbox_main.add_child(spacer_top)
	
	# Contenido de dos columnas
	var hbox_content = HBoxContainer.new()
	hbox_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_content.add_theme_constant_override("separation", 50)
	vbox_main.add_child(hbox_content)
	
	# Columna Izquierda: Opciones con Scroll
	scroll_left = ScrollContainer.new()
	scroll_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_left.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	hbox_content.add_child(scroll_left)
	
	var vbox_left = VBoxContainer.new()
	vbox_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_left.add_theme_constant_override("separation", 20) # Aumentado el espacio entre opciones
	scroll_left.add_child(vbox_left)
	
	for i in range(opciones.size()):
		var op = opciones[i]
		
		if op.has("tipo") and op.tipo == "titulo":
			var lbl_titulo = Label.new()
			lbl_titulo.text = op.nombre
			lbl_titulo.add_theme_font_size_override("font_size", 18)
			lbl_titulo.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
			
			var margin_title = MarginContainer.new()
			margin_title.add_theme_constant_override("margin_top", 15)
			margin_title.add_theme_constant_override("margin_bottom", 5)
			margin_title.add_child(lbl_titulo)
			vbox_left.add_child(margin_title)
			continue
			
		var panel_fila = PanelContainer.new()
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0) # Transparente por defecto
		style.border_width_bottom = 1
		style.border_color = Color(1, 1, 1, 0.2)
		style.content_margin_left = 20
		style.content_margin_right = 20
		style.content_margin_top = 15
		style.content_margin_bottom = 15
		panel_fila.add_theme_stylebox_override("panel", style)
		
		var hbox_fila = HBoxContainer.new()
		panel_fila.add_child(hbox_fila)
		
		var lbl_nombre = Label.new()
		lbl_nombre.text = op.nombre
		lbl_nombre.add_theme_font_size_override("font_size", 22)
		lbl_nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox_fila.add_child(lbl_nombre)
		
		var lbl_valor = Label.new()
		lbl_valor.text = "◀  " + op.valores[op.indice] + "  ▶"
		lbl_valor.add_theme_font_size_override("font_size", 22)
		hbox_fila.add_child(lbl_valor)
		
		vbox_left.add_child(panel_fila)
		fila_nodos.append({
			"panel": panel_fila,
			"style": style,
			"lbl_valor": lbl_valor,
			"op": op
		})
	
	# Columna Derecha: Descripción
	var panel_desc = PanelContainer.new()
	panel_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_desc.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	var style_desc = StyleBoxFlat.new()
	style_desc.bg_color = Color(0.05, 0.05, 0.05, 0.8)
	style_desc.border_width_left = 4
	style_desc.border_color = Color.WHITE
	style_desc.content_margin_left = 30
	style_desc.content_margin_right = 30
	style_desc.content_margin_top = 30
	style_desc.content_margin_bottom = 30
	panel_desc.add_theme_stylebox_override("panel", style_desc)
	
	var vbox_desc = VBoxContainer.new()
	vbox_desc.add_theme_constant_override("separation", 15)
	panel_desc.add_child(vbox_desc)
	
	lbl_titulo_desc = Label.new()
	lbl_titulo_desc.add_theme_font_size_override("font_size", 26)
	lbl_titulo_desc.add_theme_color_override("font_color", Color.WHITE)
	vbox_desc.add_child(lbl_titulo_desc)
	
	lbl_texto_desc = Label.new()
	lbl_texto_desc.add_theme_font_size_override("font_size", 20)
	lbl_texto_desc.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	lbl_texto_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox_desc.add_child(lbl_texto_desc)
	
	hbox_content.add_child(panel_desc)
	
	# Footer Navegación
	var footer = HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	margin.add_child(footer)
	
	var nav_label = Label.new()
	nav_label.text = "[▲/▼] Navegar   [◀/▶] Cambiar   [Esc/Atrás] Regresar"
	nav_label.add_theme_font_size_override("font_size", 20)
	nav_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	footer.add_child(nav_label)

var ultimo_movimiento: int = 0

func _unhandled_input(event):
	if not (event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion):
		return
	if event.is_echo():
		return
		
	var tiempo_actual = Time.get_ticks_msec()
		
	if event.is_action_pressed("ui_down") or event.is_action_pressed("mover_abajo"):
		if tiempo_actual - ultimo_movimiento > 200:
			indice_enfocado = min(indice_enfocado + 1, fila_nodos.size() - 1)
			_actualizar_ui()
			_actualizar_descripcion()
			ultimo_movimiento = tiempo_actual
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("mover_arriba"):
		if tiempo_actual - ultimo_movimiento > 200:
			indice_enfocado = max(indice_enfocado - 1, 0)
			_actualizar_ui()
			_actualizar_descripcion()
			ultimo_movimiento = tiempo_actual
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("mover_izquierda"):
		if tiempo_actual - ultimo_movimiento > 200:
			_cambiar_valor(-1)
			ultimo_movimiento = tiempo_actual
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("mover_derecha"):
		if tiempo_actual - ultimo_movimiento > 200:
			_cambiar_valor(1)
			ultimo_movimiento = tiempo_actual
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("pausar") or (event is InputEventJoypadButton and event.button_index == JOY_BUTTON_B):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://ui/menu/menu.tscn")

func _cambiar_valor(direccion: int):
	var op = fila_nodos[indice_enfocado].op
	op.indice = clamp(op.indice + direccion, 0, op.valores.size() - 1)
	
	_aplicar_cambio_configuracion(op.id, op.indice)
	_actualizar_ui()

func _aplicar_cambio_configuracion(id: String, indice: int):
	match id:
		"tamano":
			Configuracion.set_tamaño_fuente(indice)
		"filtro":
			Configuracion.set_filtro_color(indice)
		"movimiento":
			Configuracion.set_movimiento_reducido(indice == 1)
		"alto_contraste":
			Configuracion.set_alto_contraste(indice == 1)
		"opacidad_ui":
			Configuracion.set_opacidad_interfaz(indice)
			_aplicar_opacidad_local(indice)
		"velocidad":
			var vel = 100
			if indice == 0: vel = 75
			elif indice == 1: vel = 100
			elif indice == 2: vel = 125
			Configuracion.set_velocidad_juego(vel)
		"vol_general":
			Configuracion.set_volumen_general(indice)
		"vol_musica":
			Configuracion.set_volumen_musica(indice)
		"vol_sfx":
			Configuracion.set_volumen_sfx(indice)
		"vibracion":
			Configuracion.set_vibracion_mando(indice == 1)
		"sensibilidad":
			Configuracion.set_sensibilidad_mando(indice)

func _actualizar_ui():
	for i in range(fila_nodos.size()):
		var nodo = fila_nodos[i]
		var op = nodo.op
		
		if i == indice_enfocado:
			nodo.style.bg_color = Color.WHITE
			nodo.lbl_valor.add_theme_color_override("font_color", Color.BLACK)
			nodo.panel.get_child(0).get_child(0).add_theme_color_override("font_color", Color.BLACK) # lbl_nombre
			scroll_left.ensure_control_visible(nodo.panel)
		else:
			nodo.style.bg_color = Color(0, 0, 0, 0)
			nodo.lbl_valor.add_theme_color_override("font_color", Color.WHITE)
			nodo.panel.get_child(0).get_child(0).add_theme_color_override("font_color", Color.WHITE)
			
		var text_val = op.valores[op.indice]
		if op.indice == op.valores.size() - 1:
			nodo.lbl_valor.text = "◀  " + text_val + "   "
		elif op.indice == 0:
			nodo.lbl_valor.text = "   " + text_val + "  ▶"
		else:
			nodo.lbl_valor.text = "◀  " + text_val + "  ▶"

func _actualizar_descripcion():
	var op = fila_nodos[indice_enfocado].op
	lbl_titulo_desc.text = op.nombre
	lbl_texto_desc.text = op.desc

func _aplicar_opacidad_local(valor: int):
	var alpha = float(valor) / 10.0
	# Limitar a un mínimo de 0.2 y máximo de 1.0 para que no sea totalmente invisible
	alpha = clamp(alpha, 0.2, 1.0)
	
	# Opacidad del fondo de la descripción
	var desc_panel = lbl_titulo_desc.get_parent().get_parent()
	var desc_style = desc_panel.get_theme_stylebox("panel")
	if desc_style:
		desc_style.bg_color = Color(0.05, 0.05, 0.05, alpha * 0.9) # Un poco más transparente que sólido
		
	# Opacidad del color rect oscurecedor general
	var bg_dim = get_node_or_null("ColorRect")
	if bg_dim:
		bg_dim.color = Color(0, 0, 0, alpha * 0.8)
