import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config.dart';
import '../../core/utils/dates.dart';
import '../../data/data_controller.dart';
import '../../data/models/assistant.dart';
import '../../data/remote/sync.dart';
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

    // Connected: the cloud assistant (Supabase Edge Function) answers and
    // the server enforces limits and executes. If it can't be reached the
    // on-device assistant answers instead.
    final client = ref.read(supabaseClientProvider);
    if (client != null && client.auth.currentSession != null && settings.assistant.enabled) {
      final done = await _sendRemote(client, convId, trimmed, l, gen);
      if (done || gen != _generation) return convId;
    }

    // Keeps the "thinking" state visible and the UI responsive.
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

  /// Returns false when the on-device assistant should answer instead.
  Future<bool> _sendRemote(SupabaseClient client, String convId, String text, AppLocalizations l, int gen) async {
    final Map<String, Object?> r;
    try {
      // The server reads the user's data from the database, so send any
      // queued local changes first.
      await ref.read(syncProvider.notifier).sync().timeout(const Duration(seconds: 8));
      final res = await client.functions.invoke('assistant', body: {
        'conversationId': convId,
        'message': text,
        'now': encodeInstant(_clock()),
        'timeZone': ?await _timeZone(),
        'locale': l.localeName,
      }).timeout(const Duration(seconds: 90));
      r = (res.data as Map).cast<String, Object?>();
    } on FunctionException catch (e) {
      final error = (e.details is Map) ? (e.details as Map)['error'] : null;
      if (gen != _generation) return true;
      switch (error) {
        case 'limit_reached':
          _data.addMessage(convId, MessageRole.assistant, l.aiLimitReached, kind: MessageKind.error);
          state = AssistantUiState(suggestions: state.suggestions);
          return true;
        case 'assistant_disabled':
          _data.addMessage(convId, MessageRole.assistant, l.aiDisabled, kind: MessageKind.info);
          state = AssistantUiState(suggestions: state.suggestions);
          return true;
      }
      debugPrint('cloud assistant unavailable: ${e.status} $error');
      return false;
    } catch (e) {
      debugPrint('cloud assistant unavailable: $e');
      return false;
    }
    if (gen != _generation) return true;

    final reply = (r['reply'] as String?)?.trim() ?? '';
    final kind = r['kind'] as String?;
    final calls = ((r['calls'] as List?) ?? const [])
        .map((c) => ToolCall.fromJson((c as Map).cast<String, Object?>()))
        .toList();
    final actionId = r['actionId'] as String?;

    if (kind == 'error' || (actionId == null && reply.isEmpty)) {
      final msg = r['error'] == 'refusal' ? l.aiRefused : l.aiFailed;
      _data.addMessage(convId, MessageRole.assistant, msg, kind: MessageKind.error);
      state = AssistantUiState(failedDraft: text);
      return true;
    }
    if (actionId == null || calls.isEmpty) {
      final note = r['note'] == 'drafts_disabled' ? '\n${l.aiDraftsDisabled}' : '';
      _data.addMessage(convId, MessageRole.assistant, '$reply$note',
          kind: kind == 'info' ? MessageKind.info : MessageKind.text);
      state = const AssistantUiState();
      return true;
    }

    final status = r['actionStatus'] as String?;
    if (status != null && status != 'pending') {
      // Allowed to run automatically; the server already applied it.
      final ok = status == 'executed';
      _data.addMessage(convId, MessageRole.assistant, ok ? '$reply\n${l.aiAutoDone}' : l.aiExecFailed,
          kind: ok ? MessageKind.text : MessageKind.error);
      if (ok) unawaited(ref.read(syncProvider.notifier).sync());
      state = const AssistantUiState();
      return true;
    }

    final p = ActionProposal(
      id: newId(),
      conversationId: convId,
      reason: reply,
      calls: calls,
      idempotencyKey: actionId,
      createdAt: _clock(),
      remoteId: actionId,
    );
    _data.saveProposal(p);
    _data.addMessage(convId, MessageRole.assistant, reply,
        kind: kind == 'plan' ? MessageKind.plan : MessageKind.proposal, proposalId: p.id);
    state = const AssistantUiState();
    return true;
  }

  static Future<String?> _timeZone() async {
    try {
      return (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (_) {
      return null; // the server falls back to the profile's zone
    }
  }

  /// Executes an approved proposal: on the server for cloud proposals,
  /// otherwise on the device.
  Future<ExecResult> approve(String proposalId) async {
    final p = ref.read(dataProvider).proposal(proposalId);
    final client = ref.read(supabaseClientProvider);
    if (p == null || !p.remote) return executor.executeProposal(proposalId);
    if (p.status == ProposalStatus.executed) return const ExecResult(ExecOutcome.alreadyExecuted);
    if (p.status != ProposalStatus.pending) return const ExecResult(ExecOutcome.notPending);
    if (client == null) return const ExecResult(ExecOutcome.failed, error: 'offline');

    Map<String, Object?> r;
    try {
      final res = await client.functions
          .invoke('assistant/execute', body: {'actionId': p.remoteId})
          .timeout(const Duration(seconds: 30));
      r = (res.data as Map).cast<String, Object?>();
    } catch (e) {
      // Not decided: the user can try again (execution is idempotent).
      return ExecResult(ExecOutcome.failed, error: '$e');
    }
    final outcome = switch (r['outcome']) {
      'executed' => ExecOutcome.executed,
      'already_executed' => ExecOutcome.alreadyExecuted,
      'stale' => ExecOutcome.stale,
      'not_pending' => ExecOutcome.notPending,
      'not_found' => ExecOutcome.invalid,
      _ => ExecOutcome.failed,
    };
    final count = switch (r['applied'] ?? (r['result'] as Map?)?['applied']) { num n => n.toInt(), _ => 0 };
    final current = ref.read(dataProvider).proposal(proposalId) ?? p;
    _data.saveProposal(current.copyWith(
      status: switch (outcome) {
        ExecOutcome.executed || ExecOutcome.alreadyExecuted => ProposalStatus.executed,
        ExecOutcome.stale => ProposalStatus.stale,
        ExecOutcome.notPending => ProposalStatus.rejected,
        _ => ProposalStatus.failed,
      },
      decidedAt: _clock(),
      result: (r['error'] as String?) ?? '$count',
    ));
    if (outcome == ExecOutcome.executed) {
      // Bring the server's changes to the device.
      unawaited(ref.read(syncProvider.notifier).sync());
    }
    return ExecResult(outcome, count: count, error: r['error'] as String?);
  }

  Future<void> reject(String proposalId) async {
    final p = ref.read(dataProvider).proposal(proposalId);
    executor.reject(proposalId);
    final client = ref.read(supabaseClientProvider);
    if (p == null || !p.remote || p.status != ProposalStatus.pending || client == null) return;
    try {
      await client.functions.invoke('assistant/reject', body: {'actionId': p.remoteId});
    } catch (_) {
      // Rejected on the device either way; the server row just stays pending.
    }
  }

  /// Replaces one call's args before approval (the review screen's "edit").
  void editCall(String proposalId, int index, Map<String, Object?> args) {
    final p = ref.read(dataProvider).proposal(proposalId);
    if (p == null || p.remote || p.status != ProposalStatus.pending) return;
    final calls = [...p.calls];
    calls[index] = ToolCall(calls[index].tool, args);
    _data.saveProposal(p.copyWith(calls: calls));
  }

  void removeCall(String proposalId, int index) {
    final p = ref.read(dataProvider).proposal(proposalId);
    if (p == null || p.remote || p.status != ProposalStatus.pending) return;
    final calls = [...p.calls]..removeAt(index);
    if (calls.isEmpty) {
      executor.reject(proposalId);
    } else {
      _data.saveProposal(p.copyWith(calls: calls));
    }
  }
}

final assistantProvider = NotifierProvider<AssistantService, AssistantUiState>(AssistantService.new);
