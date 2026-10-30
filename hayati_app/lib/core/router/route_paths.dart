/// Route paths in one place.
abstract final class Routes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const auth = '/auth';
  static const onboarding = '/onboarding';
  static const locked = '/locked';
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
  static const notificationSettings = '/settings/notifications';
  static const profile = '/settings/profile';
  static const subscription = '/settings/subscription';
  static const help = '/settings/help';
  static const privacy = '/settings/privacy';
  static const prayer = '/prayer';
  static const prayerSettings = '/prayer/settings';
  static const fitness = '/fitness';
  static const fitnessSetup = '/fitness/setup';
  static const english = '/english';
  static const accountability = '/accountability';
  static const activity = '/activity';
  static const healthSetup = '/health';
  static const devices = '/health/devices';
  static const healthPrivacy = '/health/privacy';
  static const appointments = '/health/appointments';
  static const vitals = '/health/vitals';
  static const sleep = '/health/sleep';
  static const learn = '/health/learn';
  static const womens = '/womens';
  static const womensInsights = '/womens/insights';
  static const nutrition = '/nutrition';
  static const nutritionWeek = '/nutrition/week';
  static String _q(Map<String, String?> m) {
    final e = {for (final x in m.entries) if (x.value != null) x.key: x.value!};
    return e.isEmpty ? '' : '?${Uri(queryParameters: e).query}';
  }

  static String nutritionAdd({String? day, String? meal, String? q}) => '/nutrition/add${_q({'day': day, 'meal': meal, 'q': q})}';
  static String nutritionPhoto({String? day, String? meal}) => '/nutrition/photo${_q({'day': day, 'meal': meal})}';
  static String nutritionScan({String? day, String? meal}) => '/nutrition/scan${_q({'day': day, 'meal': meal})}';
  static String customFood({String? id, String? barcode, String? day, String? meal}) =>
      '/nutrition/food${_q({'id': id, 'barcode': barcode, 'day': day, 'meal': meal})}';
  static const englishReview = '/english/review';
  static const placement = '/english/test?kind=placement';
  static const levelCheck = '/english/test?kind=level';

  static String task(String id) => '/task/$id';
  static String event(String id) => '/event/$id';
  static String goal(String id) => '/goal/$id';
  static String note(String id) => '/note/$id';
  static String review(String id) => '/assistant/review/$id';
  static String timeTab(String tab) => '/time?tab=$tab';
  static String exercise(String id) => '/fitness/exercise/$id';
  static String womensDay(String day) => '/womens/day?day=$day';
  static String appointment(String id) => '/health/appointments/$id';
  static String article(String id) => '/health/learn/$id';
  static String program(String id) => '/fitness/program/$id';
  static String programSession(String id) => '/fitness/session?program=$id';
  static const fitnessProgress = '/fitness/progress';
  static String lesson(String id) => '/english/lesson/$id';
  static String accountabilityRule({String? ruleId, String? taskId}) =>
      '/accountability/rule${ruleId != null ? '?id=$ruleId' : (taskId != null ? '?task=$taskId' : '')}';
  static String accountabilityEvent(String id) => '/accountability/event/$id';
  static String workout(String place, int weekday, {bool atHome = false}) =>
      '/fitness/session?place=$place&day=$weekday${atHome ? '&home=1' : ''}';
}
