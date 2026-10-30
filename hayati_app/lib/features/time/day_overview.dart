import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/models/prayer.dart';
import '../../domain/day_schedule.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';

/// Name of a stretch of the day, for lists and clashes.
String slotLabel(AppLocalizations l, DaySlot s) => switch (s.kind) {
      SlotKind.prayer => l.prayerName(Prayer.values.byName(s.refId!)),
      SlotKind.work => l.workBlock,
      SlotKind.rest => l.restBlock,
      SlotKind.sleep => l.clashSleep,
      SlotKind.event || SlotKind.task => s.label ?? '',
      SlotKind.free => l.slotFree,
      SlotKind.past => l.slotPast,
    };

Color slotColor(BuildContext context, SlotKind k) {
  final scheme = Theme.of(context).colorScheme;
  return switch (k) {
    SlotKind.sleep => scheme.onSurface.withValues(alpha: 0.18),
    SlotKind.work => scheme.secondary,
    SlotKind.event => scheme.primary,
    SlotKind.prayer => context.status.success,
    SlotKind.rest => context.status.info,
    SlotKind.task => AppColors.gold,
    SlotKind.free => scheme.primary.withValues(alpha: 0.08),
    SlotKind.past => scheme.onSurface.withValues(alpha: 0.06),
  };
}

/// The 24 hours of one day as a bar, what is taken and what is free, the
/// free stretches, and anything that clashes.
class DayOverviewCard extends StatelessWidget {
  const DayOverviewCard({super.key, required this.schedule, required this.fmt});
  final DaySchedule schedule;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final s = schedule;
    final free = s.freeSlots();
    final kinds = {for (final x in s.slots) x.kind}.toList()..sort((a, b) => a.index.compareTo(b.index));
    String label(SlotKind k) => switch (k) {
          SlotKind.sleep => l.slotSleep,
          SlotKind.work => l.workBlock,
          SlotKind.event => l.slotEvent,
          SlotKind.prayer => l.slotPrayer,
          SlotKind.rest => l.restBlock,
          SlotKind.task => l.slotTask,
          SlotKind.free => l.slotFree,
          SlotKind.past => l.slotPast,
        };

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.dayOverview, style: t.titleSmall),
        const SizedBox(height: Space.m),
        Semantics(
          label: [for (final x in s.slots) '${fmt.time(x.start)}–${fmt.time(x.end)} ${label(x.kind)}'].join('، '),
          child: ExcludeSemantics(
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 18,
                  child: Row(children: [
                    for (final x in s.slots)
                      Expanded(flex: x.minutes.clamp(1, 1440), child: Container(color: slotColor(context, x.kind))),
                  ]),
                ),
              ),
              const SizedBox(height: 4),
              Row(children: [
                for (final h in const [0, 6, 12, 18, 24])
                  Expanded(
                    child: Text(
                      fmt.minutesOfDay(h == 24 ? 0 : h * 60),
                      textAlign: h == 0 ? TextAlign.start : (h == 24 ? TextAlign.end : TextAlign.center),
                      style: t.labelSmall?.copyWith(color: context.status.textSecondary),
                    ),
                  ),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: Space.s),
        Wrap(spacing: Space.m, runSpacing: Space.xs, children: [
          for (final k in kinds)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: slotColor(context, k), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              Text(label(k), style: t.labelSmall),
            ]),
        ]),
        const SizedBox(height: Space.m),
        Row(children: [
          _Num(label: l.slotFree, value: l.durationShort(s.freeMinutes)),
          _Num(label: l.busyTime, value: l.durationShort(s.busyMinutes)),
          _Num(label: l.slotSleep, value: l.durationShort(s.sleepMinutes)),
        ]),
        if (s.dueMinutes > 0) ...[
          const SizedBox(height: Space.s),
          Text(
            s.fitsDue ? l.dayFits : l.dueNeeds(l.durationShort(s.dueMinutes), l.durationShort(s.freeMinutes)),
            style: t.bodySmall?.copyWith(color: s.fitsDue ? context.status.success : context.status.warning),
          ),
        ],
        const SizedBox(height: Space.m),
        Text(l.freeSlotsTitle, style: t.labelMedium),
        const SizedBox(height: Space.xs),
        if (free.isEmpty)
          Text(l.noFreeSlots, style: t.bodySmall?.copyWith(color: context.status.textSecondary))
        else
          Wrap(spacing: Space.s, runSpacing: Space.s, children: [
            for (final f in free)
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text('${fmt.time(f.start)}–${fmt.time(f.end)} · ${l.durationShort(f.minutes)}'),
              ),
          ]),
        if (s.clashes.isNotEmpty) ...[
          const SizedBox(height: Space.m),
          Row(children: [
            Icon(Icons.warning_amber, size: 18, color: context.status.warning),
            const SizedBox(width: Space.xs),
            Text(l.clashesTitle, style: t.labelMedium?.copyWith(color: context.status.warning)),
          ]),
          for (final c in s.clashes)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(l.clashItem(slotLabel(l, c.a), slotLabel(l, c.b), fmt.time(c.b.start)), style: t.bodySmall),
            ),
        ],
      ]),
    );
  }
}

class _Num extends StatelessWidget {
  const _Num({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: t.labelSmall?.copyWith(color: context.status.textSecondary)),
        Text(value, style: t.titleSmall),
      ]),
    );
  }
}
