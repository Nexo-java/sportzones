/// Model data user untuk otentikasi dan profil.
/// Model ini merepresentasikan struktur data user yang disimpan di Firestore.
/// - Register: setelah admin/user mendaftar, `UserModel.tambahData` dipakai
///   untuk membuat objek user baru lalu disimpan di Firestore melalui layanan
///   autentikasi (lihat `FirebaseAuthService.registerWithEmail`).
/// - Login: ketika login berhasil, layanan autentikasi akan menyinkronkan data
///   user dari Firestore dan membuat objek `UserModel` via `fromJson`, lalu
///   memanggil `UserRepository.setCurrentUser` sehingga UI tahu user aktif.
/// - Saved news: daftar `savedNews` adalah list ID berita yang disimpan oleh
///   user. Untuk menambahkan/ menghapus, gunakan `addSavedNews`/`removeSavedNews`
///   pada `UserRepository` atau `BookmarkService` yang akan memperbarui model
///   lalu menyinkronkan ke Firestore.
///
/// Keterangan singkat fungsi: `fromJson` membaca data mentah dari Firestore,
/// `toMap` membungkus objek menjadi Map untuk disimpan kembali ke Firestore.
class UserModel {
  /// ID unik user (dokumen Firestore `users/{id_user}`).
  final String idUser;

  /// Nama tampilan / username.
  final String username;

  /// Role user, mis. `admin` atau `user`.
  final String role; // "admin" or "user"
  /// Password lokal (catatan: simpan password di Auth service, bukan ideal di model).
  final String password;

  /// Email user.
  final String email;

  /// Daftar id berita yang disimpan (bookmark) oleh user.
  final List<String> savedNews; // List of saved news IDs
  /// Informasi gambar profil (bisa Map atau legacy String).
  final Map<String, dynamic>? imgUrl; // Profile image object for Firebase

  UserModel({
    required this.idUser,
    required this.username,
    required this.role,
    required this.password,
    required this.email,
    this.savedNews = const [],
    this.imgUrl,
  });

  /// Create a copy of this model with modified fields
  UserModel copyWith({
    String? idUser,
    String? username,
    String? role,
    String? password,
    String? email,
    List<String>? savedNews,
    Map<String, dynamic>? imgUrl,
  }) {
    return UserModel(
      idUser: idUser ?? this.idUser,
      username: username ?? this.username,
      role: role ?? this.role,
      password: password ?? this.password,
      email: email ?? this.email,
      savedNews: savedNews ?? this.savedNews,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }

  /// Membuat objek user baru dari input pendaftaran.
  /// Biasanya dipanggil oleh flow register; setelah dibuat, objek ini
  /// dibungkus (`toMap`) dan disimpan ke Firestore oleh layanan auth.
  factory UserModel.tambahData({
    required String idUser,
    required String username,
    required String password,
    required String email,
    String role = 'user',
    Map<String, dynamic>? imgUrl,
  }) {
    return UserModel(
      idUser: idUser,
      username: username,
      role: role,
      password: password,
      email: email,
      savedNews: [],
      imgUrl: imgUrl,
    );
  }

  /// Mengembalikan salinan user dengan data profil yang diubah.
  /// Dipakai saat user mengubah profil; hasilnya biasanya disimpan kembali
  /// lewat `FirebaseAuthService.updateUserProfile` atau `UserRepository.ubahData`.
  UserModel ubahData({
    String? username,
    String? email,
    Map<String, dynamic>? imgUrl,
  }) {
    return UserModel(
      idUser: idUser,
      username: username ?? this.username,
      role: role,
      password: password,
      email: email ?? this.email,
      savedNews: savedNews,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }

  /// Menambahkan ID berita ke daftar `savedNews` dan mengembalikan objek baru.
  /// Perubahan pada savedNews biasanya diikuti oleh update ke Firestore
  /// (lihat `FirebaseAuthService.addSavedNews`) dan update dalam `UserRepository`.
  UserModel addSavedNews(String newsId) {
    if (!savedNews.contains(newsId)) {
      return UserModel(
        idUser: idUser,
        username: username,
        role: role,
        password: password,
        email: email,
        savedNews: [...savedNews, newsId],
        imgUrl: imgUrl,
      );
    }
    return this;
  }

  /// Menghapus ID berita dari `savedNews`.
  UserModel removeSavedNews(String newsId) {
    return UserModel(
      idUser: idUser,
      username: username,
      role: role,
      password: password,
      email: email,
      savedNews: savedNews.where((id) => id != newsId).toList(),
      imgUrl: imgUrl,
    );
  }

  /// Mengecek apakah sebuah berita sudah ada di daftar simpanan user.
  bool isNewsSaved(String newsId) => savedNews.contains(newsId);

  /// Getter untuk mengambil URL gambar profil sebagai String.
  String get imageUrl => (imgUrl?['url'] ?? '').toString();

  /// Mengubah Map/JSON yang diterima dari Firestore menjadi `UserModel`.
  /// Proses ini biasanya dipanggil saat login sukses atau saat sinkronisasi
  /// user dari database ke `UserRepository`.
  factory UserModel.fromJson(Map<String, dynamic> map) {
    final dynamic imgRaw = map['img_url'];
    Map<String, dynamic>? parsedImgUrl;
    if (imgRaw is Map<String, dynamic>) {
      parsedImgUrl = Map<String, dynamic>.from(imgRaw);
    } else if (imgRaw is String) {
      parsedImgUrl = {'url': imgRaw, 'source': 'legacy'};
    }

    return UserModel(
      idUser: map['id_user'] ?? map['id'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? 'user',
      password: map['password'] ?? '',
      email: map['email'] ?? '',
      savedNews: (map['saved_news'] is Iterable)
          ? List<String>.from(
              (map['saved_news'] as Iterable).map((e) => e?.toString() ?? ''),
            )
          : <String>[],
      imgUrl: parsedImgUrl,
    );
  }

  /// Mengubah `UserModel` menjadi Map untuk disimpan ke Firestore.
  /// Pastikan struktur Map sesuai ekspektasi collection `users` di Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'username': username,
      'role': role,
      'password': password,
      'email': email,
      'saved_news': savedNews,
      'img_url': imgUrl ?? {'url': '', 'source': 'model'},
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $idUser, username: $username, role: $role, email: $email)';
  }
}
