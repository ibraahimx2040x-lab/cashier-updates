import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Sanad's mark: the letter S drawn as the sun's path, with a saffron sun
/// where the day begins (same geometry as tool/make_brand.py).
class SanadMark extends StatelessWidget {
  const SanadMark({super.key, this.size = 64, this.color = Colors.white, this.sun = AppColors.gold});
  final double size;
  final Color color;
  final Color sun;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Sanad',
        child: CustomPaint(size: Size.square(size), painter: _MarkPainter(color, sun)),
      );
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.color, this.sun);
  final Color color;
  final Color sun;

  @override
  void paint(Canvas canvas, Size s) {
    final h = s.height * 0.82;
    final r = h / 4;
    final w = h * 0.17;
    final cx = s.width / 2, cy = s.height / 2;
    Offset upper(double deg) => Offset(cx + r * math.cos(deg * math.pi / 180), cy - r - r * math.sin(deg * math.pi / 180));
    Offset lower(double deg) => Offset(cx + r * math.cos(deg * math.pi / 180), cy + r - r * math.sin(deg * math.pi / 180));
    final path = Path()..moveTo(upper(48).dx, upper(48).dy);
    for (var a = 48.0; a <= 270; a += 3) {
      path.lineTo(upper(a).dx, upper(a).dy);
    }
    for (var a = 90.0; a >= -160; a -= 3) {
      path.lineTo(lower(a).dx, lower(a).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(upper(8), w * 0.78, Paint()..color = sun);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.color != color || old.sun != sun;
}

/// The mark on its sky tile, as on the app icon.
class SanadTile extends StatelessWidget {
  const SanadTile({super.key, this.size = 56});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.28),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1F2766), Color(0xFF2F6DAE)]),
          boxShadow: [BoxShadow(color: const Color(0xFF1F2766).withValues(alpha: 0.28), blurRadius: size * 0.4, offset: Offset(0, size * 0.14))],
        ),
        alignment: Alignment.center,
        child: SanadMark(size: size * 0.7),
      );
}
