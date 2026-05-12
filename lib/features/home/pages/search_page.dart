import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../news/pages/news_detail_page.dart';
import '../../notification/pages/notification_page.dart';
import '../../authentication/models/news_model.dart';
import '../widgets/latest_news_card.dart';
import '../../../shared/widgets/custom_header.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

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


  final List<_SearchCategory> _categories = const [
    _SearchCategory(name: 'Badminton', icon: Icons.sports_tennis),
    _SearchCategory(name: 'Soccer', icon: Icons.sports_soccer),
    _SearchCategory(name: 'Basketball', icon: Icons.sports_basketball),
    _SearchCategory(name: 'Volly', icon: Icons.sports_volleyball),
    _SearchCategory(name: 'Tennis', icon: Icons.sports_tennis),
  ];

  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _loadNewsFromFirestore();
  }

  void _loadNewsFromFirestore() {
    _newsSubscription = _firestore.collection('berita').snapshots().listen(
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
    await prefs.setStringList(_historyStorageKey, _searchHistory.take(_maxHistory).toList());
  }

  void _toggleFilter() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
    });
  }

  Future<void> _onCategoryTap(String categoryName) async {
    final nextCategory = _selectedCategory == categoryName ? null : categoryName;

    setState(() {
      _selectedCategory = nextCategory;
    });

    if (_isShowingResults && _submittedQuery.isNotEmpty) {
      await _executeSearch(_submittedQuery, saveToHistory: false);
    }
  }

  Future<void> _submitSearch(String value) async {
    final keyword = value.trim();
    if (keyword.isEmpty) {
      return;
    }

    await _executeSearch(keyword, saveToHistory: true);
  }

  Future<void> _executeSearch(String keyword, {required bool saveToHistory}) async {
    final normalized = keyword.trim();
    if (normalized.isEmpty) return;

    if (saveToHistory) {
      _searchHistory.removeWhere((item) => item.toLowerCase() == normalized.toLowerCase());
      _searchHistory.insert(0, normalized);
      if (_searchHistory.length > _maxHistory) {
        _searchHistory = _searchHistory.take(_maxHistory).toList();
      }
      await _saveSearchHistory();
    }

    final normalizedQuery = normalized.toLowerCase();
    final selectedCategory = _selectedCategory;

    final results = _allNews.where((item) {
      final title = item.judul.toLowerCase();
      final description = item.deskripsi.toLowerCase();
      final category = item.kategori;

      final matchesKeyword = title.contains(normalizedQuery) || description.contains(normalizedQuery);
      final matchesCategory = selectedCategory == null || selectedCategory == category;
      return matchesKeyword && matchesCategory;
    }).toList(growable: false);

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
        pageBuilder: (context, animation, secondaryAnimation) => const NotificationPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(curve),
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(curve),
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
    return Container(
      color: _bgColor,
      child: Column(
        children: [
          CustomHeader(onNotificationTap: _openNotifications),
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
                          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: _surfaceColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _isFilterOpen ? _accentColor : Colors.transparent,
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
                                  onPressed: () => _submitSearch(_searchController.text),
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
                            child: Icon(
                              Icons.tune,
                              size: 30,
                              color: _isFilterOpen ? _accentColor : Colors.white,
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
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(22, 4, 22, 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _categories.map((category) {
                                  final isSelected = _selectedCategory == category.name;
                                  return InkWell(
                                    onTap: () => _onCategoryTap(category.name),
                                    borderRadius: BorderRadius.circular(999),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFD9D9D9) : Colors.white,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            category.name,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            category.icon,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
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
                          child: SlideTransition(position: offsetAnimation, child: child),
                        );
                      },
                      child: _isShowingResults
                          ? Column(
                              key: ValueKey('search-results-$_submittedQuery-$_selectedCategory'),
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
                                          padding: const EdgeInsets.symmetric(vertical: 8),
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
                                                  overflow: TextOverflow.ellipsis,
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
