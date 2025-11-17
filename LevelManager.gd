extends Node

# Configuration des niveaux
var level_configs = [
	# Niveaux débutants (1-5)
	{"difficulty": "Débutant", "grid_size": 3, "min_moves": 3, "max_moves": 4, "obstacles": 0, "special_tiles": []},
	{"difficulty": "Débutant", "grid_size": 3, "min_moves": 3, "max_moves": 5, "obstacles": 1, "special_tiles": []},
	{"difficulty": "Débutant", "grid_size": 4, "min_moves": 4, "max_moves": 5, "obstacles": 1, "special_tiles": []},
	{"difficulty": "Débutant", "grid_size": 4, "min_moves": 4, "max_moves": 6, "obstacles": 2, "special_tiles": []},
	{"difficulty": "Débutant", "grid_size": 4, "min_moves": 5, "max_moves": 6, "obstacles": 2, "special_tiles": []},

	# Niveaux intermédiaires (6-10)
	{"difficulty": "Intermédiaire", "grid_size": 5, "min_moves": 5, "max_moves": 7, "obstacles": 3, "special_tiles": []},
	{"difficulty": "Intermédiaire", "grid_size": 5, "min_moves": 6, "max_moves": 8, "obstacles": 4, "special_tiles": ["teleporter"]},
	{"difficulty": "Intermédiaire", "grid_size": 5, "min_moves": 6, "max_moves": 8, "obstacles": 4, "special_tiles": ["bonus"]},
	{"difficulty": "Intermédiaire", "grid_size": 5, "min_moves": 7, "max_moves": 9, "obstacles": 5, "special_tiles": ["trap"]},
	{"difficulty": "Intermédiaire", "grid_size": 6, "min_moves": 7, "max_moves": 10, "obstacles": 5, "special_tiles": ["teleporter", "bonus"]},

	# Niveaux avancés (11-15)
	{"difficulty": "Avancé", "grid_size": 6, "min_moves": 8, "max_moves": 12, "obstacles": 6, "special_tiles": ["teleporter", "trap"]},
	{"difficulty": "Avancé", "grid_size": 7, "min_moves": 9, "max_moves": 12, "obstacles": 7, "special_tiles": ["teleporter", "bonus", "trap"]},
	{"difficulty": "Avancé", "grid_size": 7, "min_moves": 10, "max_moves": 12, "obstacles": 8, "special_tiles": ["door", "teleporter"]},
	{"difficulty": "Avancé", "grid_size": 7, "min_moves": 10, "max_moves": 13, "obstacles": 8, "special_tiles": ["door", "bonus", "trap"]},
	{"difficulty": "Avancé", "grid_size": 8, "min_moves": 12, "max_moves": 15, "obstacles": 9, "special_tiles": ["teleporter", "door", "trap"]},

	# Niveaux experts (16-20)
	{"difficulty": "Expert", "grid_size": 8, "min_moves": 13, "max_moves": 18, "obstacles": 10, "special_tiles": ["teleporter", "door", "bonus", "trap"]},
	{"difficulty": "Expert", "grid_size": 9, "min_moves": 15, "max_moves": 20, "obstacles": 12, "special_tiles": ["teleporter", "door", "bonus", "trap"]},
	{"difficulty": "Expert", "grid_size": 9, "min_moves": 16, "max_moves": 22, "obstacles": 13, "special_tiles": ["teleporter", "door", "bonus", "trap"]},
	{"difficulty": "Expert", "grid_size": 9, "min_moves": 18, "max_moves": 25, "obstacles": 14, "special_tiles": ["teleporter", "door", "bonus", "trap"]},
	{"difficulty": "Expert", "grid_size": 9, "min_moves": 20, "max_moves": 28, "obstacles": 15, "special_tiles": ["teleporter", "door", "bonus", "trap"]},
]

# Progression du joueur
var current_level = 0
var level_stars = []  # Étoiles obtenues par niveau
var total_stars = 0

func _ready():
	load_progress()

func get_current_level_config():
	"""Retourne la configuration du niveau actuel"""
	if current_level < level_configs.size():
		return level_configs[current_level]
	# Si tous les niveaux sont terminés, générer un niveau aléatoire difficile
	return {"difficulty": "Infini", "grid_size": 9, "min_moves": 20, "max_moves": 30, "obstacles": 15, "special_tiles": ["teleporter", "door", "bonus", "trap"]}

func calculate_stars(moves_used: int, optimal_moves: int) -> int:
	"""Calcule le nombre d'étoiles selon le nombre de mouvements"""
	if moves_used == optimal_moves:
		return 3  # ⭐⭐⭐ Solution optimale
	elif moves_used <= optimal_moves + 3:
		return 2  # ⭐⭐ Très bon
	else:
		return 1  # ⭐ Complété

func complete_level(stars: int):
	"""Marque un niveau comme complété avec un certain nombre d'étoiles"""
	# Sauvegarder les étoiles si c'est mieux que le précédent record
	if current_level >= level_stars.size():
		level_stars.append(stars)
		total_stars += stars
	elif stars > level_stars[current_level]:
		total_stars -= level_stars[current_level]
		level_stars[current_level] = stars
		total_stars += stars

	# Passer au niveau suivant
	current_level += 1
	save_progress()

func reset_progress():
	"""Réinitialise la progression"""
	current_level = 0
	level_stars.clear()
	total_stars = 0
	save_progress()

func save_progress():
	"""Sauvegarde la progression (pour l'instant en mémoire)"""
	# Pour le web, on pourrait utiliser localStorage via JavaScript
	pass

func load_progress():
	"""Charge la progression sauvegardée"""
	# Pour le web, on pourrait charger depuis localStorage
	pass

func get_level_number() -> int:
	"""Retourne le numéro du niveau actuel (1-indexed)"""
	return current_level + 1

func get_total_levels() -> int:
	"""Retourne le nombre total de niveaux prédéfinis"""
	return level_configs.size()
