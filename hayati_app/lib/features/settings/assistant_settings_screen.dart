import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';

/// Screen 20 — each assistant capability is a separate, revocable grant.
/// Disabling the assistant never disables the rest of the app.
class AssistantSettingsScreen extends ConsumerWidget {
  const AssistantSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final p = d.settings.assistant;
    final c = ref.read(dataProvider.notifier);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final t = Theme.of(context).textTheme;
    void up(AssistantPermissions Function(AssistantPermissions) f) =>
        c.updateSettings((s) => s.copyWith(assistant: f(s.assistant)));
    Widget header(String text, [String? sub]) => Padding(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.xl, Space.gutter, Space.s),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(text, style: t.titleSmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
            if (sub != null) Text(sub, style: t.bodySmall),
          ]),
        );
    Widget sw(String title, String sub, bool v, ValueChanged<bool> f) => SwitchListTile(
          title: Text(title),
          subtitle: Text(sub),
          value: v,
          onChanged: p.enabled ? f : null,
        );
    Widget locked(String title) => ListTile(
          leading: Icon(Icons.lock_outline, color: context.status.success),
          title: Text(title),
          subtitle: Text(l.alwaysRequired),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.assistantSettings)),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: ListView(padding: const EdgeInsets.only(bottom: Space.xxl), children: [
          SwitchListTile(
            title: Text(l.enableAssistant, style: t.titleMedium),
            subtitle: Text(l.enableAssistantSub),
            value: p.enabled,
            onChanged: (v) => up((x) => x.copyWith(enabled: v)),
          ),
          header(l.autoActions, l.autoActionsSub),
          sw(l.permCreateTasks, l.permCreateTasksSub, p.autoCreateTasks, (v) => up((x) => x.copyWith(autoCreateTasks: v))),
          sw(l.permAddNotes, l.permAddNotesSub, p.autoAddNotes, (v) => up((x) => x.copyWith(autoAddNotes: v))),
          sw(l.permLogHabits, l.permLogHabitsSub, p.autoLogHabits, (v) => up((x) => x.copyWith(autoLogHabits: v))),
          sw(l.permDraftPlans, l.permDraftPlansSub, p.autoDraftPlans, (v) => up((x) => x.copyWith(autoDraftPlans: v))),
          header(l.approvals),
          sw(l.approveReschedule, l.approveRescheduleSub, p.approveReschedule, (v) => up((x) => x.copyWith(approveReschedule: v))),
          locked(l.approveDelete),
          locked(l.approveBulk),
          header(l.dataAccess, l.dataAccessSub),
          sw(l.navTasks, l.shareSub, p.shareTasks, (v) => up((x) => x.copyWith(shareTasks: v))),
          sw(l.eventsLabel, l.shareSub, p.shareEvents, (v) => up((x) => x.copyWith(shareEvents: v))),
          sw(l.navGoals, l.shareSub, p.shareGoals, (v) => up((x) => x.copyWith(shareGoals: v))),
          sw(l.navHabits, l.shareSub, p.shareHabits, (v) => up((x) => x.copyWith(shareHabits: v))),
          sw(l.navNotes, l.shareNotesSub, p.shareNotes, (v) => up((x) => x.copyWith(shareNotes: v))),
          sw(l.navExpenses, l.shareSub, p.shareExpenses, (v) => up((x) => x.copyWith(shareExpenses: v))),
          sw(l.navFitness, l.shareSub, p.shareFitness, (v) => up((x) => x.copyWith(shareFitness: v))),
          sw(l.navEnglish, l.shareSub, p.shareLearning, (v) => up((x) => x.copyWith(shareLearning: v))),
          header(l.privacyRetention),
          ListTile(
            title: Text(l.keepChats),
            trailing: DropdownButton<int>(
              value: p.retentionDays,
              underline: const SizedBox.shrink(),
              items: [
                for (final dd in const [7, 30, 90, 365]) DropdownMenuItem(value: dd, child: Text(l.daysCount(dd))),
                DropdownMenuItem(value: 0, child: Text(l.untilDeleted)),
              ],
              onChanged: (v) => up((x) => x.copyWith(retentionDays: v)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: Text(l.deleteAllChats),
            onTap: () async {
              if (await confirmDialog(context, title: l.deleteAllChats, message: l.deleteAllChatsBody, confirmLabel: l.delete)) {
                c.deleteAllConversations();
                if (context.mounted) showSnack(context, l.deleted);
              }
            },
          ),
          header(l.actionLog, l.actionLogSub),
          if (d.actionLogs.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(horizontal: Space.gutter), child: Text(l.noActions, style: t.bodySmall))
          else ...[
            for (final a in d.actionLogs.take(30))
              ListTile(
                dense: true,
                leading: Icon(a.ok ? Icons.check_circle_outline : Icons.error_outline,
                    color: a.ok ? context.status.success : Theme.of(context).colorScheme.error),
                title: Text(l.toolName(a.tool)),
                subtitle: Text('${fmt.dateTime(a.at)} · ${a.auto ? l.auto : l.approved}${a.error == null ? '' : ' · ${a.error}'}'),
              ),
            TextButton(onPressed: c.clearActionLogs, child: Text(l.clearLog)),
          ],
        ]),
      ),
    );
  }
}
