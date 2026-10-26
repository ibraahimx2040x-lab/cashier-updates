import '../core/utils/dates.dart';
import '../data/app_data.dart';
import '../data/data_controller.dart';
import '../data/models/misc.dart';
import '../l10n/app_localizations.dart';

/// Turns due reminders into in-app notifications (screen 18).
///
/// Runs on app start and periodically while the app is open. Each reminder
/// has a dedupe key so it is delivered once, even across restarts.
/// OS-level push / local notifications are a platform integration that is
/// not part of local mode (see docs/ROADMAP.md).
List<AppNotification> dueReminders(AppData d, DateTime now, AppLocalizations l) {
  final out = <AppNotification>[];
  // Ignore reminders that expired more than a day ago.
  final horizon = now.subtract(const Duration(days: 1));

  for (final t in d.tasks) {
    final r = t.reminderAt;
    if (r == null || !t.isOpen || t.archived) continue;
    if (r.isAfter(now) || r.isBefore(horizon)) continue;
    out.add(AppNotification(
      id: newId(),
      type: NotificationType.task,
      title: l.notifTaskTitle(t.title),
      body: t.dueAt == null ? '' : l.notifDue,
      createdAt: now,
      refId: t.id,
      dedupeKey: 'task:${t.id}:${encodeInstant(r)}',
    ));
  }
  for (final e in d.events) {
    final m = e.reminderMinutesBefore;
    if (m == null) continue;
    final at = e.start.subtract(Duration(minutes: m));
    if (at.isAfter(now) || at.isBefore(horizon) || e.start.isBefore(now.subtract(const Duration(hours: 1)))) {
      continue;
    }
    out.add(AppNotification(
      id: newId(),
      type: NotificationType.event,
      title: l.notifEventTitle(e.title),
      body: l.notifEventBody(m),
      createdAt: now,
      refId: e.id,
      dedupeKey: 'event:${e.id}:${encodeInstant(e.start)}:$m',
    ));
  }
  final today = dayKey(now);
  for (final h in d.habits) {
    final m = h.reminderMinutes;
    if (m == null || !h.isDueOn(now) || d.habitDoneOn(h.id, today)) continue;
    if (atMinutes(now, m).isAfter(now)) continue;
    out.add(AppNotification(
      id: newId(),
      type: NotificationType.habit,
      title: l.notifHabitTitle(h.name),
      createdAt: now,
      refId: h.id,
      dedupeKey: 'habit:${h.id}:$today',
    ));
  }
  return out;
}

void syncReminders(DataController c, DateTime now, AppLocalizations l) {
  for (final n in dueReminders(c.snapshot, now, l)) {
    c.notify(n);
  }
}
