/// News model for news/berita management
/// Implements the Berita class from the class diagram
class NewsModel {
  final String idBerita; // id_berita
  final String judul; // title
  final String deskripsi; // short description
  final String isiKonten; // content for detail page
  final String imgUrl; // image URL
  final String kategori; // category (Badminton, Soccer, etc)
  final int likesCount; // number of likes
  final DateTime createdAt; // created timestamp
  final DateTime? updatedAt; // last updated timestamp
  final String createdBy; // author/creator name
  final String? mapsUrl; // optional maps URL

  NewsModel({
    required this.idBerita,
    required this.judul,
    required this.deskripsi,
    required this.isiKonten,
    required this.imgUrl,
    required this.kategori,
    this.likesCount = 0,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.mapsUrl,
  });

  /// Create a copy with modified fields
  NewsModel copyWith({
    String? idBerita,
    String? judul,
    String? deskripsi,
    String? isiKonten,
    String? imgUrl,
    String? kategori,
    int? likesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? mapsUrl,
  }) {
    return NewsModel(
      idBerita: idBerita ?? this.idBerita,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      isiKonten: isiKonten ?? this.isiKonten,
      imgUrl: imgUrl ?? this.imgUrl,
      kategori: kategori ?? this.kategori,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      mapsUrl: mapsUrl ?? this.mapsUrl,
    );
  }

  /// tambahData → Add new news (Admin only)
  factory NewsModel.tambahData({
    required String idBerita,
    required String judul,
    required String deskripsi,
    required String isiKonten,
    required String imgUrl,
    required String kategori,
    required String createdBy,
    String? mapsUrl,
  }) {
    return NewsModel(
      idBerita: idBerita,
      judul: judul,
      deskripsi: deskripsi,
      isiKonten: isiKonten,
      imgUrl: imgUrl,
      kategori: kategori,
      likesCount: 0,
      createdAt: DateTime.now(),
      updatedAt: null,
      createdBy: createdBy,
      mapsUrl: mapsUrl,
    );
  }

  /// ubahData → Update existing news (Admin only)
  NewsModel ubahData({
    String? judul,
    String? deskripsi,
    String? isiKonten,
    String? imgUrl,
    String? kategori,
    String? mapsUrl,
  }) {
    return NewsModel(
      idBerita: idBerita,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      isiKonten: isiKonten ?? this.isiKonten,
      imgUrl: imgUrl ?? this.imgUrl,
      kategori: kategori ?? this.kategori,
      likesCount: likesCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      createdBy: createdBy,
      mapsUrl: mapsUrl ?? this.mapsUrl,
    );
  }

  /// hapusData → Delete news (Admin only)
  /// Returns null to indicate deletion
  static NewsModel? hapusData(String newsId) {
    // In real app, this would handle deletion in database
    return null;
  }

  /// lihatData → Get/view news data (returns self)
  NewsModel lihatData() => this;

  /// Add like to news
  NewsModel addLike() {
    return copyWith(likesCount: likesCount + 1);
  }

  /// Remove like from news
  NewsModel removeLike() {
    return copyWith(likesCount: (likesCount - 1).clamp(0, double.infinity).toInt());
  }

  /// Factory from JSON (for future backend integration)
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      idBerita: json['id_berita'] ?? json['id'] ?? '',
      judul: json['judul'] ?? json['title'] ?? '',
      deskripsi: json['deskripsi'] ?? json['description'] ?? '',
      isiKonten: json['isi_konten'] ?? json['content'] ?? '',
      imgUrl: json['img_url'] ?? json['imageUrl'] ?? '',
      kategori: json['kategori'] ?? json['category'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      createdBy: json['created_by'] ?? json['createdBy'] ?? 'Admin',
      mapsUrl: json['maps_url'],
    );
  }

  /// Convert to JSON (for future backend integration)
  Map<String, dynamic> toJson() {
    return {
      'id_berita': idBerita,
      'judul': judul,
      'deskripsi': deskripsi,
      'isi_konten': isiKonten,
      'img_url': imgUrl,
      'kategori': kategori,
      'likes_count': likesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
      'maps_url': mapsUrl,
    };
  }

  @override
  String toString() {
    return 'NewsModel(id: $idBerita, judul: $judul, kategori: $kategori, createdAt: $createdAt)';
  }

  /// For backward compatibility with existing code using 'title', 'date', etc
  String get title => judul;
  String get date => createdAt.toString().split(' ')[0];
  String get description => deskripsi;
  String get imageUrl => imgUrl;
  String get category => kategori;
}
