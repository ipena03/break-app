// ==============================================================
// FICHIER : lib/widgets/custom_widgets.dart
// RÔLE    : Widgets personnalisés et réutilisables dans toute l'app
// Au lieu de répéter le même code partout, on crée des "briques"
// ==============================================================

import 'dart:io';                   // Pour afficher les images depuis le téléphone
import 'package:flutter/material.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────
// WIDGET : Champ de texte personnalisé
// Un TextField stylisé aux couleurs de l'app
// ─────────────────────────────────────────────
class CustomTextField extends StatelessWidget {
  // Les paramètres que ce widget accepte
  final String label;              // Texte du label (ex: "Email")
  final String hint;               // Texte indicatif (ex: "votre@email.com")
  final TextEditingController controller; // Pour lire la valeur saisie
  final bool isPassword;           // Est-ce un champ mot de passe ?
  final TextInputType keyboardType; // Type de clavier (email, texte, etc.)
  final IconData? prefixIcon;      // Icône à gauche du champ

  // Constructeur avec les paramètres
  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,       // Par défaut : pas un mot de passe
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // On retourne un TextField stylisé
    return TextField(
      controller: controller,
      obscureText: isPassword,     // Cache le texte si c'est un mot de passe
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        // Icône à gauche si fournie
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET : Photo de profil circulaire
// Affiche une photo ou un avatar par défaut
// ─────────────────────────────────────────────
class ProfileAvatar extends StatelessWidget {
  final String? photoPath; // Chemin de la photo (peut être null)
  final double size;       // Taille du cercle
  final VoidCallback? onTap; // Action au clic (optionnel)

  const ProfileAvatar({
    super.key,
    this.photoPath,
    this.size = 100,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // On déclenche l'action si l'utilisateur appuie

      // Stack = superposition de widgets (photo + badge modifier)
      child: Stack(
        children: [
          // Le cercle avec la photo ou l'avatar
          CircleAvatar(
            radius: size / 2,
            backgroundColor: AppColors.surface,

            // On choisit l'image à afficher
            backgroundImage: photoPath != null && photoPath!.isNotEmpty
                ? FileImage(File(photoPath!)) as ImageProvider // Photo réelle
                : null,

            // Si pas de photo : on affiche une icône
            child: (photoPath == null || photoPath!.isEmpty)
                ? Icon(
                    Icons.person,
                    size: size * 0.5,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),

          // Badge "modifier" en bas à droite (visible seulement si onTap est fourni)
          if (onTap != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET : Tag de style breakdance
// Un petit badge coloré (ex: "B-BOY", "CREW")
// ─────────────────────────────────────────────
class BreakTag extends StatelessWidget {
  final String label;
  final Color? color;

  const BreakTag({
    super.key,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppColors.accent).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? AppColors.accent).withOpacity(0.5),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color ?? AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET : Séparateur avec texte ("ou")
// ─────────────────────────────────────────────
class OrDivider extends StatelessWidget {
  final String text;

  const OrDivider({super.key, this.text = 'ou'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Ligne à gauche
        const Expanded(
          child: Divider(color: AppColors.border, thickness: 1),
        ),
        // Texte au centre
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        // Ligne à droite
        const Expanded(
          child: Divider(color: AppColors.border, thickness: 1),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET : Logo de l'application
// Le titre stylisé "BREAK•APP"
// ─────────────────────────────────────────────
class AppLogo extends StatelessWidget {
  final double fontSize;

  const AppLogo({super.key, this.fontSize = 32});

  @override
  Widget build(BuildContext context) {
    return RichText(
      // RichText permet d'avoir plusieurs styles dans un même texte
      text: TextSpan(
        children: [
          TextSpan(
            text: 'BREAK',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          TextSpan(
            text: '•',
            style: TextStyle(
              color: AppColors.accent, // Le point est en rouge
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(
            text: 'APP',
            style: TextStyle(
              color: AppColors.accent, // "APP" en rouge
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}
