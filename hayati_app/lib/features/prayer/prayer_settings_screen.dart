import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/prayer.dart';
import '../../domain/prayer_times.dart';
import '../../l10n/app_localizations.dart';
import '../../services/location.dart';
import '../../widgets/common.dart';
import '../../widgets/device_notifications_card.dart';
import '../../widgets/home_logo.dart';

/// Screen 11 — where and how prayer times are calculated, and reminders.
class PrayerSettingsScreen extends ConsumerStatefulWidget {
  const PrayerSettingsScreen({super.key});

  @override
  ConsumerState<PrayerSettingsScreen> createState() => _PrayerSettingsScreenState();
}

class _PrayerSettingsScreenState extends ConsumerState<PrayerSettingsScreen> {
  bool _locating = false;

  void _update(PrayerSettings Function(PrayerSettings) f) =>
      ref.read(dataProvider.notifier).updateSettings((s) => s.copyWith(prayer: f(s.prayer)));

  Future<void> _useMyLocation() async {
    final l = AppLocalizations.of(context);
    setState(() => _locating = true);
    final r = await ref.read(locationServiceProvider).current();
    if (!mounted) return;
    setState(() => _locating = false);
    if (r.failure != null) {
      showSnack(context, switch (r.failure!) {
        LocationFailure.serviceOff => l.locationOff,
        LocationFailure.denied => l.locationDenied,
        LocationFailure.error => l.locationError,
      });
      return;
    }
    _update((p) => p.copyWith(enabled: true, place: '', latitude: () => r.latitude, longitude: () => r.longitude));
    if (mounted) await askForNotificationsIfUnknown(context);
  }

  Future<void> _pickCity() async {
    final city = await showModalBottomSheet<PrayerCity>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CityPicker(),
    );
    if (city == null || !mounted) return;
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    _update((p) => p.copyWith(
          enabled: true,
          place: ar ? city.ar : city.en,
          latitude: () => city.latitude,
          longitude: () => city.longitude,
          method: city.method,
        ));
    if (mounted) await askForNotificationsIfUnknown(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final ps = d.settings.prayer;
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final t = Theme.of(context).textTheme;
    final preview = prayerDay(ps.copyWith(enabled: true), now);

    return Scaffold(
      appBar: AppBar(title: Text(l.prayerSettingsTitle), actions: const [HomeLogoButton()]),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.xxl),
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                title: Text(l.prayerEnable),
                subtitle: Text(l.prayerEnableHint),
                value: ps.enabled,
                onChanged: ps.hasLocation ? (v) => _update((p) => p.copyWith(enabled: v)) : null,
              ),
            ),
            const SizedBox(height: Space.xl),
            SectionHeader(l.prayerLocation),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Icon(Icons.place_outlined, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Text(
                      !ps.hasLocation
                          ? l.prayerNoLocation
                          : ps.place.isNotEmpty
                              ? ps.place
                              : '${l.myLocation} (${ps.latitude!.toStringAsFixed(2)}, ${ps.longitude!.toStringAsFixed(2)})',
                      style: t.titleSmall,
                    ),
                  ),
                ]),
                const SizedBox(height: Space.m),
                Wrap(spacing: Space.s, runSpacing: Space.s, children: [
                  FilledButton.icon(
                    onPressed: _pickCity,
                    icon: const Icon(Icons.location_city),
                    label: Text(l.pickCity),
                  ),
                  OutlinedButton.icon(
                    onPressed: _locating ? null : _useMyLocation,
                    icon: _locating
                        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location),
                    label: Text(l.useMyLocation),
                  ),
                ]),
                const SizedBox(height: Space.s),
                Text(l.locationPrivacy, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
              ]),
            ),
            const SizedBox(height: Space.xl),
            SectionHeader(l.prayerCalculation),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: Space.s),
              child: Column(children: [
                ListTile(
                  title: Text(l.prayerMethodLabel),
                  subtitle: DropdownButton<PrayerMethod>(
                    isExpanded: true,
                    value: ps.method,
                    underline: const SizedBox(),
                    items: [
                      for (final m in PrayerMethod.values) DropdownMenuItem(value: m, child: Text(l.prayerMethod(m))),
                    ],
                    onChanged: (m) => _update((p) => p.copyWith(method: m)),
                  ),
                ),
                SwitchListTile(
                  title: Text(l.hanafiAsr),
                  subtitle: Text(l.hanafiAsrHint),
                  value: ps.hanafiAsr,
                  onChanged: (v) => _update((p) => p.copyWith(hanafiAsr: v)),
                ),
              ]),
            ),
            const SizedBox(height: Space.xl),
            SectionHeader(l.prayerReminders),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: Space.s),
              child: Column(children: [
                SwitchListTile(
                  title: Text(l.prayerNotify),
                  value: ps.notify,
                  onChanged: (v) async {
                    _update((p) => p.copyWith(notify: v));
                    if (v) await askForNotificationsIfUnknown(context);
                  },
                ),
                ListTile(
                  title: Text(l.prayerRemindBefore),
                  trailing: DropdownButton<int>(
                    value: ps.remindBefore,
                    underline: const SizedBox(),
                    items: [
                      for (final m in const [0, 5, 10, 15, 30])
                        DropdownMenuItem(value: m, child: Text(m == 0 ? l.none : l.unitMinutes(m))),
                    ],
                    onChanged: ps.notify ? (m) => _update((p) => p.copyWith(remindBefore: m)) : null,
                  ),
                ),
                ListTile(
                  title: Text(l.prayerBlock),
                  subtitle: Text(l.prayerBlockHint),
                  trailing: DropdownButton<int>(
                    value: ps.blockMinutes,
                    underline: const SizedBox(),
                    items: [
                      for (final m in const [10, 15, 20, 30, 45]) DropdownMenuItem(value: m, child: Text(l.unitMinutes(m))),
                    ],
                    onChanged: (m) => _update((p) => p.copyWith(blockMinutes: m)),
                  ),
                ),
                SwitchListTile(
                  title: Text(l.prayerLogToggle),
                  subtitle: Text(l.prayerLogToggleHint),
                  value: ps.logEnabled,
                  onChanged: (v) => _update((p) => p.copyWith(logEnabled: v)),
                ),
              ]),
            ),
            if (preview != null) ...[
              const SizedBox(height: Space.xl),
              SectionHeader(l.prayerPreview),
              AppCard(
                child: Wrap(spacing: Space.l, runSpacing: Space.s, children: [
                  for (final p in Prayer.values)
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(l.prayerName(p), style: t.labelMedium?.copyWith(color: context.status.textSecondary)),
                      Text(fmt.time(preview[p]), style: t.titleSmall),
                    ]),
                ]),
              ),
              const SizedBox(height: Space.s),
              Text(l.prayerCalcNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CityPicker extends StatefulWidget {
  const _CityPicker();
  @override
  State<_CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<_CityPicker> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final q = _q.trim().toLowerCase();
    final cities = prayerCities.where((c) => q.isEmpty || c.ar.contains(q) || c.en.toLowerCase().contains(q)).toList();
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.s),
            child: SearchField(hint: l.searchCity, onChanged: (v) => setState(() => _q = v)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.location_city),
                title: Text(ar ? cities[i].ar : cities[i].en),
                subtitle: Text(ar ? cities[i].en : cities[i].ar),
                onTap: () => Navigator.pop(context, cities[i]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
