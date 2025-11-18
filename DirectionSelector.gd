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
	buttons_container.add_theme_constant_override("separation", 15)
	add_child(buttons_container)

	# Créer les boutons pour chaque direction disponible
	for direction in available_directions:
		var button = Button.new()
		button.custom_minimum_size = Vector2(100, 100)

		# Texte et couleur du bouton selon l'action
		var action_text = ""
		var button_color = Color.WHITE
		match direction:
			0:  # TURN_LEFT
				action_text = "↶ TOURNER\nGAUCHE"
				button_color = Color(0.4, 0.7, 1.0)  # Bleu clair
			1:  # TURN_RIGHT
				action_text = "↷ TOURNER\nDROITE"
				button_color = Color(1.0, 0.6, 0.4)  # Orange clair
			2:  # FORWARD
				action_text = "⬆ AVANCER"
				button_color = Color(0.6, 1.0, 0.6)  # Vert clair
			3:  # BACKWARD
				action_text = "⬇ RECULER"
				button_color = Color(1.0, 0.9, 0.4)  # Jaune

		button.text = action_text
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_color_override("font_color", Color.BLACK)

		# Créer un StyleBox coloré pour le bouton
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = button_color
		style_normal.corner_radius_top_left = 10
		style_normal.corner_radius_top_right = 10
		style_normal.corner_radius_bottom_left = 10
		style_normal.corner_radius_bottom_right = 10
		style_normal.border_width_all = 3
		style_normal.border_color = Color.WHITE
		button.add_theme_stylebox_override("normal", style_normal)

		var style_hover = StyleBoxFlat.new()
		style_hover.bg_color = button_color.lightened(0.2)
		style_hover.corner_radius_top_left = 10
		style_hover.corner_radius_top_right = 10
		style_hover.corner_radius_bottom_left = 10
		style_hover.corner_radius_bottom_right = 10
		style_hover.border_width_all = 3
		style_hover.border_color = Color.WHITE
		button.add_theme_stylebox_override("hover", style_hover)

		var style_pressed = StyleBoxFlat.new()
		style_pressed.bg_color = button_color.darkened(0.2)
		style_pressed.corner_radius_top_left = 10
		style_pressed.corner_radius_top_right = 10
		style_pressed.corner_radius_bottom_left = 10
		style_pressed.corner_radius_bottom_right = 10
		style_pressed.border_width_all = 3
		style_pressed.border_color = Color.WHITE
		button.add_theme_stylebox_override("pressed", style_pressed)

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
