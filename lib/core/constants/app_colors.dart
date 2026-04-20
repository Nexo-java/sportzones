import 'package:flutter/material.dart';

/// App-wide color palette constants
class AppColors {
  // Primary Colors
  static const Color primaryDark = Color(0xFF09092D);
  static const Color primaryBlue = Color(0xFF162B4D);
  static const Color primaryYellow = Color(0xFFFBC02D);
  
  // Text Colors
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color textDark = Color(0xFF212121);
  
  // Background Colors
  static const Color backgroundDark = Color(0xFF09092D);
  static const Color backgroundWhite = Colors.white;
  
  // Border Colors
  static const Color borderGrey = Color(0xFFE0E0E0);
  
  // Gradient Colors
  static final List<Color> logoGradient = [
    primaryYellow,
    Colors.blue.shade400,
  ];
}
