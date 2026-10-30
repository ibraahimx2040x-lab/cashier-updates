import '../core/router/route_paths.dart';
import '../core/utils/dates.dart';
import '../data/app_data.dart';
import '../core/utils/labels.dart';
import '../data/models/health.dart';
import '../data/models/prayer.dart';
import '../l10n/app_localizations.dart';
import '../data/models/alarm.dart';
import '../data/models/goal.dart';
import '../data/models/money.dart';
import '../data/models/settings.dart';
import '../data/models/task.dart';
import 'activity.dart';
import 'fitness/today.dart';
import 'learning/path.dart';
import 'money.dart';
import 'prayer_times.dart';
import 'womens/cycle.dart';

/// One reminder for the phone's notification system.
class DeviceReminder {
  const DeviceReminder({required this.id, required this.at, required this.title, this.body = '', required this.route, this.alarm});

  /// Stable across reschedules (derived from the reminder's dedupe key), so
  /// re-planning replaces rather than duplicates.
  final int id;
  final DateTime at;
  final String title;
  final String body;

  /// Where tapping the notification opens.
  final String route;

  /// Set for a sounding alarm (not a quiet notification).
  final Alarm? alarm;
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
  final notify = d.settings.notify;

  for (final t in notify.on(NotifySection.tasks) ? d.tasks : const <Task>[]) {
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
  for (final e in notify.on(NotifySection.events) ? d.events : const <CalendarEvent>[]) {
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
  for (final h in notify.on(NotifySection.habits) ? d.habits : const <Habit>[]) {
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
  // Time to wind down, every night it's set.
  final bed = h.bedtimeReminder;
  if (bed != null && h.has(HealthModule.sleep)) {
    for (var i = 0; i < prayerDays; i++) {
      final day = today.add(Duration(days: i));
      final at = atMinutes(day, bed);
      if (!inWindow(at)) continue;
      out.add(DeviceReminder(
        id: stableId('bedtime:${dayKey(day)}:$bed'),
        at: at,
        title: l.notifBedtimeTitle,
        body: l.notifBedtimeBody,
        route: Routes.sleep,
      ));
    }
  }
  // Health appointments: the time only, never the title, on a lock screen.
  if (h.has(HealthModule.womens) || h.has(HealthModule.mens)) {
    for (final a in d.appointments) {
      final m = a.reminderMinutes;
      if (m == null) continue;
      final at = a.at.subtract(Duration(minutes: m));
      if (!inWindow(at)) continue;
      out.add(DeviceReminder(
        id: stableId('appointment:${a.id}:${encodeInstant(a.at)}:$m'),
        at: at,
        title: l.notifAppointmentTitle,
        body: l.notifEventBody(m),
        route: Routes.appointments,
      ));
    }
  }
  // Two days before the estimated window, worded so it gives nothing away.
  if (h.cycleReminders && d.settings.sex == Sex.female && h.has(HealthModule.womens)) {
    final st = cycleStatus(d, now);
    if (st.windowStart != null && !st.inPeriod) {
      final day = dateOnly(st.windowStart!).subtract(const Duration(days: 2));
      final at = day.add(const Duration(hours: 9));
      if (inWindow(at)) {
        out.add(DeviceReminder(
          id: stableId('cycle:${dayKey(day)}'),
          at: at,
          title: l.notifNeutralTitle,
          body: l.notifNeutralBody,
          route: Routes.womens,
        ));
      }
    }
  }
  out.addAll(_sectionReminders(d, now, l, today, prayerDays, inWindow));
  out.sort((a, b) => a.at.compareTo(b.at));
  // Alarms always get their place, whatever else is scheduled.
  final alarms = planAlarms(d, now, l);
  return [...alarms, ...out.take(maxScheduled - alarms.length)]..sort((a, b) => a.at.compareTo(b.at));
}

/// Every ring of every alarm in the next week (and a pending snooze).
List<DeviceReminder> planAlarms(AppData d, DateTime now, AppLocalizations l) => [
      for (final a in d.alarms)
        for (final at in a.nextRings(now))
          DeviceReminder(
            id: stableId('alarm:${a.id}:${encodeInstant(at)}'),
            at: at,
            title: a.label.isNotEmpty ? a.label : l.alarmDefaultTitle,
            body: l.alarmBody,
            route: a.taskId != null ? Routes.task(a.taskId!) : (a.eventId != null ? Routes.event(a.eventId!) : Routes.alarms),
            alarm: a,
          ),
    ].take(20).toList();

/// The daily reminders of sections that have no time of their own (v4
/// change 14): goals near their date, workout days, water, the day's
/// lesson, and monthly money items on the day they're due. Each stops once
/// what it asks for is done, and each has its own switch and time.
List<DeviceReminder> _sectionReminders(
    AppData d, DateTime now, AppLocalizations l, DateTime today, int days, bool Function(DateTime) inWindow) {
  final out = <DeviceReminder>[];
  final n = d.settings.notify;
  DateTime at(DateTime day, NotifySection s) => atMinutes(day, n.timeOf(s));

  if (n.on(NotifySection.goals)) {
    for (final g in d.goals.where((g) => g.status == GoalStatus.active && g.targetDate != null)) {
      final target = parseDayKey(g.targetDate!);
      for (final (before, title) in [(3, l.notifGoalSoon(g.title, 3)), (0, l.notifGoalToday(g.title))]) {
        final t = at(target.subtract(Duration(days: before)), NotifySection.goals);
        if (!inWindow(t)) continue;
        out.add(DeviceReminder(id: stableId('goal:${g.id}:${g.targetDate}:$before'), at: t, title: title, route: Routes.goal(g.id)));
      }
    }
  }
  for (var i = 0; i < days; i++) {
    final day = today.add(Duration(days: i));
    final key = dayKey(day);
    if (n.on(NotifySection.fitness) && d.sessionsOn(key).isEmpty) {
      final w = todaysWorkout(d, day);
      final t = at(day, NotifySection.fitness);
      if (w != null && inWindow(t)) {
        out.add(DeviceReminder(
          id: stableId('fitness:$key'),
          at: t,
          title: l.notifWorkoutTitle,
          body: l.notifWorkoutBody(w.$2.minutes, l.workoutPlace(w.$1.place)),
          route: Routes.fitness,
        ));
      }
    }
    final h = d.settings.health;
    if (n.on(NotifySection.water) && h.has(HealthModule.nutrition) && d.waterOn(key) < h.waterGoalMl) {
      final t = at(day, NotifySection.water);
      if (inWindow(t)) {
        out.add(DeviceReminder(id: stableId('water:$key'), at: t, title: l.notifWaterTitle, body: l.notifWaterBody, route: Routes.nutrition));
      }
    }
    if (n.on(NotifySection.learning) && d.learningPath != null && !(i == 0 && lessonDoneToday(d, now))) {
      final lesson = nextLesson(d);
      final t = at(day, NotifySection.learning);
      if (lesson != null && inWindow(t)) {
        out.add(DeviceReminder(
          id: stableId('lesson:$key'),
          at: t,
          title: l.notifLessonTitle,
          body: l.localeName == 'ar' ? lesson.titleAr : lesson.titleEn,
          route: Routes.english,
        ));
      }
    }
    if (n.on(NotifySection.money) && d.settings.has(AppModule.expenses)) {
      for (final r in d.recurring.where((r) => r.active)) {
        if (dueIn(DateTime(day.year, day.month), r.dayOfMonth) != day) continue;
        if (r.endsOn != null && key.compareTo(r.endsOn!) > 0 || key.compareTo(r.startsOn) < 0) continue;
        final t = at(day, NotifySection.money);
        if (!inWindow(t)) continue;
        out.add(DeviceReminder(
          id: stableId('money:${r.id}:$key'),
          at: t,
          title: l.notifMoneyDue(r.title.isNotEmpty ? r.title : (r.kind == RecurringKind.expense ? l.expenseCategory(r.category) : l.monthlyIncome)),
          body: '${(r.amountMinor / 100).toStringAsFixed(r.amountMinor % 100 == 0 ? 0 : 2)} ${r.currency}',
          route: Routes.expenses,
        ));
      }
    }
  }
  return out;
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
