import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/auth.dart';
import '../../data/data_controller.dart';
import '../../data/remote/sync.dart';
import '../../data/models/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/device_notifications_card.dart';
import '../auth/onboarding_screen.dart' show currencies;
import '../../widgets/home_logo.dart';
import '../auth/guest_locked_screen.dart' show GuestCard;

/// Screen 19 — general settings. Changes apply immediately; none of them
/// alter stored records (language, currency and time zone are display-only).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final c = ref.read(dataProvider.notifier);
    final locale = ref.watch(localeProvider);
    final fmt = Fmt.of(context, use24h: s.use24h);
    void up(UserSettings Function(UserSettings) f) => c.updateSettings(f);
    final t = Theme.of(context).textTheme;

    Widget header(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.xl, Space.gutter, Space.s),
          child: Text(text, style: t.titleSmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
        );
    Widget nav(IconData i, String title, String route, {String? sub}) => ListTile(
          leading: IconBadge(i),
          title: Text(title),
          subtitle: sub == null ? null : Text(sub),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(route),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.navSettings), actions: const [HomeLogoButton()]),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: ListView(padding: const EdgeInsets.only(bottom: Space.xxl), children: [
          header(l.account),
          if (ref.watch(authProvider).user?.guest ?? false)
            const Padding(padding: EdgeInsets.symmetric(horizontal: Space.gutter), child: GuestCard(showLeave: true))
          else ...[
            nav(Icons.person_outline, l.profileTitle, Routes.profile),
            nav(Icons.auto_awesome_outlined, l.assistantSettings, Routes.assistantSettings),
            nav(Icons.mosque_outlined, l.prayerSettingsTitle, Routes.prayerSettings),
            nav(Icons.workspace_premium_outlined, l.subscriptionTitle, Routes.subscription),
          ],
          if (ref.watch(authProvider.notifier).remote)
            Builder(builder: (context) {
              final sync = ref.watch(syncProvider);
              return ListTile(
                leading: IconBadge(sync.phase == SyncPhase.offline ? Icons.cloud_off_outlined : Icons.cloud_done_outlined),
                title: Text(l.syncStatus),
                subtitle: Text(sync.pending > 0
                    ? l.syncPending(sync.pending)
                    : (sync.lastSynced == null ? l.syncNever : l.syncUpToDate(fmt.dateTime(sync.lastSynced!)))),
                trailing: sync.phase == SyncPhase.syncing
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : TextButton(onPressed: () => ref.read(syncProvider.notifier).sync(), child: Text(l.syncNow)),
              );
            }),
          header(l.navNotifications),
          const Padding(padding: EdgeInsets.symmetric(horizontal: Space.gutter), child: DeviceNotificationsCard()),
          header(l.appearance),
          ListTile(
            leading: IconBadge(Icons.translate),
            title: Text(l.language),
            trailing: SegmentedButton<String>(
              segments: const [ButtonSegment(value: 'ar', label: Text('ع')), ButtonSegment(value: 'en', label: Text('EN'))],
              selected: {locale.languageCode},
              onSelectionChanged: (v) => ref.read(localeProvider.notifier).set(Locale(v.first)),
            ),
          ),
          ListTile(
            leading: IconBadge(Icons.dark_mode_outlined),
            title: Text(l.theme),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: Space.s),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'light', label: Text(l.themeLight)),
                  ButtonSegment(value: 'dark', label: Text(l.themeDark)),
                  ButtonSegment(value: 'system', label: Text(l.themeSystem)),
                ],
                selected: {s.themeMode},
                onSelectionChanged: (v) => up((x) => x.copyWith(themeMode: v.first)),
              ),
            ),
          ),
          header(l.regional),
          ListTile(
            leading: IconBadge(Icons.public),
            title: Text(l.timezone),
            subtitle: Text('${DateTime.now().timeZoneName} · ${l.timezoneDeviceNote}'),
          ),
          ListTile(
            leading: IconBadge(Icons.payments_outlined),
            title: Text(l.defaultCurrency),
            subtitle: Text(l.currencyChangeNote),
            trailing: DropdownButton<String>(
              value: s.currency,
              underline: const SizedBox.shrink(),
              items: [for (final c in currencies) DropdownMenuItem(value: c, child: Text(c))],
              onChanged: (v) => up((x) => x.copyWith(currency: v)),
            ),
          ),
          ListTile(
            leading: IconBadge(Icons.calendar_view_week),
            title: Text(l.weekStart),
            trailing: DropdownButton<int>(
              value: s.weekStart,
              underline: const SizedBox.shrink(),
              items: [for (final d in const [6, 7, 1]) DropdownMenuItem(value: d, child: Text(l.weekdayShort(d)))],
              onChanged: (v) => up((x) => x.copyWith(weekStart: v)),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.schedule),
            title: Text(l.use24h),
            subtitle: Text(fmt.minutesOfDay(20 * 60 + 30)),
            value: s.use24h,
            onChanged: (v) => up((x) => x.copyWith(use24h: v)),
          ),
          header(l.homeSections),
          SwitchListTile(title: Text(l.todaysHabits), value: s.homeShowHabits, onChanged: (v) => up((x) => x.copyWith(homeShowHabits: v))),
          ListTile(
            title: Text(l.sectionsShown),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: Space.s),
              child: Wrap(spacing: Space.s, runSpacing: Space.s, children: [
                for (final m in AppModule.values)
                  FilterChip(
                    label: Text(l.module(m)),
                    selected: s.has(m),
                    onSelected: (v) => up((x) => x.copyWith(modules: v ? {...x.modules, m} : ({...x.modules}..remove(m)))),
                  ),
              ]),
            ),
          ),
          header(l.planningPrefs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
            child: Column(children: [
              // Bedtime after midnight is stored past 24:00 (v4 change 11).
              Row(children: [
                Expanded(child: TimePickerField(label: l.wakeTime, minutes: s.dayStart, fmt: fmt, clearable: false, onChanged: (v) {
                  final bed = s.dayEnd % (24 * 60);
                  if (v! != bed) up((x) => x.copyWith(dayStart: v, dayEnd: bed <= v ? bed + 24 * 60 : bed));
                })),
                const SizedBox(width: Space.m),
                Expanded(child: TimePickerField(label: l.bedTime, minutes: s.dayEnd % (24 * 60), fmt: fmt, clearable: false, onChanged: (v) {
                  if (v! != s.dayStart) up((x) => x.copyWith(dayEnd: v <= x.dayStart ? v + 24 * 60 : v));
                })),
              ]),
              const SizedBox(height: Space.s),
              Text(l.bedTimeHint, style: t.bodySmall),
              const SizedBox(height: Space.l),
              Row(children: [
                Expanded(child: TimePickerField(label: l.workStart, minutes: s.work?.start, fmt: fmt, onChanged: (v) {
                  up((x) => x.copyWith(work: () => v == null ? null : TimeRange(v, x.work?.end ?? v + 8 * 60)));
                })),
                const SizedBox(width: Space.m),
                Expanded(child: TimePickerField(label: l.workEnd, minutes: s.work?.end, fmt: fmt, onChanged: (v) {
                  up((x) => x.copyWith(work: () => v == null || x.work == null || v <= x.work!.start ? x.work : TimeRange(x.work!.start, v)));
                })),
              ]),
              const SizedBox(height: Space.m),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final d in const [6, 7, 1, 2, 3, 4, 5])
                    FilterChip(
                      showCheckmark: false,
                      label: Text(l.weekdayShort(d)),
                      selected: s.workDays.contains(d),
                      onSelected: (v) => up((x) => x.copyWith(workDays: v ? {...x.workDays, d} : ({...x.workDays}..remove(d)))),
                    ),
                ]),
              ),
              const SizedBox(height: Space.s),
              Text(l.workDaysHint, style: t.bodySmall),
              const SizedBox(height: Space.l),
              Align(alignment: AlignmentDirectional.centerStart, child: Text(l.breaksTitle, style: t.labelMedium)),
              for (final (i, b) in s.breaks.indexed)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.free_breakfast_outlined),
                  title: Text('${fmt.minutesOfDay(b.start)} – ${fmt.minutesOfDay(b.end)}'),
                  trailing: IconButton(
                    tooltip: l.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => up((x) => x.copyWith(breaks: [...x.breaks]..removeAt(i))),
                  ),
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l.addBreak),
                  onPressed: () async {
                    final start = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 13, minute: 0));
                    if (start == null || !context.mounted) return;
                    final end = await showTimePicker(context: context, initialTime: TimeOfDay(hour: (start.hour + 1) % 24, minute: start.minute));
                    if (end == null) return;
                    final a = start.hour * 60 + start.minute, b = end.hour * 60 + end.minute;
                    if (b <= a) {
                      if (context.mounted) showSnack(context, l.errEndBeforeStart);
                      return;
                    }
                    up((x) => x.copyWith(breaks: [...x.breaks, TimeRange(a, b)]..sort((p, q) => p.start.compareTo(q.start))));
                  },
                ),
              ),
            ]),
          ),
          header(l.more),
          nav(Icons.help_outline, l.helpTitle, Routes.help),
          nav(Icons.privacy_tip_outlined, l.privacyTitle, Routes.privacy),
        ]),
      ),
    );
  }
}
