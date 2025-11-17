extends VBoxContainer

signal direction_selected(direction: int)

var available_directions = []
var direction_buttons = []
var is_enabled = true

func _ready():
	custom_minimum_size = Vector2(600, 120)

func setup(directions: Array):
	"""Configure les directions disponibles"""
	available_directions = directions.duplicate()
	create_direction_buttons()

func create_direction_buttons():
	"""Crée les boutons de direction"""
	# Nettoyer les boutons existants
	for child in get_children():
		child.queue_free()
	direction_buttons.clear()

	# Créer un conteneur horizontal pour les boutons
	var buttons_container = HBoxContainer.new()
	buttons_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(buttons_container)

	# Créer les boutons pour chaque direction disponible
	for direction in available_directions:
		var button = Button.new()
		button.custom_minimum_size = Vector2(80, 80)

		# Texte du bouton selon la direction
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

		button.text = arrow_text
		button.add_theme_font_size_override("font_size", 36)

		# Stocker la direction dans les métadonnées du bouton
		button.set_meta("direction", direction)
		button.set_meta("index", direction_buttons.size())

		# Connecter le signal
		button.pressed.connect(_on_direction_button_pressed.bind(button))

		buttons_container.add_child(button)
		direction_buttons.append(button)

func _on_direction_button_pressed(button: Button):
	"""Appelé quand un bouton de direction est pressé"""
	if not is_enabled:
		return

	var direction = button.get_meta("direction")

	# Griser le bouton (désactivé visuellement)
	button.disabled = true
	button.modulate = Color(0.5, 0.5, 0.5)

	# Émettre le signal
	direction_selected.emit(direction)

func reset():
	"""Réinitialise tous les boutons"""
	for button in direction_buttons:
		button.disabled = false
		button.modulate = Color.WHITE

func set_enabled(enabled: bool):
	"""Active ou désactive tous les boutons"""
	is_enabled = enabled
	for button in direction_buttons:
		if not button.disabled:  # Ne pas réactiver les boutons déjà utilisés
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE if not enabled else Control.MOUSE_FILTER_STOP
