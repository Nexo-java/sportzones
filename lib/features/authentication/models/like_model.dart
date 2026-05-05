import 'package:cloud_firestore/cloud_firestore.dart';

/// Like entity for relation between User and Berita
class LikeModel {
  final String likeId;
  final String idUser;
  final String idBerita;
  final DateTime createdAt;

  LikeModel({
    required this.likeId,
    required this.idUser,
    required this.idBerita,
    required this.createdAt,
  });

  /// tambahData → Create new like relation
  factory LikeModel.tambahData({
    required String likeId,
    required String idUser,
    required String idBerita,
    DateTime? createdAt,
  }) {
    return LikeModel(
      likeId: likeId,
      idUser: idUser,
      idBerita: idBerita,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// ubahData → Copy-like update (kept for diagram consistency)
  LikeModel ubahData({
    String? likeId,
    String? idUser,
    String? idBerita,
    DateTime? createdAt,
  }) {
    return LikeModel(
      likeId: likeId ?? this.likeId,
      idUser: idUser ?? this.idUser,
      idBerita: idBerita ?? this.idBerita,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory LikeModel.fromJson(Map<String, dynamic> map) {
    final dynamic rawCreatedAt = map['created_at'];
    DateTime parsedCreatedAt;
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else if (rawCreatedAt is DateTime) {
      parsedCreatedAt = rawCreatedAt;
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return LikeModel(
      likeId: map['like_id'] ?? map['id'] ?? '',
      idUser: map['id_user'] ?? '',
      idBerita: map['id_berita'] ?? '',
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'like_id': likeId,
      'id_user': idUser,
      'id_berita': idBerita,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
