import 'package:flutter/material.dart';

/// Sanad palette: sky ink with a saffron accent (v4 identity, "Daylight").
/// The panel at the top of each screen takes the current sky (daylight.dart);
/// these are the steady colours around it.
///
/// Text pairs were checked against WCAG AA; gold is for accents and
/// non-text marks on light surfaces ([goldDeep] when it carries text).
abstract final class AppColors {
  // Light
  static const navy = Color(0xFF242C6E); // primary: sky ink
  static const indigo = Color(0xFF3B47B0); // interaction / progress
  static const highlight = Color(0xFFECEEFA); // highlighted surfaces
  static const background = Color(0xFFF4F5F9);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF171A33);
  static const textSecondary = Color(0xFF5A5F7E);
  static const danger = Color(0xFFB42318);

  // Saffron accents (named gold for continuity).
  static const gold = Color(0xFFE09A2F);
  static const goldDeep = Color(0xFF8A5710);
  static const goldSoft = Color(0xFFFCF0DC);

  /// The hero panels at the top of each screen.
  static const heroGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF0D1230), Color(0xFF1F2766)],
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
  static const darkBackground = Color(0xFF0B0E1F);
  static const darkCard = Color(0xFF151932);
  static const darkCardHigh = Color(0xFF1D2240);
  static const darkTextPrimary = Color(0xFFE8EAF4);
  static const darkTextSecondary = Color(0xFFA2A8C3);
  static const darkPrimary = Color(0xFFB3BBFF);
  static const darkHighlight = Color(0xFF242A55);
  static const darkGold = Color(0xFFF0B861);
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
