class UserModel {
  final String id;
  final String nama;
  final String email;
  final String foto;
  final bool paid;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.foto,
    required this.paid,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      foto: json['foto']?.toString() ?? '',
      paid: json['paid'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'foto': foto,
      'paid': paid,
    };
  }

  UserModel copyWith({String? nama, String? foto, bool? paid}) {
    return UserModel(
      id: id,
      nama: nama ?? this.nama,
      email: email,
      foto: foto ?? this.foto,
      paid: paid ?? this.paid,
    );
  }
}
