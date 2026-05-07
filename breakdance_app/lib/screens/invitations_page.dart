// ==============================================================
// FICHIER : lib/screens/invitations_page.dart
// ROLE    : Page des invitations recues par un danseur
//           Le danseur peut accepter ou refuser les invitations
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/invitation_model.dart';
import '../models/user_model.dart';
import '../services/social_service.dart';
import '../widgets/app_theme.dart';

class InvitationsPage extends StatefulWidget {
  final UserModel user;

  const InvitationsPage({super.key, required this.user});

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  final SocialService _socialService = SocialService();
  List<Invitation> _invitations = [];
  bool _chargement = true;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final invitations = await _socialService.chargerInvitations(widget.user.id);
    // On affiche uniquement les invitations en attente
    setState(() {
      _invitations = invitations.where((i) => i.estEnAttente).toList();
      _chargement = false;
    });
  }

  Future<void> _accepter(Invitation inv) async {
    await _socialService.accepterInvitation(inv);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tu as rejoint ${inv.crewNom} !'), backgroundColor: AppColors.accent),
      );
      Navigator.of(context).pop(true); // On retourne true pour recharger le profil
    }
  }

  Future<void> _refuser(Invitation inv) async {
    await _socialService.refuserInvitation(inv);
    setState(() => _invitations.removeWhere((i) => i.id == inv.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation refusee.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('INVITATIONS'),
      ),
      body: _chargement
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _invitations.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.mail_outline, color: AppColors.textSecondary, size: 48),
                  SizedBox(height: 16),
                  Text('Aucune invitation en attente', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _invitations.length,
                  itemBuilder: (_, i) => _carteInvitation(_invitations[i]),
                ),
    );
  }

  Widget _carteInvitation(Invitation inv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 22, backgroundColor: const Color(0xFF457B9D).withOpacity(0.2),
            backgroundImage: inv.crewPhoto.isNotEmpty ? FileImage(File(inv.crewPhoto)) : null,
            child: inv.crewPhoto.isEmpty ? const Icon(Icons.groups, color: Color(0xFF457B9D)) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(inv.crewNom, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
            const Text('T\'invite a rejoindre le crew', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ])),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          // Bouton refuser
          Expanded(child: OutlinedButton(
            onPressed: () => _refuser(inv),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary, side: const BorderSide(color: AppColors.border)),
            child: const Text('REFUSER'),
          )),
          const SizedBox(width: 10),
          // Bouton accepter
          Expanded(child: ElevatedButton(
            onPressed: () => _accepter(inv),
            child: const Text('ACCEPTER'),
          )),
        ]),
      ]),
    );
  }
}
