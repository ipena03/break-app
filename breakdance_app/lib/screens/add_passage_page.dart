// ==============================================================
// FICHIER : lib/screens/add_passage_page.dart
// RÔLE    : Formulaire pour créer OU modifier un passage
// Si passageAModifier est fourni → mode modification
// Sinon → mode création
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/moov.dart';
import '../models/passage.dart';
import '../widgets/app_theme.dart';

class AddPassagePage extends StatefulWidget {
  final List<Moov> moovsDispo;
  final Passage? passageAModifier; // null = création, non-null = modification

  const AddPassagePage({
    super.key,
    required this.moovsDispo,
    this.passageAModifier, // Optionnel
  });

  @override
  State<AddPassagePage> createState() => _AddPassagePageState();
}

class _AddPassagePageState extends State<AddPassagePage> {
  late TextEditingController _nomController;
  late List<String> _moovIdsSelectionnes;
  String? _erreur;

  // Vrai si on est en mode modification
  bool get _estModification => widget.passageAModifier != null;

  @override
  void initState() {
    super.initState();
    if (_estModification) {
      // Mode modification : on pré-remplit avec les données existantes
      _nomController = TextEditingController(
          text: widget.passageAModifier!.nom);
      _moovIdsSelectionnes =
          List.from(widget.passageAModifier!.moovIds);
    } else {
      // Mode création : tout vide
      _nomController = TextEditingController();
      _moovIdsSelectionnes = [];
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  // ── Cocher/décocher un moov ──
  void _toggleMoov(String id) {
    setState(() {
      if (_moovIdsSelectionnes.contains(id)) {
        _moovIdsSelectionnes.remove(id);
      } else {
        _moovIdsSelectionnes.add(id);
      }
    });
  }

  // ── Liste des moovs dans l'ordre de sélection ──
  List<Moov> get _moovsSelectionnes {
    return _moovIdsSelectionnes.map((id) =>
      widget.moovsDispo.firstWhere(
        (m) => m.id == id,
        orElse: () => Moov(
            id: id, nom: '?', categories: [],
            userId: '', dateCreation: DateTime.now()),
      )
    ).toList();
  }

  // ── Valider et enregistrer ──
  void _enregistrer() {
    final nom = _nomController.text.trim();

    if (nom.isEmpty) {
      setState(() => _erreur = 'Donne un nom à ton passage !');
      return;
    }
    if (_moovIdsSelectionnes.isEmpty) {
      setState(() => _erreur = 'Sélectionne au moins un moov.');
      return;
    }

    final passage = Passage(
      // En modification on garde le même ID, en création on en crée un nouveau
      id: _estModification
          ? widget.passageAModifier!.id
          : 'passage_${DateTime.now().millisecondsSinceEpoch}',
      nom: nom,
      moovIds: List.from(_moovIdsSelectionnes),
      userId: widget.passageAModifier?.userId ?? '',
      dateCreation: widget.passageAModifier?.dateCreation ?? DateTime.now(),
    );

    // On retourne le passage à la page précédente
    Navigator.of(context).pop(passage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        // Le titre change selon le mode
        title: Text(_estModification ? 'MODIFIER LE PASSAGE' : 'NOUVEAU PASSAGE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _enregistrer,
            child: const Text('SAUVER',
                style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Nom du passage ──
            _label('NOM DU PASSAGE'),
            const SizedBox(height: 12),
            TextField(
              controller: _nomController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              onChanged: (_) => setState(() => _erreur = null),
              decoration: const InputDecoration(
                hintText: 'ex: Mon passage battle...',
                prefixIcon: Icon(Icons.queue_music,
                    color: AppColors.textSecondary, size: 20),
              ),
            ),

            const SizedBox(height: 32),

            // ── Sélection des moovs ──
            Row(
              children: [
                _label('SÉLECTIONNE TES MOOVS'),
                const Spacer(),
                Text(
                  '${_moovIdsSelectionnes.length} sélectionné${_moovIdsSelectionnes.length > 1 ? "s" : ""}',
                  style: const TextStyle(color: AppColors.accent, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'L\'ordre de sélection = ordre du passage',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Aucun moov disponible
            if (widget.moovsDispo.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border)),
                child: const Center(
                  child: Text(
                    'Aucun moov disponible.\nCrée d\'abord des moovs !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                  ),
                ),
              )
            else
              // Liste des moovs sélectionnables
              ...widget.moovsDispo.map((moov) {
                final estSel = _moovIdsSelectionnes.contains(moov.id);
                final numero = estSel
                    ? _moovIdsSelectionnes.indexOf(moov.id) + 1
                    : null;

                return GestureDetector(
                  onTap: () => _toggleMoov(moov.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: estSel
                          ? AppColors.accent.withOpacity(0.08)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: estSel ? AppColors.accent : AppColors.border,
                        width: estSel ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Miniature ou icône
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 50, height: 50,
                            child: moov.mediaUrl != null
                                ? Image.file(File(moov.mediaUrl!),
                                    fit: BoxFit.cover)
                                : Container(
                                    color: AppColors.accent.withOpacity(0.08),
                                    child: const Icon(
                                        Icons.local_fire_department,
                                        color: AppColors.accent, size: 22)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Nom + catégories
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(moov.nom,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              if (moov.categories.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(moov.categories.join(' • '),
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ],
                          ),
                        ),
                        // Cercle numéro (si sélectionné) ou vide
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: estSel
                                ? AppColors.accent
                                : Colors.transparent,
                            border: Border.all(
                              color: estSel
                                  ? AppColors.accent
                                  : AppColors.border,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              estSel ? '$numero' : '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            // ── Aperçu de l'ordre du passage ──
            if (_moovsSelectionnes.isNotEmpty) ...[
              const SizedBox(height: 32),
              _label('APERÇU DU PASSAGE'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.accent.withOpacity(0.25))),
                child: Column(
                  children: _moovsSelectionnes.asMap().entries.map((e) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.15),
                                shape: BoxShape.circle),
                            child: Center(
                              child: Text('${e.key + 1}',
                                  style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(e.value.nom,
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Message d'erreur ──
            if (_erreur != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3))),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text(_erreur!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            ElevatedButton.icon(
              onPressed: _enregistrer,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: Text(_estModification
                  ? 'SAUVEGARDER LES MODIFICATIONS'
                  : 'ENREGISTRER LE PASSAGE'),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.bold));
}
