import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/auth.dart';
import '../../data/data_controller.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/assistant/review_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/expenses/expenses_screen.dart';
import '../../features/goals/goal_edit_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/habits/habits_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/notes/note_editor_screen.dart';
import '../../features/notes/notes_screen.dart';
import '../../features/notifications/notifications_screen.dart';
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

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Route paths in one place.
abstract final class Routes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const auth = '/auth';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const time = '/time';
  static const goals = '/goals';
  static const assistant = '/assistant';
  static const progress = '/progress';
  static const habits = '/habits';
  static const notes = '/notes';
  static const expenses = '/expenses';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const assistantSettings = '/settings/assistant';
  static const profile = '/settings/profile';
  static const subscription = '/settings/subscription';
  static const help = '/settings/help';
  static const privacy = '/settings/privacy';

  static String task(String id) => '/task/$id';
  static String event(String id) => '/event/$id';
  static String goal(String id) => '/goal/$id';
  static String note(String id) => '/note/$id';
  static String review(String id) => '/assistant/review/$id';
  static String timeTab(String tab) => '/time?tab=$tab';
}

const _publicRoutes = {Routes.welcome, Routes.auth};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.listen(settingsProvider.select((s) => s.onboardingDone), (_, _) => refresh.value++);
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
