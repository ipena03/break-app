// ==============================================================
// FICHIER : lib/screens/edit_profile_page.dart
// ROLE    : Modifier mon profil — v6 avec description + date event
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_widgets.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _pseudoCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _paysCtrl;
  late TextEditingController _villeCtrl;
  String? _newPhotoPath;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pseudoCtrl = TextEditingController(text: widget.user.pseudo);
    _descCtrl = TextEditingController(text: widget.user.description ?? '');
    _paysCtrl = TextEditingController(text: widget.user.pays ?? '');
    _villeCtrl = TextEditingController(text: widget.user.ville ?? '');
    _newPhotoPath = widget.user.photoPath;
  }

  @override
  void dispose() { _pseudoCtrl.dispose(); _descCtrl.dispose(); _paysCtrl.dispose(); _villeCtrl.dispose(); super.dispose(); }

  void _choisirPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: AppColors.accent),
            title: const Text('Prendre une photo', style: TextStyle(color: AppColors.textPrimary)),
            onTap: () async { Navigator.pop(ctx); final f = await _picker.pickImage(source: ImageSource.camera, maxWidth: 500, imageQuality: 80); if (f != null) setState(() => _newPhotoPath = f.path); },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: AppColors.accent),
            title: const Text('Choisir depuis la galerie', style: TextStyle(color: AppColors.textPrimary)),
            onTap: () async { Navigator.pop(ctx); final f = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 500, imageQuality: 80); if (f != null) setState(() => _newPhotoPath = f.path); },
          ),
          if (_newPhotoPath != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
              onTap: () { Navigator.pop(ctx); setState(() => _newPhotoPath = null); },
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Future<void> _sauvegarder() async {
    if (_pseudoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le nom ne peut pas etre vide'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);

    final updatedUser = UserModel(
      id: widget.user.id, email: widget.user.email,
      pseudo: _pseudoCtrl.text.trim(),
      photoPath: _newPhotoPath,
      accountType: widget.user.accountType,
      pays: _paysCtrl.text.trim().isEmpty ? null : _paysCtrl.text.trim(),
      ville: _villeCtrl.text.trim().isEmpty ? null : _villeCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      crewId: widget.user.crewId,
    );

    await AuthService().updateProfile(updatedUser);

    // Si c'est un event, on met aussi a jour l'event global
    if (widget.user.estEvent) {
      final events = await StorageService().chargerEvents();
      final i = events.indexWhere((e) => e.userId == widget.user.id);
      if (i != -1) {
        final updatedEvent = EventModel(
          id: events[i].id, nom: updatedUser.pseudo,
          ville: updatedUser.ville ?? events[i].ville,
          description: updatedUser.description,
          photoPath: updatedUser.photoPath,
          flyers: events[i].flyers, dateEvent: events[i].dateEvent,
          userId: events[i].userId, dateCreation: events[i].dateCreation,
        );
        await StorageService().upsertEvent(updatedEvent);
      }
    }

    setState(() => _isLoading = false);
    if (mounted) Navigator.of(context).pop(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('MODIFIER MON PROFIL'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Navigator.of(context).pop()),
        actions: [TextButton(onPressed: _isLoading ? null : _sauvegarder, child: Text('SAUVER', style: TextStyle(color: _isLoading ? AppColors.textSecondary : AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 1)))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Photo
          Center(child: ProfileAvatar(photoPath: _newPhotoPath, size: 100, onTap: _choisirPhoto)),
          const SizedBox(height: 6),
          const Text('Appuie pour changer', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 28),

          // Nom / Pseudo
          _buildField(_pseudoCtrl, widget.user.estCrew ? 'Nom du crew' : widget.user.estEvent ? 'Nom de l\'event' : 'Pseudo', Icons.tag),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: _descCtrl, maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Description / Bio', hintText: 'Decris toi en quelques mots...', alignLabelWithHint: true),
          ),
          const SizedBox(height: 16),

          // Pays (crew)
          if (widget.user.estCrew) ...[_buildField(_paysCtrl, 'Pays', Icons.flag_outlined), const SizedBox(height: 16)],
          // Ville (event)
          if (widget.user.estEvent) ...[_buildField(_villeCtrl, 'Ville', Icons.location_on_outlined), const SizedBox(height: 16)],

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _sauvegarder,
            child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('SAUVEGARDER'),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon) => TextField(
    controller: ctrl,
    style: const TextStyle(color: AppColors.textPrimary),
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20)),
  );
}
