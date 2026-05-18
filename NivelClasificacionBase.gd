extends "res://scripts/Nivel2.gd"

# Sobreescribe en cada nivel hijo
var mensajes_tutorial: Array = []
var tutorial_completado: bool = false

@onready var dialogo = $DialogoTutorial

func _ready():
	# Conectar diálogo antes de iniciar el nivel
	if not mensajes_tutorial.is_empty():
		dialogo.dialogo_terminado.connect(_on_tutorial_terminado)
		# Pausar cola hasta que termine el tutorial
		await get_tree().process_frame
		dialogo.iniciar(mensajes_tutorial)
	else:
		super()

func _on_tutorial_terminado():
	tutorial_completado = true
	super()  # Arranca el nivel normalmente
