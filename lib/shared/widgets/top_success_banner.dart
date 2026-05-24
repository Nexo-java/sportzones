import 'package:flutter/material.dart';

/// Reusable success notification banner with smooth slide animation
///
/// Slides down from above the header with a green background, white border,
/// and a check icon. Designed to provide visual feedback for successful actions.
class TopSuccessBanner extends StatelessWidget {
  const TopSuccessBanner({
    super.key,
    required this.animation,
    this.text = 'Login Berhasil',
    this.backgroundColor = const Color(0xFF6FA437),
    this.maxWidth,
    this.height = 82,
    this.fontSize = 22,
    this.iconSize = 24,
    this.horizontalMargin = 14,
  });

  final Animation<Offset> animation;
  final String text;
  final Color backgroundColor;
  final double? maxWidth;
  final double height;
  final double fontSize;
  final double iconSize;
  final double horizontalMargin;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
          child: Container(
            width: double.infinity,
            height: height,
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: iconSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
