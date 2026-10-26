import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/goal.dart';
import '../../data/models/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

const currencies = ['SAR', 'AED', 'KWD', 'QAR', 'BHD', 'OMR', 'EGP', 'JOD', 'USD', 'EUR', 'GBP'];

/// Screen 4 — four short steps; only the minimum needed to personalise.
/// Nothing (tasks, notifications) is created without the user choosing it.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final _name = TextEditingController();
  final _goal = TextEditingController();
  String _currency = 'SAR';
  Set<AppModule> _modules = {...AppModule.values};
  bool _hasWork = false;
  int _workStart = 9 * 60, _workEnd = 17 * 60;
  int _dayStart = 7 * 60, _dayEnd = 23 * 60;
  bool _hasBreak = false;
  int _breakStart = 13 * 60, _breakEnd = 14 * 60;

  @override
  void dispose() {
    _name.dispose();
    _goal.dispose();
    super.dispose();
  }

  void _finish() {
    final data = ref.read(dataProvider.notifier);
    final goalTitle = _goal.text.trim();
    if (goalTitle.isNotEmpty) {
      final now = ref.read(clockProvider)();
      data.saveGoal(
        Goal(id: newId(), title: goalTitle, startDate: dayKey(now), createdAt: now, updatedAt: now),
        const [],
      );
    }
    data.updateSettings((s) => s.copyWith(
          displayName: _name.text.trim(),
          currency: _currency,
          modules: _modules.isEmpty ? {AppModule.time} : _modules,
          work: () => _hasWork && _workEnd > _workStart ? TimeRange(_workStart, _workEnd) : null,
          dayStart: _dayStart,
          dayEnd: _dayEnd > _dayStart ? _dayEnd : _dayStart + 60,
          breaks: _hasBreak && _breakEnd > _breakStart ? [TimeRange(_breakStart, _breakEnd)] : const [],
          onboardingDone: true,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final steps = [_language(l), _interests(l), _goalStep(l), _planning(l)];
    final titles = [l.obStep1, l.obStep2, l.obStep3, l.obStep4];
    final last = _step == steps.length - 1;
    return Scaffold(
      appBar: AppBar(
        leading: _step == 0 ? null : BackButton(onPressed: () => setState(() => _step--)),
        title: Text(l.stepOf(_step + 1, steps.length)),
        actions: [
          if (_step == 2) TextButton(onPressed: () => setState(() => _step++), child: Text(l.skip)),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 560,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.xl),
              child: LinearProgressIndicator(value: (_step + 1) / steps.length, minHeight: 4),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.all(Space.xl), children: [
                Text(titles[_step], style: t.headlineSmall),
                const SizedBox(height: Space.xl),
                steps[_step],
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.l),
              child: Row(children: [
                if (_step > 0) ...[
                  Expanded(child: SecondaryButton(label: l.back, onPressed: () => setState(() => _step--))),
                  const SizedBox(width: Space.m),
                ],
                Expanded(
                  child: PrimaryButton(
                    label: last ? l.finishSetup : l.next,
                    onPressed: last ? _finish : () => setState(() => _step++),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _language(AppLocalizations l) {
    final locale = ref.watch(localeProvider);
    final offset = DateTime.now().timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final tz = '${DateTime.now().timeZoneName} (UTC$sign${offset.inHours.abs().toString().padLeft(2, '0')}:${(offset.inMinutes.abs() % 60).toString().padLeft(2, '0')})';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppTextField(label: l.displayNameOptional, controller: _name),
      const SizedBox(height: Space.l),
      Text(l.language, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: Space.s),
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'ar', label: Text('العربية')),
          ButtonSegment(value: 'en', label: Text('English')),
        ],
        selected: {locale.languageCode},
        onSelectionChanged: (v) => ref.read(localeProvider.notifier).set(Locale(v.first)),
      ),
      const SizedBox(height: Space.l),
      Text(l.timezone, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: Space.s),
      AppCard(
        child: Row(children: [
          const Icon(Icons.public),
          const SizedBox(width: Space.m),
          Expanded(child: Text('$tz\n${l.timezoneDetected}')),
        ]),
      ),
      const SizedBox(height: Space.l),
      Text(l.defaultCurrency, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: Space.s),
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: _currency,
        items: [for (final c in currencies) DropdownMenuItem(value: c, child: Text(c))],
        onChanged: (v) => setState(() => _currency = v ?? _currency),
      ),
    ]);
  }

  Widget _interests(AppLocalizations l) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.interestsHint),
        const SizedBox(height: Space.l),
        Wrap(spacing: Space.s, runSpacing: Space.s, children: [
          for (final m in AppModule.values)
            FilterChip(
              label: Text(l.module(m)),
              selected: _modules.contains(m),
              onSelected: (v) => setState(() => _modules = v ? {..._modules, m} : ({..._modules}..remove(m))),
            ),
        ]),
      ]);

  Widget _goalStep(AppLocalizations l) {
    final samples = [l.sampleGoal1, l.sampleGoal2, l.sampleGoal3, l.sampleGoal4];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l.goalStepHint),
      const SizedBox(height: Space.l),
      Wrap(spacing: Space.s, runSpacing: Space.s, children: [
        for (final s in samples) ActionChip(label: Text(s), onPressed: () => setState(() => _goal.text = s)),
      ]),
      const SizedBox(height: Space.l),
      AppTextField(label: l.goalTitle, controller: _goal, hint: l.goalTitleHint),
    ]);
  }

  Widget _planning(AppLocalizations l) {
    final fmt = Fmt.of(context);
    Widget pair(String a, int va, ValueChanged<int> ca, String b, int vb, ValueChanged<int> cb) => Row(children: [
          Expanded(child: TimePickerField(label: a, minutes: va, fmt: fmt, clearable: false, onChanged: (v) => setState(() => ca(v!)))),
          const SizedBox(width: Space.m),
          Expanded(child: TimePickerField(label: b, minutes: vb, fmt: fmt, clearable: false, onChanged: (v) => setState(() => cb(v!)))),
        ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l.planningHint),
      const SizedBox(height: Space.l),
      pair(l.dayStart, _dayStart, (v) => _dayStart = v, l.dayEnd, _dayEnd, (v) => _dayEnd = v),
      const SizedBox(height: Space.l),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l.hasWorkHours),
        value: _hasWork,
        onChanged: (v) => setState(() => _hasWork = v),
      ),
      if (_hasWork) pair(l.workStart, _workStart, (v) => _workStart = v, l.workEnd, _workEnd, (v) => _workEnd = v),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l.hasBreak),
        value: _hasBreak,
        onChanged: (v) => setState(() => _hasBreak = v),
      ),
      if (_hasBreak) pair(l.breakStart, _breakStart, (v) => _breakStart = v, l.breakEnd, _breakEnd, (v) => _breakEnd = v),
      const SizedBox(height: Space.l),
      Text(l.onboardingNoAuto, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}
