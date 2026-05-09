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
	contenedor_animado.hide()
	actualizar_paginas_estaticas()

func actualizar_paginas_estaticas():
	# Página Izquierda
	if indice_actual < base_datos.size():
		var data = base_datos[indice_actual]
		nombre_izq.text = data.nombre
		foto_izq.texture = data.imagen
		desc_izq.text = data.descripcion
	
	# Página Derecha
	if indice_actual + 1 < base_datos.size():
		var data = base_datos[indice_actual + 1]
		nombre_der.text = data.nombre
		foto_der.texture = data.imagen
		desc_der.text = data.descripcion

func _on_boton_siguiente_pressed():
	# Solo avanzamos si hay más hojas
	if indice_actual + 2 < base_datos.size():
		# 1. Copiamos el contenido de la derecha al nodo que se va a doblar
		anim_nombre.text = nombre_der.text
		anim_foto.texture = foto_der.texture
		anim_desc.text = desc_der.text
		
		# 2. Avanzamos el índice y actualizamos el fondo (que queda oculto por ahora)
		indice_actual += 2
		actualizar_paginas_estaticas()
		
		# 3. Ejecutamos el efecto de doblado
		ejecutar_animacion_doblez()

func ejecutar_animacion_doblez():
	contenedor_animado.show()
	# Ponemos el progreso del shader en 0
	contenedor_animado.material.set_shader_parameter("progress", 0.0)
	
	var tween = create_tween()
	# Animamos la propiedad 'progress' del shader
	tween.tween_property(contenedor_animado.material, "shader_parameter/progress", 1.0, 0.6)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	# Al terminar, ocultamos el duplicado
	tween.tween_callback(contenedor_animado.hide)

func _on_boton_atras_pressed():
	if indice_actual - 2 >= 0:
		indice_actual -= 2
		actualizar_paginas_estaticas()
		# Nota: Para el botón atrás podrías hacer una animación inversa 
		# cambiando el progress de 1.0 a 0.0


func _on_button_siguiente_pressed():
	if indice_actual + 2 < base_datos.size():
		# Primero: Pasamos la info de la derecha al papel que se va a mover
		anim_nombre.text = nombre_der.text
		anim_foto.texture = foto_der.texture
		anim_desc.text = desc_der.text
		
		# Segundo: Avanzamos el índice de la base de datos
		indice_actual += 2
		
		# Tercero: Cambiamos el fondo (para que cuando la hoja termine de caer, ya esté lo nuevo)
		actualizar_paginas_estaticas()
		
		# Cuarto: Iniciamos el efecto visual
		ejecutar_animacion_doblez()


func _on_button_atras_pressed():
	# Solo regresamos si no estamos en la primera página (índice 0)
	if indice_actual - 2 >= 0:
		# 1. Restamos 2 para ir a la dupla de páginas anterior
		indice_actual -= 2
		
		# 2. Reproducir sonido si tienes el AudioStreamPlayer
		if $Residuoario/AudioStreamPlayer.stream != null:
			$Residuoario/AudioStreamPlayer.play()
		
		# 3. Actualizar los textos e imágenes de las páginas estáticas
		actualizar_paginas_estaticas()
		
		# 4. (Opcional) Si quieres que se vea una animación de regreso:
		# ejecutar_animacion_reversa()
