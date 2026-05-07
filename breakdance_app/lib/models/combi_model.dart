// ==============================================================
// FICHIER : lib/models/combi_model.dart
// ROLE    : Structure d'une combi — version 6
// Ajout : description
// ==============================================================

class Combi {
  String id;
  String nom;
  String style;
  String? description;
  String? photoPath;
  String userId;
  DateTime dateCreation;

  Combi({
    required this.id,
    required this.nom,
    required this.style,
    this.description,
    this.photoPath,
    required this.userId,
    required this.dateCreation,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'style': style,
    'description': description ?? '',
    'photoPath': photoPath ?? '',
    'userId': userId,
    'dateCreation': dateCreation.toIso8601String(),
  };

  factory Combi.fromJson(Map<String, dynamic> json) => Combi(
    id: json['id'] ?? '',
    nom: json['nom'] ?? '',
    style: json['style'] ?? 'Combis',
    description: _emptyToNull(json['description']),
    photoPath: _emptyToNull(json['photoPath']),
    userId: json['userId'] ?? '',
    dateCreation: DateTime.tryParse(json['dateCreation'] ?? '') ?? DateTime.now(),
  );

  static String? _emptyToNull(dynamic v) =>
      (v == null || v.toString().isEmpty) ? null : v.toString();
}

const List<String> stylesCombi = ['Portes', 'Accroches', 'Combis'];

const Map<String, int> couleurStyles = {
  'Portes':    0xFFE63946,
  'Accroches': 0xFF457B9D,
  'Combis':    0xFF2A9D8F,
};
