# configuracion.gd - Autoload
extends Node

signal tamaño_cambiado(nuevo_tamaño: String, valor_activo: int, valor_inactivo: int)

enum TamañoFuente { NORMAL, MEDIANO, GRANDE }

# Tamaños base para cada opción
const TAMAÑOS = {
	TamañoFuente.NORMAL:  {"activo": 32, "inactivo": 26},
	TamañoFuente.MEDIANO: {"activo": 37, "inactivo": 31},  # +5
	TamañoFuente.GRANDE:  {"activo": 42, "inactivo": 36}   # +5 más
}

var tamaño_actual: int = TamañoFuente.NORMAL

func _ready():
	cargar_configuracion()
	# Aplicar el tamaño guardado al inicio
	aplicar_tamaño_actual()

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

func guardar_configuracion():
	var config = ConfigFile.new()
	config.set_value("accesibilidad", "tamaño_fuente", tamaño_actual)
	config.save("user://configuracion.cfg")

func cargar_configuracion():
	var config = ConfigFile.new()
	if config.load("user://configuracion.cfg") == OK:
		tamaño_actual = config.get_value("accesibilidad", "tamaño_fuente", TamañoFuente.NORMAL)
