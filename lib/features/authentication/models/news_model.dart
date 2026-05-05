import 'package:cloud_firestore/cloud_firestore.dart';

/// News model for news/berita management
/// Implements the Berita class from the class diagram
class SportModel {
  final String idBerita; // id_berita
  final String judul; // title
  final String deskripsi; // short description
  final String isiKonten; // content for detail page
  final String imgUrl; // image URL
  final String kategori; // category (Badminton, Soccer, etc)
  final DateTime createdAt; // created timestamp
  final DateTime? updatedAt; // last updated timestamp
  final String createdBy; // author/creator name
  final String? mapsUrl; // optional maps URL

  SportModel({
    required this.idBerita,
    required this.judul,
    required this.deskripsi,
    required this.isiKonten,
    required this.imgUrl,
    required this.kategori,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.mapsUrl,
  });

  /// Create a copy with modified fields
  SportModel copyWith({
    String? idBerita,
    String? judul,
    String? deskripsi,
    String? isiKonten,
    String? imgUrl,
    String? kategori,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? mapsUrl,
  }) {
    return SportModel(
      idBerita: idBerita ?? this.idBerita,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      isiKonten: isiKonten ?? this.isiKonten,
      imgUrl: imgUrl ?? this.imgUrl,
      kategori: kategori ?? this.kategori,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      mapsUrl: mapsUrl ?? this.mapsUrl,
    );
  }

  /// tambahData → Add new news (Admin only)
  factory SportModel.tambahData({
    required String idBerita,
    required String judul,
    required String deskripsi,
    required String isiKonten,
    required String imgUrl,
    required String kategori,
    required String createdBy,
    String? mapsUrl,
  }) {
    return SportModel(
      idBerita: idBerita,
      judul: judul,
      deskripsi: deskripsi,
      isiKonten: isiKonten,
      imgUrl: imgUrl,
      kategori: kategori,
      createdAt: DateTime.now(),
      updatedAt: null,
      createdBy: createdBy,
      mapsUrl: mapsUrl,
    );
  }

  /// ubahData → Update existing news (Admin only)
  SportModel ubahData({
    String? judul,
    String? deskripsi,
    String? isiKonten,
    String? imgUrl,
    String? kategori,
    String? mapsUrl,
  }) {
    return SportModel(
      idBerita: idBerita,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      isiKonten: isiKonten ?? this.isiKonten,
      imgUrl: imgUrl ?? this.imgUrl,
      kategori: kategori ?? this.kategori,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      createdBy: createdBy,
      mapsUrl: mapsUrl ?? this.mapsUrl,
    );
  }

  /// hapusData → Delete news (Admin only)
  /// Returns null to indicate deletion
  static SportModel? hapusData(String newsId) {
    // In real app, this would handle deletion in database
    return null;
  }

  /// lihatData → Get/view news data (returns self)
  SportModel lihatData() => this;

  /// Factory from JSON (for future backend integration)
  factory SportModel.fromJson(Map<String, dynamic> map
  ) {
    final dynamic rawCreatedAt = map['created_at'];
    DateTime parsedCreatedAt;
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    final dynamic rawUpdatedAt = map['updated_at'];
    DateTime? parsedUpdatedAt;
    if (rawUpdatedAt is Timestamp) {
      parsedUpdatedAt = rawUpdatedAt.toDate();
    } else if (rawUpdatedAt is String) {
      parsedUpdatedAt = DateTime.tryParse(rawUpdatedAt);
    }

    return SportModel(
      idBerita: map['id_berita'] ?? map['id'] ?? '',
      judul: map['judul'] ?? map['title'] ?? '',
      deskripsi: map['deskripsi'] ?? map['description'] ?? '',
      isiKonten: map['isi_konten'] ?? map['content'] ?? '',
      imgUrl: map['img_url'] ?? map['imageUrl'] ?? '',
      kategori: map['kategori'] ?? map['category'] ?? '',
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
      createdBy: map['created_by'] ?? map['createdBy'] ?? 'Admin',
      mapsUrl: map['maps_url'],
    );
  }

  /// Convert to JSON (for future backend integration)
  Map<String, dynamic> toMap() {
    return {
      'id_berita': idBerita,
      'judul': judul,
      'deskripsi': deskripsi,
      'isi_konten': isiKonten,
      'img_url': imgUrl,
      'kategori': kategori,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      'created_by': createdBy,
      'maps_url': mapsUrl,
    };
  }

  @override
  String toString() {
    return 'SportModel(id: $idBerita, judul: $judul, kategori: $kategori, createdAt: $createdAt)';
  }

  /// For backward compatibility with existing code using 'title', 'date', etc
  String get title => judul;
  String get date => createdAt.toString().split(' ')[0];
  String get description => deskripsi;
  String get imageUrl => imgUrl;
  String get category => kategori;
}
