# 🚀 Guide de Déploiement - Labyrinthe Puzzle

## Problème actuel

La branche `gh-pages` n'existe pas encore car le workflow GitHub Actions ne s'est pas encore exécuté avec succès.

## ✅ Solution : Déclencher le workflow manuellement

### Étape 1 : Aller sur la page Actions
👉 **https://github.com/Robbibb/Labirinthe_Godot/actions**

### Étape 2 : Sélectionner le workflow
- Dans la liste de gauche, cliquez sur **"Deploy to GitHub Pages"**

### Étape 3 : Déclencher manuellement
- Cliquez sur le bouton **"Run workflow"** (en haut à droite)
- Sélectionnez la branche : **claude/godot-puzzle-game-01JS4RzFSkCE3Pg6hetEFY7L**
- Cliquez sur **"Run workflow"** (bouton vert)

### Étape 4 : Attendre l'exécution
- Le workflow va s'exécuter (environ 3-5 minutes)
- Vous verrez une pastille orange puis verte quand c'est terminé
- Une fois terminé, la branche `gh-pages` sera créée automatiquement

### Étape 5 : Configurer GitHub Pages
Une fois le workflow terminé :
1. Allez sur **https://github.com/Robbibb/Labirinthe_Godot/settings/pages**
2. Sous "Build and deployment" :
   - **Source :** Deploy from a branch
   - **Branch :** gh-pages
   - **Folder :** / (root)
3. Cliquez sur **Save**

### Étape 6 : Accéder au jeu
Après 2-3 minutes, le jeu sera disponible à :
👉 **https://robbibb.github.io/Labirinthe_Godot/**

---

## 🔍 Vérifier si le workflow s'est déjà exécuté

Si vous voyez déjà un workflow en cours d'exécution ou terminé sur https://github.com/Robbibb/Labirinthe_Godot/actions, passez directement à l'étape 5.

---

## ⚠️ Si le workflow échoue

Si le workflow échoue, vérifiez les logs d'erreur dans l'onglet Actions et partagez-les pour qu'on puisse corriger le problème.

---

## 📋 Résumé des fichiers créés

- `GameManager.gd` - Logique principale du jeu
- `Grid.gd` - Gestion du damier 5x5
- `Sequencer.gd` - Zone de séquençage des mouvements
- `DirectionSelector.gd` - Sélection des directions
- `Main.tscn` - Scène principale
- `.github/workflows/deploy.yml` - Déploiement automatique
- `export_presets.cfg` - Configuration export HTML5

Tout est prêt, il suffit juste de déclencher le workflow ! 🎉
