// ==============================================================
// FICHIER : lib/models/moov_model.dart
// RÔLE    : Définit la structure d'un "moov" (mouvement de breakdance)
// Un moov c'est un move/figure que le danseur a appris ou créé
// ==============================================================

// La classe Moov représente un mouvement de breakdance
class Moov {
  // ── Les informations d'un moov ──
  String id;              // Identifiant unique (pour le retrouver dans la liste)
  String nom;             // Nom du mouvement (ex: "Six Step", "Windmill")
  List<String> categories; // Liste des catégories (ex: ["Footwork", "Powermove"])
  String? imagePath;      // Chemin vers une image (peut être null = pas d'image)
  DateTime dateCreation;  // Quand le moov a été créé

  // ── Le constructeur ──
  Moov({
    required this.id,
    required this.nom,
    required this.categories,
    this.imagePath,
    required this.dateCreation,
  });
}

// ── Liste de toutes les catégories disponibles ──
// On la définit ici pour pouvoir l'utiliser partout dans l'app
const List<String> categoriesDisponibles = [
  'Top Rock',
  'Descente',
  'Footwork',
  'Freeze',
  'Powermove',
];

// ── Couleurs associées à chaque catégorie ──
// Chaque catégorie a sa couleur pour les chips
const Map<String, int> couleurCategories = {
  'Top Rock':   0xFFE63946, // Rouge
  'Descente':   0xFF457B9D, // Bleu
  'Footwork':   0xFF2A9D8F, // Vert
  'Freeze':     0xFFE9C46A, // Jaune
  'Powermove':  0xFFE76F51, // Orange
};
