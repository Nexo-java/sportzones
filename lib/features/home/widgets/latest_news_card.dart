import 'package:flutter/material.dart';
import '../../../services/bookmark_service.dart';
import '../../../core/utils/responsive_layout.dart';

class LatestNewsCard extends StatefulWidget {
  const LatestNewsCard({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.imageUrl,
    this.onTap,
  });

  final String title;
  final String category;
  final String date;
  final String imageUrl;
  final VoidCallback? onTap;

  @override
  State<LatestNewsCard> createState() => _LatestNewsCardState();
}

class _LatestNewsCardState extends State<LatestNewsCard> {
  bool _isLiked = false;
  bool _isSaved = false;
  final BookmarkService _bookmarkService = BookmarkService();

  late String _itemId;

  @override
  void initState() {
    super.initState();
    // Create a unique ID based on title and date
    _itemId = '${widget.title}_${widget.date}'.hashCode.toString();
    _isSaved = _bookmarkService.isBookmarked(_itemId);
  }

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

  void _toggleBookmark() {
    setState(() {
      _isSaved = !_isSaved;
    });

    if (_isSaved) {
      // Add to bookmarks
      final newsItem = NewsItem(
        id: _itemId,
        title: widget.title,
        category: widget.category,
        date: widget.date,
        imageUrl: widget.imageUrl,
      );
      _bookmarkService.addBookmark(newsItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to bookmarks'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.grey.shade800,
        ),
      );
    } else {
      // Remove from bookmarks
      _bookmarkService.removeBookmark(_itemId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from bookmarks'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.grey.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveLayout.scale(context, min: 0.9, max: 1.08);
    final cardHeight = (118 * scale).clamp(108.0, 124.0).toDouble();
    final imageWidth = (140 * scale).clamp(124.0, 146.0).toDouble();
    final actionWidth = (80 * scale).clamp(70.0, 84.0).toDouble();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: imageWidth,
                  child: Image.network(
                    widget.imageUrl,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 3 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        widget.category,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      widget.title,
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
                    Text(
                      widget.date,
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
              SizedBox(
                width: actionWidth,
                child: Column(
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _actionIcon(
                          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? const Color(0xFFFF5F5F) : Colors.white,
                          onTap: () {
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                          },
                        ),
                        SizedBox(width: 10 * scale),
                        _actionIcon(
                          icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: _isSaved ? const Color(0xFFFECF06) : Colors.white,
                          onTap: _toggleBookmark,
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
      ),
    );
  }
}
