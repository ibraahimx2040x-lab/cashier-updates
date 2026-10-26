import 'package:flutter/material.dart';

/// Brand palette from the design document (section 7).
///
/// These are starting values; contrast must be re-validated against WCAG
/// before they are frozen.
abstract final class AppColors {
  // Light
  static const deepGreen = Color(0xFF163A36); // primary
  static const midGreen = Color(0xFF246B57); // interaction / progress
  static const lightGreen = Color(0xFFE4EFEA); // highlighted surfaces
  static const background = Color(0xFFF7F8F5);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF202925);
  static const textSecondary = Color(0xFF68756F);
  static const danger = Color(0xFFB42318);

  // Status colours (always paired with an icon or label, never colour alone).
  static const success = Color(0xFF1E7A46);
  static const warning = Color(0xFFB54708);
  static const info = Color(0xFF2E5E8C);
  static const inactive = Color(0xFF8A938F);

  // Dark
  static const darkBackground = Color(0xFF111815);
  static const darkCard = Color(0xFF1B2420);
  static const darkCardHigh = Color(0xFF243029);
  static const darkTextPrimary = Color(0xFFE7ECE9);
  static const darkTextSecondary = Color(0xFFA3B0AA);
  static const darkPrimary = Color(0xFF7FC8AE);
  static const darkLightGreen = Color(0xFF1F3A31);
  static const darkDanger = Color(0xFFF97066);
}

/// Spacing scale built on multiples of 4 (section 10).
abstract final class Space {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const gutter = 16.0;
}

abstract final class Radii {
  static const button = 12.0;
  static const card = 16.0;
  static const sheet = 20.0;
}
