import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/learning/curriculum.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';

/// One question at a time. With [feedback], each answer is marked right or
/// wrong (and the right one shown) before moving on; without it (placement
/// tests), answers aren't revealed.
class QuizRunner extends StatefulWidget {
  const QuizRunner({super.key, required this.questions, required this.onDone, this.feedback = true});
  final List<Question> questions;
  final ValueChanged<Map<String, int>> onDone;
  final bool feedback;

  @override
  State<QuizRunner> createState() => _QuizRunnerState();
}

class _QuizRunnerState extends State<QuizRunner> {
  int _i = 0;
  int? _chosen;
  bool _checked = false;
  final _answers = <String, int>{};

  Question get _q => widget.questions[_i];

  void _next() {
    _answers[_q.id] = _chosen!;
    if (_i == widget.questions.length - 1) {
      widget.onDone(Map.of(_answers));
      return;
    }
    setState(() {
      _i++;
      _chosen = null;
      _checked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final passage = passageById(_q.passageId);
    final last = _i == widget.questions.length - 1;

    Color? border(int i) {
      if (!_checked) return i == _chosen ? scheme.primary : null;
      if (i == _q.answer) return context.status.success;
      if (i == _chosen) return scheme.error;
      return null;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: (_i + 1) / widget.questions.length),
              duration: Motion.medium,
              curve: Motion.curve,
              builder: (_, v, _) => LinearProgressIndicator(value: v, minHeight: 8),
            ),
          ),
        ),
        const SizedBox(width: Space.m),
        Text(l.questionOf(_i + 1, widget.questions.length), style: t.labelMedium),
      ]),
      const SizedBox(height: Space.l),
      SmoothSwitcher(
        childKey: _i,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (passage != null) ...[
            AppCard(
              color: context.status.highlight,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.readThis, style: t.labelMedium?.copyWith(color: scheme.primary)),
                const SizedBox(height: Space.s),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(passage.text, style: t.bodyLarge?.copyWith(fontFamily: 'Readex')),
                ),
              ]),
            ),
            const SizedBox(height: Space.m),
          ],
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(_q.prompt, style: t.titleLarge?.copyWith(fontFamily: 'Readex')),
          ),
          const SizedBox(height: Space.l),
          for (var i = 0; i < _q.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: AnimatedContainer(
                duration: Motion.fast,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Radii.card),
                  border: Border.all(color: border(i) ?? Colors.transparent, width: 2),
                ),
                child: AppCard(
                  onTap: _checked ? null : () => setState(() => _chosen = i),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(children: [
                      Icon(
                        _checked && i == _q.answer
                            ? Icons.check_circle
                            : _checked && i == _chosen
                                ? Icons.cancel
                                : i == _chosen
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                        color: border(i) ?? context.status.inactive,
                      ),
                      const SizedBox(width: Space.m),
                      Expanded(child: Text(_q.options[i], style: t.titleMedium?.copyWith(fontFamily: 'Readex'))),
                    ]),
                  ),
                ),
              ),
            ),
          if (_checked)
            Padding(
              padding: const EdgeInsets.only(top: Space.s),
              child: Text(
                _chosen == _q.answer ? l.answerRight : l.answerWrong(_q.options[_q.answer]),
                style: t.titleSmall?.copyWith(color: _chosen == _q.answer ? context.status.success : scheme.error),
              ),
            ),
        ]),
      ),
      const SizedBox(height: Space.l),
      if (widget.feedback && !_checked)
        PrimaryButton(label: l.checkAnswer, onPressed: _chosen == null ? null : () => setState(() => _checked = true))
      else
        PrimaryButton(label: last ? l.seeResult : l.next, onPressed: _chosen == null ? null : _next),
      if (!widget.feedback) ...[
        const SizedBox(height: Space.s),
        Text(l.placementNoPeek, textAlign: TextAlign.center, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
      ],
    ]);
  }
}

/// Correct answers in [answers] as a percentage of [questions].
int scorePercent(List<Question> questions, Map<String, int> answers) {
  if (questions.isEmpty) return 0;
  final right = questions.where((q) => answers[q.id] == q.answer).length;
  return (right * 100 / questions.length).round();
}
