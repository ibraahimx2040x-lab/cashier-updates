import '../core/utils/dates.dart';
import '../data/app_data.dart';
import '../data/data_controller.dart';
import '../data/models/accountability.dart';
import '../data/models/misc.dart';
import '../l10n/app_localizations.dart';

/// Rules whose grace period has run out: an active rule on an open task
/// whose deadline is [AccountabilityRule.graceDays] or more days past, and
/// that hasn't already been triggered for that same deadline.
List<AccountabilityEvent> dueAccountability(AppData d, DateTime now) {
  final today = dateOnly(now);
  final out = <AccountabilityEvent>[];
  for (final r in d.accountabilityRules) {
    if (!r.active) continue;
    final t = d.task(r.taskId);
    if (t == null || !t.isOpen || t.archived || t.dueDate == null) continue;
    final due = parseDayKey(t.dueDate!);
    if (today.difference(due).inDays < r.graceDays) continue;
    if (d.accountabilityEvents.any((e) => e.ruleId == r.id && e.dueDate == t.dueDate)) continue;
    out.add(AccountabilityEvent(
      id: newId(),
      ruleId: r.id,
      taskId: t.id,
      dueDate: t.dueDate!,
      triggeredOn: dayKey(today),
    ));
  }
  return out;
}

/// Records newly triggered events and tells the user in the notification
/// centre. Returns the new notifications.
List<AppNotification> syncAccountability(DataController c, DateTime now, AppLocalizations l) {
  final out = <AppNotification>[];
  for (final e in dueAccountability(c.snapshot, now)) {
    c.addAccountabilityEvent(e);
    final n = AppNotification(
      id: newId(),
      type: NotificationType.accountability,
      title: l.notifAccountability(c.snapshot.task(e.taskId)?.title ?? ''),
      body: l.notifAccountabilityBody,
      createdAt: now,
      refId: e.id,
      dedupeKey: 'accountability:${e.ruleId}:${e.dueDate}',
    );
    if (c.notify(n)) out.add(n);
  }
  return out;
}

/// The default new deadline offered when rescheduling.
String suggestedNewDue(DateTime now) => dayKey(dateOnly(now).add(const Duration(days: 3)));
