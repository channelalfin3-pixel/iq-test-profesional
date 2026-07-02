import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';
import '../utils/session_manager.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepository();

  AuthStatus status = AuthStatus.unknown;
  UserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;

  /// Dipanggil saat splash screen untuk cek apakah user masih punya sesi aktif
  Future<void> checkSession() async {
    final hasSession = await SessionManager.instance.hasActiveSession();
    if (hasSession) {
      currentUser = await SessionManager.instance.getUser();
      status = AuthStatus.authenticated;
    } else {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password, {bool rememberMe = true}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repo.login(email: email, password: password, rememberMe: rememberMe);

    isLoading = false;
    if (result.success) {
      currentUser = await SessionManager.instance.getUser();
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      errorMessage = result.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String nama, String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repo.register(nama: nama, email: email, password: password);

    isLoading = false;
    if (!result.success) errorMessage = result.message;
    notifyListeners();
    return result.success;
  }

  Future<bool> forgotPassword(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final result = await _repo.forgotPassword(email);
    isLoading = false;
    if (!result.success) errorMessage = result.message;
    notifyListeners();
    return result.success;
  }

  Future<bool> resetPassword(String email, String token, String newPassword) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final result = await _repo.resetPassword(email: email, resetToken: token, newPassword: newPassword);
    isLoading = false;
    if (!result.success) errorMessage = result.message;
    notifyListeners();
    return result.success;
  }

  Future<bool> uploadPhoto(String base64Data, String mimeType) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final result = await _repo.uploadPhoto(base64Data: base64Data, mimeType: mimeType);
    isLoading = false;
    if (result.success && currentUser != null) {
      final url = (result.data as Map<String, dynamic>)['url']?.toString() ?? '';
      currentUser = currentUser!.copyWith(foto: url);
      await SessionManager.instance.updateUser(currentUser!);
      notifyListeners();
      return true;
    }
    errorMessage = result.message;
    notifyListeners();
    return false;
  }

  Future<bool> updateProfile({String? nama, String? newPassword}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final result = await _repo.updateProfile(nama: nama, newPassword: newPassword);
    isLoading = false;
    if (result.success && currentUser != null) {
      if (nama != null) currentUser = currentUser!.copyWith(nama: nama);
      await SessionManager.instance.updateUser(currentUser!);
      notifyListeners();
      return true;
    }
    errorMessage = result.message;
    notifyListeners();
    return false;
  }

  Future<void> updatePaidStatus(bool paid) async {
    if (currentUser == null) return;
    currentUser = currentUser!.copyWith(paid: paid);
    await SessionManager.instance.updateUser(currentUser!);
    notifyListeners();
  }

  Future<void> logout() async {
    await _repo.logout();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
