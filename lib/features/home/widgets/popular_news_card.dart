import 'package:flutter/material.dart';
import '../../../core/utils/responsive_layout.dart';

class PopularNewsCard extends StatefulWidget {
  const PopularNewsCard({
    super.key,
    required this.title,
    required this.date,
    required this.imageUrl,
    this.onTap,
  });

  final String title;
  final String date;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  State<PopularNewsCard> createState() => _PopularNewsCardState();
}

class _PopularNewsCardState extends State<PopularNewsCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.imageUrl;
    final scale = ResponsiveLayout.scale(context, min: 0.9, max: 1.08);
    final cardWidth = (168 * scale).clamp(150.0, 178.0).toDouble();
    final imageHeight = (142 * scale).clamp(126.0, 150.0).toDouble();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        scale: _isPressed ? 0.98 : 1.0,
        child: SizedBox(
          width: cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: imageUrl == null || imageUrl.isEmpty
                      ? Container(
                          color: const Color(0xFF4A4A6A),
                          child: const Icon(
                            Icons.image,
                            color: Colors.white30,
                            size: 38,
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF4A4A6A),
                              child: const Icon(
                                Icons.image,
                                color: Colors.white30,
                                size: 38,
                              ),
                            );
                          },
                        ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E4B),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(5)),
                ),
                padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.date,
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
