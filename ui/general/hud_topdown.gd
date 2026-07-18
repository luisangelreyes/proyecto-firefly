extends CanvasLayer

var barra_tiempo: ProgressBar
var lbl_tiempo: Label
var lbl_bote: Label
var lbl_residuos: Label

const COLOR_BOTE = [Color("00f969ff"), Color("0e95ffff")]
const NOMBRES_BOTE = ["Orgánico", "Inorgánico"]

func setup():
	barra_tiempo = $BarraTiempo
	lbl_tiempo = $LabelTiempo
	lbl_bote = $LabelBote
	lbl_residuos = $LabelResiduos

func _on_tiempo_actualizado(tiempo_restante: float):
	if barra_tiempo and lbl_tiempo:
		barra_tiempo.value = tiempo_restante
		lbl_tiempo.text = "%d" % ceil(tiempo_restante)
		
		if tiempo_restante <= 10:
			barra_tiempo.modulate = Color("#f87171")
		elif tiempo_restante <= 25:
			barra_tiempo.modulate = Color("#fbbf24")
		else:
			barra_tiempo.modulate = Color("#86efac")

func _on_bote_cambiado(bote_activo: int):
	if lbl_bote:
		lbl_bote.text = "Bote: " + NOMBRES_BOTE[bote_activo]
		lbl_bote.add_theme_color_override("font_color", COLOR_BOTE[bote_activo])

func _on_residuos_actualizados(recogidos: int, total_residuos: int):
	if lbl_residuos:
		lbl_residuos.text = "Residuos: %d / %d" % [recogidos, total_residuos]

func _on_max_tiempo_configurado(tiempo_max: float):
	if barra_tiempo:
		barra_tiempo.max_value = tiempo_max
		barra_tiempo.value = tiempo_max
