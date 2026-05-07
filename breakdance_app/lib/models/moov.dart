// ==============================================================
// FICHIER : lib/models/moov.dart
// RÔLE    : Définit la structure d'un moov (mouvement de breakdance)
// VERSION : 3 — ajout userId + sérialisation JSON pour la sauvegarde
// ==============================================================

// La classe Moov représente un mouvement de breakdance
class Moov {
  String id;               // Identifiant unique (ex: "moov_1234567890")
  String nom;              // Nom du mouvement (ex: "Six Step")
  List<String> categories; // Catégories (ex: ["Footwork", "Freeze"])
  String? mediaUrl;        // Chemin ou URL de l'image/vidéo (peut être null)
  String? mediaType;       // Type du média : "photo", "video", ou null
  String userId;           // ID de l'utilisateur propriétaire du moov
  DateTime dateCreation;   // Date de création

  Moov({
    required this.id,
    required this.nom,
    required this.categories,
    this.mediaUrl,
    this.mediaType,
    required this.userId,
    required this.dateCreation,
  });

  // ── Convertit le Moov en Map pour le sauvegarder en JSON ──
  // C'est comme "emballer" l'objet pour le stocker
  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'categories': categories,       // List<String> → JSON array
    'mediaUrl': mediaUrl ?? '',
    'mediaType': mediaType ?? '',
    'userId': userId,
    'dateCreation': dateCreation.toIso8601String(), // DateTime → String
  };

  // ── Recrée un Moov depuis un Map JSON ──
  // C'est comme "déballer" l'objet depuis le stockage
  factory Moov.fromJson(Map<String, dynamic> json) => Moov(
    id: json['id'] ?? '',
    nom: json['nom'] ?? '',
    // On convertit la liste JSON en List<String>
    categories: List<String>.from(json['categories'] ?? []),
    mediaUrl: (json['mediaUrl'] as String?)?.isEmpty == true
        ? null
        : json['mediaUrl'],
    mediaType: (json['mediaType'] as String?)?.isEmpty == true ? null : json['mediaType'],
    userId: json['userId'] ?? '',
    dateCreation: DateTime.tryParse(json['dateCreation'] ?? '') ?? DateTime.now(),
  );
}

// ── Catégories disponibles ──
const List<String> categoriesDisponibles = [
  'Top Rock',
  'Descente',
  'Footwork',
  'Freeze',
  'Powermove',
];

// ── Couleurs associées à chaque catégorie (valeurs ARGB) ──
const Map<String, int> couleurCategories = {
  'Top Rock':  0xFFE63946, // Rouge
  'Descente':  0xFF457B9D, // Bleu
  'Footwork':  0xFF2A9D8F, // Vert teal
  'Freeze':    0xFFE9C46A, // Jaune
  'Powermove': 0xFFE76F51, // Orange
};
