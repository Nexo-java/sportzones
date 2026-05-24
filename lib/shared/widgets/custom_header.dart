import 'package:flutter/material.dart';
import '../../core/utils/responsive_layout.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({
    super.key,
    this.onNotificationTap,
    this.showNotificationButton = true,
    this.unreadNotificationCount = 0,
  });

  final VoidCallback? onNotificationTap;
  final bool showNotificationButton;
  final int unreadNotificationCount;

  static const _headerColor = Color(0xFF09092D);
  static const _dividerColor = Color(0xFF1A1A40);
  static const _baseLogoHeight = 110.0;
  static const _baseLogoLeft = -19.0;
  static const _baseLogoTop = 6.0;

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveLayout.scale(context, min: 0.9, max: 1.08);
    final logoHeight = _baseLogoHeight * scale;
    final logoLeft = _baseLogoLeft * scale;
    final logoTop = _baseLogoTop * scale;

    return Container(
      color: _headerColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 18 * scale,
                vertical: 10 * scale,
              ),
              child: SizedBox(
                height: 44 * scale,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Transform.translate(
                          offset: Offset(logoLeft, logoTop),
                          child: OverflowBox(
                            maxHeight: logoHeight,
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: logoHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showNotificationButton)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onNotificationTap,
                                customBorder: const CircleBorder(),
                                child: Container(
                                  width: 42 * scale,
                                  height: 42 * scale,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.notifications_rounded,
                                    color: Colors.white,
                                    size: 24 * scale,
                                  ),
                                ),
                              ),
                            ),
                            // Red badge for unread notifications
                            if (unreadNotificationCount > 0)
                              Positioned(
                                top: -4 * scale,
                                right: -4 * scale,
                                child: Container(
                                  width: 10 * scale,
                                  height: 10 * scale,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD94242),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 1,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(color: _dividerColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
