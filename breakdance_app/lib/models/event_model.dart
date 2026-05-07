// ==============================================================
// FICHIER : lib/models/event_model.dart
// ROLE    : Structure d'un event — version 6
// Ajout : description, date, plusieurs flyers (images)
// ==============================================================

class EventModel {
  String id;
  String nom;
  String ville;
  String? description;
  String? photoPath;          // Photo principale
  List<String> flyers;        // Liste de chemins vers les flyers/images
  DateTime? dateEvent;        // Date de l'evenement
  String userId;
  DateTime dateCreation;

  EventModel({
    required this.id,
    required this.nom,
    required this.ville,
    this.description,
    this.photoPath,
    this.flyers = const [],
    this.dateEvent,
    required this.userId,
    required this.dateCreation,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'ville': ville,
    'description': description ?? '',
    'photoPath': photoPath ?? '',
    'flyers': flyers,
    'dateEvent': dateEvent?.toIso8601String() ?? '',
    'userId': userId,
    'dateCreation': dateCreation.toIso8601String(),
  };

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    id: json['id'] ?? '',
    nom: json['nom'] ?? '',
    ville: json['ville'] ?? '',
    description: _emptyToNull(json['description']),
    photoPath: _emptyToNull(json['photoPath']),
    flyers: List<String>.from(json['flyers'] ?? []),
    dateEvent: json['dateEvent'] != null && json['dateEvent'].isNotEmpty
        ? DateTime.tryParse(json['dateEvent'])
        : null,
    userId: json['userId'] ?? '',
    dateCreation: DateTime.tryParse(json['dateCreation'] ?? '') ?? DateTime.now(),
  );

  static String? _emptyToNull(dynamic v) =>
      (v == null || v.toString().isEmpty) ? null : v.toString();
}
