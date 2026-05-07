// ==============================================================
// FICHIER : lib/screens/passages_page.dart
// RÔLE    : Liste des passages — création, consultation ET modification
// VERSION : 4.1 — modification des passages réactivée
// ==============================================================

import 'package:flutter/material.dart';
import '../models/moov.dart';
import '../models/passage.dart';
import '../widgets/app_theme.dart';
import 'add_passage_page.dart';
import 'moov_detail_page.dart'; // Pour ouvrir le détail d'un moov

class PassagesPage extends StatelessWidget {
  final List<Passage> passages;
  final List<Moov> moovsDispo;
  final Function(Passage) onAjouter;
  final Function(Passage) onModifier; // Callback pour sauvegarder une modification
  final Function(String) onSupprimer;

  const PassagesPage({
    super.key,
    required this.passages,
    required this.moovsDispo,
    required this.onAjouter,
    required this.onModifier,
    required this.onSupprimer,
  });

  // ── Créer un nouveau passage ──
  Future<void> _creerPassage(BuildContext context) async {
    final passage = await Navigator.of(context).push<Passage>(
      MaterialPageRoute(
        builder: (_) => AddPassagePage(moovsDispo: moovsDispo),
      ),
    );
    if (passage != null) onAjouter(passage);
  }

  // ── Modifier un passage existant ──
  // On ouvre AddPassagePage en lui passant le passage déjà existant
  Future<void> _modifierPassage(BuildContext context, Passage passage) async {
    final passageModifie = await Navigator.of(context).push<Passage>(
      MaterialPageRoute(
        builder: (_) => AddPassagePage(
          moovsDispo: moovsDispo,
          passageAModifier: passage, // On passe le passage existant
        ),
      ),
    );
    if (passageModifie != null) onModifier(passageModifie);
  }

  // ── Récupère les objets Moov depuis les IDs du passage ──
  List<Moov> _getMoovsPassage(Passage passage) {
    return passage.moovIds.map((id) {
      return moovsDispo.firstWhere(
        (m) => m.id == id,
        orElse: () => Moov(
          id: id, nom: '(moov supprimé)',
          categories: [], userId: '', dateCreation: DateTime.now(),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MES PASSAGES',
                style: TextStyle(color: AppColors.textPrimary,
                    fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
            Text('${passages.length} passage${passages.length > 1 ? "s" : ""}',
                style: const TextStyle(color: AppColors.textSecondary,
                    fontSize: 11, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: passages.isEmpty
          ? _buildEtatVide()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: passages.length,
              itemBuilder: (context, index) =>
                  _buildCartePassage(context, passages[index]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _creerPassage(context),
        backgroundColor: const Color(0xFF457B9D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('PASSAGE',
            style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildEtatVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF457B9D).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF457B9D).withOpacity(0.3)),
            ),
            child: const Icon(Icons.queue_music, color: Color(0xFF457B9D), size: 40),
          ),
          const SizedBox(height: 20),
          const Text('AUCUN PASSAGE',
              style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text('Un passage = une séquence de moovs\npour ton battle !',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildCartePassage(BuildContext context, Passage passage) {
    final moovsPassage = _getMoovsPassage(passage);

    return Dismissible(
      key: Key(passage.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmerSuppression(context, passage.nom),
      onDismissed: (_) => onSupprimer(passage.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
            color: Colors.red.shade800,
            borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text('Supprimer', style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),

      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── En-tête : icône + nom + boutons ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFF457B9D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.queue_music,
                        color: Color(0xFF457B9D), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(passage.nom,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  // Badge nombre de moovs
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFF457B9D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF457B9D).withOpacity(0.3))),
                    child: Text(
                      '${moovsPassage.length} moov${moovsPassage.length > 1 ? "s" : ""}',
                      style: const TextStyle(
                          color: Color(0xFF457B9D),
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              // ── Aperçu des 3 premiers moovs ──
              if (moovsPassage.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),
                ...moovsPassage.take(3).toList().asMap().entries.map((e) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                              color: const Color(0xFF457B9D).withOpacity(0.15),
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text('${e.key + 1}',
                                style: const TextStyle(
                                    color: Color(0xFF457B9D),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(e.value.nom,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                if (moovsPassage.length > 3)
                  Text('... et ${moovsPassage.length - 3} de plus',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic)),
              ],

              const SizedBox(height: 14),

              // ── Boutons : Voir + Modifier ──
              Row(
                children: [
                  // Bouton "Voir"
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _voirDetailPassage(context, passage, moovsPassage),
                      icon: const Icon(Icons.visibility_outlined, size: 15),
                      label: const Text('VOIR'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Bouton "Modifier"
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _modifierPassage(context, passage),
                      icon: const Icon(Icons.edit_outlined, size: 15),
                      label: const Text('MODIFIER'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF457B9D),
                        side: const BorderSide(color: Color(0xFF457B9D)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Détail complet en BottomSheet (lecture) ──
  // ── Affiche le détail complet d'un passage (avec moovs cliquables) ──
  void _voirDetailPassage(
      BuildContext context, Passage passage, List<Moov> moovs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text(passage.nom,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              '${moovs.length} moov${moovs.length > 1 ? "s" : ""}  •  Appuie sur un moov pour voir son média',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 24),
            // Liste des moovs — chaque moov est cliquable si il a un média
            ...moovs.asMap().entries.map((e) {
              final i = e.key;
              final m = e.value;
              // Est-ce que ce moov a une photo ou une vidéo ?
              final aMedia = m.mediaUrl != null && m.mediaUrl!.isNotEmpty;
              return GestureDetector(
                // Au clic : on ouvre la page détail du moov
                onTap: aMedia
                    ? () => Navigator.of(ctx).push(MaterialPageRoute(
                          builder: (_) => MoovDetailPage(moov: m),
                        ))
                    : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      // Bordure bleue si cliquable, grise sinon
                      color: aMedia
                          ? const Color(0xFF457B9D).withOpacity(0.4)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Numéro dans le passage
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                            color: const Color(0xFF457B9D).withOpacity(0.15),
                            shape: BoxShape.circle),
                        child: Center(
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  color: Color(0xFF457B9D),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Nom + catégories
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.nom,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold)),
                            if (m.categories.isNotEmpty)
                              Text(m.categories.join(' • '),
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11)),
                          ],
                        ),
                      ),
                      // Icône photo ou vidéo si média dispo + flèche
                      if (aMedia) ...[
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF457B9D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            m.mediaType == 'video'
                                ? Icons.play_circle_outline
                                : Icons.photo_outlined,
                            color: const Color(0xFF457B9D),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textSecondary, size: 16),
                      ],
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmerSuppression(BuildContext context, String nom) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Supprimer ?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Supprimer le passage "$nom" ?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ANNULER',
                  style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('SUPPRIMER',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
