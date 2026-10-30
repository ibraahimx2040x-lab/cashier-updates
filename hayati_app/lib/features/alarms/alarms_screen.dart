import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/alarm.dart';
import '../../l10n/app_localizations.dart';
import '../../services/device_notifications.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/home_logo.dart';

String toneName(AppLocalizations l, AlarmTone t) => switch (t) {
      AlarmTone.dawn => l.toneDawn,
      AlarmTone.chime => l.toneChime,
      AlarmTone.bells => l.toneBells,
      AlarmTone.pulse => l.tonePulse,
    };

/// Sounding alarms, apart from quiet notifications (v4 change 15).
class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final d = ref.watch(dataProvider);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final alarms = [...d.alarms]..sort((a, b) => a.minutes.compareTo(b.minutes));
    final now = DateTime.now();
    String repeat(Alarm a) {
      if (!a.repeats) return a.onDate == null ? l.alarmOnce : '${l.alarmOnce} · ${fmt.day(a.onDate!)}';
      if (a.weekdays.length == 7) return l.alarmEveryDay;
      return [for (final w in const [6, 7, 1, 2, 3, 4, 5]) if (a.weekdays.contains(w)) l.weekdayShort(w)].join('، ');
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.alarmsTitle), actions: const [HomeLogoButton()]),
      floatingActionButton: FloatingActionButton(tooltip: l.addAlarm, onPressed: () => showAlarmEditor(context, ref), child: const Icon(Icons.alarm_add)),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 96), children: [
          if (kIsWeb || defaultTargetPlatform == TargetPlatform.iOS) ...[
            AppCard(
              color: context.status.highlight,
              child: Row(children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: Space.m),
                Expanded(child: Text(kIsWeb ? l.alarmsWebNote : l.alarmsIosNote, style: t.bodySmall)),
              ]),
            ),
            const SizedBox(height: Space.m),
          ],
          if (alarms.isEmpty)
            EmptyState(icon: Icons.alarm, title: l.noAlarms, message: l.noAlarmsBody, action: l.addAlarm, onAction: () => showAlarmEditor(context, ref))
          else
            for (final a in alarms)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.s),
                child: AppCard(
                  onTap: () => showAlarmEditor(context, ref, existing: a),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(fmt.minutesOfDay(a.minutes),
                            style: t.displaySmall?.copyWith(fontSize: 34, color: a.enabled ? null : context.status.textSecondary)),
                        Text([if (a.label.isNotEmpty) a.label, repeat(a), toneName(l, a.tone)].join(' · '),
                            style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                        if (a.snoozedUntil != null && a.snoozedUntil!.isAfter(now))
                          Text(l.alarmSnoozed(fmt.time(a.snoozedUntil!)), style: t.bodySmall?.copyWith(color: context.status.warning)),
                      ]),
                    ),
                    Switch(
                      value: a.enabled,
                      onChanged: (v) => ref.read(dataProvider.notifier).saveAlarm(a.copyWith(enabled: v)),
                    ),
                  ]),
                ),
              ),
        ]),
      ),
    );
  }
}

Future<void> showAlarmEditor(BuildContext context, WidgetRef ref, {Alarm? existing}) =>
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => _AlarmEditor(existing: existing));

class _AlarmEditor extends ConsumerStatefulWidget {
  const _AlarmEditor({this.existing});
  final Alarm? existing;

  @override
  ConsumerState<_AlarmEditor> createState() => _AlarmEditorState();
}

class _AlarmEditorState extends ConsumerState<_AlarmEditor> {
  late final Alarm? _e = widget.existing;
  late final _label = TextEditingController(text: _e?.label ?? '');
  late int _minutes = _e?.minutes ?? 6 * 60;
  late Set<int> _days = {...?_e?.weekdays};
  late DateTime _date = _e?.onDate == null ? dateOnly(DateTime.now()) : parseDayKey(_e!.onDate!);
  late AlarmTone _tone = _e?.tone ?? AlarmTone.dawn;
  late bool _vibrate = _e?.vibrate ?? true;
  late int _snooze = _e?.snoozeMinutes ?? 10;
  late String? _link = _e?.taskId != null ? 'task:${_e!.taskId}' : (_e?.eventId != null ? 'event:${_e!.eventId}' : null);

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final c = ref.read(dataProvider.notifier);
    final link = _link?.split(':');
    final a = (_e ?? Alarm(id: newId(), minutes: _minutes, updatedAt: DateTime.now())).copyWith(
      label: _label.text.trim(),
      minutes: _minutes,
      weekdays: _days,
      onDate: () => _days.isEmpty ? dayKey(_date) : null,
      tone: _tone,
      vibrate: _vibrate,
      snoozeMinutes: _snooze,
      enabled: true,
      taskId: () => link?.first == 'task' ? link![1] : null,
      eventId: () => link?.first == 'event' ? link![1] : null,
      snoozedUntil: () => null,
    );
    c.saveAlarm(a);
    final device = ref.read(deviceNotificationsProvider);
    if (device is PluginDeviceNotifications) await device.requestExactAlarms();
    if (mounted) Navigator.pop(context);
  }

  /// Linking to an upcoming task or appointment sets the alarm to its time.
  void _pickLink(String? v, Map<String, (String, DateTime)> items) {
    setState(() {
      _link = v;
      final it = v == null ? null : items[v];
      if (it != null) {
        _minutes = it.$2.hour * 60 + it.$2.minute;
        _date = dateOnly(it.$2);
        _days = {};
        if (_label.text.trim().isEmpty) _label.text = it.$1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final d = ref.watch(dataProvider);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final now = DateTime.now();
    final items = <String, (String, DateTime)>{
      for (final e in d.events.where((e) => e.start.isAfter(now)).take(20)) 'event:${e.id}': (e.title, e.start),
      for (final x in d.tasks.where((x) => x.isOpen && (x.plannedStart ?? x.dueAt)?.isAfter(now) == true).take(20))
        'task:${x.id}': (x.title, (x.plannedStart ?? x.dueAt)!),
    };
    if (_link != null && !items.containsKey(_link)) _link = null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l), children: [
          Row(children: [
            Expanded(child: Text(_e == null ? l.addAlarm : l.editAlarm, style: t.titleLarge)),
            if (_e != null)
              IconButton(
                tooltip: l.delete,
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (await confirmDialog(context, title: l.deleteAlarmTitle, message: _e.label, confirmLabel: l.delete)) {
                    ref.read(dataProvider.notifier).deleteAlarm(_e.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
          ]),
          const SizedBox(height: Space.m),
          TimePickerField(label: l.time, minutes: _minutes, fmt: fmt, clearable: false, onChanged: (v) => setState(() => _minutes = v!)),
          const SizedBox(height: Space.l),
          AppTextField(label: l.alarmLabel, controller: _label, maxLength: 80),
          const SizedBox(height: Space.l),
          Text(l.alarmRepeat, style: t.labelMedium),
          const SizedBox(height: Space.s),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final w in const [6, 7, 1, 2, 3, 4, 5])
              FilterChip(
                showCheckmark: false,
                label: Text(l.weekdayShort(w)),
                selected: _days.contains(w),
                onSelected: (v) => setState(() => _days = v ? {..._days, w} : ({..._days}..remove(w))),
              ),
          ]),
          if (_days.isEmpty) ...[
            const SizedBox(height: Space.m),
            DatePickerField(label: '${l.alarmOnce} · ${l.date}', value: _date, fmt: fmt, clearable: false, onChanged: (v) => setState(() => _date = v ?? _date)),
          ],
          const SizedBox(height: Space.l),
          Text(l.alarmTone, style: t.labelMedium),
          const SizedBox(height: Space.s),
          Wrap(spacing: Space.s, runSpacing: Space.s, children: [
            for (final x in AlarmTone.values)
              ChoiceChip(avatar: const Icon(Icons.music_note_outlined, size: 18), label: Text(toneName(l, x)), selected: _tone == x, onSelected: (_) => setState(() => _tone = x)),
          ]),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(l.alarmVibrate), value: _vibrate, onChanged: (v) => setState(() => _vibrate = v)),
          Text(l.alarmSnoozeFor, style: t.labelMedium),
          const SizedBox(height: Space.s),
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [for (final m in const [5, 10, 15]) ButtonSegment(value: m, label: Text(l.minutesShort(m)))],
            selected: {_snooze},
            onSelectionChanged: (v) => setState(() => _snooze = v.single),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: Space.l),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: _link,
              decoration: InputDecoration(labelText: l.alarmFor),
              items: [
                DropdownMenuItem(value: null, child: Text(l.alarmNone)),
                for (final e in items.entries) DropdownMenuItem(value: e.key, child: Text('${e.value.$1} · ${fmt.dateTime(e.value.$2)}', overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => _pickLink(v, items),
            ),
          ],
          const SizedBox(height: Space.l),
          if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
            Padding(padding: const EdgeInsets.only(bottom: Space.s), child: Text(l.alarmExactNeeded, style: t.bodySmall?.copyWith(color: context.status.textSecondary))),
          PrimaryButton(label: l.save, onPressed: _save),
        ]),
      ),
    );
  }
}
