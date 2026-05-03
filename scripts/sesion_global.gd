extends Node

# ── SESIÓN ACTIVA ─────────────────────────────────────────────────────────────
var perfil_actual: String = ""
var puntaje: int = 0
var vidas: int = 3
var combo: int = 1

# ── ESTRUCTURA DE PROGRESO POR MUNDOS ────────────────────────────────────────
# mundo_actual y nivel_actual indican dónde está el jugador ahora mismo
var mundo_actual: int = 1
var nivel_actual: int = 1

# Mapa de niveles desbloqueados — clave "mundo-nivel"
# 1-1: Tutorial
# 1-2: Caída de residuos (NivelBase)
# 1-3: Dr. Mario de residuos
var niveles_desbloqueados: Dictionary = {
	"1-1": true,
	"1-2": false,
	"1-3": false,
}

# Rutas de escena por nivel — se usa desde el menú para cargar la escena correcta
const RUTAS_NIVELES: Dictionary = {
	"1-1": "res://scenes/niveles/NivelTutorial1.tscn",
	"1-2": "res://scenes/niveles/NivelBase.tscn",
	"1-3": "res://scenes/niveles/Nivel2.tscn",
}

# Ruta del archivo de guardado
var ruta_guardado: String = "user://perfiles_recolectores.json"

# ── RF-01 / RF-06: NUEVA PARTIDA ─────────────────────────────────────────────
func iniciar_nueva_partida(nombre_jugador: String):
	perfil_actual = nombre_jugador
	puntaje       = 0
	vidas         = 3
	combo         = 1
	mundo_actual  = 1
	nivel_actual  = 1
	niveles_desbloqueados = {
		"1-1": true,
		"1-2": false,
		"1-3": false,
	}
	guardar_progreso()

# ── DESBLOQUEAR SIGUIENTE NIVEL ───────────────────────────────────────────────
func completar_nivel(mundo: int, nivel: int):
	var clave_actual   = "%d-%d" % [mundo, nivel]
	var clave_siguiente = "%d-%d" % [mundo, nivel + 1]

	# Si existe el siguiente nivel en el mapa, lo desbloqueamos
	if niveles_desbloqueados.has(clave_siguiente):
		niveles_desbloqueados[clave_siguiente] = true

	# Avanzamos el puntero de progreso
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
	perfil_actual = nombre_jugador
	puntaje       = d.get("puntaje", 0)
	vidas         = d.get("vidas", 3)
	combo         = d.get("combo", 1)
	mundo_actual  = d.get("mundo_actual", 1)
	nivel_actual  = d.get("nivel_actual", 1)

	# Compatibilidad hacia atrás: si el JSON es viejo y no tiene
	# niveles_desbloqueados, arrancamos con solo el tutorial disponible
	niveles_desbloqueados = d.get("niveles_desbloqueados", {"1-1": true, "1-2": false, "1-3": false})
	return true

# ── HELPERS DE JUEGO ──────────────────────────────────────────────────────────
func registrar_acierto(cantidad: int):
	puntaje += cantidad

func registrar_error():
	vidas -= 1
