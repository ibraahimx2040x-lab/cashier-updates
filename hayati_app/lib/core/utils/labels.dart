import '../../data/models/accountability.dart';
import '../../data/models/fitness.dart';
import '../../data/models/goal.dart';
import '../../data/models/health.dart';
import '../../data/models/learning.dart';
import '../../data/models/misc.dart';
import '../../data/models/nutrition.dart';
import '../../data/models/prayer.dart';
import '../../data/models/settings.dart';
import '../../data/models/task.dart';
import '../../domain/fitness/exercises.dart';
import '../../domain/nutrition/foods.dart';
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

  String dayFocus(DayFocus f) => switch (f) {
        DayFocus.fullBody => focusFullBody,
        DayFocus.upper => focusUpper,
        DayFocus.lower => focusLower,
        DayFocus.conditioning => focusConditioning,
        DayFocus.mobility => focusMobility,
      };

  String fitnessGoal(FitnessGoal g) => switch (g) {
        FitnessGoal.strength => fgStrength,
        FitnessGoal.muscle => fgMuscle,
        FitnessGoal.fatLoss => fgFatLoss,
        FitnessGoal.general => fgGeneral,
        FitnessGoal.mobility => fgMobility,
      };

  String fitnessGoalHint(FitnessGoal g) => switch (g) {
        FitnessGoal.strength => fgStrengthHint,
        FitnessGoal.muscle => fgMuscleHint,
        FitnessGoal.fatLoss => fgFatLossHint,
        FitnessGoal.general => fgGeneralHint,
        FitnessGoal.mobility => fgMobilityHint,
      };

  String fitnessLevel(FitnessLevel v) => switch (v) {
        FitnessLevel.beginner => flBeginner,
        FitnessLevel.intermediate => flIntermediate,
        FitnessLevel.advanced => flAdvanced,
      };

  String workoutPlace(WorkoutPlace p) => switch (p) {
        WorkoutPlace.home => placeHome,
        WorkoutPlace.gym => placeGym,
      };

  String equipment(Equipment e) => switch (e) {
        Equipment.dumbbells => eqDumbbells,
        Equipment.kettlebell => eqKettlebell,
        Equipment.bands => eqBands,
        Equipment.pullupBar => eqPullupBar,
        Equipment.bench => eqBench,
      };

  String muscle(Muscle m) => switch (m) {
        Muscle.chest => muChest,
        Muscle.back => muBack,
        Muscle.legs => muLegs,
        Muscle.glutes => muGlutes,
        Muscle.shoulders => muShoulders,
        Muscle.arms => muArms,
        Muscle.core => muCore,
        Muscle.fullBody => muFullBody,
        Muscle.cardio => muCardio,
        Muscle.mobility => muMobility,
        Muscle.balance => muBalance,
        Muscle.pelvicFloor => muPelvicFloor,
      };

  String difficulty(int d) => switch (d) {
        1 => diffEasy,
        2 => diffMedium,
        _ => diffHard,
      };

  /// "3 × 10" or "3 × 30 s" / "20 min".
  String prescription(PlannedExercise x) {
    if (x.seconds != null && x.seconds! >= 300) return unitMinutes(x.seconds! ~/ 60);
    final per = x.seconds != null ? secondsShort(x.seconds!) : '${x.reps}';
    return '${x.sets} × $per';
  }

  /// "A2 · Elementary".
  String cefr(Cefr c) => switch (c) {
        Cefr.a1 => cefrA1,
        Cefr.a2 => cefrA2,
        Cefr.b1 => cefrB1,
        Cefr.b2 => cefrB2,
      };

  String skill(Skill s) => switch (s) {
        Skill.vocabulary => skillVocabulary,
        Skill.grammar => skillGrammar,
        Skill.reading => skillReading,
      };

  String consequence(Consequence c, {String custom = ''}) => switch (c) {
        Consequence.extraReview => conExtraReview,
        Consequence.planningSession => conPlanning,
        Consequence.firstStepFirst => conFirstStep,
        Consequence.custom => custom,
      };

  String delayReason(DelayReason r) => switch (r) {
        DelayReason.postponed => drPostponed,
        DelayReason.emergency => drEmergency,
        DelayReason.illness => drIllness,
        DelayReason.notImportant => drNotImportant,
      };

  String eventOutcome(EventOutcome o) => switch (o) {
        EventOutcome.pending => eoPending,
        EventOutcome.consequenceAccepted => eoAccepted,
        EventOutcome.rescheduled => eoRescheduled,
        EventOutcome.dropped => eoDropped,
      };

  String healthModule(HealthModule m) => switch (m) {
        HealthModule.activity => hmActivity,
        HealthModule.nutrition => hmNutrition,
        HealthModule.sleep => hmSleep,
        HealthModule.womens => hmWomens,
        HealthModule.mens => hmMens,
      };

  String healthKind(HealthKind k) => switch (k) {
        HealthKind.steps => hkSteps,
        HealthKind.sleep => hkSleep,
        HealthKind.heartRate => hkHeartRate,
        HealthKind.workouts => hkWorkouts,
      };

  /// What reading [k] brings in, for the permission switches.
  String healthKindSub(HealthKind k) => switch (k) {
        HealthKind.steps => hkStepsSub,
        HealthKind.sleep => hkSleepSub,
        HealthKind.heartRate => hkHeartRateSub,
        HealthKind.workouts => hkWorkoutsSub,
      };

  /// A health store workout code (e.g. RUNNING_TREADMILL) as a word.
  String workoutActivity(String code) => switch (code) {
        'RUNNING' || 'RUNNING_TREADMILL' => woRunning,
        'WALKING' || 'WALKING_TREADMILL' => woWalking,
        'BIKING' || 'BIKING_STATIONARY' => woCycling,
        'SWIMMING' || 'SWIMMING_POOL' || 'SWIMMING_OPEN_WATER' => woSwimming,
        'STRENGTH_TRAINING' || 'TRADITIONAL_STRENGTH_TRAINING' || 'FUNCTIONAL_STRENGTH_TRAINING' || 'WEIGHTLIFTING' || 'CALISTHENICS' || 'CORE_TRAINING' => woStrength,
        'YOGA' => woYoga,
        'PILATES' => woPilates,
        'HIKING' => woHiking,
        'HIGH_INTENSITY_INTERVAL_TRAINING' => woHiit,
        'ELLIPTICAL' => woElliptical,
        'ROWING' || 'ROWING_MACHINE' => woRowing,
        'STAIR_CLIMBING' || 'STAIR_CLIMBING_MACHINE' => woStairs,
        'SOCCER' => woFootball,
        'BASKETBALL' => woBasketball,
        'TENNIS' => woTennis,
        _ => woOther,
      };

  String mealType(MealType m) => switch (m) {
        MealType.breakfast => mealBreakfast,
        MealType.lunch => mealLunch,
        MealType.dinner => mealDinner,
        MealType.snack => mealSnack,
      };

  String foodGroup(FoodGroup g) => switch (g) {
        FoodGroup.grains => fgGrains,
        FoodGroup.dishes => fgDishes,
        FoodGroup.protein => fgProtein,
        FoodGroup.dairy => fgDairy,
        FoodGroup.fruit => fgFruit,
        FoodGroup.vegetables => fgVegetables,
        FoodGroup.drinks => fgDrinks,
        FoodGroup.snacks => fgSnacks,
        FoodGroup.extras => fgExtras,
      };

  String activitySource(ActivitySource s) => switch (s) {
        ActivitySource.healthConnect => sourceHealthConnect,
        ActivitySource.healthKit => sourceHealthKit,
        ActivitySource.phone => sourcePhone,
        ActivitySource.manual => sourceManual,
      };

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
        NotificationType.accountability => navAccountability,
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
