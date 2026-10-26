import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/data_controller.dart';
import '../../data/models/settings.dart';
import '../../l10n/app_localizations.dart';
import '../expenses/expenses_screen.dart';
import '../habits/habits_screen.dart';

/// Quick add: task, event, goal, habit, note, expense — limited to the
/// sections the user enabled.
Future<void> showQuickAdd(BuildContext context, WidgetRef ref) {
  final l = AppLocalizations.of(context);
  final s = ref.read(settingsProvider);
  final items = <(IconData, String, void Function(BuildContext))>[
    (Icons.check_box_outlined, l.addTask, (c) => c.push(Routes.task('new'))),
    (Icons.event, l.addEvent, (c) => c.push(Routes.event('new'))),
    (Icons.flag_outlined, l.addGoal, (c) => c.push(Routes.goal('new'))),
    if (s.has(AppModule.habits)) (Icons.repeat, l.addHabit, (c) => showHabitEditor(c, ref)),
    if (s.has(AppModule.notes)) (Icons.sticky_note_2_outlined, l.addNote, (c) => c.push(Routes.note('new'))),
    if (s.has(AppModule.expenses))
      (Icons.account_balance_wallet_outlined, l.addExpense, (c) => showExpenseEditor(c, ref)),
  ];
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.quickAdd, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Space.m),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: Space.s,
            crossAxisSpacing: Space.s,
            childAspectRatio: 1.15,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final it in items)
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Radii.card),
                    onTap: () {
                      Navigator.pop(sheet);
                      it.$3(context);
                    },
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(it.$1, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: Space.s),
                      Text(it.$2, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium),
                    ]),
                  ),
                ),
            ],
          ),
        ]),
      ),
    ),
  );
}
