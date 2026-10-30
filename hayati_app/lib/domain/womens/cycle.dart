import 'dart:math' as math;

import '../../core/utils/dates.dart';
import '../../data/app_data.dart';
import '../../data/models/womens.dart';

/// Estimates from what the user recorded (spec 4.4): the average of the
/// last six cycles, with a range. Never stored, never presented as fact,
/// and no "safe days".

/// Gaps between starts longer than this are treated as missed logging, not
/// a cycle.
const _maxCycle = 90;
const _minCycle = 15;
const _defaultPeriod = 5;

class CycleEstimate {
  const CycleEstimate({
    required this.lengths,
    required this.cycleLength,
    required this.minLength,
    required this.maxLength,
    required this.periodLength,
    required this.fromSettings,
  });

  /// Recent cycle lengths in days, oldest first.
  final List<int> lengths;
  final int cycleLength;
  final int minLength;
  final int maxLength;
  final int periodLength;

  /// True when the length is the user's own figure, not worked out.
  final bool fromSettings;
}

/// Periods oldest first.
List<CyclePeriod> sortedPeriods(AppData d) => [...d.periods]..sort((a, b) => a.start.compareTo(b.start));

/// Lengths between consecutive starts (last [take]), skipping gaps that
/// look like missed logging.
List<int> cycleLengths(List<CyclePeriod> periods, {int take = 6}) {
  final out = <int>[];
  for (var i = 1; i < periods.length; i++) {
    final n = parseDayKey(periods[i].start).difference(parseDayKey(periods[i - 1].start)).inDays;
    if (n >= _minCycle && n <= _maxCycle) out.add(n);
  }
  return out.length > take ? out.sublist(out.length - take) : out;
}

int periodDays(CyclePeriod p) => p.end == null ? 0 : parseDayKey(p.end!).difference(parseDayKey(p.start)).inDays + 1;

/// Null while there's not enough to go on: fewer than two periods and no
/// usual length set.
CycleEstimate? estimateCycle(AppData d) {
  final periods = sortedPeriods(d);
  final h = d.settings.health;
  final lengths = cycleLengths(periods);
  final done = [for (final p in periods) if (p.end != null) periodDays(p)];
  final recent = done.length > 6 ? done.sublist(done.length - 6) : done;
  final period = recent.isNotEmpty ? (recent.reduce((a, b) => a + b) / recent.length).round() : (h.periodLength ?? _defaultPeriod);
  if (lengths.isEmpty) {
    if (periods.isEmpty || h.cycleLength == null) return null;
    final n = h.cycleLength!;
    return CycleEstimate(lengths: const [], cycleLength: n, minLength: n - 2, maxLength: n + 2, periodLength: period, fromSettings: true);
  }
  final avg = (lengths.reduce((a, b) => a + b) / lengths.length).round();
  // A single cycle says little about the spread: allow two days either way.
  final lo = math.min(lengths.reduce(math.min), avg - 2);
  final hi = math.max(lengths.reduce(math.max), avg + 2);
  return CycleEstimate(lengths: lengths, cycleLength: avg, minLength: lo, maxLength: hi, periodLength: period, fromSettings: false);
}

/// Where the user is today.
class CycleStatus {
  const CycleStatus({
    this.last,
    this.dayOfCycle,
    this.inPeriod = false,
    this.periodDay,
    this.estimate,
    this.nextStart,
    this.windowStart,
    this.windowEnd,
    this.daysLate = 0,
  });

  final CyclePeriod? last;

  /// 1 on the first day of the last period.
  final int? dayOfCycle;
  final bool inPeriod;
  final int? periodDay;
  final CycleEstimate? estimate;

  /// The most likely start of the next period, and the estimated window.
  final DateTime? nextStart;
  final DateTime? windowStart;
  final DateTime? windowEnd;

  /// Days past the end of the window (0 when not late).
  final int daysLate;

  bool get canPredict => nextStart != null;
}

/// An open period counts as going on for this many days at most; after
/// that the app asks whether it ended.
const openPeriodLimit = 10;

CycleStatus cycleStatus(AppData d, DateTime now) {
  final periods = sortedPeriods(d).where((p) => !parseDayKey(p.start).isAfter(dateOnly(now))).toList();
  if (periods.isEmpty) return const CycleStatus();
  final last = periods.last;
  final today = dateOnly(now);
  final start = parseDayKey(last.start);
  final day = today.difference(start).inDays + 1;
  final inPeriod = last.end == null ? day <= openPeriodLimit : !today.isAfter(parseDayKey(last.end!));
  final e = estimateCycle(d);
  if (e == null) return CycleStatus(last: last, dayOfCycle: day, inPeriod: inPeriod, periodDay: inPeriod ? day : null);
  final next = start.add(Duration(days: e.cycleLength));
  final ws = start.add(Duration(days: e.minLength));
  final we = start.add(Duration(days: e.maxLength));
  return CycleStatus(
    last: last,
    dayOfCycle: day,
    inPeriod: inPeriod,
    periodDay: inPeriod ? day : null,
    estimate: e,
    nextStart: next,
    windowStart: ws,
    windowEnd: we,
    daysLate: today.isAfter(we) ? today.difference(we).inDays : 0,
  );
}

enum DayMark { none, period, predicted }

/// What a calendar day shows: a recorded period day, or one in a predicted
/// period (the next [ahead] cycles only).
Map<String, DayMark> calendarMarks(AppData d, DateTime now, {int ahead = 3}) {
  final out = <String, DayMark>{};
  final today = dateOnly(now);
  for (final p in d.periods) {
    final s = parseDayKey(p.start);
    final end = p.end != null
        ? parseDayKey(p.end!)
        : (() {
            final cap = s.add(const Duration(days: openPeriodLimit - 1));
            return today.isBefore(cap) ? today : cap;
          })();
    for (var x = s; !x.isAfter(end); x = x.add(const Duration(days: 1))) {
      out[dayKey(x)] = DayMark.period;
    }
  }
  final st = cycleStatus(d, now);
  final e = st.estimate;
  if (e == null || st.nextStart == null) return out;
  var next = st.nextStart!;
  // A late period is shown from tomorrow rather than in the past.
  if (next.isBefore(today) && !st.inPeriod) next = today.add(const Duration(days: 1));
  for (var c = 0; c < ahead; c++) {
    for (var i = 0; i < e.periodLength; i++) {
      final k = dayKey(next.add(Duration(days: i)));
      if (next.add(Duration(days: i)).isAfter(today)) out.putIfAbsent(k, () => DayMark.predicted);
    }
    next = next.add(Duration(days: e.cycleLength));
  }
  return out;
}

/// Recorded cycles vary a lot, or are unusually short or long — worth a
/// general word with a doctor. Not a diagnosis; nothing is inferred.
bool irregular(CycleEstimate? e) {
  if (e == null || e.lengths.isEmpty) return false;
  if (e.lengths.any((n) => n < 21 || n > 45)) return true;
  return e.lengths.length >= 3 && e.lengths.reduce(math.max) - e.lengths.reduce(math.min) > 9;
}

class SymptomStat {
  const SymptomStat(this.symptom, this.count, this.typicalDay);
  final Symptom symptom;
  final int count;

  /// The average day of the cycle it was logged on, when known.
  final int? typicalDay;
}

/// The day of the cycle [day] falls on, from the period that started last
/// before it.
int? cycleDayOf(List<CyclePeriod> sorted, String day) {
  CyclePeriod? p;
  for (final x in sorted) {
    if (x.start.compareTo(day) <= 0) p = x;
  }
  if (p == null) return null;
  final n = parseDayKey(day).difference(parseDayKey(p.start)).inDays + 1;
  return n <= _maxCycle ? n : null;
}

/// Most often logged symptoms, most frequent first.
List<SymptomStat> symptomStats(AppData d) {
  final sorted = sortedPeriods(d);
  final days = <Symptom, List<int>>{};
  final counts = <Symptom, int>{};
  for (final log in d.cycleLogs) {
    final cd = cycleDayOf(sorted, log.day);
    for (final s in log.symptoms) {
      counts[s] = (counts[s] ?? 0) + 1;
      if (cd != null) (days[s] ??= []).add(cd);
    }
  }
  final out = [
    for (final e in counts.entries)
      SymptomStat(e.key, e.value, days[e.key] == null ? null : (days[e.key]!.reduce((a, b) => a + b) / days[e.key]!.length).round()),
  ]..sort((a, b) => b.count != a.count ? b.count.compareTo(a.count) : a.symptom.index.compareTo(b.symptom.index));
  return out;
}

/// Each recorded cycle's length with its start, oldest first, for the chart.
List<(String, int)> cycleHistory(AppData d) {
  final p = sortedPeriods(d);
  return [
    for (var i = 1; i < p.length; i++)
      if (parseDayKey(p[i].start).difference(parseDayKey(p[i - 1].start)).inDays case final n when n >= _minCycle && n <= _maxCycle)
        (p[i - 1].start, n),
  ];
}

/// The next appointment from [now] on, if any.
HealthAppointment? nextAppointment(AppData d, DateTime now) {
  final up = d.appointments.where((a) => !a.at.isBefore(now)).toList()..sort((a, b) => a.at.compareTo(b.at));
  return up.firstOrNull;
}
