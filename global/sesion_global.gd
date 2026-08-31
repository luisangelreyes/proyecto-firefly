extends Node

var _ventana_enfocada: bool = true

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_ventana_enfocada = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_ventana_enfocada = false



# ── SESIÓN ACTIVA ─────────────────────────────────────────────────────────────
var perfil_actual: String = ""

const Grupos = {
	RESIDUO_CAIDA = "basura_caida",
	RESIDUO_TD = "residuo_td",
}

const Categorias = {
	PELIGROSO = "peligroso",
	ORGANICO = "organico",
	INORGANICO = "inorganico",
	PAPEL = "papel",
	VIDRIO = "vidrio",
	PLASTICO = "plastico",
	METAL = "metal",
	TELA = "tela"
}
var puntaje: int = 0
var vidas: int = 3
var combo: int = 1
var recien_completado: bool = false
var _musica_menu: AudioStreamPlayer
var modo_libre_config: Dictionary = {}
var es_modo_libre: bool = false
var mundo_actual: int = 1
var nivel_actual: int = 1
var datos_residuos: Dictionary = {}

var niveles_desbloqueados: Dictionary = {
	"1-1": true,  "1-2": false, "1-3": false, "1-4": false,
	"2-1": false, "2-2": false, "2-3": false,
	"2-4": false, "2-5": false, "2-6": false,
}

const RUTAS_NIVELES: Dictionary = {
	
	"1-1": "res://scenes/niveles/tutoriales/NivelTutorial1.tscn",
	"1-2": "res://scenes/niveles/tutoriales/NivelCaida0.tscn",
	"1-3": "res://scenes/niveles/mundo1/NivelCaida1.tscn",
	"1-4": "res://scenes/niveles/mundo1/NivelClasificacion1_4.tscn",

	"2-1": "res://scenes/niveles/mundo2/NivelCaida2_1.tscn",
	"2-2": "res://scenes/niveles/mundo2/NivelClasificacion2_2.tscn",
	"2-3": "res://scenes/niveles/mundo2/nivel_top_down_tutorial_2_2.tscn",
	"2-4": "res://scenes/niveles/mundo2/NivelCaida2_3.tscn",
	"2-5": "res://scenes/niveles/mundo2/NivelClasificacion2_5.tscn",
	"2-6": "res://scenes/niveles/NIVEL_FINAL/NivelBoss.tscn",
}

var ruta_guardado: String = "user://perfiles_recolectores.json"
var ultimo_perfil_usado: String = ""
var eventos_sesion: Array = []
var tiempo_inicio_sesion: float = 0.0
var tiempo_ultimo_residuo: float = 0.0
signal tipo_control_cambiado(es_mando: bool)
var usando_mando: bool = false


func _ready():
	_musica_menu = AudioStreamPlayer.new()
	#_musica_menu.stream = preload("res://assets/audio/music/MENU_FONDO.2mp3.mp3")
	_musica_menu.volume_db = 0.0
	_musica_menu.bus = "Master"
	_musica_menu.autoplay = false
	add_child(_musica_menu)
	_cargar_datos_residuos()

func _cargar_datos_residuos():
	var file = FileAccess.open("res://global/datos_residuos.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var json = JSON.new()
		if json.parse(text) == OK:
			datos_residuos = json.data
		else:
			push_error("Error al parsear datos_residuos.json")
	else:
		push_error("No se pudo abrir datos_residuos.json")


func reproducir_musica_menu():
	if is_instance_valid(_musica_menu) and not _musica_menu.playing:
		_musica_menu.play()

func detener_musica_menu():
	if is_instance_valid(_musica_menu) and _musica_menu.playing:
		_musica_menu.stop()
		

func _input(event):
	if not _ventana_enfocada:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			get_viewport().set_input_as_handled()
			return

	var hubo_cambio = false
	
	# Detectar Teclado o Ratón
	if event is InputEventKey or event is InputEventMouse or event is InputEventMouseButton:
		if usando_mando == true:
			usando_mando = false
			hubo_cambio = true
			
	# Detectar Mando (Control)
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		# Ignoramos movimientos minúsculos de las palancas (stick drift)
		if event is InputEventJoypadMotion and abs(event.axis_value) < 0.2:
			return
			
		if usando_mando == false:
			usando_mando = true
			hubo_cambio = true
			

	if hubo_cambio:
		tipo_control_cambiado.emit(usando_mando)
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
	recien_completado = true
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
	perfil_actual       = nombre_jugador
	ultimo_perfil_usado = nombre_jugador
	puntaje             = d.get("puntaje", 0)
	vidas               = d.get("vidas", 3)
	combo               = d.get("combo", 1)
	mundo_actual        = d.get("mundo_actual", 1)
	nivel_actual        = d.get("nivel_actual", 1)

	# ← ESTA línea faltaba — carga el progreso real del JSON
	niveles_desbloqueados = d.get("niveles_desbloqueados", {
		"1-1": true, "1-2": false, "1-3": false, "1-4": false,
		"2-1": false, "2-2": false, "2-3": false,
		"2-4": false, "2-5": false, "2-6": false,
	})

	# Parchar claves faltantes en perfiles viejos
	for clave in ["1-1","1-2","1-3","1-4","2-1","2-2","2-3","2-4","2-5","2-6"]:
		if not niveles_desbloqueados.has(clave):
			niveles_desbloqueados[clave] = false

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
