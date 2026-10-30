import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/task.dart';
import '../../domain/day_schedule.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/device_notifications_card.dart';
import 'day_overview.dart';

/// Event (fixed appointment) editor — part of the calendar (screen 8).
/// Overlaps are allowed but always flagged.
class EventEditScreen extends ConsumerStatefulWidget {
  const EventEditScreen({super.key, this.eventId, this.date});
  final String? eventId;
  final String? date;

  @override
  ConsumerState<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends ConsumerState<EventEditScreen> {
  final _form = GlobalKey<FormState>();
  late final CalendarEvent? _orig = ref.read(dataProvider).event(widget.eventId);
  late final _title = TextEditingController(text: _orig?.title ?? '');
  late final _location = TextEditingController(text: _orig?.location ?? '');
  late final _notes = TextEditingController(text: _orig?.notes ?? '');
  late DateTime _day = _orig != null
      ? dateOnly(_orig.start)
      : (widget.date != null ? parseDayKey(widget.date!) : dateOnly(DateTime.now()));
  late int _start = _orig == null ? _defaultStart() : _orig.start.hour * 60 + _orig.start.minute;
  late int _end = _orig == null ? _start + 60 : _orig.end.hour * 60 + _orig.end.minute;
  late int? _reminder = _orig?.reminderMinutesBefore;
  bool _dirty = false;

  int _defaultStart() {
    final n = DateTime.now();
    return ((n.hour + 1).clamp(0, 22)) * 60;
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  DateTime get _startAt => atMinutes(_day, _start);
  DateTime get _endAt => atMinutes(_day, _end);

  List<DaySlot> get _clashes =>
      _end > _start ? clashesFor(ref.read(dataProvider), _startAt, _endAt, DateTime.now(), exceptId: _orig?.id) : const [];

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    if (_end <= _start) {
      showSnack(context, l.errEndBeforeStart);
      return;
    }
    // Two things can't happen at once: ask before keeping a clash.
    final clash = _clashes.firstOrNull;
    if (clash != null &&
        !await confirmDialog(context, title: l.conflict, message: l.clashSave(slotLabel(l, clash)), confirmLabel: l.saveAnyway, danger: false)) {
      return;
    }
    if (!mounted) return;
    final e = CalendarEvent(
      id: _orig?.id ?? newId(),
      title: _title.text.trim(),
      start: _startAt,
      end: _endAt,
      location: _location.text.trim(),
      notes: _notes.text.trim(),
      reminderMinutesBefore: _reminder,
      updatedAt: DateTime.now(),
    );
    ref.read(dataProvider.notifier).saveEvent(e);
    _dirty = false;
    showSnack(context, l.saved);
    if (_reminder != null) askForNotificationsIfUnknown(context);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final fmt = Fmt.of(context, use24h: s.use24h);
    ref.watch(dataProvider);
    final clashes = _clashes;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!_dirty || await confirmDiscard(context)) {
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_orig == null ? l.newEvent : l.editEvent),
          actions: [
            if (_orig != null)
              IconButton(
                tooltip: l.delete,
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (await confirmDialog(context, title: l.deleteEventTitle, message: l.deleteEventBody(_orig.title), confirmLabel: l.delete)) {
                    ref.read(dataProvider.notifier).deleteEvent(_orig.id);
                    if (context.mounted) context.pop();
                  }
                },
              ),
          ],
        ),
        body: Form(
          key: _form,
          onChanged: () => _dirty = true,
          child: ResponsiveContainer(
            maxWidth: 640,
            child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
              AppTextField(
                label: l.eventTitle,
                controller: _title,
                autofocus: _orig == null,
                validator: (v) => (v ?? '').trim().isEmpty ? l.errRequired : null,
              ),
              const SizedBox(height: Space.l),
              DatePickerField(label: l.date, value: _day, fmt: fmt, clearable: false, onChanged: (v) => setState(() {
                _day = v ?? _day;
                _dirty = true;
              })),
              const SizedBox(height: Space.l),
              Row(children: [
                Expanded(child: TimePickerField(label: l.startTime, minutes: _start, fmt: fmt, clearable: false, onChanged: (v) => setState(() {
                  final len = _end - _start;
                  _start = v!;
                  _end = (_start + (len > 0 ? len : 60)).clamp(0, 24 * 60 - 1);
                  _dirty = true;
                }))),
                const SizedBox(width: Space.m),
                Expanded(child: TimePickerField(label: l.endTime, minutes: _end, fmt: fmt, clearable: false, onChanged: (v) => setState(() {
                  _end = v!;
                  _dirty = true;
                }))),
              ]),
              if (_end <= _start) ...[
                const SizedBox(height: Space.s),
                Text(l.errEndBeforeStart, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              if (clashes.isNotEmpty) ...[
                const SizedBox(height: Space.s),
                Pill(label: l.conflictWith(slotLabel(l, clashes.first)), color: context.status.warning, icon: Icons.warning_amber),
              ],
              const SizedBox(height: Space.l),
              AppTextField(label: l.locationOptional, controller: _location),
              const SizedBox(height: Space.l),
              Text(l.reminder, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: Space.s),
              DropdownButtonFormField<int?>(
                isExpanded: true,
                initialValue: _reminder,
                items: [
                  DropdownMenuItem(value: null, child: Text(l.noReminder)),
                  for (final m in const [0, 10, 30, 60, 1440])
                    DropdownMenuItem(value: m, child: Text(m == 0 ? l.atTime : l.beforeMinutes(l.durationShort(m)))),
                ],
                onChanged: (v) => setState(() {
                  _reminder = v;
                  _dirty = true;
                }),
              ),
              const SizedBox(height: Space.l),
              AppTextField(label: l.notesOptional, controller: _notes, maxLines: 4),
            ]),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Space.l),
            child: ResponsiveContainer(maxWidth: 640, child: PrimaryButton(label: l.saveEvent, onPressed: _save)),
          ),
        ),
      ),
    );
  }
}
