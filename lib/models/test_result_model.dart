class TestResultModel {
  final String historyId;
  final int benar;
  final int salah;
  final int totalSoal;
  final int persentase;
  final int iq;
  final String kategori;
  final int durasiDetik;
  final List<String> kekuatan;
  final List<String> perluDitingkatkan;
  final List<String> rekomendasi;

  TestResultModel({
    required this.historyId,
    required this.benar,
    required this.salah,
    required this.totalSoal,
    required this.persentase,
    required this.iq,
    required this.kategori,
    required this.durasiDetik,
    required this.kekuatan,
    required this.perluDitingkatkan,
    required this.rekomendasi,
  });

  factory TestResultModel.fromJson(Map<String, dynamic> json) {
    final analisis = json['analisis'] as Map<String, dynamic>? ?? {};
    return TestResultModel(
      historyId: json['historyId']?.toString() ?? '',
      benar: json['benar'] ?? 0,
      salah: json['salah'] ?? 0,
      totalSoal: json['totalSoal'] ?? 0,
      persentase: json['persentase'] ?? 0,
      iq: json['iq'] ?? 0,
      kategori: json['kategori']?.toString() ?? '',
      durasiDetik: json['durasiDetik'] ?? 0,
      kekuatan: List<String>.from(analisis['kekuatan'] ?? []),
      perluDitingkatkan: List<String>.from(analisis['perluDitingkatkan'] ?? []),
      rekomendasi: List<String>.from(json['rekomendasi'] ?? []),
    );
  }
}

class HistoryItemModel {
  final String id;
  final DateTime tanggal;
  final int skor;
  final int iq;
  final String kategori;
  final int benar;
  final int salah;
  final int durasi;

  HistoryItemModel({
    required this.id,
    required this.tanggal,
    required this.skor,
    required this.iq,
    required this.kategori,
    required this.benar,
    required this.salah,
    required this.durasi,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      id: json['id']?.toString() ?? '',
      tanggal: DateTime.tryParse(json['tanggal']?.toString() ?? '') ?? DateTime.now(),
      skor: json['skor'] ?? 0,
      iq: json['iq'] ?? 0,
      kategori: json['kategori']?.toString() ?? '',
      benar: json['benar'] ?? 0,
      salah: json['salah'] ?? 0,
      durasi: json['durasi'] ?? 0,
    );
  }
}
