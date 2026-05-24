import 'package:flutter/foundation.dart';

import '../user/user_repository.dart';
import '../auth/firebase_auth_service.dart';

class NewsItem {
  final String id;
  final String title;
  final String category;
  final String date;
  final String imageUrl;

  NewsItem({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// BookmarkService now stores bookmarks per-user to avoid cross-account sharing.
class BookmarkService extends ChangeNotifier {
  static final BookmarkService _instance = BookmarkService._internal();

  factory BookmarkService() {
    return _instance;
  }

  BookmarkService._internal();

  // Map userId -> bookmarks list
  final Map<String, List<NewsItem>> _userBookmarks = {};

  String _currentUserId() {
    final user = UserRepository.instance.getCurrentUser();
    return user?.idUser ?? '_guest';
  }

  /// Get bookmarks for current user (or empty list)
  List<NewsItem> get bookmarks {
    final uid = _currentUserId();
    if (!_userBookmarks.containsKey(uid)) {
      return const <NewsItem>[];
    }

    final currentBookmarks = _userBookmarks[uid];
    if (currentBookmarks == null || currentBookmarks.isEmpty) {
      return const <NewsItem>[];
    }

    return List<NewsItem>.unmodifiable(List<NewsItem>.from(currentBookmarks));
  }

  void addBookmark(NewsItem item, {String? forUserId}) {
    final uid = forUserId ?? _currentUserId();
    final list = _userBookmarks.putIfAbsent(uid, () => []);
    if (!list.any((b) => b.id == item.id)) {
      list.add(item);
      // Update local user repository immediately
      try {
        UserRepository.instance.addSavedNews(uid, item.id);
      } catch (_) {}
      // Also persist to Firestore if possible (fire-and-forget)
      try {
        FirebaseAuthService.instance.addSavedNews(userId: uid, newsId: item.id);
      } catch (_) {}
      notifyListeners();
    }
  }

  void removeBookmark(String id, {String? forUserId}) {
    final uid = forUserId ?? _currentUserId();
    final list = _userBookmarks[uid];
    list?.removeWhere((b) => b.id == id);
    // Update local repository and Firestore
    try {
      UserRepository.instance.removeSavedNews(uid, id);
    } catch (_) {}
    try {
      FirebaseAuthService.instance.removeSavedNews(userId: uid, newsId: id);
    } catch (_) {}
    notifyListeners();
  }

  bool isBookmarked(String id, {String? forUserId}) {
    final uid = forUserId ?? _currentUserId();
    if (UserRepository.instance.isNewsSaved(uid, id)) {
      return true;
    }
    final list = _userBookmarks[uid];
    if (list == null) return false;
    return list.any((b) => b.id == id);
  }

  void clear({String? forUserId}) {
    final uid = forUserId ?? _currentUserId();
    _userBookmarks[uid]?.clear();
    notifyListeners();
  }
}
