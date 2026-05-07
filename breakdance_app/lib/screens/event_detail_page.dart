// ==============================================================
// FICHIER : lib/screens/event_detail_page.dart
// ROLE    : Detail d'un event — infos, date, description, flyers
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';

class EventDetailPage extends StatefulWidget {
  final EventModel event;
  final UserModel? currentUser; // Pour savoir si c'est le proprietaire

  const EventDetailPage({super.key, required this.event, this.currentUser});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late EventModel _event;
  final ImagePicker _picker = ImagePicker();
  final StorageService _storage = StorageService();

  // Est-ce que l'utilisateur connecte est le proprietaire de cet event ?
  bool get _estProprietaire => widget.currentUser?.id == widget.event.userId;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  // ── Ajouter un flyer ──
  Future<void> _ajouterFlyer() async {
    final XFile? f = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 90);
    if (f != null) {
      final newFlyers = [..._event.flyers, f.path];
      final updated = EventModel(
        id: _event.id, nom: _event.nom, ville: _event.ville,
        description: _event.description, photoPath: _event.photoPath,
        flyers: newFlyers, dateEvent: _event.dateEvent,
        userId: _event.userId, dateCreation: _event.dateCreation,
      );
      await _storage.upsertEvent(updated);
      setState(() => _event = updated);
    }
  }

  // ── Supprimer un flyer ──
  Future<void> _supprimerFlyer(int index) async {
    final newFlyers = List<String>.from(_event.flyers)..removeAt(index);
    final updated = EventModel(
      id: _event.id, nom: _event.nom, ville: _event.ville,
      description: _event.description, photoPath: _event.photoPath,
      flyers: newFlyers, dateEvent: _event.dateEvent,
      userId: _event.userId, dateCreation: _event.dateCreation,
    );
    await _storage.upsertEvent(updated);
    setState(() => _event = updated);
  }

  // ── Voir un flyer en grand ──
  void _voirFlyer(int index) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Stack(children: [
            InteractiveViewer(
              child: Image.file(File(_event.flyers[index]), fit: BoxFit.contain),
            ),
            Positioned(top: 8, right: 8, child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 20)),
            )),
          ]),
        ),
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'Date non definie';
    const m = ['', 'jan', 'fev', 'mar', 'avr', 'mai', 'jun', 'jul', 'aou', 'sep', 'oct', 'nov', 'dec'];
    return '${d.day} ${m[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _event.photoPath != null
                      ? Image.file(File(_event.photoPath!), fit: BoxFit.cover)
                      : Container(color: const Color(0xFFE9C46A).withOpacity(0.2),
                          child: const Icon(Icons.event, color: Color(0xFFE9C46A), size: 60)),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                  ))),
                  Positioned(bottom: 16, left: 16, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_event.nom, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Row(children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(_event.ville, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(_formatDate(_event.dateEvent), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ]),
                    ],
                  )),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Description
                if (_event.description != null && _event.description!.isNotEmpty) ...[
                  const Text('DESCRIPTION', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_event.description!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6)),
                  const SizedBox(height: 28),
                ],

                // Section Flyers
                Row(children: [
                  const Text('FLYERS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  // Bouton ajout flyer (proprietaire seulement)
                  if (_estProprietaire)
                    GestureDetector(
                      onTap: _ajouterFlyer,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.accent.withOpacity(0.4))),
                        child: const Row(children: [
                          Icon(Icons.add, color: AppColors.accent, size: 14),
                          SizedBox(width: 4),
                          Text('AJOUTER', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                ]),
                const SizedBox(height: 12),

                // Grille de flyers
                if (_event.flyers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: const Center(child: Column(children: [
                      Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 32),
                      SizedBox(height: 8),
                      Text('Aucun flyer', style: TextStyle(color: AppColors.textSecondary)),
                    ])),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.75,
                    ),
                    itemCount: _event.flyers.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _voirFlyer(i),
                      onLongPress: _estProprietaire ? () => _supprimerFlyer(i) : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(fit: StackFit.expand, children: [
                          Image.file(File(_event.flyers[i]), fit: BoxFit.cover),
                          if (_estProprietaire)
                            Positioned(top: 6, right: 6, child: GestureDetector(
                              onTap: () => _supprimerFlyer(i),
                              child: Container(padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 14)),
                            )),
                        ]),
                      ),
                    ),
                  ),

                if (_estProprietaire && _event.flyers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Appui long sur un flyer pour le supprimer', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 11)),
                  ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
