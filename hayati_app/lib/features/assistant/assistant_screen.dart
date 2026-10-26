import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/data_controller.dart';
import '../../data/models/assistant.dart';
import '../../domain/assistant/assistant_service.dart';
import '../../domain/assistant/executor.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import 'describe.dart';

/// Screen 13 — the assistant conversation.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key, this.prompt});

  /// Pre-fills (does not send) a request, e.g. from "plan my day".
  final String? prompt;

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  String? _conversationId;

  @override
  void initState() {
    super.initState();
    if (widget.prompt != null) _input.text = widget.prompt!;
    final convs = ref.read(dataProvider).conversations;
    if (convs.isNotEmpty) _conversationId = convs.first.id;
  }

  @override
  void didUpdateWidget(AssistantScreen old) {
    super.didUpdateWidget(old);
    if (widget.prompt != null && widget.prompt != old.prompt) _input.text = widget.prompt!;
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final l = AppLocalizations.of(context);
    final msg = text ?? _input.text;
    if (msg.trim().isEmpty) return;
    _input.clear();
    final id = await ref.read(assistantProvider.notifier).send(_conversationId, msg, l);
    if (!mounted) return;
    setState(() => _conversationId = id);
    final failed = ref.read(assistantProvider).failedDraft;
    if (failed != null && _input.text.isEmpty) _input.text = failed;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  void _newChat() => setState(() => _conversationId = null);

  Future<void> _history() async {
    final l = AppLocalizations.of(context);
    final id = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => Consumer(builder: (context, ref, _) {
        final convs = ref.watch(dataProvider.select((d) => d.conversations));
        final fmt = Fmt.of(context);
        return SafeArea(
          child: convs.isEmpty
              ? Padding(padding: const EdgeInsets.all(Space.xl), child: Text(l.noConversations))
              : ListView(shrinkWrap: true, children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.l),
                    child: Text(l.previousChats, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  for (final c in convs)
                    ListTile(
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(fmt.dateTime(c.updatedAt)),
                      selected: c.id == _conversationId,
                      onTap: () => Navigator.pop(sheet, c.id),
                      trailing: IconButton(
                        tooltip: l.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          if (await confirmDialog(context, title: l.deleteChatTitle, message: l.deleteChatBody, confirmLabel: l.delete)) {
                            ref.read(dataProvider.notifier).deleteConversation(c.id);
                            if (c.id == _conversationId) _newChat();
                          }
                        },
                      ),
                    ),
                ]),
        );
      }),
    );
    if (id != null) setState(() => _conversationId = id);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final ui = ref.watch(assistantProvider);
    final perms = d.settings.assistant;
    if (_conversationId != null && !d.conversations.any((c) => c.id == _conversationId)) _conversationId = null;
    final messages = d.messages.where((m) => m.conversationId == _conversationId).toList().reversed.toList();
    final chips = [
      ...ui.suggestions,
      ...[l.aiChipPlanDay, l.aiChipOverdue, l.aiChipSplitGoal, l.aiChipReview, l.aiChipAddTask].where((c) => !ui.suggestions.contains(c)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.assistantTitle),
          Text(l.assistantSubtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.status.textSecondary)),
        ]),
        actions: [
          IconButton(tooltip: l.previousChats, onPressed: _history, icon: const Icon(Icons.history)),
          IconButton(tooltip: l.newChat, onPressed: _newChat, icon: const Icon(Icons.add_comment_outlined)),
          IconButton(tooltip: l.assistantSettings, onPressed: () => context.push(Routes.assistantSettings), icon: const Icon(Icons.tune)),
        ],
      ),
      body: !perms.enabled
          ? EmptyState(
              icon: Icons.auto_awesome_outlined,
              title: l.assistantDisabled,
              message: l.assistantDisabledBody,
              action: l.openSettings,
              onAction: () => context.push(Routes.assistantSettings),
            )
          : ResponsiveContainer(
              maxWidth: 820,
              child: Column(children: [
                Expanded(
                  child: messages.isEmpty
                      ? _Intro(onPick: (t) => _input.text = t)
                      : ListView.builder(
                          controller: _scroll,
                          reverse: true,
                          padding: const EdgeInsets.all(Space.gutter),
                          itemCount: messages.length + (ui.busy ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (ui.busy && i == 0) return const _Thinking();
                            final m = messages[ui.busy ? i - 1 : i];
                            return _Bubble(message: m);
                          },
                        ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
                    children: [
                      for (final c in chips)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: Space.s),
                          child: ActionChip(label: Text(c), onPressed: ui.busy ? null : () => _send(c)),
                        ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, Space.m),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.send,
                          onSubmitted: ui.busy ? null : (_) => _send(),
                          decoration: InputDecoration(hintText: l.assistantHint),
                        ),
                      ),
                      const SizedBox(width: Space.s),
                      ui.busy
                          ? IconButton.filledTonal(
                              tooltip: l.stop,
                              onPressed: () => ref.read(assistantProvider.notifier).cancel(),
                              icon: const Icon(Icons.stop),
                            )
                          : IconButton.filled(tooltip: l.send, onPressed: () => _send(), icon: const Icon(Icons.send)),
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.s),
                  child: Text(
                    l.usageToday(ref.read(dataProvider.notifier).assistantUsageToday(), freeAssistantDailyLimit),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.status.textSecondary),
                  ),
                ),
              ]),
            ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onPick});
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(padding: const EdgeInsets.all(Space.xl), children: [
      Icon(Icons.auto_awesome, size: 40, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: Space.l),
      Text(l.assistantIntroTitle, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
      const SizedBox(height: Space.s),
      Text(l.assistantIntroBody, textAlign: TextAlign.center),
      const SizedBox(height: Space.xl),
      for (final ex in [l.aiExample1, l.aiExample2, l.aiExample3])
        Padding(
          padding: const EdgeInsets.only(bottom: Space.s),
          child: AppCard(onTap: () => onPick(ex), child: Row(children: [
            const Icon(Icons.lightbulb_outline, size: 20),
            const SizedBox(width: Space.m),
            Expanded(child: Text(ex)),
          ])),
        ),
    ]);
  }
}

class _Thinking extends StatelessWidget {
  const _Thinking();

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.s),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: Space.s),
            Text(AppLocalizations.of(context).thinking),
          ]),
        ),
      );
}

class _Bubble extends ConsumerWidget {
  const _Bubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final mine = message.role == MessageRole.user;
    final isErr = message.kind == MessageKind.error;
    final bg = mine
        ? scheme.primary
        : (isErr ? scheme.error.withValues(alpha: 0.08) : scheme.surface);
    final fg = mine ? scheme.onPrimary : scheme.onSurface;
    final radius = BorderRadiusDirectional.only(
      topStart: const Radius.circular(Radii.card),
      topEnd: const Radius.circular(Radii.card),
      bottomStart: Radius.circular(mine ? Radii.card : 4),
      bottomEnd: Radius.circular(mine ? 4 : Radii.card),
    );
    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.85 > 620 ? 620 : MediaQuery.sizeOf(context).width * 0.85),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: Space.xs),
          padding: const EdgeInsets.all(Space.m),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: mine ? null : Border.all(color: isErr ? scheme.error.withValues(alpha: 0.4) : scheme.outlineVariant),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (isErr) ...[Icon(Icons.error_outline, size: 18, color: scheme.error), const SizedBox(width: Space.s)],
              if (message.kind == MessageKind.info) ...[Icon(Icons.info_outline, size: 18, color: context.status.info), const SizedBox(width: Space.s)],
              Flexible(child: SelectableText(message.text, style: TextStyle(color: fg))),
            ]),
            if (message.proposalId != null) _ProposalCard(proposalId: message.proposalId!),
          ]),
        ),
      ),
    );
  }
}

/// Inline card for a plan / proposal with approve, edit, cancel.
class _ProposalCard extends ConsumerWidget {
  const _ProposalCard({required this.proposalId});
  final String proposalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final p = d.proposal(proposalId);
    if (p == null) return const SizedBox.shrink();
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final t = Theme.of(context).textTheme;
    final s = context.status;
    final descs = [for (final c in p.calls) describeCall(c, d, l, fmt)];

    final status = switch (p.status) {
      ProposalStatus.pending => null,
      ProposalStatus.executed => (l.proposalExecuted, s.success, Icons.check_circle_outline),
      ProposalStatus.rejected => (l.proposalRejected, s.inactive, Icons.block),
      ProposalStatus.failed => (l.proposalFailed, Theme.of(context).colorScheme.error, Icons.error_outline),
      ProposalStatus.stale => (l.proposalStale, s.warning, Icons.update),
    };

    return Container(
      margin: const EdgeInsets.only(top: Space.m),
      padding: const EdgeInsets.all(Space.m),
      decoration: BoxDecoration(color: s.highlight, borderRadius: BorderRadius.circular(Radii.button)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.changesCount(p.calls.length), style: t.labelMedium),
        const SizedBox(height: Space.s),
        for (final dsc in descs.take(6))
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• ${dsc.title}: ${dsc.subject}${dsc.lines.isEmpty ? '' : ' — ${dsc.lines.first.next}'}',
                style: t.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        if (descs.length > 6) Text(l.andMore(descs.length - 6), style: t.bodySmall),
        for (final w in p.warnings)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              Icon(Icons.warning_amber, size: 16, color: s.warning),
              const SizedBox(width: 4),
              Expanded(child: Text(w, style: t.bodySmall)),
            ]),
          ),
        const SizedBox(height: Space.m),
        if (status != null)
          Pill(label: status.$1, color: status.$2, icon: status.$3)
        else
          Wrap(spacing: Space.s, runSpacing: Space.s, children: [
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
              onPressed: () async {
                final r = await ref.read(assistantProvider.notifier).approve(p.id);
                if (context.mounted) _report(context, ref, r);
              },
              child: Text(l.approve),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(64, 40)),
              onPressed: () => context.push(Routes.review(p.id)),
              child: Text(p.remote ? l.details : l.edit),
            ),
            TextButton(
              onPressed: () => ref.read(assistantProvider.notifier).reject(p.id),
              child: Text(l.cancel),
            ),
          ]),
      ]),
    );
  }
}

void _report(BuildContext context, WidgetRef ref, ExecResult r) {
  final l = AppLocalizations.of(context);
  final c = ref.read(dataProvider.notifier);
  switch (r.outcome) {
    case ExecOutcome.executed:
      showSnack(context, l.executedCount(r.count),
          actionLabel: r.undo.isEmpty ? null : l.undo, onAction: () => c.restoreTasks(r.undo));
    case ExecOutcome.alreadyExecuted:
      showSnack(context, l.alreadyExecuted);
    case ExecOutcome.stale:
      showSnack(context, l.proposalStale);
    case ExecOutcome.invalid:
    case ExecOutcome.failed:
      showSnack(context, l.aiExecFailed);
    case ExecOutcome.notPending:
      break;
  }
}

/// Shared with the review screen.
void reportExecution(BuildContext context, WidgetRef ref, ExecResult r) => _report(context, ref, r);
