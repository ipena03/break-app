// ==============================================================
// FICHIER : lib/screens/login_page.dart
// RÔLE    : L'écran de connexion (email + mot de passe)
// C'est la première page que voit l'utilisateur
// ==============================================================

import 'package:flutter/material.dart';
import '../services/auth_service.dart';       // Notre service d'authentification
import '../widgets/app_theme.dart';           // Couleurs et thème
import '../widgets/custom_widgets.dart';      // Nos widgets réutilisables
import 'register_page.dart';                  // Page d'inscription
import 'home_page.dart';                      // Page principale avec onglets

// LoginPage est un StatefulWidget car il a des données qui changent
// (les champs de texte, le chargement, les erreurs)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// L'état de la page (tout ce qui peut changer)
class _LoginPageState extends State<LoginPage> {
  // ── Contrôleurs pour lire ce que l'utilisateur tape ──
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ── Service d'authentification ──
  final AuthService _authService = AuthService();

  // ── Variables d'état ──
  bool _isLoading = false;    // True = on affiche un indicateur de chargement
  String? _errorMessage;      // Message d'erreur (null = pas d'erreur)
  bool _showPassword = false; // True = le mot de passe est visible

  // Libérer la mémoire quand la page est détruite (bonne pratique)
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // FONCTION : Tentative de connexion
  // ─────────────────────────────────────────────
  Future<void> _handleLogin() async {
    // On récupère ce que l'utilisateur a tapé
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Vérification basique : les champs ne doivent pas être vides
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs.';
      });
      return; // On arrête la fonction ici
    }

    // On passe en mode "chargement"
    setState(() {
      _isLoading = true;
      _errorMessage = null; // On efface les anciennes erreurs
    });

    // On appelle le service de connexion
    final error = await _authService.login(email, password);

    // On sort du mode chargement
    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      // Il y a une erreur : on l'affiche
      setState(() {
        _errorMessage = error;
      });
    } else {
      // Connexion réussie ! On navigue vers le profil
      if (mounted) { // Vérification que la page existe encore
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // CONSTRUCTION DE L'INTERFACE
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond de l'écran
      backgroundColor: AppColors.background,

      // Rend le fond "scrollable" pour éviter le débordement sur petits écrans
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // ── Logo de l'application ──
              const AppLogo(fontSize: 36),

              const SizedBox(height: 8),

              // ── Sous-titre ──
              const Text(
                'LA COMMUNAUTÉ DES DANSEURS',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 60),

              // ── Titre de la section ──
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CONNEXION',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Champ Email ──
              CustomTextField(
                label: 'Email',
                hint: 'votre@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 16),

              // ── Champ Mot de passe ──
              // Ici on utilise un TextField direct pour gérer l'icône "œil"
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword, // Cache ou montre le mot de passe
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  hintText: '••••••••',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  // Icône "œil" pour afficher/masquer le mot de passe
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      // On bascule l'état d'affichage
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Message d'erreur (visible seulement si erreur) ──
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_errorMessage != null) const SizedBox(height: 16),

              // ── Bouton de connexion ──
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin, // Désactivé si chargement
                child: _isLoading
                    // Si chargement : on affiche un spinner
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    // Sinon : texte normal
                    : const Text('SE CONNECTER'),
              ),

              const SizedBox(height: 32),

              // ── Séparateur ──
              const OrDivider(),

              const SizedBox(height: 32),

              // ── Lien vers l'inscription ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pas encore de compte ? ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    // Au clic, on navigue vers la page d'inscription
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "S'INSCRIRE",
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
