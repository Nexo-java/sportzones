import 'package:flutter/material.dart';

class ResponsiveLayout {
  const ResponsiveLayout._();

  static double scale(BuildContext context, {double min = 0.88, double max = 1.14}) {
    final width = MediaQuery.sizeOf(context).width;
    final scaled = width / 390;
    final safeMin = min.clamp(0.7, 1.0).toDouble();
    final safeMax = max.clamp(safeMin, 1.0).toDouble();
    return scaled.clamp(safeMin, safeMax).toDouble();
  }

  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 520;
    if (width >= 900) return 500;
    if (width >= 600) return 480;
    return width;
  }

  static bool shouldCenterContent(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }
}

class ResponsiveAppFrame extends StatelessWidget {
  const ResponsiveAppFrame({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final currentScale = media.textScaler.scale(14) / 14;
    final normalizedScale = currentScale.clamp(0.95, 1.05).toDouble();

    final framedChild = ResponsiveLayout.shouldCenterContent(context)
        ? Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveLayout.contentMaxWidth(context),
              ),
              child: child,
            ),
          )
        : child;

    return MediaQuery(
      data: media.copyWith(
        textScaler: TextScaler.linear(normalizedScale),
      ),
      child: framedChild,
    );
  }
}