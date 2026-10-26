import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/data_controller.dart';
import '../../data/models/misc.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';

const appVersion = '0.1.0';

/// Screen 23 — FAQ and problem reports. Reports never include chats,
/// notes or expenses; technical info is attached only with consent.
class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final faqs = [
      (l.faq1q, l.faq1a),
      (l.faq2q, l.faq2a),
      (l.faq3q, l.faq3a),
      (l.faq4q, l.faq4a),
      (l.faq5q, l.faq5a),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.helpTitle)),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: ListView(padding: const EdgeInsets.symmetric(vertical: Space.m), children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
            child: Text(l.faq, style: Theme.of(context).textTheme.titleMedium),
          ),
          for (final (q, a) in faqs)
            ExpansionTile(
              title: Text(q),
              childrenPadding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.l),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(a)],
            ),
          const Divider(height: Space.xxl),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: Text(l.reportProblem),
            subtitle: Text(l.reportProblemSub),
            onTap: () => showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => const _ReportForm()),
          ),
          ListTile(leading: const Icon(Icons.support_agent), title: Text(l.contactSupport), subtitle: const Text('support@hayati.app')),
          ListTile(leading: const Icon(Icons.info_outline), title: Text(l.appVersion), subtitle: const Text(appVersion)),
        ]),
      ),
    );
  }
}

class _ReportForm extends ConsumerStatefulWidget {
  const _ReportForm();

  @override
  ConsumerState<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends ConsumerState<_ReportForm> {
  final _form = GlobalKey<FormState>();
  final _desc = TextEditingController();
  final _steps = TextEditingController();
  String _kind = 'bug';
  bool _tech = false;

  @override
  void dispose() {
    _desc.dispose();
    _steps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final kinds = {'bug': l.kindBug, 'notifications': l.kindNotifications, 'assistant': l.kindAssistant, 'other': l.kindOther};
    final tech = 'v$appVersion · ${defaultTargetPlatform.name} · ${kIsWeb ? 'web' : 'native'} · ${Localizations.localeOf(context).languageCode}';
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Form(
          key: _form,
          child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l), children: [
            Text(l.reportProblem, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Space.l),
            Wrap(spacing: Space.s, children: [
              for (final e in kinds.entries) ChoiceChip(label: Text(e.value), selected: _kind == e.key, onSelected: (_) => setState(() => _kind = e.key)),
            ]),
            const SizedBox(height: Space.l),
            AppTextField(label: l.problemDescription, controller: _desc, maxLines: 4, validator: (v) => (v ?? '').trim().isEmpty ? l.errRequired : null),
            const SizedBox(height: Space.l),
            AppTextField(label: l.stepsOptional, controller: _steps, maxLines: 3),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _tech,
              onChanged: (v) => setState(() => _tech = v ?? false),
              title: Text(l.includeTechInfo),
              subtitle: Text(tech),
            ),
            Text(l.reportPrivacy, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Space.l),
            PrimaryButton(
              label: l.send,
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                ref.read(dataProvider.notifier).addReport(SupportReport(
                      id: newId(),
                      kind: _kind,
                      description: _desc.text.trim(),
                      steps: _steps.text.trim(),
                      techInfo: _tech ? tech : null,
                      createdAt: DateTime.now(),
                    ));
                Navigator.pop(context);
                showSnack(context, l.reportSaved);
              },
            ),
          ]),
        ),
      ),
    );
  }
}
