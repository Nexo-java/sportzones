import 'package:flutter/material.dart';
import '../features/authentication/screens/splash_screen.dart';
import '../features/authentication/screens/logo_animation_screen.dart';
import '../features/authentication/screens/login_screen.dart';

/// Route configuration and navigation management
class RouteConfig {
  static const String splash = '/';
  static const String logoAnimation = '/logo-animation';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  /// Generate routes based on route settings
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case logoAnimation:
        return MaterialPageRoute(builder: (_) => const LogoAnimationScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
