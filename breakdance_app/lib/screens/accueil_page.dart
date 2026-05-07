// ==============================================================
// FICHIER : lib/screens/accueil_page.dart
// ROLE    : Page d'accueil — bienvenue + stats selon le type de compte
// VERSION : 5
// ==============================================================

import 'package:flutter/material.dart';
import '../models/moov.dart';
import '../models/passage.dart';
import '../models/combi_model.dart';
import '../models/user_model.dart';
import '../widgets/app_theme.dart';

class AccueilPage extends StatelessWidget {
  final UserModel? user;
  final List<Moov> moovs;
  final List<Passage> passages;
  final List<Combi> combis;
  final VoidCallback onAction; // Action principale selon le type

  const AccueilPage({
    super.key,
    required this.user,
    required this.moovs,
    required this.passages,
    required this.combis,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final estDanseur = user?.estDanseur ?? true;
    final estCrew = user?.estCrew ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── En-tete ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(text: const TextSpan(children: [
                    TextSpan(text: 'BREAK', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    TextSpan(text: '•APP', style: TextStyle(color: AppColors.accent, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ])),
                  // Badge type de compte
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.accent.withOpacity(0.3))),
                    child: Row(children: [
                      Icon(_iconePourType(user?.accountType), color: AppColors.accent, size: 14),
                      const SizedBox(width: 4),
                      Text((user?.accountType ?? 'bboy').toUpperCase(), style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ]),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // ── Message de bienvenue ──
              Text(
                'YO, ${(user?.pseudo ?? 'DANCER').toUpperCase()} !',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              Text(
                estCrew ? 'Gere tes combis et represente ton crew !' : 'Pret a travailler tes moves ?',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),

              const SizedBox(height: 32),

              // ── Stats selon le type ──
              if (estDanseur)
                Row(children: [
                  Expanded(child: _statCard('${moovs.length}', 'MOOVS', Icons.local_fire_department, AppColors.accent)),
                  const SizedBox(width: 16),
                  Expanded(child: _statCard('${passages.length}', 'PASSAGES', Icons.queue_music, const Color(0xFF457B9D))),
                ]),

              if (estCrew)
                Row(children: [
                  Expanded(child: _statCard('${combis.length}', 'COMBIS', Icons.groups, const Color(0xFF457B9D))),
                  const SizedBox(width: 16),
                  Expanded(child: _statCard(
                    '${combis.where((c) => c.style == 'Portes').length}',
                    'PORTES', Icons.accessibility_new, AppColors.accent)),
                ]),

              if (user?.estEvent ?? false)
                _statCard('1', 'EVENT ACTIF', Icons.event, const Color(0xFFE9C46A)),

              const SizedBox(height: 32),

              // ── Bouton principal ──
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(estCrew ? Icons.add : Icons.add, size: 18),
                label: Text(estCrew ? 'AJOUTER UNE COMBI' : 'AJOUTER UN MOOV'),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconePourType(String? type) {
    switch (type) {
      case 'bgirl': return Icons.girl;
      case 'crew': return Icons.groups;
      case 'event': return Icons.event;
      default: return Icons.boy;
    }
  }

  Widget _statCard(String valeur, String label, IconData icone, Color couleur) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
      decoration: BoxDecoration(color: couleur.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: couleur.withOpacity(0.2))),
      child: Column(children: [
        Icon(icone, color: couleur, size: 24),
        const SizedBox(height: 10),
        Text(valeur, style: TextStyle(color: couleur, fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: couleur.withOpacity(0.7), fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
