import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../news/pages/news_detail_page.dart';
import '../../notification/pages/notification_page.dart';
import '../../authentication/models/sport_model.dart';
import '../widgets/latest_news_card.dart';
import '../../../shared/widgets/custom_header.dart';
import '../../../shared/widgets/sports_category_list.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.notifications});

  final ValueNotifier<List<Map<String, dynamic>>>? notifications;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

/// SearchPage
///
/// Kegunaan:
/// - Menyediakan UI pencarian berita dengan dukungan history, kategori,
///   dan hasil realtime dari koleksi `berita` di Firestore.
/// - Menormalisasi perbandingan kategori dengan case-insensitive dan trim
///   untuk menghindari mismatch pada filter kategori.
///
/// Catatan:
/// - Search history disimpan ke `SharedPreferences` dengan batas maksimum
///   item yang diizinkan (_maxHistory).

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  static const _bgColor = Color(0xFF09092D);
  static const _surfaceColor = Color(0xFF1A1A40);
  static const _accentColor = Color(0xFFFECF06);
  static const _historyStorageKey = 'search_history_keywords';
  static const _maxHistory = 8;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _newsSubscription;

  bool _isFilterOpen = false;
  bool _isShowingResults = false;
  bool _isSearching = false;
  String _submittedQuery = '';
  String? _selectedCategory;
  List<SportModel> _searchResults = const [];
  List<SportModel> _allNews = [];

  final List<_SearchCategory> _categories = [
    _SearchCategory(
      name: 'Badminton',
      icon: SportsCategoryList.categories[0].icon!,
    ),
    _SearchCategory(
      name: 'Soccer',
      icon: SportsCategoryList.categories[1].icon!,
    ),
    _SearchCategory(
      name: 'Basketball',
      icon: SportsCategoryList.categories[2].icon!,
    ),
    _SearchCategory(
      name: 'Volly',
      icon: SportsCategoryList.categories[3].icon!,
    ),
    _SearchCategory(name: 'Tennis', icon: Icons.sports_tennis),
  ];

  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    // Mulai langganan realtime ke koleksi 'berita' agar data tersedia untuk search
    // Data ditampung di _allNews, pencarian dilakukan secara lokal pada list ini.
    _loadNewsFromFirestore();
  }

  void _loadNewsFromFirestore() {
    // Langganan realtime: setiap perubahan di koleksi 'berita' akan diterima
    // sebagai snapshot. Kita konversi setiap dokumen menjadi `SportModel`
    // menggunakan `SportModel.fromJson` sehingga tipe waktu dan field lain
    // sudah sesuai untuk digunakan di UI dan proses pencarian.
    _newsSubscription = _firestore
        .collection('berita')
        .snapshots()
        .listen(
          (snapshot) {
            if (!mounted) return;

            final newsList = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id_berita'] = doc.id;
              return SportModel.fromJson(data);
            }).toList();

            setState(() {
              _allNews = newsList;
            });
          },
          onError: (e) {
            if (kDebugMode) {
              print('Error loading news: $e');
            }
          },
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _newsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_historyStorageKey) ?? <String>[];

    if (!mounted) return;
    setState(() {
      _searchHistory = stored.take(_maxHistory).toList();
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _historyStorageKey,
      _searchHistory.take(_maxHistory).toList(),
    );
  }

  void _toggleFilter() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
    });
  }

  Future<void> _onCategoryTap(String categoryName) async {
    final nextCategory = _selectedCategory == categoryName
        ? null
        : categoryName;

    setState(() {
      _selectedCategory = nextCategory;
    });

    // If a category was selected, show results filtered by that category.
    if (_selectedCategory != null) {
      await _applyCategoryFilter(_selectedCategory!);
      return;
    }

    // If category deselected, reset search view
    if (_isShowingResults && _submittedQuery.isNotEmpty) {
      await _executeSearch(_submittedQuery, saveToHistory: false);
    } else if (_isShowingResults && _submittedQuery.isEmpty) {
      _resetToInitialSearchView();
    }
  }

  Future<void> _applyCategoryFilter(String category) async {
    setState(() {
      _submittedQuery = '';
      _isShowingResults = true;
      _isSearching = true;
    });

    _searchFocusNode.unfocus();

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    final normCategory = category.toLowerCase().trim();
    // Filter category dilakukan secara eksak pada field kategori.
    // Karena data sudah distandardisasi di model, kita gunakan lower-case
    // trim untuk perbandingan yang konsisten.
    final results = _allNews
        .where((item) {
          final itemCat = item.kategori.toLowerCase().trim();
          return itemCat == normCategory;
        })
        .toList(growable: false);

    setState(() {
      _isSearching = false;
      _searchResults = results;
    });
  }

  Future<void> _submitSearch(String value) async {
    final keyword = value.trim();
    if (keyword.isEmpty) {
      return;
    }

    await _executeSearch(keyword, saveToHistory: true);
  }

  Future<void> _executeSearch(
    String keyword, {
    required bool saveToHistory,
  }) async {
    final normalized = keyword.trim();
    if (normalized.isEmpty) return;

    if (saveToHistory) {
      _searchHistory.removeWhere(
        (item) => item.toLowerCase() == normalized.toLowerCase(),
      );
      _searchHistory.insert(0, normalized);
      if (_searchHistory.length > _maxHistory) {
        _searchHistory = _searchHistory.take(_maxHistory).toList();
      }
      await _saveSearchHistory();
    }

    final normalizedQuery = normalized.toLowerCase();
    final selectedCategory = _selectedCategory;

    // Pencarian dijalankan di memori (_allNews) sehingga respons cepat
    // tanpa memerlukan query kompleks ke Firestore. Mekanisme:
    // - normalisasi: semua teks diubah ke lower-case
    // - pencocokan kata kunci: cek apakah judul atau deskripsi mengandung query
    // - filter kategori (opsional): jika kategori dipilih, hanya hasil kategori itu
    final results = _allNews
        .where((item) {
          final title = item.judul.toLowerCase();
          final description = item.deskripsi.toLowerCase();
          final category = item.kategori.toLowerCase().trim();

          final matchesKeyword =
              title.contains(normalizedQuery) ||
              description.contains(normalizedQuery);
          final matchesCategory =
              selectedCategory == null ||
              selectedCategory.toLowerCase().trim() == category;
          return matchesKeyword && matchesCategory;
        })
        .toList(growable: false);

    setState(() {
      _submittedQuery = normalized;
      _isShowingResults = true;
      _isSearching = true;
    });

    _searchFocusNode.unfocus();

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    setState(() {
      _isSearching = false;
      _searchResults = results;
    });
  }

  Future<void> _onHistoryTap(String keyword) async {
    _searchController.text = keyword;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );
    await _executeSearch(keyword, saveToHistory: true);
  }

  void _openNotifications() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 240),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) =>
            NotificationPage(notifications: widget.notifications),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(curve),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _resetToInitialSearchView() {
    setState(() {
      _isShowingResults = false;
      _isSearching = false;
      _submittedQuery = '';
      _searchResults = const [];
      _selectedCategory = null;
      _isFilterOpen = false;
    });
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  void _openNewsDetail(SportModel item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) => NewsDetailPage(
          newsId: item.idBerita,
          imageUrl: item.imgUrl,
          title: item.judul,
          description: item.deskripsi,
          date: _formatDate(item.createdAt),
          category: item.kategori,
          createdBy: item.createdBy,
          updatedAt: item.updatedAt,
          initialBottomTabIndex: 1,
          notifications: widget.notifications,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unread =
        widget.notifications?.value
            .where((n) => (n['isRead'] as bool? ?? false) == false)
            .length ??
        0;

    return Container(
      color: _bgColor,
      child: Column(
        children: [
          CustomHeader(
            onNotificationTap: _openNotifications,
            unreadNotificationCount: unread,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_isShowingResults) {
                              _resetToInitialSearchView();
                              return;
                            }
                            Navigator.maybePop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: _surfaceColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _isFilterOpen
                                    ? _accentColor
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onSubmitted: _submitSearch,
                              textInputAction: TextInputAction.search,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                isCollapsed: true,
                                hintText: 'Search...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9696B8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF9696B8),
                                  size: 22,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      _submitSearch(_searchController.text),
                                  splashRadius: 20,
                                  icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF9696B8),
                                    size: 20,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _toggleFilter,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: _isFilterOpen
                                ? SvgPicture.asset(
                                    'assets/icons/search_filter_active.svg',
                                    width: 30,
                                    height: 30,
                                    colorFilter: const ColorFilter.mode(
                                      _accentColor,
                                      BlendMode.srcIn,
                                    ),
                                  )
                                : SvgPicture.asset(
                                    'assets/icons/search_filter_inactive.svg',
                                    width: 30,
                                    height: 30,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: _isFilterOpen
                        // Bagian filter kategori: menampilkan chips kategori.
                        // Memilih kategori akan memanggil _onCategoryTap yang
                        // mengaplikasikan filter kategori atau membatalkannya.
                        ? Padding(
                            // align chip block with search field horizontal padding
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Builder(
                                builder: (context) {
                                  final double spacing = 8; // Wrap spacing

                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      // Keep 3 columns but shrink chips when needed
                                      const int columns = 3;
                                      final double totalSpacing =
                                          spacing * (columns - 1);
                                      final double baseWidth =
                                          (constraints.maxWidth -
                                              totalSpacing) /
                                          columns;
                                      final double chipWidthScaled =
                                          baseWidth * 0.88;
                                      const double minChipWidth = 145.0;
                                      final double finalChipWidth =
                                          chipWidthScaled < minChipWidth
                                          ? minChipWidth
                                          : chipWidthScaled;

                                      // Try to constrain chips to align under the search field
                                      // Estimate left/right offsets caused by the back button and filter icon
                                      const double leftOffset =
                                          46.0; // outer padding(8) + back button ~30 + gap 8
                                      const double rightOffset =
                                          44.0; // gap 8 + filter icon ~30 + padding
                                      double chipsContainerWidth =
                                          constraints.maxWidth -
                                          leftOffset -
                                          rightOffset;
                                      if (chipsContainerWidth <= 0) {
                                        chipsContainerWidth =
                                            constraints.maxWidth;
                                      }

                                      return Row(
                                        children: [
                                          SizedBox(width: leftOffset),
                                          SizedBox(
                                            width: chipsContainerWidth,
                                            child: Wrap(
                                              alignment: WrapAlignment.start,
                                              spacing: spacing,
                                              runSpacing: spacing,
                                              children: _categories.map((
                                                category,
                                              ) {
                                                final isSelected =
                                                    _selectedCategory ==
                                                    category.name;
                                                return SizedBox(
                                                  width: finalChipWidth,
                                                  child: InkWell(
                                                    onTap: () => _onCategoryTap(
                                                      category.name,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFFFECF06,
                                                              )
                                                            : Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              999,
                                                            ),
                                                        border: Border.all(
                                                          color: isSelected
                                                              ? const Color(
                                                                  0xFFFECF06,
                                                                )
                                                              : const Color(
                                                                  0xFFE6E6E6,
                                                                ),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            category.name,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  isSelected
                                                                  ? FontWeight
                                                                        .w900
                                                                  : FontWeight
                                                                        .w800,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Icon(
                                                            category.icon,
                                                            size: 18,
                                                            color: Colors.black,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Divider(
                      color: _surfaceColor,
                      thickness: 1,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0, 0.02),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          ),
                        );
                      },
                      // Jika sedang menampilkan hasil pencarian, render list hasil
                      // dan indikator loading saat proses pencarian. Jika tidak,
                      // tampilkan riwayat pencarian yang disimpan di SharedPreferences.
                      child: _isShowingResults
                          ? Column(
                              key: ValueKey(
                                'search-results-$_submittedQuery-$_selectedCategory',
                              ),
                              children: [
                                if (_isSearching)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: LinearProgressIndicator(
                                      minHeight: 2,
                                      color: _accentColor,
                                      backgroundColor: _surfaceColor,
                                    ),
                                  )
                                else if (_searchResults.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'No results found',
                                        style: TextStyle(
                                          color: Color(0xFFAAAAAA),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ..._searchResults.map((item) {
                                    return LatestNewsCard(
                                      newsId: item.idBerita,
                                      title: item.judul,
                                      category: item.kategori,
                                      date: _formatDate(item.createdAt),
                                      imageUrl: item.imgUrl,
                                      onTap: () => _openNewsDetail(item),
                                    );
                                  }),
                                const SizedBox(height: 24),
                              ],
                            )
                          : Column(
                              key: const ValueKey('search-history'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Search history',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (_searchHistory.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.history,
                                          size: 22,
                                          color: Color(0xFFAAAAAA),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Belum ada riwayat pencarian',
                                            style: TextStyle(
                                              color: Color(0xFFAAAAAA),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Column(
                                    children: _searchHistory.map((item) {
                                      return InkWell(
                                        onTap: () => _onHistoryTap(item),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.history,
                                                size: 22,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  item,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                const SizedBox(height: 28),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchCategory {
  const _SearchCategory({required this.name, required this.icon});

  final String name;
  final IconData icon;
}
