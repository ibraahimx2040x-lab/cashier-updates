import '../../core/utils/dates.dart';
import '../../data/app_data.dart';
import '../../data/models/assistant.dart';
import '../../data/models/fitness.dart';
import '../../data/models/goal.dart';
import '../../data/models/settings.dart';
import '../../data/models/task.dart';
import '../../l10n/app_localizations.dart';
import '../day_timeline.dart';
import '../fitness/exercises.dart';
import '../fitness/plan_generator.dart';
import '../learning/path.dart';
import '../metrics.dart';
import '../planner.dart';
import 'tools.dart';

/// What the engine wants to say/do in response to one user message.
class EngineReply {
  const EngineReply(
    this.text, {
    this.kind = MessageKind.text,
    this.calls = const [],
    this.reason = '',
    this.warnings = const [],
    this.suggestions = const [],
  });

  final String text;
  final MessageKind kind;

  /// Proposed tool calls; the service decides (via [ToolPolicy]) whether
  /// they run immediately or need review.
  final List<ToolCall> calls;
  final String reason;
  final List<String> warnings;

  /// Quick replies to show (e.g. clarifying "AM / PM").
  final List<String> suggestions;
}

/// The data the assistant is allowed to see, after applying the user's
/// sharing permissions (screen 20). The engine never reads [AppData]
/// directly.
class AssistantContext {
  AssistantContext(AppData d, AssistantPermissions p)
      : tasks = p.shareTasks ? d.tasks : const [],
        events = p.shareEvents ? d.events : const [],
        goals = p.shareGoals ? d.goals : const [],
        milestones = p.shareGoals ? d.milestones : const [],
        habits = p.shareHabits ? d.habits : const [],
        habitLogs = p.shareHabits ? d.habitLogs : const [],
        settings = d.settings,
        fitness = p.shareFitness ? d.settings.fitness : null,
        gymPlan = p.shareFitness ? d.activePlan(WorkoutPlace.gym) : null,
        learning = p.shareLearning ? d : null,
        perms = p,
        _data = d;

  final List<Task> tasks;
  final List<CalendarEvent> events;
  final List<Goal> goals;
  final List<Milestone> milestones;
  final List<Habit> habits;
  final List<HabitLog> habitLogs;
  final UserSettings settings;
  final FitnessProfile? fitness;
  final WorkoutPlan? gymPlan;

  /// Learning data, when shared.
  final AppData? learning;
  final AssistantPermissions perms;
  final AppData _data;

  /// Report over shared data only.
  AppData get filtered => _data.copyWith(
        tasks: tasks,
        events: events,
        goals: goals,
        milestones: milestones,
        habits: habits,
        habitLogs: habitLogs,
        notes: const [],
        expenses: perms.shareExpenses ? _data.expenses : const [],
      );
}

/// On-device, rule-based assistant used in local mode and as a fallback
/// when the AI provider is unreachable. It understands a fixed set of
/// Arabic and English intents and only ever proposes registered tools.
class LocalAssistantEngine {
  const LocalAssistantEngine(this.l);
  final AppLocalizations l;

  EngineReply respond(String input, AssistantContext ctx, DateTime now) {
    final t = normalize(input);
    if (t.isEmpty) return EngineReply(l.aiUnsupported, kind: MessageKind.info);

    if (_has(t, const ['متاخر', 'المتاخره', 'overdue', 'late tasks'])) return _overdue(ctx, now);
    // "I'm late, rearrange the rest of my day": the plan always starts
    // from now, so re-planning is the answer.
    if (_has(t, const ['خطط', 'خطه يومي', 'رتب يومي', 'بقيه يومي', 'تاخرت', 'plan my day', 'plan today', 'plan the day',
        'rest of my day', 'running late'])) {
      return _planDay(ctx, now);
    }
    if (_has(t, const ['اضف ملاحظه', 'ملاحظه:', 'سجل ملاحظه', 'add note', 'add a note', 'note:'])) {
      return _addNote(input);
    }
    if (_has(t, const ['اضف مهمه', 'مهمه جديده', 'ذكرني', 'add task', 'add a task', 'new task', 'remind me'])) {
      return _addTask(input, t, ctx, now);
    }
    if (_has(t, const ['النادي', 'الجيم', 'النادى', 'gym']) &&
        _has(t, const ['ما اقدر', 'ما قدرت', 'مقدر', 'ما راح', 'لن اذهب', 'ما اروح', 'can\'t', 'cannot', 'cant', 'unable', 'skip'])) {
      return _gymAtHome(ctx, now);
    }
    if (_has(t, const ['فاتني الدرس', 'فاتني درس', 'ما ذاكرت', 'ما درست', 'missed my lesson', 'missed the lesson', 'skipped my lesson'])) {
      return _missedLesson(ctx, now);
    }
    final free = _durationMinutes(t);
    if (free != null && _has(t, const ['عندي', 'فاضي', 'وقت', 'i have', 'free', 'spare'])) {
      return _freeTime(ctx, now, free);
    }
    final habit = _matchHabit(t, ctx);
    if (habit != null && _has(t, const ['سجل', 'تم', 'انجزت', 'خلصت', 'done', 'log', 'completed', 'did'])) {
      if (!ctx.perms.shareHabits) return EngineReply(l.aiNeedsSharing(l.navHabits), kind: MessageKind.info);
      return EngineReply(
        l.aiHabitLogged(habit.name),
        calls: [ToolCall(Tools.logHabit, {'habitId': habit.id, 'day': dayKey(now)})],
        reason: l.aiReasonHabit(habit.name),
      );
    }
    if (_has(t, const ['تقسيم هدف', 'قسم هدف', 'break down', 'split my goal', 'milestones for'])) {
      return _splitGoal(ctx, now);
    }
    if (_has(t, const ['اتعلم', 'تعلم', 'ابي اتعلم', 'ابغى اتعلم', 'learn', 'هدف جديد', 'new goal'])) {
      return _learnGoal(input, t, now);
    }
    if (_has(t, const ['تقدم', 'راجع', 'تقرير', 'progress', 'review', 'report', 'how did i do'])) {
      return _review(ctx, now);
    }
    return EngineReply(
      l.aiUnsupported,
      kind: MessageKind.info,
      suggestions: [l.aiChipPlanDay, l.aiChipAddTask, l.aiChipReview],
    );
  }

  // ------------------------------------------------------------- intents

  /// A home version of today's gym workout, saying plainly which
  /// exercises have no real home equivalent.
  EngineReply _gymAtHome(AssistantContext ctx, DateTime now) {
    if (!ctx.perms.shareFitness) return EngineReply(l.aiNeedsSharing(l.navFitness), kind: MessageKind.info);
    final day = ctx.gymPlan?.dayFor(now.weekday);
    if (ctx.fitness == null || ctx.gymPlan == null) return EngineReply(l.aiNoGymPlan, kind: MessageKind.info);
    if (day == null) return EngineReply(l.aiNoGymToday, kind: MessageKind.info);
    final lang = l.localeName;
    String name(PlannedExercise x) => exerciseById(x.exerciseId)!.name(lang);
    final lines = [
      for (final s in homeVersion(day, ctx.fitness!))
        switch (s.kind) {
          SwapKind.same => '• ${name(s.original)}',
          SwapKind.alternative => '• ${name(s.original)} ← ${name(s.replacement!)}',
          SwapKind.approximate => '• ${l.approximateSwap(name(s.original), name(s.replacement!))}',
          SwapKind.none => '• ${l.noHomeAlternative(name(s.original))}',
        },
    ];
    return EngineReply('${l.aiGymAtHome}\n${lines.join('\n')}\n${l.aiGymAtHomeHint}', kind: MessageKind.info);
  }

  /// "I missed my lesson": what's next, whether review comes first, and a
  /// slot today if there's one. Nothing is changed.
  EngineReply _missedLesson(AssistantContext ctx, DateTime now) {
    final d = ctx.learning;
    if (d == null) return EngineReply(l.aiNeedsSharing(l.navEnglish), kind: MessageKind.info);
    if (d.learningPath == null) return EngineReply(l.aiNoEnglishPath, kind: MessageKind.info);
    final lesson = nextLesson(d);
    final due = dueReviews(d, now).length;
    final parts = <String>[
      lesson == null ? l.levelCheckReady : l.aiNextLesson(lesson.title(l.localeName), lesson.minutes),
      if (due > 0) l.aiReviewFirst(due),
    ];
    final slot = buildTimeline(d, now).items.where((i) => i.kind == TimelineKind.lesson).firstOrNull;
    parts.add(slot == null ? l.aiNoSlotToday : l.aiLessonSlot(minutesToHm(slot.start.hour * 60 + slot.start.minute)));
    return EngineReply(parts.join('\n'), kind: MessageKind.info);
  }

  /// Suggests open tasks that fit into [minutes] (no changes proposed).
  EngineReply _freeTime(AssistantContext ctx, DateTime now, int minutes) {
    if (!ctx.perms.shareTasks) return EngineReply(l.aiNeedsSharing(l.navTasks), kind: MessageKind.info);
    final today = dateOnly(now);
    int urgency(Task x) {
      if (x.dueDate == null) return 2;
      return parseDayKey(x.dueDate!).isAfter(today) ? 1 : 0;
    }
    final fits = ctx.tasks
        .where((x) => x.isOpen && !x.archived && x.estimatedMinutes != null && x.estimatedMinutes! <= minutes)
        .toList()
      ..sort((a, b) {
        final u = urgency(a).compareTo(urgency(b));
        if (u != 0) return u;
        return b.priority.index.compareTo(a.priority.index);
      });
    if (fits.isEmpty) return EngineReply(l.aiFreeTimeNone(minutes), kind: MessageKind.info);
    final lines = [for (final x in fits.take(3)) l.aiFreeTimeItem(x.title, x.estimatedMinutes!)];
    return EngineReply('${l.aiFreeTime(minutes)}\n${lines.join('\n')}', kind: MessageKind.info);
  }

  EngineReply _planDay(AssistantContext ctx, DateTime now) {
    if (!ctx.perms.shareTasks) return EngineReply(l.aiNeedsSharing(l.navTasks), kind: MessageKind.info);
    final plan = const Planner().plan(
      day: now,
      now: now,
      tasks: ctx.tasks,
      events: ctx.events,
      settings: ctx.settings,
    );
    if (plan.isEmpty) return EngineReply(l.aiPlanNothing, kind: MessageKind.info);
    final calls = [
      for (final p in plan.planned)
        ToolCall(Tools.planTask, {'taskId': p.task.id, 'plannedStart': encodeInstant(p.start)}),
    ];
    final warnings = <String>[
      if (plan.unscheduled.isNotEmpty) l.aiPlanUnscheduled(plan.unscheduled.length),
      if (plan.planned.any((p) => p.estimated)) l.aiPlanEstimated,
      if (!ctx.perms.shareEvents) l.aiPlanNoEvents,
    ];
    return EngineReply(
      l.aiPlanSummary(plan.planned.length, plan.freeMinutes ~/ 60, plan.freeMinutes % 60),
      kind: calls.isEmpty ? MessageKind.info : MessageKind.plan,
      calls: calls,
      reason: l.aiReasonPlan,
      warnings: warnings,
    );
  }

  EngineReply _overdue(AssistantContext ctx, DateTime now) {
    if (!ctx.perms.shareTasks) return EngineReply(l.aiNeedsSharing(l.navTasks), kind: MessageKind.info);
    final overdue = ctx.tasks.where((t) => t.isOverdue(now)).toList();
    if (overdue.isEmpty) return EngineReply(l.aiNoOverdue, kind: MessageKind.info);
    final plan = const Planner().plan(
      day: now,
      now: now,
      tasks: overdue,
      events: ctx.events,
      settings: ctx.settings,
    );
    final today = dayKey(now);
    final tomorrow = dayKey(dateOnly(now).add(const Duration(days: 1)));
    final calls = <ToolCall>[
      for (final p in plan.planned) ...[
        ToolCall(Tools.moveTask, {'taskId': p.task.id, 'dueDate': today}),
        ToolCall(Tools.planTask, {'taskId': p.task.id, 'plannedStart': encodeInstant(p.start)}),
      ],
      for (final u in plan.unscheduled) ToolCall(Tools.moveTask, {'taskId': u.task.id, 'dueDate': tomorrow}),
    ];
    return EngineReply(
      l.aiOverdueSummary(overdue.length, plan.planned.length, plan.unscheduled.length),
      kind: MessageKind.plan,
      calls: calls,
      reason: l.aiReasonOverdue,
    );
  }

  EngineReply _addNote(String raw) {
    final body = raw
        .replaceFirst(RegExp(r'^\s*(أضف|اضف|سجل|سجّل)\s+ملاحظ[ةه]\s*[:：]?\s*'), '')
        .replaceFirst(RegExp(r'^\s*(add\s+(a\s+)?note|note)\s*[:：]?\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^\s*ملاحظ[ةه]\s*[:：]\s*'), '')
        .trim();
    if (body.isEmpty) return EngineReply(l.aiNoteEmpty, kind: MessageKind.info);
    return EngineReply(l.aiNoteReady, calls: [ToolCall(Tools.addNote, {'body': body})], reason: l.aiReasonNote);
  }

  EngineReply _addTask(String raw, String norm, AssistantContext ctx, DateTime now) {
    final parsed = parseTaskRequest(raw, now);
    if (parsed.title.isEmpty) return EngineReply(l.aiTaskNoTitle, kind: MessageKind.info);
    if (parsed.ambiguousHour != null) {
      final h = parsed.ambiguousHour!;
      return EngineReply(
        l.aiAskAmPm(h),
        kind: MessageKind.info,
        suggestions: [
          '${raw.trim()} ${l.localeName == 'ar' ? 'صباحًا' : 'am'}',
          '${raw.trim()} ${l.localeName == 'ar' ? 'مساءً' : 'pm'}',
        ],
      );
    }
    final args = <String, Object?>{
      'title': parsed.title,
      if (parsed.dueDate != null) 'dueDate': parsed.dueDate,
      if (parsed.dueTime != null) 'dueTime': parsed.dueTime,
      if (parsed.minutes != null) 'estimatedMinutes': parsed.minutes,
      if (parsed.highPriority) 'priority': Priority.high.name,
    };
    final warnings = <String>[];
    if (parsed.dueDate != null && parsed.dueTime != null) {
      final at = atMinutes(parseDayKey(parsed.dueDate!), parsed.dueTime!);
      final clash = ctx.events.where((e) => e.overlaps(at, at.add(Duration(minutes: parsed.minutes ?? 30))));
      if (clash.isNotEmpty) warnings.add(l.aiConflictWith(clash.first.title));
      if (at.isBefore(now)) warnings.add(l.aiTimeInPast);
    }
    return EngineReply(
      l.aiTaskReady(parsed.title),
      calls: [ToolCall(Tools.createTask, args)],
      reason: l.aiReasonTask,
      warnings: warnings,
    );
  }

  EngineReply _splitGoal(AssistantContext ctx, DateTime now) {
    if (!ctx.perms.shareGoals) return EngineReply(l.aiNeedsSharing(l.navGoals), kind: MessageKind.info);
    final candidates = ctx.goals
        .where((g) => g.status == GoalStatus.active && !ctx.milestones.any((m) => m.goalId == g.id))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (candidates.isEmpty) return EngineReply(l.aiNoGoalToSplit, kind: MessageKind.info);
    final g = candidates.first;
    return EngineReply(
      l.aiSplitReady(g.title),
      kind: MessageKind.proposal,
      calls: [
        ToolCall(Tools.addMilestones, {'goalId': g.id, 'titles': _milestoneTemplate(g.title)}),
      ],
      reason: l.aiReasonSplit(g.title),
    );
  }

  EngineReply _learnGoal(String raw, String norm, DateTime now) {
    final subject = _extractSubject(raw);
    if (subject.isEmpty) return EngineReply(l.aiGoalNoSubject, kind: MessageKind.info);
    final minutes = _durationMinutes(norm) ?? 30;
    final days = int.tryParse(RegExp(r'(\d+)\s*(يوم|ايام|days?)').firstMatch(norm)?.group(1) ?? '') ?? 30;
    final title = l.aiGoalTitle(subject);
    final milestones = _milestoneTemplate(subject);
    final start = dateOnly(now).add(const Duration(days: 1));
    final tasks = [
      for (var i = 0; i < 7; i++)
        {
          'title': l.aiSessionTitle(subject, i + 1),
          'dueDate': dayKey(start.add(Duration(days: i))),
          'estimatedMinutes': minutes,
          'milestone': 0,
        },
    ];
    return EngineReply(
      l.aiGoalReady(subject, minutes, days),
      kind: MessageKind.proposal,
      calls: [
        ToolCall(Tools.createGoal, {
          'title': title,
          'category': GoalCategory.learning.name,
          'targetDate': dayKey(dateOnly(now).add(Duration(days: days))),
          'milestones': milestones,
          'tasks': tasks,
        }),
      ],
      reason: l.aiReasonGoal,
      warnings: [l.aiGoalFirstWeekOnly],
    );
  }

  EngineReply _review(AssistantContext ctx, DateTime now) {
    final from = startOfWeek(now, ctx.settings.weekStart);
    final r = PeriodReport.build(ctx.filtered, from, from.add(const Duration(days: 7)), now);
    if (!r.hasData) return EngineReply(l.reportNoData, kind: MessageKind.info);
    final parts = <String>[
      l.aiReviewTasks(r.completed),
      if (r.completionRate != null) l.aiReviewRate((r.completionRate! * 100).round(), r.dueInPeriod),
      if (r.overdue > 0) l.aiReviewOverdue(r.overdue),
      if (r.habitRate != null) l.aiReviewHabits(r.habitDone, r.habitDue),
      for (final (g, p) in r.goals.take(3))
        if (p.percent != null) l.aiReviewGoal(g.title, p.percent!),
      l.aiReviewNote,
    ];
    return EngineReply(parts.join('\n'));
  }

  // ------------------------------------------------------------- helpers

  List<String> _milestoneTemplate(String subject) => [
        l.aiMs1(subject),
        l.aiMs2(subject),
        l.aiMs3(subject),
        l.aiMs4(subject),
      ];

  Habit? _matchHabit(String norm, AssistantContext ctx) {
    for (final h in ctx.habits.where((h) => h.active)) {
      final n = normalize(h.name);
      if (n.isNotEmpty && norm.contains(n)) return h;
    }
    return null;
  }

  static bool _has(String t, List<String> keys) => keys.any(t.contains);

  static String _extractSubject(String raw) {
    final m = RegExp(
      r'(?:أتعلم|اتعلم|تعلم|تعلّم|learn(?:ing)?|هدف\s+جديد|new\s+goal)\s*[:：]?\s*(.+?)'
      r'(?=\s+(?:و\S*|and|كل|every|لمدة|for|في|خلال|يوميا|يوميًا|daily|each|[0-9٠-٩]+)(?:\s|$)|[.،,؟?!]|$)',
      caseSensitive: false,
    ).firstMatch(raw);
    var s = (m?.group(1) ?? '').trim();
    s = s.replaceAll(RegExp(r'^(the|to|how to)\s+', caseSensitive: false), '');
    return s.length > 60 ? s.substring(0, 60) : s;
  }

  static int? _durationMinutes(String norm) {
    final m = RegExp(r'(\d+)\s*(دقيقه|دقائق|دقايق|min|mins|minutes?)').firstMatch(norm);
    if (m != null) return int.parse(m.group(1)!);
    final h = RegExp(r'(\d+)\s*(ساعه|ساعات|hours?|hrs?)').firstMatch(norm);
    if (h != null) return int.parse(h.group(1)!) * 60;
    if (norm.contains('نص ساعه') || norm.contains('half an hour')) return 30;
    if (norm.contains('ساعه') && !norm.contains('الساعه')) return 60;
    return null;
  }
}

/// Lower-cases, strips Arabic diacritics/tatweel and unifies letter forms.
String normalize(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[ً-ْـ]'), '')
    .replaceAll(RegExp('[أإآ]'), 'ا')
    .replaceAll('ة', 'ه')
    .replaceAll('ى', 'ي')
    .replaceAllMapped(RegExp('[٠-٩]'), (m) => '${m[0]!.codeUnitAt(0) - 0x660}')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

class ParsedTask {
  const ParsedTask({
    required this.title,
    this.dueDate,
    this.dueTime,
    this.minutes,
    this.highPriority = false,
    this.ambiguousHour,
  });

  final String title;
  final String? dueDate;
  final int? dueTime;
  final int? minutes;
  final bool highPriority;

  /// Set when an hour was given without AM/PM and could be either.
  final int? ambiguousHour;
}

/// Extracts title, day, time, duration and urgency from e.g.
/// «أضف مهمة مراجعة الإنجليزية غدًا الساعة 8 مساءً» or
/// "add task review English tomorrow at 8pm".
ParsedTask parseTaskRequest(String raw, DateTime now) {
  var text = raw.replaceAllMapped(RegExp('[٠-٩]'), (m) => '${m[0]!.codeUnitAt(0) - 0x660}');
  final norm = normalize(text);

  String? dueDate;
  final today = dateOnly(now);
  if (RegExp(r'بعد\s*(غد|بكر)|day after tomorrow').hasMatch(norm)) {
    dueDate = dayKey(today.add(const Duration(days: 2)));
  } else if (RegExp(r'غدا|بكر[اه]|بكره|tomorrow').hasMatch(norm)) {
    dueDate = dayKey(today.add(const Duration(days: 1)));
  } else if (RegExp(r'اليوم|today|tonight|الليله').hasMatch(norm)) {
    dueDate = dayKey(today);
  }

  int? dueTime;
  int? ambiguous;
  final tm = RegExp(
    r'(?:الساع[ةه]|at|@)?\s*(\d{1,2})(?:[:.](\d{2}))?\s*(صباحًا|صباحا|صباح|الصبح|ص|مساءً|مساءا|مساء|المساء|بالليل|الليل|م|am|a\.m\.|pm|p\.m\.)?(?=\s|$|[.،,])',
    caseSensitive: false,
  );
  for (final m in tm.allMatches(text)) {
    final before = text.substring(0, m.start);
    final hasMarker = m.group(0)!.contains(RegExp(r'الساع|at|@', caseSensitive: false));
    final mer = m.group(3)?.toLowerCase();
    // Only treat a number as a time when it's introduced as one.
    if (!hasMarker && mer == null) continue;
    // Skip numbers that are durations ("30 دقيقة").
    final after = text.substring(m.end).trimLeft();
    if (RegExp(r'^(دقيق|دقائق|ساع|min|hour)', caseSensitive: false).hasMatch(after)) continue;
    var h = int.parse(m.group(1)!);
    final mi = int.tryParse(m.group(2) ?? '') ?? 0;
    if (h > 23 || mi > 59) continue;
    final pm = mer != null && RegExp(r'^(م|مساء|المساء|بالليل|الليل|pm|p\.m\.)').hasMatch(mer);
    final am = mer != null && !pm;
    if (pm && h < 12) h += 12;
    if (am && h == 12) h = 0;
    if (mer == null && h >= 1 && h <= 12 && !norm.contains('الليله') && !norm.contains('tonight')) {
      ambiguous = h;
    }
    if (mer == null && (norm.contains('الليله') || norm.contains('tonight')) && h < 12) h += 12;
    dueTime = h * 60 + mi;
    dueDate ??= dayKey(today);
    text = before + text.substring(m.end);
    break;
  }

  int? minutes;
  final dm = RegExp(r'(?:لمدة|مدة|for)?\s*(\d+)\s*(دقيقة|دقيقه|دقائق|دقايق|min|mins|minutes?|ساعة|ساعه|ساعات|hours?)',
          caseSensitive: false)
      .firstMatch(text);
  if (dm != null) {
    final v = int.parse(dm.group(1)!);
    minutes = RegExp(r'^(ساع|hour)', caseSensitive: false).hasMatch(dm.group(2)!) ? v * 60 : v;
    text = text.replaceRange(dm.start, dm.end, ' ');
  }

  final high = RegExp(r'مهم|عاجل|urgent|important|asap').hasMatch(norm);

  var title = text
      .replaceFirst(
          RegExp(r'^\s*(أضف|اضف|ضيف|سجل)\s+مهم[ةه](\s+جديد[ةه])?\s*[:：]?\s*|^\s*ذكرني\s+(ب|أن|ان)?\s*'), '')
      .replaceFirst(
          RegExp(r'^\s*(add\s+(a\s+)?(new\s+)?task|new\s+task|remind\s+me\s+(to\s+)?)\s*[:：]?\s*',
              caseSensitive: false),
          '')
      .replaceAll(
          RegExp(r'\s*(بعد\s*غد|بعد\s*بكر[ةه]|غدًا|غداً|غدا|بكر[ةه]|اليوم|الليلة|day after tomorrow|tomorrow|today|tonight)\s*',
              caseSensitive: false),
          ' ')
      .replaceAll(RegExp(r'\s*(مهم[ةه]?\s*جدا|عاجل[ةه]?|urgent|important|asap)\s*', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'\s+(في|on|at)\s*$', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  title = title.replaceAll(RegExp(r'^[،,:\-\s]+|[،,.\-\s]+$'), '');

  return ParsedTask(
    title: title,
    dueDate: dueDate,
    dueTime: ambiguous == null ? dueTime : null,
    minutes: minutes,
    highPriority: high,
    ambiguousHour: ambiguous,
  );
}
