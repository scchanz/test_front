class MenuModel {
  final String id;
  final String nama;
  final String tipe;
  final List<String>? subitems;

  MenuModel({
    required this.id,
    required this.nama,
    required this.tipe,
    this.subitems,
  });

  factory MenuModel.fromMap(String id, Map<String, dynamic> map) {
    return MenuModel(
      id: id,
      nama: map['nama'],
      tipe: map['tipe'],
      subitems: map['subitems'] != null ? List<String>.from(map['subitems']) : null,
    );
  }
}