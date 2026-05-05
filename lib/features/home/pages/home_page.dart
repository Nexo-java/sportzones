import 'dart:async';

import 'package:flutter/material.dart';

import '../../../shared/widgets/custom_header.dart';
import '../../../shared/widgets/sports_category_list.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../news/pages/news_detail_page.dart';
import '../../notification/pages/notification_page.dart';
import '../../authentication/models/news_model.dart';
import '../widgets/hot_news_card.dart';
import '../widgets/latest_news_section.dart';
import '../widgets/popular_news_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.homeResetCounter,
    required this.latestNews,
  });

  final int homeResetCounter;
  final List<SportModel> latestNews;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _selectedCategoryIndex;
  bool _isOpeningDetail = false;
  final PageController _hotNewsPageController = PageController();
  Timer? _hotNewsAutoSlideTimer;
  int _hotNewsPageIndex = 0;

  static const List<Map<String, String>> _hotNewsItems = [
    {
      'title': 'Lin chun Yi wins india open 2026 Against Jonathan Cristie',
      'date': '19/20/2023',
      'image': '',
      'source': 'Sportzone',
      'description': _hotNewsDescription,
    },
    {
      'title': 'Anthony Ginting Returns in Style with Straight-Set Win at Malaysia Open',
      'date': '22/01/2026',
      'image': '',
      'source': 'Sportzone',
      'description': _hotNewsDescription2,
    },
    {
      'title': 'Indonesia U-23 Holds Japan in Thrilling Match Ahead of Asian Cup Qualifiers',
      'date': '25/01/2026',
      'image': '',
      'source': 'Sportzone',
      'description': _hotNewsDescription3,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startHotNewsAutoSlide();
  }

  @override
  void dispose() {
    _hotNewsAutoSlideTimer?.cancel();
    _hotNewsPageController.dispose();
    super.dispose();
  }

  void _startHotNewsAutoSlide() {
    _hotNewsAutoSlideTimer?.cancel();
    _hotNewsAutoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_hotNewsPageController.hasClients || _hotNewsItems.isEmpty) {
        return;
      }

      final nextPage = (_hotNewsPageIndex + 1) % _hotNewsItems.length;
      _hotNewsPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.homeResetCounter != widget.homeResetCounter) {
      setState(() {
        _selectedCategoryIndex = null;
      });
    }
  }

  void _onCategorySelected(SportsCategory category) {
    final index = SportsCategoryList.categories.indexWhere((item) => item.name == category.name);
    if (index >= 0) {
      setState(() {
        _selectedCategoryIndex = index;
      });
    }
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

  Future<void> _openNewsDetail({
    String? newsId,
    required String title,
    required String date,
    required String imageUrl,
    required String description,
    required String category,
    String createdBy = 'Admin',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) async {
    if (_isOpeningDetail) return;
    _isOpeningDetail = true;

    await _warmUpImage(imageUrl);

    if (!mounted) {
      _isOpeningDetail = false;
      return;
    }

    final resolvedNewsId = newsId ?? '$title|$date'.hashCode.toString();

    final result = await Navigator.push<dynamic>(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) => NewsDetailPage(
          newsId: resolvedNewsId,
          imageUrl: imageUrl,
          title: title,
          description: description,
          date: date,
          category: category,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          initialBottomTabIndex: 0,
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

    if (result == true && mounted) {
      setState(() {
        widget.latestNews.removeWhere((item) => item.idBerita == resolvedNewsId);
      });
    } else if (result is Map &&
        result['action'] == 'updated' &&
        result['news'] is SportModel &&
        mounted) {
      final updatedNews = result['news'] as SportModel;
      setState(() {
        final index = widget.latestNews.indexWhere(
          (item) => item.idBerita == resolvedNewsId,
        );
        if (index >= 0) {
          widget.latestNews[index] = updatedNews;
        }
      });
    }

    _isOpeningDetail = false;
  }

  Future<void> _warmUpImage(String imageUrl) async {
    if (imageUrl.isEmpty || !mounted) return;

    ImageProvider? provider;
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      provider = NetworkImage(imageUrl);
    } else {
      provider = AssetImage(imageUrl);
    }

    try {
      await precacheImage(provider, context).timeout(
        const Duration(milliseconds: 120),
      );
    } catch (_) {
      // Ignore image warm-up failures and keep navigation responsive.
    }
  }

  Widget _buildHotNewsCarousel() {
    final scale = ResponsiveLayout.scale(context, min: 0.9, max: 1.08);
    final carouselHeight = (300 * scale).clamp(260.0, 320.0).toDouble();

    return SizedBox(
      height: carouselHeight,
      child: PageView.builder(
        controller: _hotNewsPageController,
        itemCount: _hotNewsItems.length,
        onPageChanged: (index) {
          _hotNewsPageIndex = index;
        },
        itemBuilder: (context, index) {
          final item = _hotNewsItems[index];
          final title = item['title'] ?? '';
          final date = item['date'] ?? '';
          final image = item['image'] ?? '';
          final source = item['source'] ?? 'Sportzone';
          final description = item['description'] ?? _hotNewsDescription;

          return HotNewsCard(
            title: title,
            imageUrl: image,
            date: date,
            source: source,
            height: carouselHeight,
            onTap: () {
              _openNewsDetail(
                title: title,
                date: date,
                imageUrl: image,
                description: description,
                category: 'Hot News',
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SportsCategory? selectedCategory;
    final selectedIndex = _selectedCategoryIndex;
    if (selectedIndex != null &&
        selectedIndex >= 0 &&
        selectedIndex < SportsCategoryList.categories.length) {
      selectedCategory = SportsCategoryList.categories[selectedIndex];
    }
    final filteredNews = selectedCategory == null
        ? widget.latestNews
        : widget.latestNews
              .where(
                (item) =>
                    item.category.trim().toLowerCase() == selectedCategory!.name.toLowerCase(),
              )
              .toList(growable: false);
    final topPadding = MediaQuery.paddingOf(context).top;
    final headerHeight = topPadding + 65;

    return Container(
      color: const Color(0xFF09092D),
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedSectionDelegate(
              height: headerHeight,
              child: CustomHeader(onNotificationTap: _openNotifications),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedSectionDelegate(
              height: 84,
              child: Container(
                color: const Color(0xFF09092D),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: SportsCategoryList(
                  initialSelectedIndex: _selectedCategoryIndex,
                  onCategorySelected: _onCategorySelected,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: selectedCategory == null
                  ? Column(
                      key: const ValueKey('home-all-news'),
                      children: [
                        const SizedBox(height: 16),
                        _buildHotNewsCarousel(),
                        const SizedBox(height: 24),
                        PopularNewsSection(
                          onNewsTap: ({required title, required date, imageUrl}) {
                            _openNewsDetail(
                              title: title,
                              date: date,
                              imageUrl: imageUrl ?? '',
                              description: _popularNewsDescription,
                              category: 'Popular',
                            );
                          },
                        ),
                        const SizedBox(height: 1),
                        LatestNewsSection(
                          newsItems: filteredNews,
                          onNewsTap: (newsItem) {
                            _openNewsDetail(
                              newsId: newsItem.idBerita,
                              title: newsItem.title,
                              date: newsItem.date,
                              imageUrl: newsItem.imageUrl,
                              description: newsItem.description,
                              category: newsItem.category,
                              createdBy: newsItem.createdBy,
                              createdAt: newsItem.createdAt,
                              updatedAt: newsItem.updatedAt,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : Column(
                      key: ValueKey('home-category-${selectedCategory.name}'),
                      children: [
                        const SizedBox(height: 16),
                        LatestNewsSection(
                          newsItems: filteredNews,
                          showHeader: false,
                          onNewsTap: (newsItem) {
                            _openNewsDetail(
                              newsId: newsItem.idBerita,
                              title: newsItem.title,
                              date: newsItem.date,
                              imageUrl: newsItem.imageUrl,
                              description: newsItem.description,
                              category: newsItem.category,
                              createdBy: newsItem.createdBy,
                              createdAt: newsItem.createdAt,
                              updatedAt: newsItem.updatedAt,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

const _hotNewsDescription =
  'Lin Chun Yi delivered a standout performance at the India Open 2026, defeating '
  'Jonathan Christie in a high-pressure clash.\n\n'
  'From the opening rally, Lin controlled the pace with sharp net play and quick '
  'transitions, forcing errors from his opponent.\n\n'
  'The result confirms Lin\'s rising form this season and strengthens his position '
  'ahead of the next Super Series tournament.';

const _hotNewsDescription2 =
  'Anthony Ginting marked his comeback with confidence at the Malaysia Open 2026, '
  'closing the match in two straight sets against a tough top-20 opponent.\n\n'
  'He controlled tempo from the baseline and punished short returns, showing strong '
  'rhythm after months of recovery.\n\n'
  'The win boosts Indonesia\'s campaign and signals that Ginting is ready for the '
  'next major tournaments this season.';

const _hotNewsDescription3 =
  'Indonesia U-23 delivered a composed performance to hold Japan in a dramatic '
  'friendly match before Asian Cup qualifiers.\n\n'
  'The team defended compactly and launched quick counters, creating several big '
  'chances in the second half.\n\n'
  'Coaches praised the squad\'s discipline and chemistry, calling it a strong '
  'foundation for the qualification phase.';

const _popularNewsDescription =
  'This popular story captures one of the most discussed moments in today\'s sports '
  'headline cycle.\n\n'
  'With strong reactions from fans and analysts, the matchup has quickly become a '
  'trending topic across multiple platforms.\n\n'
  'More updates are expected as teams release official statements and post-match '
  'analysis.';

class _PinnedSectionDelegate extends SliverPersistentHeaderDelegate {
  _PinnedSectionDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedSectionDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
