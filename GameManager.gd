extends Node2D

# Références aux zones
@onready var grid = $Grid
@onready var sequencer = $UI/Sequencer
@onready var direction_selector = $UI/DirectionSelector
@onready var execute_button = $UI/ExecuteButton
@onready var reset_button = $UI/ResetButton
@onready var player_sprite = $Grid/Player
@onready var level_label = $UI/LevelLabel
@onready var stars_label = $UI/StarsLabel

# Gestionnaire de niveaux
var level_manager

# Configuration du jeu (dynamique selon le niveau)
var GRID_SIZE = 5
const CELL_SIZE = 80

# État du jeu
var start_pos = Vector2i(0, 0)
var end_pos = Vector2i(4, 4)
var current_pos = Vector2i(0, 0)
var obstacles = []
var available_moves = []
var selected_sequence = []
var is_executing = false
var optimal_solution = []
var moves_used = 0

# Directions
enum Direction { RIGHT, LEFT, UP, DOWN }
var direction_vectors = {
	Direction.RIGHT: Vector2i(1, 0),
	Direction.LEFT: Vector2i(-1, 0),
	Direction.UP: Vector2i(0, -1),
	Direction.DOWN: Vector2i(0, 1)
}

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
	moves_used = 0

	# Générer un chemin solution
	var solution_path = generate_solution_path()

	# Vérifier que le chemin est valide (atteint bien la destination)
	var test_pos = start_pos
	for dir in solution_path:
		test_pos += direction_vectors[dir]

	# Si le chemin n'atteint pas la destination, régénérer le niveau
	if test_pos != end_pos:
		print("Chemin invalide détecté, régénération...")
		generate_level()
		return

	# Sauvegarder la solution optimale
	optimal_solution = solution_path.duplicate()

	# Compter combien de chaque direction est nécessaire dans la solution
	var direction_counts = [0, 0, 0, 0]  # RIGHT, LEFT, UP, DOWN
	for dir in solution_path:
		direction_counts[dir] += 1

	# Construire available_moves en garantissant qu'on a AU MOINS les mouvements nécessaires
	available_moves.clear()

	# Ajouter les mouvements nécessaires + quelques extras pour chaque direction
	for dir in range(4):
		var needed = direction_counts[dir]
		var extras = randi() % 3 + 2  # 2 à 4 mouvements supplémentaires
		var total = needed + extras

		for i in range(total):
			available_moves.append(dir)

	# Mélanger les mouvements
	available_moves.shuffle()

	# Placer des obstacles (en évitant le chemin solution)
	generate_obstacles(solution_path)

	# Mettre à jour l'affichage
	if grid:
		grid.setup_grid(start_pos, end_pos, obstacles, GRID_SIZE)

func generate_solution_path() -> Array:
	"""Génère un chemin solution du départ à l'arrivée avec des zigzags"""
	var path = []
	var pos = start_pos

	# Créer un chemin avec des zigzags pour plus de variété
	var steps_x = abs(end_pos.x - start_pos.x)
	var steps_y = abs(end_pos.y - start_pos.y)

	var dir_x = Direction.RIGHT if end_pos.x > start_pos.x else Direction.LEFT
	var dir_y = Direction.DOWN if end_pos.y > start_pos.y else Direction.UP

	# Alterner entre mouvements X et Y pour créer un zigzag
	var use_x = true

	while pos != end_pos:
		if use_x and pos.x != end_pos.x:
			# Se déplacer horizontalement
			path.append(dir_x)
			pos += direction_vectors[dir_x]
		elif pos.y != end_pos.y:
			# Se déplacer verticalement
			path.append(dir_y)
			pos += direction_vectors[dir_y]
		else:
			break

		# Alterner pour créer un zigzag
		use_x = not use_x

		# Sécurité
		if path.size() > 30:
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
	solution_positions[pos] = true

	for dir in solution_path:
		pos += direction_vectors[dir]
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
	"""Execute la séquence de mouvements case par case"""
	current_pos = start_pos
	update_player_position()

	for direction in selected_sequence:
		await get_tree().create_timer(0.5).timeout

		var next_pos = current_pos + direction_vectors[direction]

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
		grid.set_player_position(current_pos)

func show_error():
	"""Affiche une animation d'erreur"""
	if player_sprite:
		for i in range(3):
			player_sprite.modulate = Color.RED
			await get_tree().create_timer(0.2).timeout
			player_sprite.modulate = Color.WHITE
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
