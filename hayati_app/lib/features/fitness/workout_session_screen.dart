import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/fitness.dart';
import '../../domain/fitness/exercises.dart';
import '../../domain/fitness/plan_generator.dart';
import '../../domain/fitness/programs.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/home_logo.dart';

class _Entry {
  _Entry(this.target);
  final PlannedExercise target;
  bool done = false;
  int? reps;
  int? seconds;
  double? weight;
}

/// Screen 15 — doing a planned workout: tick sets, adjust what you actually
/// did, rest between sets, then save. Only ticked sets are recorded.
class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({super.key, required this.place, required this.weekday, this.atHome = false, this.programId});
  final WorkoutPlace place;
  final int weekday;

  /// A program (flexibility, pelvic floor…) instead of a plan day.
  final String? programId;

  /// A gym day done at home with substitutes.
  final bool atHome;

  @override
  ConsumerState<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  WorkoutPlan? _plan;
  Program? _program;
  WorkoutDay? _day;
  List<Swap> _swaps = const [];
  List<PlannedExercise> _list = const [];
  late List<List<_Entry>> _entries;
  Timer? _rest;
  int _restLeft = 0;

  @override
  void initState() {
    super.initState();
    final d = ref.read(dataProvider);
    final program = programById(widget.programId);
    if (program != null) {
      // Women's and men's programs open only for that audience.
      _program = programVisible(program, d.settings) && clearedFor(program, d.settings.health) ? program : null;
      _day = _program?.asDay(widget.weekday);
    } else {
      _plan = d.activePlan(widget.place);
      _day = _plan?.dayFor(widget.weekday);
    }
    final profile = d.settings.fitness;
    if (_day != null && widget.atHome && profile != null) {
      _swaps = homeVersion(_day!, profile);
      _list = [for (final s in _swaps) ?s.replacement];
    } else {
      _list = _day?.exercises ?? const [];
    }
    _entries = [
      for (final x in _list) [for (var i = 0; i < x.sets; i++) _Entry(x)..reps = x.reps..seconds = x.seconds],
    ];
  }

  @override
  void dispose() {
    _rest?.cancel();
    super.dispose();
  }

  bool get _started => _entries.any((e) => e.any((s) => s.done));

  void _toggle(_Entry e, int restSeconds) {
    setState(() => e.done = !e.done);
    if (e.done && restSeconds > 0) {
      HapticFeedback.lightImpact();
      _startRest(restSeconds);
    }
  }

  void _startRest(int seconds) {
    _rest?.cancel();
    setState(() => _restLeft = seconds);
    _rest = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _restLeft--);
      if (_restLeft <= 0) {
        t.cancel();
        HapticFeedback.mediumImpact();
      }
    });
  }

  Future<void> _finish() async {
    final l = AppLocalizations.of(context);
    if (!_started) {
      if (await confirmDialog(context, title: l.noSetsTitle, message: l.noSetsBody, confirmLabel: l.leaveWithoutSaving) &&
          mounted) {
        context.pop();
      }
      return;
    }
    final r = await showModalBottomSheet<(int?, String)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _FinishSheet(),
    );
    if (r == null || !mounted) return;
    final now = ref.read(clockProvider)();
    final sets = <SetLog>[
      for (var i = 0; i < _entries.length; i++)
        for (var j = 0; j < _entries[i].length; j++)
          if (_entries[i][j].done)
            SetLog(
              exerciseId: _list[i].exerciseId,
              setIndex: j,
              reps: _entries[i][j].reps,
              seconds: _entries[i][j].seconds,
              weightKg: _entries[i][j].weight,
            ),
    ];
    final all = _entries.every((e) => e.every((s) => s.done));
    ref.read(dataProvider.notifier).logWorkout(WorkoutSession(
          id: newId(),
          planId: _plan?.id,
          programId: _program?.id,
          day: dayKey(now),
          place: widget.atHome || _program != null ? WorkoutPlace.home : widget.place,
          focus: _day!.focus,
          status: all ? SessionStatus.completed : SessionStatus.partial,
          difficulty: r.$1,
          note: r.$2,
          sets: sets,
          substituted: widget.atHome,
          createdAt: now,
        ));
    showSnack(context, all ? l.workoutSaved : l.workoutSavedPartial);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = l.localeName;
    if (_day == null) {
      return Scaffold(appBar: AppBar(actions: const [HomeLogoButton()]), body: EmptyState(icon: Icons.event_busy, title: l.noWorkoutThatDay));
    }
    final total = _entries.fold<int>(0, (s, e) => s + e.length);
    final done = _entries.fold<int>(0, (s, e) => s + e.where((x) => x.done).length);
    final notes = _swaps.where((s) => s.kind == SwapKind.approximate || s.kind == SwapKind.none).toList();

    return PopScope(
      canPop: !_started,
      onPopInvokedWithResult: (popped, _) async {
        if (popped) return;
        if (await confirmDiscard(context) && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_program?.name(lang) ?? l.todaysWorkout(l.dayFocus(_day!.focus))), actions: const [HomeLogoButton()]),
        body: ResponsiveContainer(
          maxWidth: 760,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 140),
            children: [
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: total == 0 ? 0 : done / total),
                      duration: Motion.medium,
                      curve: Motion.curve,
                      builder: (_, v, _) => LinearProgressIndicator(value: v, minHeight: 8),
                    ),
                  ),
                ),
                const SizedBox(width: Space.m),
                Text(l.setsProgress(done, total), style: t.labelMedium),
              ]),
              if (widget.atHome) ...[
                const SizedBox(height: Space.l),
                AppCard(
                  color: context.status.highlight,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.home_outlined, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: Space.s),
                      Expanded(child: Text(l.homeVersionTitle, style: t.titleSmall)),
                    ]),
                    const SizedBox(height: Space.xs),
                    Text(l.homeVersionBody, style: t.bodySmall),
                    for (final s in notes) ...[
                      const SizedBox(height: Space.xs),
                      Text(
                        s.kind == SwapKind.none
                            ? l.noHomeAlternative(exerciseById(s.original.exerciseId)!.name(lang))
                            : l.approximateSwap(
                                exerciseById(s.original.exerciseId)!.name(lang),
                                exerciseById(s.replacement!.exerciseId)!.name(lang),
                              ),
                        style: t.bodySmall?.copyWith(color: context.status.warning),
                      ),
                    ],
                  ]),
                ),
              ],
              const SizedBox(height: Space.l),
              for (var i = 0; i < _list.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.m),
                  child: _ExerciseCard(
                    plan: _list[i],
                    entries: _entries[i],
                    onToggle: (e) => _toggle(e, _list[i].restSeconds),
                    onChanged: () => setState(() {}),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedSize(
              duration: Motion.medium,
              curve: Motion.curve,
              child: _restLeft > 0
                  ? Container(
                      width: double.infinity,
                      color: AppColors.navy,
                      padding: const EdgeInsets.symmetric(horizontal: Space.gutter, vertical: Space.s),
                      child: Row(children: [
                        const Icon(Icons.timer_outlined, color: Colors.white),
                        const SizedBox(width: Space.s),
                        Expanded(child: Text(l.restFor(_restLeft), style: t.titleSmall?.copyWith(color: Colors.white))),
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: Colors.white),
                          onPressed: () {
                            _rest?.cancel();
                            setState(() => _restLeft = 0);
                          },
                          child: Text(l.skipRest),
                        ),
                      ]),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.l),
              child: ResponsiveContainer(
                maxWidth: 760,
                child: PrimaryButton(label: l.finishWorkout, icon: Icons.flag, onPressed: _finish),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.plan, required this.entries, required this.onToggle, required this.onChanged});
  final PlannedExercise plan;
  final List<_Entry> entries;
  final ValueChanged<_Entry> onToggle;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final e = exerciseById(plan.exerciseId)!;
    final timed = plan.seconds != null;
    final allDone = entries.every((x) => x.done);
    return AnimatedContainer(
      duration: Motion.medium,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: allDone ? context.status.success : Colors.transparent, width: 1.5),
      ),
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
              child: InkWell(
                onTap: () => context.push(Routes.exercise(e.id)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.name(l.localeName), style: t.titleMedium),
                  Text('${l.prescription(plan)} · ${l.restSeconds(plan.restSeconds)}',
                      style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                ]),
              ),
            ),
            IconButton(
              tooltip: l.howTo,
              icon: const Icon(Icons.info_outline),
              onPressed: () => context.push(Routes.exercise(e.id)),
            ),
          ]),
          const SizedBox(height: Space.s),
          for (var j = 0; j < entries.length; j++)
            Padding(
              padding: const EdgeInsets.only(top: Space.xs),
              child: Row(children: [
                Checkbox(
                  value: entries[j].done,
                  semanticLabel: l.setN(j + 1),
                  onChanged: (_) => onToggle(entries[j]),
                ),
                SizedBox(width: 56, child: Text(l.setN(j + 1), style: t.labelMedium)),
                const SizedBox(width: Space.s),
                Expanded(
                  child: _NumField(
                    label: timed ? l.secondsLabel : l.repsLabel,
                    initial: timed ? entries[j].seconds : entries[j].reps,
                    onChanged: (v) {
                      if (timed) {
                        entries[j].seconds = v?.round();
                      } else {
                        entries[j].reps = v?.round();
                      }
                      onChanged();
                    },
                  ),
                ),
                if (!timed && (e.equipment.isNotEmpty || e.gymOnly.isNotEmpty)) ...[
                  const SizedBox(width: Space.s),
                  Expanded(
                    child: _NumField(
                      label: l.weightKg,
                      initial: entries[j].weight,
                      decimal: true,
                      onChanged: (v) {
                        entries[j].weight = v?.toDouble();
                        onChanged();
                      },
                    ),
                  ),
                ],
              ]),
            ),
        ]),
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  const _NumField({required this.label, required this.initial, required this.onChanged, this.decimal = false});
  final String label;
  final num? initial;
  final ValueChanged<num?> onChanged;
  final bool decimal;

  @override
  Widget build(BuildContext context) => TextFormField(
        initialValue: initial?.toString() ?? '',
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(decimal ? r'[0-9.]' : r'[0-9]'))],
        decoration: InputDecoration(labelText: label, isDense: true),
        onChanged: (v) => onChanged(num.tryParse(v)),
      );
}

/// How hard it felt (optional) and a note.
class _FinishSheet extends StatefulWidget {
  const _FinishSheet();
  @override
  State<_FinishSheet> createState() => _FinishSheetState();
}

class _FinishSheetState extends State<_FinishSheet> {
  int? _difficulty;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, MediaQuery.viewInsetsOf(context).bottom + Space.l),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.howDidItFeel, style: t.titleMedium),
        const SizedBox(height: Space.m),
        Wrap(spacing: Space.s, runSpacing: Space.s, children: [
          for (var i = 1; i <= 5; i++)
            ChoiceChip(
              label: Text(l.effort('$i')),
              selected: _difficulty == i,
              onSelected: (on) => setState(() => _difficulty = on ? i : null),
            ),
        ]),
        const SizedBox(height: Space.l),
        TextField(
          controller: _note,
          maxLength: 2000,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(labelText: l.workoutNote, hintText: l.workoutNoteHint),
        ),
        const SizedBox(height: Space.m),
        PrimaryButton(label: l.saveWorkout, onPressed: () => Navigator.pop(context, (_difficulty, _note.text.trim()))),
      ]),
    );
  }
}
