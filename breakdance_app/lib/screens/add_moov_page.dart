// ==============================================================
// FICHIER : lib/screens/add_moov_page.dart
// ROLE    : Formulaire pour creer un nouveau moov
// VERSION : 4.4 — Photo ou Video, galerie ou camera
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/moov.dart';
import '../widgets/app_theme.dart';

class AddMoovPage extends StatefulWidget {
  const AddMoovPage({super.key});

  @override
  State<AddMoovPage> createState() => _AddMoovPageState();
}

class _AddMoovPageState extends State<AddMoovPage> {

  final TextEditingController _nomController = TextEditingController();
  final List<String> _categoriesSelectionnees = [];
  final ImagePicker _picker = ImagePicker();
  String? _erreur;
  String? _mediaPath;
  String? _mediaType;

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  Future<void> _prendrePhoto() async {
    try {
      final XFile? f = await _picker.pickImage(source: ImageSource.camera, maxWidth: 800, imageQuality: 85);
      if (f != null) setState(() { _mediaPath = f.path; _mediaType = 'photo'; });
    } catch (e) {
      setState(() => _erreur = 'Impossible d\'ouvrir la camera.');
    }
  }

  Future<void> _choisirPhoto() async {
    try {
      final XFile? f = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
      if (f != null) setState(() { _mediaPath = f.path; _mediaType = 'photo'; });
    } catch (e) {
      setState(() => _erreur = 'Impossible d\'acceder a la galerie.');
    }
  }

  Future<void> _filmerVideo() async {
    try {
      final XFile? f = await _picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(minutes: 5));
      if (f != null) setState(() { _mediaPath = f.path; _mediaType = 'video'; });
    } catch (e) {
      setState(() => _erreur = 'Impossible d\'ouvrir la camera video.');
    }
  }

  Future<void> _choisirVideo() async {
    try {
      final XFile? f = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 5));
      if (f != null) setState(() { _mediaPath = f.path; _mediaType = 'video'; });
    } catch (e) {
      setState(() => _erreur = 'Impossible d\'acceder aux videos.');
    }
  }

  void _afficherMenuMedia() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('AJOUTER UN MEDIA', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            // Section PHOTO
            const Align(alignment: Alignment.centerLeft,
              child: Padding(padding: EdgeInsets.only(left: 16, bottom: 4),
                child: Text('PHOTO', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)))),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.camera_alt, color: AppColors.accent)),
              title: const Text('Prendre une photo', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              subtitle: const Text('Ouvrir la camera maintenant', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () { Navigator.pop(ctx); _prendrePhoto(); },
            ),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.photo_library, color: AppColors.accent)),
              title: const Text('Choisir une photo', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              subtitle: const Text('Depuis ta galerie', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () { Navigator.pop(ctx); _choisirPhoto(); },
            ),
            const Divider(color: AppColors.border),
            // Section VIDEO
            const Align(alignment: Alignment.centerLeft,
              child: Padding(padding: EdgeInsets.only(left: 16, bottom: 4),
                child: Text('VIDEO', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)))),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF457B9D).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.videocam, color: Color(0xFF457B9D))),
              title: const Text('Filmer maintenant', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              subtitle: const Text('Ouvrir la camera pour filmer', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () { Navigator.pop(ctx); _filmerVideo(); },
            ),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF457B9D).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.video_library, color: Color(0xFF457B9D))),
              title: const Text('Choisir une video', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              subtitle: const Text('Depuis ta galerie (max 5 min)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () { Navigator.pop(ctx); _choisirVideo(); },
            ),
            if (_mediaPath != null) ...[
              const Divider(color: AppColors.border),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.delete_outline, color: Colors.red)),
                title: const Text('Supprimer le media', style: TextStyle(color: Colors.red)),
                onTap: () { Navigator.pop(ctx); setState(() { _mediaPath = null; _mediaType = null; }); },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _toggleCategorie(String cat) {
    setState(() {
      if (_categoriesSelectionnees.contains(cat)) {
        _categoriesSelectionnees.remove(cat);
      } else {
        _categoriesSelectionnees.add(cat);
      }
    });
  }

  void _enregistrer() {
    final nom = _nomController.text.trim();
    if (nom.isEmpty) { setState(() => _erreur = 'Donne un nom a ton moov !'); return; }
    if (_categoriesSelectionnees.isEmpty) { setState(() => _erreur = 'Choisis au moins une categorie.'); return; }
    final nouveauMoov = Moov(
      id: 'moov_${DateTime.now().millisecondsSinceEpoch}',
      nom: nom,
      categories: List.from(_categoriesSelectionnees),
      mediaUrl: _mediaPath,
      mediaType: _mediaType,
      userId: '',
      dateCreation: DateTime.now(),
    );
    Navigator.of(context).pop(nouveauMoov);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('NOUVEAU MOOV'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Navigator.of(context).pop()),
        actions: [TextButton(onPressed: _enregistrer, child: const Text('SAUVER', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 1)))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('NOM DU MOOV'),
            const SizedBox(height: 12),
            TextField(
              controller: _nomController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              onChanged: (_) => setState(() => _erreur = null),
              decoration: const InputDecoration(
                hintText: 'ex: Six Step, Windmill, Freeze...',
                prefixIcon: Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
              ),
            ),
            const SizedBox(height: 32),
            _label('CATEGORIES'),
            const SizedBox(height: 4),
            const Text('Tu peux en selectionner plusieurs', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: categoriesDisponibles.map((cat) {
                final estSel = _categoriesSelectionnees.contains(cat);
                final couleur = Color(couleurCategories[cat] ?? 0xFFE63946);
                return GestureDetector(
                  onTap: () => _toggleCategorie(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: estSel ? couleur.withOpacity(0.18) : AppColors.surface,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: estSel ? couleur : AppColors.border, width: estSel ? 2 : 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (estSel) ...[Icon(Icons.check, color: couleur, size: 14), const SizedBox(width: 6)],
                        Text(cat, style: TextStyle(color: estSel ? couleur : AppColors.textSecondary, fontWeight: estSel ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            _label('PHOTO / VIDEO'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _afficherMenuMedia,
              child: Container(
                width: double.infinity, height: 180,
                decoration: BoxDecoration(
                  color: AppColors.surface, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _mediaPath != null ? AppColors.accent : AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _mediaPath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.accent, size: 24)),
                              const SizedBox(width: 16),
                              const Text('ou', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              const SizedBox(width: 16),
                              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Color(0xFF457B9D).withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.videocam_outlined, color: Color(0xFF457B9D), size: 24)),
                            ]),
                            const SizedBox(height: 12),
                            const Text('Ajouter une photo ou une video', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            const Text('Appuie pour choisir', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          ],
                        )
                      : Stack(fit: StackFit.expand, children: [
                          if (_mediaType == 'photo') Image.file(File(_mediaPath!), fit: BoxFit.cover),
                          if (_mediaType == 'video')
                            Container(color: Colors.black,
                              child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.play_circle_outline, color: Colors.white, size: 52),
                                SizedBox(height: 8),
                                Text('Video selectionnee', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              ]))),
                          Positioned(top: 10, left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: _mediaType == 'video' ? const Color(0xFF457B9D) : AppColors.accent, borderRadius: BorderRadius.circular(20)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(_mediaType == 'video' ? Icons.videocam : Icons.photo, color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text(_mediaType == 'video' ? 'VIDEO' : 'PHOTO', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ]),
                            )),
                          Positioned(bottom: 10, right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.edit, color: Colors.white, size: 13),
                                SizedBox(width: 4),
                                Text('Changer', style: TextStyle(color: Colors.white, fontSize: 11)),
                              ]),
                            )),
                        ]),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_erreur != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_erreur!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                ]),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(onPressed: _enregistrer, icon: const Icon(Icons.save_outlined, size: 18), label: const Text('ENREGISTRER LE MOOV')),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold));
}
