import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/app.dart';
import 'package:hayati/core/router/app_router.dart';
import 'package:hayati/core/utils/dates.dart';
import 'package:hayati/data/auth.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/goal.dart';
import 'package:hayati/data/models/misc.dart';
import 'package:hayati/data/models/task.dart';
import 'package:hayati/data/store/local_store.dart';
import 'package:hayati/domain/assistant/assistant_service.dart';
import 'package:hayati/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> pumpApp(WidgetTester tester, {required String locale, required Size size}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({DevicePrefs.localeKey: locale});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [localStoreProvider.overrideWithValue(LocalStore(prefs))]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const HayatiApp()));
  await tester.pumpAndSettle();
  return container;
}

/// Signs up while pumping, so the fake-async timers inside complete.
Future<void> signUp(WidgetTester tester, ProviderContainer c) async {
  var done = false;
  c.read(authProvider.notifier).signUp('u@example.com', 'password1').then((_) => done = true);
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
  d.saveHabit(Habit(id: 'h1', name: 'Walk', weekdays: const {1, 2, 3, 4, 5, 6, 7}, startDate: dayKey(now.subtract(const Duration(days: 40))), reminderMinutes: 0));
  d.setHabitDone('h1', dayKey(now.subtract(const Duration(days: 1))), true);
  d.saveNote(Note(id: 'n1', title: 'Idea', body: 'Some body text', category: 'work', pinned: true, goalId: 'g1', updatedAt: now));
  d.addExpense(Expense(id: 'x1', amountMinor: 2550, currency: 'SAR', category: 'food', spentAt: now, description: 'Lunch'));
  d.addExpense(Expense(id: 'x2', amountMinor: 1000, currency: 'USD', category: 'education', spentAt: now));
  d.saveBudget(const Budget(id: 'b1', currency: 'SAR', limitMinor: 2000));
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

      expect(find.text(l.todayPlan), findsOneWidget);
      expect(find.text(l.newUserTitle), findsOneWidget);
      expect(c.read(dataProvider).settings.onboardingDone, isTrue);
    });
  }

  for (final (name, size) in [('phone', const Size(390, 844)), ('desktop', const Size(1366, 900))]) {
    for (final locale in ['ar', 'en']) {
      testWidgets('every screen renders with data ($name, $locale)', (tester) async {
        final c = await pumpApp(tester, locale: locale, size: size);
        await signUp(tester, c);
        c.read(dataProvider.notifier).updateSettings((s) => s.copyWith(onboardingDone: true));
        seed(c);
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
        ];
        for (final r in routes) {
          router.go(r);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: r);
          // Guards against a screen laying out with an empty body.
          expect(find.byType(Text).evaluate().length + find.byType(EditableText).evaluate().length, greaterThan(6), reason: r);
        }
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
}
