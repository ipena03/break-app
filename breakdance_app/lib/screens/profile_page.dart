// ==============================================================
// FICHIER : lib/screens/profile_page.dart
// ROLE    : Mon profil — v6 avec description et bouton invitations
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/social_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_widgets.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';
import 'invitations_page.dart';

class ProfilePage extends StatefulWidget {
  final UserModel? userOverride;
  final Function(UserModel)? onUserUpdated;
  const ProfilePage({super.key, this.userOverride, this.onUserUpdated});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _user;
  bool _isLoading = true;
  int _nbInvitations = 0; // Nombre d'invitations en attente
  final AuthService _authService = AuthService();

  @override
  void initState() { super.initState(); _loadUser(); }

  @override
  void didUpdateWidget(ProfilePage old) {
    super.didUpdateWidget(old);
    if (widget.userOverride != null) setState(() => _user = widget.userOverride);
  }

  Future<void> _loadUser() async {
    final user = widget.userOverride ?? await _authService.getCurrentUser();
    int nbInv = 0;
    // Pour les danseurs : on compte les invitations en attente
    if (user != null && user.estDanseur) {
      final invs = await SocialService().chargerInvitations(user.id);
      nbInv = invs.where((i) => i.estEnAttente).length;
    }
    setState(() { _user = user; _nbInvitations = nbInv; _isLoading = false; });
  }

  Future<void> _handleLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('SE DECONNECTER ?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Tu vas quitter ton compte.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULER', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SE DECONNECTER', style: TextStyle(color: AppColors.accent))),
        ],
      ),
    );
    if (ok == true) {
      await _authService.logout();
      if (mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
    }
  }

  Future<void> _modifierProfil() async {
    if (_user == null) return;
    final updated = await Navigator.of(context).push<UserModel>(MaterialPageRoute(builder: (_) => EditProfilePage(user: _user!)));
    if (updated != null) { setState(() => _user = updated); widget.onUserUpdated?.call(updated); }
  }

  Future<void> _voirInvitations() async {
    if (_user == null) return;
    final ok = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => InvitationsPage(user: _user!)));
    if (ok == true) await _loadUser(); // Recharge pour mettre a jour le crewId
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
    if (_user == null) return const Scaffold(backgroundColor: AppColors.background, body: Center(child: Text('Erreur', style: TextStyle(color: AppColors.textPrimary))));
    return _buildContent();
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.primary,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(children: [
              Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)]))),
              Positioned(bottom: 20, left: 0, right: 0, child: Column(children: [
                ProfileAvatar(photoPath: _user!.photoPath, size: 80),
                const SizedBox(height: 8),
                Text(_user!.pseudo, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text(_user!.accountType.toUpperCase(), style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
              ])),
            ]),
          ),
          actions: [
            // Badge invitations (danseurs seulement)
            if (_user!.estDanseur && _nbInvitations > 0)
              Stack(children: [
                IconButton(icon: const Icon(Icons.mail_outline), onPressed: _voirInvitations),
                Positioned(right: 6, top: 6, child: Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  child: Center(child: Text('$_nbInvitations', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                )),
              ])
            else if (_user!.estDanseur)
              IconButton(icon: const Icon(Icons.mail_outline, color: AppColors.textSecondary), onPressed: _voirInvitations),
            IconButton(icon: const Icon(Icons.logout, color: AppColors.textSecondary), onPressed: _handleLogout),
          ],
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Description
            if (_user!.description != null && _user!.description!.isNotEmpty) ...[
              const Text('A PROPOS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_user!.description!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6)),
              const SizedBox(height: 24),
            ],

            const Text('MES INFORMATIONS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(children: [
                _infoRow(Icons.email_outlined, 'Email', _user!.email),
                if (_user!.estDanseur) ...[const Divider(height: 1, color: AppColors.border), _infoRow(Icons.tag, 'Pseudo', _user!.pseudo)],
                if (_user!.estCrew) ...[const Divider(height: 1, color: AppColors.border), _infoRow(Icons.groups, 'Crew', _user!.pseudo), const Divider(height: 1, color: AppColors.border), _infoRow(Icons.flag_outlined, 'Pays', _user!.pays ?? '-')],
                if (_user!.estEvent) ...[const Divider(height: 1, color: AppColors.border), _infoRow(Icons.event, 'Event', _user!.pseudo), const Divider(height: 1, color: AppColors.border), _infoRow(Icons.location_on_outlined, 'Ville', _user!.ville ?? '-')],
              ]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: _modifierProfil, icon: const Icon(Icons.edit_outlined, size: 18), label: const Text('MODIFIER MON PROFIL')),
            const SizedBox(height: 40),
          ]),
        )),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Icon(icon, color: AppColors.accent, size: 18), const SizedBox(width: 12),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      const Spacer(),
      Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
    ]),
  );
}
