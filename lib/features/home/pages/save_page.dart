import 'package:flutter/material.dart';

import '../../../shared/widgets/custom_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../services/bookmark_service.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../notification/pages/notification_page.dart';

class SavePage extends StatefulWidget {
  const SavePage({super.key});

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  final BookmarkService _bookmarkService = BookmarkService();

  void _deleteBookmark(String id) {
    setState(() {
      _bookmarkService.removeBookmark(id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from bookmarks'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey.shade800,
      ),
    );
  }

  void _toggleBookmark(String id) {
    setState(() {
      _bookmarkService.removeBookmark(id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from bookmarks'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey.shade800,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final bookmarks = _bookmarkService.bookmarks;

    return Container(
      color: const Color(0xFF09092D),
      child: Column(
        children: [
          CustomHeader(onNotificationTap: _openNotifications),
          Expanded(
            child: bookmarks.isEmpty
                ? EmptyState(
                    message: 'No saved news yet',
                    icon: Icons.bookmark_border,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: bookmarks.length,
                    itemBuilder: (context, index) {
                      final item = bookmarks[index];
                      return _BookmarkCard(
                        item: item,
                        onDelete: () => _deleteBookmark(item.id),
                        onBookmarkToggle: () => _toggleBookmark(item.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BookmarkCard extends StatefulWidget {
  final NewsItem item;
  final VoidCallback onDelete;
  final VoidCallback onBookmarkToggle;

  const _BookmarkCard({
    required this.item,
    required this.onDelete,
    required this.onBookmarkToggle,
  });

  @override
  State<_BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<_BookmarkCard> {
  final bool _isSaved = true; // Always true since it's bookmarked

  Widget _actionIcon({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveLayout.scale(context, min: 0.9, max: 1.08);
    final cardHeight = (118 * scale).clamp(108.0, 124.0).toDouble();
    final imageWidth = (140 * scale).clamp(124.0, 146.0).toDouble();
    final actionWidth = (80 * scale).clamp(70.0, 84.0).toDouble();

    return Material(
      color: Colors.transparent,
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
                child: Image.network(
                  widget.item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF4A4A6A),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image,
                        color: Colors.white38,
                        size: 30,
                      ),
                    );
                  },
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
                    padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 3 * scale),
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
            // ACTIONS (delete + bookmark)
            SizedBox(
              width: actionWidth,
              child: Column(
                children: [
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // DELETE button
                      _actionIcon(
                        icon: Icons.delete_outline,
                        color: const Color(0xFFFF5F5F),
                        onTap: widget.onDelete,
                      ),
                      SizedBox(width: 10 * scale),
                      // BOOKMARK button (always yellow/active)
                      _actionIcon(
                        icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: _isSaved ? const Color(0xFFFECF06) : Colors.white,
                        onTap: widget.onBookmarkToggle,
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
