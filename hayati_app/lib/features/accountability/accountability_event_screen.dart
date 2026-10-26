import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/accountability.dart';
import '../../data/models/task.dart';
import '../../domain/accountability.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';

/// A late task: first why, then what follows. Only a deliberate
/// postponement brings the agreed consequence; nothing changes until the
/// user confirms.
class AccountabilityEventScreen extends ConsumerStatefulWidget {
  const AccountabilityEventScreen({super.key, required this.eventId});
  final String eventId;

  @override
  ConsumerState<AccountabilityEventScreen> createState() => _AccountabilityEventScreenState();
}

class _AccountabilityEventScreenState extends ConsumerState<AccountabilityEventScreen> {
  DelayReason? _reason;
  late String _newDue = suggestedNewDue(ref.read(clockProvider)());
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// The agreed consequence as a small task for today.
  Task? _consequenceTask(AccountabilityRule rule, Task task, AppLocalizations l) {
    final data = ref.read(dataProvider.notifier);
    final today = dayKey(ref.read(clockProvider)());
    final (title, minutes) = switch (rule.consequence) {
      Consequence.extraReview => (l.conTaskReview(task.title), 20),
      Consequence.planningSession => (l.conTaskPlanning(task.title), 15),
      Consequence.firstStepFirst => (l.conTaskFirstStep(task.title), 15),
      Consequence.custom => (rule.customText, null),
    };
    return data.newTask(title: title, dueDate: today, estimatedMinutes: minutes, priority: Priority.medium);
  }

  void _confirm(AccountabilityEvent e, AccountabilityRule? rule, Task? task) {
    final l = AppLocalizations.of(context);
    ref.read(dataProvider.notifier).resolveAccountability(
          e.id,
          _reason!,
          newDueDate: _reason == DelayReason.notImportant ? null : _newDue,
          note: _note.text.trim(),
          consequenceTask: _reason == DelayReason.postponed && rule != null && task != null ? _consequenceTask(rule, task, l) : null,
        );
    showSnack(context, l.accSaved);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final e = d.accountabilityEvent(widget.eventId);
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    if (e == null) return Scaffold(appBar: AppBar(), body: EmptyState(icon: Icons.search_off, title: l.itemGone));
    final task = d.task(e.taskId);
    final rule = d.rule(e.ruleId);
    final now = ref.watch(clockProvider)();
    final late = dateOnly(now).difference(parseDayKey(e.dueDate)).inDays;

    if (!e.pending) {
      final rows = [
        (Icons.event_busy, l.accMissedOn(fmt.day(e.dueDate))),
        (Icons.help_outline, l.delayReason(e.reason!)),
        (Icons.flag_outlined, l.eventOutcome(e.outcome)),
        if (e.newDueDate != null) (Icons.event_available, l.accNewDue(fmt.day(e.newDueDate!))),
        if (e.resolvedAt != null) (Icons.check, l.accAnsweredOn(fmt.date(e.resolvedAt!))),
        if (e.note.isNotEmpty) (Icons.notes, e.note),
      ];
      return Scaffold(
        appBar: AppBar(title: Text(l.navAccountability)),
        body: ResponsiveContainer(
          maxWidth: 720,
          child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
            FadeSlideIn(
              child: AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(task?.title ?? l.itemGone, style: t.titleMedium),
                  const SizedBox(height: Space.m),
                  for (final (icon, text) in rows)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.s),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(icon, size: 18, color: context.status.textSecondary),
                        const SizedBox(width: Space.s),
                        Expanded(child: Text(text, style: t.bodyMedium)),
                      ]),
                    ),
                ]),
              ),
            ),
            if (task != null) ...[
              const SizedBox(height: Space.m),
              OutlinedButton.icon(
                onPressed: () => context.push(Routes.task(task.id)),
                icon: const Icon(Icons.open_in_new),
                label: Text(l.accOpenTask),
              ),
            ],
          ]),
        ),
      );
    }

    final reasonCards = [
      for (final (r, icon) in [
        (DelayReason.postponed, Icons.schedule),
        (DelayReason.emergency, Icons.warning_amber),
        (DelayReason.illness, Icons.healing_outlined),
        (DelayReason.notImportant, Icons.remove_circle_outline),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: Space.s),
          child: AppCard(
            color: _reason == r ? context.status.highlight : null,
            onTap: () => setState(() => _reason = r),
            child: Row(children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: Space.m),
              Expanded(child: Text(l.delayReason(r), style: t.titleSmall)),
              if (_reason == r) Icon(Icons.check_circle, color: context.status.success),
            ]),
          ),
        ),
    ];

    final next = switch (_reason) {
      null => const SizedBox.shrink(),
      DelayReason.postponed => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AppCard(
            color: context.status.highlight,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.accAgreedConsequence, style: t.labelMedium),
              const SizedBox(height: Space.xs),
              Text(rule == null ? l.accRuleRemoved : l.consequence(rule.consequence, custom: rule.customText), style: t.titleSmall),
              const SizedBox(height: Space.xs),
              Text(l.accConsequenceAsTask, style: t.bodySmall),
            ]),
          ),
          const SizedBox(height: Space.m),
          Text(l.accMakeupPlan, style: t.titleSmall),
        ]),
      DelayReason.emergency || DelayReason.illness => AppCard(
          child: Text(_reason == DelayReason.illness ? l.accIllnessNote : l.accEmergencyNote),
        ),
      DelayReason.notImportant => AppCard(child: Text(l.accDropNote)),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.navAccountability)),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 120),
          children: [
            FadeSlideIn(
              child: Container(
                padding: const EdgeInsets.all(Space.xl),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Radii.sheet),
                  gradient: const LinearGradient(colors: [AppColors.deepGreen, AppColors.midGreen]),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(task?.title ?? l.itemGone, style: t.headlineSmall?.copyWith(color: Colors.white)),
                  const SizedBox(height: Space.xs),
                  Text(l.accLateBy(late, fmt.day(e.dueDate)), style: t.bodyMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: Space.s),
                  Text(l.accNoBlame, style: t.bodySmall?.copyWith(color: Colors.white70)),
                ]),
              ),
            ),
            const SizedBox(height: Space.xl),
            SectionHeader(l.accWhy),
            ...reasonCards,
            const SizedBox(height: Space.l),
            SmoothSwitcher(childKey: _reason ?? 'none', child: next),
            if (_reason != null && _reason != DelayReason.notImportant) ...[
              const SizedBox(height: Space.m),
              DatePickerField(
                label: l.accNewDeadline,
                value: parseDayKey(_newDue),
                fmt: fmt,
                clearable: false,
                firstDate: dateOnly(now),
                onChanged: (v) => setState(() => _newDue = v == null ? _newDue : dayKey(v)),
              ),
            ],
            if (_reason != null) ...[
              const SizedBox(height: Space.m),
              TextField(controller: _note, maxLength: 2000, decoration: InputDecoration(labelText: l.accNote)),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.l),
          child: ResponsiveContainer(
            maxWidth: 720,
            child: PrimaryButton(
              label: _reason == DelayReason.notImportant ? l.accCloseTask : l.accConfirm,
              onPressed: _reason == null ? null : () => _confirm(e, rule, task),
            ),
          ),
        ),
      ),
    );
  }
}
