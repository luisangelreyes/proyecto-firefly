extends Node

# Variables de Sesión Actual
var perfil_actual = "Invitado"
var puntaje = 0
var vidas = 3
var combo = 1
var nivel_actual = 1

# Ruta segura para guardar datos localmente
var ruta_guardado = "user://perfiles_recolectores.json"

# --- RF-01 y RF-06: Crear nueva partida y guardar perfil ---
func iniciar_nueva_partida(nombre_jugador: String):
	perfil_actual = nombre_jugador
	puntaje = 0
	vidas = 3
	combo = 1
	nivel_actual = 1
	
	# Guardamos inmediatamente para que el perfil exista
	guardar_progreso()

# --- Funciones Internas de Archivos JSON ---
func guardar_progreso():
	# 1. Cargamos lo que ya existe para no borrar otros perfiles
	var datos_perfiles = cargar_todos_los_perfiles()
	
	# 2. Actualizamos o creamos el perfil actual
	datos_perfiles[perfil_actual] = {
		"puntaje": puntaje,
		"vidas": vidas,
		"combo": combo,
		"nivel_actual": nivel_actual
	}
	
	# 3. Guardamos el diccionario completo en el JSON
	var archivo = FileAccess.open(ruta_guardado, FileAccess.WRITE)
	if archivo:
		archivo.store_string(JSON.stringify(datos_perfiles, "\t"))
		archivo.close()

func cargar_todos_los_perfiles() -> Dictionary:
	# Si no hay archivo, devolvemos un diccionario vacío
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
	
	if datos.has(nombre_jugador):
		perfil_actual = nombre_jugador
		puntaje = datos[nombre_jugador].get("puntaje", 0)
		vidas = datos[nombre_jugador].get("vidas", 3)
		combo = datos[nombre_jugador].get("combo", 1)
		nivel_actual = datos[nombre_jugador].get("nivel_actual", 1)
		return true
		
	return false
