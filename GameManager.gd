extends Node2D

# Références aux zones
@onready var grid = $Grid
@onready var sequencer = $UI/Sequencer
@onready var direction_selector = $UI/DirectionSelector
@onready var execute_button = $UI/ExecuteButton
@onready var reset_button = $UI/ResetButton
@onready var player_sprite = $Grid/Player

# Configuration du jeu
const GRID_SIZE = 5
const CELL_SIZE = 80

# État du jeu
var start_pos = Vector2i(0, 0)
var end_pos = Vector2i(4, 4)
var current_pos = Vector2i(0, 0)
var obstacles = []
var available_moves = []
var selected_sequence = []
var is_executing = false

# Directions
enum Direction { RIGHT, LEFT, UP, DOWN }
var direction_vectors = {
	Direction.RIGHT: Vector2i(1, 0),
	Direction.LEFT: Vector2i(-1, 0),
	Direction.UP: Vector2i(0, -1),
	Direction.DOWN: Vector2i(0, 1)
}

func _ready():
	generate_level()
	setup_ui()
	update_player_position()

func generate_level():
	"""Génère un niveau aléatoire avec un chemin solution"""
	randomize()

	# Choisir départ et arrivée
	start_pos = Vector2i(randi() % GRID_SIZE, randi() % GRID_SIZE)
	end_pos = Vector2i(randi() % GRID_SIZE, randi() % GRID_SIZE)

	# S'assurer que départ et arrivée sont différents
	while end_pos == start_pos:
		end_pos = Vector2i(randi() % GRID_SIZE, randi() % GRID_SIZE)

	current_pos = start_pos

	# Générer un chemin solution
	var solution_path = generate_solution_path()
	available_moves = solution_path.duplicate()

	# Ajouter des mouvements supplémentaires variés (au moins 2 de chaque direction)
	var extra_per_direction = 2
	for dir in range(4):
		for i in range(extra_per_direction):
			available_moves.append(dir)

	# Ajouter quelques mouvements aléatoires supplémentaires
	var random_extras = randi() % 4 + 2
	for i in range(random_extras):
		available_moves.append(randi() % 4)

	# Mélanger les mouvements
	available_moves.shuffle()

	# Placer des obstacles (en évitant le chemin solution)
	generate_obstacles(solution_path)

	# Mettre à jour l'affichage
	if grid:
		grid.setup_grid(start_pos, end_pos, obstacles)

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

	# Calculer les positions du chemin solution
	var solution_positions = {}
	var pos = start_pos
	solution_positions[pos] = true

	for dir in solution_path:
		pos += direction_vectors[dir]
		if is_valid_position(pos):
			solution_positions[pos] = true

	# Ajouter des obstacles aléatoires
	var num_obstacles = randi() % 8 + 3
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
			await show_victory()
			await get_tree().create_timer(1.0).timeout
			generate_level()
			_on_reset_pressed()
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

func show_victory():
	"""Affiche une animation de victoire"""
	if player_sprite:
		for i in range(3):
			player_sprite.modulate = Color.GREEN
			await get_tree().create_timer(0.2).timeout
			player_sprite.modulate = Color.WHITE
			await get_tree().create_timer(0.2).timeout
