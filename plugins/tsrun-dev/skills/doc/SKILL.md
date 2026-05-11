---
name: doc
description: Generate or update project documentation. Use when the user asks to document code, update docs, or create technical/user documentation.
argument-hint: [target] [options]
---

Generate or update documentation for: $ARGUMENTS

## Instructions

1. **Analyse le contexte** : Lis les fichiers cibles, explore la structure du projet, identifie les frameworks et technologies utilisees.

2. **Identifie la doc existante** : Cherche les fichiers de documentation existants (`docs/`, `README.md`, etc.) pour respecter le style et la structure en place.

3. **Adapte le format au besoin** :
   - Si la cible est un **fichier ou module** : documente les fonctions, classes, parametres, retours, et exemples d'utilisation
   - Si la cible est un **container/service** : documente le role, les frameworks, les fichiers principaux, la configuration
   - Si la cible est un **projet entier** : produis une vue d'ensemble avec architecture, composants, flux, et deploiement
   - Si la cible est **user** : redige une doc utilisateur avec les etapes d'utilisation, laisse des champs libres pour captures d'ecran

4. **Style** :
   - Markdown, en francais sauf si demande autrement
   - Tableaux pour les listes structurees (frameworks, champs, config)
   - Sections claires avec separateurs `---`
   - Pas d'emojis sauf demande explicite
   - Concis et precis, pas de remplissage

5. **Ecris la doc** dans le dossier `docs/` du projet ou a l'emplacement demande. Prefere mettre a jour un fichier existant plutot que d'en creer un nouveau.
