import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/dates.dart';
import '../../data/auth.dart';
import '../../data/data_controller.dart';
import '../../data/remote/sync.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/assistant/review_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/accountability/accountability_event_screen.dart';
import '../../features/accountability/accountability_screen.dart';
import '../../features/accountability/rule_editor_screen.dart';
import '../../features/activity/activity_screen.dart';
import '../../features/activity/health_setup_screen.dart';
import '../../data/models/nutrition.dart';
import '../../features/nutrition/add_food_screen.dart';
import '../../features/nutrition/custom_food_screen.dart';
import '../../features/nutrition/nutrition_screen.dart';
import '../../features/nutrition/nutrition_week_screen.dart';
import '../../features/nutrition/photo_screen.dart';
import '../../features/nutrition/scan_screen.dart';
import '../../services/barcode_lookup.dart';
import '../../features/english/english_screen.dart';
import '../../features/english/english_test_screen.dart';
import '../../features/english/lesson_screen.dart';
import '../../features/english/review_screen.dart';
import '../../features/expenses/expenses_screen.dart';
import '../../data/models/fitness.dart';
import '../../features/fitness/exercise_screen.dart';
import '../../features/fitness/fitness_screen.dart';
import '../../features/fitness/fitness_setup_screen.dart';
import '../../features/fitness/workout_session_screen.dart';
import '../../features/goals/goal_edit_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/habits/habits_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/notes/note_editor_screen.dart';
import '../../features/notes/notes_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/prayer/prayer_screen.dart';
import '../../features/prayer/prayer_settings_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/settings/assistant_settings_screen.dart';
import '../../features/settings/help_screen.dart';
import '../../features/settings/privacy_screen.dart';
import '../../features/settings/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/subscription_screen.dart';
import '../../features/shell/shell.dart';
import '../../features/time/event_edit_screen.dart';
import '../../features/time/task_edit_screen.dart';
import '../../features/time/time_screen.dart';

import 'route_paths.dart';

export 'route_paths.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

const _publicRoutes = {Routes.welcome, Routes.auth};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.listen(settingsProvider.select((s) => s.onboardingDone), (_, _) => refresh.value++);
  ref.listen(syncProvider.select((s) => s.ready), (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  GoRoute page(String path, Widget Function(GoRouterState) build) => GoRoute(
        path: path,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, s) => build(s),
      );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;
      // Keep the requested location (deep link, web URL) across the splash.
      if (!auth.restored) {
        return loc == Routes.splash ? null : '${Routes.splash}?from=${Uri.encodeComponent(state.uri.toString())}';
      }
      if (!auth.signedIn) return _publicRoutes.contains(loc) ? null : Routes.welcome;
      // New device, connected mode: wait for the account's data before
      // deciding between onboarding and home.
      if (!ref.read(syncProvider).ready) {
        return loc == Routes.splash ? null : '${Routes.splash}?from=${Uri.encodeComponent(state.uri.toString())}';
      }
      final onboarded = ref.read(settingsProvider).onboardingDone;
      if (!onboarded) return loc == Routes.onboarding ? null : Routes.onboarding;
      if (loc == Routes.splash) {
        final from = state.uri.queryParameters['from'];
        return from != null && from.startsWith('/') && !from.startsWith(Routes.splash) ? from : Routes.home;
      }
      if (_publicRoutes.contains(loc) || loc == Routes.onboarding) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
      GoRoute(
        path: Routes.auth,
        builder: (_, s) => AuthScreen(signUp: s.uri.queryParameters['mode'] == 'signup'),
      ),
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.time,
              builder: (_, s) => TimeScreen(initialTab: s.uri.queryParameters['tab']),
            ),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.goals, builder: (_, _) => const GoalsScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.assistant,
              builder: (_, s) => AssistantScreen(prompt: s.uri.queryParameters['q']),
            ),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.progress, builder: (_, _) => const ProgressScreen())]),
        ],
      ),
      page('/task/:id', (s) => TaskEditScreen(
            taskId: s.pathParameters['id'] == 'new' ? null : s.pathParameters['id'],
            goalId: s.uri.queryParameters['goal'],
            dueDate: s.uri.queryParameters['date'],
          )),
      page('/event/:id', (s) => EventEditScreen(
            eventId: s.pathParameters['id'] == 'new' ? null : s.pathParameters['id'],
            date: s.uri.queryParameters['date'],
          )),
      page('/goal/:id', (s) => GoalEditScreen(goalId: s.pathParameters['id'] == 'new' ? null : s.pathParameters['id'])),
      page('/assistant/review/:id', (s) => ReviewScreen(proposalId: s.pathParameters['id']!)),
      page(Routes.prayer, (_) => const PrayerScreen()),
      page(Routes.prayerSettings, (_) => const PrayerSettingsScreen()),
      page(Routes.fitness, (_) => const FitnessScreen()),
      page(Routes.fitnessSetup, (_) => const FitnessSetupScreen()),
      page('/fitness/exercise/:id', (s) => ExerciseScreen(exerciseId: s.pathParameters['id']!)),
      page('/fitness/session', (s) => WorkoutSessionScreen(
            place: WorkoutPlace.values.where((p) => p.name == s.uri.queryParameters['place']).firstOrNull ?? WorkoutPlace.home,
            weekday: int.tryParse(s.uri.queryParameters['day'] ?? '') ?? DateTime.now().weekday,
            atHome: s.uri.queryParameters['home'] == '1',
          )),
      page(Routes.english, (_) => const EnglishScreen()),
      page('/english/test', (s) => EnglishTestScreen(levelCheck: s.uri.queryParameters['kind'] == 'level')),
      page('/english/lesson/:id', (s) => LessonScreen(lessonId: s.pathParameters['id']!)),
      page(Routes.englishReview, (_) => const EnglishReviewScreen()),
      page(Routes.activity, (_) => const ActivityScreen()),
      page(Routes.healthSetup, (_) => const HealthSetupScreen()),
      page(Routes.nutrition, (_) => const NutritionScreen()),
      page(Routes.nutritionWeek, (_) => const NutritionWeekScreen()),
      page('/nutrition/add', (s) => AddFoodScreen(day: _day(s), meal: _meal(s), query: s.uri.queryParameters['q'] ?? '')),
      page('/nutrition/photo', (s) => PhotoScreen(day: _day(s), meal: _meal(s))),
      page('/nutrition/scan', (s) => ScanScreen(day: _day(s), meal: _meal(s))),
      page('/nutrition/food', (s) => CustomFoodScreen(
            foodId: s.uri.queryParameters['id'],
            barcode: s.uri.queryParameters['barcode'],
            product: s.extra is ProductInfo ? s.extra! as ProductInfo : null,
            day: _day(s),
            meal: _meal(s),
          )),
      page(Routes.accountability, (_) => const AccountabilityScreen()),
      page('/accountability/rule', (s) => RuleEditorScreen(ruleId: s.uri.queryParameters['id'], taskId: s.uri.queryParameters['task'])),
      page('/accountability/event/:id', (s) => AccountabilityEventScreen(eventId: s.pathParameters['id']!)),
      page(Routes.habits, (_) => const HabitsScreen()),
      page(Routes.notes, (_) => const NotesScreen()),
      page('/note/:id', (s) => NoteEditorScreen(noteId: s.pathParameters['id'] == 'new' ? null : s.pathParameters['id'])),
      page(Routes.expenses, (_) => const ExpensesScreen()),
      page(Routes.notifications, (_) => const NotificationsScreen()),
      page(Routes.settings, (_) => const SettingsScreen()),
      page(Routes.assistantSettings, (_) => const AssistantSettingsScreen()),
      page(Routes.profile, (_) => const ProfileScreen()),
      page(Routes.subscription, (_) => const SubscriptionScreen()),
      page(Routes.help, (_) => const HelpScreen()),
      page(Routes.privacy, (_) => const PrivacyScreen()),
    ],
  );
});

/// The day a food screen adds to (today unless given; never in the future).
String _day(GoRouterState s) {
  final today = dayKey(DateTime.now());
  final d = s.uri.queryParameters['day'];
  return d != null && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(d) && d.compareTo(today) <= 0 ? d : today;
}

MealType _meal(GoRouterState s) =>
    MealType.values.where((m) => m.name == s.uri.queryParameters['meal']).firstOrNull ?? MealType.snack;
