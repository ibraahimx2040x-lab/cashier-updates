import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/health.dart';
import '../../domain/vitals.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../womens/womens_gate.dart';
import '../../widgets/home_logo.dart';

IconData metricIcon(MetricKind k) => switch (k) {
      MetricKind.weight => Icons.monitor_weight_outlined,
      MetricKind.waist => Icons.straighten,
      MetricKind.restingHr => Icons.favorite_border,
      MetricKind.bp => Icons.bloodtype_outlined,
      MetricKind.bodyFat => Icons.percent,
    };

/// A measurement with its unit, e.g. "72.5 kg" or "120/80 mmHg".
String metricValue(AppLocalizations l, Fmt fmt, BodyMetric m) => switch (m.kind) {
      MetricKind.weight => l.kgN(fmt.number(m.value)),
      MetricKind.waist => l.cmN(fmt.number(m.value)),
      MetricKind.restingHr => l.bpmN(m.value.round()),
      MetricKind.bp => l.mmHgN(m.value.round(), (m.value2 ?? 0).round()),
      MetricKind.bodyFat => l.percentN(fmt.number(m.value)),
    };

/// Screen 44 — body measurements: the latest of each kind with its source
/// and a short trend, added by hand or read from the phone's health app.
class VitalsScreen extends ConsumerWidget {
  const VitalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final d = ref.watch(dataProvider);
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final advice = bpAdvice(d);

    final children = <Widget>[
      if (advice != BpAdvice.none)
        AppCard(
          color: context.status.highlight,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconBadge(advice == BpAdvice.urgent ? Icons.warning_amber_rounded : Icons.medical_services_outlined, color: AppColors.goldDeep),
            const SizedBox(width: Space.m),
            Expanded(child: Text(advice == BpAdvice.urgent ? l.bpUrgent : l.bpSeeDoctor, style: t.bodyMedium)),
          ]),
        ),
      for (final k in MetricKind.values) _MetricCard(kind: k, now: now, fmt: fmt),
      AppCard(
        onTap: () => context.push(Routes.devices),
        child: Row(children: [
          const IconBadge(Icons.watch_outlined),
          const SizedBox(width: Space.m),
          Expanded(child: Text(l.vitalsFromDevices, style: t.bodyMedium)),
          const Icon(Icons.chevron_right),
        ]),
      ),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline, size: 18, color: context.status.info),
        const SizedBox(width: Space.s),
        Expanded(child: Text(l.vitalsNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary))),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.vitals), actions: [
        IconButton(tooltip: l.healthLearn, icon: const Icon(Icons.menu_book_outlined), onPressed: () => context.push(Routes.learn)), const HomeLogoButton()]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => addMetricDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.addMeasurement),
      ),
      body: HealthLockGate(
        child: ResponsiveContainer(
          maxWidth: 720,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 120),
            itemCount: children.length,
            separatorBuilder: (_, _) => const SizedBox(height: Space.m),
            itemBuilder: (_, i) => children[i],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends ConsumerWidget {
  const _MetricCard({required this.kind, required this.now, required this.fmt});
  final MetricKind kind;
  final DateTime now;
  final Fmt fmt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final d = ref.watch(dataProvider);
    final list = metricsOf(d, kind);
    final latest = list.firstOrNull;
    final recent = list.take(10).toList().reversed.toList();
    final change = metricChange(d, kind, now);
    final top = recent.isEmpty ? 1.0 : recent.map((m) => m.value).reduce(math.max);
    final bottom = recent.isEmpty ? 0.0 : recent.map((m) => m.value).reduce(math.min);

    return AppCard(
      onTap: list.isEmpty ? () => addMetricDialog(context, ref, kind: kind) : () => _history(context, ref),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBadge(metricIcon(kind)),
          const SizedBox(width: Space.m),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.metricKind(kind), style: t.labelMedium?.copyWith(color: context.status.textSecondary)),
              if (latest == null)
                Text(l.noMeasurementYet, style: t.bodyMedium)
              else ...[
                Text(metricValue(l, fmt, latest), style: t.titleLarge),
                Text(
                  [
                    fmt.dateTime(latest.measuredAt),
                    if (change != null && change != 0 && kind != MetricKind.bp) l.changeIn30Days(change > 0 ? '+${fmt.number(change)}' : fmt.number(change)),
                  ].join(' · '),
                  style: t.bodySmall?.copyWith(color: context.status.textSecondary),
                ),
              ],
            ]),
          ),
          if (latest != null) Pill(label: l.activitySource(latest.source), color: AppColors.goldDeep),
        ]),
        if (recent.length > 1) ...[
          const SizedBox(height: Space.m),
          SizedBox(
            height: 32,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (final m in recent)
                Expanded(
                  child: Container(
                    height: top == bottom ? 16 : 6 + 26 * (m.value - bottom) / (top - bottom),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: m == latest ? AppColors.gold : Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ]),
          ),
        ],
      ]),
    );
  }

  void _history(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => Consumer(builder: (ctx, ref, _) {
        final list = metricsOf(ref.watch(dataProvider), kind);
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.7),
            child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l), children: [
              Row(children: [
                Expanded(child: Text(l.metricKind(kind), style: Theme.of(ctx).textTheme.titleMedium)),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    addMetricDialog(context, ref, kind: kind);
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l.addMeasurement),
                ),
              ]),
              for (final m in list)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(metricValue(l, fmt, m)),
                  subtitle: Text([fmt.dateTime(m.measuredAt), l.activitySource(m.source), if (m.note.isNotEmpty) m.note].join(' · ')),
                  trailing: m.source == ActivitySource.manual
                      ? IconButton(
                          tooltip: l.delete,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => ref.read(dataProvider.notifier).deleteMetric(m.id),
                        )
                      : null,
                ),
            ]),
          ),
        );
      }),
    );
  }
}

/// Adds a measurement typed in by the user.
Future<void> addMetricDialog(BuildContext context, WidgetRef ref, {MetricKind? kind}) async {
  final l = AppLocalizations.of(context);
  final saved = await showDialog<bool>(context: context, builder: (_) => _MetricDialog(initial: kind ?? MetricKind.weight));
  if (saved == true && context.mounted) showSnack(context, l.saved);
}

class _MetricDialog extends ConsumerStatefulWidget {
  const _MetricDialog({required this.initial});
  final MetricKind initial;

  @override
  ConsumerState<_MetricDialog> createState() => _MetricDialogState();
}

class _MetricDialogState extends ConsumerState<_MetricDialog> {
  late MetricKind _kind = widget.initial;
  final _value = TextEditingController();
  final _value2 = TextEditingController();
  final _note = TextEditingController();
  bool _bad = false;

  @override
  void dispose() {
    _value.dispose();
    _value2.dispose();
    _note.dispose();
    super.dispose();
  }

  double? _num(String s) => double.tryParse(s.trim().replaceAll(',', '.').replaceAll('٫', '.'));

  void _save() {
    final v = _num(_value.text);
    final v2 = _kind == MetricKind.bp ? _num(_value2.text) : null;
    try {
      if (v == null || (_kind == MetricKind.bp && v2 == null)) throw ArgumentError('value');
      ref.read(dataProvider.notifier).addMetric(kind: _kind, value: v, value2: v2, note: _note.text);
      Navigator.pop(context, true);
    } on ArgumentError {
      setState(() => _bad = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (lo, hi) = BodyMetric.range(_kind);
    final numbers = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,٫]')), LengthLimitingTextInputFormatter(6)];
    return AlertDialog(
      title: Text(l.addMeasurement),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Wrap(spacing: Space.s, runSpacing: Space.s, children: [
            for (final k in MetricKind.values)
              ChoiceChip(label: Text(l.metricKind(k)), selected: _kind == k, onSelected: (_) => setState(() => _kind = k)),
          ]),
          const SizedBox(height: Space.m),
          if (_kind == MetricKind.bp)
            Row(children: [
              Expanded(child: TextField(controller: _value, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: numbers, decoration: InputDecoration(labelText: l.systolic))),
              const SizedBox(width: Space.m),
              Expanded(child: TextField(controller: _value2, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: numbers, decoration: InputDecoration(labelText: l.diastolic))),
            ])
          else
            TextField(
              controller: _value,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: numbers,
              decoration: InputDecoration(labelText: l.metricUnitLabel(_kind)),
            ),
          if (_bad)
            Padding(
              padding: const EdgeInsets.only(top: Space.s),
              child: Text(l.metricOutOfRange(lo.round(), hi.round()), style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          TextField(controller: _note, maxLength: 500, decoration: InputDecoration(labelText: l.workoutNote)),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
        FilledButton(onPressed: _save, child: Text(l.save)),
      ],
    );
  }
}
