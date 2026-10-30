import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/app.dart';
import 'package:hayati/core/router/app_router.dart';
import 'package:hayati/core/utils/dates.dart';
import 'package:hayati/core/utils/format.dart';
import 'package:hayati/core/utils/labels.dart';
import 'package:hayati/data/auth.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/accountability.dart';
import 'package:hayati/data/models/fitness.dart';
import 'package:hayati/data/models/goal.dart';
import 'package:hayati/data/models/health.dart';
import 'package:hayati/data/models/learning.dart';
import 'package:hayati/data/models/misc.dart';
import 'package:hayati/data/models/nutrition.dart';
import 'package:hayati/data/models/task.dart';
import 'package:hayati/data/models/womens.dart';
import 'package:hayati/data/store/local_store.dart';
import 'package:hayati/features/home/home_screen.dart';
import 'package:hayati/features/nutrition/scan_screen.dart';
import 'package:hayati/domain/activity.dart';
import 'package:hayati/domain/assistant/assistant_service.dart';
import 'package:hayati/domain/device_reminders.dart';
import 'package:hayati/domain/fitness/plan_generator.dart';
import 'package:hayati/domain/learning/curriculum.dart';
import 'package:hayati/domain/prayer_times.dart';
import 'package:hayati/widgets/common.dart';
import 'package:hayati/l10n/app_localizations.dart';
import 'package:hayati/services/device_notifications.dart';
import 'package:hayati/services/barcode_lookup.dart';
import 'package:hayati/services/food_recognizer.dart';
import 'package:hayati/services/health_lock.dart';
import 'package:hayati/services/health_reader.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart' show FakeHealthReader;

/// Records what would be scheduled with the OS.
class FakeDeviceNotifications implements DeviceNotifications {
  List<DeviceReminder> scheduled = [];
  DevicePermission state = DevicePermission.unknown;
  int requests = 0;

  @override
  bool get canSchedule => true;
  @override
  Future<void> init({required void Function(String route) onOpen}) async {}
  @override
  Future<DevicePermission> permission() async => state;
  @override
  Future<DevicePermission> requestPermission() async {
    requests++;
    return state = DevicePermission.granted;
  }
  @override
  Future<void> reschedule(List<DeviceReminder> reminders) async => scheduled = reminders;
  @override
  Future<void> showNow(int id, String title, String body, String route) async {}
}

class FakeBarcodeLookup implements BarcodeLookup {
  @override
  Future<LookupResult> find(String barcode, {required String lang}) async => barcode == '6281007012345'
      ? const LookupResult.found(ProductInfo(
          barcode: '6281007012345', name: 'Laban', portion: '200 ml', grams: 200, per: Nutrients(kcal: 92, protein: 6, carbs: 9, fat: 3)))
      : const LookupResult.failed(LookupFailure.notFound);
}

/// The phone's unlock, answering [ok].
class FakeDeviceAuth implements DeviceAuth {
  bool ok = true;
  int asked = 0;
  @override
  Future<bool> available() async => true;
  @override
  Future<bool> authenticate(String reason) async {
    asked++;
    return ok;
  }
}

Future<ProviderContainer> pumpApp(WidgetTester tester, {required String locale, required Size size, HealthReader? reader, DeviceAuth? auth}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({DevicePrefs.localeKey: locale});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [
    localStoreProvider.overrideWithValue(LocalStore(prefs)),
    deviceNotificationsProvider.overrideWithValue(FakeDeviceNotifications()),
    healthReaderProvider.overrideWithValue(reader ?? const UnsupportedHealthReader()),
    deviceAuthProvider.overrideWithValue(auth ?? const NoDeviceAuth()),
    foodRecognizerProvider.overrideWithValue(const UnavailableFoodRecognizer()),
    barcodeLookupProvider.overrideWithValue(FakeBarcodeLookup()),
    scanCameraProvider.overrideWithValue(false),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const HayatiApp()));
  await tester.pumpAndSettle();
  return container;
}

/// Signs up while pumping, so the fake-async timers inside complete.
Future<void> signUp(WidgetTester tester, ProviderContainer c, {Sex? sex = Sex.male}) async {
  var done = false;
  c.read(authProvider.notifier).signUp('u@example.com', 'password1', sex: sex).then((_) => done = true);
  for (var i = 0; i < 20 && !done; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(done, isTrue);
}

/// Scrolls [f] into view (lists build lazily) and taps it.
Future<void> tapIn(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(f, 150, scrollable: find.byType(Scrollable).first);
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
}

void seed(ProviderContainer c) {
  final d = c.read(dataProvider.notifier);
  final now = DateTime.now();
  final today = dayKey(now);
  final g = Goal(id: 'g1', title: 'Flutter', description: 'Basics', targetDate: dayKey(now.add(const Duration(days: 30))), createdAt: now, updatedAt: now);
  d.saveGoal(g, const [Milestone(id: 'm1', goalId: 'g1', title: 'Dart', order: 0), Milestone(id: 'm2', goalId: 'g1', title: 'Widgets', order: 1)]);
  d.saveGoal(Goal(id: 'g2', title: 'Read', progressMode: ProgressMode.manual, manualProgress: 40, status: GoalStatus.paused, createdAt: now, updatedAt: now), const []);
  for (var i = 0; i < 5; i++) {
    d.saveTask(d.newTask(
      title: 'Task number $i with a fairly long title to test wrapping',
      dueDate: i == 4 ? dayKey(now.subtract(const Duration(days: 2))) : today,
      dueTime: i == 1 ? 20 * 60 : null,
      estimatedMinutes: i == 2 ? null : 30 + i * 10,
      priority: Priority.values[i % 3],
      goalId: i < 2 ? 'g1' : null,
      milestoneId: i == 0 ? 'm1' : null,
    ));
  }
  final first = c.read(dataProvider).tasks.first;
  d.setTaskStatus(first.id, TaskStatus.done);
  d.saveEvent(CalendarEvent(
    id: 'e1',
    title: 'Lecture',
    start: DateTime(now.year, now.month, now.day, 10),
    end: DateTime(now.year, now.month, now.day, 12),
    location: 'Room 4',
    reminderMinutesBefore: 30,
    updatedAt: now,
  ));
  d.saveEvent(CalendarEvent(id: 'e2', title: 'Overlap', start: DateTime(now.year, now.month, now.day, 11), end: DateTime(now.year, now.month, now.day, 13), updatedAt: now));
  final fp = FitnessProfile(
    goal: FitnessGoal.general,
    level: FitnessLevel.beginner,
    daysPerWeek: 6,
    minutesPerSession: 45,
    weekdays: [now.weekday, for (var i = 1; i < 6; i++) (now.weekday + i - 1) % 7 + 1],
    places: const {WorkoutPlace.home, WorkoutPlace.gym},
    preferredPlace: WorkoutPlace.gym,
  );
  const gen = PlanGenerator();
  d.saveFitness(fp, {WorkoutPlace.home: gen.build(fp, WorkoutPlace.home), WorkoutPlace.gym: gen.build(fp, WorkoutPlace.gym)});
  d.startLearning(Cefr.b1, 3);
  d.recordLesson('b1_perfect', 60, const ['w_already', 'w_yet']);
  d.reviewWord('w_already', 1, today); // due now, so the review screen has a question
  d.saveHabit(Habit(id: 'h1', name: 'Walk', weekdays: const {1, 2, 3, 4, 5, 6, 7}, startDate: dayKey(now.subtract(const Duration(days: 40))), reminderMinutes: 0));
  d.setHabitDone('h1', dayKey(now.subtract(const Duration(days: 1))), true);
  d.saveNote(Note(id: 'n1', title: 'Idea', body: 'Some body text', category: 'work', pinned: true, goalId: 'g1', updatedAt: now));
  d.addExpense(Expense(id: 'x1', amountMinor: 2550, currency: 'SAR', category: 'food', spentAt: now, description: 'Lunch'));
  d.addExpense(Expense(id: 'x2', amountMinor: 1000, currency: 'USD', category: 'education', spentAt: now));
  d.saveBudget(const Budget(id: 'b1', currency: 'SAR', limitMinor: 2000));
  final late = d.newTask(title: 'Late report', dueDate: dayKey(now.subtract(const Duration(days: 10))));
  d.saveTask(late);
  d.saveRule(AccountabilityRule(id: 'ar1', taskId: late.id, consequence: Consequence.planningSession, createdAt: now));
  d.addAccountabilityEvent(AccountabilityEvent(id: 'ae1', ruleId: 'ar1', taskId: late.id, dueDate: late.dueDate!, triggeredOn: today));
  d.addAccountabilityEvent(AccountabilityEvent(id: 'ae0', taskId: first.id, dueDate: '2026-01-01', triggeredOn: '2026-01-08')
      .resolve(DelayReason.illness, EventOutcome.rescheduled, newDueDate: today, note: 'flu', at: now));
  for (var i = 0; i < 9; i++) {
    d.recordActivity(dayKey(now.subtract(Duration(days: i))), i.isEven ? ActivitySource.healthConnect : ActivitySource.manual,
        steps: 4000 + i * 1100);
  }
  d.logFood(day: today, meal: MealType.lunch, name: 'Chicken mandi', per: const Nutrients(kcal: 620, protein: 35, carbs: 68, fat: 22), portions: 1.5);
  d.logFood(day: today, meal: MealType.breakfast, name: 'Dates', per: const Nutrients(kcal: 28, carbs: 7.5), portions: 3);
  d.saveCustomFood(CustomFood(id: 'cf1', name: 'My laban', portion: 'bottle', per: const Nutrients(kcal: 120, protein: 8), barcode: '6281000000001', createdAt: now));
  d.addWater(today, 1250);
  d.setSex(Sex.male);
  d.saveAppointment(HealthAppointment(
      id: 'ap1', title: 'Annual checkup', kind: AppointmentKind.checkup, at: now.add(const Duration(days: 2)), place: 'Clinic',
      questions: const ['Blood test?', 'Vitamin D?'], reminderMinutes: 60, updatedAt: now));
  d.saveAppointment(HealthAppointment(id: 'ap0', title: 'Blood test', kind: AppointmentKind.test, at: now.subtract(const Duration(days: 20)), updatedAt: now));
  final night = DateTime(now.year, now.month, now.day);
  d.importSleep(ActivitySource.healthConnect, [
    for (var i = 0; i < 6; i++) (night.subtract(Duration(days: i, minutes: 60 + i * 20)), night.subtract(Duration(days: i)).add(Duration(hours: 6, minutes: i * 10))),
  ], from: night.subtract(const Duration(days: 7)));
  d.importRestingHeart(ActivitySource.healthConnect, [for (var i = 0; i < 5; i++) (night.subtract(Duration(days: i)), 58.0 + i)]);
  d.importWorkouts(ActivitySource.healthConnect, [
    DeviceWorkout(id: 'r1', source: ActivitySource.healthConnect, activity: 'RUNNING', start: night.subtract(const Duration(hours: 30)),
        end: night.subtract(const Duration(hours: 29, minutes: 25)), kcal: 410, distanceM: 6200, updatedAt: now),
    DeviceWorkout(id: 's1', source: ActivitySource.healthConnect, activity: 'SWIMMING_POOL', start: night.subtract(const Duration(hours: 54)),
        end: night.subtract(const Duration(hours: 53, minutes: 15)), updatedAt: now),
  ], from: night.subtract(const Duration(days: 7)));
  d.logWorkout(WorkoutSession(id: 'ws1', day: dayKey(now.subtract(const Duration(days: 3))), place: WorkoutPlace.home, focus: DayFocus.fullBody,
      status: SessionStatus.completed, sets: const [SetLog(exerciseId: 'goblet_squat', setIndex: 0, reps: 10, weightKg: 12), SetLog(exerciseId: 'push_up', setIndex: 0, reps: 8)], createdAt: now));
  d.logWorkout(WorkoutSession(id: 'ws2', day: today, place: WorkoutPlace.home, focus: DayFocus.mobility, status: SessionStatus.completed,
      sets: const [SetLog(exerciseId: 'goblet_squat', setIndex: 0, reps: 8, weightKg: 14), SetLog(exerciseId: 'plank', setIndex: 0, seconds: 30)],
      programId: 'flexibility', createdAt: now.add(const Duration(minutes: 1))));
  d.notify(AppNotification(id: 'nt', type: NotificationType.task, title: 'Reminder', createdAt: now, refId: first.id, dedupeKey: 'x'));
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  for (final locale in ['ar', 'en']) {
    testWidgets('sign up → onboarding → home ($locale)', (tester) async {
      final c = await pumpApp(tester, locale: locale, size: const Size(390, 844));
      final l = lookupAppLocalizations(Locale(locale));

      expect(find.text(l.welcomeTitle), findsOneWidget);
      final dir = tester.widget<Directionality>(find.byType(Directionality).first);
      expect(dir.textDirection, locale == 'ar' ? TextDirection.rtl : TextDirection.ltr);

      await tapIn(tester, find.text(l.getStarted));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'user@example.com');
      await tester.enterText(fields.at(1), 'password1');
      await tester.enterText(fields.at(2), 'password1');
      await tapIn(tester, find.byType(Checkbox));
      // Sex is required at sign-up.
      await tapIn(tester, find.text(l.createAccount));
      await tester.pumpAndSettle();
      expect(find.text(l.errSex), findsOneWidget);
      await tapIn(tester, find.text(l.sexFemale));
      await tapIn(tester, find.text(l.createAccount));
      await tester.pumpAndSettle();

      // Onboarding: 4 steps.
      expect(find.text(l.obStep1), findsOneWidget);
      for (var i = 0; i < 3; i++) {
        await tapIn(tester, find.text(l.next));
        await tester.pumpAndSettle();
      }
      await tapIn(tester, find.text(l.finishSetup));
      await tester.pumpAndSettle();

      expect(find.text(l.homeViewToday), findsOneWidget);
      expect(find.textContaining(l.nowLabel), findsWidgets);
      expect(find.text(l.newUserTitle), findsOneWidget);
      expect(c.read(dataProvider).settings.onboardingDone, isTrue);
      final s = c.read(dataProvider).settings;
      expect(s.sex, Sex.female);
      expect(s.health.has(HealthModule.womens), isTrue);
      expect(s.health.has(HealthModule.mens), isFalse);
    });
  }

  for (final (name, size) in [('phone', const Size(390, 844)), ('desktop', const Size(1366, 900))]) {
    for (final locale in ['ar', 'en']) {
      testWidgets('every screen renders with data ($name, $locale)', (tester) async {
        final c = await pumpApp(tester, locale: locale, size: size);
        await signUp(tester, c);
        c.read(dataProvider.notifier).updateSettings((s) => s.copyWith(onboardingDone: true));
        seed(c);
        // Prayer times on (Riyadh), so the home strip, planner blocks and
        // the prayer screens render with real times.
        c.read(dataProvider.notifier).updateSettings((s) => s.copyWith(
              prayer: s.prayer.copyWith(enabled: true, place: 'الرياض', latitude: () => 24.7136, longitude: () => 46.6753),
            ));
        await tester.pumpAndSettle();
        final router = c.read(routerProvider);
        final d = c.read(dataProvider);
        final taskId = d.tasks.first.id;
        final routes = [
          Routes.home,
          Routes.timeTab('tasks'),
          Routes.timeTab('calendar'),
          Routes.timeTab('planner'),
          Routes.goals,
          Routes.assistant,
          Routes.progress,
          Routes.task('new'),
          Routes.task(taskId),
          Routes.event('new'),
          Routes.event('e1'),
          Routes.goal('new'),
          Routes.goal('g1'),
          Routes.habits,
          Routes.notes,
          Routes.note('n1'),
          Routes.note('new'),
          Routes.expenses,
          Routes.notifications,
          Routes.settings,
          Routes.assistantSettings,
          Routes.profile,
          Routes.subscription,
          Routes.help,
          Routes.privacy,
          Routes.prayer,
          Routes.prayerSettings,
          Routes.fitness,
          Routes.fitnessSetup,
          Routes.exercise('goblet_squat'),
          Routes.workout('gym', DateTime.now().weekday),
          Routes.workout('gym', DateTime.now().weekday, atHome: true),
          Routes.english,
          Routes.lesson('b1_passive'),
          Routes.englishReview,
          Routes.placement,
          Routes.levelCheck,
          Routes.accountability,
          Routes.accountabilityRule(),
          Routes.accountabilityRule(ruleId: 'ar1'),
          Routes.accountabilityEvent('ae1'),
          Routes.accountabilityEvent('ae0'),
          Routes.activity,
          Routes.healthSetup,
          Routes.nutrition,
          Routes.nutritionWeek,
          Routes.nutritionAdd(meal: 'lunch'),
          Routes.nutritionScan(),
          Routes.customFood(),
          Routes.customFood(id: 'cf1'),
          Routes.nutritionPhoto(),
          Routes.program('flexibility'),
          Routes.program('pelvic_floor_men'),
          Routes.programSession('balance'),
          Routes.fitnessProgress,
          Routes.devices,
          Routes.appointments,
          Routes.appointment('ap1'),
          Routes.appointment('new'),
          Routes.healthPrivacy,
        ];
        for (final r in routes) {
          router.go(r);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: r);
          // Guards against a screen laying out with an empty body.
          expect(find.byType(Text).evaluate().length + find.byType(EditableText).evaluate().length, greaterThan(6), reason: r);
        }
        // The home screen's week and goals views.
        final l = lookupAppLocalizations(Locale(locale));
        router.go(Routes.home);
        await tester.pumpAndSettle();
        for (final v in [l.homeViewWeek, l.homeViewGoals, l.homeViewToday]) {
          await tester.tap(find.descendant(of: find.byType(SegmentedButton<HomeView>), matching: find.text(v)));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: v);
        }
        // The prayer card names the next prayer; the hero's "next up" line
        // may say the same when a prayer is the next item, depending on the hour.
        expect(find.text(l.nextPrayerIs(l.prayerName(nextPrayer(c.read(dataProvider).settings.prayer, DateTime.now())!.$1))), findsAtLeastNWidgets(1));
      });
    }
  }

  testWidgets('assistant: request → proposal → approve (ar)', (tester) async {
    final c = await pumpApp(tester, locale: 'ar', size: const Size(390, 844));
    final l = lookupAppLocalizations(const Locale('ar'));
    await signUp(tester, c);
    c.read(dataProvider.notifier).updateSettings((s) => s.copyWith(onboardingDone: true));
    await tester.pumpAndSettle();
    c.read(routerProvider).go(Routes.assistant);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'أبي أتعلم الإنجليزية 30 دقيقة كل يوم');
    await tester.tap(find.byTooltip(l.send));
    await tester.pumpAndSettle();
    expect(c.read(dataProvider).goals, isEmpty, reason: 'nothing is created before approval');
    expect(find.text(l.approve), findsOneWidget);

    await tapIn(tester, find.text(l.approve));
    await tester.pumpAndSettle();
    final d = c.read(dataProvider);
    expect(d.goals.single.title, 'تعلم الإنجليزية');
    expect(d.tasks, hasLength(7));
    expect(find.text(l.proposalExecuted), findsOneWidget);
    expect(c.read(assistantProvider).busy, isFalse);
  });

  /// A female account with periods, day logs and an appointment.
  void seedWomens(ProviderContainer c) {
    final d = c.read(dataProvider.notifier);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    String back(int n) => dayKey(today.subtract(Duration(days: n)));
    for (final (s, e) in [(88, 84), (60, 55), (31, 27)]) {
      d.savePeriod(CyclePeriod(id: 'p$s', start: back(s), end: back(e), updatedAt: now));
    }
    d.startPeriod(back(2));
    for (final (n, sy) in [(31, {Symptom.cramps, Symptom.fatigue}), (30, {Symptom.cramps}), (2, {Symptom.cramps, Symptom.backPain}), (1, {Symptom.headache})]) {
      d.saveCycleLog(CycleDayLog(id: '', day: back(n), flow: FlowLevel.medium, pain: 4, symptoms: sy, mood: CycleMood.low, energy: 2, note: 'note', updatedAt: now));
    }
    d.saveAppointment(HealthAppointment(id: 'ap1', title: 'Checkup', at: now.add(const Duration(days: 3)), questions: const ['Q'], updatedAt: now));
  }

  for (final (name, size) in [('phone', const Size(390, 844)), ('desktop', const Size(1366, 900))]) {
    for (final locale in ['ar', 'en']) {
      testWidgets("women's health screens render ($name, $locale)", (tester) async {
        final c = await pumpApp(tester, locale: locale, size: size);
        await signUp(tester, c, sex: Sex.female);
        final data = c.read(dataProvider.notifier);
        data.updateSettings((s) => s.copyWith(onboardingDone: true));
        data.setSex(Sex.female);
        seedWomens(c);
        await tester.pumpAndSettle();
        final router = c.read(routerProvider);
        for (final r in [
          Routes.home,
          Routes.womens,
          Routes.womensDay(dayKey(DateTime.now())),
          Routes.womensDay(dayKey(DateTime.now().subtract(const Duration(days: 30)))),
          Routes.womensInsights,
          Routes.appointments,
          Routes.appointment('ap1'),
          Routes.healthPrivacy,
          Routes.healthSetup,
        ]) {
          router.go(r);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: r);
          expect(find.byType(Text).evaluate().length + find.byType(EditableText).evaluate().length, greaterThan(6), reason: r);
        }
      });
    }
  }

  testWidgets("women's health: record a period, log a day, men never see it (en)", (tester) async {
    final c = await pumpApp(tester, locale: 'en', size: const Size(390, 844));
    final l = lookupAppLocalizations(const Locale('en'));
    await signUp(tester, c, sex: Sex.female);
    final data = c.read(dataProvider.notifier);
    data.updateSettings((s) => s.copyWith(onboardingDone: true));
    data.setSex(Sex.female);
    await tester.pumpAndSettle();
    final router = c.read(routerProvider);
    router.go(Routes.womens);
    await tester.pumpAndSettle();
    expect(find.text(l.cycleStartTitle), findsOneWidget);
    await tester.tap(find.text(l.periodStartedToday));
    await tester.pumpAndSettle();
    expect(c.read(dataProvider).periods.single.end, isNull);
    expect(find.text(l.periodDayN(1)), findsOneWidget);

    // Log today: pain and a symptom.
    await tapIn(tester, find.text(l.howIsToday));
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.flowLevel(FlowLevel.heavy)));
    await tapIn(tester, find.text(l.symptom(Symptom.cramps)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.save));
    await tester.pumpAndSettle();
    final log = c.read(dataProvider).cycleLog(dayKey(DateTime.now()))!;
    expect((log.flow, log.symptoms.single), (FlowLevel.heavy, Symptom.cramps));
    expect(find.text(l.todayLogged), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.periodEndedToday));
    await tester.pumpAndSettle();
    expect(c.read(dataProvider).periods.single.end, dayKey(DateTime.now()));

    // A male account: no menu item, and the screens refuse.
    data.setSex(Sex.male);
    router.go(Routes.womens);
    await tester.pumpAndSettle();
    expect(find.text(l.womensUnavailable), findsOneWidget);
    expect(find.text(l.periodStartedToday), findsNothing);
  });

  testWidgets('health lock: phone unlock first, locks again in the background; cycle data on this phone only (ar)', (tester) async {
    final auth = FakeDeviceAuth();
    final c = await pumpApp(tester, locale: 'ar', size: const Size(390, 844), auth: auth);
    final l = lookupAppLocalizations(const Locale('ar'));
    await signUp(tester, c, sex: Sex.female);
    final data = c.read(dataProvider.notifier);
    data.updateSettings((s) => s.copyWith(onboardingDone: true));
    data.setSex(Sex.female);
    await tester.pumpAndSettle();
    final router = c.read(routerProvider);
    router.go(Routes.healthPrivacy);
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.healthLock));
    await tester.pumpAndSettle();
    expect((auth.asked, c.read(dataProvider).settings.health.lockEnabled), (1, true));

    // Home shows nothing but the section's name while locked.
    data.startPeriod(dayKey(DateTime.now()));
    router.go(Routes.home);
    await tester.pumpAndSettle();
    expect(find.text(l.periodDayN(1), skipOffstage: false), findsNothing);
    expect(find.text(l.navWomens, skipOffstage: false), findsOneWidget);

    // Back from the background: locked until the phone says yes.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    auth.ok = false;
    router.go(Routes.womens);
    await tester.pumpAndSettle();
    expect(find.text(l.healthLocked), findsOneWidget);
    expect(find.text(l.periodDayN(1)), findsNothing);
    auth.ok = true;
    await tester.tap(find.text(l.unlock));
    await tester.pumpAndSettle();
    expect(find.text(l.periodDayN(1)), findsOneWidget);

    // Keep it on this phone only, after confirming.
    router.go(Routes.healthPrivacy);
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.cycleLocalOnly));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.continueLabel));
    await tester.pumpAndSettle();
    expect(c.read(dataProvider).settings.health.cycleLocalOnly, isTrue);
  });

  testWidgets('accountability: agree to a rule, then answer a late task (en)', (tester) async {
    final c = await pumpApp(tester, locale: 'en', size: const Size(390, 844));
    final l = lookupAppLocalizations(const Locale('en'));
    await signUp(tester, c);
    final data = c.read(dataProvider.notifier);
    data.updateSettings((s) => s.copyWith(onboardingDone: true));
    final now = DateTime.now();
    final task = data.newTask(title: 'Essay', dueDate: dayKey(now.subtract(const Duration(days: 4))));
    data.saveTask(task);
    await tester.pumpAndSettle();
    final router = c.read(routerProvider);
    router.push(Routes.accountability);
    await tester.pumpAndSettle();
    router.push(Routes.accountabilityRule(taskId: task.id));
    await tester.pumpAndSettle();

    await tapIn(tester, find.text(l.accDaysLate(3)));
    await tester.pumpAndSettle();
    // Unsafe custom wording is refused; saving needs explicit agreement.
    await tapIn(tester, find.text(l.conCustom));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'No sleep until done');
    await tester.pumpAndSettle();
    expect(find.text(l.accCustomUnsafe), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Tidy my desk first');
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.save));
    await tester.pumpAndSettle();
    expect(c.read(dataProvider).accountabilityRules, isEmpty, reason: 'not agreed yet');
    await tapIn(tester, find.text(l.accAgree));
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.save));
    await tester.pumpAndSettle();
    final rule = c.read(dataProvider).accountabilityRules.single;
    expect((rule.graceDays, rule.consequence, rule.customText), (3, Consequence.custom, 'Tidy my desk first'));

    // The shell notices the task is 4 days late and asks why.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(c.read(dataProvider).accountabilityEvents.where((e) => e.pending), hasLength(1));
    final event = c.read(dataProvider).accountabilityEvents.single;
    router.push(Routes.accountabilityEvent(event.id));
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.delayReason(DelayReason.postponed)));
    await tester.pumpAndSettle();
    expect(find.text('Tidy my desk first'), findsOneWidget);
    await tapIn(tester, find.text(l.accConfirm));
    await tester.pumpAndSettle();
    final d = c.read(dataProvider);
    expect(d.accountabilityEvent(event.id)!.outcome, EventOutcome.consequenceAccepted);
    expect(d.task(task.id)!.dueDate, dayKey(now.add(const Duration(days: 3))));
    expect(d.tasks.where((t) => t.title == 'Tidy my desk first'), hasLength(1));
  });

  testWidgets('accounts made before sign-up asked for sex are asked once (ar)', (tester) async {
    final c = await pumpApp(tester, locale: 'ar', size: const Size(390, 844));
    final l = lookupAppLocalizations(const Locale('ar'));
    await signUp(tester, c, sex: null);
    c.read(dataProvider.notifier).updateSettings((s) => s.copyWith(onboardingDone: true));
    await tester.pumpAndSettle();
    expect(find.text(l.sexAskTitle), findsOneWidget);
    await tester.tap(find.text(l.sexMale));
    await tester.pumpAndSettle();
    expect(find.text(l.sexAskTitle), findsNothing);
    final s = c.read(dataProvider).settings;
    expect((s.sex, s.health.has(HealthModule.mens)), (Sex.male, true));
    // Changing it from the profile.
    c.read(routerProvider).push(Routes.profile);
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.sexLabel));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.sexFemale));
    await tester.pumpAndSettle();
    expect(c.read(dataProvider).settings.sex, Sex.female);
  });

  testWidgets('programs: women and men each see only their own (en)', (tester) async {
    final c = await pumpApp(tester, locale: 'en', size: const Size(390, 844));
    final l = lookupAppLocalizations(const Locale('en'));
    await signUp(tester, c, sex: Sex.female);
    final data = c.read(dataProvider.notifier);
    data.updateSettings((s) => s.copyWith(onboardingDone: true));
    data.setSex(Sex.female);
    await tester.pumpAndSettle();
    final router = c.read(routerProvider);
    router.go(Routes.fitness);
    await tester.pumpAndSettle();
    expect(find.text(l.programsForWomen, skipOffstage: false), findsOneWidget);
    expect(find.text(l.programsForMen, skipOffstage: false), findsNothing);
    router.push(Routes.program('back_posture_men'));
    await tester.pumpAndSettle();
    expect(find.text(l.programUnavailable), findsOneWidget);

    // Pregnancy waits for the doctor's go-ahead before it can start.
    router.go(Routes.program('pregnancy_t2'));
    await tester.pumpAndSettle();
    bool startEnabled() => tester.widget<PrimaryButton>(find.widgetWithText(PrimaryButton, l.startProgram)).onPressed != null;
    expect(startEnabled(), isFalse);
    await tapIn(tester, find.text(l.clearanceConfirm));
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.continueLabel));
    await tester.pumpAndSettle();
    expect(c.read(dataProvider).settings.health.pregnancyCleared, isTrue);
    expect(startEnabled(), isTrue);

    // Switching to male swaps the sections.
    data.setSex(Sex.male);
    router.go(Routes.fitness);
    await tester.pumpAndSettle();
    expect(find.text(l.programsForMen, skipOffstage: false), findsOneWidget);
    expect(find.text(l.programsForWomen, skipOffstage: false), findsNothing);
  });

  testWidgets('devices: turn on sleep, pick the source that counts, remove a source (en)', (tester) async {
    final today = DateTime.now();
    final night = DateTime(today.year, today.month, today.day);
    final reader = FakeHealthReader(
      days: [StepDay(dayKey(today), 6400)],
      sleep: [(night.subtract(const Duration(hours: 1)), night.add(const Duration(hours: 6, minutes: 30)))],
      heart: [(night.add(const Duration(hours: 6)), 61)],
    );
    final c = await pumpApp(tester, locale: 'en', size: const Size(390, 844), reader: reader);
    final l = lookupAppLocalizations(const Locale('en'));
    await signUp(tester, c);
    final data = c.read(dataProvider.notifier);
    data.updateSettings((s) => s.copyWith(onboardingDone: true));
    data.recordActivity(dayKey(today), ActivitySource.manual, steps: 3000);
    await tester.pumpAndSettle();
    final router = c.read(routerProvider);
    router.push(Routes.devices);
    await tester.pumpAndSettle();
    expect(find.text(l.whatThisPhoneReads), findsOneWidget);

    await tapIn(tester, find.text(l.hkSleep));
    await tester.pumpAndSettle();
    expect(reader.asked.last, {HealthKind.sleep});
    expect(c.read(dataProvider).sleep, hasLength(1));
    await tapIn(tester, find.text(l.hkSteps));
    await tester.pumpAndSettle();
    expect(activityDay(c.read(dataProvider), dayKey(today)).steps, 6400, reason: 'Health Connect counts before manual');

    // Two sources for steps: the user picks which one counts.
    await tapIn(tester, find.widgetWithText(ChoiceChip, l.sourceManual));
    await tester.pumpAndSettle();
    expect(c.read(dataProvider).settings.health.preferredSource, ActivitySource.manual);
    expect(activityDay(c.read(dataProvider), dayKey(today)).steps, 3000);

    // Sleep shows on the activity screen with its source.
    router.go(Routes.activity);
    await tester.pumpAndSettle();
    expect(find.text(l.durationText(450), skipOffstage: false), findsOneWidget);

    // Removing Health Connect's data keeps what was added by hand.
    router.push(Routes.devices);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text(l.whichSourceCounts), 150, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l.removeSourceData).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.delete));
    await tester.pumpAndSettle();
    final d = c.read(dataProvider);
    expect((d.sleep.isEmpty, d.activity.single.source), (true, ActivitySource.manual));
  });

  testWidgets('steps: add by hand, change the goal (en)', (tester) async {
    final c = await pumpApp(tester, locale: 'en', size: const Size(390, 844));
    final l = lookupAppLocalizations(const Locale('en'));
    await signUp(tester, c);
    c.read(dataProvider.notifier).updateSettings((s) => s.copyWith(onboardingDone: true));
    await tester.pumpAndSettle();
    final router = c.read(routerProvider);
    router.push(Routes.activity);
    await tester.pumpAndSettle();
    // Tests run as "web or desktop": manual entry only.
    expect(find.text(l.activityWebNote), findsOneWidget);
    await tester.tap(find.text(l.addStepsManually));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '999999');
    await tester.pumpAndSettle();
    expect(find.text(l.stepsInvalid), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '8500');
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.save));
    await tester.pumpAndSettle();
    final d = c.read(dataProvider);
    final today = activityDay(d, dayKey(DateTime.now()));
    expect((today.steps, today.source), (8500, ActivitySource.manual));
    expect(find.text('8,500'), findsWidgets);
    router.push(Routes.healthSetup);
    await tester.pumpAndSettle();
    await tapIn(tester, find.widgetWithText(ChoiceChip, '10,000'));
    await tester.pumpAndSettle();
    expect(c.read(dataProvider).settings.health.stepGoal, 10000);
  });

  testWidgets('food: search and add, barcode to saved food, water (en)', (tester) async {
    final c = await pumpApp(tester, locale: 'en', size: const Size(390, 844));
    final l = lookupAppLocalizations(const Locale('en'));
    await signUp(tester, c);
    c.read(dataProvider.notifier).updateSettings((s) => s.copyWith(onboardingDone: true));
    await tester.pumpAndSettle();
    final router = c.read(routerProvider);
    router.push(Routes.nutrition);
    await tester.pumpAndSettle();
    // The photo button only shows where the on-device model runs.
    expect(find.text(l.mealPhoto), findsNothing);
    await tester.tap(find.byTooltip(l.addCup));
    await tester.pumpAndSettle();
    final today = dayKey(DateTime.now());
    expect(c.read(dataProvider).waterOn(today), 250);

    await tester.tap(find.text(l.addFood));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'mandi');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chicken mandi'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l.more));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.addToDay));
    await tester.pumpAndSettle();
    final logged = c.read(dataProvider).foodLogs.single;
    expect((logged.name, logged.portions, logged.total.kcal, logged.foodRef), ('Chicken mandi', 1.5, 930, 'chicken_mandi'));
    expect(find.text(l.kcalN('930')), findsWidgets);

    // A barcode Open Food Facts knows: check the label, save, add.
    router.push(Routes.nutritionScan(meal: 'snack'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '12ab');
    await tester.tap(find.text(l.lookUp));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '6281007012345');
    await tester.tap(find.text(l.lookUp));
    await tester.pumpAndSettle();
    expect(find.text(l.productFound), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Laban'), findsOneWidget);
    await tapIn(tester, find.text(l.saveAndAdd));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.addToDay));
    await tester.pumpAndSettle();
    final d = c.read(dataProvider);
    expect(d.customFoods.single.barcode, '6281007012345');
    expect(d.foodLogs.where((f) => f.name == 'Laban').single.meal, MealType.snack);

    // The same barcode again opens the saved food directly.
    router.push(Routes.nutritionScan());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '6281007012345');
    await tester.tap(find.text(l.lookUp));
    await tester.pumpAndSettle();
    expect(find.text(l.addToDay), findsOneWidget);
  });

  testWidgets('task editor validates and saves', (tester) async {
    final c = await pumpApp(tester, locale: 'en', size: const Size(390, 844));
    final l = lookupAppLocalizations(const Locale('en'));
    await signUp(tester, c);
    c.read(dataProvider.notifier).updateSettings((s) => s.copyWith(onboardingDone: true));
    await tester.pumpAndSettle();
    c.read(routerProvider).push(Routes.task('new'));
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.saveTask));
    await tester.pumpAndSettle();
    expect(find.text(l.errRequired), findsOneWidget);
    expect(c.read(dataProvider).tasks, isEmpty);
    await tester.enterText(find.byType(TextFormField).first, 'Write report');
    await tapIn(tester, find.text(l.saveTask));
    await tester.pumpAndSettle();
    expect(c.read(dataProvider).tasks.single.title, 'Write report');
  });

  testWidgets('fitness: set up a plan, do a workout, save only the ticked sets (ar)', (tester) async {
    final c = await pumpApp(tester, locale: 'ar', size: const Size(390, 844));
    final l = lookupAppLocalizations(const Locale('ar'));
    await signUp(tester, c);
    c.read(dataProvider.notifier).updateSettings((s) => s.copyWith(onboardingDone: true));
    await tester.pumpAndSettle();
    final router = c.read(routerProvider);
    router.go(Routes.fitness);
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.createMyPlan));
    await tester.pumpAndSettle();

    // Default answers, but train every day of the week starting today.
    await tapIn(tester, find.text('6'));
    await tester.pumpAndSettle();
    final today = DateTime.now().weekday;
    final picked = c.read(dataProvider).settings.weekStart;
    // Make sure today is among the six days.
    final chosen = [for (var i = 0; i < 6; i++) (picked - 1 + i) % 7 + 1];
    if (!chosen.contains(today)) {
      final drop = chosen.last;
      await tapIn(tester, find.widgetWithText(FilterChip, Fmt('ar').weekdayShort(DateTime(2026, 1, 5).add(Duration(days: drop - 1)))));
      await tester.pumpAndSettle();
      await tapIn(tester, find.widgetWithText(FilterChip, Fmt('ar').weekdayShort(DateTime(2026, 1, 5).add(Duration(days: today - 1)))));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text(l.showMyPlan));
    await tester.pumpAndSettle();
    expect(find.text(l.savePlan), findsOneWidget, reason: 'preview shown');
    await tester.tap(find.text(l.savePlan));
    await tester.pumpAndSettle();
    final plan = c.read(dataProvider).activePlan(WorkoutPlace.home)!;
    expect(plan.version, 1);
    expect(plan.dayFor(today), isNotNull);

    await tapIn(tester, find.text(l.startWorkout));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump(const Duration(seconds: 200)); // let the rest timer run out
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.finishWorkout));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.effort('3')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.saveWorkout));
    await tester.pumpAndSettle();
    final s = c.read(dataProvider).workoutSessions.single;
    expect(s.sets, hasLength(1), reason: 'only the ticked set');
    expect(s.status, SessionStatus.partial);
    expect(s.difficulty, 3);
    expect(s.planId, plan.id);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.text(l.workoutDoneToday), findsOneWidget);
  });

  testWidgets('english: placement → path → lesson mastered (en)', (tester) async {
    final c = await pumpApp(tester, locale: 'en', size: const Size(390, 900));
    final l = lookupAppLocalizations(const Locale('en'));
    await signUp(tester, c);
    c.read(dataProvider.notifier).updateSettings((s) => s.copyWith(onboardingDone: true));
    await tester.pumpAndSettle();
    final router = c.read(routerProvider);
    router.go(Routes.english);
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.takePlacement));
    await tester.pumpAndSettle();

    Future<void> answer(Question q, {required bool right, required bool feedback, required bool last}) async {
      final option = q.options[right ? q.answer : (q.answer + 1) % q.options.length];
      await tapIn(tester, find.text(option).last);
      await tester.pumpAndSettle();
      if (feedback) {
        await tapIn(tester, find.text(l.checkAnswer));
        await tester.pumpAndSettle();
      }
      await tapIn(tester, find.text(last ? l.seeResult : l.next));
      await tester.pumpAndSettle();
    }

    // Right on A1–A2, wrong above: should place at A2.
    for (var i = 0; i < placementQuestions.length; i++) {
      final q = placementQuestions[i];
      await answer(q, right: q.level.index <= Cefr.a2.index, feedback: false, last: i == placementQuestions.length - 1);
    }
    expect(find.text(l.placementResult(l.cefr(Cefr.a2))), findsOneWidget);
    await tapIn(tester, find.text(l.startPath));
    await tester.pumpAndSettle();
    expect(c.read(dataProvider).learningPath!.level, Cefr.a2);
    expect(c.read(dataProvider).assessments.single.kind, AssessmentKind.placement);

    final lesson = lessonsAt(Cefr.a2).first;
    await tapIn(tester, find.text(l.startLesson));
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.startQuiz));
    await tester.pumpAndSettle();
    for (var i = 0; i < lesson.quiz.length; i++) {
      await answer(lesson.quiz[i], right: true, feedback: true, last: i == lesson.quiz.length - 1);
    }
    expect(find.text('100%'), findsOneWidget);
    expect(c.read(dataProvider).lessonProgress(lesson.id)!.mastered, isTrue);
    expect(c.read(dataProvider).vocabReviews, hasLength(lesson.words.length));
  });

  testWidgets('reminders are scheduled on the device and permission is asked once', (tester) async {
    final c = await pumpApp(tester, locale: 'en', size: const Size(390, 844));
    final fake = c.read(deviceNotificationsProvider) as FakeDeviceNotifications;
    await signUp(tester, c);
    c.read(dataProvider.notifier).updateSettings((s) => s.copyWith(onboardingDone: true));
    await tester.pumpAndSettle();
    expect(fake.scheduled, isEmpty);

    final d = c.read(dataProvider.notifier);
    final due = DateTime.now().add(const Duration(days: 1));
    final t = d.newTask(
      title: 'Call the bank',
      dueDate: dayKey(due),
      dueTime: 20 * 60,
      reminderAt: DateTime(due.year, due.month, due.day, 19, 30),
    );
    d.saveTask(t);
    await tester.pump(const Duration(seconds: 3)); // debounce
    await tester.pumpAndSettle();
    expect(fake.scheduled.single.route, '/task/${t.id}');

    // Completing the task removes its reminder.
    d.toggleTaskDone(t.id);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(fake.scheduled, isEmpty);

    // Saving a reminder from the editor asks for permission, once.
    final l = lookupAppLocalizations(const Locale('en'));
    c.read(routerProvider).push(Routes.task(t.id));
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.saveTask));
    await tester.pumpAndSettle();
    expect(fake.requests, 1);
    c.read(routerProvider).push(Routes.task(t.id));
    await tester.pumpAndSettle();
    await tapIn(tester, find.text(l.saveTask));
    await tester.pumpAndSettle();
    expect(fake.requests, 1, reason: 'already answered');
  });
}
