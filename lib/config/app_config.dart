/// Konfigurasi global aplikasi.
/// GANTI [baseUrl] dengan Web App URL hasil deploy Google Apps Script Anda.
class AppConfig {
  AppConfig._();

  /// Contoh: https://script.google.com/macros/s/XXXXXXXXXXXXX/exec
  static const String baseUrl =
      'https://script.google.com/macros/s/AKfycbzle3Nl5JKczR9mJm5yLshNjgAhmfoANak7waey9TWjjZtThCqzboT5aLf2vmtlyWAXBQ/exec';

  static const String appName = 'IQ Test Professional';

  static const int testDurationMinutes = 45;
  static const int totalQuestions = 40;
  static const int testPrice = 20000; // Rupiah, sinkron dengan Config.gs backend

  static const String certificateIssuer = 'DIGITAL LEARNING INDONESIA';
  static const String certificateIssuerRole = 'Program Asesmen & Pengembangan Diri';

  // Key untuk penyimpanan lokal (SharedPreferences / SecureStorage)
  static const String keySessionToken = 'session_token';
  static const String keyUserData = 'user_data';
  static const String keyRememberMe = 'remember_me';
  static const String keyThemeMode = 'theme_mode';
}
