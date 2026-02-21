# Pipeline technique — Application de fluence

## 1. Objectif du pipeline
L’application de fluence permet d’évaluer la vitesse et la précision de lecture d’un élève.  
Elle enregistre la lecture, mesure le temps, calcule le nombre de mots lus par minute et, à terme, détecte les erreurs ou omissions.

Le pipeline doit être simple, rapide, fiable et adapté à une utilisation en classe.

---

## 2. Vue d’ensemble
Le pipeline se compose de quatre grandes étapes :

1. Affichage du texte et choix du mode de lecture  
2. Enregistrement audio + chronométrage  
3. Analyse de la lecture (vitesse, mots/minute, erreurs)  
4. Sauvegarde et feedback

---

## 3. Étapes détaillées

### 3.1 Affichage du texte
- Le texte est affiché avec options d’accessibilité :
  - police (ex. OpenDyslexic)
  - taille du texte
  - interlignage
  - surlignage une ligne sur deux
- L’enseignant choisit un mode :
  - **Mode 1** : texte visible → démarrage manuel du chrono
  - **Mode 2** : texte visible → démarrage automatique à la première voix détectée
  - **Mode 3** : texte caché → affichage + chrono au clic

Entrée : texte + mode  
Sortie : interface prête pour la lecture

---

### 3.2 Enregistrement audio + chronométrage
- L’élève lit le texte à voix haute.
- L’application enregistre l’audio (WAV ou MP3).
- Le chrono démarre selon le mode choisi.
- L’enregistrement s’arrête manuellement ou automatiquement.

Entrée : voix de l’élève  
Sortie : fichier audio + durée totale

---

### 3.3 Analyse de la lecture
#### 3.3.1 Calcul de la vitesse
- Le texte contient un nombre de mots connu.
- Vitesse = mots lus / durée (en minutes).

#### 3.3.2 Détection d’erreurs (phase 2 du projet)
- Transcription audio → texte (Whisper ou équivalent)
- Normalisation des deux textes
- Alignement mot à mot
- Détection :
  - mots manquants
  - mots incorrects
  - mots ajoutés
  - hésitations (optionnel)

Entrée : audio + texte de référence  
Sortie : vitesse + erreurs (optionnel)

---

### 3.4 Sauvegarde et feedback
- Enregistrement d’une `ReadingSession` :
  - texte_id
  - durée
  - mots/minute
  - date
  - erreurs (optionnel)
- Affichage d’un feedback clair :
  - vitesse
  - progression par rapport aux séances précédentes
  - erreurs éventuelles

Entrée : résultats de l’analyse  
Sortie : feedback + historique

---

## 4. Contraintes techniques

### Performance
- Analyse rapide (< 1 seconde pour la vitesse)
- Transcription optionnelle mais optimisée

### Accessibilité
- Police adaptée
- Taille ajustable
- Surlignage configurable

### Simplicité
- Interface pensée pour un usage en classe
- Peu de clics
- Résultats lisibles immédiatement

---

## 5. Risques et solutions

| Risque | Solution |
|-------|----------|
| Transcription imprécise | Algorithme tolérant + correction manuelle |
| Élève parle trop doucement | Détection automatique du volume minimal |
| Mauvaise qualité audio | Filtre de bruit |
| Temps de traitement trop long | Transcription locale |

---

## 6. Intégration future
- Gamification (badges, niveaux)
- Suivi par élève
- Graphiques de progression
- Textes de difficulté croissante