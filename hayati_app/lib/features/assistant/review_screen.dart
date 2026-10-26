import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/data_controller.dart';
import '../../data/models/assistant.dart';
import '../../domain/assistant/assistant_service.dart';
import '../../domain/assistant/tools.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import 'assistant_screen.dart';
import 'describe.dart';

/// Screen 14 — review what the assistant wants to change before it runs.
/// One generic preview for every action type.
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, required this.proposalId});
  final String proposalId;

  Future<void> _editTitle(BuildContext context, WidgetRef ref, ActionProposal p, int i) async {
    final l = AppLocalizations.of(context);
    final call = p.calls[i];
    final key = call.tool == Tools.createGoal || call.tool == Tools.createTask ? 'title' : 'body';
    final c = TextEditingController(text: call.args[key] as String? ?? '');
    final r = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.edit),
        content: TextField(controller: c, autofocus: true, maxLines: key == 'body' ? 4 : 1),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: Text(l.save)),
        ],
      ),
    );
    c.dispose();
    if (r == null || r.isEmpty) return;
    ref.read(assistantProvider.notifier).editCall(p.id, i, {...call.args, key: r});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final p = d.proposal(proposalId);
    final t = Theme.of(context).textTheme;
    if (p == null) {
      return Scaffold(appBar: AppBar(), body: ErrorState(message: l.proposalNotFound));
    }
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final pending = p.status == ProposalStatus.pending;
    final svc = ref.read(assistantProvider.notifier);
    final editable = {Tools.createTask, Tools.createGoal, Tools.addNote};

    return Scaffold(
      appBar: AppBar(title: Text(l.reviewChanges)),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
          AppCard(
            color: context.status.highlight,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.reason, style: t.labelMedium),
              const SizedBox(height: 4),
              Text(p.reason),
              const SizedBox(height: Space.m),
              Text(l.affectedItems(p.calls.length), style: t.titleSmall),
            ]),
          ),
          for (final w in p.warnings) ...[
            const SizedBox(height: Space.s),
            Row(children: [
              Icon(Icons.warning_amber, color: context.status.warning),
              const SizedBox(width: Space.s),
              Expanded(child: Text(w)),
            ]),
          ],
          if (!pending) ...[
            const SizedBox(height: Space.m),
            Text(switch (p.status) {
              ProposalStatus.executed => l.proposalExecuted,
              ProposalStatus.rejected => l.proposalRejected,
              ProposalStatus.failed => l.proposalFailed,
              ProposalStatus.stale => l.proposalStale,
              ProposalStatus.pending => '',
            }, style: t.titleSmall),
          ],
          const SizedBox(height: Space.l),
          for (var i = 0; i < p.calls.length; i++)
            Builder(builder: (context) {
              final dsc = describeCall(p.calls[i], d, l, fmt);
              return Padding(
                padding: const EdgeInsets.only(bottom: Space.s),
                child: AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(dsc.title, style: t.labelMedium?.copyWith(color: context.status.textSecondary)),
                          Text(dsc.subject, style: t.titleSmall),
                        ]),
                      ),
                      if (pending && editable.contains(p.calls[i].tool))
                        IconButton(tooltip: l.edit, icon: const Icon(Icons.edit_outlined), onPressed: () => _editTitle(context, ref, p, i)),
                      if (pending)
                        IconButton(tooltip: l.removeItem, icon: const Icon(Icons.remove_circle_outline), onPressed: () => svc.removeCall(p.id, i)),
                    ]),
                    for (final line in dsc.lines)
                      Padding(
                        padding: const EdgeInsets.only(top: Space.s),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          SizedBox(width: 120, child: Text(line.label, style: t.bodySmall)),
                          Expanded(
                            child: line.current == null
                                ? Text(line.next, style: t.bodyMedium)
                                : Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, children: [
                                    Text(line.current!, style: t.bodyMedium?.copyWith(decoration: TextDecoration.lineThrough, color: context.status.textSecondary)),
                                    const Icon(Icons.arrow_forward, size: 14),
                                    Text(line.next, style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                  ]),
                          ),
                        ]),
                      ),
                  ]),
                ),
              );
            }),
        ]),
      ),
      bottomNavigationBar: !pending
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Space.l),
                child: ResponsiveContainer(
                  maxWidth: 720,
                  child: Row(children: [
                    Expanded(
                      child: SecondaryButton(
                        label: l.reject,
                        onPressed: () {
                          svc.executor.reject(p.id);
                          context.pop();
                        },
                      ),
                    ),
                    const SizedBox(width: Space.m),
                    Expanded(
                      child: PrimaryButton(
                        label: l.execute,
                        onPressed: () {
                          final r = svc.executor.executeProposal(p.id);
                          reportExecution(context, ref, r);
                          if (r.ok) context.pop();
                        },
                      ),
                    ),
                  ]),
                ),
              ),
            ),
    );
  }
}
