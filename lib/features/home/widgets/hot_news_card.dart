import 'package:flutter/material.dart';
import '../../../core/utils/responsive_layout.dart';

class HotNewsCard extends StatefulWidget {
  const HotNewsCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.date,
    this.source = 'Sportzone',
    this.onTap,
    this.height = 280,
  });

  final String title;
  final String imageUrl;
  final String date;
  final String source;
  final VoidCallback? onTap;
  final double height;

  @override
  State<HotNewsCard> createState() => _HotNewsCardState();
}

class _HotNewsCardState extends State<HotNewsCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveLayout.scale(context, min: 0.9, max: 1.08);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22 * scale),
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22 * scale),
              ),
              child: Stack(
                children: [
                  // Background Image or Placeholder
                  Positioned.fill(
                    child: widget.imageUrl.isEmpty
                        ? Container(
                            color: const Color(0xFF4A4A6A),
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.white30,
                                size: 64,
                              ),
                            ),
                          )
                        : Image.asset(
                            widget.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF4A4A6A),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white30,
                                    size: 48,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.75),
                            Colors.black.withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Content (Bottom Area)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(16 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.7,
                            ),
                            child: Text(
                              widget.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17 * scale,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                          ),

                          SizedBox(height: 14 * scale),

                          // Meta Info Row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.source,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                              Text(
                                widget.date,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
