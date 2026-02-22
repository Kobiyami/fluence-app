# TECHNICAL BACKLOG — fluence-app (MVP)

## 1. Architecture générale

### Modèles nécessaires
- Student
- Text
- Session

### Relations
- Un Student a plusieurs Sessions
- Un Text a plusieurs Sessions
- Une Session appartient à un Student et à un Text

### Tables
- students
- texts
- sessions

---

## 2. Migrations

### students
- first_name (string)
- last_name (string)
- code (string)
- timestamps

### texts
- title (string)
- content (text)
- word_count (integer)
- timestamps

### sessions
- student_id (references)
- text_id (references)
- duration_seconds (integer)
- score_wpm (integer)
- timestamps

---

## 3. Routes (MVP)

### Élève
- /students
- /students/:id
- /login

### Textes
- /texts
- /texts/:id

### Séance
- /sessions/new
- /sessions/start
- /sessions/stop
- /sessions/:id

---

## 4. Écrans à développer

### Écran 1 — Choix du profil
- liste des élèves
- bouton “changer de profil”

### Écran 2 — Saisie du code
- champ code
- validation

### Écran 3 — Choix du texte
- liste des textes
- aperçu

### Écran 4 — Prêt à lire
- bouton “Démarrer”

### Écran 5 — Chronomètre
- chrono en cours
- bouton “Arrêter”

### Écran 6 — Résultats
- temps
- score
- feedback

---

## 5. Tâches techniques du Sprint 1

### Backend
- [ ] Créer modèle Student
- [ ] Créer modèle Text
- [ ] Créer modèle Session
- [ ] Générer migrations
- [ ] Ajouter validations
- [ ] Calcul automatique du score dans Session

### Frontend / Views
- [ ] Page sélection élève
- [ ] Page saisie code
- [ ] Page sélection texte
- [ ] Page “prêt à lire”
- [ ] Page chronomètre
- [ ] Page résultats

### Logique
- [ ] Chronomètre JS simple
- [ ] Calcul score (mots / durée)
- [ ] Sauvegarde automatique de la session

---

## 6. Risques techniques

- Gestion du chronomètre côté front
- Synchronisation front/back
- Sécurité minimale du code élève
- Interface tablette (touch events)

---

## 7. Dépendances éventuelles

MVP :
- aucune dépendance externe obligatoire

Plus tard :
- Chart.js (graphique)
- Stimulus (organisation JS)
- Devise (auth enseignant)