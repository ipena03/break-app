// ==============================================================
// FICHIER : lib/services/storage_service.dart
// ROLE    : Sauvegarde et chargement — version 6
// ==============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/moov.dart';
import '../models/passage.dart';
import '../models/combi_model.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

class StorageService {
  String _moovKey(String uid) => 'moovs_$uid';
  String _passageKey(String uid) => 'passages_$uid';
  String _combiKey(String uid) => 'combis_$uid';
  static const String _eventsKey = 'events_global';

  // ─── MOOVS ───
  Future<List<Moov>> chargerMoovs(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final list = jsonDecode(prefs.getString(_moovKey(uid)) ?? '[]') as List;
    return list.map((e) => Moov.fromJson(e)).toList();
  }
  Future<void> _saveMoovs(String uid, List<Moov> l) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_moovKey(uid), jsonEncode(l.map((e) => e.toJson()).toList()));
  }
  Future<List<Moov>> ajouterMoov(String uid, Moov m) async { final l = await chargerMoovs(uid); l.insert(0, m); await _saveMoovs(uid, l); return l; }
  Future<List<Moov>> modifierMoov(String uid, Moov m) async { final l = await chargerMoovs(uid); final i = l.indexWhere((e) => e.id == m.id); if (i != -1) { l[i] = m; await _saveMoovs(uid, l); } return l; }
  Future<List<Moov>> supprimerMoov(String uid, String id) async { final l = await chargerMoovs(uid); l.removeWhere((e) => e.id == id); await _saveMoovs(uid, l); return l; }

  // ─── PASSAGES ───
  Future<List<Passage>> chargerPassages(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final list = jsonDecode(prefs.getString(_passageKey(uid)) ?? '[]') as List;
    return list.map((e) => Passage.fromJson(e)).toList();
  }
  Future<void> _savePassages(String uid, List<Passage> l) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passageKey(uid), jsonEncode(l.map((e) => e.toJson()).toList()));
  }
  Future<List<Passage>> ajouterPassage(String uid, Passage p) async { final l = await chargerPassages(uid); l.insert(0, p); await _savePassages(uid, l); return l; }
  Future<List<Passage>> modifierPassage(String uid, Passage p) async { final l = await chargerPassages(uid); final i = l.indexWhere((e) => e.id == p.id); if (i != -1) { l[i] = p; await _savePassages(uid, l); } return l; }
  Future<List<Passage>> supprimerPassage(String uid, String id) async { final l = await chargerPassages(uid); l.removeWhere((e) => e.id == id); await _savePassages(uid, l); return l; }

  // ─── COMBIS ───
  Future<List<Combi>> chargerCombis(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final list = jsonDecode(prefs.getString(_combiKey(uid)) ?? '[]') as List;
    return list.map((e) => Combi.fromJson(e)).toList();
  }
  Future<void> _saveCombis(String uid, List<Combi> l) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_combiKey(uid), jsonEncode(l.map((e) => e.toJson()).toList()));
  }
  Future<List<Combi>> ajouterCombi(String uid, Combi c) async { final l = await chargerCombis(uid); l.insert(0, c); await _saveCombis(uid, l); return l; }
  Future<List<Combi>> modifierCombi(String uid, Combi c) async { final l = await chargerCombis(uid); final i = l.indexWhere((e) => e.id == c.id); if (i != -1) { l[i] = c; await _saveCombis(uid, l); } return l; }
  Future<List<Combi>> supprimerCombi(String uid, String id) async { final l = await chargerCombis(uid); l.removeWhere((e) => e.id == id); await _saveCombis(uid, l); return l; }

  // ─── EVENTS ───
  Future<List<EventModel>> chargerEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final list = jsonDecode(prefs.getString(_eventsKey) ?? '[]') as List;
    return list.map((e) => EventModel.fromJson(e)).toList();
  }
  Future<void> sauvegarderEvents(List<EventModel> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_eventsKey, jsonEncode(events.map((e) => e.toJson()).toList()));
  }
  Future<void> upsertEvent(EventModel event) async {
    final events = await chargerEvents();
    final i = events.indexWhere((e) => e.userId == event.userId);
    if (i != -1) events[i] = event; else events.insert(0, event);
    await sauvegarderEvents(events);
  }
  Future<void> mettreAJourEvent(EventModel event) async => upsertEvent(event);

  // ─── CREWS (liste publique) ───
  Future<List<UserModel>> chargerTousLesCrews() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users_list') ?? '{}';
    final Map<String, dynamic> users = jsonDecode(usersJson);
    return users.values
        .where((u) => u['accountType'] == 'crew')
        .map((u) => UserModel.fromMap(u as Map<String, dynamic>))
        .toList();
  }
}
