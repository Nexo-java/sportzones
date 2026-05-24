import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data berita untuk menyimpan dan menampilkan informasi news.
/// Kelas ini menjadi jembatan antara data Firestore dan UI Flutter.
class SportModel {
  /// ID unik berita di database.
  final String idBerita; // id_berita
  /// Judul berita yang ditampilkan ke pengguna.
  final String judul; // title
  /// Ringkasan singkat berita.
  final String deskripsi; // short description
  /// Isi lengkap berita untuk halaman detail.
  final String isiKonten; // content for detail page
  /// Link gambar berita.
  final String imgUrl; // image URL
  /// Kategori berita seperti Badminton, Soccer, dan lainnya.
  final String kategori; // category (Badminton, Soccer, etc)
  /// Waktu berita pertama kali dibuat.
  final DateTime createdAt; // created timestamp
  /// Waktu berita terakhir diubah.
  final DateTime? updatedAt; // last updated timestamp
  /// Nama admin atau pembuat berita.
  final String createdBy; // author/creator name
  /// Link tambahan jika berita punya lokasi maps.
  final String? mapsUrl; // optional maps URL

  /// Konstruktor utama untuk membuat objek berita.
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

  /// Membuat salinan objek dengan beberapa field yang diubah.
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

  /// Membuat berita baru dari input admin.
  /// Ini dipakai saat form tambah berita selesai diisi.
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

  /// Mengubah data berita yang sudah ada.
  /// Dipakai saat admin melakukan edit berita.
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

  /// Menandai penghapusan berita.
  /// Di versi ini masih placeholder dan mengembalikan null.
  static SportModel? hapusData(String newsId) {
    // Pada aplikasi nyata, penghapusan dilakukan di database.
    return null;
  }

  /// Mengembalikan objek berita itu sendiri untuk kebutuhan baca data.
  SportModel lihatData() => this;

  /// Bagian ini dipakai saat aplikasi membaca data dari database
  /// dan Mengubah data mentah dari Firestore/JSON menjadi objek SportModel
  factory SportModel.fromJson(Map<String, dynamic> map) {
    // Firestore menyimpan waktu sebagai Timestamp, jadi perlu dikonversi.
    final dynamic rawCreatedAt = map['created_at'];
    DateTime parsedCreatedAt;
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    // Waktu update juga dibaca dan dikonversi jika tersedia.
    final dynamic rawUpdatedAt = map['updated_at'];
    DateTime? parsedUpdatedAt;
    if (rawUpdatedAt is Timestamp) {
      parsedUpdatedAt = rawUpdatedAt.toDate();
    } else if (rawUpdatedAt is String) {
      parsedUpdatedAt = DateTime.tryParse(rawUpdatedAt);
    }

    // Data mentah yang sudah dibersihkan dimasukkan ke model yang rapi.
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

  /// Mengubah objek SportModel kembali menjadi Map untuk disimpan ke Firestore.
  Map<String, dynamic> toMap() {
    // Format ini cocok untuk penyimpanan data ke database cloud.
    return {
      'id_berita': idBerita,
      'judul': judul,
      'deskripsi': deskripsi,
      'isi_konten': isiKonten,
      'img_url': imgUrl,
      'kategori': kategori,
      // DateTime lokal diubah kembali ke Timestamp agar cocok dengan Firestore.
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      'created_by': createdBy,
      'maps_url': mapsUrl,
    };
  }

  /// Menampilkan isi objek untuk debugging atau logging.
  @override
  String toString() {
    return 'SportModel(id: $idBerita, judul: $judul, kategori: $kategori, createdAt: $createdAt)';
  }

  /// Getter tambahan agar kode lama yang memakai nama field lain tetap jalan.
  String get title => judul;

  /// Getter tanggal dalam format sederhana.
  String get date => createdAt.toString().split(' ')[0];

  /// Getter alias untuk deskripsi.
  String get description => deskripsi;

  /// Getter alias untuk gambar.
  String get imageUrl => imgUrl;

  /// Getter alias untuk kategori.
  String get category => kategori;
}
