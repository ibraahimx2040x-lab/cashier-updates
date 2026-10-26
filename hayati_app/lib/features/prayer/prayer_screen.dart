import 'dart:async';

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
import '../../data/models/prayer.dart';
import '../../domain/prayer_times.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';

/// Screen 10 — prayer times for a day, the next prayer, and an optional
/// log the user fills in themselves.
class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  int _offset = 0; // days from today
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final ps = d.settings.prayer;
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final settingsButton = IconButton(
      tooltip: l.prayerSettingsTitle,
      icon: const Icon(Icons.tune),
      onPressed: () => context.push(Routes.prayerSettings),
    );

    if (!ps.active) {
      return Scaffold(
        appBar: AppBar(title: Text(l.navPrayer), actions: [settingsButton]),
        body: EmptyState(
          icon: Icons.mosque_outlined,
          title: l.prayerSetupTitle,
          message: l.prayerSetupBody,
          action: l.prayerSetupAction,
          onAction: () => context.push(Routes.prayerSettings),
        ),
      );
    }

    final day = dateOnly(now).add(Duration(days: _offset));
    final times = prayerDay(ps, day)!;
    final isToday = _offset == 0;
    final next = nextPrayer(ps, now)!;
    final current = isToday ? currentPrayer(ps, now) : null;
    final left = next.$2.difference(now).inMinutes + 1;
    final place = ps.place.isNotEmpty ? ps.place : l.myLocation;

    // Last 7 days of the user's own log (today included).
    final weekDays = [for (var i = 0; i < 7; i++) dayKey(dateOnly(now).subtract(Duration(days: i)))];
    final logged = d.prayerLogs.where((x) => weekDays.contains(x.day)).length;

    return Scaffold(
      appBar: AppBar(title: Text(l.navPrayer), actions: [settingsButton]),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl),
          children: [
            FadeSlideIn(
              child: Container(
                padding: const EdgeInsets.all(Space.xl),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Radii.sheet),
                  gradient: const LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [AppColors.deepGreen, AppColors.midGreen],
                  ),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.nextPrayerIs(l.prayerName(next.$1)), style: t.titleMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: Space.xs),
                  Text(fmt.time(next.$2), style: t.displaySmall?.copyWith(color: Colors.white)),
                  Text(l.inDuration(l.durationText(left)), style: t.bodyMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: Space.l),
                  Row(children: [
                    const Icon(Icons.place_outlined, color: Colors.white70, size: 18),
                    const SizedBox(width: Space.xs),
                    Expanded(
                      child: Text('$place · ${l.prayerMethod(ps.method)}',
                          style: t.bodySmall?.copyWith(color: Colors.white70), overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: Space.l),
            Row(children: [
              IconButton(
                tooltip: l.previousDay,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _offset--),
              ),
              Expanded(
                child: Text(
                  isToday ? l.today : fmt.fullDate(day),
                  textAlign: TextAlign.center,
                  style: t.titleSmall,
                ),
              ),
              IconButton(
                tooltip: l.nextDay,
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _offset++),
              ),
            ]),
            const SizedBox(height: Space.s),
            SmoothSwitcher(
              childKey: _offset,
              child: AppCard(
                padding: const EdgeInsets.symmetric(vertical: Space.s),
                child: Column(children: [
                  for (final p in Prayer.values) ...[
                    _PrayerRow(
                      name: l.prayerName(p),
                      time: fmt.time(times[p]),
                      current: p == current,
                      // Logging is the user's own record: only for prayers
                      // whose time has come, never for future ones.
                      logged: ps.logEnabled && !times[p].isAfter(now) ? d.prayerLogged(p, dayKey(day)) : null,
                      onLog: (v) => ref.read(dataProvider.notifier).setPrayerLogged(p, dayKey(day), v),
                    ),
                    if (p == Prayer.fajr)
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.wb_twilight, color: context.status.inactive),
                        title: Text(l.sunrise, style: t.bodyMedium?.copyWith(color: context.status.textSecondary)),
                        trailing: Text(fmt.time(times.sunrise), style: t.bodyMedium?.copyWith(color: context.status.textSecondary)),
                      ),
                  ],
                ]),
              ),
            ),
            if (ps.logEnabled) ...[
              const SizedBox(height: Space.l),
              AppCard(
                child: Row(children: [
                  Icon(Icons.insights_outlined, color: scheme.primary),
                  const SizedBox(width: Space.m),
                  Expanded(child: Text(l.prayerWeekLogged(logged))),
                ]),
              ),
            ],
            const SizedBox(height: Space.l),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline, size: 18, color: context.status.info),
              const SizedBox(width: Space.s),
              Expanded(child: Text(l.prayerCalcNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary))),
            ]),
          ],
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({required this.name, required this.time, required this.current, required this.logged, required this.onLog});
  final String name;
  final String time;
  final bool current;

  /// Null when logging isn't offered for this row.
  final bool? logged;
  final ValueChanged<bool> onLog;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: Motion.medium,
      color: current ? context.status.highlight : Colors.transparent,
      child: ListTile(
        leading: Icon(current ? Icons.mosque : Icons.mosque_outlined, color: scheme.primary),
        title: Text(name, style: t.titleSmall?.copyWith(fontWeight: current ? FontWeight.w700 : FontWeight.w600)),
        subtitle: current ? Text(l.prayerCurrent) : null,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(time, style: t.titleMedium),
          if (logged != null) ...[
            const SizedBox(width: Space.s),
            Tooltip(
              message: l.prayerLogHint,
              child: Checkbox(
                value: logged,
                semanticLabel: l.prayerLogLabel(name),
                onChanged: (v) => onLog(v ?? false),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
