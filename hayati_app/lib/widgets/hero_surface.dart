import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/daylight.dart';
import '../data/data_controller.dart';

/// The sky right now for this user: from their prayer times when a place is
/// set, otherwise from the clock.
final skyTimeProvider = Provider<SkyTime>((ref) {
  final now = ref.watch(clockProvider)();
  return skyTimeAt(now, ref.watch(settingsProvider).prayer);
});

/// The panel at the top of a screen. It takes the colour of the sky at the
/// current prayer time (the "Daylight" identity): violet at fajr, blue
/// through the day, amber at asr, red at maghrib, night after isha, with
/// the sun (or the moon) where it is. Static, so it never keeps the frame
/// clock busy.
class HeroSurface extends ConsumerWidget {
  const HeroSurface({super.key, required this.child, this.padding = const EdgeInsets.all(Space.xl), this.height, this.period});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? height;

  /// Fix the sky (previews, tests); null follows the time.
  final SkyTime? period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radius = BorderRadius.circular(Radii.sheet);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final sky = Skies.of(period ?? ref.watch(skyTimeProvider), dark: dark);
    return AnimatedContainer(
      duration: Motion.slow,
      curve: Motion.curve,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: sky.gradient,
        boxShadow: [BoxShadow(color: sky.top.withValues(alpha: dark ? 0.2 : 0.28), blurRadius: 28, offset: const Offset(0, 12))],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          painter: SkyPainter(sky: sky, rtl: rtl),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The sun's glow and disc, or a crescent and a few stars at night.
class SkyPainter extends CustomPainter {
  const SkyPainter({required this.sky, required this.rtl});
  final Sky sky;
  final bool rtl;

  static const _stars = [(0.12, 0.18, 1.3), (0.24, 0.52, 0.9), (0.36, 0.14, 1.0), (0.55, 0.30, 0.8), (0.66, 0.12, 1.1), (0.08, 0.66, 0.8)];

  @override
  void paint(Canvas canvas, Size size) {
    // The day starts on the reading side: right in Arabic, left in English.
    double x(double f) => rtl ? (1 - f) * size.width : f * size.width;
    final c = Offset(x(sky.sunX), sky.sunY * size.height);
    final glowR = math.max(size.width, size.height) * 0.55;
    canvas.drawCircle(
      c,
      glowR,
      Paint()
        ..shader = RadialGradient(colors: [sky.glow.withValues(alpha: 0.36), sky.glow.withValues(alpha: 0)])
            .createShader(Rect.fromCircle(center: c, radius: glowR)),
    );
    final r = math.min(size.height, 160) * 0.12;
    if (sky.night) {
      final star = Paint()..color = sky.body.withValues(alpha: 0.75);
      for (final (fx, fy, sr) in _stars) {
        canvas.drawCircle(Offset(x(fx), fy * size.height), sr, star);
      }
      // Crescent: the moon minus an offset disc of the sky's colour.
      canvas.saveLayer(Rect.fromCircle(center: c, radius: r * 2), Paint());
      canvas.drawCircle(c, r, Paint()..color = sky.body);
      canvas.drawCircle(c + Offset((rtl ? -1 : 1) * r * 0.55, -r * 0.25), r * 0.92, Paint()..blendMode = BlendMode.clear);
      canvas.restore();
    } else {
      canvas.drawCircle(c, r * 1.6, Paint()..color = sky.body.withValues(alpha: 0.18));
      canvas.drawCircle(c, r, Paint()..color = sky.body);
    }
  }

  @override
  bool shouldRepaint(SkyPainter old) => old.sky != sky || old.rtl != rtl;
}
