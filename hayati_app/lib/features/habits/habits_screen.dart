import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/goal.dart';
import '../../domain/metrics.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/device_notifications_card.dart';
import '../../widgets/home_logo.dart';

/// Screen 12 — habits and their history.
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final c = ref.read(dataProvider.notifier);
    final today = dayKey(now);
    final due = d.habits.where((h) => h.isDueOn(now)).toList();
    final done = due.where((h) => d.habitDoneOn(h.id, today)).length;
    final weekStart = startOfWeek(now, d.settings.weekStart);
    final active = d.habits.where((h) => h.active).toList();
    final inactive = d.habits.where((h) => !h.active).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navHabits),
        actions: [IconButton(tooltip: l.addHabit, icon: const Icon(Icons.add), onPressed: () => showHabitEditor(context, ref)), const HomeLogoButton()],
      ),
      body: d.habits.isEmpty
          ? EmptyState(
              icon: Icons.repeat,
              title: l.noHabitsYet,
              message: l.habitsEmptyBody,
              action: l.addHabit,
              onAction: () => showHabitEditor(context, ref),
            )
          : ResponsiveContainer(
              maxWidth: 760,
              child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(fmt.fullDate(now), style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: Space.xs),
                    Text(l.habitsDoneOf(done, due.length)),
                    const SizedBox(height: Space.m),
                    Row(children: [
                      for (var i = 0; i < 7; i++)
                        Builder(builder: (context) {
                          final day = weekStart.add(Duration(days: i));
                          final dueOn = d.habits.where((h) => h.isDueOn(day)).toList();
                          final doneOn = dueOn.where((h) => d.habitDoneOn(h.id, dayKey(day))).length;
                          final future = day.isAfter(dateOnly(now));
                          return Expanded(
                            child: Semantics(
                              label: '${fmt.weekdayDate(day)}: $doneOn / ${dueOn.length}',
                              child: Column(children: [
                                Text(fmt.weekdayShort(day), style: Theme.of(context).textTheme.labelSmall),
                                const SizedBox(height: 4),
                                Container(
                                  width: 34,
                                  height: 34,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: dueOn.isEmpty || future
                                        ? null
                                        : (doneOn == dueOn.length ? context.status.success.withValues(alpha: 0.2) : context.status.highlight),
                                    border: isSameDay(day, now) ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5) : null,
                                  ),
                                  child: Text(dueOn.isEmpty ? '–' : '$doneOn/${dueOn.length}', style: Theme.of(context).textTheme.labelSmall),
                                ),
                              ]),
                            ),
                          );
                        }),
                    ]),
                  ]),
                ),
                const SizedBox(height: Space.xl),
                for (final h in active)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.s),
                    child: Builder(builder: (_) {
                      final logs = d.habitLogs.where((x) => x.habitId == h.id).map((x) => x.day).toSet();
                      final stats = HabitStats.compute(h, logs, now.subtract(const Duration(days: 29)), now);
                      return HabitCard(
                        habit: h,
                        dueToday: h.isDueOn(now),
                        doneToday: d.habitDoneOn(h.id, today),
                        subtitle: '${h.weekdays.length == 7 ? l.everyDay : (h.weekdays.toList()..sort()).map(l.weekdayShort).join('، ')}'
                            ' · ${l.streakDays(stats.streak)}',
                        onToggle: () => c.setHabitDone(h.id, today, !d.habitDoneOn(h.id, today)),
                        onOpen: () => showHabitHistory(context, ref, h.id),
                      );
                    }),
                  ),
                if (inactive.isNotEmpty) ...[
                  const SizedBox(height: Space.l),
                  SectionHeader(l.inactiveHabits),
                  for (final h in inactive)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.pause_circle_outline),
                      title: Text(h.name),
                      onTap: () => showHabitEditor(context, ref, habit: h),
                    ),
                ],
              ]),
            ),
    );
  }
}

/// Add/edit habit sheet (also used from quick add).
Future<void> showHabitEditor(BuildContext context, WidgetRef ref, {Habit? habit}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _HabitEditor(habit: habit),
  );
}

class _HabitEditor extends ConsumerStatefulWidget {
  const _HabitEditor({this.habit});
  final Habit? habit;

  @override
  ConsumerState<_HabitEditor> createState() => _HabitEditorState();
}

class _HabitEditorState extends ConsumerState<_HabitEditor> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.habit?.name ?? '');
  late final _desc = TextEditingController(text: widget.habit?.description ?? '');
  late Set<int> _days = {...(widget.habit?.weekdays ?? const {1, 2, 3, 4, 5, 6, 7})};
  late DateTime _start = widget.habit == null ? DateTime.now() : parseDayKey(widget.habit!.startDate);
  late int? _reminder = widget.habit?.reminderMinutes;
  late bool _active = widget.habit?.active ?? true;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _save() {
    final l = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    if (_days.isEmpty) {
      showSnack(context, l.errPickDays);
      return;
    }
    ref.read(dataProvider.notifier).saveHabit(Habit(
          id: widget.habit?.id ?? newId(),
          name: _name.text.trim(),
          description: _desc.text.trim(),
          weekdays: _days,
          startDate: dayKey(_start),
          reminderMinutes: _reminder,
          active: _active,
        ));
    if (_reminder != null) askForNotificationsIfUnknown(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context, use24h: ref.read(settingsProvider).use24h);
    final order = [6, 7, 1, 2, 3, 4, 5];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Form(
          key: _form,
          child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l), children: [
            Text(widget.habit == null ? l.addHabit : l.editHabit, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Space.l),
            AppTextField(label: l.habitName, controller: _name, autofocus: widget.habit == null, validator: (v) => (v ?? '').trim().isEmpty ? l.errRequired : null),
            const SizedBox(height: Space.l),
            AppTextField(label: l.descriptionOptional, controller: _desc),
            const SizedBox(height: Space.l),
            Text(l.repeatDays, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Space.s),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final d in order)
                FilterChip(
                  label: Text(l.weekdayShort(d)),
                  selected: _days.contains(d),
                  showCheckmark: false,
                  onSelected: (v) => setState(() => _days = v ? {..._days, d} : ({..._days}..remove(d))),
                ),
            ]),
            const SizedBox(height: Space.l),
            DatePickerField(label: l.startDate, value: _start, fmt: fmt, clearable: false, onChanged: (v) => setState(() => _start = v ?? _start)),
            const SizedBox(height: Space.l),
            TimePickerField(label: l.reminderTimeOptional, minutes: _reminder, fmt: fmt, onChanged: (v) => setState(() => _reminder = v)),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(l.active), value: _active, onChanged: (v) => setState(() => _active = v)),
            const SizedBox(height: Space.m),
            PrimaryButton(label: l.save, onPressed: _save),
            if (widget.habit != null) ...[
              const SizedBox(height: Space.s),
              TextButton(
                onPressed: () async {
                  if (await confirmDialog(context, title: l.deleteHabitTitle, message: l.deleteHabitBody, confirmLabel: l.delete)) {
                    ref.read(dataProvider.notifier).deleteHabit(widget.habit!.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                child: Text(l.delete),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

/// History: past 5 weeks; non-due days are neutral; past days can be
/// corrected; future days are disabled.
Future<void> showHabitHistory(BuildContext context, WidgetRef ref, String habitId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) => Consumer(builder: (context, ref, _) {
      final l = AppLocalizations.of(context);
      final d = ref.watch(dataProvider);
      final h = d.habit(habitId);
      if (h == null) return const SizedBox.shrink();
      final now = ref.read(clockProvider)();
      final fmt = Fmt.of(context);
      final logs = d.habitLogs.where((x) => x.habitId == h.id).map((x) => x.day).toSet();
      final s30 = HabitStats.compute(h, logs, now.subtract(const Duration(days: 29)), now);
      final gridStart = startOfWeek(now, d.settings.weekStart).subtract(const Duration(days: 28));
      final c = ref.read(dataProvider.notifier);
      return SafeArea(
        child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l), children: [
          Row(children: [
            Expanded(child: Text(h.name, style: Theme.of(context).textTheme.titleLarge)),
            TextButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(l.edit),
              onPressed: () {
                Navigator.pop(sheet);
                showHabitEditor(context, ref, habit: h);
              },
            ),
          ]),
          const SizedBox(height: Space.m),
          Row(children: [
            Expanded(child: _Metric(l.adherence30, s30.adherence == null ? '—' : '${(s30.adherence! * 100).round()}%')),
            Expanded(child: _Metric(l.doneDays, '${s30.doneDays}/${s30.dueDays}')),
            Expanded(child: _Metric(l.currentStreak, '${s30.streak}')),
          ]),
          const SizedBox(height: Space.l),
          Text(l.historyHint, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: Space.s),
          Row(children: [
            for (var i = 0; i < 7; i++)
              Expanded(child: Center(child: Text(fmt.weekdayShort(gridStart.add(Duration(days: i))), style: Theme.of(context).textTheme.labelSmall))),
          ]),
          for (var w = 0; w < 5; w++)
            Row(children: [
              for (var i = 0; i < 7; i++)
                Builder(builder: (context) {
                  final day = gridStart.add(Duration(days: w * 7 + i));
                  final key = dayKey(day);
                  final dueOn = h.isDueOn(day);
                  final future = day.isAfter(dateOnly(now));
                  final done = logs.contains(key);
                  final s = context.status;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Tooltip(
                        message: '${fmt.date(day)} — ${!dueOn ? l.notDue : (done ? l.statusDone : l.notLogged)}',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: future || !dueOn ? null : () => c.setHabitDone(h.id, key, !done),
                          child: Container(
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: !dueOn || future ? null : (done ? s.success.withValues(alpha: 0.25) : s.highlight),
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            ),
                            child: !dueOn
                                ? Text('·', style: TextStyle(color: s.inactive))
                                : Icon(done ? Icons.check : Icons.remove, size: 16, color: future ? s.inactive : (done ? s.success : s.textSecondary)),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ]),
          const SizedBox(height: Space.m),
          Wrap(spacing: Space.l, children: [
            _Legend(icon: Icons.check, label: l.statusDone),
            _Legend(icon: Icons.remove, label: l.notLogged),
            _Legend(text: '·', label: l.notDue),
          ]),
        ]),
      );
    }),
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
      ]);
}

class _Legend extends StatelessWidget {
  const _Legend({this.icon, this.text, required this.label});
  final IconData? icon;
  final String? text;
  final String label;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) Icon(icon, size: 14) else Text(text!),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ]);
}
