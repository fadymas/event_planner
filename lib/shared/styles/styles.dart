import 'package:flutter/material.dart';
import 'colors.dart';

class AppStyles {
  // Border radius
  static const double borderRadius = 12.0; // Used for main containers and cards
  static const double smallBorderRadius =
      8.0; // Used for buttons and small containers

  // Padding
  static const double defaultPadding = 16.0; // Standard padding for containers
  static const double smallPadding = 8.0; // Small padding for elements
  static const double tinyPadding = 4.0; // Minimal padding for tight spaces

  // Icon sizes
  static const double iconSize = 24.0; // Standard icon size
  static const double smallIconSize =
      20.0; // Small icon size for secondary elements
  static const double largeIconSize = 28.0; // Large icon size for emphasis

  // Text styles
  static const TextStyle titleStyle = TextStyle(
    color: AppColors.text,
    fontWeight: FontWeight.bold,
    fontSize: 14.0,
  );

  static const TextStyle subtitleStyle = TextStyle(
    color: AppColors.grey,
    fontSize: 12.0,
  );

  static const TextStyle menuLabelStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  // Input decoration styles
  static InputDecoration inputDecoration({
    required String label,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: menuLabelStyle.copyWith(fontSize: 14, color: AppColors.grey),
      prefixIcon:
          prefixIcon != null ? Icon(prefixIcon, color: AppColors.grey) : null,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
        borderSide: BorderSide(color: AppColors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
        borderSide: BorderSide(color: AppColors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    );
  }

  // Card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: AppColors.cardBorder),
    boxShadow: [
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );
}
