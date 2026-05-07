// ==============================================================
// FICHIER : lib/screens/user_profile_page.dart
// ROLE    : Profil public d'un utilisateur (vu par les autres)
//           Affiche pseudo, photo, description, crew actuel
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/social_service.dart';
import '../widgets/app_theme.dart';

class UserProfilePage extends StatefulWidget {
  final UserModel user;         // L'utilisateur dont on voit le profil
  final UserModel? currentUser; // L'utilisateur connecte

  const UserProfilePage({super.key, required this.user, this.currentUser});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserModel? _crew; // Le crew dont ce danseur est membre
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _chargerCrew();
  }

  Future<void> _chargerCrew() async {
    if (widget.user.crewId != null && widget.user.crewId!.isNotEmpty) {
      final crew = await SocialService().chargerUserParId(widget.user.crewId!);
      setState(() { _crew = crew; _chargement = false; });
    } else {
      setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)]),
                  )),
                  Positioned(bottom: 16, left: 0, right: 0, child: Column(children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: AppColors.accent.withOpacity(0.2),
                      backgroundImage: widget.user.photoPath != null ? FileImage(File(widget.user.photoPath!)) : null,
                      child: widget.user.photoPath == null
                          ? Text(widget.user.pseudo[0].toUpperCase(), style: const TextStyle(color: AppColors.accent, fontSize: 28, fontWeight: FontWeight.bold))
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(widget.user.pseudo, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Text(widget.user.accountType.toUpperCase(), style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ])),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Description
                if (widget.user.description != null && widget.user.description!.isNotEmpty) ...[
                  const Text('A PROPOS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.user.description!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6)),
                  const SizedBox(height: 24),
                ],

                // Crew actuel (si danseur)
                if (widget.user.estDanseur) ...[
                  const Text('CREW', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _chargement
                      ? const CircularProgressIndicator(color: AppColors.accent)
                      : _crew != null
                          ? Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                              child: Row(children: [
                                CircleAvatar(
                                  radius: 20, backgroundColor: const Color(0xFF457B9D).withOpacity(0.2),
                                  backgroundImage: _crew!.photoPath != null ? FileImage(File(_crew!.photoPath!)) : null,
                                  child: _crew!.photoPath == null ? const Icon(Icons.groups, color: Color(0xFF457B9D), size: 20) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(_crew!.pseudo, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                  if (_crew!.pays != null) Text(_crew!.pays!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ])),
                              ]),
                            )
                          : Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                              child: const Text('Sans crew', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                  const SizedBox(height: 24),
                ],

                // Pays si crew
                if (widget.user.estCrew && widget.user.pays != null) ...[
                  const Text('PAYS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.flag_outlined, color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 6),
                    Text(widget.user.pays!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  ]),
                  const SizedBox(height: 24),
                ],

                // Ville si event
                if (widget.user.estEvent && widget.user.ville != null) ...[
                  Row(children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 6),
                    Text(widget.user.ville!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  ]),
                ],

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
