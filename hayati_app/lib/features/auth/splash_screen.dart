import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/daylight.dart';
import '../../data/models/prayer.dart';
import '../../widgets/brand.dart';
import '../../widgets/hero_surface.dart' show SkyPainter;
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
    final t = Theme.of(context).textTheme;
    // Opens on the sky of the moment: the identity starts here.
    final sky = Skies.of(skyTimeAt(DateTime.now(), const PrayerSettings()), dark: Theme.of(context).brightness == Brightness.dark);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: sky.gradient),
        child: CustomPaint(
          painter: SkyPainter(sky: sky, rtl: rtl),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutExpo,
              builder: (_, v, child) => Opacity(opacity: v, child: Transform.scale(scale: 0.94 + 0.06 * v, child: child)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SanadMark(size: 96),
                const SizedBox(height: Space.l),
                Text(l.appName, style: t.displaySmall?.copyWith(color: Colors.white, fontSize: 40)),
                const SizedBox(height: Space.xs),
                Text(l.splashTagline, style: t.titleMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w400)),
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
          ),
        ),
      ),
    );
  }
}
