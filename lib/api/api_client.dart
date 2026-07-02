import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Hasil standar dari setiap pemanggilan API
class ApiResult {
  final bool success;
  final String message;
  final dynamic data;

  ApiResult({required this.success, required this.message, this.data});

  factory ApiResult.fromJson(Map<String, dynamic> json) {
    return ApiResult(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'],
    );
  }

  factory ApiResult.error(String message) {
    return ApiResult(success: false, message: message);
  }
}

/// Client HTTP terpusat. Semua request ke backend Apps Script HARUS lewat sini
/// agar penanganan error, timeout, dan format request konsisten.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const Duration _timeout = Duration(seconds: 25);

  /// Semua endpoint backend memakai POST dengan body { action: ..., ...data }
  ///
  /// CATATAN PENTING: Content-Type sengaja "text/plain", BUKAN "application/json".
  /// Google Apps Script tidak mengirim header CORS untuk preflight request,
  /// sehingga browser (termasuk saat testing via `flutter run -d chrome`)
  /// akan memblokir request POST jika Content-Type-nya "application/json".
  /// Memakai "text/plain" menghindari preflight sama sekali. Apps Script tetap
  /// bisa membaca body-nya sebagai JSON biasa karena ia mem-parsing berdasarkan
  /// isi (jsonEncode), bukan berdasarkan header Content-Type.
  /// JANGAN diubah kembali ke "application/json".
  Future<ApiResult> post(String action, Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(AppConfig.baseUrl),
            headers: {'Content-Type': 'text/plain;charset=utf-8'},
            body: jsonEncode({'action': action, ...data}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        return ApiResult.error('Server error (${response.statusCode}). Coba lagi nanti.');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResult.fromJson(decoded);
    } on FormatException {
      return ApiResult.error('Respons server tidak valid. Pastikan BASE_URL sudah benar.');
    } catch (e) {
      return ApiResult.error('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    }
  }
}
