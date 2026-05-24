import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/widgets/custom_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../services/user/user_repository.dart';
import '../../../services/bookmark/bookmark_service.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../notification/pages/notification_page.dart';
import '../../news/pages/news_detail_page.dart';
import '../../../shared/widgets/web_safe_network_image.dart';

class SavePage extends StatefulWidget {
  const SavePage({super.key, this.notifications});

  final ValueNotifier<List<Map<String, dynamic>>>? notifications;

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<_SavedNewsItem> _savedNews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedNews();
  }

  Future<void> _loadSavedNews() async {
    final currentUser = UserRepository.instance.getCurrentUser();
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _savedNews = [];
      });
      return;
    }

    try {
      List<_SavedNewsItem> loadedNews = [];

      // Get saved news IDs from user
      for (final newsId in currentUser.savedNews) {
        try {
          final doc = await _firestore.collection('berita').doc(newsId).get();
          if (doc.exists) {
            final data = doc.data()!;
            loadedNews.add(
              _SavedNewsItem(
                id: newsId,
                title: data['judul'] ?? '',
                category: data['kategori'] ?? '',
                imageUrl: data['img_url'] ?? '',
                date: _formatDate(data['created_at']),
              ),
            );
          }
        } catch (_) {
          // Skip if news document not found or error
        }
      }

      if (mounted) {
        setState(() {
          _savedNews = loadedNews;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _savedNews = [];
        });
      }
    }
  }

  String _formatDate(dynamic createdAt) {
    if (createdAt is Timestamp) {
      final date = createdAt.toDate();
      return '${date.day}/${date.month}/${date.year}';
    } else if (createdAt is String) {
      try {
        final date = DateTime.parse(createdAt);
        return '${date.day}/${date.month}/${date.year}';
      } catch (_) {
        return '';
      }
    }
    return '';
  }

  Future<void> _deleteBookmark(String newsId) async {
    try {
      final currentUser = UserRepository.instance.getCurrentUser();
      if (currentUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Not logged in')));
        return;
      }

      // Use BookmarkService so all bookmark-aware pages refresh instantly
      BookmarkService().removeBookmark(newsId, forUserId: currentUser.idUser);

      // Reload bookmarks from updated UserRepository
      await _loadSavedNews();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final unread =
        widget.notifications?.value
            .where((n) => (n['isRead'] as bool? ?? false) == false)
            .length ??
        0;

    return Container(
      color: const Color(0xFF09092D),
      child: Column(
        children: [
          CustomHeader(
            onNotificationTap: _openNotifications,
            unreadNotificationCount: unread,
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFECF06),
                      ),
                    ),
                  )
                : _savedNews.isEmpty
                ? EmptyState(
                    message: 'No saved news yet',
                    icon: Icons.bookmark_border,
                  )
                : RefreshIndicator(
                    onRefresh: _loadSavedNews,
                    color: const Color(0xFFFECF06),
                    backgroundColor: const Color(0xFF1A1A40),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: _savedNews.length,
                      itemBuilder: (context, index) {
                        final item = _savedNews[index];
                        return _BookmarkCard(
                          item: item,
                          onBookmarkToggle: () => _deleteBookmark(item.id),
                          onOpenDetail: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(
                                  milliseconds: 220,
                                ),
                                reverseTransitionDuration: const Duration(
                                  milliseconds: 180,
                                ),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        NewsDetailPage(
                                          newsId: item.id,
                                          imageUrl: item.imageUrl,
                                          title: item.title,
                                          description: '',
                                          date: item.date,
                                          category: item.category,
                                          notifications: widget.notifications,
                                        ),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      final curve = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      );
                                      return FadeTransition(
                                        opacity: Tween<double>(
                                          begin: 0.0,
                                          end: 1.0,
                                        ).animate(curve),
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
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SavedNewsItem {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String date;

  _SavedNewsItem({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.date,
  });
}

class _BookmarkCard extends StatefulWidget {
  final _SavedNewsItem item;
  final Future<void> Function() onBookmarkToggle;
  final VoidCallback? onOpenDetail;

  const _BookmarkCard({
    required this.item,
    required this.onBookmarkToggle,
    this.onOpenDetail,
  });

  @override
  State<_BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<_BookmarkCard> {
  final bool _isSaved = true; // Always true since it's bookmarked
  bool _isDeleting = false;

  Widget _actionIcon({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required bool isLoading,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: isLoading ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Icon(icon, color: color, size: 24),
      ),
    );
  }

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onBookmarkToggle();
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveLayout.scale(context, min: 0.9, max: 1.08);
    final cardHeight = (118 * scale).clamp(108.0, 124.0).toDouble();
    final imageWidth = (140 * scale).clamp(124.0, 146.0).toDouble();
    final actionWidth = (80 * scale).clamp(70.0, 84.0).toDouble();

    return GestureDetector(
      onTap: widget.onOpenDetail,
      child: Container(
        height: cardHeight,
        margin: EdgeInsets.only(bottom: 12 * scale),
        padding: EdgeInsets.all(10 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A40),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: imageWidth,
                child: WebSafeNetworkImage(
                  imageUrl: widget.item.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 10 * scale),
            // CONTENT (category, title, date)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale,
                      vertical: 3 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      widget.item.category,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  // Title
                  Text(
                    widget.item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),
                  // Date
                  Text(
                    widget.item.date,
                    style: TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8 * scale),
            // ACTIONS (bookmark)
            SizedBox(
              width: actionWidth,
              child: Column(
                children: [
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // BOOKMARK button (always yellow/active)
                      _actionIcon(
                        icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: _isSaved
                            ? const Color(0xFFFECF06)
                            : Colors.white,
                        onTap: _handleDelete,
                        isLoading: _isDeleting,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
