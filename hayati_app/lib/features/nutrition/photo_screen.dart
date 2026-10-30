import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/models/nutrition.dart';
import '../../domain/nutrition/foods.dart';
import '../../l10n/app_localizations.dart';
import '../../services/food_recognizer.dart';
import '../../widgets/common.dart';
import 'portion_sheet.dart';
import '../../widgets/home_logo.dart';

/// Screen 37b — a meal photo, read on the phone: the model suggests what
/// it shows, the user picks the matching food (or searches), and the
/// numbers come from the food list. The photo is not kept.
class PhotoScreen extends ConsumerStatefulWidget {
  const PhotoScreen({super.key, required this.day, required this.meal});
  final String day;
  final MealType meal;

  @override
  ConsumerState<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends ConsumerState<PhotoScreen> {
  String? _path;
  List<FoodGuess>? _guesses;
  bool _busy = false;
  bool _failed = false;

  Future<void> _take(ImageSource source) async {
    final x = await ImagePicker().pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    if (x == null || !mounted) return;
    setState(() {
      _path = x.path;
      _busy = true;
      _failed = false;
      _guesses = null;
    });
    try {
      final g = await ref.read(foodRecognizerProvider).recognize(x.path);
      if (mounted) setState(() => _guesses = g);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pick(BuiltinFood f) async {
    final l = AppLocalizations.of(context);
    final lang = l.localeName;
    final ok = await showPortionSheet(context, ref,
        name: f.name(lang), portion: f.portion(lang), per: f.per, day: widget.day, meal: widget.meal, foodRef: f.id);
    if (ok && mounted) {
      showSnack(context, l.foodAdded(f.name(lang)));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context);
    final lang = l.localeName;
    final guesses = _guesses ?? const [];
    final matches = [
      ...{
        for (final g in guesses)
          for (final f in foodsForLabel(g.label)) f,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.mealPhoto), actions: const [HomeLogoButton()]),
      body: ResponsiveContainer(
        maxWidth: 640,
        child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
          if (_path != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.card),
              child: Image.file(File(_path!), height: 220, fit: BoxFit.cover),
            )
          else
            AppCard(
              color: context.status.highlight,
              child: Row(children: [
                const IconBadge(Icons.photo_camera_outlined, color: AppColors.goldDeep),
                const SizedBox(width: Space.m),
                Expanded(child: Text(l.photoIntro, style: t.bodyMedium)),
              ]),
            ),
          if (_path == null) ...[
            const SizedBox(height: Space.m),
            for (final (i, step) in [l.photoStep1, l.photoStep2, l.photoStep3].indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.xs),
                child: Row(children: [
                  CircleAvatar(radius: 11, child: Text('${i + 1}', style: t.labelSmall)),
                  const SizedBox(width: Space.s),
                  Expanded(child: Text(step, style: t.bodyMedium)),
                ]),
              ),
          ],
          const SizedBox(height: Space.m),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _busy ? null : () => _take(ImageSource.camera),
                icon: const Icon(Icons.photo_camera),
                label: Text(l.takePhoto),
              ),
            ),
            const SizedBox(width: Space.s),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : () => _take(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l.fromGallery),
              ),
            ),
          ]),
          const SizedBox(height: Space.l),
          if (_busy) const LoadingState(),
          if (_failed) Text(l.photoFailed, style: t.bodyMedium),
          if (_guesses != null && !_busy) ...[
            if (matches.isNotEmpty) ...[
              SectionHeader(l.didYouEat),
              for (final f in matches)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.s),
                  child: AppCard(
                    onTap: () => _pick(f),
                    child: Row(children: [
                      const IconBadge(Icons.restaurant),
                      const SizedBox(width: Space.m),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(f.name(lang), style: t.titleSmall),
                          Text('${f.portion(lang)} · ${macroLine(l, fmt, f.per)}', style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                        ]),
                      ),
                      const Icon(Icons.add_circle_outline),
                    ]),
                  ),
                ),
            ] else
              Text(l.photoNoMatch, style: t.bodyMedium),
            if (guesses.isNotEmpty) ...[
              const SizedBox(height: Space.m),
              Text(l.modelSaw, style: t.labelMedium?.copyWith(color: context.status.textSecondary)),
              const SizedBox(height: Space.xs),
              Wrap(spacing: Space.s, runSpacing: Space.s, children: [
                for (final g in guesses.take(5))
                  ActionChip(
                    label: Text('${g.label} · ${(g.confidence * 100).round()}%'),
                    onPressed: () => context.pushReplacement(Routes.nutritionAdd(day: widget.day, meal: widget.meal.name, q: g.label)),
                  ),
              ]),
            ],
            const SizedBox(height: Space.l),
            OutlinedButton.icon(
              onPressed: () => context.pushReplacement(Routes.nutritionAdd(day: widget.day, meal: widget.meal.name)),
              icon: const Icon(Icons.search),
              label: Text(l.searchInstead),
            ),
          ],
          const SizedBox(height: Space.l),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.lock_outline, size: 18, color: context.status.success),
            const SizedBox(width: Space.s),
            Expanded(child: Text(l.photoPrivacy, style: t.bodySmall?.copyWith(color: context.status.textSecondary))),
          ]),
        ]),
      ),
    );
  }
}
