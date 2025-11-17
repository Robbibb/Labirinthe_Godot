# Labyrinthe Puzzle - Godot Game

Un jeu de puzzle/labyrinthe créé avec Godot 4.2 et déployé sur GitHub Pages.

## Description du Jeu

Le jeu se compose de trois zones principales :

### Zone 1 - Le Damier
- Grille de 5x5 cases (A-E horizontalement, 1-5 verticalement)
- Point de départ (marqué "D") et point d'arrivée (marqué "A")
- Obstacles placés aléatoirement sur la grille

### Zone 2 - Séquenceur de Déplacements
- Affiche la séquence de mouvements sélectionnée
- Les flèches apparaissent dans l'ordre de sélection

### Zone 3 - Sélection des Directions
- Boutons de direction (↑ ↓ ← →)
- Cliquez sur une flèche pour l'ajouter à votre séquence
- Les boutons se grisent après utilisation

## Comment Jouer

1. **Observer** : Regardez la position de départ (D) et d'arrivée (A) sur le damier
2. **Planifier** : Trouvez le chemin pour atteindre l'arrivée en évitant les obstacles
3. **Sélectionner** : Cliquez sur les flèches disponibles pour créer votre séquence
4. **Exécuter** : Appuyez sur le bouton "Exécuter" pour tester votre solution
5. **Réessayer** : Si vous vous trompez, utilisez le bouton "Reset" pour recommencer

## Fonctionnalités

- ✅ Génération aléatoire de niveaux
- ✅ Animation case par case des déplacements
- ✅ Détection de collision avec les obstacles
- ✅ Feedback visuel (rouge si erreur, vert si victoire)
- ✅ Système de reset pour recommencer
- ✅ Interface intuitive et claire

## Jouer en Ligne

Le jeu est disponible en ligne à l'adresse :
**https://robbibb.github.io/Labirinthe_Godot/**

## Développement

Ce projet utilise Godot 4.2.2 et est automatiquement déployé sur GitHub Pages via GitHub Actions.

### Structure du Projet

```
├── Main.tscn              # Scène principale
├── GameManager.gd         # Gestionnaire principal du jeu
├── Grid.gd               # Gestion du damier
├── Sequencer.gd          # Gestion de la zone 2
├── DirectionSelector.gd  # Gestion de la zone 3
└── .github/
    └── workflows/
        └── deploy.yml    # Configuration du déploiement automatique
```

## Technologies

- **Moteur** : Godot 4.2.2
- **Langage** : GDScript
- **Export** : HTML5/WebGL
- **Hébergement** : GitHub Pages
- **CI/CD** : GitHub Actions

## Licence

Ce projet est créé à des fins éducatives et de démonstration.
