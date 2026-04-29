/// User model for authentication and profile management
/// Implements the User class from the class diagram
class UserModel {
  final String idUser;
  final String username;
  final String role; // "admin" or "user"
  final String password;
  final String email;
  final List<String> savedNews; // List of saved news IDs
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

  /// tambahData → Register/create new user
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

  /// ubahData → Update user profile information
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

  /// Add a news ID to saved news list
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

  /// Remove a news ID from saved news list
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

  /// Check if news is saved
  bool isNewsSaved(String newsId) => savedNews.contains(newsId);

  /// Helper getter agar UI tetap mudah akses URL string
  String get imageUrl => (imgUrl?['url'] ?? '').toString();

  /// Factory from JSON (for future backend integration)
  factory UserModel.fromJson(Map<String, dynamic> map) {
    final dynamic imgRaw = map['img_url'];
    Map<String, dynamic>? parsedImgUrl;
    if (imgRaw is Map<String, dynamic>) {
      parsedImgUrl = Map<String, dynamic>.from(imgRaw);
    } else if (imgRaw is String) {
      parsedImgUrl = {
        'url': imgRaw,
        'source': 'legacy',
      };
    }

    return UserModel(
      idUser: map['id_user'] ?? map['id'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? 'user',
      password: map['password'] ?? '',
      email: map['email'] ?? '',
      savedNews: List<String>.from(map['saved_news'] ?? []),
      imgUrl: parsedImgUrl,
    );
  }

  /// Convert to JSON (for future backend integration)
  Map<String, dynamic> toJson() {
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
