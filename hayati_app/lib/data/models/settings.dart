import 'fitness.dart';
import 'health.dart';
import 'prayer.dart';

/// Per-user preferences (the `profiles` table on the server).
class TimeRange {
  const TimeRange(this.start, this.end);
  final int start; // minutes since midnight
  final int end;

  Map<String, Object?> toJson() => {'start': start, 'end': end};
  factory TimeRange.fromJson(Map<String, Object?> j) =>
      TimeRange(j['start'] as int, j['end'] as int);
}

enum AppModule { time, learning, habits, expenses, notes }

/// Each assistant capability is a separate, revocable grant (screen 20).
/// There is deliberately no "allow everything" switch.
class AssistantPermissions {
  const AssistantPermissions({
    this.enabled = true,
    this.autoCreateTasks = false,
    this.autoAddNotes = false,
    this.autoLogHabits = false,
    this.autoDraftPlans = true,
    this.approveReschedule = true,
    this.shareTasks = true,
    this.shareEvents = true,
    this.shareGoals = true,
    this.shareHabits = true,
    this.shareNotes = false,
    this.shareExpenses = false,
    this.shareFitness = true,
    this.shareLearning = true,
    this.shareActivity = true,
    this.shareNutrition = true,
    this.shareSleep = true,
    this.shareVitals = false,
    this.shareCycle = false,
    this.retentionDays = 90,
  });

  final bool enabled;
  final bool autoCreateTasks;
  final bool autoAddNotes;
  final bool autoLogHabits;
  final bool autoDraftPlans;

  /// Moving a single item's time. Deletes and bulk changes always require
  /// approval in v1 and are not configurable.
  final bool approveReschedule;

  // Which data the assistant may read.
  final bool shareTasks;
  final bool shareEvents;
  final bool shareGoals;
  final bool shareHabits;
  final bool shareNotes;
  final bool shareExpenses;
  final bool shareFitness;
  final bool shareLearning;

  // Health (spec 6): activity, food totals and sleep are shared by default;
  // measurements and the cycle only when the user turns them on.
  final bool shareActivity;
  final bool shareNutrition;
  final bool shareSleep;
  final bool shareVitals;
  final bool shareCycle;

  /// Conversation retention; 0 = keep until deleted.
  final int retentionDays;

  AssistantPermissions copyWith({
    bool? enabled,
    bool? autoCreateTasks,
    bool? autoAddNotes,
    bool? autoLogHabits,
    bool? autoDraftPlans,
    bool? approveReschedule,
    bool? shareTasks,
    bool? shareEvents,
    bool? shareGoals,
    bool? shareHabits,
    bool? shareNotes,
    bool? shareExpenses,
    bool? shareFitness,
    bool? shareLearning,
    bool? shareActivity,
    bool? shareNutrition,
    bool? shareSleep,
    bool? shareVitals,
    bool? shareCycle,
    int? retentionDays,
  }) =>
      AssistantPermissions(
        enabled: enabled ?? this.enabled,
        autoCreateTasks: autoCreateTasks ?? this.autoCreateTasks,
        autoAddNotes: autoAddNotes ?? this.autoAddNotes,
        autoLogHabits: autoLogHabits ?? this.autoLogHabits,
        autoDraftPlans: autoDraftPlans ?? this.autoDraftPlans,
        approveReschedule: approveReschedule ?? this.approveReschedule,
        shareTasks: shareTasks ?? this.shareTasks,
        shareEvents: shareEvents ?? this.shareEvents,
        shareGoals: shareGoals ?? this.shareGoals,
        shareHabits: shareHabits ?? this.shareHabits,
        shareNotes: shareNotes ?? this.shareNotes,
        shareExpenses: shareExpenses ?? this.shareExpenses,
        shareFitness: shareFitness ?? this.shareFitness,
        shareLearning: shareLearning ?? this.shareLearning,
        shareActivity: shareActivity ?? this.shareActivity,
        shareNutrition: shareNutrition ?? this.shareNutrition,
        shareSleep: shareSleep ?? this.shareSleep,
        shareVitals: shareVitals ?? this.shareVitals,
        shareCycle: shareCycle ?? this.shareCycle,
        retentionDays: retentionDays ?? this.retentionDays,
      );

  Map<String, Object?> toJson() => {
        'enabled': enabled,
        'autoCreateTasks': autoCreateTasks,
        'autoAddNotes': autoAddNotes,
        'autoLogHabits': autoLogHabits,
        'autoDraftPlans': autoDraftPlans,
        'approveReschedule': approveReschedule,
        'shareTasks': shareTasks,
        'shareEvents': shareEvents,
        'shareGoals': shareGoals,
        'shareHabits': shareHabits,
        'shareNotes': shareNotes,
        'shareExpenses': shareExpenses,
        'shareFitness': shareFitness,
        'shareLearning': shareLearning,
        'shareActivity': shareActivity,
        'shareNutrition': shareNutrition,
        'shareSleep': shareSleep,
        'shareVitals': shareVitals,
        'shareCycle': shareCycle,
        'retentionDays': retentionDays,
      };

  factory AssistantPermissions.fromJson(Map<String, Object?> j) {
    const d = AssistantPermissions();
    bool b(String k, bool def) => (j[k] as bool?) ?? def;
    return AssistantPermissions(
      enabled: b('enabled', d.enabled),
      autoCreateTasks: b('autoCreateTasks', d.autoCreateTasks),
      autoAddNotes: b('autoAddNotes', d.autoAddNotes),
      autoLogHabits: b('autoLogHabits', d.autoLogHabits),
      autoDraftPlans: b('autoDraftPlans', d.autoDraftPlans),
      approveReschedule: b('approveReschedule', d.approveReschedule),
      shareTasks: b('shareTasks', d.shareTasks),
      shareEvents: b('shareEvents', d.shareEvents),
      shareGoals: b('shareGoals', d.shareGoals),
      shareHabits: b('shareHabits', d.shareHabits),
      shareNotes: b('shareNotes', d.shareNotes),
      shareExpenses: b('shareExpenses', d.shareExpenses),
      shareFitness: b('shareFitness', d.shareFitness),
      shareLearning: b('shareLearning', d.shareLearning),
      shareActivity: b('shareActivity', d.shareActivity),
      shareNutrition: b('shareNutrition', d.shareNutrition),
      shareSleep: b('shareSleep', d.shareSleep),
      shareVitals: b('shareVitals', d.shareVitals),
      shareCycle: b('shareCycle', d.shareCycle),
      retentionDays: (j['retentionDays'] as int?) ?? d.retentionDays,
    );
  }
}

class UserSettings {
  const UserSettings({
    this.displayName = '',
    this.showNameInGreeting = true,
    this.themeMode = 'system',
    this.currency = 'SAR',
    this.weekStart = 7,
    this.use24h = false,
    this.dayStart = 7 * 60,
    this.dayEnd = 23 * 60,
    this.work,
    this.workDays = const {7, 1, 2, 3, 4},
    this.breaks = const [],
    this.modules = const {
      AppModule.time,
      AppModule.learning,
      AppModule.habits,
      AppModule.expenses,
      AppModule.notes,
    },
    this.onboardingDone = false,
    this.homeShowEvents = true,
    this.homeShowHabits = true,
    this.homeShowGoals = true,
    this.assistant = const AssistantPermissions(),
    this.prayer = const PrayerSettings(),
    this.fitness,
    this.sex,
    this.health = const HealthSettings(),
  });

  final String displayName;
  final bool showNameInGreeting;
  final String themeMode; // system | light | dark
  final String currency;
  final int weekStart;
  final bool use24h;
  final int dayStart;
  final int dayEnd;

  /// Fixed work / study block on [workDays].
  final TimeRange? work;
  final Set<int> workDays;
  final List<TimeRange> breaks;
  final Set<AppModule> modules;
  final bool onboardingDone;
  final bool homeShowEvents;
  final bool homeShowHabits;
  final bool homeShowGoals;
  final AssistantPermissions assistant;
  final PrayerSettings prayer;

  /// Null until the user sets up a training plan.
  final FitnessProfile? fitness;

  /// Chosen at sign-up; null only for accounts made before it was asked.
  final Sex? sex;
  final HealthSettings health;

  bool has(AppModule m) => modules.contains(m);

  UserSettings copyWith({
    String? displayName,
    bool? showNameInGreeting,
    String? themeMode,
    String? currency,
    int? weekStart,
    bool? use24h,
    int? dayStart,
    int? dayEnd,
    TimeRange? Function()? work,
    Set<int>? workDays,
    List<TimeRange>? breaks,
    Set<AppModule>? modules,
    bool? onboardingDone,
    bool? homeShowEvents,
    bool? homeShowHabits,
    bool? homeShowGoals,
    AssistantPermissions? assistant,
    PrayerSettings? prayer,
    FitnessProfile? Function()? fitness,
    Sex? sex,
    HealthSettings? health,
  }) =>
      UserSettings(
        displayName: displayName ?? this.displayName,
        showNameInGreeting: showNameInGreeting ?? this.showNameInGreeting,
        themeMode: themeMode ?? this.themeMode,
        currency: currency ?? this.currency,
        weekStart: weekStart ?? this.weekStart,
        use24h: use24h ?? this.use24h,
        dayStart: dayStart ?? this.dayStart,
        dayEnd: dayEnd ?? this.dayEnd,
        work: work != null ? work() : this.work,
        workDays: workDays ?? this.workDays,
        breaks: breaks ?? this.breaks,
        modules: modules ?? this.modules,
        onboardingDone: onboardingDone ?? this.onboardingDone,
        homeShowEvents: homeShowEvents ?? this.homeShowEvents,
        homeShowHabits: homeShowHabits ?? this.homeShowHabits,
        homeShowGoals: homeShowGoals ?? this.homeShowGoals,
        assistant: assistant ?? this.assistant,
        prayer: prayer ?? this.prayer,
        fitness: fitness != null ? fitness() : this.fitness,
        sex: sex ?? this.sex,
        health: health ?? this.health,
      );

  Map<String, Object?> toJson() => {
        'displayName': displayName,
        'showNameInGreeting': showNameInGreeting,
        'themeMode': themeMode,
        'currency': currency,
        'weekStart': weekStart,
        'use24h': use24h,
        'dayStart': dayStart,
        'dayEnd': dayEnd,
        'work': work?.toJson(),
        'workDays': workDays.toList(),
        'breaks': breaks.map((b) => b.toJson()).toList(),
        'modules': modules.map((m) => m.name).toList(),
        'onboardingDone': onboardingDone,
        'homeShowEvents': homeShowEvents,
        'homeShowHabits': homeShowHabits,
        'homeShowGoals': homeShowGoals,
        'assistant': assistant.toJson(),
        'prayer': prayer.toJson(),
        'fitness': fitness?.toJson(),
        'sex': sex?.name,
        'health': health.toJson(),
      };

  factory UserSettings.fromJson(Map<String, Object?> j) {
    const d = UserSettings();
    return UserSettings(
      displayName: (j['displayName'] as String?) ?? d.displayName,
      showNameInGreeting: (j['showNameInGreeting'] as bool?) ?? d.showNameInGreeting,
      themeMode: (j['themeMode'] as String?) ?? d.themeMode,
      currency: (j['currency'] as String?) ?? d.currency,
      weekStart: (j['weekStart'] as int?) ?? d.weekStart,
      use24h: (j['use24h'] as bool?) ?? d.use24h,
      dayStart: (j['dayStart'] as int?) ?? d.dayStart,
      dayEnd: (j['dayEnd'] as int?) ?? d.dayEnd,
      work: j['work'] == null ? null : TimeRange.fromJson((j['work'] as Map).cast()),
      workDays: ((j['workDays'] as List?)?.cast<int>().toSet()) ?? d.workDays,
      breaks: ((j['breaks'] as List?) ?? const [])
          .map((e) => TimeRange.fromJson((e as Map).cast()))
          .toList(),
      modules: ((j['modules'] as List?)?.map((e) => AppModule.values.byName(e as String)).toSet()) ??
          d.modules,
      onboardingDone: (j['onboardingDone'] as bool?) ?? d.onboardingDone,
      homeShowEvents: (j['homeShowEvents'] as bool?) ?? d.homeShowEvents,
      homeShowHabits: (j['homeShowHabits'] as bool?) ?? d.homeShowHabits,
      homeShowGoals: (j['homeShowGoals'] as bool?) ?? d.homeShowGoals,
      assistant: j['assistant'] == null
          ? d.assistant
          : AssistantPermissions.fromJson((j['assistant'] as Map).cast()),
      prayer: j['prayer'] == null ? d.prayer : PrayerSettings.fromJson((j['prayer'] as Map).cast()),
      fitness: FitnessProfile.fromJson((j['fitness'] as Map?)?.cast()),
      sex: Sex.values.where((x) => x.name == j['sex']).firstOrNull,
      health: HealthSettings.fromJson((j['health'] as Map?)?.cast()),
    );
  }
}
