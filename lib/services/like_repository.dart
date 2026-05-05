import 'package:flutter/foundation.dart';

import '../features/authentication/models/like_model.dart';

/// Repository for like relations between User and Berita
/// Uses deterministic document ids to prevent duplicate likes
class LikeRepository {
  static final LikeRepository _instance = LikeRepository._internal();

  factory LikeRepository() {
    return _instance;
  }

  LikeRepository._internal();

  static LikeRepository get instance => _instance;

  final Map<String, LikeModel> _likes = <String, LikeModel>{};
  final List<ValueNotifier<List<LikeModel>>> _listeners = [];

  String buildLikeId(String userId, String newsId) => '${userId}_$newsId';

  /// tambahData → Create like relation if not duplicated
  bool tambahData({
    required String idUser,
    required String idBerita,
  }) {
    if (idUser.isEmpty || idBerita.isEmpty) {
      return false;
    }

    final likeId = buildLikeId(idUser, idBerita);
    if (_likes.containsKey(likeId)) {
      return false;
    }

    _likes[likeId] = LikeModel.tambahData(
      likeId: likeId,
      idUser: idUser,
      idBerita: idBerita,
    );
    _notifyListeners();
    return true;
  }

  /// ubahData → Kept for class-diagram completeness
  bool ubahData({
    required String likeId,
    String? idUser,
    String? idBerita,
    DateTime? createdAt,
  }) {
    final existing = _likes[likeId];
    if (existing == null) {
      return false;
    }

    final updated = existing.ubahData(
      likeId: likeId,
      idUser: idUser,
      idBerita: idBerita,
      createdAt: createdAt,
    );
    _likes[likeId] = updated;
    _notifyListeners();
    return true;
  }

  bool hapusData({
    required String idUser,
    required String idBerita,
  }) {
    final likeId = buildLikeId(idUser, idBerita);
    final removed = _likes.remove(likeId) != null;
    if (removed) {
      _notifyListeners();
    }
    return removed;
  }

  LikeModel? lihatDataById(String likeId) => _likes[likeId];

  List<LikeModel> lihatData() => List.unmodifiable(_likes.values.toList());

  List<LikeModel> getLikesByUser(String idUser) {
    return _likes.values.where((like) => like.idUser == idUser).toList();
  }

  List<LikeModel> getLikesByNews(String idBerita) {
    return _likes.values.where((like) => like.idBerita == idBerita).toList();
  }

  Set<String> getLikedNewsIdsByUser(String idUser) {
    return getLikesByUser(idUser).map((like) => like.idBerita).toSet();
  }

  bool isNewsLikedByUser({
    required String idUser,
    required String idBerita,
  }) {
    return _likes.containsKey(buildLikeId(idUser, idBerita));
  }

  int getLikeCountByNews(String idBerita) {
    return getLikesByNews(idBerita).length;
  }

  int getLikeCountByUser(String idUser) {
    return getLikesByUser(idUser).length;
  }

  void addListener(VoidCallback listener) {
    final notifier = ValueNotifier<List<LikeModel>>(lihatData());
    notifier.addListener(listener);
    _listeners.add(notifier);
  }

  void clear() {
    _likes.clear();
    _notifyListeners();
  }

  void _notifyListeners() {
    final snapshot = lihatData();
    for (final listener in _listeners) {
      listener.value = snapshot;
    }
  }
}
