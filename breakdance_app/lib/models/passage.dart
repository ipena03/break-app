// ==============================================================
// FICHIER : lib/models/passage.dart
// RÔLE    : Définit la structure d'un "passage"
// Un passage = une séquence de moovs enchaînés (comme une chorégraphie)
// ==============================================================

// La classe Passage représente une séquence de moovs
class Passage {
  String id;           // Identifiant unique
  String nom;          // Nom du passage (ex: "Mon passage battle")
  List<String> moovIds; // Liste des IDs des moovs dans ce passage (dans l'ordre)
  String userId;       // ID de l'utilisateur propriétaire
  DateTime dateCreation;

  Passage({
    required this.id,
    required this.nom,
    required this.moovIds,
    required this.userId,
    required this.dateCreation,
  });

  // ── Convertit en Map pour la sauvegarde JSON ──
  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'moovIds': moovIds, // On sauvegarde les IDs, pas les moovs complets
    'userId': userId,
    'dateCreation': dateCreation.toIso8601String(),
  };

  // ── Recrée un Passage depuis un Map JSON ──
  factory Passage.fromJson(Map<String, dynamic> json) => Passage(
    id: json['id'] ?? '',
    nom: json['nom'] ?? '',
    moovIds: List<String>.from(json['moovIds'] ?? []),
    userId: json['userId'] ?? '',
    dateCreation: DateTime.tryParse(json['dateCreation'] ?? '') ?? DateTime.now(),
  );
}
