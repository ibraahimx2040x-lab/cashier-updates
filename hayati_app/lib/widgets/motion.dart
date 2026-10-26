import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Fades and lifts its child into place once, when first shown. Items in a
/// list pass their [index] so they arrive one after another. Respects the
/// system "reduce motion" setting.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final delay = (index.clamp(0, 8)) * 50;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.slow + Duration(milliseconds: delay),
      curve: Interval(delay / (Motion.slow.inMilliseconds + delay), 1, curve: Motion.curve),
      child: child,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child),
      ),
    );
  }
}

/// Cross-fades between [child] values (keyed by [childKey]) with a small
/// vertical lift.
class SmoothSwitcher extends StatelessWidget {
  const SmoothSwitcher({super.key, required this.childKey, required this.child});
  final Object childKey;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: Motion.medium,
        switchInCurve: Motion.curve,
        switchOutCurve: Curves.easeIn,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [...previous, ?current],
        ),
        transitionBuilder: (child, a) => FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(a),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(childKey), child: child),
      );
}
