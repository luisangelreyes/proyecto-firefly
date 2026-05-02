extends CanvasLayer

@onready var menu_pausa = $Control

func _ready():
	menu_pausa.hide()
	# Nos conectamos a la señal global
	SesionGlobal.abrir_menu_pausa.connect(_alternar_pausa)

func _input(event):
	if event.is_action_pressed("pausa"):
		_alternar_pausa()

func _alternar_pausa():
	var nuevo_estado = not get_tree().paused
	get_tree().paused = nuevo_estado
	menu_pausa.visible = nuevo_estado

func _on_boton_continuar_pressed():
	get_tree().paused = false
	menu_pausa.hide()
