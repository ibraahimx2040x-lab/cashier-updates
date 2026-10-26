import '../../core/utils/dates.dart';

class Conversation {
  const Conversation({required this.id, required this.title, required this.updatedAt});

  final String id;
  final String title;
  final DateTime updatedAt;

  Conversation copyWith({String? title, DateTime? updatedAt}) =>
      Conversation(id: id, title: title ?? this.title, updatedAt: updatedAt ?? this.updatedAt);

  Map<String, Object?> toJson() =>
      {'id': id, 'title': title, 'updatedAt': encodeInstant(updatedAt)};

  factory Conversation.fromJson(Map<String, Object?> j) => Conversation(
        id: j['id'] as String,
        title: j['title'] as String,
        updatedAt: decodeInstant(j['updatedAt'])!,
      );
}

enum MessageRole { user, assistant }

/// What kind of bubble/card to render (screen 13).
enum MessageKind { text, plan, proposal, error, info }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.text,
    this.kind = MessageKind.text,
    this.proposalId,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final MessageRole role;
  final String text;
  final MessageKind kind;
  final String? proposalId;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'role': role.name,
        'text': text,
        'kind': kind.name,
        'proposalId': proposalId,
        'createdAt': encodeInstant(createdAt),
      };

  factory ChatMessage.fromJson(Map<String, Object?> j) => ChatMessage(
        id: j['id'] as String,
        conversationId: j['conversationId'] as String,
        role: MessageRole.values.byName(j['role'] as String),
        text: j['text'] as String,
        kind: MessageKind.values.byName(j['kind'] as String),
        proposalId: j['proposalId'] as String?,
        createdAt: decodeInstant(j['createdAt'])!,
      );
}

/// A single tool invocation inside a proposal. `tool` must be one of the
/// names registered in `AssistantTools`; `args` are validated against that
/// tool's schema before execution.
class ToolCall {
  const ToolCall(this.tool, this.args);

  final String tool;
  final Map<String, Object?> args;

  Map<String, Object?> toJson() => {'tool': tool, 'args': args};

  factory ToolCall.fromJson(Map<String, Object?> j) =>
      ToolCall(j['tool'] as String, (j['args'] as Map).cast<String, Object?>());
}

enum ProposalStatus { pending, executed, rejected, failed, stale }

/// A set of changes the assistant wants to make, shown on the review
/// screen (14) before execution when approval is required.
class ActionProposal {
  const ActionProposal({
    required this.id,
    required this.conversationId,
    required this.reason,
    required this.calls,
    this.status = ProposalStatus.pending,
    required this.idempotencyKey,
    this.snapshot = const {},
    this.warnings = const [],
    required this.createdAt,
    this.decidedAt,
    this.result = '',
    this.remoteId,
  });

  final String id;
  final String conversationId;
  final String reason;
  final List<ToolCall> calls;
  final ProposalStatus status;

  /// Executing the same key twice is a no-op.
  final String idempotencyKey;

  /// `recordId -> updatedAt` of the records the proposal was based on.
  /// If any changed, the proposal is stale and must be regenerated.
  final Map<String, String> snapshot;
  final List<String> warnings;
  final DateTime createdAt;
  final DateTime? decidedAt;
  final String result;

  /// The server's action id when the cloud assistant proposed this. Such
  /// proposals are executed by the server, so they can't be edited here.
  final String? remoteId;

  bool get remote => remoteId != null;

  ActionProposal copyWith({
    ProposalStatus? status,
    DateTime? decidedAt,
    String? result,
    List<ToolCall>? calls,
  }) =>
      ActionProposal(
        id: id,
        conversationId: conversationId,
        reason: reason,
        calls: calls ?? this.calls,
        status: status ?? this.status,
        idempotencyKey: idempotencyKey,
        snapshot: snapshot,
        warnings: warnings,
        createdAt: createdAt,
        decidedAt: decidedAt ?? this.decidedAt,
        result: result ?? this.result,
        remoteId: remoteId,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'reason': reason,
        'calls': calls.map((c) => c.toJson()).toList(),
        'status': status.name,
        'idempotencyKey': idempotencyKey,
        'snapshot': snapshot,
        'warnings': warnings,
        'createdAt': encodeInstant(createdAt),
        'decidedAt': encodeInstant(decidedAt),
        'result': result,
        if (remoteId != null) 'remoteId': remoteId,
      };

  factory ActionProposal.fromJson(Map<String, Object?> j) => ActionProposal(
        id: j['id'] as String,
        conversationId: j['conversationId'] as String,
        reason: j['reason'] as String,
        calls: (j['calls'] as List).map((e) => ToolCall.fromJson((e as Map).cast())).toList(),
        status: ProposalStatus.values.byName(j['status'] as String),
        idempotencyKey: j['idempotencyKey'] as String,
        snapshot: ((j['snapshot'] as Map?) ?? const {}).cast<String, String>(),
        warnings: ((j['warnings'] as List?) ?? const []).cast<String>(),
        createdAt: decodeInstant(j['createdAt'])!,
        decidedAt: decodeInstant(j['decidedAt']),
        result: (j['result'] as String?) ?? '',
        remoteId: j['remoteId'] as String?,
      );
}

/// Audit log entry (`assistant_actions`). Holds no message content.
class ActionLog {
  const ActionLog({
    required this.id,
    required this.tool,
    required this.ok,
    required this.at,
    this.proposalId,
    this.auto = false,
    this.error,
  });

  final String id;
  final String tool;
  final bool ok;
  final DateTime at;
  final String? proposalId;
  final bool auto;
  final String? error;

  Map<String, Object?> toJson() => {
        'id': id,
        'tool': tool,
        'ok': ok,
        'at': encodeInstant(at),
        'proposalId': proposalId,
        'auto': auto,
        'error': error,
      };

  factory ActionLog.fromJson(Map<String, Object?> j) => ActionLog(
        id: j['id'] as String,
        tool: j['tool'] as String,
        ok: j['ok'] as bool,
        at: decodeInstant(j['at'])!,
        proposalId: j['proposalId'] as String?,
        auto: (j['auto'] as bool?) ?? false,
        error: j['error'] as String?,
      );
}
