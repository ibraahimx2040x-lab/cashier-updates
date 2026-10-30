import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/fitness.dart';
import '../../domain/fitness/exercises.dart';
import '../../domain/fitness/plan_generator.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import '../../widgets/home_logo.dart';

/// Screen 13 — answers that shape the plan, then a preview before saving.
/// Saving creates a new plan version; earlier ones are kept.
class FitnessSetupScreen extends ConsumerStatefulWidget {
  const FitnessSetupScreen({super.key});

  @override
  ConsumerState<FitnessSetupScreen> createState() => _FitnessSetupScreenState();
}

class _FitnessSetupScreenState extends ConsumerState<FitnessSetupScreen> {
  late FitnessGoal _goal;
  late FitnessLevel _level;
  late int _days;
  late List<int> _weekdays;
  late int _minutes;
  late Set<WorkoutPlace> _places;
  late Set<Equipment> _equipment;
  Map<WorkoutPlace, List<WorkoutDay>>? _preview;

  @override
  void initState() {
    super.initState();
    final s = ref.read(dataProvider).settings;
    final f = s.fitness;
    _goal = f?.goal ?? FitnessGoal.general;
    _level = f?.level ?? FitnessLevel.beginner;
    _days = f?.daysPerWeek ?? 3;
    _weekdays = f?.weekdays ?? PlanGenerator.defaultWeekdays(_days, s.weekStart);
    _minutes = f?.minutesPerSession ?? 45;
    _places = {...?f?.places};
    if (_places.isEmpty) _places = {WorkoutPlace.home};
    _equipment = {...?f?.homeEquipment};
  }

  int get _weekStart => ref.read(dataProvider).settings.weekStart;

  /// Weekdays in the order of the user's week.
  List<int> _ordered(Iterable<int> days) =>
      [...days]..sort((a, b) => ((a - _weekStart + 7) % 7).compareTo((b - _weekStart + 7) % 7));

  FitnessProfile get _profile => FitnessProfile(
        goal: _goal,
        level: _level,
        daysPerWeek: _days,
        minutesPerSession: _minutes,
        weekdays: _ordered(_weekdays),
        places: _places,
        homeEquipment: _equipment,
        preferredPlace: _places.contains(ref.read(dataProvider).settings.fitness?.preferredPlace)
            ? ref.read(dataProvider).settings.fitness!.preferredPlace
            : _places.first,
      );

  void _changed(VoidCallback f) => setState(() {
        f();
        _preview = null;
      });

  bool get _valid => _weekdays.length == _days && _places.isNotEmpty;

  void _generate() {
    const g = PlanGenerator();
    setState(() => _preview = {for (final p in WorkoutPlace.values) if (_places.contains(p)) p: g.build(_profile, p)});
  }

  void _save() {
    final l = AppLocalizations.of(context);
    ref.read(dataProvider.notifier).saveFitness(_profile, _preview!);
    showSnack(context, l.planSaved);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context);

    Widget chips<T>(List<T> values, bool Function(T) selected, String Function(T) label, void Function(T) onTap) => Wrap(
          spacing: Space.s,
          runSpacing: Space.s,
          children: [
            for (final v in values)
              ChoiceChip(label: Text(label(v)), selected: selected(v), onSelected: (_) => onTap(v)),
          ],
        );

    final week = [for (var i = 0; i < 7; i++) (_weekStart - 1 + i) % 7 + 1];

    return Scaffold(
      appBar: AppBar(title: Text(l.fitnessSetupTitle), actions: const [HomeLogoButton()]),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 120),
          children: [
            SectionHeader(l.fsGoal),
            for (final g in FitnessGoal.values)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.s),
                child: AppCard(
                  color: _goal == g ? context.status.highlight : null,
                  onTap: () => _changed(() => _goal = g),
                  child: Row(children: [
                    Icon(_goal == g ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: Space.m),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l.fitnessGoal(g), style: t.titleSmall),
                        Text(l.fitnessGoalHint(g), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                      ]),
                    ),
                  ]),
                ),
              ),
            const SizedBox(height: Space.l),
            SectionHeader(l.fsLevel),
            chips(FitnessLevel.values, (v) => v == _level, l.fitnessLevel, (v) => _changed(() => _level = v)),
            const SizedBox(height: Space.xl),
            SectionHeader(l.fsDays),
            chips([2, 3, 4, 5, 6], (v) => v == _days, (v) => '$v', (v) => _changed(() {
                  _days = v;
                  _weekdays = PlanGenerator.defaultWeekdays(v, _weekStart);
                })),
            const SizedBox(height: Space.m),
            Text(l.fsWhichDays(_days), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
            const SizedBox(height: Space.s),
            Wrap(spacing: Space.s, runSpacing: Space.s, children: [
              for (final wd in week)
                FilterChip(
                  label: Text(fmt.weekdayShort(DateTime(2026, 1, 5).add(Duration(days: wd - 1)))),
                  selected: _weekdays.contains(wd),
                  onSelected: (on) => _changed(() {
                    if (on && _weekdays.length < _days) _weekdays = [..._weekdays, wd];
                    if (!on) _weekdays = _weekdays.where((x) => x != wd).toList();
                  }),
                ),
            ]),
            if (_weekdays.length != _days) ...[
              const SizedBox(height: Space.s),
              Text(l.fsPickDays(_days - _weekdays.length), style: t.bodySmall?.copyWith(color: context.status.warning)),
            ],
            const SizedBox(height: Space.xl),
            SectionHeader(l.fsMinutes),
            chips([20, 30, 45, 60, 75, 90], (v) => v == _minutes, l.unitMinutes, (v) => _changed(() => _minutes = v)),
            const SizedBox(height: Space.xl),
            SectionHeader(l.fsPlaces),
            Text(l.fsPlacesHint, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
            const SizedBox(height: Space.s),
            Wrap(spacing: Space.s, children: [
              for (final p in WorkoutPlace.values)
                FilterChip(
                  avatar: Icon(p == WorkoutPlace.home ? Icons.home_outlined : Icons.fitness_center, size: 18),
                  label: Text(l.workoutPlace(p)),
                  selected: _places.contains(p),
                  onSelected: (on) => _changed(() => _places = on ? {..._places, p} : ({..._places}..remove(p))),
                ),
            ]),
            if (_places.contains(WorkoutPlace.home)) ...[
              const SizedBox(height: Space.xl),
              SectionHeader(l.fsEquipment),
              Text(l.fsEquipmentHint, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
              const SizedBox(height: Space.s),
              Wrap(spacing: Space.s, runSpacing: Space.s, children: [
                for (final e in Equipment.values)
                  FilterChip(
                    label: Text(l.equipment(e)),
                    selected: _equipment.contains(e),
                    onSelected: (on) => _changed(() => _equipment = on ? {..._equipment, e} : ({..._equipment}..remove(e))),
                  ),
              ]),
            ],
            const SizedBox(height: Space.xl),
            if (_preview != null) SmoothSwitcher(childKey: _preview!, child: _Preview(plans: _preview!)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.l),
          child: ResponsiveContainer(
            maxWidth: 760,
            child: _preview == null
                ? PrimaryButton(label: l.showMyPlan, icon: Icons.auto_awesome, onPressed: _valid ? _generate : null)
                : PrimaryButton(label: l.savePlan, icon: Icons.check, onPressed: _save),
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.plans});
  final Map<WorkoutPlace, List<WorkoutDay>> plans;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final e in plans.entries) ...[
        SectionHeader(l.planFor(l.workoutPlace(e.key))),
        if (PlanGenerator.needsMoreRecovery(e.value))
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s),
            child: Text(l.recoveryWarning, style: t.bodySmall?.copyWith(color: context.status.warning)),
          ),
        for (var i = 0; i < e.value.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s),
            child: FadeSlideIn(
              index: i,
              child: AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        '${fmt.weekdayShort(DateTime(2026, 1, 5).add(Duration(days: e.value[i].weekday - 1)))} · ${l.dayFocus(e.value[i].focus)}',
                        style: t.titleSmall,
                      ),
                    ),
                    Pill(label: l.unitMinutes(e.value[i].minutes), color: AppColors.indigo, icon: Icons.timer_outlined),
                  ]),
                  const SizedBox(height: Space.s),
                  for (final x in e.value[i].exercises)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(children: [
                        Expanded(child: Text('• ${exerciseById(x.exerciseId)!.name(l.localeName)}', style: t.bodyMedium)),
                        Text(l.prescription(x), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                      ]),
                    ),
                ]),
              ),
            ),
          ),
        const SizedBox(height: Space.m),
      ],
      Text(l.planExplain, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
    ]);
  }
}
