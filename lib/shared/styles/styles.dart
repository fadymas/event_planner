import 'package:flutter/material.dart';
import 'colors.dart';

class AppStyles {
  // Border radius
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;

  // Padding
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;

  // Icon sizes
  static const double iconSize = 24.0;
  static const double smallIconSize = 20.0;
  static const double largeIconSize = 28.0;

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
}
