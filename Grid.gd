extends Node2D

var GRID_SIZE = 5
const CELL_SIZE = 80

var start_pos = Vector2i(0, 0)
var end_pos = Vector2i(4, 4)
var obstacles = []
var player_pos = Vector2i(0, 0)
var player_flash_color = Color(1.0, 0.5, 0.0)  # Orange par défaut

func _ready():
	queue_redraw()

func setup_grid(start: Vector2i, end: Vector2i, obs: Array, grid_size: int = 5):
	"""Configure la grille avec les positions de départ, arrivée et obstacles"""
	GRID_SIZE = grid_size
	start_pos = start
	end_pos = end
	player_pos = start
	obstacles = obs.duplicate()
	queue_redraw()

func set_player_position(pos: Vector2i):
	"""Met à jour la position du joueur"""
	player_pos = pos
	queue_redraw()

func grid_to_pixel(grid_pos: Vector2i) -> Vector2:
	"""Convertit une position grille en position pixel"""
	return Vector2(grid_pos.x * CELL_SIZE + CELL_SIZE / 2, grid_pos.y * CELL_SIZE + CELL_SIZE / 2)

func _draw():
	"""Dessine la grille"""
	# Dessiner les cases
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var rect = Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
			var pos = Vector2i(x, y)

			# Couleur de fond de la case
			var color = Color.WHITE
			if pos == start_pos:
				color = Color(0.5, 0.8, 1.0)  # Bleu clair pour le départ
			elif pos == end_pos:
				color = Color(0.5, 1.0, 0.5)  # Vert clair pour l'arrivée
			elif obstacles.has(pos):
				color = Color(0.3, 0.3, 0.3)  # Gris foncé pour les obstacles

			draw_rect(rect, color, true)
			draw_rect(rect, Color.BLACK, false, 2.0)

	# Dessiner les labels de colonnes (A, B, C, D, E, F, G, H, I)
	var columns = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]
	for i in range(min(GRID_SIZE, columns.size())):
		var label_pos = Vector2(i * CELL_SIZE + CELL_SIZE / 2 - 8, -10)
		draw_string(ThemeDB.fallback_font, label_pos, columns[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.BLACK)

	# Dessiner les labels de lignes (1, 2, 3, 4, 5)
	for i in range(GRID_SIZE):
		var label_pos = Vector2(-20, i * CELL_SIZE + CELL_SIZE / 2 + 5)
		draw_string(ThemeDB.fallback_font, label_pos, str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.BLACK)

	# Dessiner les icônes de départ et arrivée
	draw_circle(grid_to_pixel(start_pos), 15, Color(0.2, 0.4, 0.8))
	draw_string(ThemeDB.fallback_font, grid_to_pixel(start_pos) - Vector2(8, -5), "D", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)

	draw_circle(grid_to_pixel(end_pos), 15, Color(0.2, 0.8, 0.2))
	draw_string(ThemeDB.fallback_font, grid_to_pixel(end_pos) - Vector2(8, -5), "A", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)

	# Dessiner le joueur avec la couleur flash
	draw_circle(grid_to_pixel(player_pos), 18, player_flash_color)
	draw_string(ThemeDB.fallback_font, grid_to_pixel(player_pos) - Vector2(8, -5), "P", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
