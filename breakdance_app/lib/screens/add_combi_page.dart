// ==============================================================
// FICHIER : lib/screens/add_combi_page.dart
// ROLE    : Creer ou modifier une combi — version 6 avec description
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/combi_model.dart';
import '../widgets/app_theme.dart';

class AddCombiPage extends StatefulWidget {
  final Combi? combiAModifier; // null = creation, non-null = modification

  const AddCombiPage({super.key, this.combiAModifier});

  @override
  State<AddCombiPage> createState() => _AddCombiPageState();
}

class _AddCombiPageState extends State<AddCombiPage> {
  late TextEditingController _nomCtrl;
  late TextEditingController _descCtrl;
  late String _styleSelectionne;
  String? _photoPath;
  final ImagePicker _picker = ImagePicker();
  String? _erreur;

  bool get _estModification => widget.combiAModifier != null;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: widget.combiAModifier?.nom ?? '');
    _descCtrl = TextEditingController(text: widget.combiAModifier?.description ?? '');
    _styleSelectionne = widget.combiAModifier?.style ?? 'Combis';
    _photoPath = widget.combiAModifier?.photoPath;
  }

  @override
  void dispose() { _nomCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _choisirPhoto() async {
    final XFile? f = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (f != null) setState(() => _photoPath = f.path);
  }

  Future<void> _prendrePhoto() async {
    try {
      final XFile? f = await _picker.pickImage(source: ImageSource.camera, maxWidth: 800, imageQuality: 85);
      if (f != null) setState(() => _photoPath = f.path);
    } catch (e) { setState(() => _erreur = 'Impossible d\'ouvrir la camera.'); }
  }

  void _afficherMenuPhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('AJOUTER UNE PHOTO', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.camera_alt, color: AppColors.accent)),
            title: const Text('Prendre une photo', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            onTap: () { Navigator.pop(ctx); _prendrePhoto(); },
          ),
          ListTile(
            leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.photo_library, color: AppColors.accent)),
            title: const Text('Choisir depuis la galerie', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            onTap: () { Navigator.pop(ctx); _choisirPhoto(); },
          ),
          if (_photoPath != null)
            ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete_outline, color: Colors.red)),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () { Navigator.pop(ctx); setState(() => _photoPath = null); },
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _enregistrer() {
    if (_nomCtrl.text.trim().isEmpty) { setState(() => _erreur = 'Donne un nom a la combi !'); return; }
    final combi = Combi(
      id: widget.combiAModifier?.id ?? 'combi_${DateTime.now().millisecondsSinceEpoch}',
      nom: _nomCtrl.text.trim(),
      style: _styleSelectionne,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      photoPath: _photoPath,
      userId: widget.combiAModifier?.userId ?? '',
      dateCreation: widget.combiAModifier?.dateCreation ?? DateTime.now(),
    );
    Navigator.of(context).pop(combi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(_estModification ? 'MODIFIER LA COMBI' : 'NOUVELLE COMBI'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Navigator.of(context).pop()),
        actions: [TextButton(onPressed: _enregistrer, child: const Text('SAUVER', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 1)))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('NOM'),
          const SizedBox(height: 12),
          TextField(controller: _nomCtrl, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16), onChanged: (_) => setState(() => _erreur = null),
            decoration: const InputDecoration(hintText: 'ex: Lift en duo, Accroche finale...', prefixIcon: Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20))),
          const SizedBox(height: 24),
          _label('DESCRIPTION'),
          const SizedBox(height: 12),
          TextField(controller: _descCtrl, maxLines: 3, style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Decris cette combi...', alignLabelWithHint: true)),
          const SizedBox(height: 24),
          _label('STYLE'),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: stylesCombi.map((s) {
            final sel = _styleSelectionne == s;
            final c = Color(couleurStyles[s] ?? 0xFFE63946);
            return GestureDetector(
              onTap: () => setState(() => _styleSelectionne = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(color: sel ? c.withOpacity(0.18) : AppColors.surface, borderRadius: BorderRadius.circular(30), border: Border.all(color: sel ? c : AppColors.border, width: sel ? 2 : 1)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (sel) ...[Icon(Icons.check, color: c, size: 14), const SizedBox(width: 6)],
                  Text(s, style: TextStyle(color: sel ? c : AppColors.textSecondary, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
                ]),
              ),
            );
          }).toList()),
          const SizedBox(height: 24),
          _label('PHOTO'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _afficherMenuPhoto,
            child: Container(
              width: double.infinity, height: 160,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _photoPath != null ? AppColors.accent : AppColors.border)),
              child: ClipRRect(borderRadius: BorderRadius.circular(15), child: _photoPath != null
                  ? Stack(fit: StackFit.expand, children: [
                      Image.file(File(_photoPath!), fit: BoxFit.cover),
                      Positioned(bottom: 8, right: 8, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.edit, color: Colors.white, size: 12), SizedBox(width: 4), Text('Changer', style: TextStyle(color: Colors.white, fontSize: 10))]),
                      )),
                    ])
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.accent, size: 24)),
                      const SizedBox(height: 8),
                      const Text('Ajouter une photo', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                    ])),
            ),
          ),
          const SizedBox(height: 24),
          if (_erreur != null) ...[
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.withOpacity(0.3))),
              child: Row(children: [const Icon(Icons.error_outline, color: Colors.red, size: 18), const SizedBox(width: 8), Expanded(child: Text(_erreur!, style: const TextStyle(color: Colors.red, fontSize: 13)))])),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(onPressed: _enregistrer, icon: const Icon(Icons.save_outlined, size: 18),
            label: Text(_estModification ? 'SAUVEGARDER' : 'ENREGISTRER LA COMBI')),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold));
}
