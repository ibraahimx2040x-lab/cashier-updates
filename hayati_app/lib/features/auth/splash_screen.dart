import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/auth.dart';
import '../../l10n/app_localizations.dart';

/// Screen 1 — brand while the session is restored. Never stays stuck: on
/// failure it shows an error with retry.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // Providers can't be modified while the tree is building.
    WidgetsBinding.instance.addPostFrameCallback((_) => _restore());
  }

  Future<void> _restore() async {
    setState(() => _failed = false);
    try {
      await Future.wait([
        ref.read(authProvider.notifier).restore(),
        Future<void>.delayed(const Duration(milliseconds: 700)),
      ]).timeout(const Duration(seconds: 10));
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.deepGreen,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const HayatiLogo(size: 88),
          const SizedBox(height: Space.l),
          Text('حياتي', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontFamily: 'Tajawal')),
          Text('Hayati', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70, fontFamily: 'Inter')),
          const SizedBox(height: Space.xxl),
          if (_failed) ...[
            Text(l.splashFailed, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: Space.m),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
              onPressed: _restore,
              child: Text(l.retry),
            ),
          ] else
            const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
        ]),
      ),
    );
  }
}

/// Compass-like mark: a ring with a connected path — simple on purpose.
class HayatiLogo extends StatelessWidget {
  const HayatiLogo({super.key, this.size = 64, this.color = Colors.white});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Hayati',
        child: CustomPaint(size: Size.square(size), painter: _LogoPainter(color)),
      );
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final r = s.width / 2;
    final ring = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.07;
    canvas.drawCircle(c, r * 0.86, ring);
    // A winding S-shaped path between two dots (same as tool/make_brand.py).
    final path = Path()
      ..moveTo(c.dx - r * 0.40, c.dy + r * 0.36)
      ..quadraticBezierTo(c.dx + r * 0.05, c.dy + r * 0.50, c.dx, c.dy)
      ..quadraticBezierTo(c.dx - r * 0.05, c.dy - r * 0.50, c.dx + r * 0.40, c.dy - r * 0.36);
    canvas.drawPath(path, ring..strokeCap = StrokeCap.round);
    final dot = Paint()..color = color;
    canvas.drawCircle(Offset(c.dx - r * 0.40, c.dy + r * 0.36), r * 0.11, dot);
    canvas.drawCircle(Offset(c.dx + r * 0.40, c.dy - r * 0.36), r * 0.11, dot);
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.color != color;
}
