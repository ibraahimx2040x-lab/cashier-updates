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
    highlight: AppColors.highlight,
    textSecondary: AppColors.textSecondary,
  );

  static const dark = StatusColors(
    success: Color(0xFF6CCB92),
    warning: Color(0xFFF5B95C),
    info: Color(0xFF8AB8E6),
    inactive: Color(0xFF7E849E),
    highlight: AppColors.darkHighlight,
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
  /// Readex Pro sets Arabic and Latin in one voice; Reem Kufi, a geometric
  /// Kufi, is the display face for titles and big numbers.
  static String fontFor(Locale locale) => 'Readex';
  static const display = 'ReemKufi';

  static ThemeData light(Locale locale) => _build(
        locale,
        const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.navy,
          onPrimary: Colors.white,
          primaryContainer: AppColors.highlight,
          onPrimaryContainer: AppColors.navy,
          secondary: AppColors.indigo,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.highlight,
          onSecondaryContainer: AppColors.navy,
          error: AppColors.danger,
          onError: Colors.white,
          surface: AppColors.card,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textSecondary,
          surfaceContainerLowest: AppColors.background,
          surfaceContainerLow: AppColors.background,
          surfaceContainer: AppColors.card,
          tertiary: AppColors.gold,
          onTertiary: AppColors.navy,
          tertiaryContainer: AppColors.goldSoft,
          onTertiaryContainer: AppColors.goldDeep,
          surfaceContainerHigh: Color(0xFFEEF1F8),
          surfaceContainerHighest: Color(0xFFE6EAF4),
          outline: Color(0xFFCFD5E6),
          outlineVariant: Color(0xFFE3E7F2),
        ),
        AppColors.background,
        StatusColors.light,
      );

  static ThemeData dark(Locale locale) => _build(
        locale,
        const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.darkPrimary,
          onPrimary: Color(0xFF0E1640),
          primaryContainer: AppColors.darkHighlight,
          onPrimaryContainer: Color(0xFFDDE3FF),
          secondary: Color(0xFF9DADF5),
          onSecondary: Color(0xFF0E1640),
          secondaryContainer: AppColors.darkHighlight,
          onSecondaryContainer: Color(0xFFDDE3FF),
          tertiary: AppColors.darkGold,
          onTertiary: Color(0xFF2A1E05),
          tertiaryContainer: Color(0xFF3A2F14),
          onTertiaryContainer: Color(0xFFF5DFA8),
          error: AppColors.darkDanger,
          onError: Color(0xFF3A0905),
          surface: AppColors.darkCard,
          onSurface: AppColors.darkTextPrimary,
          onSurfaceVariant: AppColors.darkTextSecondary,
          surfaceContainerLowest: AppColors.darkBackground,
          surfaceContainerLow: AppColors.darkBackground,
          surfaceContainer: AppColors.darkCard,
          surfaceContainerHigh: AppColors.darkCardHigh,
          surfaceContainerHighest: Color(0xFF262E52),
          outline: Color(0xFF454D72),
          outlineVariant: Color(0xFF2E3657),
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
      headlineSmall: TextStyle(fontFamily: display, fontSize: 25, fontWeight: FontWeight.w700, height: lh),
      titleLarge: TextStyle(fontFamily: display, fontSize: 21, fontWeight: FontWeight.w600, height: lh),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: lh),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: lh),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: lh),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: lh),
      bodySmall: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w400, height: lh),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.2),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.2),
      displaySmall: TextStyle(fontFamily: display, fontSize: 31, fontWeight: FontWeight.w700, height: 1.2),
    ).apply(
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
      fontFamilyFallback: const ['Readex'],
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
        elevation: dark ? 0 : 3,
        shadowColor: AppColors.navy.withValues(alpha: 0.08),
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
