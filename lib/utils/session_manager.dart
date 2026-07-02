import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

/// Menyimpan sesi login secara lokal di perangkat.
/// Token disimpan di secure storage (lebih aman dari SharedPreferences biasa),
/// sedangkan data user non-sensitif disimpan di SharedPreferences untuk akses cepat.
class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  final _secureStorage = const FlutterSecureStorage();

  Future<void> saveSession({
    required String token,
    required UserModel user,
    required bool rememberMe,
  }) async {
    await _secureStorage.write(key: AppConfig.keySessionToken, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.keyUserData, jsonEncode(user.toJson()));
    await prefs.setBool(AppConfig.keyRememberMe, rememberMe);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: AppConfig.keySessionToken);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConfig.keyUserData);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConfig.keyRememberMe) ?? false;
  }

  Future<void> updateUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.keyUserData, jsonEncode(user.toJson()));
  }

  Future<bool> hasActiveSession() async {
    final token = await getToken();
    final remember = await getRememberMe();
    return token != null && token.isNotEmpty && remember;
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: AppConfig.keySessionToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.keyUserData);
    await prefs.remove(AppConfig.keyRememberMe);
  }
}
