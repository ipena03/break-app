// ==============================================================
// FICHIER : lib/screens/home_page.dart
// ROLE    : Navigation dynamique — version 6
// Bboy/Bgirl : Accueil | Moovs | Passages | Crews | Events | Profil
// Crew       : Accueil | Combis | Crews | Events | Profil
// Event      : Accueil | Events | Profil
// ==============================================================

import 'package:flutter/material.dart';
import '../models/moov.dart';
import '../models/passage.dart';
import '../models/combi_model.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import 'accueil_page.dart';
import 'moovs_page.dart';
import 'passages_page.dart';
import 'combi_page.dart';
import 'crew_page.dart';
import 'event_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indexOnglet = 0;
  UserModel? _user;
  List<Moov> _moovs = [];
  List<Passage> _passages = [];
  List<Combi> _combis = [];
  List<EventModel> _events = [];
  List<UserModel> _crews = [];
  bool _chargement = true;

  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  @override
  void initState() { super.initState(); _chargerTout(); }

  Future<void> _chargerTout() async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;
    final moovs = user.estDanseur ? await _storageService.chargerMoovs(user.id) : <Moov>[];
    final passages = user.estDanseur ? await _storageService.chargerPassages(user.id) : <Passage>[];
    final combis = user.estCrew ? await _storageService.chargerCombis(user.id) : <Combi>[];
    final events = await _storageService.chargerEvents();
    final crews = await _storageService.chargerTousLesCrews();
    setState(() { _user = user; _moovs = moovs; _passages = passages; _combis = combis; _events = events; _crews = crews; _chargement = false; });
  }

  Future<void> _ajouterMoov(Moov m) async {
    if (_user == null) return;
    final moov = Moov(id: m.id, nom: m.nom, categories: m.categories, mediaUrl: m.mediaUrl, mediaType: m.mediaType, userId: _user!.id, dateCreation: m.dateCreation);
    final l = await _storageService.ajouterMoov(_user!.id, moov);
    setState(() => _moovs = l);
  }
  Future<void> _modifierMoov(Moov m) async { if (_user == null) return; final l = await _storageService.modifierMoov(_user!.id, m); setState(() => _moovs = l); }
  Future<void> _supprimerMoov(String id) async { if (_user == null) return; final l = await _storageService.supprimerMoov(_user!.id, id); setState(() => _moovs = l); }

  Future<void> _ajouterPassage(Passage p) async {
    if (_user == null) return;
    final passage = Passage(id: p.id, nom: p.nom, moovIds: p.moovIds, userId: _user!.id, dateCreation: p.dateCreation);
    final l = await _storageService.ajouterPassage(_user!.id, passage);
    setState(() => _passages = l);
  }
  Future<void> _modifierPassage(Passage p) async { if (_user == null) return; final l = await _storageService.modifierPassage(_user!.id, p); setState(() => _passages = l); }
  Future<void> _supprimerPassage(String id) async { if (_user == null) return; final l = await _storageService.supprimerPassage(_user!.id, id); setState(() => _passages = l); }

  Future<void> _ajouterCombi(Combi c) async {
    if (_user == null) return;
    final combi = Combi(id: c.id, nom: c.nom, style: c.style, description: c.description, photoPath: c.photoPath, userId: _user!.id, dateCreation: c.dateCreation);
    final l = await _storageService.ajouterCombi(_user!.id, combi);
    setState(() => _combis = l);
  }
  Future<void> _modifierCombi(Combi c) async { if (_user == null) return; final l = await _storageService.modifierCombi(_user!.id, c); setState(() => _combis = l); }
  Future<void> _supprimerCombi(String id) async { if (_user == null) return; final l = await _storageService.supprimerCombi(_user!.id, id); setState(() => _combis = l); }

  void _mettreAJourUser(UserModel u) => setState(() => _user = u);

  List<Widget> get _pages {
    if (_user == null) return [];
    if (_user!.estDanseur) return [
      AccueilPage(user: _user, moovs: _moovs, passages: _passages, combis: _combis, onAction: () => setState(() => _indexOnglet = 1)),
      MoovsPage(moovs: _moovs, onAjouter: _ajouterMoov, onModifier: _modifierMoov, onSupprimer: _supprimerMoov),
      PassagesPage(passages: _passages, moovsDispo: _moovs, onAjouter: _ajouterPassage, onModifier: _modifierPassage, onSupprimer: _supprimerPassage),
      CrewPage(crews: _crews, currentUser: _user),
      EventPage(events: _events, currentUser: _user),
      ProfilePage(userOverride: _user, onUserUpdated: _mettreAJourUser),
    ];
    if (_user!.estCrew) return [
      AccueilPage(user: _user, moovs: _moovs, passages: _passages, combis: _combis, onAction: () => setState(() => _indexOnglet = 1)),
      CombiPage(combis: _combis, onAjouter: _ajouterCombi, onModifier: _modifierCombi, onSupprimer: _supprimerCombi),
      CrewPage(crews: _crews, currentUser: _user),
      EventPage(events: _events, currentUser: _user),
      ProfilePage(userOverride: _user, onUserUpdated: _mettreAJourUser),
    ];
    return [
      AccueilPage(user: _user, moovs: _moovs, passages: _passages, combis: _combis, onAction: () {}),
      EventPage(events: _events, currentUser: _user),
      ProfilePage(userOverride: _user, onUserUpdated: _mettreAJourUser),
    ];
  }

  List<BottomNavigationBarItem> get _navItems {
    if (_user == null) return [];
    if (_user!.estDanseur) return [
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 0 ? Icons.home : Icons.home_outlined), label: 'ACCUEIL'),
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 1 ? Icons.local_fire_department : Icons.local_fire_department_outlined), label: 'MOOVS'),
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 2 ? Icons.queue_music : Icons.queue_music_outlined), label: 'PASSAGES'),
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 3 ? Icons.groups : Icons.groups_outlined), label: 'CREWS'),
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 4 ? Icons.event : Icons.event_outlined), label: 'EVENTS'),
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 5 ? Icons.person : Icons.person_outline), label: 'PROFIL'),
    ];
    if (_user!.estCrew) return [
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 0 ? Icons.home : Icons.home_outlined), label: 'ACCUEIL'),
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 1 ? Icons.sports_martial_arts : Icons.sports_martial_arts), label: 'COMBIS'),
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 2 ? Icons.groups : Icons.groups_outlined), label: 'CREWS'),
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 3 ? Icons.event : Icons.event_outlined), label: 'EVENTS'),
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 4 ? Icons.person : Icons.person_outline), label: 'PROFIL'),
    ];
    return [
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 0 ? Icons.home : Icons.home_outlined), label: 'ACCUEIL'),
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 1 ? Icons.event : Icons.event_outlined), label: 'EVENTS'),
      BottomNavigationBarItem(icon: Icon(_indexOnglet == 2 ? Icons.person : Icons.person_outline), label: 'PROFIL'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_chargement) return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
    final pages = _pages;
    final si = _indexOnglet.clamp(0, pages.length - 1);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: si, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border, width: 1))),
        child: BottomNavigationBar(
          currentIndex: si,
          onTap: (i) => setState(() => _indexOnglet = i),
          backgroundColor: AppColors.primary,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontSize: 9, letterSpacing: 0.5),
          items: _navItems,
        ),
      ),
    );
  }
}
