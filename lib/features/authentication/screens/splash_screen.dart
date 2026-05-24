import 'package:flutter/material.dart';
import 'logo_animation_screen.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.01, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.forward();

    // Navigate to logo animation screen after splash
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LogoAnimationScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Calculate diagonal to ensure circle covers entire screen including corners
    final diagonal = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            // White background
            Container(color: Colors.white),
            // Animated circle that expands
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                final radius = 1 + (diagonal - 1) * _scaleAnimation.value;
                return ClipPath(
                  clipper: CircleClipper(
                    radius: radius,
                    center: Offset(size.width / 2, size.height / 2),
                  ),
                  child: Container(color: const Color(0xFF09092D)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CircleClipper extends CustomClipper<Path> {
  final double radius;
  final Offset center;

  CircleClipper({required this.radius, required this.center});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(CircleClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}
