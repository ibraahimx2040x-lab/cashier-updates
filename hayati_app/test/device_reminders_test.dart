import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/models/goal.dart';
import 'package:hayati/data/models/health.dart';
import 'package:hayati/data/models/money.dart';
import 'package:hayati/data/models/nutrition.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/data/models/task.dart';
import 'package:hayati/domain/device_reminders.dart';
import 'package:hayati/l10n/app_localizations.dart';

void main() {
  final now = DateTime(2026, 3, 10, 9); // Tuesday
  final l = lookupAppLocalizations(const Locale('ar'));
  Task task(String id, {DateTime? reminder, TaskStatus status = TaskStatus.todo}) => Task(
        id: id,
        title: id,
        reminderAt: reminder,
        status: status,
        completedAt: status == TaskStatus.done ? now : null,
        createdAt: now,
        updatedAt: now,
      );

  test('future task reminders only, open tasks only, soonest first', () {
    final d = AppData(tasks: [
      task('later', reminder: now.add(const Duration(hours: 5))),
      task('soon', reminder: now.add(const Duration(hours: 1))),
      task('past', reminder: now.subtract(const Duration(minutes: 1))),
      task('done', reminder: now.add(const Duration(hours: 2)), status: TaskStatus.done),
      task('far', reminder: now.add(const Duration(days: 30))),
    ]);
    final r = planDeviceReminders(d, now, l);
    expect(r.map((x) => x.route), ['/task/soon', '/task/later']);
    expect(r.first.title, contains('soon'));
  });

  test('event reminder fires before the start', () {
    final d = AppData(events: [
      CalendarEvent(id: 'e', title: 'محاضرة', start: DateTime(2026, 3, 10, 13), end: DateTime(2026, 3, 10, 14), reminderMinutesBefore: 30, updatedAt: now),
    ]);
    final r = planDeviceReminders(d, now, l).single;
    expect(r.at, DateTime(2026, 3, 10, 12, 30));
    expect(r.route, '/event/e');
  });

  test('habit reminders on due days only, skipping a day already logged', () {
    // Tuesday (2) and Thursday (4), 08:00 and 20:00.
    const h = Habit(id: 'h', name: 'مشي', weekdays: {2, 4}, startDate: '2026-01-01', reminderMinutes: 20 * 60);
    final d = AppData(habits: const [h], habitLogs: const [HabitLog(id: 'l', habitId: 'h', day: '2026-03-12')]);
    final r = planDeviceReminders(d, now, l, horizonDays: 8);
    // Tue 10 20:00 (today, still ahead), Thu 12 logged → skipped, Tue 17 20:00.
    expect(r.map((x) => x.at), [DateTime(2026, 3, 10, 20), DateTime(2026, 3, 17, 20)]);
  });

  test('ids are stable and the list is capped for iOS', () {
    final d = AppData(tasks: [for (var i = 0; i < 80; i++) task('t$i', reminder: now.add(Duration(minutes: i + 1)))]);
    final a = planDeviceReminders(d, now, l), b = planDeviceReminders(d, now, l);
    expect(a.length, maxScheduled);
    expect(a.map((x) => x.id), b.map((x) => x.id));
    expect(a.map((x) => x.id).toSet().length, a.length);
    expect(stableId('x'), inInclusiveRange(0, 0x7fffffff));
  });

  group('section notifications (v4 change 14)', () {
    test('a section switched off sends nothing; the others keep theirs', () {
      final d = AppData(tasks: [task('t', reminder: now.add(const Duration(hours: 1)))]);
      expect(planDeviceReminders(d, now, l), hasLength(1));
      final off = d.copyWith(settings: const UserSettings(notify: NotificationPrefs(off: {NotifySection.tasks, NotifySection.water})));
      expect(planDeviceReminders(off, now, l), isEmpty);
    });

    test('goals three days before and on the day, at the chosen time', () {
      final g = Goal(id: 'g', title: 'نصف ماراثون', targetDate: '2026-03-14', createdAt: now, updatedAt: now);
      final d = AppData(goals: [g], settings: const UserSettings(notify: NotificationPrefs(off: {}, times: {NotifySection.goals: 8 * 60})));
      final r = planDeviceReminders(d, now, l).where((x) => x.route == '/goal/g').toList();
      expect(r.map((x) => x.at), [DateTime(2026, 3, 11, 8), DateTime(2026, 3, 14, 8)]);
    });

    test('water only below the goal, and off unless turned on', () {
      const health = HealthSettings(modules: {HealthModule.nutrition}, waterGoalMl: 2000);
      final d = AppData(settings: const UserSettings(health: health));
      expect(planDeviceReminders(d, now, l).where((x) => x.title == l.notifWaterTitle), isEmpty, reason: 'off by default');
      final on = AppData(
        settings: const UserSettings(health: health, notify: NotificationPrefs(off: {})),
        water: const [WaterDay(id: 'w', day: '2026-03-10', ml: 2000)],
      );
      final r = planDeviceReminders(on, now, l).where((x) => x.title == l.notifWaterTitle).map((x) => x.at).toList();
      expect(r, [DateTime(2026, 3, 11, 13)], reason: "today's goal is met; tomorrow's isn't yet");
    });

    test('a monthly expense on the day it is due', () {
      final d = AppData(recurring: [
        RecurringItem(id: 'rent', kind: RecurringKind.expense, amountMinor: 150000, currency: 'SAR', title: 'الإيجار', dayOfMonth: 11, startsOn: '2026-01-01', updatedAt: now),
      ]);
      final r = planDeviceReminders(d, now, l).where((x) => x.route == '/expenses').single;
      expect((r.at, r.title, r.body), (DateTime(2026, 3, 11, 9), l.notifMoneyDue('الإيجار'), '1500 SAR'));
    });

    test('preferences round-trip and keep defaults', () {
      const p = NotificationPrefs(off: {NotifySection.money}, times: {NotifySection.fitness: 1200});
      final back = NotificationPrefs.fromJson(p.toJson());
      expect((back.on(NotifySection.money), back.timeOf(NotifySection.fitness), back.timeOf(NotifySection.learning)), (false, 1200, 20 * 60));
      expect(const NotificationPrefs().on(NotifySection.water), isFalse);
      expect(UserSettings.fromJson(const UserSettings(notify: p).toJson()).notify.off, {NotifySection.money});
    });
  });
}
