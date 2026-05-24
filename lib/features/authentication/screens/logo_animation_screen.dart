import 'package:flutter/material.dart';
import 'login_screen.dart';

class LogoAnimationScreen extends StatefulWidget {
  const LogoAnimationScreen({super.key});

  @override
  State<LogoAnimationScreen> createState() => _LogoAnimationScreenState();
}

class _LogoAnimationScreenState extends State<LogoAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _controller.forward();
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09092D),
      body: Center(
        child: FadeTransition(opacity: _fadeAnimation, child: _buildLogo()),
      ),
    );
  }

  Widget _buildLogo() {
    final media = MediaQuery.of(context);
    final shortestSide = media.size.shortestSide;

    // Use breakpoint sizing so web narrow preview and physical phones feel closer.
    double logoWidth;
    if (shortestSide < 340) {
      logoWidth = 220;
    } else if (shortestSide < 390) {
      logoWidth = 250;
    } else if (shortestSide < 430) {
      logoWidth = 280;
    } else {
      logoWidth = 310;
    }

    logoWidth = logoWidth.clamp(200.0, media.size.width * 0.86);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: logoWidth,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
