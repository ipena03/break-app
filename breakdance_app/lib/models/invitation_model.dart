// ==============================================================
// FICHIER : lib/models/invitation_model.dart
// ROLE    : Structure d'une invitation de crew vers un danseur
// Un crew envoie une invitation, le danseur l'accepte ou la refuse
// ==============================================================

class Invitation {
  String id;
  String crewId;      // ID du crew qui invite
  String crewNom;     // Nom du crew (pour l'afficher sans requete)
  String crewPhoto;   // Photo du crew
  String dancerId;    // ID du danseur invite
  String statut;      // 'en_attente', 'acceptee', 'refusee'
  DateTime dateEnvoi;

  Invitation({
    required this.id,
    required this.crewId,
    required this.crewNom,
    this.crewPhoto = '',
    required this.dancerId,
    this.statut = 'en_attente',
    required this.dateEnvoi,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'crewId': crewId,
    'crewNom': crewNom,
    'crewPhoto': crewPhoto,
    'dancerId': dancerId,
    'statut': statut,
    'dateEnvoi': dateEnvoi.toIso8601String(),
  };

  factory Invitation.fromJson(Map<String, dynamic> json) => Invitation(
    id: json['id'] ?? '',
    crewId: json['crewId'] ?? '',
    crewNom: json['crewNom'] ?? '',
    crewPhoto: json['crewPhoto'] ?? '',
    dancerId: json['dancerId'] ?? '',
    statut: json['statut'] ?? 'en_attente',
    dateEnvoi: DateTime.tryParse(json['dateEnvoi'] ?? '') ?? DateTime.now(),
  );

  bool get estEnAttente => statut == 'en_attente';
  bool get estAcceptee => statut == 'acceptee';
}
