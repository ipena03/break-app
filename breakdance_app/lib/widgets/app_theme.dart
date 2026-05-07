// ==============================================================
// FICHIER : lib/widgets/app_theme.dart
// RÔLE    : Définit les couleurs, styles et thème général de l'app
// Centraliser les couleurs ici permet de les changer facilement
// ==============================================================

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// COULEURS PRINCIPALES DE L'APPLICATION
// Inspirées du breakdance : noir, rouge, blanc
// ─────────────────────────────────────────────
class AppColors {
  // Couleur principale : noir profond (comme la scène)
  static const Color primary = Color(0xFF0D0D0D);

  // Couleur d'accent : rouge vif (énergie, passion)
  static const Color accent = Color(0xFFE63946);

  // Fond des écrans
  static const Color background = Color(0xFF111111);

  // Fond des cartes/containers
  static const Color surface = Color(0xFF1E1E1E);

  // Texte principal (blanc)
  static const Color textPrimary = Color(0xFFF5F5F5);

  // Texte secondaire (gris clair)
  static const Color textSecondary = Color(0xFF9E9E9E);

  // Bordures et séparateurs
  static const Color border = Color(0xFF2E2E2E);

  // Couleur de succès (vert)
  static const Color success = Color(0xFF4CAF50);

  // Constructeur privé pour empêcher l'instanciation
  AppColors._();
}

// ─────────────────────────────────────────────
// THÈME GLOBAL DE L'APPLICATION
// On définit ici comment l'app va "ressembler" globalement
// ─────────────────────────────────────────────
class AppTheme {
  // La méthode statique qui retourne le ThemeData complet
  static ThemeData get darkTheme {
    return ThemeData(
      // On utilise un thème sombre (dark)
      brightness: Brightness.dark,

      // Couleur principale du thème
      primaryColor: AppColors.accent,

      // Couleur de fond des pages
      scaffoldBackgroundColor: AppColors.background,

      // Schéma de couleurs (Flutter 3+)
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),

      // Style des boutons principaux (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,      // Fond rouge
          foregroundColor: Colors.white,          // Texte blanc
          minimumSize: const Size(double.infinity, 52), // Bouton pleine largeur
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Coins arrondis
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2, // Espacement des lettres
          ),
        ),
      ),

      // Style des champs de texte (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,                           // Fond rempli
        fillColor: AppColors.surface,           // Couleur du fond
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),

      // Style de l'AppBar (barre du haut)
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0,                           // Pas d'ombre
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }

  // Constructeur privé
  AppTheme._();
}
