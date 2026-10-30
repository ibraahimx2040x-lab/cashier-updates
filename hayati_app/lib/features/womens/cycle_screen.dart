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
import '../../data/models/womens.dart';
import '../../domain/womens/cycle.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_surface.dart';
import 'womens_gate.dart';
import '../../widgets/home_logo.dart';

const periodColor = Color(0xFFC2185B);

/// Screen 41 — the cycle: where today falls, the next estimated period with
/// its window, a calendar of recorded and estimated days, and the periods
/// recorded so far. Estimates only; never "safe days".
class CycleScreen extends ConsumerStatefulWidget {
  const CycleScreen({super.key});

  @override
  ConsumerState<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends ConsumerState<CycleScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _act(void Function() f, String done) {
    final l = AppLocalizations.of(context);
    try {
      f();
      showSnack(context, done);
    } on ArgumentError {
      showSnack(context, l.periodInvalid);
    }
  }

  Future<void> _addPast() async {
    final l = AppLocalizations.of(context);
    final now = ref.read(clockProvider)();
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: dateOnly(now),
      helpText: l.addPastPeriod,
    );
    if (r == null || !mounted) return;
    final data = ref.read(dataProvider.notifier);
    _act(() => data.savePeriod(CyclePeriod(id: newId(), start: dayKey(r.start), end: dayKey(r.end), updatedAt: now)), l.periodSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    if (!womensVisible(s)) return const WomensUnavailable();
    return Scaffold(
      appBar: AppBar(title: Text(l.navWomens), actions: [
        IconButton(tooltip: l.cycleInsights, icon: const Icon(Icons.insights_outlined), onPressed: () => context.push(Routes.womensInsights)),
        IconButton(tooltip: l.healthPrivacy, icon: const Icon(Icons.shield_outlined), onPressed: () => context.push(Routes.healthPrivacy)), const HomeLogoButton()]),
      body: HealthLockGate(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final d = ref.watch(dataProvider);
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final data = ref.read(dataProvider.notifier);
    final st = cycleStatus(d, now);
    final today = dayKey(now);
    final marks = calendarMarks(d, now);
    final todayLog = d.cycleLog(today);
    final periods = sortedPeriods(d).reversed.toList();
    final open = d.periods.where((p) => p.end == null).firstOrNull;

    String headline() {
      if (st.last == null) return l.cycleStartTitle;
      if (st.inPeriod) return l.periodDayN(st.periodDay!);
      return l.cycleDayN(st.dayOfCycle!);
    }

    String sub() {
      if (st.last == null) return l.cycleStartBody;
      if (!st.canPredict) return l.needMoreData;
      if (st.daysLate > 0) return l.periodLateBy(st.daysLate);
      final days = st.nextStart!.difference(dateOnly(now)).inDays;
      return days <= 0 ? l.periodDueAbout : l.nextPeriodIn(days);
    }

    final children = <Widget>[
      HeroSurface(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.water_drop_outlined, color: AppColors.gold, size: 32),
          const SizedBox(height: Space.m),
          Text(headline(), style: t.headlineSmall?.copyWith(color: Colors.white)),
          const SizedBox(height: Space.xs),
          Text(sub(), style: t.bodyMedium?.copyWith(color: Colors.white70)),
          if (st.canPredict && st.daysLate == 0) ...[
            const SizedBox(height: Space.xs),
            Text(l.estimatedWindow(fmt.dateShort(st.windowStart!), fmt.dateShort(st.windowEnd!)),
                style: t.labelMedium?.copyWith(color: Colors.white70)),
          ],
          const SizedBox(height: Space.m),
          Wrap(spacing: Space.s, runSpacing: Space.s, children: [
            if (open != null && st.inPeriod)
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy),
                onPressed: () => _act(() => data.endPeriod(today), l.periodEnded),
                icon: const Icon(Icons.check),
                label: Text(l.periodEndedToday),
              )
            else
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy),
                onPressed: () => _act(() => data.startPeriod(today), l.periodStarted),
                icon: const Icon(Icons.add),
                label: Text(l.periodStartedToday),
              ),
          ]),
        ]),
      ),
      AppCard(
        onTap: () => context.push(Routes.womensDay(today)),
        child: Row(children: [
          const IconBadge(Icons.edit_note, color: periodColor),
          const SizedBox(width: Space.m),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(todayLog == null ? l.howIsToday : l.todayLogged, style: t.titleSmall),
              Text(
                todayLog == null ? l.howIsTodaySub : logSummary(l, todayLog),
                style: t.bodySmall?.copyWith(color: context.status.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
          const Icon(Icons.chevron_right),
        ]),
      ),
      _Calendar(
        month: _month,
        marks: marks,
        logged: {for (final x in d.cycleLogs) x.day},
        today: dateOnly(now),
        fmt: fmt,
        onMonth: (m) => setState(() => _month = m),
        onDay: (day) => context.push(Routes.womensDay(dayKey(day))),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeader(l.recordedPeriods, action: l.addPastPeriod, onAction: _addPast),
        if (periods.isEmpty)
          AppCard(child: Text(l.noPeriodsYet, style: t.bodyMedium))
        else
          for (final p in periods.take(8))
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: AppCard(
                child: Row(children: [
                  const Icon(Icons.water_drop, color: periodColor, size: 20),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Text(
                      p.end == null
                          ? l.periodSinceDate(fmt.day(p.start))
                          : '${fmt.dateShort(parseDayKey(p.start))} – ${fmt.dateShort(parseDayKey(p.end!))} · ${l.daysN(periodDays(p))}',
                      style: t.bodyMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: l.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      if (await confirmDialog(context, title: l.deletePeriodTitle, message: l.deletePeriodBody, confirmLabel: l.delete)) {
                        data.deletePeriod(p.id);
                      }
                    },
                  ),
                ]),
              ),
            ),
      ]),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline, size: 18, color: context.status.info),
        const SizedBox(width: Space.s),
        Expanded(child: Text(l.cycleDisclaimer, style: t.bodySmall?.copyWith(color: context.status.textSecondary))),
      ]),
    ];

    return ResponsiveContainer(
      maxWidth: 720,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl),
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(height: Space.l),
        itemBuilder: (_, i) => children[i],
      ),
    );
  }
}

/// A day's log in a line.
String logSummary(AppLocalizations l, CycleDayLog x) => [
      if (x.flow != null) l.flowLevel(x.flow!),
      if (x.pain != null) l.painN(x.pain!),
      for (final s in x.symptoms.take(3)) l.symptom(s),
      if (x.mood != null) l.cycleMood(x.mood!),
      if (x.energy != null) l.energyN(x.energy!),
    ].join(' · ');

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.month,
    required this.marks,
    required this.logged,
    required this.today,
    required this.fmt,
    required this.onMonth,
    required this.onDay,
  });
  final DateTime month;
  final Map<String, DayMark> marks;
  final Set<String> logged;
  final DateTime today;
  final Fmt fmt;
  final ValueChanged<DateTime> onMonth;
  final ValueChanged<DateTime> onDay;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final first = DateTime(month.year, month.month);
    final days = DateTime(month.year, month.month + 1, 0).day;
    // Saturday-first weeks, as most calendars here are.
    final lead = (first.weekday + 1) % 7;
    final cells = <DateTime?>[for (var i = 0; i < lead; i++) null, for (var i = 0; i < days; i++) DateTime(month.year, month.month, i + 1)];

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          IconButton(tooltip: l.previous, icon: const Icon(Icons.chevron_left), onPressed: () => onMonth(DateTime(month.year, month.month - 1))),
          Expanded(child: Text(fmt.monthYear(month), style: t.titleSmall, textAlign: TextAlign.center)),
          IconButton(tooltip: l.next, icon: const Icon(Icons.chevron_right), onPressed: () => onMonth(DateTime(month.year, month.month + 1))),
        ]),
        const SizedBox(height: Space.xs),
        Row(children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Text(fmt.weekdayShort(DateTime(2026, 1, 3 + i)), textAlign: TextAlign.center, style: t.labelSmall?.copyWith(color: context.status.textSecondary)),
            ),
        ]),
        const SizedBox(height: Space.xs),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final c in cells)
              if (c == null)
                const SizedBox.shrink()
              else
                _DayCell(
                  day: c,
                  mark: marks[dayKey(c)] ?? DayMark.none,
                  logged: logged.contains(dayKey(c)),
                  today: c == today,
                  onTap: c.isAfter(today) ? null : () => onDay(c),
                ),
          ],
        ),
        const SizedBox(height: Space.s),
        Wrap(spacing: Space.l, runSpacing: Space.xs, children: [
          _Legend(color: periodColor, label: l.legendPeriod),
          _Legend(color: periodColor.withValues(alpha: 0.25), label: l.legendEstimated),
          _Legend(color: AppColors.gold, label: l.legendLogged, dot: true),
        ]),
      ]),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.mark, required this.logged, required this.today, this.onTap});
  final DateTime day;
  final DayMark mark;
  final bool logged;
  final bool today;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final bg = switch (mark) {
      DayMark.period => periodColor,
      DayMark.predicted => periodColor.withValues(alpha: 0.18),
      DayMark.none => Colors.transparent,
    };
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: today ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
          ),
          child: Stack(alignment: Alignment.center, children: [
            Text('${day.day}',
                style: t.bodySmall?.copyWith(
                  color: mark == DayMark.period ? Colors.white : (onTap == null ? context.status.textSecondary : null),
                  fontWeight: today ? FontWeight.w700 : null,
                )),
            if (logged)
              const Positioned(bottom: 3, child: CircleAvatar(radius: 2.5, backgroundColor: AppColors.gold)),
          ]),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, this.dot = false});
  final Color color;
  final String label;
  final bool dot;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: dot ? 6 : 12, height: dot ? 6 : 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: Space.xs),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ]);
}
