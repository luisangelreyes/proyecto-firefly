# configuracion.gd - Autoload
extends Node

signal tamaño_cambiado(nuevo_tamaño: String, valor_activo: int, valor_inactivo: int)
signal filtro_cambiado(tipo: int)
signal movimiento_reducido_cambiado(valor: bool)
signal velocidad_cambiado(valor: int)
signal alto_contraste_cambiado(valor: bool)
signal opacidad_interfaz_cambiada(valor: int)

enum TamañoFuente { NORMAL, GRANDE }
enum FiltroColor { NINGUNO, DEUTERANOPIA, PROTANOPIA, TRITANOPIA }

const VELOCIDAD_75 := 75
const VELOCIDAD_100 := 100
const VELOCIDAD_125 := 125

const TAMAÑOS = {
	TamañoFuente.NORMAL:  {"activo": 32, "inactivo": 26},
	TamañoFuente.GRANDE:  {"activo": 42, "inactivo": 36}
}

var tamaño_actual: int = TamañoFuente.NORMAL
var filtro_actual: int = FiltroColor.NINGUNO
var movimiento_reducido: bool = false
var velocidad_actual: int = VELOCIDAD_100

var volumen_general: int = 10
var volumen_musica: int = 10
var volumen_sfx: int = 10
var vibracion_mando: bool = true

var alto_contraste: bool = false
var opacidad_interfaz: int = 10 # Default to 10 (100%)

var _overlay_layer: CanvasLayer
var _overlay_rect: ColorRect
var _shader_material: ShaderMaterial

func _ready():
	_configurar_buses_audio()
	cargar_configuracion()
	aplicar_tamaño_actual()
	_crear_overlay()
	aplicar_filtro_actual()
	get_tree().node_added.connect(_on_node_added)

func _configurar_buses_audio():
	# Crear buses de música y sfx si no existen
	var _idx_master = AudioServer.get_bus_index("Master")
	
	if AudioServer.get_bus_index("Musica") == -1:
		AudioServer.add_bus()
		var idx_musica = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(idx_musica, "Musica")
		AudioServer.set_bus_send(idx_musica, "Master")
		
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		var idx_sfx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(idx_sfx, "SFX")
		AudioServer.set_bus_send(idx_sfx, "Master")

func _on_node_added(node: Node):
	if node is Control:
		# Call deferred to ensure the node has completed its setup
		call_deferred("_escalar_nodo_control", node)

func set_tamaño_fuente(nuevo_tamaño: int):
	tamaño_actual = nuevo_tamaño
	guardar_configuracion()
	aplicar_tamaño_actual()

func get_tamaño_activo() -> int:
	return TAMAÑOS[tamaño_actual]["activo"]

func get_tamaño_inactivo() -> int:
	return TAMAÑOS[tamaño_actual]["inactivo"]

func get_nombre_tamaño() -> String:
	match tamaño_actual:
		TamañoFuente.NORMAL:
			return "Normal"
		TamañoFuente.GRANDE:
			return "Grande"
	return "Normal"

func aplicar_tamaño_actual():
	var valores = TAMAÑOS[tamaño_actual]
	emit_signal("tamaño_cambiado", get_nombre_tamaño(), valores["activo"], valores["inactivo"])
	_escalar_fuentes_escena()

func get_factor_tamaño() -> float:
	match tamaño_actual:
		TamañoFuente.NORMAL: return 1.0
		TamañoFuente.GRANDE: return 1.25
	return 1.0

func _escalar_fuentes_escena():
	var root = get_tree().root
	_aplicar_escala_recursiva(root)

func _aplicar_escala_recursiva(nodo: Node):
	if nodo is Control:
		_escalar_nodo_control(nodo)
	for hijo in nodo.get_children():
		_aplicar_escala_recursiva(hijo)

func _escalar_nodo_control(control: Control):
	# Evitar afectar los labels que ya usan LabelConfigurable.gd para evitar doble escalado
	if control.has_method("_on_cambio_tamaño") and control.get_script() != null and "LabelConfigurable" in control.get_script().resource_path:
		return

	var propiedades_fuente = [
		"font_size", "normal_font_size", "bold_font_size", 
		"italics_font_size", "bold_italics_font_size", "mono_font_size"
	]
	
	for prop in propiedades_fuente:
		var meta_name = "original_" + prop
		if control.has_meta(meta_name):
			var original = control.get_meta(meta_name)
			control.add_theme_font_size_override(prop, int(original * get_factor_tamaño()))
		else:
			# Extrae el tamaño por defecto si no tiene override y lo guarda como original
			var size = control.get_theme_font_size(prop)
			if size > 0: # Solo si la fuente está configurada
				control.set_meta(meta_name, size)
				control.add_theme_font_size_override(prop, int(size * get_factor_tamaño()))
func set_filtro_color(nuevo_filtro: int):
	filtro_actual = nuevo_filtro
	guardar_configuracion()
	aplicar_filtro_actual()

func get_nombre_filtro() -> String:
	match filtro_actual:
		FiltroColor.NINGUNO:
			return "Ninguno"
		FiltroColor.DEUTERANOPIA:
			return "Deuteranopia"
		FiltroColor.PROTANOPIA:
			return "Protanopia"
		FiltroColor.TRITANOPIA:
			return "Tritanopia"
	return "Ninguno"

func set_movimiento_reducido(valor: bool):
	movimiento_reducido = valor
	guardar_configuracion()
	emit_signal("movimiento_reducido_cambiado", valor)

func set_velocidad_juego(porcentaje: int):
	if porcentaje not in [VELOCIDAD_75, VELOCIDAD_100, VELOCIDAD_125]:
		return
	velocidad_actual = porcentaje
	Engine.time_scale = porcentaje / 100.0
	guardar_configuracion()
	emit_signal("velocidad_cambiado", porcentaje)

func get_nombre_velocidad() -> String:
	return str(velocidad_actual) + "%"

func aplicar_filtro_actual():
	if _shader_material:
		_shader_material.set_shader_parameter("filtro_tipo", filtro_actual)
	emit_signal("filtro_cambiado", filtro_actual)

func _crear_overlay():
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 128
	add_child(_overlay_layer)

	_overlay_rect = ColorRect.new()
	_overlay_rect.anchor_left = 0.0
	_overlay_rect.anchor_top = 0.0
	_overlay_rect.anchor_right = 1.0
	_overlay_rect.anchor_bottom = 1.0
	_overlay_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_rect.color = Color.WHITE
	_overlay_layer.add_child(_overlay_rect)

	_shader_material = ShaderMaterial.new()
	_shader_material.shader = preload("res://shaders/filtro_color.gdshader")
	_overlay_rect.material = _shader_material

func guardar_configuracion():
	var config = ConfigFile.new()
	config.set_value("accesibilidad", "tamaño_fuente", tamaño_actual)
	config.set_value("accesibilidad", "filtro_color", filtro_actual)
	config.set_value("accesibilidad", "movimiento_reducido", movimiento_reducido)
	config.set_value("accesibilidad", "velocidad_juego", velocidad_actual)
	config.set_value("accesibilidad", "alto_contraste", alto_contraste)
	config.set_value("accesibilidad", "opacidad_interfaz", opacidad_interfaz)
	
	config.set_value("audio", "volumen_general", volumen_general)
	config.set_value("audio", "volumen_musica", volumen_musica)
	config.set_value("audio", "volumen_sfx", volumen_sfx)
	config.set_value("controles", "vibracion_mando", vibracion_mando)
	
	config.save("user://configuracion.cfg")

func cargar_configuracion():
	var config = ConfigFile.new()
	if config.load("user://configuracion.cfg") == OK:
		tamaño_actual = config.get_value("accesibilidad", "tamaño_fuente", TamañoFuente.NORMAL)
		filtro_actual = config.get_value("accesibilidad", "filtro_color", FiltroColor.NINGUNO)
		movimiento_reducido = config.get_value("accesibilidad", "movimiento_reducido", false)
		velocidad_actual = config.get_value("accesibilidad", "velocidad_juego", VELOCIDAD_100)
		alto_contraste = config.get_value("accesibilidad", "alto_contraste", false)
		opacidad_interfaz = config.get_value("accesibilidad", "opacidad_interfaz", 5)
		
		volumen_general = config.get_value("audio", "volumen_general", 10)
		volumen_musica = config.get_value("audio", "volumen_musica", 10)
		volumen_sfx = config.get_value("audio", "volumen_sfx", 10)
		vibracion_mando = config.get_value("controles", "vibracion_mando", true)
		
	Engine.time_scale = velocidad_actual / 100.0
	
	_aplicar_volumen("Master", volumen_general)
	_aplicar_volumen("Musica", volumen_musica)
	_aplicar_volumen("SFX", volumen_sfx)

func set_volumen_general(valor: int):
	volumen_general = valor
	_aplicar_volumen("Master", valor)
	guardar_configuracion()

func set_volumen_musica(valor: int):
	volumen_musica = valor
	_aplicar_volumen("Musica", valor)
	guardar_configuracion()

func set_volumen_sfx(valor: int):
	volumen_sfx = valor
	_aplicar_volumen("SFX", valor)
	guardar_configuracion()

func _aplicar_volumen(bus_name: String, valor: int):
	var idx = AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		if valor == 0:
			AudioServer.set_bus_mute(idx, true)
		else:
			AudioServer.set_bus_mute(idx, false)
			# Convertir 1-10 a decibelios. 10 = 0dB. 1 = -40dB
			var db = linear_to_db(float(valor) / 10.0)
			AudioServer.set_bus_volume_db(idx, db)

func set_vibracion_mando(valor: bool):
	vibracion_mando = valor
	guardar_configuracion()
	if valor:
		# Vibrar un poco de prueba
		Input.start_joy_vibration(0, 0.5, 0.5, 0.2)

func set_alto_contraste(valor: bool):
	alto_contraste = valor
	guardar_configuracion()
	emit_signal("alto_contraste_cambiado", valor)

func set_opacidad_interfaz(valor: int):
	opacidad_interfaz = valor
	guardar_configuracion()
	emit_signal("opacidad_interfaz_cambiada", valor)
