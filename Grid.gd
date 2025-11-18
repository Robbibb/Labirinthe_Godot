extends Node2D

var GRID_SIZE = 5
const CELL_SIZE = 80

var start_pos = Vector2i(0, 0)
var end_pos = Vector2i(4, 4)
var obstacles = []
var player_pos = Vector2i(0, 0)
var player_facing = 0  # 0=Nord, 1=Est, 2=Sud, 3=Ouest
var player_flash_color = Color(1.0, 0.5, 0.0)  # Orange par défaut

func _ready():
	print("Grid _ready appelé, GRID_SIZE: ", GRID_SIZE)
	visible = true  # S'assurer que le Grid est visible
	queue_redraw()

func setup_grid(start: Vector2i, end: Vector2i, obs: Array, grid_size: int = 5):
	"""Configure la grille avec les positions de départ, arrivée et obstacles"""
	GRID_SIZE = grid_size
	start_pos = start
	end_pos = end
	player_pos = start
	obstacles = obs.duplicate()
	print("Grid setup_grid appelé - Taille: ", GRID_SIZE, "x", GRID_SIZE, ", Start: ", start, ", End: ", end, ", Obstacles: ", obstacles.size())
	queue_redraw()

func set_player_position(pos: Vector2i, facing: int = 0):
	"""Met à jour la position et l'orientation du joueur"""
	player_pos = pos
	player_facing = facing
	queue_redraw()

func grid_to_pixel(grid_pos: Vector2i) -> Vector2:
	"""Convertit une position grille en position pixel"""
	return Vector2(grid_pos.x * CELL_SIZE + CELL_SIZE / 2, grid_pos.y * CELL_SIZE + CELL_SIZE / 2)

func _draw():
	"""Dessine la grille"""
	print("Grid _draw appelé - GRID_SIZE: ", GRID_SIZE, ", Position: ", position)

	# Dessiner les cases
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var rect = Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
			var pos = Vector2i(x, y)

			# Couleur de fond de la case avec dégradé
			var color = Color(0.95, 0.95, 0.98)  # Blanc-bleuté léger
			if pos == start_pos:
				color = Color(0.7, 0.9, 1.0)  # Bleu clair pour le départ
			elif pos == end_pos:
				color = Color(0.7, 1.0, 0.7)  # Vert clair pour l'arrivée
			elif obstacles.has(pos):
				# On ne dessine pas de fond pour les obstacles
				color = Color(0.85, 0.85, 0.88)

			draw_rect(rect, color, true)
			draw_rect(rect, Color(0.6, 0.6, 0.7), false, 3.0)  # Bordure plus épaisse

	# Dessiner les obstacles en premier (derrière les autres éléments)
	for obstacle_pos in obstacles:
		draw_obstacle(grid_to_pixel(obstacle_pos))

	# Dessiner les labels de colonnes (A, B, C, D, E, F, G, H, I)
	var columns = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]
	for i in range(min(GRID_SIZE, columns.size())):
		var label_pos = Vector2(i * CELL_SIZE + CELL_SIZE / 2 - 8, -10)
		draw_string(ThemeDB.fallback_font, label_pos, columns[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.3, 0.3, 0.5))

	# Dessiner les labels de lignes (1, 2, 3, 4, 5)
	for i in range(GRID_SIZE):
		var label_pos = Vector2(-20, i * CELL_SIZE + CELL_SIZE / 2 + 5)
		draw_string(ThemeDB.fallback_font, label_pos, str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.3, 0.3, 0.5))

	# Dessiner le drapeau d'arrivée
	draw_flag(grid_to_pixel(end_pos))

	# Dessiner le point de départ
	draw_start_marker(grid_to_pixel(start_pos))

	# Dessiner le joueur (toujours au-dessus)
	draw_player(grid_to_pixel(player_pos))

func draw_player(pos: Vector2):
	"""Dessine un personnage mignon pour le joueur avec son orientation très visible"""
	# Calculer la rotation selon l'orientation
	# 0=Nord(haut), 1=Est(droite), 2=Sud(bas), 3=Ouest(gauche)
	var rotation = player_facing * PI / 2  # 0°, 90°, 180°, 270°

	# Corps principal (cercle avec la couleur flash)
	draw_circle(pos, 24, player_flash_color)
	# Contour blanc
	draw_arc(pos, 24, 0, TAU, 32, Color.WHITE, 3.0)

	# GROSSE FLÈCHE directionnelle pointant vers l'avant (très visible)
	var arrow_front = Vector2(0, -32)  # Pointe vers le haut par défaut
	var arrow_front_rotated = arrow_front.rotated(rotation)
	var arrow_front_points = PackedVector2Array([
		pos + arrow_front_rotated,  # Pointe
		pos + arrow_front_rotated + Vector2(-10, 12).rotated(rotation),  # Base gauche
		pos + arrow_front_rotated + Vector2(0, 8).rotated(rotation),  # Centre base
		pos + arrow_front_rotated + Vector2(10, 12).rotated(rotation)  # Base droite
	])
	# Fond de la flèche
	draw_colored_polygon(arrow_front_points, Color.WHITE)
	# Contour noir
	draw_polyline(PackedVector2Array([
		arrow_front_points[0],
		arrow_front_points[1],
		arrow_front_points[2],
		arrow_front_points[3],
		arrow_front_points[0]
	]), Color.BLACK, 3.0)

	# Yeux PLUS GROS (tournés dans la direction)
	var eye_offset = 9
	var eye1_local = Vector2(-eye_offset, -8)
	var eye2_local = Vector2(eye_offset, -8)

	# Rotation des yeux
	var eye1_rotated = eye1_local.rotated(rotation)
	var eye2_rotated = eye2_local.rotated(rotation)

	# Dessiner les yeux plus gros et expressifs
	draw_circle(pos + eye1_rotated, 6, Color.WHITE)
	draw_circle(pos + eye2_rotated, 6, Color.WHITE)
	draw_circle(pos + eye1_rotated, 3, Color.BLACK)
	draw_circle(pos + eye2_rotated, 3, Color.BLACK)
	# Reflets dans les yeux
	draw_circle(pos + eye1_rotated + Vector2(-1, -1), 1, Color.WHITE)
	draw_circle(pos + eye2_rotated + Vector2(-1, -1), 1, Color.WHITE)

	# Sourire (tourné dans la direction)
	var smile_points = PackedVector2Array()
	for i in range(7):
		var angle = PI * 0.2 + (i * PI * 0.6 / 6)
		var smile_radius = 11
		var local_point = Vector2(cos(angle) * smile_radius, sin(angle) * smile_radius + 4)
		smile_points.append(pos + local_point.rotated(rotation))
	draw_polyline(smile_points, Color.BLACK, 3.5)

	# Petit nez/bec pointant dans la direction pour encore plus de clarté
	var nose_local = Vector2(0, -2)
	var nose_rotated = nose_local.rotated(rotation)
	draw_circle(pos + nose_rotated, 2, Color(0.9, 0.4, 0.2))

func draw_flag(pos: Vector2):
	"""Dessine un drapeau coloré pour l'arrivée"""
	# Mât du drapeau
	draw_line(pos + Vector2(5, -20), pos + Vector2(5, 15), Color(0.4, 0.3, 0.2), 3.0)

	# Drapeau triangulaire
	var flag_points = PackedVector2Array([
		pos + Vector2(5, -20),
		pos + Vector2(30, -10),
		pos + Vector2(5, 0)
	])
	draw_colored_polygon(flag_points, Color(1.0, 0.8, 0.0))  # Jaune doré
	draw_polyline(flag_points, Color(0.8, 0.6, 0.0), 2.0)

	# Base du drapeau
	draw_circle(pos + Vector2(5, 15), 5, Color(0.4, 0.3, 0.2))

	# Étoile sur le drapeau
	draw_star(pos + Vector2(15, -10), 5, Color.WHITE)

func draw_start_marker(pos: Vector2):
	"""Dessine un marqueur de départ"""
	# Cercle de départ
	draw_circle(pos, 18, Color(0.3, 0.6, 1.0))
	# Contour blanc
	draw_arc(pos, 18, 0, TAU, 32, Color.WHITE, 3.0)

	# Flèche vers le haut
	var arrow_points = PackedVector2Array([
		pos + Vector2(0, -8),
		pos + Vector2(-6, 2),
		pos + Vector2(-2, 2),
		pos + Vector2(-2, 8),
		pos + Vector2(2, 8),
		pos + Vector2(2, 2),
		pos + Vector2(6, 2)
	])
	draw_colored_polygon(arrow_points, Color.WHITE)

func draw_obstacle(pos: Vector2):
	"""Dessine un mur avec texture de briques"""
	var brick_size = 15
	var offset_x = -30
	var offset_y = -30

	# Dessiner plusieurs "briques"
	for row in range(4):
		for col in range(4):
			var brick_x = pos.x + offset_x + col * brick_size + (brick_size / 2 if row % 2 == 1 else 0)
			var brick_y = pos.y + offset_y + row * brick_size

			# Couleur variant légèrement pour chaque brique
			var brick_color = Color(0.5 + randf() * 0.1, 0.3 + randf() * 0.1, 0.25 + randf() * 0.1)
			var brick_rect = Rect2(brick_x, brick_y, brick_size - 2, brick_size - 2)

			draw_rect(brick_rect, brick_color, true)
			draw_rect(brick_rect, Color(0.3, 0.2, 0.15), false, 1.5)

func draw_star(pos: Vector2, size: float, color: Color):
	"""Dessine une étoile à 5 branches"""
	var points = PackedVector2Array()
	for i in range(10):
		var angle = -PI / 2 + i * PI / 5
		var radius = size if i % 2 == 0 else size * 0.4
		points.append(pos + Vector2(cos(angle) * radius, sin(angle) * radius))
	draw_colored_polygon(points, color)
