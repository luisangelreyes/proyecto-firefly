# configuracion.gd - Autoload
extends Node

signal tamaño_cambiado(nuevo_tamaño: String, valor_activo: int, valor_inactivo: int)
signal filtro_cambiado(tipo: int)
signal movimiento_reducido_cambiado(valor: bool)

enum TamañoFuente { NORMAL, MEDIANO, GRANDE }
enum FiltroColor { NINGUNO, DEUTERANOPIA, PROTANOPIA, TRITANOPIA }

const TAMAÑOS = {
	TamañoFuente.NORMAL:  {"activo": 32, "inactivo": 26},
	TamañoFuente.MEDIANO: {"activo": 42, "inactivo": 36},
	TamañoFuente.GRANDE:  {"activo": 47, "inactivo": 41}
}

var tamaño_actual: int = TamañoFuente.NORMAL
var filtro_actual: int = FiltroColor.NINGUNO
var movimiento_reducido: bool = false

var _overlay_layer: CanvasLayer
var _overlay_rect: ColorRect
var _shader_material: ShaderMaterial

func _ready():
	cargar_configuracion()
	aplicar_tamaño_actual()
	_crear_overlay()
	aplicar_filtro_actual()

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
		TamañoFuente.MEDIANO:
			return "Mediano"
		TamañoFuente.GRANDE:
			return "Grande"
	return "Normal"

func aplicar_tamaño_actual():
	var valores = TAMAÑOS[tamaño_actual]
	emit_signal("tamaño_cambiado", get_nombre_tamaño(), valores["activo"], valores["inactivo"])

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
	config.save("user://configuracion.cfg")

func cargar_configuracion():
	var config = ConfigFile.new()
	if config.load("user://configuracion.cfg") == OK:
		tamaño_actual = config.get_value("accesibilidad", "tamaño_fuente", TamañoFuente.NORMAL)
		filtro_actual = config.get_value("accesibilidad", "filtro_color", FiltroColor.NINGUNO)
		movimiento_reducido = config.get_value("accesibilidad", "movimiento_reducido", false)
