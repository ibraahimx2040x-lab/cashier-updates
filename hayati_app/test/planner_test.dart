import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/core/utils/dates.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/data/models/task.dart';
import 'package:hayati/domain/planner.dart';

Task task(String id, {int? minutes, Priority p = Priority.medium, String? due, int? dueTime}) => Task(
      id: id,
      title: id,
      estimatedMinutes: minutes,
      priority: p,
      dueDate: due,
      dueTime: dueTime,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  final day = DateTime(2026, 3, 10);
  final morning = DateTime(2026, 3, 10, 6); // before the day starts
  const settings = UserSettings(dayStart: 8 * 60, dayEnd: 18 * 60);

  test('places tasks around a fixed event (doc example 9–13)', () {
    final event = CalendarEvent(
      id: 'e',
      title: 'Work',
      start: DateTime(2026, 3, 10, 9),
      end: DateTime(2026, 3, 10, 13),
      updatedAt: DateTime(2026),
    );
    final plan = const Planner().plan(
      day: day,
      now: morning,
      tasks: [task('a', minutes: 30), task('b', minutes: 60), task('c', minutes: 45)],
      events: [event],
      settings: settings,
    );
    expect(plan.planned, hasLength(3));
    expect(plan.unscheduled, isEmpty);
    for (final p in plan.planned) {
      expect(event.overlaps(p.start, p.end), isFalse, reason: '${p.task.id} overlaps the event');
    }
    // 8:00–9:00 free (60) + 13:00–18:00 (300) = 360
    expect(plan.freeMinutes, 360);
  });

  test('does not squeeze tasks in when the day is full', () {
    const tight = UserSettings(dayStart: 8 * 60, dayEnd: 10 * 60);
    final plan = const Planner().plan(
      day: day,
      now: morning,
      tasks: [task('a', minutes: 60, p: Priority.high), task('b', minutes: 60), task('c', minutes: 60)],
      events: const [],
      settings: tight,
    );
    expect(plan.overCapacity, isTrue);
    expect(plan.planned.map((p) => p.task.id), ['a']);
    expect(plan.unscheduled.map((u) => u.task.id), containsAll(['b', 'c']));
  });

  test('flags tasks without a duration as estimated', () {
    final plan = const Planner().plan(day: day, now: morning, tasks: [task('x')], events: const [], settings: settings);
    expect(plan.planned.single.estimated, isTrue);
    expect(plan.planned.single.end.difference(plan.planned.single.start).inMinutes, 30);
  });

  test('orders overdue, then priority', () {
    final plan = const Planner().plan(
      day: day,
      now: morning,
      tasks: [
        task('low', minutes: 10, p: Priority.low),
        task('high', minutes: 10, p: Priority.high),
        task('late', minutes: 10, p: Priority.low, due: '2026-03-01'),
      ],
      events: const [],
      settings: settings,
    );
    expect(plan.planned.map((p) => p.task.id), ['late', 'high', 'low']);
  });

  test('respects manual order and exclusions', () {
    final plan = const Planner().plan(
      day: day,
      now: morning,
      tasks: [task('a', minutes: 10), task('b', minutes: 10), task('c', minutes: 10)],
      events: const [],
      settings: settings,
      manualOrder: ['c', 'a'],
      exclude: {'b'},
    );
    expect(plan.planned.map((p) => p.task.id), ['c', 'a']);
  });

  test('ignores done, cancelled, archived and future-due tasks', () {
    final plan = const Planner().plan(
      day: day,
      now: morning,
      tasks: [
        task('done', minutes: 10).copyWith(status: TaskStatus.done),
        task('cancel', minutes: 10).copyWith(status: TaskStatus.cancelled),
        task('arch', minutes: 10).copyWith(archived: true),
        task('future', minutes: 10, due: '2026-03-20'),
      ],
      events: const [],
      settings: settings,
    );
    expect(plan.isEmpty, isTrue);
  });

  test('today starts from now, not the start of the day', () {
    final now = DateTime(2026, 3, 10, 15, 2);
    final plan = const Planner().plan(day: day, now: now, tasks: [task('a', minutes: 30)], events: const [], settings: settings);
    expect(plan.planned.single.start, DateTime(2026, 3, 10, 15, 5));
  });

  test('work block and breaks are fixed', () {
    final s = settings.copyWith(work: () => const TimeRange(9 * 60, 17 * 60), workDays: {DateTime(2026, 3, 10).weekday});
    final plan = const Planner().plan(
      day: day,
      now: morning,
      tasks: [task('a', minutes: 45), task('b', minutes: 45), task('long', minutes: 90, p: Priority.low)],
      events: const [],
      settings: s,
    );
    expect(plan.planned.map((p) => (p.task.id, p.start.hour)), [('a', 8), ('b', 17)]);
    // 120 free minutes minus 15% slack leaves no room for another 90.
    expect(plan.unscheduled.single.task.id, 'long');
    expect(plan.unscheduled.single.reason, UnscheduledReason.noTime);
  });

  test('a task longer than any free window is reported as such', () {
    final s = settings.copyWith(work: () => const TimeRange(9 * 60, 17 * 60), workDays: {DateTime(2026, 3, 10).weekday});
    final plan = const Planner(slackRatio: 0).plan(day: day, now: morning, tasks: [task('long', minutes: 90)], events: const [], settings: s);
    expect(plan.unscheduled.single.reason, UnscheduledReason.noSlotLongEnough);
  });

  test('dayKey round-trips', () {
    expect(dayKey(parseDayKey('2026-01-05')), '2026-01-05');
  });
}
