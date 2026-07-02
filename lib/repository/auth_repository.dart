import '../api/api_client.dart';
import '../models/user_model.dart';
import '../utils/session_manager.dart';

class AuthRepository {
  final _api = ApiClient.instance;

  Future<ApiResult> register({
    required String nama,
    required String email,
    required String password,
  }) {
    return _api.post('register', {
      'nama': nama,
      'email': email,
      'password': password,
    });
  }

  Future<ApiResult> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final result = await _api.post('login', {'email': email, 'password': password});
    if (result.success && result.data != null) {
      final data = result.data as Map<String, dynamic>;
      final token = data['token']?.toString() ?? '';
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await SessionManager.instance.saveSession(token: token, user: user, rememberMe: rememberMe);
    }
    return result;
  }

  Future<ApiResult> forgotPassword(String email) {
    return _api.post('forgotPassword', {'email': email});
  }

  Future<ApiResult> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) {
    return _api.post('resetPassword', {
      'email': email,
      'resetToken': resetToken,
      'newPassword': newPassword,
    });
  }

  Future<ApiResult> uploadPhoto({required String base64Data, required String mimeType}) async {
    final token = await SessionManager.instance.getToken();
    return _api.post('uploadPhoto', {
      'token': token,
      'base64Data': base64Data,
      'mimeType': mimeType,
    });
  }

  Future<ApiResult> updateProfile({String? nama, String? foto, String? newPassword}) async {
    final token = await SessionManager.instance.getToken();
    return _api.post('updateProfile', {
      'token': token,
      if (nama != null) 'nama': nama,
      if (foto != null) 'foto': foto,
      if (newPassword != null) 'newPassword': newPassword,
    });
  }

  Future<void> logout() async {
    final token = await SessionManager.instance.getToken();
    await _api.post('logout', {'token': token});
    await SessionManager.instance.clearSession();
  }
}
