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
