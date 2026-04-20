import 'package:flutter/material.dart';

import '../../news/pages/news_detail_page.dart';
import '../widgets/latest_news_card.dart';
import '../../../shared/widgets/custom_header.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.isAdmin = false,
  });

  final bool isAdmin;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  static const _bgColor = Color(0xFF09092D);
  static const _surfaceColor = Color(0xFF1A1A40);
  static const _accentColor = Color(0xFFFECF06);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isFilterOpen = false;
  String? _selectedCategory;

  final List<Map<String, String>> _dummyNews = const [
    {
      'title': 'Lin chun Yi wins india open 2026 Against Jonathan Cristie',
      'category': 'Badminton',
      'date': '19/20/2023',
      'image': 'https://via.placeholder.com/150',
      'description': 'Hot news detail from home page.',
    },
    {
      'title': 'Tim Judo Indonesia Bawa Pulang 4 Emas, Lampaui Target di SEA Games 2025',
      'category': 'Judo',
      'date': '16/12/2025',
      'image': 'https://via.placeholder.com/150',
      'description': 'Latest news detail from home page.',
    },
    {
      'title': 'Manchester is red! Manchester is back with big momentum',
      'category': 'Soccer',
      'date': '12/01/01',
      'image': 'https://via.placeholder.com/150',
      'description': 'Popular news detail from home page.',
    },
    {
      'title': 'Indonesia has already for Indonesia in this major event',
      'category': 'Badminton',
      'date': '12/01/02',
      'image': 'https://via.placeholder.com/150',
      'description': 'Popular news detail from home page.',
    },
    {
      'title': 'Brazil keeps pushing after dramatic late comeback win',
      'category': 'Soccer',
      'date': '12/01/03',
      'image': 'https://via.placeholder.com/150',
      'description': 'Popular news detail from home page.',
    },
    {
      'title': 'The derby turns chaotic after a stunning extra-time goal',
      'category': 'Soccer',
      'date': '12/01/04',
      'image': 'https://via.placeholder.com/150',
      'description': 'Popular news detail from home page.',
    },
    {
      'title': 'Final set thriller ends with unbelievable rally sequence',
      'category': 'Tennis',
      'date': '12/01/05',
      'image': 'https://via.placeholder.com/150',
      'description': 'Popular news detail from home page.',
    },
    {
      'title': 'New strategy changes the game for underdog contenders',
      'category': 'Basketball',
      'date': '12/01/06',
      'image': 'https://via.placeholder.com/150',
      'description': 'Popular news detail from home page.',
    },
    {
      'title': 'Captain returns and instantly changes team chemistry',
      'category': 'Volly',
      'date': '12/01/07',
      'image': 'https://via.placeholder.com/150',
      'description': 'Popular news detail from home page.',
    },
  ];

  final List<_SearchCategory> _categories = const [
    _SearchCategory(name: 'Badminton', icon: Icons.sports_tennis),
    _SearchCategory(name: 'Soccer', icon: Icons.sports_soccer),
    _SearchCategory(name: 'Basketball', icon: Icons.sports_basketball),
    _SearchCategory(name: 'Volly', icon: Icons.sports_volleyball),
    _SearchCategory(name: 'Tennis', icon: Icons.sports_tennis),
  ];

  List<String> _searchHistory = ['Badminton', 'Soccer', 'Basketball'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _toggleFilter() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
    });
  }

  void _onCategoryTap(String categoryName) {
    setState(() {
      if (_selectedCategory == categoryName) {
        _selectedCategory = null;
      } else {
        _selectedCategory = categoryName;
      }
    });
  }

  void _submitSearch(String value) {
    final keyword = value.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _searchHistory.removeWhere((item) => item.toLowerCase() == keyword.toLowerCase());
      _searchHistory.insert(0, keyword);
      if (_searchHistory.length > 8) {
        _searchHistory = _searchHistory.take(8).toList();
      }
    });
  }

  void _onHistoryTap(String keyword) {
    _searchController.text = keyword;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );
    _submitSearch(keyword);
    _searchFocusNode.unfocus();
  }

  List<Map<String, String>> get _filteredNews {
    final query = _searchController.text.trim().toLowerCase();
    return _dummyNews.where((item) {
      final title = (item['title'] ?? '').toLowerCase();
      final category = item['category'] ?? '';

      final matchTitle = query.isEmpty || title.contains(query);
      final matchCategory = _selectedCategory == null || _selectedCategory == category;

      return matchTitle && matchCategory;
    }).toList();
  }

  void _openNewsDetail(Map<String, String> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsDetailPage(
          imageUrl: item['image'] ?? '',
          title: item['title'] ?? '',
          description: item['description'] ?? '',
          date: item['date'] ?? '',
          category: item['category'] ?? '',
          initialBottomTabIndex: 1,
          isAdmin: widget.isAdmin,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _searchController.text.trim().isNotEmpty;
    final filteredNews = _filteredNews;
    final showResultsSection = hasQuery || _selectedCategory != null;

    return Container(
      color: _bgColor,
      child: Column(
        children: [
          const CustomHeader(),
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
                          onPressed: () => Navigator.maybePop(context),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(
                                isCollapsed: true,
                                hintText: 'Search...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9696B8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Color(0xFF9696B8),
                                  size: 22,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
                                  return InkWell(
                                    onTap: () => _onCategoryTap(category.name),
                                    borderRadius: BorderRadius.circular(999),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            category.name,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
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
                    child: showResultsSection
                        ? Column(
                            children: [
                              if (filteredNews.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Tidak ada hasil pencarian',
                                      style: TextStyle(
                                        color: Color(0xFFAAAAAA),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...filteredNews.map((item) {
                                  return LatestNewsCard(
                                    title: item['title'] ?? '',
                                    category: item['category'] ?? '',
                                    date: item['date'] ?? '',
                                    imageUrl: item['image'] ?? '',
                                    onTap: () => _openNewsDetail(item),
                                  );
                                }),
                              const SizedBox(height: 24),
                            ],
                          )
                        : Column(
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
                                const Text(
                                  'Belum ada riwayat pencarian',
                                  style: TextStyle(
                                    color: Color(0xFFAAAAAA),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
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
