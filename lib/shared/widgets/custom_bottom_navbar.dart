import 'dart:math' as math;

import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _iconColor = Color(0xFF09092D);
  static const _activeCircleColor = Color(0xFFD9D9D9);
  static const _notchColor = Color(0xFF09092D);
  static const _barHeight = 80.0;
  static const _barRadius = 10.0;
  static const _activeCircleSize = 45.0;
  static const _notchWidth = 88.0;
  static const _notchHeight = 66.0;

  static const _tabs = <IconData>[
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.bookmark_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _barHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / _tabs.length;
          final rawNotchLeft =
              (itemWidth * currentIndex) + ((itemWidth - _notchWidth) / 2);
          final rawCircleLeft =
              (itemWidth * currentIndex) + ((itemWidth - _activeCircleSize) / 2);

          final maxNotchLeft = math.max(0.0, constraints.maxWidth - _notchWidth);
          final maxCircleLeft =
              math.max(0.0, constraints.maxWidth - _activeCircleSize);

          final notchLeft = rawNotchLeft.clamp(0.0, maxNotchLeft).toDouble();
          final circleLeft = rawCircleLeft.clamp(0.0, maxCircleLeft).toDouble();

          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(_barRadius),
                    topRight: Radius.circular(_barRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_barRadius),
                  topRight: Radius.circular(_barRadius),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      left: notchLeft,
                      top: 0,
                      width: _notchWidth,
                      height: _notchHeight,
                      child: const RepaintBoundary(
                        child: CustomPaint(
                          painter: _ActiveNotchPainter(color: _notchColor),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Row(
                        children: List.generate(_tabs.length, (index) {
                          final isActive = currentIndex == index;
                          return Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => onTap(index),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Center(
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 280),
                                    curve: Curves.easeOutCubic,
                                    scale: isActive ? 1.0 : 0.96,
                                    child: Icon(
                                      _tabs[index],
                                      size: 31,
                                      color: isActive
                                          ? Colors.transparent
                                          : _iconColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      left: circleLeft,
                      top: 4,
                      width: _activeCircleSize,
                      height: _activeCircleSize,
                      child: IgnorePointer(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            key: ValueKey<int>(currentIndex),
                            decoration: const BoxDecoration(
                              color: _activeCircleColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _tabs[currentIndex],
                              size: 31,
                              color: _iconColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActiveNotchPainter extends CustomPainter {
  const _ActiveNotchPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(
        size.width * 0.06,
        0,
        size.width * 0.16,
        size.height * 0.50,
      )
      ..cubicTo(
        size.width * 0.30,
        size.height * 1.16,
        size.width * 0.70,
        size.height * 1.16,
        size.width * 0.84,
        size.height * 0.50,
      )
      ..quadraticBezierTo(
        size.width * 0.94,
        0,
        size.width,
        0,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ActiveNotchPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
