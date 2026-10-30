import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/health_sync.dart';
import '../../data/models/health.dart';
import '../../domain/sleep.dart';
import '../../l10n/app_localizations.dart';
import '../../services/health_reader.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_surface.dart';

IconData kindIcon(HealthKind k) => switch (k) {
      HealthKind.steps => Icons.directions_walk,
      HealthKind.sleep => Icons.bedtime_outlined,
      HealthKind.heartRate => Icons.favorite_border,
      HealthKind.workouts => Icons.sports_gymnastics,
      HealthKind.body => Icons.monitor_weight_outlined,
    };

IconData sourceIcon(ActivitySource s) => switch (s) {
      ActivitySource.healthConnect => Icons.health_and_safety_outlined,
      ActivitySource.healthKit => Icons.favorite_outline,
      ActivitySource.phone => Icons.smartphone,
      ActivitySource.manual => Icons.edit_outlined,
    };

/// Screen 40 — what this phone reads from its health store, which sources
/// hold data, which one counts per type, and removing a source's data.
class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final d = ref.watch(dataProvider);
    final sync = ref.watch(healthSyncProvider);
    final reader = ref.watch(healthReaderProvider);
    final ctl = ref.read(healthSyncProvider.notifier);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final h = d.settings.health;
    final phone = reader.source;
    final unsupported = phone == null || sync.availability == HealthAvailability.unsupported;
    final install = sync.availability == HealthAvailability.needsInstall;
    final storeName = phone == null ? '' : l.activitySource(phone);
    final summaries = sourceSummaries(d);

    bool sectionOn(HealthKind k) => k == HealthKind.sleep ? h.has(HealthModule.sleep) : h.has(HealthModule.activity);

    Future<void> toggle(HealthKind k, bool on) async {
      if (!on) return ctl.stop(k);
      final ok = await ctl.connect({k});
      if (!ok && !install && context.mounted) showSnack(context, l.healthPermissionDenied);
    }

    final children = <Widget>[
      HeroSurface(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.watch_outlined, color: AppColors.gold, size: 32),
          const SizedBox(height: Space.m),
          Text(unsupported ? l.devicesTitle : storeName, style: t.headlineSmall?.copyWith(color: Colors.white)),
          const SizedBox(height: Space.xs),
          Text(
            unsupported ? l.devicesWebBody : l.devicesStoreBody(storeName),
            style: t.bodyMedium?.copyWith(color: Colors.white70),
          ),
          if (!unsupported && sync.linked) ...[
            const SizedBox(height: Space.m),
            Text(
              sync.failed
                  ? l.syncFailedShort
                  : sync.lastSync == null
                      ? l.notSyncedYet
                      : l.lastSyncAt(fmt.time(sync.lastSync!)),
              style: t.labelMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: Space.s),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy),
              onPressed: sync.busy ? null : () => ctl.sync(force: true),
              icon: sync.busy
                  ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync),
              label: Text(l.syncNow),
            ),
          ],
        ]),
      ),
      if (install)
        AppCard(
          color: context.status.highlight,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.installHealthConnect, style: t.titleSmall),
            const SizedBox(height: Space.xs),
            Text(l.installHealthConnectBody, style: t.bodySmall),
            const SizedBox(height: Space.s),
            FilledButton.icon(onPressed: () => ctl.connect(const {HealthKind.steps}), icon: const Icon(Icons.download), label: Text(l.install)),
          ]),
        ),
      if (!unsupported && !install)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionHeader(l.whatThisPhoneReads),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Space.s),
            child: Column(children: [
              for (final k in HealthKind.values)
                SwitchListTile(
                  secondary: IconBadge(kindIcon(k)),
                  title: Text(l.healthKind(k)),
                  subtitle: Text(sectionOn(k) ? l.healthKindSub(k) : l.turnOnSection(l.healthModule(k == HealthKind.sleep ? HealthModule.sleep : HealthModule.activity))),
                  value: sync.reads(k),
                  onChanged: sectionOn(k) ? (v) => toggle(k, v) : null,
                ),
            ]),
          ),
          const SizedBox(height: Space.xs),
          Text(l.readOnlyNote(storeName), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
        ]),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeader(l.sourcesWithData),
        if (summaries.isEmpty)
          AppCard(child: Text(l.noSourcesYet, style: t.bodyMedium))
        else
          for (final s in summaries)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: AppCard(
                child: Row(children: [
                  IconBadge(sourceIcon(s.source)),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Flexible(child: Text(l.activitySource(s.source), style: t.titleSmall)),
                        if (s.source == phone && sync.linked) ...[
                          const SizedBox(width: Space.s),
                          Pill(label: l.thisPhone, color: Theme.of(context).colorScheme.primary),
                        ],
                      ]),
                      Text(
                        [
                          if (s.stepDays > 0) l.stepDaysN(s.stepDays),
                          if (s.sleepNights > 0) l.sleepNightsN(s.sleepNights),
                          if (s.heartDays > 0) l.heartDaysN(s.heartDays),
                          if (s.workouts > 0) l.workoutsN(s.workouts),
                          if (s.measurements > 0) l.measurementsN(s.measurements),
                        ].join(' · '),
                        style: t.bodySmall?.copyWith(color: context.status.textSecondary),
                      ),
                      if (s.latest != null)
                        Text(l.latestOn(fmt.date(s.latest!)), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                    ]),
                  ),
                  IconButton(
                    tooltip: l.removeSourceData,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final name = l.activitySource(s.source);
                      if (await confirmDialog(context,
                          title: l.removeSourceDataTitle(name), message: l.removeSourceDataBody(name), confirmLabel: l.delete)) {
                        ref.read(dataProvider.notifier).deleteSourceData(s.source);
                        if (context.mounted) showSnack(context, l.sourceDataRemoved(name));
                      }
                    },
                  ),
                ]),
              ),
            ),
      ]),
      _Priority(),
      if (!unsupported && sync.linked)
        OutlinedButton.icon(
          onPressed: () async {
            if (await confirmDialog(context, title: l.disconnectTitle(storeName), message: l.disconnectBody, confirmLabel: l.disconnect)) {
              await ctl.disconnect();
            }
          },
          icon: const Icon(Icons.link_off),
          label: Text(l.disconnectThisPhone),
        ),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.lock_outline, size: 18, color: context.status.success),
        const SizedBox(width: Space.s),
        Expanded(child: Text(l.devicesPrivacy, style: t.bodySmall?.copyWith(color: context.status.textSecondary))),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.devicesTitle)),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl),
          itemCount: children.length,
          separatorBuilder: (_, _) => const SizedBox(height: Space.l),
          itemBuilder: (_, i) => children[i],
        ),
      ),
    );
  }
}

/// Which source counts for steps, sleep and heart rate, when more than one
/// has data. Workouts are listed as they are, so they have no choice.
class _Priority extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final d = ref.watch(dataProvider);
    final h = d.settings.health;
    final kinds = [
      for (final k in const [HealthKind.steps, HealthKind.sleep, HealthKind.heartRate])
        if (sourcesWith(d, k).length > 1) k,
    ];

    void pick(HealthKind k, ActivitySource? s) => ref.read(dataProvider.notifier).updateHealth((x) => switch (k) {
          HealthKind.steps => x.copyWith(preferredSource: () => s),
          HealthKind.sleep => x.copyWith(sleepSource: () => s),
          _ => x.copyWith(heartSource: () => s),
        });

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.whichSourceCounts),
      Text(l.neverAddedUp, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
      const SizedBox(height: Space.s),
      if (kinds.isEmpty)
        AppCard(child: Text(l.oneSourceEach, style: t.bodyMedium))
      else
        for (final k in kinds)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s),
            child: AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(kindIcon(k), size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: Space.s),
                  Text(l.healthKind(k), style: t.titleSmall),
                ]),
                const SizedBox(height: Space.s),
                Wrap(spacing: Space.s, runSpacing: Space.s, children: [
                  ChoiceChip(label: Text(l.automatic), selected: h.preferredFor(k) == null, onSelected: (_) => pick(k, null)),
                  for (final s in activitySourcePriority)
                    if (sourcesWith(d, k).contains(s))
                      ChoiceChip(label: Text(l.activitySource(s)), selected: h.preferredFor(k) == s, onSelected: (_) => pick(k, s)),
                ]),
              ]),
            ),
          ),
    ]);
  }
}
