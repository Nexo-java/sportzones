import 'package:flutter/foundation.dart';
import '../features/home/models/news_model.dart';

/// Repository for managing news data
/// Implements CRUD operations for news/berita
class NewsRepository {
  static final NewsRepository _instance = NewsRepository._internal();

  factory NewsRepository() {
    return _instance;
  }

  NewsRepository._internal();

  static NewsRepository get instance => _instance;

  // Mock data storage
  final List<NewsModel> _newsList = [];
  final List<ValueNotifier<List<NewsModel>>> _listeners = [];

  // Initialize with sample data
  void initializeSampleData() {
    if (_newsList.isNotEmpty) return;

    _newsList.addAll([
      NewsModel(
        idBerita: '1',
        judul: 'Lin Chun Yi Lolos ke Final India Open 2026 usai Menang Dramatis',
        deskripsi: 'Lin Chun Yi berhasil melolos ke final India Open 2026 setelah pertandingan dramatis',
        isiKonten:
            'Indonesian Tennis Star Janice Tjen Upsets Leylah Fernandez at Australian Open\n\n'
            'Janice Tjen has once again knocked out a seeded player in her Grand Slam campaign. '
            'After defeating Veronika Kudermetova at the 2025 US Open, Tjen has now stunned Canada\'s Leylah Fernandez.\n\n'
            'Fernandez, a former US Open finalist in 2021, fell to Tjen in straight sets with a score of 6-2, 7-6 (7-1).',
        imgUrl: 'https://via.placeholder.com/150',
        kategori: 'Badminton',
        likesCount: 124,
        createdAt: DateTime(2026, 1, 20),
        createdBy: 'Admin',
      ),
      NewsModel(
        idBerita: '2',
        judul: 'Anthony Ginting Bangkit dan Menang Dua Gim Langsung di Malaysia Open',
        deskripsi: 'Anthony Ginting menunjukkan performa luar biasa di Malaysia Open',
        isiKonten:
            'Anthony Ginting kembali menunjukkan performa gemilang dengan memenangkan dua pertandingan berturut-turut di Malaysia Open. '
            'Dengan permainan agresif dan strategi yang solid, Ginting berhasil mengalahkan lawan-lawannya.\n\n'
            'Ini merupakan pertanda positif untuk persiapan Ginting menjelang turnamen-turnamen besar berikutnya.',
        imgUrl: 'https://via.placeholder.com/150',
        kategori: 'Badminton',
        likesCount: 89,
        createdAt: DateTime(2026, 1, 22),
        createdBy: 'Admin',
      ),
      NewsModel(
        idBerita: '3',
        judul: 'Indonesia U-23 Tahan Imbang Jepang dalam Laga Uji Coba Intens',
        deskripsi: 'Tim Indonesia U-23 menunjukkan pertahanan solid melawan Jepang',
        isiKonten:
            'Dalam laga uji coba internasional, tim Indonesia U-23 berhasil menahan imbang Jepang dengan skor 1-1. '
            'Pertandingan yang intens ini menunjukkan peningkatan signifikan dalam performa defensif tim.\n\n'
            'Kedua gol masing-masing tim dicetak pada babak kedua, menciptakan pertandingan yang sangat menarik.',
        imgUrl: 'https://via.placeholder.com/150',
        kategori: 'Soccer',
        likesCount: 156,
        createdAt: DateTime(2026, 1, 25),
        createdBy: 'Admin',
      ),
    ]);

    _notifyListeners();
  }

  /// tambahData → Add new news (Admin only)
  void tambahData(NewsModel news) {
    _newsList.add(news);
    _notifyListeners();
  }

  /// ubahData → Update existing news (Admin only)
  void ubahData(String newsId, NewsModel updatedNews) {
    final index = _newsList.indexWhere((news) => news.idBerita == newsId);
    if (index != -1) {
      _newsList[index] = updatedNews;
      _notifyListeners();
    }
  }

  /// hapusData → Delete news (Admin only)
  void hapusData(String newsId) {
    _newsList.removeWhere((news) => news.idBerita == newsId);
    _notifyListeners();
  }

  /// lihatData → Get all news
  List<NewsModel> lihatData() => List.unmodifiable(_newsList);

  /// Get single news by ID
  NewsModel? getNewsById(String newsId) {
    try {
      return _newsList.firstWhere((news) => news.idBerita == newsId);
    } catch (e) {
      return null;
    }
  }

  /// Get news by category
  List<NewsModel> getNewsByCategory(String category) {
    return _newsList.where((news) => news.kategori == category).toList();
  }

  /// Add like to news
  void addLike(String newsId) {
    final index = _newsList.indexWhere((news) => news.idBerita == newsId);
    if (index != -1) {
      _newsList[index] = _newsList[index].addLike();
      _notifyListeners();
    }
  }

  /// Remove like from news
  void removeLike(String newsId) {
    final index = _newsList.indexWhere((news) => news.idBerita == newsId);
    if (index != -1) {
      _newsList[index] = _newsList[index].removeLike();
      _notifyListeners();
    }
  }

  /// Get all unique categories
  List<String> getAllCategories() {
    final categories = <String>{};
    for (var news in _newsList) {
      categories.add(news.kategori);
    }
    return categories.toList();
  }

  /// Search news by title
  List<NewsModel> searchByTitle(String query) {
    final lowerQuery = query.toLowerCase();
    return _newsList
        .where((news) => news.judul.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get news count
  int getNewsCount() => _newsList.length;

  /// Add listener for data changes
  void addListener(VoidCallback listener) {
    final notifier = ValueNotifier<List<NewsModel>>(_newsList);
    notifier.addListener(listener);
    _listeners.add(notifier);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener.value = List.from(_newsList);
    }
  }
}
