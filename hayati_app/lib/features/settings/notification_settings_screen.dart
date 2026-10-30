import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/data_controller.dart';
import '../../data/models/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/device_notifications_card.dart';
import '../../widgets/home_logo.dart';

/// Each section's notifications on or off, and the time of the ones that
/// remind once a day (v4 change 14).
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final s = ref.watch(settingsProvider);
    final n = s.notify;
    final fmt = Fmt.of(context, use24h: s.use24h);
    void up(NotificationPrefs Function(NotificationPrefs) f) =>
        ref.read(dataProvider.notifier).updateSettings((x) => x.copyWith(notify: f(x.notify)));

    (IconData, String, String) about(NotifySection x) => switch (x) {
          NotifySection.tasks => (Icons.check_circle_outline, l.notifSectionTasks, l.notifTasksSub),
          NotifySection.events => (Icons.event_outlined, l.notifSectionEvents, l.notifEventsSub),
          NotifySection.habits => (Icons.repeat, l.notifSectionHabits, l.notifHabitsSub),
          NotifySection.goals => (Icons.flag_outlined, l.notifSectionGoals, l.notifGoalsSub),
          NotifySection.fitness => (Icons.fitness_center, l.notifSectionFitness, l.notifFitnessSub),
          NotifySection.water => (Icons.water_drop_outlined, l.notifSectionWater, l.notifWaterSub),
          NotifySection.learning => (Icons.translate, l.notifSectionLearning, l.notifLearningSub),
          NotifySection.money => (Icons.account_balance_wallet_outlined, l.notifSectionMoney, l.notifMoneySub),
        };

    return Scaffold(
      appBar: AppBar(title: Text(l.notifSettingsTitle), actions: const [HomeLogoButton()]),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl), children: [
          Text(l.notifSettingsSub, style: t.bodyMedium?.copyWith(color: context.status.textSecondary)),
          const SizedBox(height: Space.l),
          const DeviceNotificationsCard(),
          const SizedBox(height: Space.l),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Space.xs),
            child: Column(children: [
              for (final x in NotifySection.values) ...[
                SwitchListTile(
                  secondary: IconBadge(about(x).$1),
                  title: Text(about(x).$2),
                  subtitle: Text(about(x).$3),
                  value: n.on(x),
                  onChanged: (v) => up((p) => p.copyWith(off: v ? ({...p.off}..remove(x)) : {...p.off, x})),
                ),
                if (n.on(x) && !NotificationPrefs.itemTimed.contains(x))
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(72, 0, Space.l, Space.s),
                    child: TimePickerField(
                      label: l.notifTime,
                      minutes: n.timeOf(x),
                      fmt: fmt,
                      clearable: false,
                      onChanged: (v) => up((p) => p.copyWith(times: {...p.times, x: v!})),
                    ),
                  ),
              ],
            ]),
          ),
          const SizedBox(height: Space.m),
          Text(l.notifOtherSections, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
        ]),
      ),
    );
  }
}
