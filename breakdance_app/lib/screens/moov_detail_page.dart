// ==============================================================
// FICHIER : lib/screens/moov_detail_page.dart
// ROLE    : Detail d'un moov — voir + modifier (nom, categories, photo/video)
// VERSION : 4.4 — camera + galerie pour photo et video
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../models/moov.dart';
import '../widgets/app_theme.dart';

class MoovDetailPage extends StatefulWidget {
  final Moov moov;
  const MoovDetailPage({super.key, required this.moov});

  @override
  State<MoovDetailPage> createState() => _MoovDetailPageState();
}

class _MoovDetailPageState extends State<MoovDetailPage> {

  late TextEditingController _nomController;
  late List<String> _categoriesSelectionnees;
  String? _mediaPath;
  String? _mediaType;
  bool _modeEdition = false;
  bool _voirMediaGrand = false;
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.moov.nom);
    _categoriesSelectionnees = List.from(widget.moov.categories);
    _mediaPath = widget.moov.mediaUrl;
    _mediaType = widget.moov.mediaType;
    if (_mediaType == 'video' && _mediaPath != null) {
      _initialiserVideo(_mediaPath!);
    }
  }

  Future<void> _initialiserVideo(String path) async {
    _videoController?.dispose();
    final controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    controller.setLooping(true);
    setState(() => _videoController = controller);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  // ── Les 4 methodes de selection media ──

  Future<void> _prendrePhoto() async {
    final XFile? f = await _picker.pickImage(source: ImageSource.camera, maxWidth: 800, imageQuality: 85);
    if (f != null) {
      _videoController?.dispose();
      setState(() { _mediaPath = f.path; _mediaType = 'photo'; _videoController = null; });
    }
  }

  Future<void> _choisirPhoto() async {
    final XFile? f = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (f != null) {
      _videoController?.dispose();
      setState(() { _mediaPath = f.path; _mediaType = 'photo'; _videoController = null; });
    }
  }

  Future<void> _filmerVideo() async {
    final XFile? f = await _picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(minutes: 5));
    if (f != null) {
      setState(() { _mediaPath = f.path; _mediaType = 'video'; });
      await _initialiserVideo(f.path);
    }
  }

  Future<void> _choisirVideo() async {
    final XFile? f = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 5));
    if (f != null) {
      setState(() { _mediaPath = f.path; _mediaType = 'video'; });
      await _initialiserVideo(f.path);
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
            const Text('CHANGER LE MEDIA', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
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
                onTap: () {
                  Navigator.pop(ctx);
                  _videoController?.dispose();
                  setState(() { _mediaPath = null; _mediaType = null; _videoController = null; });
                },
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

  void _sauvegarder() {
    if (_nomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le nom ne peut pas etre vide'), backgroundColor: Colors.red));
      return;
    }
    if (_categoriesSelectionnees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choisis au moins une categorie'), backgroundColor: Colors.red));
      return;
    }
    final moovModifie = Moov(
      id: widget.moov.id,
      nom: _nomController.text.trim(),
      categories: List.from(_categoriesSelectionnees),
      mediaUrl: _mediaPath,
      mediaType: _mediaType,
      userId: widget.moov.userId,
      dateCreation: widget.moov.dateCreation,
    );
    Navigator.of(context).pop(moovModifie);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(_modeEdition ? 'MODIFIER LE MOOV' : widget.moov.nom, style: const TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () { if (_modeEdition) _confirmerAbandon(); else Navigator.of(context).pop(); },
        ),
        actions: [
          if (!_modeEdition)
            TextButton(onPressed: () => setState(() => _modeEdition = true),
              child: const Text('MODIFIER', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 1))),
          if (_modeEdition)
            TextButton(onPressed: _sauvegarder,
              child: const Text('SAUVER', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 1))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zone media
            GestureDetector(
              onTap: _modeEdition ? _afficherMenuMedia : (_mediaPath != null ? () => setState(() => _voirMediaGrand = true) : null),
              child: Container(
                width: double.infinity, height: 220,
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _mediaPath == null
                      ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(_modeEdition ? Icons.add_photo_alternate_outlined : Icons.image_outlined, color: AppColors.textSecondary, size: 40),
                          const SizedBox(height: 8),
                          Text(_modeEdition ? 'Ajouter un media' : 'Pas de media', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ])
                      : Stack(fit: StackFit.expand, children: [
                          if (_mediaType == 'photo') Image.file(File(_mediaPath!), fit: BoxFit.cover),
                          if (_mediaType == 'video')
                            _videoController != null && _videoController!.value.isInitialized
                                ? GestureDetector(
                                    onTap: () => setState(() {
                                      _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                                    }),
                                    child: Stack(fit: StackFit.expand, children: [
                                      FittedBox(fit: BoxFit.cover,
                                        child: SizedBox(width: _videoController!.value.size.width, height: _videoController!.value.size.height,
                                          child: VideoPlayer(_videoController!))),
                                      Center(child: AnimatedOpacity(
                                        opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                                        duration: const Duration(milliseconds: 300),
                                        child: Container(padding: const EdgeInsets.all(12),
                                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 36)),
                                      )),
                                    ]))
                                : const Center(child: CircularProgressIndicator(color: AppColors.accent)),
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
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(_modeEdition ? Icons.edit : Icons.zoom_in, color: Colors.white, size: 13),
                                const SizedBox(width: 4),
                                Text(_modeEdition ? 'Changer' : 'Voir', style: const TextStyle(color: Colors.white, fontSize: 11)),
                              ]),
                            )),
                        ]),
                ),
              ),
            ),
            const SizedBox(height: 28),
            _label('NOM DU MOOV'),
            const SizedBox(height: 10),
            _modeEdition
                ? TextField(controller: _nomController, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20)))
                : Text(widget.moov.nom, style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 28),
            _label('CATEGORIES'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _modeEdition
                  ? categoriesDisponibles.map((cat) {
                      final sel = _categoriesSelectionnees.contains(cat);
                      final c = Color(couleurCategories[cat] ?? 0xFFE63946);
                      return GestureDetector(
                        onTap: () => _toggleCategorie(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: sel ? c.withOpacity(0.18) : AppColors.surface, borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: sel ? c : AppColors.border, width: sel ? 2 : 1)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (sel) ...[Icon(Icons.check, color: c, size: 13), const SizedBox(width: 5)],
                            Text(cat, style: TextStyle(color: sel ? c : AppColors.textSecondary, fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                          ]),
                        ),
                      );
                    }).toList()
                  : widget.moov.categories.map((cat) {
                      final c = Color(couleurCategories[cat] ?? 0xFFE63946);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(30), border: Border.all(color: c.withOpacity(0.4))),
                        child: Text(cat, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
            ),
            const SizedBox(height: 28),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 13),
              const SizedBox(width: 6),
              Text('Ajoute le ${_formatDate(widget.moov.dateCreation)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomSheet: _voirMediaGrand && _mediaPath != null
          ? GestureDetector(
              onTap: () => setState(() => _voirMediaGrand = false),
              child: Container(
                color: Colors.black.withOpacity(0.95), width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Stack(children: [
                  Center(
                    child: _mediaType == 'photo'
                        ? Image.file(File(_mediaPath!), fit: BoxFit.contain)
                        : (_videoController != null && _videoController!.value.isInitialized
                            ? GestureDetector(
                                onTap: () => setState(() {
                                  _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                                }),
                                child: AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!)))
                            : const CircularProgressIndicator(color: AppColors.accent)),
                  ),
                  Positioned(top: 16, right: 16,
                    child: GestureDetector(
                      onTap: () => setState(() => _voirMediaGrand = false),
                      child: Container(padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.close, color: Colors.white, size: 20)))),
                  const Positioned(bottom: 20, left: 0, right: 0,
                    child: Text('Appuie pour fermer', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12))),
                ]),
              ))
          : null,
    );
  }

  Future<void> _confirmerAbandon() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Abandonner les modifications ?', style: TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        content: const Text('Les changements non sauvegardes seront perdus.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CONTINUER', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ABANDONNER', style: TextStyle(color: AppColors.accent))),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() {
        _modeEdition = false;
        _nomController.text = widget.moov.nom;
        _categoriesSelectionnees = List.from(widget.moov.categories);
        _mediaPath = widget.moov.mediaUrl;
        _mediaType = widget.moov.mediaType;
      });
      if (_mediaType == 'video' && _mediaPath != null) await _initialiserVideo(_mediaPath!);
    }
  }

  Widget _label(String t) => Text(t, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold));

  String _formatDate(DateTime d) {
    const m = ['', 'jan', 'fev', 'mar', 'avr', 'mai', 'jun', 'jul', 'aou', 'sep', 'oct', 'nov', 'dec'];
    return '${d.day} ${m[d.month]} ${d.year}';
  }
}
