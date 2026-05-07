// ==============================================================
// FICHIER : lib/models/user_model.dart
// ROLE    : Structure d'un utilisateur — version 6
// Ajout : description, crewId (pour les danseurs membres d'un crew)
// ==============================================================

class UserModel {
  String id;
  String email;
  String pseudo;
  String? photoPath;
  String accountType;  // 'bboy', 'bgirl', 'crew', 'event'
  String? pays;
  String? ville;
  String? description; // Description / bio du profil
  String? crewId;      // ID du crew dont le danseur est membre (null = sans crew)

  UserModel({
    required this.id,
    required this.email,
    required this.pseudo,
    this.photoPath,
    this.accountType = 'bboy',
    this.pays,
    this.ville,
    this.description,
    this.crewId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'pseudo': pseudo,
    'photoPath': photoPath ?? '',
    'accountType': accountType,
    'pays': pays ?? '',
    'ville': ville ?? '',
    'description': description ?? '',
    'crewId': crewId ?? '',
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] ?? '',
    email: map['email'] ?? '',
    pseudo: map['pseudo'] ?? '',
    photoPath: _emptyToNull(map['photoPath']),
    accountType: map['accountType'] ?? 'bboy',
    pays: _emptyToNull(map['pays']),
    ville: _emptyToNull(map['ville']),
    description: _emptyToNull(map['description']),
    crewId: _emptyToNull(map['crewId']),
  );

  static String? _emptyToNull(dynamic v) =>
      (v == null || v.toString().isEmpty) ? null : v.toString();

  bool get estDanseur => accountType == 'bboy' || accountType == 'bgirl';
  bool get estCrew => accountType == 'crew';
  bool get estEvent => accountType == 'event';
}
