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

class BookmarkService {
  static final BookmarkService _instance = BookmarkService._internal();

  factory BookmarkService() {
    return _instance;
  }

  BookmarkService._internal();

  final List<NewsItem> _bookmarks = [];

  List<NewsItem> get bookmarks => List.unmodifiable(_bookmarks);

  void addBookmark(NewsItem item) {
    if (!_bookmarks.any((b) => b.id == item.id)) {
      _bookmarks.add(item);
    }
  }

  void removeBookmark(String id) {
    _bookmarks.removeWhere((b) => b.id == id);
  }

  bool isBookmarked(String id) {
    return _bookmarks.any((b) => b.id == id);
  }

  void clear() {
    _bookmarks.clear();
  }
}
