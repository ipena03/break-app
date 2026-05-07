# 🕺 Break•App — Application Flutter Breakdance

Application mobile Flutter dédiée à la communauté breakdance.  
Développée avec **Flutter/Dart**, prête à lancer dans **Visual Studio Code**.

---

## 📁 Structure du projet

```
breakdance_app/
├── lib/
│   ├── main.dart                    ← Point d'entrée + SplashScreen
│   ├── models/
│   │   └── user_model.dart          ← Structure de données utilisateur
│   ├── services/
│   │   └── auth_service.dart        ← Logique d'authentification
│   ├── screens/
│   │   ├── login_page.dart          ← Écran de connexion
│   │   ├── register_page.dart       ← Écran d'inscription
│   │   ├── profile_page.dart        ← Écran de profil
│   │   └── edit_profile_page.dart   ← Écran de modification du profil
│   └── widgets/
│       ├── app_theme.dart           ← Thème et couleurs
│       └── custom_widgets.dart      ← Widgets réutilisables
├── assets/
│   └── images/                      ← (vide, pour de futures images)
└── pubspec.yaml                     ← Configuration et dépendances
```

---

## 🚀 Lancement du projet

### Prérequis
1. **Flutter SDK** installé : https://flutter.dev/docs/get-started/install
2. **Visual Studio Code** avec l'extension **Flutter** + **Dart**
3. Un émulateur Android/iOS ou un vrai appareil connecté

### Étapes

```bash
# 1. Aller dans le dossier du projet
cd breakdance_app

# 2. Installer les dépendances
flutter pub get

# 3. Vérifier que tout est bien configuré
flutter doctor

# 4. Lancer l'application
flutter run
```

### Dans VS Code
1. Ouvre le dossier `breakdance_app` dans VS Code
2. Appuie sur `F5` ou clique sur **Run > Start Debugging**
3. Choisis ton émulateur/appareil dans la barre du bas

---

## ✨ Fonctionnalités

| Écran | Description |
|-------|-------------|
| **Splash Screen** | Écran de chargement avec animation fade-in |
| **Connexion** | Email + mot de passe avec toggle visibilité |
| **Inscription** | Email, pseudo, mot de passe + confirmation |
| **Profil** | Photo, pseudo, email, stats visuelles |
| **Modifier Profil** | Changer pseudo + photo (galerie ou caméra) |

---

## 🎨 Design

- **Palette** : Noir profond `#0D0D0D` + Rouge vif `#E63946` + Blanc
- **Style** : Dark theme, minimaliste, typographie espacée
- **Animations** : Fade-in sur le splash screen

---

## 🔐 Authentification (Simulation)

L'authentification est **simulée localement** avec `SharedPreferences`.  
Les données sont stockées sur l'appareil (pas de serveur).

> ⚠️ **Pour une vraie app**, remplace `auth_service.dart` par Firebase Auth :
> - Ajoute `firebase_auth` et `firebase_core` dans `pubspec.yaml`
> - Suis le guide : https://firebase.google.com/docs/flutter/setup

---

## 📦 Dépendances

| Package | Utilisation |
|---------|------------|
| `shared_preferences` | Stockage local des données utilisateur |
| `image_picker` | Sélection de photo depuis galerie ou caméra |

---

## 🛠️ Modifier l'application

### Changer les couleurs
→ Modifie `lib/widgets/app_theme.dart` dans la classe `AppColors`

### Ajouter une nouvelle page
1. Crée `lib/screens/ma_nouvelle_page.dart`
2. Importe-la là où tu veux naviguer
3. Utilise `Navigator.push()` pour y aller

### Connecter Firebase
1. `flutter pub add firebase_core firebase_auth`
2. Suis le guide Firebase Flutter
3. Remplace les méthodes dans `auth_service.dart`

---

*Projet créé avec Flutter • Commenté en français pour les débutants* 🇫🇷
