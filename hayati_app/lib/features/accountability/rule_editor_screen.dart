import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../data/models/accountability.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/home_logo.dart';

/// Agreeing to a rule in advance: which task, how late is "late", and a
/// harmless consequence the user chooses.
class RuleEditorScreen extends ConsumerStatefulWidget {
  const RuleEditorScreen({super.key, this.ruleId, this.taskId});
  final String? ruleId;
  final String? taskId;

  @override
  ConsumerState<RuleEditorScreen> createState() => _RuleEditorScreenState();
}

class _RuleEditorScreenState extends ConsumerState<RuleEditorScreen> {
  AccountabilityRule? _existing;
  String? _taskId;
  int _grace = 7;
  Consequence _consequence = Consequence.planningSession;
  final _custom = TextEditingController();
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    final d = ref.read(dataProvider);
    _existing = d.rule(widget.ruleId);
    final r = _existing;
    if (r != null) {
      _taskId = r.taskId;
      _grace = r.graceDays;
      _consequence = r.consequence;
      _custom.text = r.customText;
      _agreed = true;
    } else {
      _taskId = widget.taskId;
    }
  }

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  String? _customError(AppLocalizations l) {
    if (_consequence != Consequence.custom) return null;
    return switch (unsafeConsequence(_custom.text)) {
      null => null,
      'empty' => l.accCustomEmpty,
      'long' => l.accCustomLong,
      _ => l.accCustomUnsafe,
    };
  }

  void _save() {
    final l = AppLocalizations.of(context);
    ref.read(dataProvider.notifier).saveRule(AccountabilityRule(
          id: _existing?.id ?? newId(),
          taskId: _taskId!,
          graceDays: _grace,
          consequence: _consequence,
          customText: _consequence == Consequence.custom ? _custom.text.trim() : '',
          active: _existing?.active ?? true,
          createdAt: _existing?.createdAt ?? ref.read(clockProvider)(),
        ));
    showSnack(context, l.accRuleSaved);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final t = Theme.of(context).textTheme;
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    // Open tasks with a deadline and no rule yet (or this rule's task).
    final tasks = d.tasks
        .where((x) => x.isOpen && !x.archived && x.dueDate != null)
        .where((x) => x.id == _taskId || d.ruleForTask(x.id) == null)
        .toList();
    final error = _customError(l);
    final valid = _taskId != null && tasks.any((x) => x.id == _taskId) && error == null && _agreed;

    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? l.accAddRule : l.accEditRule),
        actions: [
          if (_existing != null)
            IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (await confirmDialog(context, title: l.accDeleteRule, message: l.accDeleteRuleBody, confirmLabel: l.delete) &&
                    context.mounted) {
                  ref.read(dataProvider.notifier).deleteRule(_existing!.id);
                  context.pop();
                }
              },
            ), const HomeLogoButton()],
      ),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 120),
          children: [
            SectionHeader(l.accWhichTask),
            if (tasks.isEmpty)
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(l.accNoEligibleTasks),
                  const SizedBox(height: Space.s),
                  TextButton(onPressed: () => context.push(Routes.task('new')), child: Text(l.addTask)),
                ]),
              )
            else
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: tasks.any((x) => x.id == _taskId) ? _taskId : null,
                hint: Text(l.accPickTask),
                items: [
                  for (final x in tasks)
                    DropdownMenuItem(value: x.id, child: Text('${x.title} · ${fmt.day(x.dueDate!)}', overflow: TextOverflow.ellipsis)),
                ],
                onChanged: _existing != null ? null : (v) => setState(() => _taskId = v),
              ),
            const SizedBox(height: Space.xl),
            SectionHeader(l.accWhenLate),
            Wrap(spacing: Space.s, children: [
              for (final g in const [1, 3, 7, 14])
                ChoiceChip(label: Text(l.accDaysLate(g)), selected: _grace == g, onSelected: (_) => setState(() => _grace = g)),
            ]),
            const SizedBox(height: Space.xl),
            SectionHeader(l.accWhatHappens),
            for (final c in Consequence.values)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.s),
                child: AppCard(
                  color: _consequence == c ? context.status.highlight : null,
                  onTap: () => setState(() => _consequence = c),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(_consequence == c ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: Space.m),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c == Consequence.custom ? l.conCustom : l.consequence(c), style: t.titleSmall),
                        Text(
                          switch (c) {
                            Consequence.extraReview => l.conExtraReviewHint,
                            Consequence.planningSession => l.conPlanningHint,
                            Consequence.firstStepFirst => l.conFirstStepHint,
                            Consequence.custom => l.conCustomHint,
                          },
                          style: t.bodySmall?.copyWith(color: context.status.textSecondary),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
            if (_consequence == Consequence.custom) ...[
              const SizedBox(height: Space.s),
              TextField(
                controller: _custom,
                maxLength: 200,
                decoration: InputDecoration(labelText: l.conCustom, errorText: _custom.text.isEmpty ? null : error),
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: Space.l),
            AppCard(
              color: context.status.highlight,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.health_and_safety_outlined, color: AppColors.indigo),
                const SizedBox(width: Space.m),
                Expanded(child: Text(l.accSafety, style: t.bodySmall)),
              ]),
            ),
            const SizedBox(height: Space.m),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _agreed,
              onChanged: (v) => setState(() => _agreed = v ?? false),
              title: Text(l.accAgree),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.l),
          child: ResponsiveContainer(
            maxWidth: 720,
            child: PrimaryButton(label: l.save, onPressed: valid ? _save : null),
          ),
        ),
      ),
    );
  }
}
