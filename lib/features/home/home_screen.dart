import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/widgets/top_success_banner.dart';
import '../../services/bookmark_service.dart';
import '../../services/notification_service.dart';
import '../../services/user_service.dart';
import '../../services/news_repository.dart';
import 'models/news_model.dart';
import 'pages/home_page.dart';
import 'pages/add_news_page.dart';
import 'pages/save_page.dart';
import 'pages/search_page.dart';
import '../profile/profile_page.dart';
import '../../shared/widgets/custom_bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialIndex = 0,
    this.animateOnEntry = false,
  });

  final int initialIndex;
  final bool animateOnEntry;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late int _currentIndex;
  int _homeResetCounter = 0;
  late final List<NewsModel> _latestNews;
  late final AnimationController _newsAddedBannerController;
  late final Animation<Offset> _newsAddedBannerAnimation;
  late final AnimationController _entryFadeController;
  Animation<double> _entryFadeAnimation = const AlwaysStoppedAnimation<double>(1.0);
  Animation<Offset> _entrySlideAnimation =
      const AlwaysStoppedAnimation<Offset>(Offset.zero);
  bool _showNewsAddedBanner = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 3);
    
    // Initialize news repository with sample data
    NewsRepository.instance.initializeSampleData();
    _latestNews = NewsRepository.instance.lihatData();

    _newsAddedBannerController = AnimationController(
      duration: const Duration(milliseconds: 820),
      vsync: this,
    );
    _newsAddedBannerAnimation = Tween<Offset>(
      begin: const Offset(0, -2.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _newsAddedBannerController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _entryFadeController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    final entryCurve = CurvedAnimation(
      parent: _entryFadeController,
      curve: Curves.easeInOut,
    );
    _entryFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(entryCurve);
    _entrySlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(entryCurve);

    if (widget.animateOnEntry) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Future<void>.delayed(const Duration(milliseconds: 70), () {
          if (!mounted) return;
          _entryFadeController.forward();
        });
      });
    } else {
      _entryFadeController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _newsAddedBannerController.dispose();
    _entryFadeController.dispose();
    super.dispose();
  }

  Future<void> _showNewsAddedSuccessBanner() async {
    if (!mounted) return;

    _newsAddedBannerController.stop();
    _newsAddedBannerController.value = 0.0;

    setState(() {
      _showNewsAddedBanner = true;
    });

    // Wait for first rendered frame so slide-down starts from true off-screen position.
    final frameReady = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!frameReady.isCompleted) {
        frameReady.complete();
      }
    });
    await frameReady.future;
    if (!mounted) return;

    await _newsAddedBannerController.forward(from: 0.0);
    await Future<void>.delayed(const Duration(milliseconds: 1900));

    if (!mounted) return;

    await _newsAddedBannerController.reverse();

    if (!mounted) return;

    setState(() {
      _showNewsAddedBanner = false;
    });
  }

  Future<void> _openAddNewsForm() async {
    final newNews = await Navigator.push<NewsModel>(
      context,
      _buildAddNewsRoute(),
    );

    if (!mounted || newNews == null) {
      return;
    }

    // Add news to repository
    NewsRepository.instance.tambahData(newNews);
    
    // Update local list
    setState(() {
      _latestNews = NewsRepository.instance.lihatData();
    });

    NotificationService.instance.addFromNews(newNews);

    await _showNewsAddedSuccessBanner();
  }

  PageRoute<NewsModel> _buildAddNewsRoute() {
    return PageRouteBuilder<NewsModel>(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => const AddNewsPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  void _onTabChanged(int index) {
    if (index == 0) {
      setState(() {
        _currentIndex = 0;
        _homeResetCounter++;
      });
      return;
    }

    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkCount = BookmarkService().bookmarks.length;
    final isAdmin = UserService.instance.isAdmin;

    final pages = [
      HomePage(
        key: ValueKey('home-reset-$_homeResetCounter'),
        homeResetCounter: _homeResetCounter,
        latestNews: _latestNews,
      ),
      const SearchPage(key: ValueKey('search-page')),
      const SavePage(key: ValueKey('save-page')),
      ProfilePage(
        key: const ValueKey('profile-page'),
        bookmarkCount: bookmarkCount,
        onOpenBookmarks: () => _onTabChanged(2),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF09092D),
      body: SlideTransition(
        position: _entrySlideAnimation,
        child: FadeTransition(
          opacity: _entryFadeAnimation,
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: pages[_currentIndex],
              ),
              if (_showNewsAddedBanner)
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 44,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: TopSuccessBanner(
                      animation: _newsAddedBannerAnimation,
                      text: 'Berhasil ditambah',
                      maxWidth: 260,
                      height: 60,
                      fontSize: 17,
                      iconSize: 19,
                      horizontalMargin: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: isAdmin && _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _openAddNewsForm,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF09092D),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
