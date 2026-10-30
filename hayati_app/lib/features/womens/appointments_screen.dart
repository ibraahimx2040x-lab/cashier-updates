import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/womens.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import 'womens_gate.dart';

IconData appointmentIcon(AppointmentKind k) => switch (k) {
      AppointmentKind.checkup => Icons.medical_services_outlined,
      AppointmentKind.test => Icons.biotech_outlined,
      AppointmentKind.followup => Icons.event_repeat,
      AppointmentKind.other => Icons.event_note,
    };

/// Screen 46 — health appointments and tests: upcoming first, then past.
class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final d = ref.watch(dataProvider);
    if (!appointmentsVisible(d.settings)) return const WomensUnavailable();
    final now = ref.watch(clockProvider)();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final up = d.appointments.where((a) => !a.at.isBefore(now)).toList()..sort((a, b) => a.at.compareTo(b.at));
    final past = d.appointments.where((a) => a.at.isBefore(now)).toList()..sort((a, b) => b.at.compareTo(a.at));

    Widget tile(HealthAppointment a) => Padding(
          padding: const EdgeInsets.only(bottom: Space.s),
          child: AppCard(
            onTap: () => context.push(Routes.appointment(a.id)),
            child: Row(children: [
              IconBadge(appointmentIcon(a.kind)),
              const SizedBox(width: Space.m),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.title, style: t.titleSmall),
                  Text(
                    [fmt.dateTime(a.at), l.appointmentKind(a.kind), if (a.place.isNotEmpty) a.place].join(' · '),
                    style: t.bodySmall?.copyWith(color: context.status.textSecondary),
                  ),
                  if (a.questions.isNotEmpty)
                    Text(l.questionsN(a.questions.length), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                ]),
              ),
              if (a.reminderMinutes != null) const Icon(Icons.notifications_active_outlined, size: 18),
            ]),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.appointments)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.appointment('new')),
        icon: const Icon(Icons.add),
        label: Text(l.addAppointment),
      ),
      body: HealthLockGate(
        child: d.appointments.isEmpty
            ? EmptyState(icon: Icons.event_note, title: l.noAppointments, message: l.noAppointmentsBody)
            : ResponsiveContainer(
                maxWidth: 720,
                child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 120), children: [
                  if (up.isNotEmpty) ...[SectionHeader(l.upcoming), for (final a in up) tile(a)],
                  if (past.isNotEmpty) ...[const SizedBox(height: Space.l), SectionHeader(l.past), for (final a in past) tile(a)],
                  const SizedBox(height: Space.l),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.lock_outline, size: 18, color: context.status.success),
                    const SizedBox(width: Space.s),
                    Expanded(child: Text(l.appointmentReminderNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary))),
                  ]),
                ]),
              ),
      ),
    );
  }
}

/// Adding or editing one appointment, with the questions to ask.
class AppointmentEditScreen extends ConsumerStatefulWidget {
  const AppointmentEditScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<AppointmentEditScreen> createState() => _AppointmentEditScreenState();
}

class _AppointmentEditScreenState extends ConsumerState<AppointmentEditScreen> {
  late final HealthAppointment? _initial = ref.read(dataProvider).appointment(widget.id);
  late final _title = TextEditingController(text: _initial?.title ?? '');
  late final _place = TextEditingController(text: _initial?.place ?? '');
  late final _notes = TextEditingController(text: _initial?.notes ?? '');
  final _question = TextEditingController();
  late AppointmentKind _kind = _initial?.kind ?? AppointmentKind.checkup;
  late DateTime _date = _initial?.at ?? DateTime.now().add(const Duration(days: 1));
  late int _minutes = _initial == null ? 9 * 60 : _initial.at.hour * 60 + _initial.at.minute;
  late final List<String> _questions = [...?_initial?.questions];
  late int? _reminder = _initial == null ? 60 : _initial.reminderMinutes;
  bool _tried = false;

  @override
  void dispose() {
    for (final c in [_title, _place, _notes, _question]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    final q = _question.text.trim();
    if (q.isEmpty || _questions.length >= HealthAppointment.maxQuestions) return;
    setState(() {
      _questions.add(q);
      _question.clear();
    });
  }

  void _save() {
    final l = AppLocalizations.of(context);
    setState(() => _tried = true);
    if (_title.text.trim().isEmpty) return;
    final a = HealthAppointment(
      id: _initial?.id ?? newId(),
      title: _title.text.trim(),
      kind: _kind,
      at: DateTime(_date.year, _date.month, _date.day, _minutes ~/ 60, _minutes % 60),
      place: _place.text.trim(),
      notes: _notes.text.trim(),
      questions: _questions,
      reminderMinutes: _reminder,
      updatedAt: DateTime.now(),
    );
    try {
      ref.read(dataProvider.notifier).saveAppointment(a);
      showSnack(context, l.saved);
      context.pop();
    } on ArgumentError {
      showSnack(context, l.checkFields);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final s = ref.watch(settingsProvider);
    if (!appointmentsVisible(s)) return const WomensUnavailable();
    final fmt = Fmt.of(context, use24h: s.use24h);

    return Scaffold(
      appBar: AppBar(title: Text(_initial == null ? l.addAppointment : l.editAppointment), actions: [
        if (_initial != null)
          IconButton(
            tooltip: l.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              if (await confirmDialog(context, title: l.deleteAppointmentTitle, message: l.deleteAppointmentBody, confirmLabel: l.delete)) {
                ref.read(dataProvider.notifier).deleteAppointment(_initial.id);
                if (context.mounted) context.pop();
              }
            },
          ),
      ]),
      body: HealthLockGate(
        child: ResponsiveContainer(
          maxWidth: 640,
          child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 120), children: [
            TextField(
              controller: _title,
              maxLength: 120,
              decoration: InputDecoration(labelText: l.appointmentTitle, errorText: _tried && _title.text.trim().isEmpty ? l.errRequired : null),
            ),
            Wrap(spacing: Space.s, runSpacing: Space.s, children: [
              for (final k in AppointmentKind.values)
                ChoiceChip(avatar: Icon(appointmentIcon(k), size: 18), label: Text(l.appointmentKind(k)), selected: _kind == k, onSelected: (_) => setState(() => _kind = k)),
            ]),
            const SizedBox(height: Space.l),
            Row(children: [
              Expanded(
                child: DatePickerField(
                  label: l.date,
                  value: _date,
                  fmt: fmt,
                  clearable: false,
                  onChanged: (v) => setState(() => _date = v ?? _date),
                ),
              ),
              const SizedBox(width: Space.m),
              Expanded(
                child: TimePickerField(
                  label: l.time,
                  minutes: _minutes,
                  fmt: fmt,
                  clearable: false,
                  onChanged: (v) => setState(() => _minutes = v ?? _minutes),
                ),
              ),
            ]),
            const SizedBox(height: Space.l),
            TextField(controller: _place, maxLength: 120, decoration: InputDecoration(labelText: l.prayerLocation)),
            TextField(controller: _notes, maxLength: 2000, maxLines: 3, decoration: InputDecoration(labelText: l.modNotes)),
            const SizedBox(height: Space.l),
            Text(l.questionsForDoctor, style: t.titleSmall),
            const SizedBox(height: Space.s),
            for (final (i, q) in _questions.indexed)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.help_outline),
                title: Text(q),
                trailing: IconButton(tooltip: l.delete, icon: const Icon(Icons.close), onPressed: () => setState(() => _questions.removeAt(i))),
              ),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _question,
                  maxLength: 300,
                  decoration: InputDecoration(labelText: l.addQuestion),
                  onSubmitted: (_) => _addQuestion(),
                ),
              ),
              IconButton(tooltip: l.addQuestion, icon: const Icon(Icons.add_circle_outline), onPressed: _addQuestion),
            ]),
            const SizedBox(height: Space.l),
            Text(l.reminder, style: t.titleSmall),
            const SizedBox(height: Space.s),
            Wrap(spacing: Space.s, runSpacing: Space.s, children: [
              ChoiceChip(label: Text(l.none), selected: _reminder == null, onSelected: (_) => setState(() => _reminder = null)),
              for (final m in const [30, 60, 180, 1440])
                ChoiceChip(label: Text(switch (m) { 60 => l.remindHourBefore, 180 => l.remind3HoursBefore, 1440 => l.remindDayBefore, _ => l.remindBeforeN(m) }), selected: _reminder == m, onSelected: (_) => setState(() => _reminder = m)),
            ]),
            const SizedBox(height: Space.s),
            Text(l.appointmentReminderNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
          ]),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.l),
          child: ResponsiveContainer(maxWidth: 640, child: PrimaryButton(label: l.save, icon: Icons.check, onPressed: _save)),
        ),
      ),
    );
  }
}
