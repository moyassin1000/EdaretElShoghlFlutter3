import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';

class AuthService {
  static const _loggedInKey = 'is_logged_in';
  static const _usernameKey = 'username';
  static const _passwordKey = 'password_hash';

  Future<void> ensureDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_usernameKey, prefs.getString(_usernameKey) ?? AppConstants.defaultUsername);
    prefs.setString(_passwordKey, prefs.getString(_passwordKey) ?? _hash(AppConstants.defaultPassword));
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  Future<String> currentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? AppConstants.defaultUsername;
  }

  Future<bool> login({required String username, required String password, bool rememberMe = true}) async {
    await ensureDefaults();
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString(_usernameKey) ?? AppConstants.defaultUsername;
    final savedPass = prefs.getString(_passwordKey) ?? _hash(AppConstants.defaultPassword);
    final ok = username.trim() == savedUser && _hash(password) == savedPass;
    if (ok) {
      await prefs.setBool(_loggedInKey, rememberMe);
    }
    return ok;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
  }

  Future<void> changePassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, _hash(newPassword));
  }

  Future<void> changeUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username.trim());
  }

  String _hash(String value) => sha256.convert(utf8.encode(value)).toString();
}
