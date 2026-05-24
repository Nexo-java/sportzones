import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../shared/widgets/custom_header.dart';
import '../../../shared/widgets/sports_category_list.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../news/pages/news_detail_page.dart';
import '../../notification/pages/notification_page.dart';
import '../../authentication/models/like_model.dart';
import '../../authentication/models/sport_model.dart';
import '../widgets/hot_news_card.dart';
import '../widgets/latest_news_section.dart';
import '../widgets/popular_news_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.homeResetCounter,
    required this.latestNews,
    required this.notifications,
  });

  final int homeResetCounter;
  final List<SportModel> latestNews;
  final ValueNotifier<List<Map<String, dynamic>>> notifications;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _selectedCategoryIndex;
  bool _isOpeningDetail = false;
  final PageController _hotNewsPageController = PageController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _hotNewsAutoSlideTimer;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _likesSubscription;
  int _hotNewsPageIndex = 0;
  Map<String, int> _likeCounts = const {};

  @override
  void initState() {
    super.initState();
    _likesSubscription = _firestore
        .collection('likes')
        .snapshots()
        .listen(
          (snapshot) {
            if (!mounted) return;

            final likes = snapshot.docs
                .map((doc) {
                  final data = doc.data();
                  data['like_id'] = data['like_id'] ?? doc.id;
                  return LikeModel.fromJson(data);
                })
                .where((like) => like.idBerita.isNotEmpty)
                .toList(growable: false);

            final counts = <String, int>{};
            for (final like in likes) {
              counts[like.idBerita] = (counts[like.idBerita] ?? 0) + 1;
            }

            setState(() {
              _likeCounts = counts;
            });
          },
          onError: (_) {
            if (!mounted) return;
            setState(() {
              _likeCounts = const {};
            });
          },
        );
    _startHotNewsAutoSlide();
  }

  @override
  void dispose() {
    _likesSubscription?.cancel();
    _hotNewsAutoSlideTimer?.cancel();
    _hotNewsPageController.dispose();
    super.dispose();
  }

  int _likesFor(SportModel news) => _likeCounts[news.idBerita] ?? 0;

  List<SportModel> _hotNewsFromRealtime() {
    if (widget.latestNews.isEmpty) return const [];

    final newestFirst = List<SportModel>.from(widget.latestNews)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final recentWindow = newestFirst.take(12).toList(growable: false)
      ..sort((a, b) {
        final likeCompare = _likesFor(b).compareTo(_likesFor(a));
        if (likeCompare != 0) return likeCompare;
        return b.createdAt.compareTo(a.createdAt);
      });

    return recentWindow.take(3).toList(growable: false);
  }

  List<SportModel> _popularNewsFromRealtime() {
    if (widget.latestNews.isEmpty) return const [];

    final ranked = List<SportModel>.from(widget.latestNews)
      ..sort((a, b) {
        final likeCompare = _likesFor(b).compareTo(_likesFor(a));
        if (likeCompare != 0) return likeCompare;
        return b.createdAt.compareTo(a.createdAt);
      });

    return ranked.take(12).toList(growable: false);
  }

  void _startHotNewsAutoSlide() {
    _hotNewsAutoSlideTimer?.cancel();
    _hotNewsAutoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final hotNews = _hotNewsFromRealtime();
      if (!mounted || !_hotNewsPageController.hasClients || hotNews.isEmpty) {
        return;
      }

      final nextPage = (_hotNewsPageIndex + 1) % hotNews.length;
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
    final index = SportsCategoryList.categories.indexWhere(
      (item) => item.name == category.name,
    );
    if (index >= 0) {
      setState(() {
        _selectedCategoryIndex = index;
      });
    }
  }

  void _openNotifications(
    ValueNotifier<List<Map<String, dynamic>>> notifications,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 240),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) =>
            NotificationPage(notifications: notifications),
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

    if (result == true && mounted) {
      setState(() {
        widget.latestNews.removeWhere(
          (item) => item.idBerita == resolvedNewsId,
        );
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

    if (kIsWeb) {
      return;
    }

    ImageProvider? provider;
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      provider = NetworkImage(imageUrl);
    } else {
      provider = AssetImage(imageUrl);
    }

    try {
      await precacheImage(
        provider,
        context,
      ).timeout(const Duration(milliseconds: 120));
    } catch (_) {
      // Ignore image warm-up failures and keep navigation responsive.
    }
  }

  Widget _buildHotNewsCarousel() {
    final hotNews = _hotNewsFromRealtime();
    if (hotNews.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_hotNewsPageIndex >= hotNews.length) {
      _hotNewsPageIndex = 0;
    }

    final scale = ResponsiveLayout.scale(context, min: 0.9, max: 1.08);
    final carouselHeight = (300 * scale).clamp(260.0, 320.0).toDouble();

    return SizedBox(
      height: carouselHeight,
      child: PageView.builder(
        controller: _hotNewsPageController,
        itemCount: hotNews.length,
        onPageChanged: (index) {
          _hotNewsPageIndex = index;
        },
        itemBuilder: (context, index) {
          final item = hotNews[index];

          return HotNewsCard(
            title: item.title,
            imageUrl: item.imageUrl,
            date: item.date,
            source: item.createdBy,
            height: carouselHeight,
            onTap: () {
              _openNewsDetail(
                newsId: item.idBerita,
                title: item.title,
                date: item.date,
                imageUrl: item.imageUrl,
                description: item.description,
                category: item.category,
                createdBy: item.createdBy,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt,
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
                    item.category.trim().toLowerCase() ==
                    selectedCategory!.name.toLowerCase(),
              )
              .toList(growable: false);
    final popularNews = _popularNewsFromRealtime();
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
              child: CustomHeader(
                onNotificationTap: () =>
                    _openNotifications(widget.notifications),
                unreadNotificationCount: widget.notifications.value
                    .where((n) => (n['isRead'] as bool? ?? false) == false)
                    .length,
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedSectionDelegate(
              height: 84,
              child: Container(
                color: const Color(0xFF09092D),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
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
                          newsItems: popularNews,
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

class _PinnedSectionDelegate extends SliverPersistentHeaderDelegate {
  _PinnedSectionDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedSectionDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
