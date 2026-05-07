// ==============================================================
// FICHIER : lib/services/auth_service.dart
// ROLE    : Authentification — version 5 avec types de comptes
// ==============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _usersKey = 'users_list';
  static const String _currentUserKey = 'current_user';

  // ── Inscription ──
  Future<String?> register(UserModel user, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final Map<String, dynamic> users = jsonDecode(usersJson);

    if (users.containsKey(user.email)) return 'Cet email est deja utilise.';
    if (!user.email.contains('@')) return 'Email invalide.';
    if (password.length < 6) return 'Mot de passe trop court (6 caracteres min).';
    if (user.pseudo.trim().isEmpty) return 'Le nom ne peut pas etre vide.';

    users[user.email] = { ...user.toMap(), 'password': password };
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_currentUserKey, jsonEncode(user.toMap()));
    return null;
  }

  // ── Connexion ──
  Future<String?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final Map<String, dynamic> users = jsonDecode(usersJson);

    if (!users.containsKey(email)) return 'Aucun compte trouve avec cet email.';
    final userData = users[email] as Map<String, dynamic>;
    if (userData['password'] != password) return 'Mot de passe incorrect.';

    final user = UserModel.fromMap(userData);
    await prefs.setString(_currentUserKey, jsonEncode(user.toMap()));
    return null;
  }

  // ── Deconnexion ──
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // ── Recuperer l'utilisateur connecte ──
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return null;
    return UserModel.fromMap(jsonDecode(userJson));
  }

  // ── Mettre a jour le profil ──
  Future<void> updateProfile(UserModel updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toMap()));
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final Map<String, dynamic> users = jsonDecode(usersJson);
    if (users.containsKey(updatedUser.email)) {
      final pass = users[updatedUser.email]['password'];
      users[updatedUser.email] = { ...updatedUser.toMap(), 'password': pass };
      await prefs.setString(_usersKey, jsonEncode(users));
    }
  }
}
