import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/health_sync.dart';
import '../../data/data_controller.dart';
import '../../data/models/health.dart';
import '../../domain/activity.dart';
import '../../l10n/app_localizations.dart';
import '../../services/health_reader.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_surface.dart';
import '../../widgets/motion.dart';
import 'health_cards.dart';

/// Screens 34–35 — today's steps against the goal, where they came from,
/// and the last week or month.
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  bool _month = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(healthSyncProvider.notifier).sync());
  }

  Future<void> _manual(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final now = ref.read(clockProvider)();
    final r = await showDialog<(String, int)>(context: context, builder: (_) => _ManualDialog(now: now));
    if (r == null || !context.mounted) return;
    ref.read(dataProvider.notifier).recordActivity(r.$1, ActivitySource.manual, steps: r.$2);
    showSnack(context, l.activitySaved);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final sync = ref.watch(healthSyncProvider);
    final now = ref.watch(clockProvider)();
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final h = d.settings.health;
    final today = activityDay(d, dayKey(now));
    final series = activitySeries(d, now, _month ? 30 : 7);
    final stats = activityStats(series, h.stepGoal);
    final streak = goalStreak(d, now, h.stepGoal);
    final progress = (today.steps / h.stepGoal).clamp(0.0, 1.0);

    final sections = <Widget>[
      HeroSurface(
        child: Row(children: [
          SizedBox.square(
            dimension: 120,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: Motion.slow,
              curve: Motion.curve,
              builder: (_, v, _) => CustomPaint(
                painter: _Ring(v),
                child: Center(
                  child: Icon(today.steps >= h.stepGoal ? Icons.emoji_events : Icons.directions_walk,
                      color: AppColors.gold, size: 36),
                ),
              ),
            ),
          ),
          const SizedBox(width: Space.l),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.stepsToday, style: t.labelMedium?.copyWith(color: Colors.white70)),
              Text(fmt.number(today.steps), style: t.displaySmall?.copyWith(color: Colors.white)),
              Text(l.ofStepGoal(fmt.number(h.stepGoal)), style: t.bodyMedium?.copyWith(color: Colors.white70)),
              const SizedBox(height: Space.s),
              Text(
                '${l.distanceKm((today.distanceM / 1000).toStringAsFixed(1))}${today.distanceEstimated && today.hasData ? ' · ${l.approx}' : ''}',
                style: t.bodySmall?.copyWith(color: Colors.white70),
              ),
              if (today.activeMinutes != null)
                Text(l.activeMinutesN(today.activeMinutes!), style: t.bodySmall?.copyWith(color: Colors.white70)),
            ]),
          ),
        ]),
      ),
      _SourceCard(sync: sync, today: today, fmt: fmt, onManual: () => _manual(context)),
      if (h.has(HealthModule.sleep) || h.has(HealthModule.activity))
        LayoutBuilder(builder: (context, c) {
          final cards = [
            if (h.has(HealthModule.sleep)) const SleepCard(),
            const HeartCard(),
          ];
          if (c.maxWidth < 560) {
            return Column(children: [
              for (final (i, x) in cards.indexed) Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : Space.l), child: x),
            ]);
          }
          return IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (final (i, x) in cards.indexed) ...[if (i > 0) const SizedBox(width: Space.l), Expanded(child: x)],
            ]),
          );
        }),
      const DeviceWorkoutsCard(),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: SectionHeader(l.history)),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [ButtonSegment(value: false, label: Text(l.week)), ButtonSegment(value: true, label: Text(l.month))],
            selected: {_month},
            onSelectionChanged: (v) => setState(() => _month = v.first),
          ),
        ]),
        const SizedBox(height: Space.s),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              height: 160,
              child: SmoothSwitcher(childKey: _month, child: _Bars(series: series, goal: h.stepGoal, fmt: fmt, month: _month)),
            ),
            const SizedBox(height: Space.m),
            Wrap(spacing: Space.l, runSpacing: Space.s, children: [
              _Stat(l.dailyAverage, fmt.number(stats.average)),
              _Stat(l.goalDays, l.nOfM(stats.goalDays, series.length)),
              if (stats.best != null) _Stat(l.bestDay, '${fmt.number(stats.best!.steps)} · ${fmt.weekdayDate(parseDayKey(stats.best!.day))}'),
              _Stat(l.goalStreak, l.daysN(streak)),
            ]),
          ]),
        ),
      ]),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline, size: 18, color: context.status.info),
        const SizedBox(width: Space.s),
        Expanded(child: Text(l.activityNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary))),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.navActivity), actions: [
        IconButton(tooltip: l.devicesTitle, icon: const Icon(Icons.watch_outlined), onPressed: () => context.push(Routes.devices)),
        IconButton(tooltip: l.healthSetup, icon: const Icon(Icons.tune), onPressed: () => context.push(Routes.healthSetup)),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _manual(context),
        icon: const Icon(Icons.edit_outlined),
        label: Text(l.addStepsManually),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(healthSyncProvider.notifier).sync(force: true),
        child: ResponsiveContainer(
          maxWidth: 760,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 120),
            itemCount: sections.length,
            separatorBuilder: (_, _) => const SizedBox(height: Space.l),
            itemBuilder: (_, i) => FadeSlideIn(index: i, child: sections[i]),
          ),
        ),
      ),
    );
  }
}

/// Where today's number comes from, and how to connect the phone's health
/// store.
class _SourceCard extends ConsumerWidget {
  const _SourceCard({required this.sync, required this.today, required this.fmt, required this.onManual});
  final HealthSyncState sync;
  final ActivityDay today;
  final Fmt fmt;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final reader = ref.watch(healthReaderProvider);
    final ctl = ref.read(healthSyncProvider.notifier);
    final storeName = reader.source == ActivitySource.healthKit ? l.sourceHealthKit : l.sourceHealthConnect;

    Widget body;
    if (sync.availability == HealthAvailability.unsupported || reader.source == null) {
      body = Text(l.activityWebNote, style: t.bodyMedium);
    } else if (sync.linked) {
      body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.connectedTo(storeName), style: t.titleSmall),
        Text(
          sync.failed
              ? l.syncFailedShort
              : sync.lastSync == null
                  ? l.notSyncedYet
                  : l.lastSyncAt(fmt.time(sync.lastSync!)),
          style: t.bodySmall?.copyWith(color: context.status.textSecondary),
        ),
        const SizedBox(height: Space.s),
        Wrap(spacing: Space.s, children: [
          OutlinedButton.icon(
            onPressed: sync.busy ? null : () => ctl.sync(force: true),
            icon: sync.busy
                ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync),
            label: Text(l.syncNow),
          ),
          TextButton(onPressed: () => context.push(Routes.devices), child: Text(l.manageDevices)),
        ]),
      ]);
    } else {
      final install = sync.availability == HealthAvailability.needsInstall;
      body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(install ? l.installHealthConnect : l.connectStepsTitle(storeName), style: t.titleSmall),
        const SizedBox(height: Space.xs),
        Text(install ? l.installHealthConnectBody : l.connectStepsBody(storeName), style: t.bodySmall),
        const SizedBox(height: Space.s),
        Wrap(spacing: Space.s, runSpacing: Space.s, children: [
          FilledButton.icon(
            onPressed: () async {
              final ok = await ctl.connect(const {HealthKind.steps});
              if (!ok && !install && context.mounted) showSnack(context, l.stepsPermissionDenied);
            },
            icon: Icon(install ? Icons.download : Icons.link),
            label: Text(install ? l.install : l.connect),
          ),
          TextButton(onPressed: () => context.push(Routes.devices), child: Text(l.manageDevices)),
        ]),
      ]);
    }

    return AppCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconBadge(sync.linked ? Icons.watch : Icons.health_and_safety_outlined),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            body,
            if (today.source != null) ...[
              const SizedBox(height: Space.s),
              Pill(label: l.todayFrom(l.activitySource(today.source!)), color: Theme.of(context).colorScheme.primary, icon: Icons.check),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: t.labelSmall?.copyWith(color: context.status.textSecondary)),
      Text(value, style: t.titleSmall),
    ]);
  }
}

/// Daily bars with the goal as a dashed line; bars reaching the goal are gold.
class _Bars extends StatelessWidget {
  const _Bars({required this.series, required this.goal, required this.fmt, required this.month});
  final List<ActivityDay> series;
  final int goal;
  final Fmt fmt;
  final bool month;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxSteps = math.max(goal * 1.15, series.fold<int>(0, (a, x) => math.max(a, x.steps)).toDouble());
    final t = Theme.of(context).textTheme;
    return Semantics(
      label: [for (final x in series) '${fmt.dateShort(parseDayKey(x.day))}: ${fmt.number(x.steps)}'].join('، '),
      child: ExcludeSemantics(
        child: LayoutBuilder(builder: (context, c) {
          final chartH = c.maxHeight - 20;
          final goalY = chartH * (1 - goal / maxSteps);
          return Stack(children: [
            Positioned(
              left: 0,
              right: 0,
              top: goalY,
              child: CustomPaint(size: const Size(double.infinity, 1), painter: _Dash(scheme.tertiary)),
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (final (i, x) in series.indexed)
                Expanded(
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: chartH * (x.steps / maxSteps)),
                      duration: Motion.slow,
                      curve: Motion.curve,
                      builder: (_, v, _) => Container(
                        height: math.max(v, x.hasData ? 3 : 0),
                        margin: EdgeInsets.symmetric(horizontal: month ? 1.5 : 6),
                        decoration: BoxDecoration(
                          color: x.steps >= goal ? AppColors.gold : scheme.primary.withValues(alpha: x.hasData ? 0.85 : 0.2),
                          borderRadius: BorderRadius.circular(month ? 3 : 6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: (!month || i % 5 == 0 || i == series.length - 1)
                          ? Text(
                              month ? '${parseDayKey(x.day).day}' : fmt.weekdayShort(parseDayKey(x.day)),
                              style: t.labelSmall?.copyWith(color: context.status.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                            )
                          : null,
                    ),
                  ]),
                ),
            ]),
          ]);
        }),
      ),
    );
  }
}

class _Dash extends CustomPainter {
  const _Dash(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0), Offset(math.min(x + 4, size.width), 0), p);
    }
  }

  @override
  bool shouldRepaint(_Dash old) => old.color != color;
}

class _Ring extends CustomPainter {
  const _Ring(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 8;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = Colors.white.withValues(alpha: 0.14);
    canvas.drawCircle(c, r, base);
    if (value <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(colors: [Color(0xFFF3D58A), AppColors.gold]).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * value, false, arc);
  }

  @override
  bool shouldRepaint(_Ring old) => old.value != value;
}

/// Steps for one of the last three days, typed in by hand.
class _ManualDialog extends StatefulWidget {
  const _ManualDialog({required this.now});
  final DateTime now;

  @override
  State<_ManualDialog> createState() => _ManualDialogState();
}

class _ManualDialogState extends State<_ManualDialog> {
  int _ago = 0;
  final _steps = TextEditingController();

  @override
  void dispose() {
    _steps.dispose();
    super.dispose();
  }

  int? get _value {
    final v = int.tryParse(_steps.text.trim());
    return v == null || v < 0 || v > DailyActivity.maxSteps ? null : v;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final day = dateOnly(widget.now).subtract(Duration(days: _ago));
    return AlertDialog(
      title: Text(l.addStepsManually),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: Space.s, children: [
          for (final a in const [0, 1, 2])
            ChoiceChip(
              label: Text(a == 0 ? l.today : (a == 1 ? l.yesterday : fmt.weekdayDate(dateOnly(widget.now).subtract(Duration(days: a))))),
              selected: _ago == a,
              onSelected: (_) => setState(() => _ago = a),
            ),
        ]),
        const SizedBox(height: Space.m),
        TextField(
          controller: _steps,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
          decoration: InputDecoration(labelText: l.stepsLabel, errorText: _steps.text.isEmpty || _value != null ? null : l.stepsInvalid),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: Space.xs),
        Text(l.manualStepsNote, style: Theme.of(context).textTheme.bodySmall),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(onPressed: _value == null ? null : () => Navigator.pop(context, (dayKey(day), _value!)), child: Text(l.save)),
      ],
    );
  }
}
