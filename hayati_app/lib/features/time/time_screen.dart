import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'calendar_view.dart';
import 'planner_view.dart';
import 'tasks_view.dart';
import '../../widgets/home_logo.dart';

/// "My time" destination: Tasks (screen 6), Calendar (8) and Planner (9).
class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key, this.initialTab});
  final String? initialTab;

  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> with SingleTickerProviderStateMixin {
  static const _tabs = ['tasks', 'calendar', 'planner'];
  late final TabController _c = TabController(length: 3, vsync: this, initialIndex: _index(widget.initialTab));

  static int _index(String? t) => t == null ? 0 : _tabs.indexOf(t).clamp(0, 2);

  @override
  void didUpdateWidget(TimeScreen old) {
    super.didUpdateWidget(old);
    if (widget.initialTab != old.initialTab && widget.initialTab != null) _c.animateTo(_index(widget.initialTab));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.navTime),
        bottom: TabBar(controller: _c, tabs: [Tab(text: l.navTasks), Tab(text: l.calendar), Tab(text: l.planner)]), actions: const [HomeLogoButton()],
      ),
      body: TabBarView(controller: _c, children: const [TasksView(), CalendarView(), PlannerView()]),
    );
  }
}
