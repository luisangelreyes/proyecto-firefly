extends Node

# ── SESIÓN ACTIVA ─────────────────────────────────────────────────────────────
var perfil_actual: String = ""
var puntaje: int = 0
var vidas: int = 3
var combo: int = 1
# En sesion_global.gd, junto a las demás variables
var modo_libre_config: Dictionary = {}
var es_modo_libre: bool = false
# ── ESTRUCTURA DE PROGRESO POR MUNDOS ────────────────────────────────────────
# mundo_actual y nivel_actual indican dónde está el jugador ahora mismo
var mundo_actual: int = 1
var nivel_actual: int = 1

var niveles_desbloqueados: Dictionary = {
	"1-1": true,  "1-2": false, "1-3": false, "1-4": false,
	"2-1": false, "2-2": false, "2-3": false,
	"2-4": false, "2-5": false, "2-6": false,
}

# Rutas de escena por nivel — se usa desde el menú para cargar la escena correcta
const RUTAS_NIVELES: Dictionary = {
	# Mundo 1
	"1-1": "res://scenes/niveles/NivelTutorial1.tscn",
	"1-2": "res://scenes/niveles/NivelCaida1.tscn",
	"1-3": "res://scenes/niveles/NivelCaida2.tscn",
	"1-4": "res://scenes/niveles/nivel2.tscn",
	# Mundo 2
	"2-1": "res://scenes/niveles/NivelTopDown.tscn",
	"2-2": "res://scenes/niveles/NivelCaida1.tscn",
	"2-3": "res://scenes/niveles/NivelCaida2.tscn",
	"2-4": "res://scenes/niveles/nivel2.tscn",
	"2-5": "res://scenes/niveles/nivel2.tscn",
	"2-6": "res://scenes/niveles/nivel2.tscn",
}

# Ruta del archivo de guardado
var ruta_guardado: String = "user://perfiles_recolectores.json"
var ultimo_perfil_usado: String = ""
var eventos_sesion: Array = []
var tiempo_inicio_sesion: float = 0.0
var tiempo_ultimo_residuo: float = 0.0

func iniciar_registro_sesion():
	eventos_sesion.clear()
	tiempo_inicio_sesion = Time.get_ticks_msec() / 1000.0
	tiempo_ultimo_residuo = tiempo_inicio_sesion

func registrar_evento(datos: Dictionary):
	datos["timestamp_ms"] = Time.get_ticks_msec()
	eventos_sesion.append(datos)
	
# ── RF-01 / RF-06: NUEVA PARTIDA ─────────────────────────────────────────────
func iniciar_nueva_partida(nombre_jugador: String):
	perfil_actual = nombre_jugador
	puntaje       = 0
	vidas         = 3
	combo         = 1
	mundo_actual  = 1
	nivel_actual  = 1
	niveles_desbloqueados = {
	"1-1": true,  "1-2": false, "1-3": false, "1-4": false,
	"2-1": false, "2-2": false, "2-3": false,
	"2-4": false, "2-5": false, "2-6": false,
	}
	guardar_progreso()

# ── DESBLOQUEAR SIGUIENTE NIVEL ───────────────────────────────────────────────
func completar_nivel(mundo: int, nivel: int):
	var _clave_actual    = "%d-%d" % [mundo, nivel]
	var clave_siguiente = "%d-%d" % [mundo, nivel + 1]

	# Si no existe el siguiente en este mundo, buscar el inicio del siguiente mundo
	if not niveles_desbloqueados.has(clave_siguiente):
		clave_siguiente = "%d-%d" % [mundo + 1, 1]

	if niveles_desbloqueados.has(clave_siguiente):
		niveles_desbloqueados[clave_siguiente] = true

	mundo_actual = mundo
	nivel_actual = nivel + 1
	guardar_sesion()

func nivel_disponible(mundo: int, nivel: int) -> bool:
	var clave = "%d-%d" % [mundo, nivel]
	return niveles_desbloqueados.get(clave, false)

func get_ruta_nivel(mundo: int, nivel: int) -> String:
	var clave = "%d-%d" % [mundo, nivel]
	return RUTAS_NIVELES.get(clave, "")

# ── GUARDAR ───────────────────────────────────────────────────────────────────
func guardar_progreso():
	var datos_perfiles = cargar_todos_los_perfiles()
	datos_perfiles[perfil_actual] = _datos_perfil_actual()
	_escribir_json(datos_perfiles)

func guardar_sesion():
	var datos_totales = cargar_todos_los_perfiles()
	datos_totales[perfil_actual] = _datos_perfil_actual()
	_escribir_json(datos_totales)

func _datos_perfil_actual() -> Dictionary:
	return {
		"puntaje":               puntaje,
		"vidas":                 vidas,
		"combo":                 combo,
		"mundo_actual":          mundo_actual,
		"nivel_actual":          nivel_actual,
		"niveles_desbloqueados": niveles_desbloqueados,
	}

func _escribir_json(datos: Dictionary):
	var archivo = FileAccess.open(ruta_guardado, FileAccess.WRITE)
	if archivo:
		archivo.store_string(JSON.stringify(datos, "\t"))
		archivo.close()

# ── CARGAR ────────────────────────────────────────────────────────────────────
func cargar_todos_los_perfiles() -> Dictionary:
	if not FileAccess.file_exists(ruta_guardado):
		return {}
	var archivo = FileAccess.open(ruta_guardado, FileAccess.READ)
	var contenido = archivo.get_as_text()
	archivo.close()
	var json = JSON.new()
	var error = json.parse(contenido)
	if error == OK and typeof(json.data) == TYPE_DICTIONARY:
		return json.data
	return {}

func cargar_partida(nombre_jugador: String) -> bool:
	var datos = cargar_todos_los_perfiles()
	if not datos.has(nombre_jugador):
		return false
	
	var d = datos[nombre_jugador]
	perfil_actual     = nombre_jugador
	ultimo_perfil_usado = nombre_jugador   # ← guardar cuál fue
	puntaje           = d.get("puntaje", 0)
	vidas             = d.get("vidas", 3)
	combo             = d.get("combo", 1)
	mundo_actual      = d.get("mundo_actual", 1)
	nivel_actual      = d.get("nivel_actual", 1)
	for clave in ["2-1","2-2","2-3","2-4","2-5","2-6"]:
		if not niveles_desbloqueados.has(clave):
			niveles_desbloqueados[clave] = false
# Parchar claves que faltan en perfiles viejos
	if not niveles_desbloqueados.has("1-4"):
		niveles_desbloqueados["1-4"] = false
	if not niveles_desbloqueados.has("1-3"):
		niveles_desbloqueados["1-3"] = false
	# Guardar que este fue el último perfil usado
		_guardar_ultimo_perfil(nombre_jugador)
	return true

func _guardar_ultimo_perfil(nombre: String):
	var ruta_ultimo = "user://ultimo_perfil.json"
	var archivo = FileAccess.open(ruta_ultimo, FileAccess.WRITE)
	if archivo:
		archivo.store_string(JSON.stringify({"ultimo": nombre}))
		archivo.close()

func cargar_ultimo_perfil() -> String:
	var ruta_ultimo = "user://ultimo_perfil.json"
	if not FileAccess.file_exists(ruta_ultimo):
		return ""
	var archivo = FileAccess.open(ruta_ultimo, FileAccess.READ)
	if not archivo:
		return ""
	var json = JSON.new()
	var error = json.parse(archivo.get_as_text())
	archivo.close()
	if error == OK and typeof(json.data) == TYPE_DICTIONARY:
		return json.data.get("ultimo", "")
	return ""
	
	
# ── HELPERS DE JUEGO ──────────────────────────────────────────────────────────
func registrar_acierto(cantidad: int):
	puntaje += cantidad

func registrar_error():
	vidas -= 1

func reiniciar_estadisticas_nivel():
	vidas = 3
	puntaje = 0 # Opcional: si quieres que el puntaje vuelva a 0 al reiniciar el intento
	combo = 1
