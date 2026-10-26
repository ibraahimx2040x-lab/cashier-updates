import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_controller.dart';
import '../../data/models/assistant.dart';
import '../../l10n/app_localizations.dart';
import 'engine.dart';
import 'executor.dart';
import 'tools.dart';

/// Local display allowance for the free plan. In production the server
/// enforces limits; this value is never trusted for billing.
const freeAssistantDailyLimit = 30;

class AssistantUiState {
  const AssistantUiState({this.busy = false, this.suggestions = const [], this.failedDraft});
  final bool busy;
  final List<String> suggestions;

  /// The user's text when sending failed, so it can be retried.
  final String? failedDraft;
}

class AssistantService extends Notifier<AssistantUiState> {
  int _generation = 0;

  @override
  AssistantUiState build() => const AssistantUiState();

  DataController get _data => ref.read(dataProvider.notifier);
  DateTime Function() get _clock => ref.read(clockProvider);

  AssistantExecutor get executor => AssistantExecutor(_data, _clock);

  /// Stops waiting for the in-flight reply (screen 13 "stop").
  void cancel() {
    _generation++;
    state = AssistantUiState(suggestions: state.suggestions);
  }

  /// Sends [text] and returns the conversation id it was posted to.
  Future<String?> send(String? conversationId, String text, AppLocalizations l) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.busy) return conversationId;
    final settings = ref.read(dataProvider).settings;
    final perms = settings.assistant;

    final convId = conversationId ??
        _data.createConversation(trimmed.length > 40 ? '${trimmed.substring(0, 40)}…' : trimmed).id;
    _data.addMessage(convId, MessageRole.user, trimmed);

    if (!_data.consumeAssistantRequest(freeAssistantDailyLimit)) {
      _data.addMessage(convId, MessageRole.assistant, l.aiLimitReached, kind: MessageKind.error);
      return convId;
    }

    final gen = ++_generation;
    state = const AssistantUiState(busy: true);
    // Keeps the "thinking" state visible and the UI responsive; a remote
    // provider call goes here in connected mode.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (gen != _generation) return convId; // cancelled

    try {
      final now = _clock();
      final reply = LocalAssistantEngine(l).respond(trimmed, AssistantContext(ref.read(dataProvider), perms), now);
      _handle(convId, reply, l);
      state = AssistantUiState(suggestions: reply.suggestions);
    } catch (_) {
      _data.addMessage(convId, MessageRole.assistant, l.aiFailed, kind: MessageKind.error);
      state = AssistantUiState(failedDraft: trimmed);
    }
    return convId;
  }

  void _handle(String convId, EngineReply reply, AppLocalizations l) {
    final perms = ref.read(dataProvider).settings.assistant;
    if (reply.calls.isEmpty) {
      _data.addMessage(convId, MessageRole.assistant, reply.text, kind: reply.kind);
      return;
    }
    if (reply.kind == MessageKind.plan && !perms.autoDraftPlans) {
      _data.addMessage(convId, MessageRole.assistant, '${reply.text}\n${l.aiDraftsDisabled}', kind: MessageKind.info);
      return;
    }

    final tier = ToolPolicy(perms).tierOf(reply.calls);
    if (tier == Tier.autoAllowed) {
      final r = executor.run(reply.calls, auto: true);
      _data.addMessage(
        convId,
        MessageRole.assistant,
        r.ok ? '${reply.text}\n${l.aiAutoDone}' : l.aiExecFailed,
        kind: r.ok ? MessageKind.text : MessageKind.error,
      );
      return;
    }

    final d = ref.read(dataProvider);
    final snapshot = <String, String>{
      for (final c in reply.calls)
        for (final id in referencedIds(c))
          if (versionOf(d, id) != null) id: versionOf(d, id)!,
    };
    final p = ActionProposal(
      id: newId(),
      conversationId: convId,
      reason: reply.reason,
      calls: reply.calls,
      idempotencyKey: newId(),
      snapshot: snapshot,
      warnings: reply.warnings,
      createdAt: _clock(),
    );
    _data.saveProposal(p);
    _data.addMessage(
      convId,
      MessageRole.assistant,
      reply.text,
      kind: reply.kind == MessageKind.plan ? MessageKind.plan : MessageKind.proposal,
      proposalId: p.id,
    );
  }

  /// Replaces one call's args before approval (the review screen's "edit").
  void editCall(String proposalId, int index, Map<String, Object?> args) {
    final p = ref.read(dataProvider).proposal(proposalId);
    if (p == null || p.status != ProposalStatus.pending) return;
    final calls = [...p.calls];
    calls[index] = ToolCall(calls[index].tool, args);
    _data.saveProposal(p.copyWith(calls: calls));
  }

  void removeCall(String proposalId, int index) {
    final p = ref.read(dataProvider).proposal(proposalId);
    if (p == null || p.status != ProposalStatus.pending) return;
    final calls = [...p.calls]..removeAt(index);
    if (calls.isEmpty) {
      executor.reject(proposalId);
    } else {
      _data.saveProposal(p.copyWith(calls: calls));
    }
  }
}

final assistantProvider = NotifierProvider<AssistantService, AssistantUiState>(AssistantService.new);
