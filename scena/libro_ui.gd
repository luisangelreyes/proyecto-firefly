extends CanvasLayer

# Aquí conectamos los archivos .tres
@export var base_datos: Array[EntradaResiduoario] = []
var indice_actual: int = 0

# Referencias a los nodos de las páginas estáticas (fondo)
@onready var nombre_izq = $Residuoario/ContenidoEstatico/PaginaIzquierda/NombreResiduo
@onready var foto_izq = $Residuoario/ContenidoEstatico/PaginaIzquierda/Residuo
@onready var desc_izq = $Residuoario/ContenidoEstatico/PaginaIzquierda/Descripcion

@onready var nombre_der = $Residuoario/ContenidoEstatico/PaginaDerecha/NombreResiduo
@onready var foto_der = $Residuoario/ContenidoEstatico/PaginaDerecha/Residuo
@onready var desc_der = $Residuoario/ContenidoEstatico/PaginaDerecha/Descripcion

# Referencias a los nodos dentro del SubViewport (el que se dobla)
@onready var anim_nombre =$Residuoario/ContenidoAnimado/SubViewport/ContenidoPagina/NombreResiduo
@onready var anim_foto = $Residuoario/ContenidoAnimado/SubViewport/ContenidoPagina/Residuo
@onready var anim_desc = $Residuoario/ContenidoAnimado/SubViewport/ContenidoPagina/Descripcion

@onready var contenedor_animado = $Residuoario/ContenidoAnimado

func _ready():
	
	# 1. Obtenemos todos los botones dentro de tu contenedor de categorías
	# Reemplaza $Categorias por la ruta real a tu contenedor de botones
	for boton in $Residuoario/Categorias.get_children():
		if boton is Button:
			# Tomamos el nombre del botón (ej: "ButtonOrganico") 
			# y le quitamos el prefijo "Button" para que quede "Organico"
			var nombre_categoria = boton.name.replace("Button", "")
			
			# Conectamos la señal y pasamos ese nombre como argumento
			boton.pressed.connect(saltar_a_categoria.bind(nombre_categoria))
	
	actualizar_paginas()
	
	# Ocultamos el contenedor animado ya que no se usará
	if has_node("Residuoario/ContinadoAnimado"):
		$Residuoario/ContinadoAnimado.hide()
	actualizar_paginas()


func actualizar_paginas():
	_limpiar_campos()
	
	# Llenar Página Izquierda
	if indice_actual < base_datos.size():
		var res = base_datos[indice_actual]
		nombre_izq.text = res.nombre
		foto_izq.texture = res.imagen
		desc_izq.text = res.descripcion
	
	# Llenar Página Derecha
	if indice_actual + 1 < base_datos.size():
		var res = base_datos[indice_actual + 1]
		nombre_der.text = res.nombre
		foto_der.texture = res.imagen
		desc_der.text = res.descripcion

func _on_button_siguiente_pressed():
	# Si hay al menos un elemento más después de la hoja actual
	if indice_actual + 2 < base_datos.size():
		indice_actual += 2
		_reproducir_sonido()
		actualizar_paginas()

func _on_button_atras_pressed():
	if indice_actual - 2 >= 0:
		indice_actual -= 2
		_reproducir_sonido()
		actualizar_paginas()

func _reproducir_sonido():
	#if audio and audio.stream:
	#	audio.play()
	pass

func _limpiar_campos():
	nombre_izq.text = ""; foto_izq.texture = null; desc_izq.text = ""
	nombre_der.text = ""; foto_der.texture = null; desc_der.text = ""
	

func saltar_a_categoria(nombre_buscado: String):
	# ¡Ojo aquí! Debe haber un espacio (Tab) al inicio de esta línea
	print("¡Clic detectado! Buscando categoría: ", nombre_buscado) 
	
	# Recorremos la base de datos
	for i in range(base_datos.size()):
		if base_datos[i].categoria == nombre_buscado:
			# Ajustamos el índice
			indice_actual = i if i % 2 == 0 else i - 1
			
			_reproducir_sonido()
			actualizar_paginas()
			return # Salimos del ciclo
