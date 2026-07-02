class QuestionOption {
  final String key; // A, B, C, D, E
  final String text;

  QuestionOption({required this.key, required this.text});

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      key: json['key']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }
}

class QuestionModel {
  final String id;
  final String kategori;
  final String pertanyaan;
  final List<QuestionOption> pilihan;
  String? jawabanDipilih; // diisi saat user menjawab (state lokal)

  QuestionModel({
    required this.id,
    required this.kategori,
    required this.pertanyaan,
    required this.pilihan,
    this.jawabanDipilih,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      pertanyaan: json['pertanyaan']?.toString() ?? '',
      pilihan: (json['pilihan'] as List<dynamic>? ?? [])
          .map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
