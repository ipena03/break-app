// ==============================================================
// FICHIER : lib/screens/combi_page.dart
// ROLE    : Mes combis privees (crew seulement) — CRUD complet
// VERSION : 6 — ajout modification
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/combi_model.dart';
import '../widgets/app_theme.dart';
import 'add_combi_page.dart';

class CombiPage extends StatefulWidget {
  final List<Combi> combis;
  final Function(Combi) onAjouter;
  final Function(Combi) onModifier;
  final Function(String) onSupprimer;

  const CombiPage({super.key, required this.combis, required this.onAjouter, required this.onModifier, required this.onSupprimer});

  @override
  State<CombiPage> createState() => _CombiPageState();
}

class _CombiPageState extends State<CombiPage> {
  String? _filtre;

  List<Combi> get _filtrees {
    if (_filtre == null) return widget.combis;
    return widget.combis.where((c) => c.style == _filtre).toList();
  }

  Future<void> _ajouterCombi() async {
    final combi = await Navigator.of(context).push<Combi>(MaterialPageRoute(builder: (_) => const AddCombiPage()));
    if (combi != null) widget.onAjouter(combi);
  }

  Future<void> _modifierCombi(Combi combi) async {
    final modifiee = await Navigator.of(context).push<Combi>(MaterialPageRoute(builder: (_) => AddCombiPage(combiAModifier: combi)));
    if (modifiee != null) widget.onModifier(modifiee);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MES COMBIS', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
          Text('${_filtrees.length} / ${widget.combis.length}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.normal)),
        ]),
      ),
      body: Column(children: [
        _buildFiltres(),
        Expanded(child: _filtrees.isEmpty ? _buildVide() : ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
          itemCount: _filtrees.length,
          itemBuilder: (_, i) => _carteCombi(_filtrees[i]),
        )),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterCombi,
        backgroundColor: const Color(0xFF457B9D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('COMBI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildFiltres() {
    return SizedBox(height: 52, child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _chip(null, 'TOUS'),
        ...stylesCombi.map((s) => Padding(padding: const EdgeInsets.only(left: 8), child: _chip(s, s))),
      ],
    ));
  }

  Widget _chip(String? val, String label) {
    final actif = _filtre == val;
    final c = val != null ? Color(couleurStyles[val] ?? 0xFFE63946) : AppColors.accent;
    return GestureDetector(
      onTap: () => setState(() => _filtre = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: actif ? c.withOpacity(0.2) : AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: actif ? c : AppColors.border, width: actif ? 2 : 1)),
        child: Text(label, style: TextStyle(color: actif ? c : AppColors.textSecondary, fontSize: 11, fontWeight: actif ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildVide() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 90, height: 90, decoration: BoxDecoration(color: const Color(0xFF457B9D).withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF457B9D).withOpacity(0.3))),
        child: const Icon(Icons.groups, color: Color(0xFF457B9D), size: 40)),
      const SizedBox(height: 20),
      const Text('AUCUNE COMBI', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
      const SizedBox(height: 8),
      const Text('Appuie sur + pour creer ta premiere combi !', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    ]));
  }

  Widget _carteCombi(Combi combi) {
    final c = Color(couleurStyles[combi.style] ?? 0xFFE63946);
    return Dismissible(
      key: Key(combi.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Supprimer ?', style: TextStyle(color: AppColors.textPrimary)),
          content: Text('Supprimer "${combi.nom}" ?', style: const TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULER', style: TextStyle(color: AppColors.textSecondary))),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SUPPRIMER', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
      onDismissed: (_) => widget.onSupprimer(combi.id),
      background: Container(margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: Colors.red.shade800, borderRadius: BorderRadius.circular(16)), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.delete_outline, color: Colors.white, size: 24), SizedBox(height: 4), Text('Supprimer', style: TextStyle(color: Colors.white, fontSize: 11))])),
      child: GestureDetector(
        onTap: () => _modifierCombi(combi), // Clic = modifier
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Row(children: [
            ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)), child: SizedBox(width: 90, height: 100,
              child: combi.photoPath != null ? Image.file(File(combi.photoPath!), fit: BoxFit.cover) : Container(color: c.withOpacity(0.1), child: Icon(Icons.groups, color: c, size: 36)))),
            Expanded(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(combi.nom, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.4))),
                child: Text(combi.style, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.bold))),
              if (combi.description != null && combi.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(combi.description!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ]))),
            const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 16)),
          ]),
        ),
      ),
    );
  }
}
