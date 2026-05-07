// ==============================================================
// FICHIER : lib/main.dart
// RÔLE    : Point d'entrée de l'application Flutter
// C'est le premier fichier qui s'exécute quand on lance l'app
// ==============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour bloquer la rotation
import 'screens/login_page.dart';       // L'écran de connexion
import 'screens/home_page.dart';        // La page principale avec les onglets
import 'services/auth_service.dart';    // Pour vérifier si l'utilisateur est connecté
import 'widgets/app_theme.dart';        // Notre thème personnalisé

// ── Point d'entrée : la première fonction appelée ──
void main() async {
  // Nécessaire avant d'utiliser des plugins Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // On bloque l'orientation en portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // On personnalise la barre de statut (heure, batterie, etc.)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // On lance l'application avec MyApp comme widget racine
  runApp(const MyApp());
}

// ── Widget racine de l'application ──
// C'est le "conteneur" principal de toute l'app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Nom de l'app (visible dans les paramètres du téléphone)
      title: 'Break•App',

      // On retire le bandeau "DEBUG" en haut à droite
      debugShowCheckedModeBanner: false,

      // Notre thème personnalisé (couleurs, styles, etc.)
      theme: AppTheme.darkTheme,

      // L'écran de démarrage (déterminé dynamiquement)
      home: const SplashScreen(),
    );
  }
}

// ==============================================================
// FICHIER : SplashScreen (dans main.dart pour simplicité)
// RÔLE    : Écran de chargement initial
// Vérifie si l'utilisateur est déjà connecté et redirige
// ==============================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Animation d'apparition du logo
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation de fondu (fade in)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this, // Lié au ticker du widget
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // On démarre l'animation
    _animationController.forward();

    // Après un délai, on vérifie la connexion
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // FONCTION : Vérifier si l'utilisateur est connecté
  // et naviguer vers la bonne page
  // ─────────────────────────────────────────────
  Future<void> _checkAuthAndNavigate() async {
    // On attend 1.5 secondes pour voir le splash screen
    await Future.delayed(const Duration(milliseconds: 1500));

    // On vérifie si quelqu'un est connecté
    final authService = AuthService();
    final user = await authService.getCurrentUser();

    if (mounted) {
      // Si un utilisateur est connecté : on va sur son profil
      // Sinon : on va sur la page de connexion
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              user != null ? const HomePage() : const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        // FadeTransition : l'animation de fondu appliquée au contenu
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icône animée ──
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: AppColors.accent,
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              // ── Logo de l'app ──
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'BREAK',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                    TextSpan(
                      text: '•',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: 'APP',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Slogan ──
              const Text(
                'LA COMMUNAUTÉ DES DANSEURS',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 60),

              // ── Indicateur de chargement ──
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
