// ==============================================================
// FICHIER : lib/screens/register_page.dart
// ROLE    : Inscription — le formulaire change selon le type de compte
// VERSION : 5 — bboy, bgirl, crew, event
// ==============================================================

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Type de compte selectionne (par defaut : bboy)
  String _accountType = 'bboy';

  // Controleurs communs a tous les types
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nomCtrl = TextEditingController(); // pseudo / nom crew / nom event

  // Controleurs specifiques
  final _paysCtrl = TextEditingController();  // Pour crew
  final _villeCtrl = TextEditingController(); // Pour event

  bool _showPassword = false;
  bool _isLoading = false;
  String? _erreur;

  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  @override
  void dispose() {
    _emailCtrl.dispose(); _passwordCtrl.dispose(); _confirmCtrl.dispose();
    _nomCtrl.dispose(); _paysCtrl.dispose(); _villeCtrl.dispose();
    super.dispose();
  }

  // ── Inscription ──
  Future<void> _handleRegister() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final nom = _nomCtrl.text.trim();

    // Validations communes
    if (email.isEmpty || password.isEmpty || nom.isEmpty) {
      setState(() => _erreur = 'Remplis tous les champs obligatoires.'); return;
    }
    if (password != _confirmCtrl.text) {
      setState(() => _erreur = 'Les mots de passe ne correspondent pas.'); return;
    }

    // Validations specifiques au type
    if (_accountType == 'crew' && _paysCtrl.text.trim().isEmpty) {
      setState(() => _erreur = 'Indique le pays du crew.'); return;
    }
    if (_accountType == 'event' && _villeCtrl.text.trim().isEmpty) {
      setState(() => _erreur = 'Indique la ville de l\'event.'); return;
    }

    setState(() { _isLoading = true; _erreur = null; });

    // Creation de l'utilisateur avec le bon type
    final user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      pseudo: nom,
      accountType: _accountType,
      pays: _accountType == 'crew' ? _paysCtrl.text.trim() : null,
      ville: _accountType == 'event' ? _villeCtrl.text.trim() : null,
    );

    final error = await _authService.register(user, password);
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _erreur = error);
    } else {
      // Si c'est un event, on l'ajoute dans la liste globale des events
      if (_accountType == 'event') {
        await _storageService.upsertEvent(EventModel(
          id: 'event_${user.id}',
          nom: nom,
          ville: _villeCtrl.text.trim(),
          userId: user.id,
          dateCreation: DateTime.now(),
        ));
      }
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('CREER UN COMPTE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Choix du type de compte ──
              _label('TYPE DE COMPTE'),
              const SizedBox(height: 12),
              // Grille 2x2 pour les 4 types
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.5,
                children: [
                  _buildTypeCard('bboy', 'B-BOY', Icons.boy),
                  _buildTypeCard('bgirl', 'B-GIRL', Icons.girl),
                  _buildTypeCard('crew', 'CREW', Icons.groups),
                  _buildTypeCard('event', 'EVENT', Icons.event),
                ],
              ),

              const SizedBox(height: 28),

              // ── Champs communs ──
              _label('INFORMATIONS'),
              const SizedBox(height: 12),

              // Nom/Pseudo/Nom event (label change selon le type)
              _buildTextField(
                controller: _nomCtrl,
                label: _accountType == 'crew' ? 'Nom du crew' : _accountType == 'event' ? 'Nom de l\'event' : 'Pseudo',
                hint: _accountType == 'crew' ? 'ex: Alpha Crew' : _accountType == 'event' ? 'ex: Battle of Nations' : 'ex: B-Boy Shadow',
                icon: Icons.tag,
              ),
              const SizedBox(height: 14),

              // Pays (uniquement crew)
              if (_accountType == 'crew') ...[
                _buildTextField(controller: _paysCtrl, label: 'Pays', hint: 'ex: France', icon: Icons.flag_outlined),
                const SizedBox(height: 14),
              ],

              // Ville (uniquement event)
              if (_accountType == 'event') ...[
                _buildTextField(controller: _villeCtrl, label: 'Ville', hint: 'ex: Paris', icon: Icons.location_on_outlined),
                const SizedBox(height: 14),
              ],

              _buildTextField(controller: _emailCtrl, label: 'Email', hint: 'votre@email.com', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
              const SizedBox(height: 14),

              // Mot de passe
              TextField(
                controller: _passwordCtrl,
                obscureText: !_showPassword,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  hintText: '6 caracteres minimum',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary, size: 20),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _confirmCtrl,
                obscureText: !_showPassword,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                ),
              ),

              const SizedBox(height: 24),

              // Erreur
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

              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('CREER MON COMPTE'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Carte de selection du type de compte ──
  Widget _buildTypeCard(String type, String label, IconData icon) {
    final estSelectionne = _accountType == type;
    return GestureDetector(
      onTap: () => setState(() => _accountType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: estSelectionne ? AppColors.accent.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: estSelectionne ? AppColors.accent : AppColors.border, width: estSelectionne ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: estSelectionne ? AppColors.accent : AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: estSelectionne ? AppColors.accent : AppColors.textSecondary, fontWeight: estSelectionne ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold));
}
