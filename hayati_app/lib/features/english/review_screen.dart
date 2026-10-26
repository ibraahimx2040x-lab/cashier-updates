import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/data_controller.dart';
import '../../data/models/learning.dart';
import '../../domain/learning/curriculum.dart';
import '../../domain/learning/path.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';

/// Screen 19 — spaced review of learned words: pick the meaning; right
/// answers come back later, missed ones tomorrow.
class EnglishReviewScreen extends ConsumerStatefulWidget {
  const EnglishReviewScreen({super.key});

  @override
  ConsumerState<EnglishReviewScreen> createState() => _EnglishReviewScreenState();
}

class _EnglishReviewScreenState extends ConsumerState<EnglishReviewScreen> {
  late final List<VocabReview> _due;
  int _i = 0;
  int? _chosen;
  int _right = 0;

  @override
  void initState() {
    super.initState();
    final d = ref.read(dataProvider);
    _due = dueReviews(d, ref.read(clockProvider)()).take(20).toList();
  }

  /// The right meaning and three others, in a stable shuffled order.
  List<String> _options(Word w) {
    final all = [for (final l in lessons) ...l.words].where((x) => x.id != w.id && x.ar != w.ar).toList();
    final seed = w.id.codeUnits.fold<int>(0, (a, b) => a + b);
    final others = {for (var k = 0; k < 3; k++) all[(seed * (k + 7)) % all.length].ar}.toList();
    final opts = [w.ar, ...others];
    return [for (var k = 0; k < opts.length; k++) opts[(k + seed) % opts.length]];
  }

  void _answer(VocabReview r, String chosen, Word w, int index) {
    final correct = chosen == w.ar;
    final (box, due) = nextReview(r, correct, ref.read(clockProvider)());
    ref.read(dataProvider.notifier).reviewWord(r.wordId, box, due);
    setState(() {
      _chosen = index;
      if (correct) _right++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    Widget body;
    if (_due.isEmpty) {
      body = EmptyState(icon: Icons.check_circle_outline, title: l.noReviewsDue);
    } else if (_i >= _due.length) {
      body = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AppCard(
          color: context.status.highlight,
          child: Column(children: [
            Icon(Icons.emoji_events_outlined, size: 40, color: scheme.primary),
            const SizedBox(height: Space.s),
            Text(l.reviewDone(_right, _due.length), style: t.titleMedium, textAlign: TextAlign.center),
          ]),
        ),
        const SizedBox(height: Space.l),
        PrimaryButton(label: l.backToPath, onPressed: () => context.go(Routes.english)),
      ]);
    } else {
      final r = _due[_i];
      final w = wordById(r.wordId);
      if (w == null) {
        // A word removed from the course: skip it.
        WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _i++));
        body = const SizedBox();
      } else {
        final opts = _options(w);
        body = SmoothSwitcher(
          childKey: _i,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.questionOf(_i + 1, _due.length), style: t.labelMedium),
            const SizedBox(height: Space.l),
            Center(
              child: Text(w.en, style: t.displaySmall?.copyWith(fontFamily: 'Inter'), textDirection: TextDirection.ltr),
            ),
            if (_chosen != null)
              Center(
                child: Text(w.example,
                    style: t.bodyMedium?.copyWith(fontFamily: 'Inter', color: context.status.textSecondary),
                    textDirection: TextDirection.ltr),
              ),
            const SizedBox(height: Space.xl),
            for (var k = 0; k < opts.length; k++)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.s),
                child: AnimatedContainer(
                  duration: Motion.fast,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Radii.card),
                    border: Border.all(
                      width: 2,
                      color: _chosen == null
                          ? Colors.transparent
                          : opts[k] == w.ar
                              ? context.status.success
                              : k == _chosen
                                  ? scheme.error
                                  : Colors.transparent,
                    ),
                  ),
                  child: AppCard(
                    onTap: _chosen == null ? () => _answer(r, opts[k], w, k) : null,
                    child: Text(isolateLatin(opts[k]), style: t.titleMedium),
                  ),
                ),
              ),
            if (_chosen != null) ...[
              const SizedBox(height: Space.m),
              PrimaryButton(
                label: _i == _due.length - 1 ? l.seeResult : l.next,
                onPressed: () => setState(() {
                  _i++;
                  _chosen = null;
                }),
              ),
            ],
          ]),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.reviewTitle)),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl), children: [body]),
      ),
    );
  }
}
