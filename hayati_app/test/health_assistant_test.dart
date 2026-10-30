import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/data/app_data.dart';
import 'package:hayati/data/data_controller.dart';
import 'package:hayati/data/models/health.dart';
import 'package:hayati/data/models/nutrition.dart';
import 'package:hayati/data/models/settings.dart';
import 'package:hayati/domain/assistant/engine.dart';
import 'package:hayati/domain/assistant/executor.dart';
import 'package:hayati/domain/assistant/tools.dart';
import 'package:hayati/domain/day_timeline.dart';
import 'package:hayati/domain/health_report.dart';
import 'package:hayati/l10n/app_localizations.dart';

import 'helpers.dart';

void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));
  final en = lookupAppLocalizations(const Locale('en'));
  final now = fixedNow; // Tuesday 2026-03-10 08:00
  AssistantContext ctx(AppData d, [AssistantPermissions p = const AssistantPermissions()]) => AssistantContext(d, p);

  final d = AppData(
    activity: [DailyActivity(id: 'a', day: '2026-03-10', source: ActivitySource.healthConnect, steps: 3200, updatedAt: fixedNow)],
    foodLogs: [
      FoodLog(id: 'f', day: '2026-03-10', meal: MealType.breakfast, name: 'Dates', total: const Nutrients(kcal: 84), loggedAt: fixedNow),
    ],
    water: const [WaterDay(id: 'w', day: '2026-03-10', ml: 500)],
    bodyMetrics: [BodyMetric(id: 'm', kind: MetricKind.weight, value: 80, source: ActivitySource.manual, measuredAt: fixedNow)],
  );

  test('sharing defaults: activity, food and sleep on; measurements and cycle off', () {
    const p = AssistantPermissions();
    expect((p.shareActivity, p.shareNutrition, p.shareSleep, p.shareVitals, p.shareCycle), (true, true, true, false, false));
    final back = AssistantPermissions.fromJson(const AssistantPermissions(shareVitals: true, shareSleep: false).toJson());
    expect((back.shareVitals, back.shareSleep), (true, false));
    // The assistant's view never holds what isn't shared, nor any cycle data.
    final h = ctx(d).health!;
    expect((h.activity.length, h.foodLogs.length, h.bodyMetrics.length, h.periods.length), (1, 1, 0, 0));
    expect(ctx(d, const AssistantPermissions(shareActivity: false, shareNutrition: false, shareSleep: false)).health, isNull);
  });

  test('"how much did I walk today?" and "what did I eat?"', () {
    final r = LocalAssistantEngine(ar).respond('كم مشيت اليوم؟', ctx(d), now);
    expect(r.text, ar.aiStepsToday(3200, 8000, 4800));
    expect(r.calls, isEmpty);
    final off = LocalAssistantEngine(en).respond('how many steps today', ctx(d, const AssistantPermissions(shareActivity: false)), now);
    expect(off.text, en.aiNeedsSharing(en.navActivity));
    final food = LocalAssistantEngine(en).respond('What did I eat today?', ctx(d), now);
    expect(food.text, contains('Dates'));
    expect(food.text, contains(en.aiFoodToday(84, 500)));
  });

  test('"log a glass of water" runs straight away; amounts in ml are read', () async {
    final c = await signedInContainer();
    final data = c.read(dataProvider.notifier);
    final r = LocalAssistantEngine(ar).respond('سجّل كوب ماء', ctx(c.read(dataProvider)), now);
    expect((r.calls.single.tool, r.calls.single.args['ml']), (Tools.logWater, 250));
    expect(const ToolPolicy(AssistantPermissions()).tierOf(r.calls), Tier.autoAllowed);
    final res = AssistantExecutor(data, () => fixedNow).run(r.calls, auto: true);
    expect(res.error, isNull);
    expect(c.read(dataProvider).waterOn('2026-03-10'), 250);
    final big = LocalAssistantEngine(en).respond('log 500 ml water', ctx(c.read(dataProvider)), now);
    expect(big.calls.single.args['ml'], 500);
  });

  test('"doctor appointment on Thursday" is proposed for approval, then saved', () async {
    final c = await signedInContainer();
    final r = LocalAssistantEngine(ar).respond('عندي موعد طبيب الخميس الساعة 10 صباحًا', ctx(c.read(dataProvider)), now);
    final call = r.calls.single;
    expect(call.tool, Tools.addAppointment);
    expect(DateTime.parse(call.args['at'] as String).toLocal(), DateTime(2026, 3, 12, 10));
    expect(const ToolPolicy(AssistantPermissions()).tierOf(r.calls), Tier.approvalRequired);
    AssistantExecutor(c.read(dataProvider.notifier), () => fixedNow).run(r.calls);
    expect(c.read(dataProvider).appointments.single.at, DateTime(2026, 3, 12, 10));
    expect(LocalAssistantEngine(en).respond('I have a doctor appointment', ctx(const AppData()), now).calls, isEmpty);
  });

  test('a short walk is suggested in free time while steps are behind the goal', () {
    final behind = buildTimeline(d, now).items.where((i) => i.kind == TimelineKind.walk).toList();
    expect((behind.length, behind.single.minutes, behind.single.suggested), (1, walkMinutes, true));
    final met = d.copyWith(activity: [DailyActivity(id: 'a', day: '2026-03-10', source: ActivitySource.manual, steps: 9000, updatedAt: fixedNow)]);
    expect(buildTimeline(met, now).items.where((i) => i.kind == TimelineKind.walk), isEmpty);
    final off = d.copyWith(settings: const UserSettings(health: HealthSettings(modules: {})));
    expect(buildTimeline(off, now).items.where((i) => i.kind == TimelineKind.walk), isEmpty);
  });

  test('report: step goal days, sleep, food and water, only up to today', () {
    final week = d.copyWith(activity: [
      for (final (day, s) in [('2026-03-09', 9000), ('2026-03-08', 8100), ('2026-03-07', 2000), ('2026-03-10', 3200)])
        DailyActivity(id: day, day: day, source: ActivitySource.manual, steps: s, updatedAt: fixedNow),
    ], sleep: [
      SleepSession(id: 's', source: ActivitySource.manual, start: DateTime(2026, 3, 9, 23), end: DateTime(2026, 3, 10, 6), updatedAt: fixedNow),
    ]);
    final r = HealthReport.build(week, DateTime(2026, 3, 7), DateTime(2026, 3, 14), now);
    expect((r.goalDays, r.stepDays, r.sleepAvg, r.sleepNights, r.foodDays, r.kcalAvg, r.waterAvg), (2, 4, 420, 1, 1, 84, 500));
    expect(HealthReport.build(const AppData(), DateTime(2026, 3, 7), DateTime(2026, 3, 14), now).isEmpty, isTrue);
  });
}
