import 'package:flutter/material.dart';

/// Brand palette: deep night navy with warm gold accents.
///
/// Text pairs were checked against WCAG AA; gold is for accents and
/// non-text marks on light surfaces ([goldDeep] when it carries text).
abstract final class AppColors {
  // Light
  static const navy = Color(0xFF1E2A5A); // primary
  static const indigo = Color(0xFF3A4FA0); // interaction / progress
  static const highlight = Color(0xFFEAEEFB); // highlighted surfaces
  static const background = Color(0xFFF5F7FB);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A2038);
  static const textSecondary = Color(0xFF5F6680);
  static const danger = Color(0xFFB42318);

  // Gold accents.
  static const gold = Color(0xFFD4A84B);
  static const goldDeep = Color(0xFF8C6A1D);
  static const goldSoft = Color(0xFFFBF3E0);

  /// The hero panels at the top of each screen.
  static const heroGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF141C42), Color(0xFF26346F), Color(0xFF34479A)],
    stops: [0, 0.6, 1],
  );

  /// Icon badge accents: mid-tone colours that read on light and dark.
  static const accents = [
    Color(0xFF4F63D2), // indigo
    Color(0xFFC28A1E), // gold
    Color(0xFF0F9BA8), // teal
    Color(0xFFD6567B), // rose
    Color(0xFF8359D6), // violet
    Color(0xFF2E9E6A), // green
    Color(0xFFE07A2F), // orange
  ];

  // Status colours (always paired with an icon or label, never colour alone).
  static const success = Color(0xFF1E7A46);
  static const warning = Color(0xFFB54708);
  static const info = Color(0xFF2E5E8C);
  static const inactive = Color(0xFF8A90A6);

  // Dark
  static const darkBackground = Color(0xFF0B1020);
  static const darkCard = Color(0xFF151B33);
  static const darkCardHigh = Color(0xFF1D2442);
  static const darkTextPrimary = Color(0xFFE8EAF4);
  static const darkTextSecondary = Color(0xFFA2A8C3);
  static const darkPrimary = Color(0xFFAAB8FF);
  static const darkHighlight = Color(0xFF232C55);
  static const darkGold = Color(0xFFE6C274);
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
  static const button = 14.0;
  static const card = 22.0;
  static const sheet = 28.0;
}

/// Motion: one easing curve and a few durations so every transition in
/// the app feels like the same system.
abstract final class Motion {
  static const curve = Curves.easeOutCubic;
  static const fast = Duration(milliseconds: 180);
  static const medium = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 480);
}
