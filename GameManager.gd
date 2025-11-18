extends Node2D

# Références aux zones
@onready var grid = $Grid
@onready var sequencer = $UI/Sequencer
@onready var direction_selector = $UI/DirectionSelector
@onready var execute_button = $UI/ExecuteButton
@onready var reset_button = $UI/ResetButton
@onready var level_label = $UI/LevelLabel
@onready var stars_label = $UI/StarsLabel
@onready var previous_level_button = $UI/PreviousLevelButton
@onready var next_level_button = $UI/NextLevelButton
@onready var reset_progress_button = $UI/ResetProgressButton

# Gestionnaire de niveaux
var level_manager

# Configuration du jeu (dynamique selon le niveau)
var GRID_SIZE = 5
const CELL_SIZE = 80

# État du jeu
var start_pos = Vector2i(0, 0)
var end_pos = Vector2i(4, 4)
var current_pos = Vector2i(0, 0)
var player_facing = 0  # 0=Nord(haut), 1=Est(droite), 2=Sud(bas), 3=Ouest(gauche)
var obstacles = []
var available_moves = []
var selected_sequence = []
var is_executing = false
var optimal_solution = []
var moves_used = 0

# Actions du joueur
enum Action { TURN_LEFT, TURN_RIGHT, FORWARD, BACKWARD }

# Vecteurs de direction selon l'orientation (Nord, Est, Sud, Ouest)
var direction_vectors = [
	Vector2i(0, -1),  # Nord (haut)
	Vector2i(1, 0),   # Est (droite)
	Vector2i(0, 1),   # Sud (bas)
	Vector2i(-1, 0)   # Ouest (gauche)
]

func _ready():
	# Créer le gestionnaire de niveaux
	var LevelManagerClass = load("res://LevelManager.gd")
	level_manager = LevelManagerClass.new()
	add_child(level_manager)

	print("LevelManager créé, niveau actuel: ", level_manager.current_level)

	generate_level()
	setup_ui()
	update_player_position()
	update_ui_labels()

func generate_level():
	"""Génère un niveau selon la configuration du LevelManager"""
	randomize()

	# Obtenir la configuration du niveau actuel
	if not level_manager:
		print("ERREUR: level_manager est null dans generate_level!")
		return

	var config = level_manager.get_current_level_config()
	GRID_SIZE = config.grid_size

	print("Génération niveau - Grille: ", GRID_SIZE, "x", GRID_SIZE, ", Obstacles: ", config.obstacles)

	# Choisir départ et arrivée
	start_pos = Vector2i(randi() % GRID_SIZE, randi() % GRID_SIZE)
	end_pos = Vector2i(randi() % GRID_SIZE, randi() % GRID_SIZE)

	# S'assurer que départ et arrivée sont différents
	while end_pos == start_pos:
		end_pos = Vector2i(randi() % GRID_SIZE, randi() % GRID_SIZE)

	current_pos = start_pos
	player_facing = 0  # Toujours commencer en regardant vers le nord
	moves_used = 0

	# Générer un chemin solution
	var solution_path = generate_solution_path()

	# Vérifier que le chemin est valide (atteint bien la destination)
	var test_pos = start_pos
	var test_facing = 0
	for action in solution_path:
		match action:
			Action.TURN_LEFT:
				test_facing = (test_facing - 1 + 4) % 4
			Action.TURN_RIGHT:
				test_facing = (test_facing + 1) % 4
			Action.FORWARD:
				test_pos += direction_vectors[test_facing]
			Action.BACKWARD:
				test_pos -= direction_vectors[test_facing]

	# Si le chemin n'atteint pas la destination, régénérer le niveau
	if test_pos != end_pos:
		print("Chemin invalide détecté, régénération...")
		generate_level()
		return

	# Sauvegarder la solution optimale
	optimal_solution = solution_path.duplicate()

	# Construire available_moves en donnant exactement la solution + quelques extras
	# Pour un jeu de puzzle, on donne les bonnes pièces dans le désordre
	available_moves.clear()

	# Ajouter toutes les actions de la solution optimale
	for action in solution_path:
		available_moves.append(action)

	# Ajouter quelques actions supplémentaires pour la difficulté
	# Mais pas trop pour ne pas rendre impossible
	var num_extras = min(3, solution_path.size() / 3)  # Max 3 extras ou 1/3 de la solution
	for i in range(num_extras):
		# Ajouter des actions aléatoires
		available_moves.append(randi() % 4)

	# Mélanger les actions
	available_moves.shuffle()

	print("Solution générée: ", solution_path.size(), " actions, Available moves: ", available_moves.size())

	# Placer des obstacles (en évitant le chemin solution)
	generate_obstacles(solution_path)

	# Mettre à jour l'affichage
	if grid:
		grid.setup_grid(start_pos, end_pos, obstacles, GRID_SIZE)

func generate_solution_path() -> Array:
	"""Génère un chemin solution du départ à l'arrivée avec rotations et mouvements"""
	var path = []
	var pos = start_pos
	var facing = 0  # Commence en regardant vers le Nord (haut)

	# Alterner entre mouvements X et Y pour créer un zigzag
	var use_x = true

	while pos != end_pos:
		var target_direction = -1

		# Décider quelle direction prendre
		if use_x and pos.x != end_pos.x:
			# Se déplacer horizontalement
			if end_pos.x > pos.x:
				target_direction = 1  # Est (droite)
			else:
				target_direction = 3  # Ouest (gauche)
		elif pos.y != end_pos.y:
			# Se déplacer verticalement
			if end_pos.y > pos.y:
				target_direction = 2  # Sud (bas)
			else:
				target_direction = 0  # Nord (haut)
		else:
			break

		# Tourner vers la direction cible
		var rotation_needed = (target_direction - facing + 4) % 4

		if rotation_needed == 1:
			# Tourner à droite une fois
			path.append(Action.TURN_RIGHT)
			facing = (facing + 1) % 4
		elif rotation_needed == 2:
			# Tourner 180° (deux fois à droite ou deux fois à gauche, choisir aléatoirement)
			if randi() % 2 == 0:
				path.append(Action.TURN_RIGHT)
				path.append(Action.TURN_RIGHT)
			else:
				path.append(Action.TURN_LEFT)
				path.append(Action.TURN_LEFT)
			facing = (facing + 2) % 4
		elif rotation_needed == 3:
			# Tourner à gauche une fois (équivalent à 3 fois à droite)
			path.append(Action.TURN_LEFT)
			facing = (facing - 1 + 4) % 4

		# Avancer dans la direction actuelle
		path.append(Action.FORWARD)
		pos += direction_vectors[facing]

		# Alterner pour créer un zigzag
		use_x = not use_x

		# Sécurité
		if path.size() > 50:
			break

	return path

func generate_obstacles(solution_path: Array):
	"""Génère des obstacles en évitant le chemin solution"""
	obstacles.clear()

	# Obtenir le nombre d'obstacles depuis la configuration
	var config = level_manager.get_current_level_config()
	var num_obstacles = config.obstacles

	# Calculer les positions du chemin solution
	var solution_positions = {}
	var pos = start_pos
	var facing = 0
	solution_positions[pos] = true

	for action in solution_path:
		match action:
			Action.TURN_LEFT:
				facing = (facing - 1 + 4) % 4
			Action.TURN_RIGHT:
				facing = (facing + 1) % 4
			Action.FORWARD:
				pos += direction_vectors[facing]
				if is_valid_position(pos):
					solution_positions[pos] = true
			Action.BACKWARD:
				pos -= direction_vectors[facing]
				if is_valid_position(pos):
					solution_positions[pos] = true

	# Ajouter des obstacles aléatoires
	for i in range(num_obstacles):
		var obs_pos = Vector2i(randi() % GRID_SIZE, randi() % GRID_SIZE)

		# Ne pas placer d'obstacle sur le chemin solution, départ ou arrivée
		if not solution_positions.has(obs_pos) and obs_pos != end_pos:
			obstacles.append(obs_pos)

func is_valid_position(pos: Vector2i) -> bool:
	"""Vérifie si une position est valide sur la grille"""
	return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE

func is_obstacle(pos: Vector2i) -> bool:
	"""Vérifie si une position contient un obstacle"""
	return obstacles.has(pos)

func setup_ui():
	"""Configure l'interface utilisateur"""
	if direction_selector:
		direction_selector.setup(available_moves)
		direction_selector.direction_selected.connect(_on_direction_selected)

	if execute_button:
		execute_button.pressed.connect(_on_execute_pressed)

	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)

	if previous_level_button:
		previous_level_button.pressed.connect(_on_previous_level_pressed)

	if next_level_button:
		next_level_button.pressed.connect(_on_next_level_pressed)

	if reset_progress_button:
		reset_progress_button.pressed.connect(_on_reset_progress_pressed)

func _on_direction_selected(direction: int):
	"""Appelé quand une direction est sélectionnée"""
	selected_sequence.append(direction)
	if sequencer:
		sequencer.add_direction(direction)

func _on_reset_pressed():
	"""Réinitialise la séquence"""
	selected_sequence.clear()
	if sequencer:
		sequencer.clear_sequence()
	if direction_selector:
		direction_selector.reset()

func _on_execute_pressed():
	"""Execute la séquence de mouvements"""
	if is_executing or selected_sequence.is_empty():
		return

	is_executing = true
	execute_button.disabled = true
	reset_button.disabled = true
	direction_selector.set_enabled(false)

	await execute_sequence()

	is_executing = false
	execute_button.disabled = false
	reset_button.disabled = false
	direction_selector.set_enabled(true)

func execute_sequence():
	"""Execute la séquence d'actions case par case"""
	current_pos = start_pos
	player_facing = 0  # Réinitialiser l'orientation
	update_player_position()

	for action in selected_sequence:
		await get_tree().create_timer(0.5).timeout

		match action:
			Action.TURN_LEFT:
				# Tourner à gauche (90° antihoraire)
				player_facing = (player_facing - 1 + 4) % 4
				update_player_position()

			Action.TURN_RIGHT:
				# Tourner à droite (90° horaire)
				player_facing = (player_facing + 1) % 4
				update_player_position()

			Action.FORWARD:
				# Avancer dans la direction actuelle
				var next_pos = current_pos + direction_vectors[player_facing]

				# Vérifier si le mouvement est valide
				if not is_valid_position(next_pos) or is_obstacle(next_pos):
					# Mouvement invalide : clignoter en rouge
					await show_error()
					_on_reset_pressed()
					return

				# Mouvement valide
				current_pos = next_pos
				update_player_position()

			Action.BACKWARD:
				# Reculer (opposé de la direction actuelle)
				var next_pos = current_pos - direction_vectors[player_facing]

				# Vérifier si le mouvement est valide
				if not is_valid_position(next_pos) or is_obstacle(next_pos):
					# Mouvement invalide : clignoter en rouge
					await show_error()
					_on_reset_pressed()
					return

				# Mouvement valide
				current_pos = next_pos
				update_player_position()

		# Vérifier si on a atteint l'arrivée
		if current_pos == end_pos:
			moves_used = selected_sequence.size()
			var stars = level_manager.calculate_stars(moves_used, optimal_solution.size())

			await show_victory(stars)
			await get_tree().create_timer(1.5).timeout

			# Enregistrer le niveau comme complété
			level_manager.complete_level(stars)

			# Générer le niveau suivant
			generate_level()
			_on_reset_pressed()
			update_ui_labels()
			return

	# Séquence terminée mais pas à l'arrivée
	await get_tree().create_timer(0.5).timeout
	_on_reset_pressed()

func update_player_position():
	"""Met à jour la position visuelle du joueur"""
	if grid:
		grid.set_player_position(current_pos, player_facing)

func show_error():
	"""Affiche une animation d'erreur"""
	if grid:
		for i in range(3):
			grid.player_flash_color = Color.RED
			grid.queue_redraw()
			await get_tree().create_timer(0.2).timeout
			grid.player_flash_color = Color(1.0, 0.5, 0.0)  # Orange
			grid.queue_redraw()
			await get_tree().create_timer(0.2).timeout

func show_victory(stars: int):
	"""Affiche une animation de victoire avec les étoiles"""
	# Animation du joueur
	if grid:
		for i in range(3):
			grid.player_flash_color = Color.GREEN
			grid.queue_redraw()
			await get_tree().create_timer(0.2).timeout
			grid.player_flash_color = Color(1.0, 0.5, 0.0)  # Orange
			grid.queue_redraw()
			await get_tree().create_timer(0.2).timeout

	# Afficher le message de victoire avec les étoiles
	var stars_text = ""
	for i in range(stars):
		stars_text += "⭐"
	print("Niveau terminé ! ", stars_text, " (", moves_used, " mouvements, optimal: ", optimal_solution.size(), ")")

func update_ui_labels():
	"""Met à jour les labels d'UI avec les infos du niveau"""
	if not level_manager:
		print("Erreur: level_manager n'existe pas!")
		return

	var level_num = level_manager.get_level_number()
	var config = level_manager.get_current_level_config()

	print("Mise à jour UI - Niveau: ", level_num, ", Difficulté: ", config.difficulty, ", Étoiles: ", level_manager.total_stars)

	if level_label:
		level_label.text = "Niveau " + str(level_num) + " - " + config.difficulty
	else:
		print("Attention: level_label n'existe pas")

	if stars_label:
		stars_label.text = "⭐ Total: " + str(level_manager.total_stars)
	else:
		print("Attention: stars_label n'existe pas")

func _on_previous_level_pressed():
	"""Revenir au niveau précédent"""
	if is_executing:
		return

	if level_manager.current_level > 0:
		level_manager.current_level -= 1
		print("Retour au niveau ", level_manager.current_level + 1)
		generate_level()
		_on_reset_pressed()
		update_ui_labels()
	else:
		print("Déjà au premier niveau")

func _on_next_level_pressed():
	"""Passer au niveau suivant"""
	if is_executing:
		return

	var max_level = level_manager.get_total_levels()
	if level_manager.current_level < max_level - 1:
		level_manager.current_level += 1
		print("Passage au niveau ", level_manager.current_level + 1)
		generate_level()
		_on_reset_pressed()
		update_ui_labels()
	else:
		print("C'est le dernier niveau prédéfini")

func _on_reset_progress_pressed():
	"""Réinitialiser toute la progression"""
	if is_executing:
		return

	print("Réinitialisation de la progression...")
	level_manager.reset_progress()
	generate_level()
	_on_reset_pressed()
	update_ui_labels()
