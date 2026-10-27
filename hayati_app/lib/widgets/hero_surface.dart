import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// The navy panel at the top of a screen: a night-sky gradient, a soft
/// gold glow in the corner and a few small gold stars. Static, so it
/// never keeps the frame clock busy.
class HeroSurface extends StatelessWidget {
  const HeroSurface({super.key, required this.child, this.padding = const EdgeInsets.all(Space.xl), this.height});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(Radii.sheet);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: AppColors.heroGradient,
        boxShadow: [BoxShadow(color: AppColors.navy.withValues(alpha: 0.28), blurRadius: 28, offset: const Offset(0, 12))],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          painter: _NightSky(rtl: rtl),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _NightSky extends CustomPainter {
  const _NightSky({required this.rtl});
  final bool rtl;

  // Star positions as fractions of the panel, kept to the top end so they
  // sit behind the icon area rather than the text.
  static const _stars = [
    (0.08, 0.16, 1.6),
    (0.17, 0.42, 1.0),
    (0.26, 0.10, 1.2),
    (0.12, 0.70, 0.9),
    (0.34, 0.30, 0.8),
    (0.05, 0.50, 1.1),
    (0.42, 0.14, 0.7),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    double x(double f) => rtl ? f * size.width : (1 - f) * size.width;
    // Corner glow.
    final glowCenter = Offset(x(0.0), 0);
    final glowRadius = math.max(size.width, size.height) * 0.6;
    canvas.drawCircle(
      glowCenter,
      glowRadius,
      Paint()
        ..shader = RadialGradient(colors: [
          AppColors.gold.withValues(alpha: 0.22),
          AppColors.gold.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: glowCenter, radius: glowRadius)),
    );
    // A faint arc, like the edge of a crescent.
    canvas.drawCircle(
      Offset(x(-0.05), size.height * 1.1),
      size.height * 0.9,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.06),
    );
    final star = Paint()..color = AppColors.gold.withValues(alpha: 0.85);
    final halo = Paint()..color = AppColors.gold.withValues(alpha: 0.18);
    for (final (fx, fy, r) in _stars) {
      final c = Offset(x(fx), fy * size.height);
      canvas.drawCircle(c, r * 3, halo);
      canvas.drawCircle(c, r, star);
    }
  }

  @override
  bool shouldRepaint(_NightSky old) => old.rtl != rtl;
}
