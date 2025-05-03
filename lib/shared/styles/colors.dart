import 'package:flutter/material.dart';

class AppColors {
  // Main colors
  static const Color background = Color(0xFFF5F5F5); // Used for app background
  static const Color primary = Color(
    0xFF48CFCB,
  ); // Primary action color, buttons, selections
  static const Color primaryDark = Color(
    0xFF229799,
  ); // Darker shade of primary for hover states
  static const Color text = Color(0xFF424242); // Main text color
  static const Color grey = Color(0xFF9E9E9E); // Secondary text, borders, icons
  static const Color white = Colors.white; // Background for cards, containers

  // Gradient colors
  static const List<Color> primaryGradient = [
    primary,
    primaryDark,
  ]; // Used in buttons and headers

  // Status colors
  static const Color success = Color(0xFF4CAF50); // Used for completed tasks
  static const Color error = Color(0xFFE57373); // Used for error states
  static const Color warning = Color(0xFFFFB74D); // Used for warnings

  // Card colors
  static const Color cardShadow = Color(0x1A000000); // Card shadow color
  static const Color cardBorder = Color(0xFFE0E0E0); // Card border color

  // Progress colors
  static const Color progressBackground = Color(
    0xFFE0E0E0,
  ); // Progress bar background

  // Event card colors
  static const Color eventIconBg = Color(0xFFF5C6EC);

  // Shadow colors
  // static Color shadowColor = grey.withOpacity(0.08);
}
