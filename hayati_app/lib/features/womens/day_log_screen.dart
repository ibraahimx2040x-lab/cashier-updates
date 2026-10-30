import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/womens.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import 'womens_gate.dart';

/// Screen 42 — how a day went: flow, pain, symptoms, mood, energy, a note.
/// Everything is optional; clearing all of it removes the day.
class DayLogScreen extends ConsumerStatefulWidget {
  const DayLogScreen({super.key, required this.day});
  final String day;

  @override
  ConsumerState<DayLogScreen> createState() => _DayLogScreenState();
}

class _DayLogScreenState extends ConsumerState<DayLogScreen> {
  late final CycleDayLog? _initial = ref.read(dataProvider).cycleLog(widget.day);
  late FlowLevel? _flow = _initial?.flow;
  late int? _pain = _initial?.pain;
  late final Set<Symptom> _symptoms = {...?_initial?.symptoms};
  late CycleMood? _mood = _initial?.mood;
  late int? _energy = _initial?.energy;
  late final _other = TextEditingController(text: _initial?.otherSymptoms ?? '');
  late final _note = TextEditingController(text: _initial?.note ?? '');

  @override
  void dispose() {
    _other.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final l = AppLocalizations.of(context);
    try {
      ref.read(dataProvider.notifier).saveCycleLog(CycleDayLog(
            id: '',
            day: widget.day,
            flow: _flow,
            pain: _pain,
            symptoms: _symptoms,
            otherSymptoms: _other.text,
            mood: _mood,
            energy: _energy,
            note: _note.text,
            updatedAt: DateTime.now(),
          ));
      showSnack(context, l.saved);
      context.pop();
    } on ArgumentError {
      showSnack(context, l.periodInvalid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final s = ref.watch(settingsProvider);
    if (!womensVisible(s)) return const WomensUnavailable();
    final fmt = Fmt.of(context, use24h: s.use24h);
    final future = parseDayKey(widget.day).isAfter(dateOnly(ref.watch(clockProvider)()));

    Widget section(String title, Widget child) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(title, style: t.titleSmall),
          const SizedBox(height: Space.s),
          child,
          const SizedBox(height: Space.l),
        ]);

    return Scaffold(
      appBar: AppBar(title: Text(fmt.fullDate(parseDayKey(widget.day)))),
      body: HealthLockGate(
        child: future
            ? EmptyState(icon: Icons.event_busy, title: l.futureDay, message: l.futureDayBody)
            : ResponsiveContainer(
                maxWidth: 640,
                child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 120), children: [
                  section(
                    l.flow,
                    Wrap(spacing: Space.s, runSpacing: Space.s, children: [
                      for (final f in FlowLevel.values)
                        ChoiceChip(label: Text(l.flowLevel(f)), selected: _flow == f, onSelected: (v) => setState(() => _flow = v ? f : null)),
                    ]),
                  ),
                  section(
                    _pain == null ? l.pain : '${l.pain}: ${_pain!}/10',
                    Row(children: [
                      Expanded(
                        child: Slider(
                          min: 0,
                          max: 10,
                          divisions: 10,
                          value: (_pain ?? 0).toDouble(),
                          label: '${_pain ?? 0}',
                          onChanged: (v) => setState(() => _pain = v.round()),
                        ),
                      ),
                      if (_pain != null) IconButton(tooltip: l.clear, icon: const Icon(Icons.close), onPressed: () => setState(() => _pain = null)),
                    ]),
                  ),
                  section(
                    l.symptoms,
                    Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Wrap(spacing: Space.s, runSpacing: Space.s, children: [
                        for (final x in Symptom.values)
                          FilterChip(
                            label: Text(l.symptom(x)),
                            selected: _symptoms.contains(x),
                            onSelected: (v) => setState(() => v ? _symptoms.add(x) : _symptoms.remove(x)),
                          ),
                      ]),
                      const SizedBox(height: Space.s),
                      TextField(controller: _other, maxLength: 200, decoration: InputDecoration(labelText: l.otherSymptoms)),
                    ]),
                  ),
                  section(
                    l.mood,
                    Wrap(spacing: Space.s, runSpacing: Space.s, children: [
                      for (final m in CycleMood.values)
                        ChoiceChip(label: Text(l.cycleMood(m)), selected: _mood == m, onSelected: (v) => setState(() => _mood = v ? m : null)),
                    ]),
                  ),
                  section(
                    l.energy,
                    Wrap(spacing: Space.s, runSpacing: Space.s, children: [
                      for (var e = 1; e <= 5; e++)
                        ChoiceChip(label: Text(l.energyN(e)), selected: _energy == e, onSelected: (v) => setState(() => _energy = v ? e : null)),
                    ]),
                  ),
                  TextField(controller: _note, maxLength: 1000, maxLines: 3, decoration: InputDecoration(labelText: l.workoutNote)),
                ]),
              ),
      ),
      bottomNavigationBar: future
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Space.l),
                child: ResponsiveContainer(maxWidth: 640, child: PrimaryButton(label: l.save, icon: Icons.check, onPressed: _save)),
              ),
            ),
    );
  }
}
