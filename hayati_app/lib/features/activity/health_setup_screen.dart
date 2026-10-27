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
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

IconData _icon(HealthModule m) => switch (m) {
      HealthModule.activity => Icons.directions_walk,
      HealthModule.nutrition => Icons.restaurant_outlined,
      HealthModule.sleep => Icons.bedtime_outlined,
      HealthModule.womens => Icons.female,
      HealthModule.mens => Icons.male,
    };

/// Screen 33 — which health sections are on, the daily step goal, height
/// (for distance) and move reminders.
class HealthSetupScreen extends ConsumerStatefulWidget {
  const HealthSetupScreen({super.key});

  @override
  ConsumerState<HealthSetupScreen> createState() => _HealthSetupScreenState();
}

class _HealthSetupScreenState extends ConsumerState<HealthSetupScreen> {
  late final _height = TextEditingController(text: ref.read(settingsProvider).health.heightCm?.toString() ?? '');

  @override
  void dispose() {
    _height.dispose();
    super.dispose();
  }

  void _up(HealthSettings Function(HealthSettings) f) => ref.read(dataProvider.notifier).updateHealth(f);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final h = s.health;
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context, use24h: s.use24h);
    // Only the section matching the sex chosen at sign-up is offered.
    final modules = [
      HealthModule.activity,
      HealthModule.nutrition,
      HealthModule.sleep,
      if (s.sex != Sex.male) HealthModule.womens,
      if (s.sex != Sex.female) HealthModule.mens,
    ];
    const ready = {HealthModule.activity, HealthModule.nutrition, HealthModule.sleep};
    final heightVal = int.tryParse(_height.text);
    final heightError = _height.text.isNotEmpty && (heightVal == null || heightVal < 80 || heightVal > 250);

    return Scaffold(
      appBar: AppBar(title: Text(l.healthSetup)),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl), children: [
          SectionHeader(l.healthSections),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Space.s),
            child: Column(children: [
              for (final m in modules)
                SwitchListTile(
                  secondary: IconBadge(_icon(m)),
                  title: Row(children: [
                    Flexible(child: Text(l.healthModule(m))),
                    if (!ready.contains(m)) ...[
                      const SizedBox(width: Space.s),
                      Pill(label: l.comingSoon, color: AppColors.goldDeep),
                    ],
                  ]),
                  value: h.has(m),
                  onChanged: (v) => _up((x) => x.copyWith(modules: v ? {...x.modules, m} : ({...x.modules}..remove(m)))),
                ),
            ]),
          ),
          const SizedBox(height: Space.xs),
          Text(l.healthSectionsNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
          const SizedBox(height: Space.l),
          AppCard(
            onTap: () => context.push(Routes.devices),
            child: Row(children: [
              const IconBadge(Icons.watch_outlined),
              const SizedBox(width: Space.m),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.devicesTitle, style: t.titleSmall),
                  Text(l.devicesSub, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                ]),
              ),
              const Icon(Icons.chevron_right),
            ]),
          ),
          if (h.has(HealthModule.nutrition)) ...[
            const SizedBox(height: Space.xl),
            SectionHeader(l.foodAndWater),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.kcalGoalOn),
                  subtitle: Text(l.kcalGoalSub),
                  value: h.kcalGoal != null,
                  onChanged: (v) => _up((x) => x.copyWith(kcalGoal: () => v ? 2000 : null)),
                ),
                if (h.kcalGoal != null) ...[
                  Text(l.kcalN(fmt.number(h.kcalGoal!)), style: t.titleMedium),
                  Slider(
                    min: 1200,
                    max: 4000,
                    divisions: 28,
                    value: h.kcalGoal!.clamp(1200, 4000).toDouble(),
                    label: fmt.number(h.kcalGoal!),
                    onChanged: (v) => _up((x) => x.copyWith(kcalGoal: () => v.round())),
                  ),
                ],
                const SizedBox(height: Space.s),
                Text(l.waterGoal, style: t.titleSmall),
                const SizedBox(height: Space.s),
                Wrap(spacing: Space.s, children: [
                  for (final ml in const [1500, 2000, 2500, 3000])
                    ChoiceChip(label: Text(l.waterMl(fmt.number(ml))), selected: h.waterGoalMl == ml, onSelected: (_) => _up((x) => x.copyWith(waterGoalMl: ml))),
                ]),
              ]),
            ),
          ],
          const SizedBox(height: Space.xl),
          SectionHeader(l.stepGoal),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(l.stepsPerDay(fmt.number(h.stepGoal)), style: t.titleMedium),
              Slider(
                min: 2000,
                max: 20000,
                divisions: 36,
                value: h.stepGoal.clamp(2000, 20000).toDouble(),
                label: fmt.number(h.stepGoal),
                onChanged: (v) => _up((x) => x.copyWith(stepGoal: v.round())),
              ),
              Wrap(spacing: Space.s, children: [
                for (final g in const [5000, 7500, 10000])
                  ChoiceChip(label: Text(fmt.number(g)), selected: h.stepGoal == g, onSelected: (_) => _up((x) => x.copyWith(stepGoal: g))),
              ]),
            ]),
          ),
          const SizedBox(height: Space.xl),
          SectionHeader(l.heightForDistance),
          TextField(
            controller: _height,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
            decoration: InputDecoration(labelText: l.heightCm, helperText: l.heightHelp, errorText: heightError ? l.heightInvalid : null),
            onChanged: (v) {
              setState(() {});
              final n = int.tryParse(v);
              if (v.isEmpty) {
                _up((x) => x.copyWith(heightCm: () => null));
              } else if (n != null && n >= 80 && n <= 250) {
                _up((x) => x.copyWith(heightCm: () => n));
              }
            },
          ),
          const SizedBox(height: Space.xl),
          SectionHeader(l.moveReminders),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.moveRemindersOn),
                subtitle: Text(l.moveRemindersSub),
                value: h.moveReminders,
                onChanged: (v) => _up((x) => x.copyWith(moveReminders: v)),
              ),
              if (h.moveReminders) ...[
                Wrap(spacing: Space.s, children: [
                  for (final m in const [60, 90, 120, 180])
                    ChoiceChip(label: Text(l.everyMinutes(m)), selected: h.moveEvery == m, onSelected: (_) => _up((x) => x.copyWith(moveEvery: m))),
                ]),
                const SizedBox(height: Space.m),
                Row(children: [
                  Expanded(
                    child: TimePickerField(
                      label: l.from,
                      minutes: h.moveStart,
                      fmt: fmt,
                      clearable: false,
                      onChanged: (v) {
                        if (v != null && v < h.moveEnd) _up((x) => x.copyWith(moveStart: v));
                      },
                    ),
                  ),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: TimePickerField(
                      label: l.to,
                      minutes: h.moveEnd,
                      fmt: fmt,
                      clearable: false,
                      onChanged: (v) {
                        if (v != null && v > h.moveStart) _up((x) => x.copyWith(moveEnd: v));
                      },
                    ),
                  ),
                ]),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}
