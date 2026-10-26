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
  static const prayer = '/prayer';
  static const prayerSettings = '/prayer/settings';
  static const fitness = '/fitness';
  static const fitnessSetup = '/fitness/setup';

  static String task(String id) => '/task/$id';
  static String event(String id) => '/event/$id';
  static String goal(String id) => '/goal/$id';
  static String note(String id) => '/note/$id';
  static String review(String id) => '/assistant/review/$id';
  static String timeTab(String tab) => '/time?tab=$tab';
  static String exercise(String id) => '/fitness/exercise/$id';
  static String workout(String place, int weekday, {bool atHome = false}) =>
      '/fitness/session?place=$place&day=$weekday${atHome ? '&home=1' : ''}';
}
