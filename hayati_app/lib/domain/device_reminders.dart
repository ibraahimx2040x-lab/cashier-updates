import '../core/router/route_paths.dart';
import '../core/utils/dates.dart';
import '../data/app_data.dart';
import '../core/utils/labels.dart';
import '../data/models/health.dart';
import '../data/models/prayer.dart';
import '../l10n/app_localizations.dart';
import 'activity.dart';
import 'prayer_times.dart';

/// One reminder for the phone's notification system.
class DeviceReminder {
  const DeviceReminder({required this.id, required this.at, required this.title, this.body = '', required this.route});

  /// Stable across reschedules (derived from the reminder's dedupe key), so
  /// re-planning replaces rather than duplicates.
  final int id;
  final DateTime at;
  final String title;
  final String body;

  /// Where tapping the notification opens.
  final String route;
}

/// iOS keeps at most 64 pending notifications per app; stay below it.
const maxScheduled = 60;

/// Reminders to schedule on the device from [d], soonest first: task
/// reminders, event reminders, each due day's habit reminder within
/// [horizonDays], and prayer times (plus the optional early reminder) for
/// [prayerDays] days. Past times, finished tasks and habits already logged
/// today are skipped.
List<DeviceReminder> planDeviceReminders(AppData d, DateTime now, AppLocalizations l,
    {int horizonDays = 14, int prayerDays = 2}) {
  final out = <DeviceReminder>[];
  final until = now.add(Duration(days: horizonDays));
  bool inWindow(DateTime t) => t.isAfter(now) && t.isBefore(until);

  for (final t in d.tasks) {
    final r = t.reminderAt;
    if (r == null || !t.isOpen || t.archived || !inWindow(r)) continue;
    out.add(DeviceReminder(
      id: stableId('task:${t.id}:${encodeInstant(r)}'),
      at: r,
      title: l.notifTaskTitle(t.title),
      body: t.dueAt == null ? '' : l.notifDue,
      route: Routes.task(t.id),
    ));
  }
  for (final e in d.events) {
    final m = e.reminderMinutesBefore;
    if (m == null) continue;
    final at = e.start.subtract(Duration(minutes: m));
    if (!inWindow(at)) continue;
    out.add(DeviceReminder(
      id: stableId('event:${e.id}:${encodeInstant(e.start)}:$m'),
      at: at,
      title: l.notifEventTitle(e.title),
      body: l.notifEventBody(m),
      route: Routes.event(e.id),
    ));
  }
  final today = dateOnly(now);
  for (final h in d.habits) {
    final m = h.reminderMinutes;
    if (m == null || !h.active) continue;
    for (var i = 0; i <= horizonDays; i++) {
      final day = today.add(Duration(days: i));
      if (!h.isDueOn(day) || d.habitDoneOn(h.id, dayKey(day))) continue;
      final at = atMinutes(day, m);
      if (!inWindow(at)) continue;
      out.add(DeviceReminder(
        id: stableId('habit:${h.id}:${dayKey(day)}'),
        at: at,
        title: l.notifHabitTitle(h.name),
        route: Routes.habits,
      ));
    }
  }
  final ps = d.settings.prayer;
  if (ps.active && ps.notify) {
    for (var i = 0; i < prayerDays; i++) {
      final day = prayerDay(ps, today.add(Duration(days: i)))!;
      for (final p in Prayer.values) {
        final at = day[p];
        final key = 'prayer:${dayKey(day.day)}:${p.name}';
        if (inWindow(at)) {
          out.add(DeviceReminder(id: stableId(key), at: at, title: l.notifPrayerTitle(l.prayerName(p)), route: Routes.prayer));
        }
        final early = at.subtract(Duration(minutes: ps.remindBefore));
        if (ps.remindBefore > 0 && inWindow(early)) {
          out.add(DeviceReminder(
            id: stableId('$key:before'),
            at: early,
            title: l.notifPrayerSoon(l.prayerName(p), ps.remindBefore),
            route: Routes.prayer,
          ));
        }
      }
    }
  }
  final h = d.settings.health;
  if (h.moveReminders && h.has(HealthModule.activity) && h.moveEvery >= 30 && h.moveEnd > h.moveStart) {
    // Today's reminders stop once the step goal is reached.
    final doneToday = activityDay(d, dayKey(today)).steps >= h.stepGoal;
    for (var i = doneToday ? 1 : 0; i < prayerDays; i++) {
      final day = today.add(Duration(days: i));
      for (var m = h.moveStart; m <= h.moveEnd; m += h.moveEvery) {
        final at = day.add(Duration(minutes: m));
        if (!inWindow(at)) continue;
        out.add(DeviceReminder(
          id: stableId('move:${dayKey(day)}:$m'),
          at: at,
          title: l.notifMoveTitle,
          body: l.notifMoveBody,
          route: Routes.activity,
        ));
      }
    }
  }
  out.sort((a, b) => a.at.compareTo(b.at));
  return out.take(maxScheduled).toList();
}

/// FNV-1a hash folded to a positive 31-bit int (Android notification ids
/// are 32-bit signed).
int stableId(String key) {
  var h = 0x811c9dc5;
  for (final c in key.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xffffffff;
  }
  return h & 0x7fffffff;
}
