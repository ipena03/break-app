// ==============================================================
// FICHIER : lib/services/social_service.dart
// ROLE    : Gere toutes les interactions sociales
//           - Invitations de crew
//           - Membres des crews
//           - Recherche d'utilisateurs
// ==============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/invitation_model.dart';

class SocialService {

  // ═══════════════════════════════════
  // RECHERCHE D'UTILISATEURS
  // ═══════════════════════════════════

  // Cherche tous les danseurs (bboy/bgirl) par pseudo
  Future<List<UserModel>> rechercherDanseurs(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users_list') ?? '{}';
    final Map<String, dynamic> users = jsonDecode(usersJson);

    return users.values
        .where((u) {
          final type = u['accountType'] ?? '';
          final pseudo = (u['pseudo'] ?? '').toString().toLowerCase();
          // On filtre sur les danseurs dont le pseudo contient la recherche
          return (type == 'bboy' || type == 'bgirl') &&
              pseudo.contains(query.toLowerCase());
        })
        .map((u) => UserModel.fromMap(u as Map<String, dynamic>))
        .toList();
  }

  // Charge un utilisateur par son ID
  Future<UserModel?> chargerUserParId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users_list') ?? '{}';
    final Map<String, dynamic> users = jsonDecode(usersJson);

    for (final userData in users.values) {
      if (userData['id'] == userId) {
        return UserModel.fromMap(userData as Map<String, dynamic>);
      }
    }
    return null;
  }

  // Charge tous les membres d'un crew (danseurs dont crewId == crewId)
  Future<List<UserModel>> chargerMembresCreww(String crewId) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users_list') ?? '{}';
    final Map<String, dynamic> users = jsonDecode(usersJson);

    return users.values
        .where((u) => u['crewId'] == crewId)
        .map((u) => UserModel.fromMap(u as Map<String, dynamic>))
        .toList();
  }

  // ═══════════════════════════════════
  // INVITATIONS
  // ═══════════════════════════════════

  String _invitationKey(String userId) => 'invitations_$userId';

  // Charge toutes les invitations d'un utilisateur
  Future<List<Invitation>> chargerInvitations(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_invitationKey(userId)) ?? '[]';
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => Invitation.fromJson(e)).toList();
  }

  Future<void> _sauvegarderInvitations(String userId, List<Invitation> invitations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_invitationKey(userId), jsonEncode(invitations.map((i) => i.toJson()).toList()));
  }

  // Envoie une invitation d'un crew vers un danseur
  Future<String?> envoyerInvitation({
    required UserModel crew,
    required UserModel danseur,
  }) async {
    // Verification : le danseur n'est pas deja dans un crew
    if (danseur.crewId != null) {
      return '${danseur.pseudo} est deja dans un crew.';
    }

    // Verification : une invitation en attente n'existe pas deja
    final invitations = await chargerInvitations(danseur.id);
    final dejaInvite = invitations.any(
      (i) => i.crewId == crew.id && i.estEnAttente,
    );
    if (dejaInvite) return 'Une invitation est deja en attente.';

    // Creation de l'invitation
    final invitation = Invitation(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      crewId: crew.id,
      crewNom: crew.pseudo,
      crewPhoto: crew.photoPath ?? '',
      dancerId: danseur.id,
      dateEnvoi: DateTime.now(),
    );

    // On sauvegarde l'invitation dans la liste du danseur
    invitations.add(invitation);
    await _sauvegarderInvitations(danseur.id, invitations);
    return null; // null = succes
  }

  // Accepter une invitation
  Future<void> accepterInvitation(Invitation invitation) async {
    // 1. On met a jour le statut de l'invitation
    final invitations = await chargerInvitations(invitation.dancerId);
    final i = invitations.indexWhere((inv) => inv.id == invitation.id);
    if (i != -1) {
      invitations[i] = Invitation(
        id: invitation.id, crewId: invitation.crewId,
        crewNom: invitation.crewNom, crewPhoto: invitation.crewPhoto,
        dancerId: invitation.dancerId, statut: 'acceptee',
        dateEnvoi: invitation.dateEnvoi,
      );
      await _sauvegarderInvitations(invitation.dancerId, invitations);
    }

    // 2. On met a jour le crewId du danseur
    await _mettreAJourCrewDuDanseur(invitation.dancerId, invitation.crewId);
  }

  // Refuser une invitation
  Future<void> refuserInvitation(Invitation invitation) async {
    final invitations = await chargerInvitations(invitation.dancerId);
    final i = invitations.indexWhere((inv) => inv.id == invitation.id);
    if (i != -1) {
      invitations[i] = Invitation(
        id: invitation.id, crewId: invitation.crewId,
        crewNom: invitation.crewNom, crewPhoto: invitation.crewPhoto,
        dancerId: invitation.dancerId, statut: 'refusee',
        dateEnvoi: invitation.dateEnvoi,
      );
      await _sauvegarderInvitations(invitation.dancerId, invitations);
    }
  }

  // ═══════════════════════════════════
  // GESTION DES MEMBRES
  // ═══════════════════════════════════

  // Retire un membre de son crew (le crew appelle cette methode)
  Future<void> retirerMembre(String dancerId) async {
    await _mettreAJourCrewDuDanseur(dancerId, null);
  }

  // Met a jour le crewId d'un danseur dans la liste globale des users
  Future<void> _mettreAJourCrewDuDanseur(String dancerId, String? newCrewId) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users_list') ?? '{}';
    final Map<String, dynamic> users = jsonDecode(usersJson);

    for (final email in users.keys) {
      if (users[email]['id'] == dancerId) {
        users[email]['crewId'] = newCrewId ?? '';
        break;
      }
    }
    await prefs.setString('users_list', jsonEncode(users));

    // Mettre a jour aussi le currentUser si c'est le meme
    final currentJson = prefs.getString('current_user');
    if (currentJson != null) {
      final current = jsonDecode(currentJson) as Map<String, dynamic>;
      if (current['id'] == dancerId) {
        current['crewId'] = newCrewId ?? '';
        await prefs.setString('current_user', jsonEncode(current));
      }
    }
  }
}
