extends Resource
class_name EntradaResiduoario

@export var nombre: String
@export var imagen: Texture2D
@export_multiline var descripcion: String
@export_enum("Organico"
			, "Inorganico"
			, "Vidrio"
			, "Plastico"
			, "Metal"
			, "Papel"
			, "Peligroso") var categoria: String
