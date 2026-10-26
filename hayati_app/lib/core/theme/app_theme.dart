import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic colours that are not part of [ColorScheme].
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.inactive,
    required this.highlight,
    required this.textSecondary,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color inactive;
  final Color highlight;
  final Color textSecondary;

  static const light = StatusColors(
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    inactive: AppColors.inactive,
    highlight: AppColors.lightGreen,
    textSecondary: AppColors.textSecondary,
  );

  static const dark = StatusColors(
    success: Color(0xFF6CCB92),
    warning: Color(0xFFF5B95C),
    info: Color(0xFF8AB8E6),
    inactive: Color(0xFF7D8783),
    highlight: AppColors.darkLightGreen,
    textSecondary: AppColors.darkTextSecondary,
  );

  @override
  StatusColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? inactive,
    Color? highlight,
    Color? textSecondary,
  }) =>
      StatusColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        info: info ?? this.info,
        inactive: inactive ?? this.inactive,
        highlight: highlight ?? this.highlight,
        textSecondary: textSecondary ?? this.textSecondary,
      );

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      inactive: Color.lerp(inactive, other.inactive, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

extension StatusColorsX on BuildContext {
  StatusColors get status => Theme.of(this).extension<StatusColors>()!;
}

abstract final class AppTheme {
  /// Arabic UI uses Tajawal; Latin text and digits fall back to Inter.
  static String fontFor(Locale locale) =>
      locale.languageCode == 'ar' ? 'Tajawal' : 'Inter';

  static ThemeData light(Locale locale) => _build(
        locale,
        const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.deepGreen,
          onPrimary: Colors.white,
          primaryContainer: AppColors.lightGreen,
          onPrimaryContainer: AppColors.deepGreen,
          secondary: AppColors.midGreen,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.lightGreen,
          onSecondaryContainer: AppColors.deepGreen,
          error: AppColors.danger,
          onError: Colors.white,
          surface: AppColors.card,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textSecondary,
          surfaceContainerLowest: AppColors.background,
          surfaceContainerLow: AppColors.background,
          surfaceContainer: AppColors.card,
          surfaceContainerHigh: Color(0xFFF0F2EE),
          surfaceContainerHighest: Color(0xFFE9ECE7),
          outline: Color(0xFFC9D0CC),
          outlineVariant: Color(0xFFE2E6E3),
        ),
        AppColors.background,
        StatusColors.light,
      );

  static ThemeData dark(Locale locale) => _build(
        locale,
        const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.darkPrimary,
          onPrimary: Color(0xFF0B2620),
          primaryContainer: AppColors.darkLightGreen,
          onPrimaryContainer: Color(0xFFCDEBDF),
          secondary: Color(0xFF8FD3BA),
          onSecondary: Color(0xFF0B2620),
          secondaryContainer: AppColors.darkLightGreen,
          onSecondaryContainer: Color(0xFFCDEBDF),
          error: AppColors.darkDanger,
          onError: Color(0xFF3A0905),
          surface: AppColors.darkCard,
          onSurface: AppColors.darkTextPrimary,
          onSurfaceVariant: AppColors.darkTextSecondary,
          surfaceContainerLowest: AppColors.darkBackground,
          surfaceContainerLow: AppColors.darkBackground,
          surfaceContainer: AppColors.darkCard,
          surfaceContainerHigh: AppColors.darkCardHigh,
          surfaceContainerHighest: Color(0xFF2C3933),
          outline: Color(0xFF4A5751),
          outlineVariant: Color(0xFF34413B),
        ),
        AppColors.darkBackground,
        StatusColors.dark,
      );

  static ThemeData _build(
    Locale locale,
    ColorScheme scheme,
    Color scaffold,
    StatusColors status,
  ) {
    final font = fontFor(locale);
    // Arabic needs a slightly taller line height (section 9).
    final lh = locale.languageCode == 'ar' ? 1.5 : 1.35;
    final text = TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: lh),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: lh),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: lh),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: lh),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: lh),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: lh),
      bodySmall: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w400, height: lh),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.2),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.2),
      displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.2),
    ).apply(
      fontFamily: font,
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.button),
    );
    const minButton = Size(64, 50);

    final dark = scheme.brightness == Brightness.dark;
    // Same smooth fade-and-rise page transition on every platform.
    const transitions = PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
    });

    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: transitions,
      splashFactory: InkRipple.splashFactory,
      colorScheme: scheme,
      fontFamily: font,
      fontFamilyFallback: const ['Tajawal', 'Inter'],
      textTheme: text,
      scaffoldBackgroundColor: scaffold,
      extensions: [status],
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      // Light: soft tinted shadow instead of a border. Dark: shadows don't
      // read, so a hairline border separates cards.
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: dark ? 0 : 2,
        shadowColor: AppColors.deepGreen.withValues(alpha: 0.10),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: dark ? BorderSide(color: scheme.outlineVariant) : BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: minButton,
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minButton,
          shape: buttonShape,
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 44),
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.button),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.button),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.button),
          borderSide: BorderSide(color: scheme.secondary, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outlineVariant),
        selectedColor: status.highlight,
        labelStyle: text.labelMedium,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sheet)),
        backgroundColor: scheme.surface,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: status.highlight,
        indicatorShape: const StadiumBorder(),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => text.labelSmall?.copyWith(
              fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            )),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primary,
          selectedForegroundColor: scheme.onPrimary,
          side: BorderSide(color: scheme.outlineVariant),
          shape: const StadiumBorder(),
          textStyle: text.labelLarge,
          animationDuration: Motion.medium,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.card)),
        elevation: 3,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: status.highlight,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 10,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.secondary,
        linearTrackColor: status.highlight,
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
