import 'dart:math' as math;

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
import '../../data/models/health.dart';
import '../../domain/sleep.dart';
import '../../domain/vitals.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_surface.dart';
import '../womens/womens_gate.dart';
import '../../widgets/home_logo.dart';

/// Screen 45 — sleep and recovery: the last two weeks of sleep (from the
/// phone's health app or entered by hand), how rested the user feels each
/// day, and an optional wind-down reminder.
class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final d = ref.watch(dataProvider);
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final h = d.settings.health;
    final series = sleepSeries(d, now, 14);
    final week = series.sublist(7);
    final avg = averageSleepMinutes(week);
    final last = series.lastWhere((s) => s.hasData, orElse: () => series.last);
    final top = series.map((s) => s.minutes).fold(0, math.max);
    final checks = checkinAverages(d, now);
    final today = dayKey(now);
    final todayCheck = d.checkin(today);
    final nights = [...d.sleep]..sort((a, b) => b.end.compareTo(a.end));

    final children = <Widget>[
      HeroSurface(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.bedtime_outlined, color: AppColors.gold, size: 32),
          const SizedBox(height: Space.m),
          Text(last.hasData ? l.durationText(last.minutes) : l.noSleepYet, style: t.headlineSmall?.copyWith(color: Colors.white)),
          if (last.main case final m?)
            Text(l.sleepWindow(fmt.time(m.start), fmt.time(m.end)), style: t.bodyMedium?.copyWith(color: Colors.white70)),
          if (avg > 0) Text(l.weekAverage(l.durationText(avg)), style: t.labelMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: Space.m),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy),
            onPressed: () => addSleepDialog(context, ref),
            icon: const Icon(Icons.add),
            label: Text(l.addSleep),
          ),
        ]),
      ),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.lastTwoWeeks, style: t.titleSmall),
          const SizedBox(height: Space.m),
          SizedBox(
            height: 80,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (final s in series)
                Expanded(
                  child: Tooltip(
                    message: '${fmt.weekdayDate(parseDayKey(s.day))}: ${s.hasData ? l.durationText(s.minutes) : '—'}',
                    child: Container(
                      height: top == 0 || !s.hasData ? 3 : 80 * s.minutes / top,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: s.minutes >= 7 * 60 ? AppColors.gold : Theme.of(context).colorScheme.primary.withValues(alpha: s.hasData ? 0.7 : 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: Space.s),
          Text(l.sleepGoldNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
        ]),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeader(l.howRested),
        _CheckinCard(day: today, initial: todayCheck),
        if (checks.days > 0) ...[
          const SizedBox(height: Space.s),
          Text(
            l.checkinWeek(
              checks.energy == null ? '—' : fmt.number(double.parse(checks.energy!.toStringAsFixed(1))),
              checks.recovery == null ? '—' : fmt.number(double.parse(checks.recovery!.toStringAsFixed(1))),
            ),
            style: t.bodySmall?.copyWith(color: context.status.textSecondary),
          ),
        ],
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeader(l.recentNights),
        if (nights.isEmpty)
          AppCard(child: Text(l.noSleepYetBody, style: t.bodyMedium))
        else
          for (final s in nights.take(10))
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: AppCard(
                child: Row(children: [
                  const IconBadge(Icons.nightlight_outlined),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${fmt.weekdayDate(s.end)} · ${l.durationText(s.minutes)}', style: t.titleSmall),
                      Text('${fmt.time(s.start)} – ${fmt.time(s.end)} · ${l.activitySource(s.source)}',
                          style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                      Row(children: [
                        for (var q = 1; q <= 5; q++)
                          InkWell(
                            onTap: () => ref.read(dataProvider.notifier).rateSleep(s.id, s.quality == q ? null : q),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon((s.quality ?? 0) >= q ? Icons.star : Icons.star_border, size: 20, color: AppColors.gold, semanticLabel: l.sleepQualityN(q)),
                            ),
                          ),
                      ]),
                    ]),
                  ),
                  if (s.source == ActivitySource.manual)
                    IconButton(
                      tooltip: l.delete,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref.read(dataProvider.notifier).deleteSleep(s.id),
                    ),
                ]),
              ),
            ),
      ]),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.bedtimeReminder),
            subtitle: Text(l.bedtimeReminderSub),
            value: h.bedtimeReminder != null,
            onChanged: (v) => ref.read(dataProvider.notifier).updateHealth((x) => x.copyWith(bedtimeReminder: () => v ? 22 * 60 + 30 : null)),
          ),
          if (h.bedtimeReminder != null)
            TimePickerField(
              label: l.time,
              minutes: h.bedtimeReminder,
              fmt: fmt,
              clearable: false,
              onChanged: (v) => ref.read(dataProvider.notifier).updateHealth((x) => x.copyWith(bedtimeReminder: () => v ?? x.bedtimeReminder)),
            ),
        ]),
      ),
      AppCard(
        onTap: () => context.push(Routes.article('sleep_basics')),
        child: Row(children: [
          const IconBadge(Icons.menu_book_outlined),
          const SizedBox(width: Space.m),
          Expanded(child: Text(l.readSleepBasics, style: t.bodyMedium)),
          const Icon(Icons.chevron_right),
        ]),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.sleepAndRecovery), actions: [
        IconButton(tooltip: l.devicesTitle, icon: const Icon(Icons.watch_outlined), onPressed: () => context.push(Routes.devices)), const HomeLogoButton()]),
      body: HealthLockGate(
        child: ResponsiveContainer(
          maxWidth: 720,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl),
            itemCount: children.length,
            separatorBuilder: (_, _) => const SizedBox(height: Space.l),
            itemBuilder: (_, i) => children[i],
          ),
        ),
      ),
    );
  }
}

/// Today's energy, fatigue, recovery and mood, saved as they're tapped.
class _CheckinCard extends ConsumerWidget {
  const _CheckinCard({required this.day, required this.initial});
  final String day;
  final WellbeingCheckin? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = initial;

    void set({int? Function()? energy, int? Function()? fatigue, int? Function()? recovery, int? Function()? mood}) {
      ref.read(dataProvider.notifier).saveCheckin(WellbeingCheckin(
            id: '',
            day: day,
            energy: energy != null ? energy() : c?.energy,
            fatigue: fatigue != null ? fatigue() : c?.fatigue,
            recovery: recovery != null ? recovery() : c?.recovery,
            mood: mood != null ? mood() : c?.mood,
            updatedAt: DateTime.now(),
          ));
    }

    Widget row(String label, int? value, void Function(int?) onPick) => Padding(
          padding: const EdgeInsets.only(bottom: Space.s),
          child: Row(children: [
            SizedBox(width: 92, child: Text(label, style: t.bodyMedium)),
            Expanded(
              child: Wrap(spacing: Space.xs, children: [
                for (var v = 1; v <= 5; v++)
                  ChoiceChip(
                    label: Text('$v'),
                    visualDensity: VisualDensity.compact,
                    selected: value == v,
                    onSelected: (on) => onPick(on ? v : null),
                  ),
              ]),
            ),
          ]),
        );

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        row(l.energy, c?.energy, (v) => set(energy: () => v)),
        row(l.fatigue, c?.fatigue, (v) => set(fatigue: () => v)),
        row(l.recovery, c?.recovery, (v) => set(recovery: () => v)),
        row(l.mood, c?.mood, (v) => set(mood: () => v)),
        Text(l.checkinScale, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
      ]),
    );
  }
}

/// Adds a night (or a nap) by hand.
Future<void> addSleepDialog(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final now = ref.read(clockProvider)();
  final fmt = Fmt.of(context, use24h: ref.read(settingsProvider).use24h);
  var wakeDay = dateOnly(now);
  var bed = 23 * 60;
  var wake = 7 * 60;
  int? quality;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
      return AlertDialog(
        title: Text(l.addSleep),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            DatePickerField(label: l.wokeUpOn, value: wakeDay, fmt: fmt, clearable: false, onChanged: (v) => setState(() => wakeDay = v ?? wakeDay)),
            const SizedBox(height: Space.m),
            TimePickerField(label: l.wentToBed, minutes: bed, fmt: fmt, clearable: false, onChanged: (v) => setState(() => bed = v ?? bed)),
            const SizedBox(height: Space.m),
            TimePickerField(label: l.wokeUp, minutes: wake, fmt: fmt, clearable: false, onChanged: (v) => setState(() => wake = v ?? wake)),
            const SizedBox(height: Space.m),
            Text(l.sleepQuality),
            Row(children: [
              for (var q = 1; q <= 5; q++)
                IconButton(
                  tooltip: l.sleepQualityN(q),
                  icon: Icon((quality ?? 0) >= q ? Icons.star : Icons.star_border, color: AppColors.gold),
                  onPressed: () => setState(() => quality = quality == q ? null : q),
                ),
            ]),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.save)),
        ],
      );
    }),
  );
  if (ok != true || !context.mounted) return;
  final end = atMinutes(wakeDay, wake);
  // A bedtime later in the day than waking means the evening before.
  final start = atMinutes(bed > wake ? wakeDay.subtract(const Duration(days: 1)) : wakeDay, bed);
  try {
    ref.read(dataProvider.notifier).addSleep(start: start, end: end, quality: quality);
    showSnack(context, l.saved);
  } on ArgumentError {
    showSnack(context, l.sleepInvalid);
  }
}
