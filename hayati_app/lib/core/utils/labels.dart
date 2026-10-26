import '../../data/models/goal.dart';
import '../../data/models/misc.dart';
import '../../data/models/prayer.dart';
import '../../data/models/settings.dart';
import '../../data/models/task.dart';
import '../../domain/planner.dart';
import '../../l10n/app_localizations.dart';

/// Localized names for enums and fixed codes.
extension Labels on AppLocalizations {
  String prayerName(Prayer p) => switch (p) {
        Prayer.fajr => prayerFajr,
        Prayer.dhuhr => prayerDhuhr,
        Prayer.asr => prayerAsr,
        Prayer.maghrib => prayerMaghrib,
        Prayer.isha => prayerIsha,
      };

  /// "1 hour 20 minutes" with localized plurals.
  String durationText(int minutes) {
    if (minutes < 60) return unitMinutes(minutes);
    final h = minutes ~/ 60, m = minutes % 60;
    return m == 0 ? unitHours(h) : '${unitHours(h)} ${unitMinutes(m)}';
  }

  String prayerMethod(PrayerMethod m) => switch (m) {
        PrayerMethod.ummAlQura => methodUmmAlQura,
        PrayerMethod.muslimWorldLeague => methodMwl,
        PrayerMethod.egyptian => methodEgyptian,
        PrayerMethod.karachi => methodKarachi,
        PrayerMethod.dubai => methodGulf,
        PrayerMethod.kuwait => methodKuwait,
        PrayerMethod.qatar => methodQatar,
        PrayerMethod.northAmerica => methodIsna,
      };

  String priority(Priority p) => switch (p) {
        Priority.low => priorityLow,
        Priority.medium => priorityMedium,
        Priority.high => priorityHigh,
      };

  String taskStatus(TaskStatus s) => switch (s) {
        TaskStatus.todo => statusTodo,
        TaskStatus.inProgress => statusInProgress,
        TaskStatus.done => statusDone,
        TaskStatus.cancelled => statusCancelled,
      };

  String goalStatus(GoalStatus s) => switch (s) {
        GoalStatus.active => goalActive,
        GoalStatus.paused => goalPaused,
        GoalStatus.completed => goalCompleted,
        GoalStatus.archived => goalArchived,
      };

  String goalCategory(GoalCategory c) => switch (c) {
        GoalCategory.learning => catLearning,
        GoalCategory.health => catHealth,
        GoalCategory.work => catWork,
        GoalCategory.money => catMoney,
        GoalCategory.personal => catPersonal,
      };

  String expenseCategory(String c) => switch (c) {
        'food' => expFood,
        'transport' => expTransport,
        'shopping' => expShopping,
        'education' => expEducation,
        'bills' => expBills,
        'entertainment' => expEntertainment,
        'other' => expOther,
        _ => c,
      };

  String module(AppModule m) => switch (m) {
        AppModule.time => modTime,
        AppModule.learning => modLearning,
        AppModule.habits => modHabits,
        AppModule.expenses => modExpenses,
        AppModule.notes => modNotes,
      };

  String notificationType(NotificationType t) => switch (t) {
        NotificationType.task => navTasks,
        NotificationType.event => eventsLabel,
        NotificationType.habit => navHabits,
        NotificationType.plan => planLabel,
        NotificationType.assistant => navAssistant,
        NotificationType.billing => subscriptionTitle,
      };

  /// 1 = Monday … 7 = Sunday.
  String weekdayShort(int d) => [wdMon, wdTue, wdWed, wdThu, wdFri, wdSat, wdSun][d - 1];

  String toolName(String tool) => switch (tool) {
        'create_task' => toolCreateTask,
        'add_note' => toolAddNote,
        'log_habit' => toolLogHabit,
        'plan_task' => toolPlanTask,
        'move_task' => toolMoveTask,
        'create_goal' => toolCreateGoal,
        'add_milestones' => toolAddMilestones,
        'delete_task' => toolDeleteTask,
        _ => tool,
      };

  String greeting(int hour) => hour < 12 ? goodMorning : (hour < 18 ? goodAfternoon : goodEvening);

  String greetingName(int hour, String name) => '${greeting(hour)}${localeName == 'ar' ? '،' : ','} $name';

  String durationShort(int minutes) {
    if (minutes < 60) return unitMinutes(minutes);
    final h = minutes ~/ 60, m = minutes % 60;
    return m == 0 ? unitHours(h) : '${unitHours(h)} ${unitMinutes(m)}';
  }
}

/// Name of a fixed block in a day plan.
String blockLabel(AppLocalizations l, Block b) => switch (b.kind) {
      BlockKind.prayer => l.prayerName(Prayer.values.byName(b.refId!)),
      BlockKind.work => l.workBlock,
      BlockKind.event => b.label ?? '',
      BlockKind.rest || BlockKind.free => l.restBlock,
    };
