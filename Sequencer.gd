extends HBoxContainer

var sequence = []
const ARROW_SIZE = 60

func _ready():
	custom_minimum_size = Vector2(600, 80)

func add_direction(direction: int):
	"""Ajoute une direction à la séquence"""
	sequence.append(direction)
	create_arrow_display(direction)

func clear_sequence():
	"""Vide la séquence"""
	sequence.clear()
	for child in get_children():
		child.queue_free()

func create_arrow_display(direction: int):
	"""Crée l'affichage visuel d'une flèche"""
	var arrow_panel = Panel.new()
	arrow_panel.custom_minimum_size = Vector2(ARROW_SIZE, ARROW_SIZE)

	var arrow_label = Label.new()
	arrow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arrow_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arrow_label.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Définir le symbole de la flèche selon la direction
	var arrow_text = ""
	match direction:
		0:  # RIGHT
			arrow_text = "→"
		1:  # LEFT
			arrow_text = "←"
		2:  # UP
			arrow_text = "↑"
		3:  # DOWN
			arrow_text = "↓"

	arrow_label.text = arrow_text
	arrow_label.add_theme_font_size_override("font_size", 36)

	arrow_panel.add_child(arrow_label)
	add_child(arrow_panel)

func get_sequence() -> Array:
	"""Retourne la séquence actuelle"""
	return sequence.duplicate()
