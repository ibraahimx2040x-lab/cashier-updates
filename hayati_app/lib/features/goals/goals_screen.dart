import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/goal.dart';
import '../../domain/metrics.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

/// Screen 10 — goals grouped active → paused → completed/archived.
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  GoalCategory? _cat;
  bool _showDone = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final goals = d.goals.where((g) => _cat == null || g.category == _cat).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final active = goals.where((g) => g.status == GoalStatus.active).toList();
    final paused = goals.where((g) => g.status == GoalStatus.paused).toList();
    final done = goals.where((g) => g.status == GoalStatus.completed || g.status == GoalStatus.archived).toList();

    Widget list(String title, List<Goal> gs) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionHeader('$title (${gs.length})'),
          for (final g in gs)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.m),
              child: GoalCard(
                goal: g,
                fmt: fmt,
                progress: GoalProgress.of(g, d.milestonesOf(g.id)),
                onTap: () => context.push(Routes.goal(g.id)),
              ),
            ),
          const SizedBox(height: Space.l),
        ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.myGoals),
        actions: [
          IconButton(tooltip: l.addGoal, onPressed: () => context.push(Routes.goal('new')), icon: const Icon(Icons.add)),
        ],
      ),
      body: ResponsiveContainer(
        child: Column(children: [
          FilterChips<GoalCategory?>(
            values: [null, ...GoalCategory.values],
            selected: _cat,
            label: (c) => c == null ? l.filterAll : l.goalCategory(c),
            onSelected: (c) => setState(() => _cat = c),
          ),
          Expanded(
            child: d.goals.isEmpty
                ? EmptyState(
                    icon: Icons.flag_outlined,
                    title: l.noGoalsYet,
                    message: l.goalsEmptyBody,
                    action: l.addGoal,
                    onAction: () => context.push(Routes.goal('new')),
                  )
                : ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.l, Space.gutter, 96), children: [
                    if (active.isEmpty && paused.isEmpty) Padding(
                      padding: const EdgeInsets.only(bottom: Space.l),
                      child: Text(l.noActiveGoals),
                    ),
                    if (active.isNotEmpty) list(l.goalActive, active),
                    if (paused.isNotEmpty) list(l.goalPaused, paused),
                    if (done.isNotEmpty)
                      _showDone
                          ? list(l.completedAndArchived, done)
                          : TextButton(
                              onPressed: () => setState(() => _showDone = true),
                              child: Text('${l.showCompleted} (${done.length})'),
                            ),
                  ]),
          ),
        ]),
      ),
    );
  }
}
