import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/data/models/task.dart';
import 'package:hayati/domain/day_schedule.dart';

DateTime at(int h, [int m = 0, int day = 10]) => DateTime(2026, 3, day, h, m);

Task task(String id, {DateTime? planned, int? minutes, String? due, TaskStatus status = TaskStatus.todo}) => Task(
      id: id,
      title: id,
      plannedStart: planned,
      estimatedMinutes: minutes,
      dueDate: due,
      status: status,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

CalendarEvent event(String id, DateTime s, DateTime e) => CalendarEvent(id: id, title: id, start: s, end: e, updatedAt: DateTime(2026));

// Awake 7:00–23:00, no work block, no prayer times (no location).
const base = UserSettings(dayStart: 7 * 60, dayEnd: 23 * 60, workDays: {});
final morning = at(6); // before the day starts

void main() {
  test('the example: appointment 8–9 and a task 10–11 leave the rest of the day free', () {
    final d = AppData(
      settings: base,
      events: [event('dentist', at(8), at(9))],
      tasks: [task('report', planned: at(10), minutes: 60)],
    );
    final s = DaySchedule.build(d, at(0), morning);
    expect([for (final f in s.freeSlots()) (f.start.hour, f.end.hour)], [(7, 8), (9, 10), (11, 23)]);
    expect((s.busyMinutes, s.freeMinutes, s.sleepMinutes), (120, 840, 480));
    expect(s.slots.first.start, at(0));
    expect(s.slots.last.end, at(0, 0, 11), reason: 'the whole 24 hours are laid out');
    expect(s.isBusy, isFalse);
  });

  test('many tasks without a time do not make a day busy; tasks due that do not fit do', () {
    final many = AppData(settings: base, tasks: [for (var i = 0; i < 40; i++) task('t$i', minutes: 30)]);
    expect(DaySchedule.build(many, at(0), morning).isBusy, isFalse, reason: 'undated tasks take no time on this day');
    final due = AppData(settings: const UserSettings(dayStart: 8 * 60, dayEnd: 10 * 60, workDays: {}), tasks: [
      for (var i = 0; i < 3; i++) task('d$i', minutes: 60, due: '2026-03-10'),
    ]);
    final s = DaySchedule.build(due, at(0), morning);
    expect((s.dueMinutes, s.freeMinutes, s.fitsDue, s.isBusy), (180, 120, false, true));
  });

  test('done tasks free their time; sleep and the past are never free', () {
    final d = AppData(settings: base, tasks: [
      task('done', planned: at(14), minutes: 60, status: TaskStatus.done),
      task('open', planned: at(15), minutes: 30),
    ]);
    final s = DaySchedule.build(d, at(0), at(12, 30));
    expect(s.freeSlots().map((f) => (f.start, f.end)), [(at(12, 30), at(15)), (at(15, 30), at(23))]);
    expect(s.slots.where((x) => x.kind == SlotKind.past).single.minutes, 330); // 7:00–12:30
  });

  test('work days, breaks and a bedtime after midnight', () {
    const s = UserSettings(dayStart: 8 * 60, dayEnd: 25 * 60, work: TimeRange(9 * 60, 17 * 60), workDays: {2}, breaks: [TimeRange(13 * 60, 14 * 60)]);
    final tue = DaySchedule.build(const AppData(settings: s), at(0), morning); // 2026-03-10 is a Tuesday
    expect(tue.slots.where((x) => x.kind == SlotKind.work).fold(0, (a, x) => a + x.minutes), 420, reason: 'work minus the break');
    expect(tue.sleepMinutes, 8 * 60, reason: 'each day is measured on its own: midnight–8:00; staying up past midnight shows the next day');
    final wed = DaySchedule.build(const AppData(settings: s), at(0, 0, 11), morning);
    expect(wed.slots.any((x) => x.kind == SlotKind.work), isFalse);
  });

  test('clashes: two appointments, or a task over one; a prayer during work is not one', () {
    final d = AppData(settings: base, events: [event('a', at(9), at(10)), event('b', at(9, 30), at(11))], tasks: [task('t', planned: at(10, 30), minutes: 60)]);
    final s = DaySchedule.build(d, at(0), morning);
    expect([for (final c in s.clashes) '${c.a.refId}-${c.b.refId}'], ['a-b', 'b-t']);
    final hits = clashesFor(d, at(9, 45), at(10, 15), morning);
    expect(hits.map((x) => x.refId).toSet(), {'a', 'b'});
    expect(clashesFor(d, at(9, 45), at(10, 15), morning, exceptId: 'a').map((x) => x.refId), ['b']);
    expect(clashesFor(d, at(2), at(3), morning).single.kind, SlotKind.sleep);
    expect(clashesFor(d, at(12), at(13), morning), isEmpty);
  });
}
