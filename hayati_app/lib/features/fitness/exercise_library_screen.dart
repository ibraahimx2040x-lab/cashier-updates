import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/fitness.dart';
import '../../domain/fitness/exercise_info.dart';
import '../../domain/fitness/exercises.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/home_logo.dart';
import 'exercise_media.dart';

/// Every exercise, browsable by muscle, level, goal and place (v4 change 7).
class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  final _search = TextEditingController();
  Muscle? _muscle;
  int? _level;
  FitnessGoal? _goal;
  WorkoutPlace? _place;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool get _filtered => _muscle != null || _level != null || _goal != null || _place != null || _search.text.isNotEmpty;

  void _clear() => setState(() {
        _muscle = _level = _goal = _place = null;
        _search.clear();
      });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = l.localeName;
    final home = ref.watch(dataProvider).settings.fitness?.homeEquipment ?? const <Equipment>{};
    final list = filterExercises(muscle: _muscle, level: _level, goal: _goal, place: _place, home: home, query: _search.text);

    return Scaffold(
      appBar: AppBar(title: Text(l.exerciseLibrary), actions: const [HomeLogoButton()]),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl), children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l.searchExercises,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(tooltip: l.clearFilters, icon: const Icon(Icons.close), onPressed: () => setState(_search.clear)),
            ),
          ),
          const SizedBox(height: Space.m),
          _ChipRow<Muscle>(
            label: l.filterMuscle,
            all: l.filterAll,
            values: Muscle.values,
            selected: _muscle,
            name: l.muscle,
            onSelected: (v) => setState(() => _muscle = v),
          ),
          _ChipRow<int>(
            label: l.filterLevel,
            all: l.filterAll,
            values: const [1, 2, 3],
            selected: _level,
            name: l.difficulty,
            onSelected: (v) => setState(() => _level = v),
          ),
          _ChipRow<FitnessGoal>(
            label: l.filterGoal,
            all: l.filterAll,
            values: FitnessGoal.values,
            selected: _goal,
            name: l.fitnessGoal,
            onSelected: (v) => setState(() => _goal = v),
          ),
          _ChipRow<WorkoutPlace>(
            label: l.filterPlace,
            all: l.filterAll,
            values: WorkoutPlace.values,
            selected: _place,
            name: l.workoutPlace,
            onSelected: (v) => setState(() => _place = v),
          ),
          const SizedBox(height: Space.s),
          Row(children: [
            Expanded(child: Text(l.exerciseCount(list.length), style: t.labelLarge?.copyWith(color: context.status.textSecondary))),
            if (_filtered) TextButton(onPressed: _clear, child: Text(l.clearFilters)),
          ]),
          const SizedBox(height: Space.s),
          if (list.isEmpty)
            EmptyState(icon: Icons.search_off, title: l.noExercisesMatch, action: l.clearFilters, onAction: _clear)
          else
            for (final e in list)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.s),
                child: AppCard(
                  onTap: () => context.push(Routes.exercise(e.id)),
                  child: Row(children: [
                    ExerciseThumb(exercise: e),
                    const SizedBox(width: Space.m),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.name(lang), style: t.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          [
                            l.muscle(e.muscle),
                            l.difficulty(e.difficulty),
                            if (e.gymOnly.isNotEmpty) l.placeGym else if (e.equipment.isEmpty) l.bodyweight else ...[for (final q in e.equipment) l.equipment(q)],
                          ].join(' · '),
                          style: t.bodySmall?.copyWith(color: context.status.textSecondary),
                        ),
                      ]),
                    ),
                    const Icon(Icons.chevron_right),
                  ]),
                ),
              ),
        ]),
      ),
    );
  }
}

/// One filter: a label and a scrolling row of chips, "All" first.
class _ChipRow<T> extends StatelessWidget {
  const _ChipRow({required this.label, required this.all, required this.values, required this.selected, required this.name, required this.onSelected});
  final String label;
  final String all;
  final List<T> values;
  final T? selected;
  final String Function(T) name;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Space.s),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: Space.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final v in [null, ...values])
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: Space.s),
                  child: ChoiceChip(
                    label: Text(v == null ? all : name(v)),
                    selected: selected == v,
                    onSelected: (_) => onSelected(v),
                  ),
                ),
            ]),
          ),
        ]),
      );
}
