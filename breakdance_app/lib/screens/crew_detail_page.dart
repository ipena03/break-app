// ==============================================================
// FICHIER : lib/screens/crew_detail_page.dart
// ROLE    : Page detail d'un crew — membres, combis, infos
//           Le crew peut inviter des danseurs et retirer des membres
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/combi_model.dart';
import '../services/social_service.dart';
import '../widgets/app_theme.dart';
import 'user_profile_page.dart';

class CrewDetailPage extends StatefulWidget {
  final UserModel crew;           // Le crew a afficher
  final UserModel? currentUser;   // L'utilisateur connecte
  final List<Combi> combis;       // Combis de ce crew

  const CrewDetailPage({
    super.key,
    required this.crew,
    required this.currentUser,
    required this.combis,
  });

  @override
  State<CrewDetailPage> createState() => _CrewDetailPageState();
}

class _CrewDetailPageState extends State<CrewDetailPage> {
  final SocialService _socialService = SocialService();
  List<UserModel> _membres = [];
  bool _chargement = true;

  // Est-ce que l'utilisateur connecte est le crew de cette page ?
  bool get _estMonCrew => widget.currentUser?.id == widget.crew.id;

  @override
  void initState() {
    super.initState();
    _chargerMembres();
  }

  Future<void> _chargerMembres() async {
    final membres = await _socialService.chargerMembresCreww(widget.crew.id);
    setState(() { _membres = membres; _chargement = false; });
  }

  // ── Retirer un membre (seulement si c'est mon crew) ──
  Future<void> _retirerMembre(UserModel membre) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Retirer du crew ?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Retirer ${membre.pseudo} du crew ?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULER', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('RETIRER', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await _socialService.retirerMembre(membre.id);
      await _chargerMembres(); // On recharge la liste
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${membre.pseudo} a ete retire du crew.')));
      }
    }
  }

  // ── Inviter un danseur (recherche) ──
  void _inviterDanseur() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _InviterDanseurSheet(
        crew: widget.crew,
        onInvite: (danseur) async {
          final erreur = await _socialService.envoyerInvitation(crew: widget.crew, danseur: danseur);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(erreur ?? 'Invitation envoyee a ${danseur.pseudo} !'),
              backgroundColor: erreur != null ? Colors.red : AppColors.accent),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── AppBar avec photo du crew ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.crew.photoPath != null
                      ? Image.file(File(widget.crew.photoPath!), fit: BoxFit.cover)
                      : Container(color: const Color(0xFF457B9D).withOpacity(0.3),
                          child: const Icon(Icons.groups, color: Color(0xFF457B9D), size: 60)),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ))),
                  Positioned(bottom: 16, left: 16, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.crew.pseudo, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      if (widget.crew.pays != null)
                        Row(children: [
                          const Icon(Icons.flag_outlined, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(widget.crew.pays!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ]),
                    ],
                  )),
                ],
              ),
            ),
            actions: [
              if (_estMonCrew)
                IconButton(
                  icon: const Icon(Icons.person_add_outlined),
                  tooltip: 'Inviter un danseur',
                  onPressed: _inviterDanseur,
                ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Description ──
                  if (widget.crew.description != null && widget.crew.description!.isNotEmpty) ...[
                    Text(widget.crew.description!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
                    const SizedBox(height: 24),
                  ],

                  // ── Membres ──
                  Row(children: [
                    const Text('MEMBRES', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${_membres.length}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 12),

                  if (_chargement)
                    const Center(child: CircularProgressIndicator(color: AppColors.accent))
                  else if (_membres.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: const Center(child: Text('Aucun membre pour l\'instant', style: TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    ..._membres.map((m) => _carteMembre(m)),

                  const SizedBox(height: 28),

                  // ── Combis du crew ──
                  if (widget.combis.isNotEmpty) ...[
                    const Text('COMBIS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...widget.combis.map((c) => _carteCombiMini(c)),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteMembre(UserModel membre) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: ListTile(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => UserProfilePage(user: membre, currentUser: widget.currentUser),
        )),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.accent.withOpacity(0.2),
          backgroundImage: membre.photoPath != null ? FileImage(File(membre.photoPath!)) : null,
          child: membre.photoPath == null ? Text(membre.pseudo[0].toUpperCase(), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)) : null,
        ),
        title: Text(membre.pseudo, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        subtitle: Text(membre.accountType.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        trailing: _estMonCrew
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                onPressed: () => _retirerMembre(membre),
              )
            : const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
      ),
    );
  }

  Widget _carteCombiMini(Combi combi) {
    final couleur = Color(couleurStyles[combi.style] ?? 0xFFE63946);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: couleur.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: combi.photoPath != null
              ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(combi.photoPath!), fit: BoxFit.cover))
              : Icon(Icons.groups, color: couleur, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(combi.nom, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(combi.style, style: TextStyle(color: couleur, fontSize: 11)),
        ])),
      ]),
    );
  }
}

// ── Sheet de recherche et invitation ──
class _InviterDanseurSheet extends StatefulWidget {
  final UserModel crew;
  final Function(UserModel) onInvite;
  const _InviterDanseurSheet({required this.crew, required this.onInvite});

  @override
  State<_InviterDanseurSheet> createState() => _InviterDanseurSheetState();
}

class _InviterDanseurSheetState extends State<_InviterDanseurSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  final SocialService _socialService = SocialService();
  List<UserModel> _resultats = [];

  Future<void> _rechercher(String query) async {
    if (query.trim().isEmpty) { setState(() => _resultats = []); return; }
    final resultats = await _socialService.rechercherDanseurs(query);
    setState(() => _resultats = resultats);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('INVITER UN DANSEUR', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            onChanged: _rechercher,
            decoration: const InputDecoration(
              hintText: 'Rechercher un pseudo...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          if (_resultats.isEmpty && _searchCtrl.text.isNotEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('Aucun danseur trouve', style: TextStyle(color: AppColors.textSecondary))),
          ..._resultats.map((d) => ListTile(
            leading: CircleAvatar(
              radius: 18, backgroundColor: AppColors.accent.withOpacity(0.2),
              backgroundImage: d.photoPath != null ? FileImage(File(d.photoPath!)) : null,
              child: d.photoPath == null ? Text(d.pseudo[0].toUpperCase(), style: const TextStyle(color: AppColors.accent)) : null,
            ),
            title: Text(d.pseudo, style: const TextStyle(color: AppColors.textPrimary)),
            subtitle: Text(d.accountType.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            trailing: ElevatedButton(
              onPressed: () => widget.onInvite(d),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: const Text('INVITER', style: TextStyle(fontSize: 11)),
            ),
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
