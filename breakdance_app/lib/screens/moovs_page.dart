// ==============================================================
// FICHIER : lib/screens/moovs_page.dart (VERSION 3)
// RÔLE    : Liste des moovs avec filtre par catégorie + détail + ajout
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/moov.dart';
import '../widgets/app_theme.dart';
import 'add_moov_page.dart';
import 'moov_detail_page.dart';

class MoovsPage extends StatefulWidget {
  final List<Moov> moovs;
  final Function(Moov) onAjouter;
  final Function(Moov) onModifier;
  final Function(String) onSupprimer;

  const MoovsPage({
    super.key,
    required this.moovs,
    required this.onAjouter,
    required this.onModifier,
    required this.onSupprimer,
  });

  @override
  State<MoovsPage> createState() => _MoovsPageState();
}

class _MoovsPageState extends State<MoovsPage> {
  String? _filtreCategorie;

  List<Moov> get _moovsFiltres {
    if (_filtreCategorie == null) return widget.moovs;
    return widget.moovs.where((m) => m.categories.contains(_filtreCategorie)).toList();
  }

  Future<void> _ajouterMoov() async {
    final nouveauMoov = await Navigator.of(context).push<Moov>(
      MaterialPageRoute(builder: (_) => const AddMoovPage()),
    );
    if (nouveauMoov != null) widget.onAjouter(nouveauMoov);
  }

  Future<void> _voirDetail(Moov moov) async {
    final moovModifie = await Navigator.of(context).push<Moov>(
      MaterialPageRoute(builder: (_) => MoovDetailPage(moov: moov)),
    );
    if (moovModifie != null) widget.onModifier(moovModifie);
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
            const Text('MES MOOVS',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
            Text('${_moovsFiltres.length} / ${widget.moovs.length} moov${widget.moovs.length > 1 ? "s" : ""}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFiltres(),
          Expanded(
            child: _moovsFiltres.isEmpty
                ? _buildEtatVide()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: _moovsFiltres.length,
                    itemBuilder: (context, index) => _buildCarteMoov(_moovsFiltres[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterMoov,
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('MOOV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildFiltres() {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildChipFiltre(null, 'TOUS'),
          const SizedBox(width: 8),
          ...categoriesDisponibles.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChipFiltre(cat, cat),
              )),
        ],
      ),
    );
  }

  Widget _buildChipFiltre(String? valeur, String label) {
    final estActif = _filtreCategorie == valeur;
    final couleur = valeur != null ? Color(couleurCategories[valeur] ?? 0xFFE63946) : AppColors.accent;
    return GestureDetector(
      onTap: () => setState(() => _filtreCategorie = valeur),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: estActif ? couleur.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: estActif ? couleur : AppColors.border, width: estActif ? 2 : 1),
        ),
        child: Text(label,
            style: TextStyle(
                color: estActif ? couleur : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: estActif ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.5)),
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
                color: AppColors.accent.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent.withOpacity(0.2))),
            child: const Icon(Icons.local_fire_department, color: AppColors.accent, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            _filtreCategorie != null ? 'Aucun moov en "$_filtreCategorie"' : 'Aucun moov pour l\'instant',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _filtreCategorie != null ? 'Essaie un autre filtre' : 'Appuie sur + pour ajouter ton premier moov',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCarteMoov(Moov moov) {
    return Dismissible(
      key: Key(moov.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmerSuppression(moov.nom),
      onDismissed: (_) => widget.onSupprimer(moov.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(color: Colors.red.shade800, borderRadius: BorderRadius.circular(16)),
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
      child: GestureDetector(
        onTap: () => _voirDetail(moov),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                child: SizedBox(
                  width: 90, height: 100,
                  child: moov.mediaUrl != null
                      ? Image.file(File(moov.mediaUrl!), fit: BoxFit.cover)
                      : Container(
                          color: AppColors.accent.withOpacity(0.08),
                          child: const Icon(Icons.local_fire_department, color: AppColors.accent, size: 32)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(moov.nom,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 5, runSpacing: 5,
                        children: moov.categories.map((cat) {
                          final c = Color(couleurCategories[cat] ?? 0xFFE63946);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: c.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: c.withOpacity(0.35))),
                            child: Text(cat, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmerSuppression(String nom) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Supprimer ?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Supprimer "$nom" définitivement ?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ANNULER', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('SUPPRIMER', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
