import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/fitness/exercise_info.dart';
import '../../domain/fitness/exercises.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/hero_surface.dart';
import 'exercise_screen.dart' show muscleIcon;

/// The movement as a short loop: start and end photos crossfading, with a
/// pause button. With reduced motion it starts paused. Exercises without a
/// matching photo say so instead of showing a wrong one.
class ExercisePhotos extends StatefulWidget {
  const ExercisePhotos({super.key, required this.exercise});
  final Exercise exercise;

  @override
  State<ExercisePhotos> createState() => _ExercisePhotosState();
}

class _ExercisePhotosState extends State<ExercisePhotos> {
  static const _hold = Duration(milliseconds: 1400);
  Timer? _timer;
  int _frame = 0;
  bool? _playing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playing ??= !MediaQuery.disableAnimationsOf(context);
    _sync();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _sync() {
    _timer?.cancel();
    _timer = _playing == true ? Timer.periodic(_hold, (_) => setState(() => _frame = 1 - _frame)) : null;
  }

  void _toggle() => setState(() {
        _playing = !_playing!;
        _sync();
      });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final photos = exercisePhotos(widget.exercise);
    if (photos.isEmpty) {
      return HeroSurface(
        child: Column(children: [
          Icon(muscleIcon(widget.exercise.muscle), size: 56, color: AppColors.gold),
          const SizedBox(height: Space.m),
          Text(l.noPhotoYet, textAlign: TextAlign.center, style: t.bodyMedium?.copyWith(color: Colors.white)),
        ]),
      );
    }
    final name = widget.exercise.name(l.localeName);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(Radii.card),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(fit: StackFit.expand, children: [
            Semantics(
              image: true,
              label: '$name · ${_frame == 0 ? l.photoStart : l.photoEnd}',
              child: GestureDetector(
                onTap: () => setState(() => _frame = 1 - _frame),
                child: AnimatedSwitcher(
                  duration: Motion.slow,
                  child: Image.asset(photos[_frame], key: ValueKey(_frame), fit: BoxFit.cover, gaplessPlayback: true),
                ),
              ),
            ),
            PositionedDirectional(
              start: Space.s,
              bottom: Space.s,
              child: _Chip(label: _frame == 0 ? l.photoStart : l.photoEnd),
            ),
            PositionedDirectional(
              end: Space.xs,
              bottom: Space.xs,
              child: IconButton.filledTonal(
                tooltip: _playing! ? l.photosPause : l.photosPlay,
                onPressed: _toggle,
                icon: Icon(_playing! ? Icons.pause : Icons.play_arrow),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: Space.xs),
      Text(l.photoCredit, style: t.labelSmall?.copyWith(color: context.status.textSecondary)),
    ]);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(999)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.m, vertical: Space.xs),
          child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white)),
        ),
      );
}

/// A small square of the exercise: its end photo, or its muscle icon.
class ExerciseThumb extends StatelessWidget {
  const ExerciseThumb({super.key, required this.exercise, this.size = 56});
  final Exercise exercise;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photos = exercisePhotos(exercise);
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.button),
      child: SizedBox.square(
        dimension: size,
        child: photos.isEmpty
            ? ColoredBox(color: context.status.highlight, child: Icon(muscleIcon(exercise.muscle), color: scheme.primary))
            : Image.asset(photos.last, fit: BoxFit.cover, cacheWidth: (size * 3).round(), excludeFromSemantics: true),
      ),
    );
  }
}
