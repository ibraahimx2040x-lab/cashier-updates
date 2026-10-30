// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accAddRule => 'Add a commitment';

  @override
  String get accAgree =>
      'I agree to this rule, and I can edit or pause it anytime';

  @override
  String get accAgreedConsequence => 'What you agreed to';

  @override
  String accAnsweredOn(String date) {
    return 'Answered $date';
  }

  @override
  String get accCloseTask => 'Close the task';

  @override
  String get accConfirm => 'Confirm';

  @override
  String get accConsequenceAsTask =>
      'It will be added as a small task for today, and the task gets the new deadline below.';

  @override
  String get accCustomEmpty => 'Write what you agree to do';

  @override
  String get accCustomLong => 'Keep it under 200 characters';

  @override
  String get accCustomUnsafe =>
      'Choose something that doesn\'t touch sleep, food, prayer, health care, or add exercise';

  @override
  String accDaysLate(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days late',
      one: '1 day late',
    );
    return '$_temp0';
  }

  @override
  String get accDeleteRule => 'Delete this commitment?';

  @override
  String get accDeleteRuleBody =>
      'The task stays. Past records are kept without the rule.';

  @override
  String get accDropNote =>
      'No problem. The task will be closed and its rule paused. Nothing else happens.';

  @override
  String accDue(String date) {
    return 'Due $date';
  }

  @override
  String get accEditRule => 'Edit commitment';

  @override
  String get accEmergencyNote =>
      'Emergencies happen. No consequence — just pick a new deadline that works.';

  @override
  String get accHistory => 'What happened before';

  @override
  String get accIllnessNote =>
      'Your health comes first. No consequence — pick a new deadline when you\'re ready.';

  @override
  String accLateBy(int n, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days past $date',
      one: '1 day past $date',
    );
    return '$_temp0';
  }

  @override
  String get accMakeupPlan => 'Make-up plan: a new deadline';

  @override
  String accMissedOn(String date) {
    return 'Was due $date';
  }

  @override
  String get accNeedsAnswer => 'Needs your answer';

  @override
  String get accNewDeadline => 'New deadline';

  @override
  String accNewDue(String date) {
    return 'New deadline $date';
  }

  @override
  String get accNoBlame =>
      'No blame. Tell us what happened and we\'ll adjust together.';

  @override
  String get accNoEligibleTasks => 'Add an open task with a deadline first.';

  @override
  String get accNoRules =>
      'No commitments yet. Add one for a task you keep putting off.';

  @override
  String get accNote => 'Note (optional)';

  @override
  String get accOpenTask => 'Open the task';

  @override
  String get accPickTask => 'Pick a task';

  @override
  String get accPrinciple1 => 'You choose the consequence in advance.';

  @override
  String get accPrinciple2 =>
      'Only a deliberate postponement brings it — never an emergency or illness.';

  @override
  String get accPrinciple3 =>
      'Nothing is rescheduled or closed without your OK.';

  @override
  String get accPrinciple4 =>
      'Never sleep, food, prayer, health care, or extra exercise.';

  @override
  String get accRuleRemoved => 'The rule was removed — nothing extra.';

  @override
  String get accRuleSaved => 'Commitment saved';

  @override
  String accRuleSummary(int days, String consequence) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'After $days days late',
      one: 'After 1 day late',
    );
    return '$_temp0: $consequence';
  }

  @override
  String get accRules => 'Your commitments';

  @override
  String get accSafety =>
      'Consequences are always harmless: they never take away sleep, food, prayer or health care, and never add exercise.';

  @override
  String get accSaved => 'Saved. Thanks for being honest.';

  @override
  String get accTitle => 'Commitments, kindly';

  @override
  String get accWhatHappens => 'Then what?';

  @override
  String get accWhenLate => 'When is it late?';

  @override
  String get accWhichTask => 'Which task?';

  @override
  String get accWhy => 'Why was it late?';

  @override
  String get account => 'Account';

  @override
  String get actionLog => 'Action log';

  @override
  String get actionLogSub =>
      'What the assistant changed, and when. No message content is stored here.';

  @override
  String get active => 'Active';

  @override
  String activeMinutesN(int n) {
    return '$n active minutes';
  }

  @override
  String get activityNote =>
      'Steps come from your phone\'s health app (Health Connect or Apple Health), which already combines your phone and watch. Distance is estimated from steps and height.';

  @override
  String get activitySaved => 'Steps saved';

  @override
  String get activityWebNote =>
      'In the browser steps can only be added by hand. Automatic counting works in the phone app.';

  @override
  String get addAppointment => 'Add appointment';

  @override
  String get addBreak => 'Add a break';

  @override
  String get addCup => 'Add a glass (250 ml)';

  @override
  String get addEvent => 'Add event';

  @override
  String get addExpense => 'Add expense';

  @override
  String get addFirstGoal => 'Add a goal';

  @override
  String get addFirstTask => 'Add your first task';

  @override
  String get addFood => 'Add food';

  @override
  String get addGoal => 'Add goal';

  @override
  String get addHabit => 'Add habit';

  @override
  String get addIncome => 'Add income';

  @override
  String get addMeasurement => 'Add measurement';

  @override
  String get addMilestone => 'Add milestone';

  @override
  String get addMonthlyExpense => 'Add a monthly expense';

  @override
  String get addMonthlyIncome => 'Add monthly income';

  @override
  String get addMyOwnFood => 'Add my own food';

  @override
  String get addNote => 'Add note';

  @override
  String get addPastPeriod => 'Add a past period';

  @override
  String get addQuestion => 'Add a question';

  @override
  String get addSleep => 'Add sleep';

  @override
  String get addStepsManually => 'Add steps';

  @override
  String get addTask => 'Add task';

  @override
  String addTo(String meal) {
    return 'Add to $meal';
  }

  @override
  String get addToDay => 'Add';

  @override
  String get adherence30 => 'Last 30 days';

  @override
  String affectedItems(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n items affected',
      one: '1 item affected',
    );
    return '$_temp0';
  }

  @override
  String get agreePrefix => 'I agree to the ';

  @override
  String get aiAppointmentNoTime =>
      'No time given: set for 9:00, change it after';

  @override
  String aiAppointmentReady(String title) {
    return '“$title” is ready to add to your health appointments.';
  }

  @override
  String get aiAppointmentTitle => 'Doctor appointment';

  @override
  String get aiAppointmentWhen =>
      'When is it? For example: “doctor appointment on Thursday at 10”.';

  @override
  String aiAskAmPm(int hour) {
    return 'Do you mean $hour in the morning or in the evening?';
  }

  @override
  String get aiAutoDone =>
      'Done automatically (you allowed this in assistant settings).';

  @override
  String get aiChipAddTask => 'Add a new task';

  @override
  String get aiChipFreeTime => 'I have half an hour, what can I get done?';

  @override
  String get aiChipLate => 'I\'m running late, rearrange the rest of my day';

  @override
  String get aiChipOverdue => 'Sort my overdue tasks';

  @override
  String get aiChipPlanDay => 'Plan my day';

  @override
  String get aiChipReview => 'Review my progress this week';

  @override
  String get aiChipSplitGoal => 'Help me break down my goal';

  @override
  String aiConflictWith(String title) {
    return 'This overlaps with “$title”.';
  }

  @override
  String get aiData => 'Assistant and your data';

  @override
  String get aiDataBody =>
      'In this version the assistant runs entirely on your device; nothing is sent to an AI provider. When the cloud assistant is enabled, only the sections you allow will be sent to the provider through our server, to answer your request.';

  @override
  String get aiDisabled => 'The assistant is turned off in assistant settings.';

  @override
  String get aiDraftsDisabled =>
      'Drafting plans is turned off in assistant settings, so I didn\'t prepare changes.';

  @override
  String get aiExample1 => 'Add a task to review English tomorrow at 8 pm';

  @override
  String get aiExample2 => 'I want to learn English, 30 minutes every day';

  @override
  String get aiExample3 => 'Plan my day';

  @override
  String get aiExecFailed => 'I couldn\'t apply that. Nothing was changed.';

  @override
  String get aiFailed =>
      'Something went wrong and I couldn\'t answer. Your message is kept — try again.';

  @override
  String aiFoodToday(int kcal, int water) {
    return 'Today: about $kcal kcal and $water ml of water.';
  }

  @override
  String aiFreeTime(int minutes) {
    return 'You have $minutes min. These tasks fit:';
  }

  @override
  String aiFreeTimeItem(String title, int minutes) {
    return '• $title ($minutes min)';
  }

  @override
  String aiFreeTimeNone(int minutes) {
    return 'No open task with an estimate fits $minutes min. Try splitting a bigger task, or take a break.';
  }

  @override
  String get aiGoalFirstWeekOnly =>
      'Only the first week of sessions is created; you can add more later.';

  @override
  String get aiGoalNoSubject => 'What would you like to learn?';

  @override
  String aiGoalReady(String subject, int minutes, int days) {
    return 'Here\'s a plan to learn $subject: $minutes-minute daily sessions over $days days, with four milestones and your first week of sessions. Nothing is created until you approve.';
  }

  @override
  String aiGoalTitle(String subject) {
    return 'Learn $subject';
  }

  @override
  String get aiGymAtHome => 'Here\'s today\'s gym workout at home:';

  @override
  String get aiGymAtHomeHint =>
      'Open Fitness and tap \"Can\'t go to the gym\" to start it.';

  @override
  String aiHabitLogged(String name) {
    return 'I\'ll log “$name” as done today.';
  }

  @override
  String aiLessonSlot(String time) {
    return 'You have free time around $time today for it.';
  }

  @override
  String get aiLimitReached =>
      'You\'ve reached today\'s assistant limit. Everything else keeps working; the limit resets tomorrow.';

  @override
  String aiMs1(String subject) {
    return 'Assess your level and pick resources for $subject';
  }

  @override
  String aiMs2(String subject) {
    return 'Learn the fundamentals of $subject';
  }

  @override
  String aiMs3(String subject) {
    return 'Practice $subject regularly';
  }

  @override
  String aiMs4(String subject) {
    return 'Complete a small project or self-test in $subject';
  }

  @override
  String aiNeedsSharing(String section) {
    return 'You haven\'t allowed me to read your $section. You can change this in assistant settings.';
  }

  @override
  String aiNextLesson(String title, int minutes) {
    return 'Next lesson: $title (about $minutes min).';
  }

  @override
  String get aiNoEnglishPath =>
      'You haven\'t started the English path yet. Open English to take the placement test.';

  @override
  String get aiNoGoalToSplit =>
      'I didn\'t find an active goal without milestones. Create a goal first or tell me what you want to learn.';

  @override
  String get aiNoGymPlan =>
      'You don\'t have a gym plan yet. Set one up in Fitness.';

  @override
  String get aiNoGymToday =>
      'Today isn\'t a gym day in your plan, so there\'s nothing to replace.';

  @override
  String get aiNoOverdue => 'You have no overdue tasks. 🎉';

  @override
  String get aiNoSlotToday =>
      'There\'s no free slot left today; tomorrow is fine — the path waits for you.';

  @override
  String get aiNoStepsYet => 'No steps recorded today yet.';

  @override
  String get aiNoteEmpty => 'What should the note say?';

  @override
  String get aiNoteReady => 'I\'ll save this note.';

  @override
  String aiOverdueSummary(int total, int today, int tomorrow) {
    return 'You have $total overdue tasks. I can fit $today today; $tomorrow would move to tomorrow.';
  }

  @override
  String get aiPlanEstimated =>
      'Some tasks have no duration; I assumed 30 minutes for them.';

  @override
  String get aiPlanNoEvents =>
      'I can\'t see your events (sharing is off), so the plan may overlap them.';

  @override
  String get aiPlanNothing => 'There are no open tasks to plan for today.';

  @override
  String aiPlanSummary(int planned, int hours, int minutes) {
    return 'Here\'s a suggested plan: $planned tasks in your free time (about $hours h $minutes min available). Review it before applying.';
  }

  @override
  String aiPlanUnscheduled(int n) {
    return '$n tasks don\'t fit today — consider moving them or shortening them.';
  }

  @override
  String get aiReasonAppointment => 'You mentioned an appointment';

  @override
  String get aiReasonGoal =>
      'You asked for a learning goal with regular practice.';

  @override
  String aiReasonHabit(String name) {
    return 'You said you completed “$name”.';
  }

  @override
  String get aiReasonNote => 'You asked to add a note.';

  @override
  String get aiReasonOverdue =>
      'Reschedule overdue tasks into today\'s free time, moving the rest to tomorrow.';

  @override
  String get aiReasonPlan =>
      'Distribute today\'s open tasks around fixed commitments, by priority and deadline.';

  @override
  String aiReasonSplit(String title) {
    return 'Break “$title” into clear milestones.';
  }

  @override
  String get aiReasonTask => 'You asked to add a task.';

  @override
  String get aiReasonWater => 'You asked to log water';

  @override
  String get aiRefused =>
      'I can\'t help with that request. Try asking in a different way.';

  @override
  String aiReviewFirst(int n) {
    return 'Start with a quick review of $n words — it helps more than skipping ahead.';
  }

  @override
  String aiReviewGoal(String title, int percent) {
    return '“$title” is at $percent%.';
  }

  @override
  String aiReviewHabits(int done, int total) {
    return 'Habits: $done of $total due check-ins logged.';
  }

  @override
  String get aiReviewNote =>
      'These are descriptive numbers from what you recorded — not judgments about why.';

  @override
  String aiReviewOverdue(int n) {
    return '$n tasks due this week are still open past their deadline.';
  }

  @override
  String aiReviewRate(int percent, int total) {
    return 'You finished $percent% of the $total tasks due this week.';
  }

  @override
  String aiReviewTasks(int n) {
    return 'This week you completed $n tasks.';
  }

  @override
  String aiSessionTitle(String subject, int n) {
    return '$subject — session $n';
  }

  @override
  String aiSplitReady(String title) {
    return 'Here\'s a suggested breakdown for “$title”.';
  }

  @override
  String aiStepsGoalMet(int steps, int goal) {
    return '$steps steps today: your goal of $goal is reached.';
  }

  @override
  String aiStepsToday(int steps, int goal, int left) {
    return '$steps steps today, $left to your goal of $goal.';
  }

  @override
  String get aiTaskNoTitle =>
      'What\'s the task? For example: “Add task review English tomorrow at 8 pm”.';

  @override
  String aiTaskReady(String title) {
    return 'I\'ll create the task “$title”.';
  }

  @override
  String get aiTimeInPast => 'That time has already passed.';

  @override
  String get aiUnsupported =>
      'I can\'t do that yet. I can plan your day, sort overdue tasks, add tasks or notes, log habits, break a goal into milestones, or review your week.';

  @override
  String aiWaterLogged(int ml) {
    return 'Logging $ml ml of water for today.';
  }

  @override
  String get allCategories => 'All categories';

  @override
  String get allDoneToday => 'You\'ve finished everything planned for today.';

  @override
  String get allMilestonesDone =>
      'All milestones are done. Mark the goal as completed?';

  @override
  String get allTasks => 'All tasks';

  @override
  String get alreadyExecuted => 'Already applied — nothing was repeated.';

  @override
  String get alternatives => 'Alternatives';

  @override
  String get alwaysRequired => 'Always required — cannot be turned off';

  @override
  String get amount => 'Amount';

  @override
  String get and => 'and';

  @override
  String andMore(int n) {
    return 'and $n more';
  }

  @override
  String get answerRight => 'Correct!';

  @override
  String answerWrong(String answer) {
    return 'The right answer: $answer';
  }

  @override
  String get any => 'Any';

  @override
  String get apCheckup => 'Checkup';

  @override
  String get apFollowup => 'Follow-up';

  @override
  String get apOther => 'Other';

  @override
  String get apTest => 'Test';

  @override
  String get appName => 'Sanad';

  @override
  String get appVersion => 'App version';

  @override
  String get appearance => 'Appearance';

  @override
  String get applyPlan => 'Apply plan';

  @override
  String applyPlanBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tasks will get planned times:',
      one: '1 task will get a planned time:',
    );
    return '$_temp0';
  }

  @override
  String get appointmentReminderNote =>
      'The reminder says “Health appointment” and the time only, not the title.';

  @override
  String get appointmentTitle => 'What is it for?';

  @override
  String get appointments => 'Health appointments';

  @override
  String get appointmentsSub => 'Checkups, tests and questions for the doctor';

  @override
  String get approvals => 'Always ask before';

  @override
  String get approve => 'Approve';

  @override
  String get approveBulk => 'Changes to several items at once';

  @override
  String get approveDelete => 'Deleting anything';

  @override
  String get approveReschedule => 'Changing a time or deadline';

  @override
  String get approveRescheduleSub =>
      'Recommended. Applies to single changes only.';

  @override
  String get approved => 'Approved';

  @override
  String get approx => 'approx.';

  @override
  String approximateSwap(String from, String to) {
    return '$from → $to (approximate)';
  }

  @override
  String get archive => 'Archive';

  @override
  String get archiveGoal => 'Archive';

  @override
  String get archived => 'Archived';

  @override
  String get archivedNotes => 'Archived notes';

  @override
  String get articleDisclaimer =>
      'General information, not a diagnosis or treatment. Contact a doctor about your own health, and emergency services if it\'s urgent.';

  @override
  String get articleUnavailable =>
      'This article isn\'t in your health sections.';

  @override
  String get askAssistantReplan => 'Ask the assistant to rearrange my day';

  @override
  String get askAssistantReview => 'Ask the assistant';

  @override
  String get askHayati => 'Ask Sanad';

  @override
  String get assistantDisabled => 'The assistant is turned off';

  @override
  String get assistantDisabledBody =>
      'Everything else in Sanad keeps working. Turn it on in settings any time.';

  @override
  String get assistantHint => 'Ask me to plan, add or review…';

  @override
  String get assistantIntroBody =>
      'I work with your own tasks, events and goals. I prepare changes; you decide what gets applied.';

  @override
  String get assistantIntroTitle => 'How can I help today?';

  @override
  String get assistantSettings => 'Assistant settings';

  @override
  String get assistantSubtitle => 'I help you organize your time and goals';

  @override
  String get assistantTitle => 'Sanad assistant';

  @override
  String assistantUsage(int used, int limit) {
    return 'Assistant today: $used of $limit';
  }

  @override
  String get atTime => 'At the time';

  @override
  String get auto => 'Automatic';

  @override
  String get autoActions => 'May do without asking';

  @override
  String get autoActionsSub =>
      'Each permission is separate and can be withdrawn at any time.';

  @override
  String get automatic => 'Automatic';

  @override
  String get averageCycle => 'Average cycle';

  @override
  String get averagePeriod => 'Average period';

  @override
  String avgKcalPerDay(String kcal) {
    return '$kcal kcal a day on average';
  }

  @override
  String get back => 'Back';

  @override
  String get backHome => 'Back to My day';

  @override
  String get backToPath => 'Back to the path';

  @override
  String get barcodeInvalid => 'A barcode is 6 to 14 digits';

  @override
  String barcodeN(String code) {
    return 'Barcode $code';
  }

  @override
  String get barcodeNumber => 'Barcode number';

  @override
  String get bedTime => 'I go to sleep at';

  @override
  String get bedTimeHint =>
      'A bedtime after midnight counts as the same night. Outside these hours nothing counts as free time.';

  @override
  String get bedtimeReminder => 'Bedtime reminder';

  @override
  String get bedtimeReminderSub => 'A nudge to start winding down';

  @override
  String beforeMinutes(String duration) {
    return '$duration before';
  }

  @override
  String get benefit1Body =>
      'Fits tasks around your fixed commitments and leaves room to breathe.';

  @override
  String get benefit1Title => 'A realistic daily plan';

  @override
  String get benefit2Body =>
      'Progress updates from what you actually complete.';

  @override
  String get benefit2Title => 'Goals that move forward';

  @override
  String get benefit3Body =>
      'Suggests and prepares; sensitive changes always wait for your approval.';

  @override
  String get benefit3Title => 'An assistant you control';

  @override
  String get bestDay => 'Best day';

  @override
  String get bestLabel => 'Best';

  @override
  String get billingNote =>
      'Paid features are only enabled after your purchase is verified by our server through the app store.';

  @override
  String get bodyweight => 'Body weight';

  @override
  String get bpSeeDoctor =>
      'Your last three blood pressure readings average 140/90 or higher. That\'s worth checking with a doctor.';

  @override
  String get bpUrgent =>
      'Your last reading is 180/120 or higher. If you have chest pain, shortness of breath, a severe headache or changes in vision, get urgent help now. Otherwise rest a few minutes, measure again, and contact a doctor today.';

  @override
  String bpmN(int n) {
    return '$n bpm';
  }

  @override
  String get breakEnd => 'Until';

  @override
  String get breakStart => 'Break from';

  @override
  String get breaksTitle => 'Breaks';

  @override
  String get budget => 'Budget';

  @override
  String budgetUsed(String spent, String cap) {
    return '$spent of $cap';
  }

  @override
  String get builtinNote =>
      'Values are typical estimates for one portion; home recipes and sizes vary. Change the amount, or save your own version.';

  @override
  String get busyTime => 'Taken';

  @override
  String get byCategory => 'By category';

  @override
  String get byMilestones => 'By milestones';

  @override
  String get byMilestonesHint =>
      'Progress = completed milestones ÷ all milestones. A milestone completes when you check it or when all its tasks are done.';

  @override
  String get byMonth => 'By month';

  @override
  String get calendar => 'Calendar';

  @override
  String get calories => 'Calories (kcal)';

  @override
  String get caloriesByDay => 'Calories by day';

  @override
  String get caloriesToday => 'Calories';

  @override
  String get cameraUnavailable =>
      'The camera isn\'t available. Type the number below.';

  @override
  String canMoveCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other:
          '$n tasks don\'t fit today and can move without hurting your goals',
      one: '1 task doesn\'t fit today and can move without hurting your goals',
    );
    return '$_temp0';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get cantGoToGym => 'Can\'t go to the gym';

  @override
  String get carbs => 'Carbs';

  @override
  String get carbsG => 'Carbs (g)';

  @override
  String get catHealth => 'Health';

  @override
  String get catLearning => 'Learning';

  @override
  String get catMoney => 'Money';

  @override
  String get catPersonal => 'Personal';

  @override
  String get catWork => 'Work';

  @override
  String get category => 'Category';

  @override
  String get categoryOptional => 'Category (optional)';

  @override
  String get cefrA1 => 'A1 · Beginner';

  @override
  String get cefrA2 => 'A2 · Elementary';

  @override
  String get cefrB1 => 'B1 · Intermediate';

  @override
  String get cefrB2 => 'B2 · Upper intermediate';

  @override
  String changeDown(int pct) {
    return '$pct% less';
  }

  @override
  String changeIn30Days(String change) {
    return '$change in 30 days';
  }

  @override
  String get changePassword => 'Change password';

  @override
  String get changeSalary => 'Change salary';

  @override
  String get changeSame => 'Same as last month';

  @override
  String changeUp(int pct) {
    return '$pct% more';
  }

  @override
  String changesCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n changes',
      one: '1 change',
    );
    return '$_temp0';
  }

  @override
  String chartCurrencyNote(String currency) {
    return 'Amounts in $currency only';
  }

  @override
  String get chartNeedsData => 'The chart shows once two months have records.';

  @override
  String get chartsTitle => 'Charts';

  @override
  String get checkAnswer => 'Check';

  @override
  String get checkFields => 'Check the fields';

  @override
  String get checkinScale =>
      '1 is the lowest, 5 the highest. Saved as you tap.';

  @override
  String checkinWeek(String energy, String recovery) {
    return 'This week: energy $energy, recovery $recovery on average';
  }

  @override
  String clashItem(String a, String b, String time) {
    return '“$a” and “$b” at $time';
  }

  @override
  String clashSave(String what) {
    return 'This time clashes with $what. Save anyway?';
  }

  @override
  String get clashSleep => 'your sleep time';

  @override
  String get clashesTitle => 'Clashes';

  @override
  String get clear => 'Clear';

  @override
  String get clearLog => 'Clear log';

  @override
  String get clearRead => 'Clear read notifications';

  @override
  String get clearanceConfirm => 'My doctor has said exercise is fine for me';

  @override
  String get clearancePostpartum =>
      'After giving birth — and especially after a caesarean or a difficult delivery — start only once your doctor says it\'s fine. The early-weeks program is gentle; the gradual return is for after your postnatal check.';

  @override
  String get clearancePregnancy =>
      'Exercise in pregnancy is usually safe and helpful, but some pregnancies need limits. Please confirm your doctor has said it\'s fine for you.';

  @override
  String get clearanceTitle => 'Your doctor\'s go-ahead first';

  @override
  String get cloudModeNotice =>
      'Your data is saved to your account and kept on this device for offline use.';

  @override
  String cmN(String v) {
    return '$v cm';
  }

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get commonSymptoms => 'Symptoms you log most';

  @override
  String get compareLastMonth => 'Compared with last month';

  @override
  String get completedAndArchived => 'Completed & archived';

  @override
  String get completedPerDay => 'Completed per day';

  @override
  String get completionRate => 'Completion rate';

  @override
  String completionRateDef(int done, int total) {
    return '$done of $total due in period (cancelled excluded)';
  }

  @override
  String get conCustom => 'Something of my own';

  @override
  String get conCustomHint => 'Your own harmless wording.';

  @override
  String get conExtraReview => 'An extra review session';

  @override
  String get conExtraReviewHint =>
      '20 minutes to look at what\'s blocking the task.';

  @override
  String get conFirstStep => 'First step before leisure';

  @override
  String get conFirstStepHint =>
      'Do a 15-minute first step before optional leisure time.';

  @override
  String get conPlanning => 'A short planning session';

  @override
  String get conPlanningHint =>
      '15 minutes to break the task into small steps.';

  @override
  String conTaskFirstStep(String task) {
    return 'First step: $task';
  }

  @override
  String conTaskPlanning(String task) {
    return 'Plan the steps: $task';
  }

  @override
  String conTaskReview(String task) {
    return 'Review what\'s blocking: $task';
  }

  @override
  String get confirmEmailSent =>
      'Account created. We sent a confirmation link to your email — open it, then sign in.';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get conflict => 'Conflict';

  @override
  String conflictKeep(String title) {
    return 'This time overlaps with “$title”. Keep it anyway?';
  }

  @override
  String conflictWith(String title) {
    return 'Overlaps with “$title”';
  }

  @override
  String get connect => 'Connect';

  @override
  String get connectInDevices => 'Connect in Devices and sources';

  @override
  String connectStepsBody(String store) {
    return 'Sanad reads your daily step total from $store. It only reads steps and never writes anything.';
  }

  @override
  String connectStepsTitle(String store) {
    return 'Count steps automatically from $store';
  }

  @override
  String connectedTo(String store) {
    return 'Connected to $store';
  }

  @override
  String get contactSupport => 'Contact support';

  @override
  String get continueAsGuest => 'Continue as a guest';

  @override
  String get continueLabel => 'Continue';

  @override
  String get couldNotFit => 'Couldn\'t fit';

  @override
  String get courseComplete => 'You\'ve completed the B2 course!';

  @override
  String get createAccount => 'Create account';

  @override
  String get createFirstPlan => 'Create my first plan';

  @override
  String get createMyPlan => 'Create my plan';

  @override
  String get currency => 'Currency';

  @override
  String get currencyChangeNote =>
      'Existing expenses keep their original currency.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get currentPlan => 'Current plan';

  @override
  String get currentSalary => 'Current salary';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get customRange => 'Custom dates';

  @override
  String cycleDayN(int n) {
    return 'Day $n of your cycle';
  }

  @override
  String get cycleDisclaimer =>
      'Estimates from what you recorded, not medical advice and not a way to prevent or plan pregnancy.';

  @override
  String get cycleInsights => 'Cycle insights';

  @override
  String get cycleLengthOverTime => 'Cycle length over time';

  @override
  String get cycleLocalOnly => 'Keep cycle data on this phone only';

  @override
  String get cycleLocalOnlyBody =>
      'Your periods and day logs are removed from your account and stay on this phone. If you delete the app or change phones, they are gone.';

  @override
  String get cycleLocalOnlyOff =>
      'Off: saved to your account, so it appears on your phone, iPhone and the web.';

  @override
  String get cycleLocalOnlyOn =>
      'On: it isn\'t saved to your account and doesn\'t appear on your other devices.';

  @override
  String get cycleLocalOnlyTitle => 'Keep it on this phone only?';

  @override
  String get cycleRange => 'Range';

  @override
  String get cycleReminders => 'Reminder before the next period';

  @override
  String get cycleRemindersSub =>
      'Two days before the estimated window. It only says “Sanad reminder”.';

  @override
  String get cycleStartBody =>
      'Tap “It started today” on the first day of your period, or add past ones below.';

  @override
  String get cycleStartTitle => 'Track your cycle';

  @override
  String get cycleSyncBody =>
      'What this phone holds is uploaded to your account and appears on your other devices.';

  @override
  String get cycleSyncTitle => 'Save it to your account?';

  @override
  String get cyclesCounted => 'Cycles counted';

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get dataAccess => 'What the assistant can read';

  @override
  String get dataAccessSub => 'Only enabled sections are used to answer you.';

  @override
  String get date => 'Date';

  @override
  String get day => 'Day';

  @override
  String get dayEnd => 'Day ends';

  @override
  String get dayFits => 'Tasks due fit in the free time.';

  @override
  String dayFreeLeft(String free) {
    return '$free free';
  }

  @override
  String get dayOfMonth => 'Day of the month';

  @override
  String dayOfMonthLabel(int day) {
    return 'Day $day of each month';
  }

  @override
  String get dayOverview => 'Your day in hours';

  @override
  String get daySchedule => 'Today\'s schedule';

  @override
  String get dayScheduleDone => 'Today\'s schedule is done';

  @override
  String get dayStart => 'Day starts';

  @override
  String daysCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String daysLoggedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days logged',
      one: '1 day logged',
      zero: 'No days logged',
    );
    return '$_temp0';
  }

  @override
  String daysN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String daysRange(int min, int max) {
    return '$min–$max days';
  }

  @override
  String get deadlineDate => 'Deadline';

  @override
  String get deadlineTime => 'Deadline time';

  @override
  String get deadlineVsPlanned =>
      'Deadline = when it must be done. Planned time = when you intend to work on it.';

  @override
  String get defaultCurrency => 'Default currency';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConsequences =>
      'This permanently deletes your account and everything in it from this device: tasks, events, goals, habits, notes, expenses and assistant chats. This can\'t be undone. Consider exporting your data first (Privacy & data).';

  @override
  String get deleteAccountConsequencesRemote =>
      'This requests permanent deletion of your account and everything in it: tasks, events, goals, habits, notes, expenses and assistant chats. You\'ll be signed out now and this device\'s copy will be removed; the server removes the rest per our retention policy. This can\'t be undone. Consider exporting your data first.';

  @override
  String get deleteAccountSub => 'Permanently remove your account and data';

  @override
  String get deleteAllChats => 'Delete all chats';

  @override
  String get deleteAllChatsBody =>
      'All conversations and pending suggestions will be deleted. Applied changes stay.';

  @override
  String get deleteAppointmentBody => 'Its notes and questions go too.';

  @override
  String get deleteAppointmentTitle => 'Delete this appointment?';

  @override
  String get deleteChatBody =>
      'This chat and its pending suggestions will be deleted. Changes you already applied stay.';

  @override
  String get deleteChatTitle => 'Delete chat?';

  @override
  String get deleteConfirmWord => 'DELETE';

  @override
  String get deleteDataRequest => 'Delete my data';

  @override
  String get deleteDataRequestSub => 'Done by deleting your account';

  @override
  String deleteEventBody(String title) {
    return '“$title” will be permanently deleted.';
  }

  @override
  String get deleteEventTitle => 'Delete event?';

  @override
  String get deleteExpenseBody => 'This expense will be deleted.';

  @override
  String get deleteExpenseTitle => 'Delete expense?';

  @override
  String get deleteFood => 'Delete this food?';

  @override
  String get deleteFoodBody => 'Meals already logged with it stay as they are.';

  @override
  String get deleteForever => 'Delete permanently';

  @override
  String get deleteGoalBody =>
      'The goal and its milestones will be deleted. Linked tasks are kept and unlinked.';

  @override
  String get deleteGoalTitle => 'Delete goal?';

  @override
  String get deleteHabitBody =>
      'The habit and its whole history will be deleted. You can make it inactive instead.';

  @override
  String get deleteHabitTitle => 'Delete habit?';

  @override
  String get deleteHealthData => 'Delete health data';

  @override
  String get deleteHealthDataBody =>
      'Steps, sleep, heart rate, workouts from your watch, food, water, cycle and appointments are removed from all your devices. This can\'t be undone.';

  @override
  String get deleteHealthDataSub =>
      'Only the health sections; the rest of your account stays';

  @override
  String get deleteHealthDataTitle => 'Delete all health data?';

  @override
  String get deleteIncomeBody => 'It will no longer count in your totals.';

  @override
  String get deleteIncomeTitle => 'Delete this income?';

  @override
  String get deleteMonthlyBody =>
      'Months already recorded stay in your records.';

  @override
  String get deleteMonthlyTitle => 'Remove this monthly item?';

  @override
  String get deleteNoteBody =>
      'This note will be permanently deleted. You can archive it instead.';

  @override
  String get deleteNoteTitle => 'Delete note?';

  @override
  String get deletePeriodBody =>
      'Estimates will be worked out again without it.';

  @override
  String get deletePeriodTitle => 'Delete this period?';

  @override
  String get deleteSalaryBody =>
      'The months it covered will use the salary before it.';

  @override
  String get deleteSalaryTitle => 'Delete this salary change?';

  @override
  String deleteTaskBody(String title) {
    return '“$title” will be permanently deleted. You can archive it instead.';
  }

  @override
  String get deleteTaskTitle => 'Delete task?';

  @override
  String get deleteWorkoutBody => 'Its logged sets will be removed.';

  @override
  String get deleteWorkoutTitle => 'Delete this workout?';

  @override
  String get deleted => 'Deleted';

  @override
  String get deletionRequested =>
      'Deletion requested. Your account and data will be removed from our servers.';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get details => 'Details';

  @override
  String get devNotifBody => 'Get reminders even when Sanad is closed.';

  @override
  String get devNotifBodyWeb =>
      'Show reminders as browser notifications while Sanad is open.';

  @override
  String get devNotifDenied =>
      'Notifications are blocked. To get reminders, allow them for Sanad in your device or browser settings.';

  @override
  String get devNotifEnable => 'Turn on';

  @override
  String get devNotifOn =>
      'On — reminders arrive even when Sanad is closed (sometimes a few minutes late).';

  @override
  String get devNotifOnWeb =>
      'On — browsers show reminders only while Sanad is open.';

  @override
  String get devNotifTitle => 'Phone notifications';

  @override
  String get devicesPrivacy =>
      'Sanad only reads, never writes, and only what you turn on. The numbers are saved to your account so your other devices see them.';

  @override
  String devicesStoreBody(String store) {
    return 'This phone reads from $store, which gathers what your watch, scale and apps record. Choose what to bring in.';
  }

  @override
  String get devicesSub =>
      'Watch, sleep, heart rate and where each number comes from';

  @override
  String get devicesTitle => 'Devices and sources';

  @override
  String get devicesWebBody =>
      'Connecting happens in the Sanad phone app: it reads from Health Connect on Android or Apple Health on iPhone. What it brings in shows here too.';

  @override
  String get diastolic => 'Lower (diastolic)';

  @override
  String get didYouEat => 'Is it one of these?';

  @override
  String get diffEasy => 'Easy';

  @override
  String get diffHard => 'Hard';

  @override
  String get diffMedium => 'Medium';

  @override
  String get discard => 'Discard';

  @override
  String get discardMessage =>
      'You have unsaved changes. Leave without saving?';

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get disconnectBody =>
      'This phone stops reading. What it already brought in stays; you can remove it under the source.';

  @override
  String get disconnectThisPhone => 'Stop reading on this phone';

  @override
  String disconnectTitle(String store) {
    return 'Stop reading from $store?';
  }

  @override
  String get dismiss => 'Dismiss';

  @override
  String get displayName => 'Display name';

  @override
  String get displayNameOptional => 'Your name (optional)';

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String get documents => 'Documents';

  @override
  String get done => 'Done';

  @override
  String get doneDays => 'Done / due';

  @override
  String get drEmergency => 'An emergency';

  @override
  String get drIllness => 'I was ill';

  @override
  String get drNotImportant => 'It\'s no longer important';

  @override
  String get drPostponed => 'I put it off on purpose';

  @override
  String get dragHint => 'Long-press and drag a task onto an hour to plan it.';

  @override
  String get due => 'Due';

  @override
  String dueNeeds(String need, String free) {
    return 'Tasks due need $need; only $free is free.';
  }

  @override
  String get dueShort => 'due';

  @override
  String get eachBarWeek => 'Each bar is a week';

  @override
  String get edit => 'Edit';

  @override
  String get editAppointment => 'Edit appointment';

  @override
  String get editEvent => 'Edit event';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get editFood => 'Edit food';

  @override
  String get editGoal => 'Goal';

  @override
  String get editHabit => 'Edit habit';

  @override
  String get editIncome => 'Edit income';

  @override
  String get editMilestone => 'Edit milestone';

  @override
  String get editPlan => 'Change plan';

  @override
  String get editTask => 'Edit task';

  @override
  String get effectiveFrom => 'Starts from';

  @override
  String effort(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '1': 'easy',
      '2': 'fairly easy',
      '3': 'moderate',
      '4': 'hard',
      'other': 'very hard',
    });
    return '$_temp0';
  }

  @override
  String get email => 'Email';

  @override
  String get emailNotVerified => 'Not verified yet';

  @override
  String get emailPassword => 'Email and password';

  @override
  String get emailVerification => 'Email verification';

  @override
  String get emailVerified => 'Verified';

  @override
  String get emptyAll => 'No tasks yet.';

  @override
  String get emptyArchived => 'Nothing archived.';

  @override
  String get emptyCompleted => 'No completed tasks yet.';

  @override
  String get emptyOverdue => 'Nothing overdue.';

  @override
  String get emptyToday => 'Nothing due today. Add a task or plan ahead.';

  @override
  String get emptyTodayDone => 'All of today\'s tasks are done. Nice work!';

  @override
  String get emptyUpcoming => 'No upcoming tasks with a deadline.';

  @override
  String get enableAssistant => 'Assistant';

  @override
  String get enableAssistantSub =>
      'Turning it off doesn\'t affect tasks, calendar or anything else.';

  @override
  String get endDateOptional => 'End date (optional)';

  @override
  String get endTime => 'Ends';

  @override
  String get energy => 'Energy';

  @override
  String energyN(int n) {
    return 'Energy $n/5';
  }

  @override
  String get energySplit => 'Where the energy came from (daily average)';

  @override
  String get englishIntroBody =>
      'A short placement test finds your level in vocabulary, grammar and reading, then you get a lesson a day and reviews of what you learned.';

  @override
  String get englishIntroTitle => 'English, step by step';

  @override
  String englishLessonItem(String title) {
    return 'English: $title';
  }

  @override
  String get eoAccepted => 'Consequence accepted';

  @override
  String get eoDropped => 'Task closed';

  @override
  String get eoPending => 'Waiting';

  @override
  String get eoRescheduled => 'Rescheduled';

  @override
  String get eqBands => 'Resistance bands';

  @override
  String get eqBench => 'Bench';

  @override
  String get eqDumbbells => 'Dumbbells';

  @override
  String get eqKettlebell => 'Kettlebell';

  @override
  String get eqPullupBar => 'Pull-up bar';

  @override
  String get errAgree => 'Please accept the terms and privacy policy';

  @override
  String get errCredentials => 'Email or password is incorrect';

  @override
  String get errCurrentPassword => 'Current password is incorrect';

  @override
  String get errEmail => 'Enter a valid email address';

  @override
  String get errEmailExists => 'An account with this email already exists';

  @override
  String get errEmailNotConfirmed =>
      'Please confirm your email first using the link we sent.';

  @override
  String get errEndBeforeStart => 'End time must be after the start time';

  @override
  String get errEndDateBeforeStart => 'The end date is before the start';

  @override
  String get errFutureIncome => 'Income can\'t be dated in the future';

  @override
  String get errNetwork => 'Connection problem. Please try again.';

  @override
  String get errPasswordMatch => 'Passwords don\'t match';

  @override
  String get errPasswordWeak =>
      'Password must be at least 8 characters and include a letter and a number';

  @override
  String get errPickDays => 'Pick at least one day';

  @override
  String get errPositiveAmount => 'Enter an amount greater than zero';

  @override
  String get errPositiveMinutes => 'Enter minutes between 1 and 1440';

  @override
  String errRange(int max) {
    return 'Between 0 and $max';
  }

  @override
  String get errRateLimited =>
      'Too many attempts. Please wait a little and try again.';

  @override
  String get errRequired => 'This field is required';

  @override
  String get errSave => 'Couldn\'t save. Check the fields and try again.';

  @override
  String get errSex => 'Choose male or female';

  @override
  String get errTargetBeforeStart => 'Target date must be after the start date';

  @override
  String get estimateNote => 'An estimate — portions and recipes vary.';

  @override
  String get estimatedDuration => 'Estimated 30 min';

  @override
  String get estimatedMinutes => 'Estimated duration (minutes)';

  @override
  String get estimatedPill => 'Estimated length';

  @override
  String estimatedWindow(String from, String to) {
    return 'Estimated window: $from – $to';
  }

  @override
  String get eventTitle => 'Event title';

  @override
  String get eventsLabel => 'Events';

  @override
  String get everyDay => 'Every day';

  @override
  String everyMinutes(int m) {
    return 'Every $m min';
  }

  @override
  String get examples => 'Examples';

  @override
  String get execute => 'Apply changes';

  @override
  String executedCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Done — $n changes applied',
      one: 'Done — 1 change applied',
    );
    return '$_temp0';
  }

  @override
  String exerciseCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String get expBills => 'Bills';

  @override
  String get expEducation => 'Education';

  @override
  String get expEntertainment => 'Entertainment';

  @override
  String get expFood => 'Food';

  @override
  String get expOther => 'Other';

  @override
  String get expShopping => 'Shopping';

  @override
  String get expTransport => 'Transport';

  @override
  String get expectedLabel => 'Expected';

  @override
  String get expenseList => 'Expenses';

  @override
  String get expensesManualNote =>
      'Expenses are entered manually. No bank accounts are linked.';

  @override
  String get explanation => 'Explanation';

  @override
  String exportCopied(int chars) {
    return 'Copied ($chars characters)';
  }

  @override
  String get exportData => 'Export my data';

  @override
  String get exportDataSub => 'Copies all your data as JSON to the clipboard';

  @override
  String get exportHealthData => 'Export health data';

  @override
  String get exportHealthDataSub =>
      'Steps, sleep, food, cycle and appointments, copied as JSON';

  @override
  String get extraLesson => 'Extra lesson';

  @override
  String get faq => 'Frequently asked questions';

  @override
  String get faq1a =>
      'The deadline is when a task must be finished. Planned time is when you intend to work on it — the planner sets it, and you can change it.';

  @override
  String get faq1q =>
      'What\'s the difference between a deadline and planned time?';

  @override
  String get faq2a =>
      'Each goal uses one method: completed milestones ÷ all milestones, or a percentage you set manually. A goal is never marked complete just because its date passed.';

  @override
  String get faq2q => 'How is goal progress calculated?';

  @override
  String get faq3a =>
      'Only what you allow in assistant settings — e.g. creating a single task. Deleting, bulk changes and rescheduling many items always need your approval.';

  @override
  String get faq3q => 'What can the assistant do on its own?';

  @override
  String get faq4a =>
      'Turn on phone notifications from the Notifications screen or Settings, and give the task a reminder plus a deadline or planned time. On phones, reminders arrive even when the app is closed (sometimes a few minutes late); in a browser they only appear while Sanad is open.';

  @override
  String get faq4q => 'I\'m not getting reminders';

  @override
  String get faq5a =>
      'In local mode, on this device only. You can export it any time from Privacy & data.';

  @override
  String get faq5aRemote =>
      'In your account on our servers, protected so only you can read it, with a copy on this device for offline use. You can export it any time from Privacy & data.';

  @override
  String get faq5q => 'Where is my data stored?';

  @override
  String get fat => 'Fat';

  @override
  String get fatG => 'Fat (g)';

  @override
  String get fatigue => 'Fatigue';

  @override
  String get featAdvancedReports => 'Detailed reports and insights';

  @override
  String featAssistantLimited(int limit) {
    return 'Assistant: up to $limit requests a day';
  }

  @override
  String get featBasicReports => 'Basic weekly reports';

  @override
  String get featCore => 'Tasks, calendar, goals, habits, notes and expenses';

  @override
  String get featMoreAssistant => 'More assistant usage';

  @override
  String get featSmartPlanning => 'Advanced smart planning';

  @override
  String get featTemplates => 'Goal templates';

  @override
  String feltLike(String effort) {
    return 'felt $effort';
  }

  @override
  String get fgDairy => 'Dairy';

  @override
  String get fgDishes => 'Dishes';

  @override
  String get fgDrinks => 'Drinks';

  @override
  String get fgExtras => 'Extras';

  @override
  String get fgFatLoss => 'Lose fat';

  @override
  String get fgFatLossHint =>
      'Strength work plus cardio. Food matters most; the app gives no diet advice.';

  @override
  String get fgFruit => 'Fruit';

  @override
  String get fgGeneral => 'General fitness';

  @override
  String get fgGeneralHint => 'Balanced strength, cardio and movement.';

  @override
  String get fgGrains => 'Bread and grains';

  @override
  String get fgMobility => 'Mobility and moving better';

  @override
  String get fgMobilityHint =>
      'Gentle sessions for flexibility, posture and recovery.';

  @override
  String get fgMuscle => 'Build muscle';

  @override
  String get fgMuscleHint =>
      'Moderate reps and enough weekly volume for each muscle.';

  @override
  String get fgProtein => 'Meat, fish and eggs';

  @override
  String get fgSnacks => 'Snacks and sweets';

  @override
  String get fgStrength => 'Get stronger';

  @override
  String get fgStrengthHint =>
      'Fewer reps, longer rest, steady progress on key lifts.';

  @override
  String get fgVegetables => 'Vegetables';

  @override
  String get filterAll => 'All';

  @override
  String get filterArchived => 'Archived';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterToday => 'Today';

  @override
  String get filterUpcoming => 'Upcoming';

  @override
  String get filteredTotal => 'Total';

  @override
  String get finishSetup => 'Finish setup';

  @override
  String get finishWorkout => 'Finish workout';

  @override
  String get fitnessIntroBody =>
      'Answer a few questions and get a plan for home, the gym, or both — with alternatives when equipment is missing.';

  @override
  String get fitnessIntroTitle => 'Training that fits your week';

  @override
  String get fitnessSafety =>
      'Sanad gives general exercise guidance, not medical advice. If you have an injury or health condition, check with a professional first, and stop if something hurts.';

  @override
  String get fitnessSetupTitle => 'Your training plan';

  @override
  String get fixedBlocks => 'Fixed blocks';

  @override
  String get fixedCommitments => 'Fixed commitments';

  @override
  String get flAdvanced => 'Advanced';

  @override
  String get flBeginner => 'Beginner';

  @override
  String get flIntermediate => 'Intermediate';

  @override
  String get flow => 'Flow';

  @override
  String get flowHeavy => 'Heavy';

  @override
  String get flowLight => 'Light';

  @override
  String get flowMedium => 'Medium';

  @override
  String get flowNone => 'None';

  @override
  String get focusConditioning => 'Conditioning';

  @override
  String get focusFullBody => 'Full body';

  @override
  String get focusLower => 'Lower body';

  @override
  String get focusMobility => 'Mobility and recovery';

  @override
  String get focusUpper => 'Upper body';

  @override
  String foodAdded(String name) {
    return 'Added $name';
  }

  @override
  String get foodAndWater => 'Food and water';

  @override
  String get foodName => 'Name';

  @override
  String get foodNoneYet => 'Nothing logged today';

  @override
  String get foodRemoved => 'Removed';

  @override
  String get foodSaved => 'Saved to your foods';

  @override
  String get forgotLocalMode =>
      'In this version, accounts are stored on this device only, so password reset by email isn\'t available yet. It will be enabled once the cloud account service is connected.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotRemoteBody =>
      'Enter your email and we\'ll send you a link to set a new password.';

  @override
  String get forgotTitle => 'Recover access';

  @override
  String get freeSlotsTitle => 'Free times';

  @override
  String get freeTime => 'Free time';

  @override
  String get freeTimeNow => 'Free time';

  @override
  String get from => 'From';

  @override
  String get fromGallery => 'From gallery';

  @override
  String get fromYourDevices => 'From your watch and apps';

  @override
  String get fsDays => 'Days per week';

  @override
  String get fsEquipment => 'Equipment at home';

  @override
  String get fsEquipmentHint => 'Leave empty for body-weight only.';

  @override
  String get fsGoal => 'What\'s your main goal?';

  @override
  String get fsLevel => 'Your experience';

  @override
  String get fsMinutes => 'Minutes per session';

  @override
  String fsPickDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Pick $n more days',
      one: 'Pick 1 more day',
    );
    return '$_temp0';
  }

  @override
  String get fsPlaces => 'Where will you train?';

  @override
  String get fsPlacesHint =>
      'Choose both to get two plans and switch between them any day.';

  @override
  String fsWhichDays(int n) {
    return 'Pick $n days';
  }

  @override
  String get futureDay => 'Not yet';

  @override
  String get futureDayBody => 'Days can be logged once they come.';

  @override
  String get getStarted => 'Get started';

  @override
  String get goBackOver => 'Go back over these lessons:';

  @override
  String get goalActive => 'Active';

  @override
  String get goalArchived => 'Archived';

  @override
  String get goalCompleted => 'Completed';

  @override
  String get goalDays => 'Goal reached';

  @override
  String get goalPaused => 'Paused';

  @override
  String get goalStepHint =>
      'Choose an example or write your own. You can skip this.';

  @override
  String get goalStreak => 'Streak';

  @override
  String get goalTitle => 'Goal title';

  @override
  String get goalTitleHint => 'e.g. Learn Flutter basics';

  @override
  String get goalsEmptyBody =>
      'A goal can have milestones and linked tasks. Progress follows what you complete.';

  @override
  String get goalsProgress => 'Goals';

  @override
  String get goalsSummary => 'Goals';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get goodMorning => 'Good morning';

  @override
  String gramsN(String g) {
    return '$g g';
  }

  @override
  String get gramsOptional => 'Grams (optional)';

  @override
  String get guestAvailable => 'Open to guests';

  @override
  String get guestBanner =>
      'You\'re using Sanad as a guest. Create an account to keep your data safe and open every section.';

  @override
  String get guestNote =>
      'Tasks, calendar and habits, on this phone only. Create an account any time and they come with you.';

  @override
  String get habitAdherence => 'Habit check-ins';

  @override
  String habitAdherenceDef(int done, int total) {
    return '$done of $total due days (non-due days excluded)';
  }

  @override
  String get habitDone => 'Done';

  @override
  String get habitDoneToday => 'Done today';

  @override
  String get habitDueToday => 'Due today';

  @override
  String get habitName => 'Habit name';

  @override
  String get habitNotDueToday => 'Not due today';

  @override
  String habitsDoneOf(int done, int total) {
    return '$done of $total logged today';
  }

  @override
  String get habitsEmptyBody =>
      'Add a habit and choose which days it\'s expected. Days it isn\'t due never count against you.';

  @override
  String get hanafiAsr => 'Hanafi Asr';

  @override
  String get hanafiAsrHint =>
      'Later Asr time (shadow twice an object\'s length).';

  @override
  String get hasBreak => 'Add a daily break';

  @override
  String get hasWorkHours => 'I have fixed work or study hours';

  @override
  String get haveAccount => 'I have an account';

  @override
  String get healthDataDeleted => 'Health data deleted';

  @override
  String get healthDataTitle => 'Your health data';

  @override
  String get healthLearn => 'Health reading';

  @override
  String get healthLearnSub => 'Short articles from public health sources';

  @override
  String get healthLock => 'Lock with fingerprint or passcode';

  @override
  String get healthLockSub =>
      'Health sections open only after your phone\'s unlock. Locks again when you leave the app.';

  @override
  String get healthLockUnavailable =>
      'Not available here: set up a screen lock on your phone first. On the web your account password protects it.';

  @override
  String get healthLocked => 'Locked';

  @override
  String get healthLockedBody =>
      'Unlock with your fingerprint, face or phone passcode.';

  @override
  String get healthPermissionDenied =>
      'Permission wasn\'t given. You can allow it from the health app\'s settings.';

  @override
  String get healthPrivacy => 'Health privacy';

  @override
  String get healthPrivacyNote =>
      'Cycle data is never shared with the assistant, and its reminders never say what they\'re about. Women\'s health shows only on accounts registered as female.';

  @override
  String get healthPrivacySub =>
      'Lock, home screen, reminders, export and delete';

  @override
  String get healthSections => 'Health sections';

  @override
  String get healthSectionsNote =>
      'Sections marked “coming soon” are saved now and appear when they\'re ready.';

  @override
  String get healthSetup => 'Health setup';

  @override
  String get healthSharing => 'Health';

  @override
  String get healthSharingSub =>
      'Summaries only. Measurements and the cycle are off until you turn them on.';

  @override
  String get healthThisPeriod => 'Health';

  @override
  String heartDaysN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'heart rate on $n days',
      one: 'heart rate on 1 day',
    );
    return '$_temp0';
  }

  @override
  String get heartNote =>
      'Your watch\'s reading, for your own record. It isn\'t a medical test.';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get heightForDistance => 'Height';

  @override
  String get heightHelp => 'Optional — makes the distance estimate closer';

  @override
  String get heightInvalid => 'Between 80 and 250 cm';

  @override
  String get helpTitle => 'Help & support';

  @override
  String get hideFromHome => 'Hide from the home screen';

  @override
  String get hideFromHomeSub => 'Women\'s health won\'t appear on “My day”.';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get highlights => 'Highlights';

  @override
  String get history => 'History';

  @override
  String get historyHint =>
      'Tap a past day to correct it. Days the habit isn\'t due are neutral.';

  @override
  String get hkBody => 'Weight and blood pressure';

  @override
  String get hkBodySub =>
      'Readings from a smart scale or blood pressure monitor';

  @override
  String get hkHeartRate => 'Resting heart rate';

  @override
  String get hkHeartRateSub => 'One value a day, as your watch measures it';

  @override
  String get hkSleep => 'Sleep';

  @override
  String get hkSleepSub => 'When you slept and for how long';

  @override
  String get hkSteps => 'Steps';

  @override
  String get hkStepsSub => 'Daily total, from the phone and any watch';

  @override
  String get hkWorkouts => 'Workouts';

  @override
  String get hkWorkoutsSub =>
      'Runs, walks, swims and other sessions your watch recorded';

  @override
  String get hmActivity => 'Steps and activity';

  @override
  String get hmMens => 'Men\'s health';

  @override
  String get hmNutrition => 'Food and calories';

  @override
  String get hmSleep => 'Sleep and recovery';

  @override
  String get hmWomens => 'Women\'s health';

  @override
  String get homeInstead => 'At home instead';

  @override
  String get homeSections => 'Home screen';

  @override
  String get homeVersionBody =>
      'Exercises are swapped for ones you can do with your home equipment. Not every exercise has an exact match.';

  @override
  String get homeVersionTitle => 'Today\'s gym workout, at home';

  @override
  String get homeViewGoals => 'Goals';

  @override
  String get homeViewToday => 'Today';

  @override
  String get homeViewWeek => 'Week';

  @override
  String get howDidItFeel => 'How did it feel? (optional)';

  @override
  String get howIsToday => 'How\'s today?';

  @override
  String get howIsTodaySub => 'Flow, pain, symptoms, mood, energy';

  @override
  String get howMuch => 'How much?';

  @override
  String get howRested => 'How do you feel today?';

  @override
  String get howTo => 'How to do it';

  @override
  String inDuration(String duration) {
    return 'in $duration';
  }

  @override
  String get inactiveHabits => 'Inactive';

  @override
  String get includeTechInfo => 'Include technical info';

  @override
  String get incomeFixed => 'Fixed salary';

  @override
  String get incomeKindExtra => 'Extra';

  @override
  String get incomeKindPay => 'Pay';

  @override
  String get incomeSource => 'Source';

  @override
  String get incomeSourceHint => 'For example: freelance, rent';

  @override
  String get incomeType => 'Income type';

  @override
  String get incomeVariable => 'Variable';

  @override
  String get incomeVariableSub => 'Record each amount when you receive it.';

  @override
  String get initialTasks => 'First tasks';

  @override
  String get install => 'Install';

  @override
  String get installHealthConnect => 'Install Health Connect';

  @override
  String get installHealthConnectBody =>
      'Android keeps steps from your phone and watch in Health Connect. Install or update it, then come back and connect.';

  @override
  String get interestsHint =>
      'Pick any — you can change this later. Sections you don\'t pick are hidden, not deleted.';

  @override
  String get irregularNote =>
      'Your recorded cycles vary a lot, or some are unusually short or long. This alone doesn\'t mean anything is wrong, but it\'s worth mentioning to a doctor.';

  @override
  String get itemGone => 'This item no longer exists.';

  @override
  String get kcalGoalOn => 'Daily calorie target';

  @override
  String get kcalGoalSub =>
      'Optional. Set your own number; the app doesn\'t suggest one.';

  @override
  String kcalN(String kcal) {
    return '$kcal kcal';
  }

  @override
  String kcalOfGoal(String kcal, String goal) {
    return '$kcal / $goal kcal';
  }

  @override
  String get keepAnyway => 'Keep anyway';

  @override
  String get keepChats => 'Keep chats for';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String kgN(String v) {
    return '$v kg';
  }

  @override
  String kgTimesReps(String kg, int reps) {
    return '$kg kg × $reps';
  }

  @override
  String get kindAssistant => 'Assistant';

  @override
  String get kindBug => 'Bug';

  @override
  String get kindNotifications => 'Notifications';

  @override
  String get kindOther => 'Other';

  @override
  String get language => 'Language';

  @override
  String get lastLabel => 'Last';

  @override
  String get lastSevenDays => 'Last 7 days';

  @override
  String lastSyncAt(String time) {
    return 'Last synced $time';
  }

  @override
  String get lastTwoWeeks => 'Last two weeks';

  @override
  String get lastWeek => 'Last week';

  @override
  String latestOn(String date) {
    return 'Latest: $date';
  }

  @override
  String get learnIntro =>
      'Short, general reading from public health organisations. It isn\'t advice for you personally; a doctor can tell you what applies to you.';

  @override
  String get leave => 'Leave';

  @override
  String get leaveGuest => 'Leave guest mode';

  @override
  String get leaveTestBody => 'Your answers so far will be lost.';

  @override
  String get leaveTestTitle => 'Leave the test?';

  @override
  String get leaveUnsavedBody =>
      'What you\'ve typed on this page will be lost.';

  @override
  String get leaveUnsavedTitle => 'Leave without saving?';

  @override
  String get leaveWithoutSaving => 'Leave without saving';

  @override
  String get legendEstimated => 'Estimated';

  @override
  String get legendLogged => 'Day logged';

  @override
  String get legendPeriod => 'Period';

  @override
  String get less => 'Less';

  @override
  String get lessonAgain =>
      'Not mastered yet (80% needed). We\'ll repeat this lesson before moving on.';

  @override
  String get lessonDoneToday => 'Today\'s English lesson is done';

  @override
  String get lessonMastered => 'Lesson mastered. On to the next!';

  @override
  String lessonMinutes(int n) {
    return 'About $n minutes';
  }

  @override
  String get levelCheckBody =>
      'You\'ve mastered every lesson at this level. Take the level check to move up.';

  @override
  String get levelCheckIntro =>
      'Questions from this level. You need 75% to move up; otherwise we\'ll point you to lessons to revisit.';

  @override
  String get levelCheckReady => 'Level check ready';

  @override
  String levelCheckTitle(String level) {
    return 'Level check: $level';
  }

  @override
  String levelComplete(String level) {
    return '$level lessons complete';
  }

  @override
  String levelLessons(String level) {
    return 'Lessons: $level';
  }

  @override
  String levelNotYet(String level) {
    return 'Not yet: $level';
  }

  @override
  String levelPassed(String level) {
    return 'Passed: $level';
  }

  @override
  String levelUp(String level) {
    return 'Moving up to $level!';
  }

  @override
  String get limit => 'Limit';

  @override
  String get linkTask => 'Add task';

  @override
  String get linkedGoal => 'Goal';

  @override
  String get linkedGoalOptional => 'Linked goal (optional)';

  @override
  String get linkedMilestoneOptional => 'Milestone (optional)';

  @override
  String get linkedTasks => 'Linked tasks';

  @override
  String get localModeNotice =>
      'Local mode: your account and data are stored on this device.';

  @override
  String get locationDenied =>
      'Location permission was denied. You can pick a city instead.';

  @override
  String get locationError =>
      'Couldn\'t get your location. Try again or pick a city.';

  @override
  String get locationOff => 'Location services are off on this device.';

  @override
  String get locationOptional => 'Location (optional)';

  @override
  String get locationPrivacy =>
      'Your location is used on this device to calculate times and saved only as coordinates in your settings.';

  @override
  String get lockedBody =>
      'As a guest you can use tasks, the calendar and habits. A free account opens everything else: prayer, health, money, learning and the assistant, synced on all your devices. What you\'ve added so far comes with you.';

  @override
  String get lockedTitle => 'This section needs an account';

  @override
  String get logoHome => 'Sanad: go to My day';

  @override
  String get lookUp => 'Look up';

  @override
  String get lookupNetwork =>
      'Couldn\'t reach the product database. Check the connection and try again.';

  @override
  String macroLine(String kcal, String p, String c, String f) {
    return '$kcal kcal · P $p · C $c · F $f';
  }

  @override
  String get manageAssistantAccess => 'Manage assistant permissions';

  @override
  String get manageDevices => 'Devices and sources';

  @override
  String get manual => 'Manually';

  @override
  String get manualHint => 'You set the percentage yourself.';

  @override
  String get manualStepsNote =>
      'If the phone app is connected, its number is used for that day.';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String markDone(String title) {
    return 'Mark “$title” done';
  }

  @override
  String get markGoalComplete => 'Mark as completed';

  @override
  String get markRead => 'Mark as read';

  @override
  String masteredScore(int n) {
    return 'Mastered · best $n%';
  }

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealPhoto => 'Meal photo';

  @override
  String get mealSnack => 'Snacks';

  @override
  String measurementsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n measurements',
      one: '1 measurement',
    );
    return '$_temp0';
  }

  @override
  String get memberSince => 'Member since';

  @override
  String get menu => 'Menu';

  @override
  String get methodEgyptian => 'Egyptian General Authority';

  @override
  String get methodGulf => 'Gulf region';

  @override
  String get methodIsna => 'ISNA (North America)';

  @override
  String get methodKarachi => 'University of Islamic Sciences, Karachi';

  @override
  String get methodKuwait => 'Kuwait';

  @override
  String get methodMwl => 'Muslim World League';

  @override
  String get methodQatar => 'Qatar';

  @override
  String get methodUmmAlQura => 'Umm al-Qura (Makkah)';

  @override
  String get metricHabits => 'Habits kept';

  @override
  String get metricIncome => 'Income';

  @override
  String get metricLessons => 'Learning sessions';

  @override
  String metricOutOfRange(int min, int max) {
    return 'Enter a number between $min and $max';
  }

  @override
  String get metricSpending => 'Spending';

  @override
  String get metricSteps => 'Steps';

  @override
  String get metricTasks => 'Tasks done';

  @override
  String get metricWorkouts => 'Workouts';

  @override
  String get milestone => 'Milestone';

  @override
  String get milestoneHint => 'e.g. Understand Dart basics';

  @override
  String get milestones => 'Milestones';

  @override
  String milestonesDone(int done, int total) {
    return '$done/$total milestones';
  }

  @override
  String get mkBloodPressure => 'Blood pressure';

  @override
  String get mkBodyFat => 'Body fat';

  @override
  String get mkBodyFatPct => 'Body fat (%)';

  @override
  String get mkHeartBpm => 'Resting heart rate (bpm)';

  @override
  String get mkWaist => 'Waist';

  @override
  String get mkWaistCm => 'Waist (cm)';

  @override
  String get mkWeight => 'Weight';

  @override
  String get mkWeightKg => 'Weight (kg)';

  @override
  String mmHgN(int sys, int dia) {
    return '$sys/$dia mmHg';
  }

  @override
  String get modExpenses => 'Expenses';

  @override
  String get modHabits => 'Habits';

  @override
  String get modLearning => 'Learning';

  @override
  String get modNotes => 'Notes';

  @override
  String get modTime => 'Time management';

  @override
  String get modelSaw => 'What the phone saw (tap to search):';

  @override
  String get moneyTabExpenses => 'Expenses';

  @override
  String get moneyTabIncome => 'Income';

  @override
  String get moneyTabSummary => 'Summary';

  @override
  String get month => 'Month';

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String get monthlyEditNote =>
      'Changes apply to the months to come. Months already recorded stay as they are.';

  @override
  String get monthlyExpenses => 'Monthly expenses';

  @override
  String get monthlyIncome => 'Monthly income';

  @override
  String get monthlyLabel => 'Monthly';

  @override
  String get mood => 'Mood';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodIrritable => 'Irritable';

  @override
  String get moodLow => 'Low';

  @override
  String get more => 'More';

  @override
  String get moreFilters => 'More filters';

  @override
  String get moreOptions => 'More options';

  @override
  String get mostLogged => 'Most logged';

  @override
  String get moveReminders => 'Move reminders';

  @override
  String get moveRemindersOn => 'Remind me to move';

  @override
  String get moveRemindersSub => 'Stops for the day once you reach your goal';

  @override
  String get moveTomorrow => 'Move to tomorrow';

  @override
  String movedTo(String time) {
    return 'Moved to $time';
  }

  @override
  String get movedTomorrow => 'Moved to tomorrow';

  @override
  String get muArms => 'Arms';

  @override
  String get muBack => 'Back';

  @override
  String get muBalance => 'Balance';

  @override
  String get muCardio => 'Cardio';

  @override
  String get muChest => 'Chest';

  @override
  String get muCore => 'Core';

  @override
  String get muFullBody => 'Full body';

  @override
  String get muGlutes => 'Glutes';

  @override
  String get muLegs => 'Legs';

  @override
  String get muMobility => 'Mobility';

  @override
  String get muPelvicFloor => 'Pelvic floor';

  @override
  String get muShoulders => 'Shoulders';

  @override
  String get multiCurrencyNote =>
      'Each currency is totalled separately — amounts are never combined across currencies.';

  @override
  String get myFoods => 'My foods';

  @override
  String get myGoals => 'My goals';

  @override
  String get myLocation => 'My location';

  @override
  String get myNotes => 'My notes';

  @override
  String nOfM(int n, int m) {
    return '$n of $m';
  }

  @override
  String get navAccountability => 'Commitments';

  @override
  String get navActivity => 'Steps';

  @override
  String get navAssistant => 'Assistant';

  @override
  String get navEnglish => 'English';

  @override
  String get navExpenses => 'Money';

  @override
  String get navFitness => 'Fitness';

  @override
  String get navGoals => 'Goals';

  @override
  String get navHabits => 'Habits';

  @override
  String get navHome => 'Home';

  @override
  String get navNotes => 'Notes';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navNutrition => 'Food';

  @override
  String get navPrayer => 'Prayer';

  @override
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navTime => 'My time';

  @override
  String get navWomens => 'Women\'s health';

  @override
  String get needMoreData =>
      'Two recorded periods are needed to estimate the next one. You can also set your usual cycle length.';

  @override
  String get neededTime => 'Tasks need';

  @override
  String needsReviewScore(int n) {
    return 'Needs another go · best $n%';
  }

  @override
  String get neverAddedUp =>
      'When two sources have the same day, one is shown, never both added up — a phone and a watch often count the same walk.';

  @override
  String get newChat => 'New chat';

  @override
  String get newEvent => 'New event';

  @override
  String get newGoal => 'New goal';

  @override
  String get newPassword => 'New password';

  @override
  String get newTask => 'New task';

  @override
  String get newUserBody =>
      'Start with one task and one goal. Then ask the assistant to plan your day.';

  @override
  String get newUserTitle => 'Welcome to Sanad 👋';

  @override
  String get newWords => 'New words';

  @override
  String get next => 'Next';

  @override
  String get nextDay => 'Next day';

  @override
  String get nextPeriod => 'Next';

  @override
  String nextPeriodIn(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Next period in about $n days',
      one: 'Next period in about a day',
    );
    return '$_temp0';
  }

  @override
  String nextPrayerIs(String name) {
    return 'Next: $name';
  }

  @override
  String get nextUp => 'Next';

  @override
  String get noActions => 'No actions yet.';

  @override
  String get noActiveGoals => 'No active goals right now.';

  @override
  String get noAppointments => 'No appointments';

  @override
  String get noAppointmentsBody =>
      'Add checkups and tests, with what you want to ask.';

  @override
  String get noConversations => 'No previous chats.';

  @override
  String get noExpensesPeriod => 'No expenses in this period';

  @override
  String get noFoodFound => 'No match';

  @override
  String get noFoodFoundBody =>
      'Add it once as your own food and it\'s kept for next time.';

  @override
  String get noFreeSlots => 'No free time left on this day.';

  @override
  String get noGoalsYet => 'No goals yet';

  @override
  String get noHabitsDueToday => 'No habits are due today.';

  @override
  String get noHabitsYet => 'No habits yet';

  @override
  String get noHeartYet => 'No resting heart rate yet';

  @override
  String noHomeAlternative(String name) {
    return '$name: no home alternative, skipped today';
  }

  @override
  String get noIncomeMonth => 'No income recorded this month';

  @override
  String get noLinkedTasks => 'No tasks linked to this goal yet.';

  @override
  String get noMeasurementYet => 'Nothing yet — tap to add';

  @override
  String get noMilestones => 'No milestones yet.';

  @override
  String get noMoneyYet => 'Nothing recorded this month';

  @override
  String get noMoneyYetBody =>
      'Add your salary or income and your expenses to see what\'s left.';

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noPeriodsYet => 'None recorded yet.';

  @override
  String get noPreviousPeriod =>
      'Nothing recorded in the previous period to compare.';

  @override
  String get noProgressYet => 'No logged sets yet';

  @override
  String get noProgressYetBody =>
      'Finish a workout or a program and your progress shows here.';

  @override
  String get noRecordsPeriod => 'Nothing recorded';

  @override
  String get noReminder => 'No reminder';

  @override
  String get noReviewsDue => 'Nothing to review right now.';

  @override
  String get noSalaryYet => 'No salary recorded yet';

  @override
  String get noSearchResults => 'No results';

  @override
  String get noSetsBody => 'Nothing will be saved. Leave the workout?';

  @override
  String get noSetsTitle => 'No sets ticked';

  @override
  String get noSleepYet => 'No sleep recorded';

  @override
  String get noSleepYetBody =>
      'Add a night by hand, or read sleep from your phone\'s health app in Devices and sources.';

  @override
  String get noSourcesYet =>
      'Nothing yet. Connect from the Sanad phone app, or add steps by hand.';

  @override
  String get noSymptomsYet => 'No symptoms logged yet.';

  @override
  String get noTasksToday => 'No tasks for today.';

  @override
  String get noUnread => 'You\'re all caught up';

  @override
  String get noUpcoming => 'No upcoming events.';

  @override
  String get noWorkoutThatDay => 'No workout is planned for that day.';

  @override
  String get none => 'None';

  @override
  String get notDue => 'Not due';

  @override
  String get notEnoughForChart => 'Not enough records yet to draw a trend.';

  @override
  String get notEnoughToCompare => 'Not enough records last month to compare.';

  @override
  String get notLogged => 'Not logged';

  @override
  String get notSet => 'Not set';

  @override
  String get notStarted => 'Not started';

  @override
  String get notSyncedYet => 'Not synced yet';

  @override
  String get noteBody => 'Write your note…';

  @override
  String get noteTitle => 'Title';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get nothingLogged => 'Nothing yet';

  @override
  String get nothingScheduled => 'Nothing scheduled';

  @override
  String get nothingScheduledNow => 'Nothing scheduled today';

  @override
  String get nothingThisWeek => 'Nothing logged this week';

  @override
  String get nothingToPlan => 'No open tasks to plan for this day.';

  @override
  String notifAccountability(String task) {
    return '\"$task\" is late';
  }

  @override
  String get notifAccountabilityBody =>
      'No blame — tell us what happened and pick what\'s next.';

  @override
  String get notifAppointmentTitle => 'Health appointment';

  @override
  String get notifBedtimeBody => 'Screens down, lights low';

  @override
  String get notifBedtimeTitle => 'Time to wind down';

  @override
  String get notifDue => 'Check its deadline in your tasks.';

  @override
  String notifEventBody(int minutes) {
    return 'Starts in $minutes min';
  }

  @override
  String notifEventTitle(String title) {
    return 'Upcoming: $title';
  }

  @override
  String get notifEventsSub => 'Before each appointment, as set on it';

  @override
  String get notifFitnessSub => 'On workout days, until you log it';

  @override
  String notifGoalSoon(String goal, int days) {
    return '“$goal” is due in $days days';
  }

  @override
  String notifGoalToday(String goal) {
    return 'Today is the date you set for “$goal”';
  }

  @override
  String get notifGoalsSub => 'Three days before a goal\'s date and on the day';

  @override
  String notifHabitTitle(String name) {
    return 'Habit reminder: $name';
  }

  @override
  String get notifHabitsSub => 'At each habit\'s reminder time';

  @override
  String get notifLearningSub => 'Until you study that day';

  @override
  String get notifLessonTitle => 'Today\'s lesson';

  @override
  String notifMoneyDue(String title) {
    return 'Due today: $title';
  }

  @override
  String get notifMoneySub => 'On the day a monthly expense or income is due';

  @override
  String get notifMoveBody => 'A short walk or a few minutes of stretching.';

  @override
  String get notifMoveTitle => 'Time to move';

  @override
  String get notifNeutralBody => 'Open the app to see it';

  @override
  String get notifNeutralTitle => 'Sanad reminder';

  @override
  String get notifOtherSections =>
      'Prayer, movement, bedtime and health reminders are set in their own sections.';

  @override
  String notifPrayerSoon(String name, int minutes) {
    return '$name prayer in $minutes min';
  }

  @override
  String notifPrayerTitle(String name) {
    return 'Time for $name prayer';
  }

  @override
  String get notifSectionEvents => 'Appointments';

  @override
  String get notifSectionFitness => 'Workouts';

  @override
  String get notifSectionGoals => 'Goals';

  @override
  String get notifSectionHabits => 'Habits';

  @override
  String get notifSectionLearning => 'Language learning';

  @override
  String get notifSectionMoney => 'Money';

  @override
  String get notifSectionTasks => 'Tasks';

  @override
  String get notifSectionWater => 'Water';

  @override
  String get notifSettingsSub =>
      'Turn each section on or off, and pick when its daily reminder comes.';

  @override
  String get notifSettingsTitle => 'What notifies you';

  @override
  String notifTaskTitle(String title) {
    return 'Reminder: $title';
  }

  @override
  String get notifTasksSub => 'At each task\'s own reminder time';

  @override
  String get notifTime => 'Time';

  @override
  String get notifWaterBody => 'Have a glass and log it.';

  @override
  String get notifWaterSub => 'Once a day, until you reach your goal';

  @override
  String get notifWaterTitle => 'Time for some water';

  @override
  String notifWorkoutBody(int minutes, String place) {
    return '$minutes minutes · $place';
  }

  @override
  String get notifWorkoutTitle => 'Today\'s workout is waiting';

  @override
  String get nowLabel => 'Now';

  @override
  String nowUntil(String time) {
    return 'Until $time';
  }

  @override
  String get nutritionNote =>
      'Numbers are estimates to help you notice patterns, not medical or diet advice.';

  @override
  String get obStep1 => 'Language and region';

  @override
  String get obStep2 => 'What would you like to organize?';

  @override
  String get obStep3 => 'A first goal (optional)';

  @override
  String get obStep4 => 'Your day';

  @override
  String get obsFew =>
      'Fewer than half of the tasks due were completed. Planning fewer tasks per day may help.';

  @override
  String get obsHalf =>
      'You completed about half of the tasks due in this period.';

  @override
  String get obsMost =>
      'You completed most of the tasks you set for this period.';

  @override
  String obsNoDeadlines(int n) {
    return 'You completed $n tasks. None had a deadline in this period, so there\'s no completion rate.';
  }

  @override
  String get observations => 'Observations';

  @override
  String ofStepGoal(String goal) {
    return 'of $goal';
  }

  @override
  String get offNote =>
      'Product data comes from Open Food Facts, a free open database. Only the barcode is sent. Check the label before saving.';

  @override
  String get ok => 'OK';

  @override
  String get onboardingNoAuto =>
      'Nothing is created or scheduled automatically. You\'ll choose what to add next.';

  @override
  String get oneSourceEach =>
      'Each type has one source so far, so there\'s nothing to choose.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get orTypeBarcode => 'Or type the barcode number';

  @override
  String get organizeGroup => 'Organize';

  @override
  String get otherIncome => 'Other income';

  @override
  String get otherSymptoms => 'Something else';

  @override
  String get overBudget => 'Over budget';

  @override
  String get overCapacity =>
      'Your tasks need more time than you have. Some can\'t fit today — move them or shorten them.';

  @override
  String get overdue => 'Overdue';

  @override
  String get overdueDef => 'Due in period, deadline passed, still open';

  @override
  String get overdueTasks => 'Overdue';

  @override
  String paidOnDay(int day) {
    return 'Paid on day $day';
  }

  @override
  String get pain => 'Pain';

  @override
  String painN(int n) {
    return 'Pain $n/10';
  }

  @override
  String get password => 'Password';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get passwordRule =>
      'At least 8 characters, with a letter and a number';

  @override
  String get past => 'Past';

  @override
  String get pastDay => 'This day has passed.';

  @override
  String get pathStarted => 'Your path starts at A1.';

  @override
  String get pauseGoal => 'Pause';

  @override
  String get pausedLabel => 'Paused';

  @override
  String get payDay => 'Pay day';

  @override
  String get perOnePortion => 'For one portion';

  @override
  String perPortion(String portion) {
    return 'Per portion: $portion';
  }

  @override
  String perWeek(int n) {
    return '$n a week';
  }

  @override
  String percentN(String v) {
    return '$v%';
  }

  @override
  String periodCovers(String from, String to) {
    return 'Covers $from – $to';
  }

  @override
  String periodDayN(int n) {
    return 'Period, day $n';
  }

  @override
  String get periodDueAbout => 'Your period may start about now';

  @override
  String get periodEnded => 'Saved: period ended';

  @override
  String get periodEndedToday => 'It ended today';

  @override
  String get periodInvalid =>
      'That doesn\'t fit: check the dates (no future days, no overlap, 15 days at most).';

  @override
  String periodLateBy(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days past the estimated window',
      one: 'A day past the estimated window',
    );
    return '$_temp0';
  }

  @override
  String get periodSaved => 'Period saved';

  @override
  String periodSinceDate(String date) {
    return 'Since $date (going on)';
  }

  @override
  String get periodStarted => 'Saved: period started';

  @override
  String get periodStartedToday => 'It started today';

  @override
  String get permAddNotes => 'Add notes';

  @override
  String get permAddNotesSub => 'Save a note you dictate.';

  @override
  String get permCreateTasks => 'Create a single task';

  @override
  String get permCreateTasksSub =>
      'From a clear request like “add task … tomorrow at 8 pm”.';

  @override
  String get permDraftPlans => 'Draft plans';

  @override
  String get permDraftPlansSub =>
      'Prepare plans for you to review. Drafts are never applied without approval.';

  @override
  String get permLogHabits => 'Log habit completion';

  @override
  String get permLogHabitsSub => 'When you say you did a habit today.';

  @override
  String get photoFailed =>
      'Couldn\'t read the photo. Try another one, or search instead.';

  @override
  String get photoIntro =>
      'Take a photo of your meal and the phone suggests what it is. You choose the food and the amount.';

  @override
  String get photoNoMatch =>
      'No close match in the food list. Try a search, or add it as your own food.';

  @override
  String get photoPrivacy =>
      'The photo is read on your phone only. It isn\'t uploaded or kept.';

  @override
  String get photoStep1 => 'Take a photo of the plate';

  @override
  String get photoStep2 => 'Pick the matching food from the suggestions';

  @override
  String get photoStep3 => 'Choose the amount — that\'s it';

  @override
  String get pickCity => 'Choose a city';

  @override
  String get pin => 'Pin';

  @override
  String get placeGym => 'Gym';

  @override
  String get placeHome => 'Home';

  @override
  String get placementExplain =>
      'Your start level is the middle of your three skill levels. You can retake the test any time.';

  @override
  String get placementIntro =>
      '24 short questions from easy to harder. Answer what you can; guessing only makes the result less accurate.';

  @override
  String get placementNoPeek =>
      'Answers are shown at the end as your level, not one by one.';

  @override
  String placementResult(String level) {
    return 'Your level: $level';
  }

  @override
  String get placementTitle => 'Placement test';

  @override
  String get planApplied => 'Plan applied';

  @override
  String get planEmptyToday => 'Nothing planned for today yet.';

  @override
  String get planExplain =>
      'Plans are built from your answers: full body up to 3 days a week, upper/lower from 4, with core work in every session and rest days between hard ones. Saving keeps your previous plan as an earlier version.';

  @override
  String planFor(String place) {
    return 'Plan: $place';
  }

  @override
  String get planFree => 'Free';

  @override
  String get planIsEstimate =>
      'This plan is an estimate based on durations and priorities. It keeps some free time for breaks and surprises.';

  @override
  String get planLabel => 'Plan';

  @override
  String get planPro => 'Sanad Pro';

  @override
  String get planSaved => 'Plan saved';

  @override
  String planSummary(int done, int total) {
    return '$done of $total tasks done today';
  }

  @override
  String planVersion(int version, String date) {
    return 'Plan version $version · created $date';
  }

  @override
  String get planWithAssistant => 'Plan with assistant';

  @override
  String get plannedDate => 'Planned day';

  @override
  String get plannedShort => 'planned';

  @override
  String get plannedTime => 'Planned time';

  @override
  String get planner => 'Planner';

  @override
  String get planningHint =>
      'This helps the planner place tasks in time you actually have.';

  @override
  String get planningPrefs => 'Planning';

  @override
  String get pointAtBarcode => 'Point the camera at the barcode';

  @override
  String get portionHint => 'e.g. piece, cup, 330 ml can';

  @override
  String get portionName => 'Portion';

  @override
  String portionsN(String n) {
    return '$n × portion';
  }

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerBlock => 'Keep time free for prayer';

  @override
  String get prayerBlockHint => 'The planner won\'t put tasks in this time.';

  @override
  String get prayerCalcNote =>
      'Times are calculated astronomically and may differ by a minute or two from your local mosque. You can change the method in settings.';

  @override
  String get prayerCalculation => 'Calculation';

  @override
  String get prayerCurrent => 'Current prayer time';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerEnable => 'Show prayer times';

  @override
  String get prayerEnableHint =>
      'On the home screen, in your day plan and as reminders.';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get prayerLocation => 'Location';

  @override
  String get prayerLogHint =>
      'Mark it yourself after you pray. Sanad never assumes.';

  @override
  String prayerLogLabel(String name) {
    return 'I prayed $name';
  }

  @override
  String get prayerLogToggle => 'Prayer log';

  @override
  String get prayerLogToggleHint =>
      'Optional. Only what you mark yourself is recorded.';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerMethodLabel => 'Method';

  @override
  String get prayerNoLocation => 'No location set yet';

  @override
  String get prayerNotify => 'Notify me at each prayer time';

  @override
  String get prayerPreview => 'Today\'s times';

  @override
  String get prayerRemindBefore => 'Also remind me before';

  @override
  String get prayerReminders => 'Reminders and planning';

  @override
  String get prayerSettingsTitle => 'Prayer times settings';

  @override
  String get prayerSetupAction => 'Set up';

  @override
  String get prayerSetupBody =>
      'Choose your city to see prayer times and plan your day around them.';

  @override
  String get prayerSetupTitle => 'Prayer times';

  @override
  String prayerWeekLogged(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'You logged $n prayers in the last 7 days.',
      one: 'You logged 1 prayer in the last 7 days.',
      zero: 'You haven\'t logged any prayers in the last 7 days.',
    );
    return '$_temp0';
  }

  @override
  String get previous => 'Previous';

  @override
  String get previousChats => 'Previous chats';

  @override
  String get previousDay => 'Previous day';

  @override
  String get pricingNotSet =>
      'Price, billing period, taxes and renewal terms will be shown clearly here before purchase is enabled.';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get privacyRetention => 'Chat history';

  @override
  String get privacyText =>
      'Sanad — Privacy policy (local mode draft)\n\n1. What we collect: only what you enter — your email, a salted hash of your password, your preferences, tasks, events, goals, habits, notes, expenses and assistant chats.\n\n2. Where it\'s stored: on this device. Nothing is sent to our servers or to an AI provider in this version.\n\n3. The assistant: it runs on your device and reads only the sections you allow in assistant settings.\n\n4. Your control: you can export all your data, delete chats, and delete your account at any time.\n\n5. Support reports never include your chats, notes or expenses; technical info is added only if you choose.\n\nThis draft must be reviewed and replaced with the final policy before public launch.';

  @override
  String get privacyTitle => 'Privacy & data';

  @override
  String get problemDescription => 'What went wrong?';

  @override
  String get productFound =>
      'Found in Open Food Facts. Check the numbers against the label before saving.';

  @override
  String get productNotFound =>
      'Not in the database yet — enter it once from the label and it\'s kept.';

  @override
  String get profileTitle => 'Profile & account';

  @override
  String get programDisclaimer =>
      'General guidance, not medical advice. If something doesn\'t feel right, stop and ask your doctor.';

  @override
  String get programExercises => 'Exercises';

  @override
  String get programStages => 'Choose your stage';

  @override
  String get programUnavailable => 'Not available';

  @override
  String get programUnavailableBody =>
      'This program isn\'t part of your health sections.';

  @override
  String get programs => 'Programs';

  @override
  String get programsForMen => 'For men';

  @override
  String get programsForWomen => 'For women';

  @override
  String get progress => 'Progress';

  @override
  String get progressLog => 'Progress log';

  @override
  String get progressLogSub => 'Your best and latest sets for each exercise';

  @override
  String get progressManual => 'Manual progress';

  @override
  String get progressMethod => 'How is progress measured?';

  @override
  String get progressNotMeasured => 'Not measured yet';

  @override
  String get progressNote =>
      'From the sets you logged: weight × reps when you entered a weight, otherwise reps or time. Gold marks the best session.';

  @override
  String get proposalExecuted => 'Applied';

  @override
  String get proposalFailed => 'Failed — nothing was changed';

  @override
  String get proposalNotFound => 'This suggestion no longer exists.';

  @override
  String get proposalRejected => 'Rejected';

  @override
  String get proposalStale =>
      'Your data changed since this was suggested. Ask again for a fresh suggestion.';

  @override
  String get protein => 'Protein';

  @override
  String get proteinG => 'Protein (g)';

  @override
  String questionOf(int current, int total) {
    return '$current of $total';
  }

  @override
  String get questionsForDoctor => 'Questions for the doctor';

  @override
  String questionsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String get quickAdd => 'Quick add';

  @override
  String readOnlyNote(String store) {
    return 'Each switch asks $store for permission the first time. Turning one off stops reading; what came in stays.';
  }

  @override
  String get readSleepBasics => 'Read: sleep basics';

  @override
  String get readThis => 'Read:';

  @override
  String get reason => 'Why';

  @override
  String get reasonDeadline => 'Would finish after its deadline time';

  @override
  String get reasonNoSlot => 'No free slot is long enough';

  @override
  String get reasonNoTime => 'Not enough free time left today';

  @override
  String get receivedThisMonth => 'Received';

  @override
  String get recentFoods => 'Recent';

  @override
  String get recentNights => 'Recent nights';

  @override
  String get recentWorkouts => 'Recent workouts';

  @override
  String get recordedPeriods => 'Recorded periods';

  @override
  String get recovery => 'Recovery';

  @override
  String get recoveryWarning =>
      'Two demanding sessions fall on back-to-back days. Consider a rest day between them.';

  @override
  String get recurringActive => 'Active';

  @override
  String get regional => 'Region & time';

  @override
  String get reject => 'Reject';

  @override
  String get remaining => 'Remaining';

  @override
  String get remainingFormula => 'Income − expenses';

  @override
  String get remind3HoursBefore => '3 hours before';

  @override
  String remindBeforeN(int n) {
    return '$n min before';
  }

  @override
  String get remindDayBefore => 'A day before';

  @override
  String get remindHourBefore => 'An hour before';

  @override
  String get reminder => 'Reminder';

  @override
  String get reminderNeedsTime =>
      'Set a deadline or a planned time for the reminder.';

  @override
  String get reminderTimeOptional => 'Reminder time (optional)';

  @override
  String get removeCup => 'Remove a glass';

  @override
  String get removeFromPlan => 'Remove from today\'s plan';

  @override
  String get removeItem => 'Remove this change';

  @override
  String get removeSourceData => 'Remove this source\'s data';

  @override
  String removeSourceDataBody(String source) {
    return 'Steps, sleep, heart rate and workouts that came from $source are removed from Sanad on all your devices. Nothing changes in $source itself.';
  }

  @override
  String removeSourceDataTitle(String source) {
    return 'Remove data from $source?';
  }

  @override
  String get removedFromPlan => 'Removed from this plan';

  @override
  String get reorder => 'Reorder';

  @override
  String get reorderHint => 'Drag to change the order; times are recalculated.';

  @override
  String get repeatDays => 'Days';

  @override
  String get repeatMonthly => 'Repeat every month';

  @override
  String get repeatMonthlySub => 'Recorded on this day each month';

  @override
  String reportFood(int days, String kcal) {
    return 'Food logged on $days days, about $kcal kcal a day';
  }

  @override
  String get reportNoData => 'Not enough data for this period yet.';

  @override
  String get reportPrivacy =>
      'Your chats, notes and expenses are never included in reports.';

  @override
  String get reportProblem => 'Report a problem';

  @override
  String get reportProblemSub => 'Describe what happened';

  @override
  String get reportSaved =>
      'Report saved. It will be sent when the support service is connected.';

  @override
  String reportSleep(String avg, int nights) {
    return 'Slept $avg on average ($nights nights recorded)';
  }

  @override
  String reportStepGoal(int days, int total) {
    return 'Step goal reached $days of $total days';
  }

  @override
  String get repsLabel => 'Reps';

  @override
  String repsN(int n) {
    return '$n reps';
  }

  @override
  String get resetLinkSent =>
      'If an account exists for this email, a reset link is on its way.';

  @override
  String get restBlock => 'Break';

  @override
  String get restDayBody =>
      'Recovery is part of the plan. A walk or light stretching is plenty.';

  @override
  String get restDayTitle => 'Rest day';

  @override
  String restFor(int n) {
    return 'Rest $n s';
  }

  @override
  String get restOfDayFree => 'The rest of the day is yours.';

  @override
  String restSeconds(int n) {
    return 'rest $n s';
  }

  @override
  String get restingHeartRate => 'Resting heart rate';

  @override
  String get restore => 'Restore';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get resumeGoal => 'Make active';

  @override
  String get retakePlacement => 'Retake test';

  @override
  String get retry => 'Try again';

  @override
  String get reviewChanges => 'Review changes';

  @override
  String reviewDone(int right, int total) {
    return '$right of $total right. Missed words come back tomorrow.';
  }

  @override
  String reviewDue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n words to review',
      one: '1 word to review',
    );
    return '$_temp0';
  }

  @override
  String get reviewMyPlan => 'Review my plan';

  @override
  String get reviewTitle => 'Word review';

  @override
  String get reviewWhy =>
      'Words you learned come back at growing intervals so they stick.';

  @override
  String get salaryChangeNote =>
      'Months before this date keep the salary they had.';

  @override
  String get salaryHistory => 'Salary history';

  @override
  String get salaryLabel => 'Salary';

  @override
  String salarySince(String amount, String date) {
    return '$amount from $date';
  }

  @override
  String salaryStoppedSince(String date) {
    return 'Variable income from $date';
  }

  @override
  String get sampleGoal1 => 'Learn English';

  @override
  String get sampleGoal2 => 'Learn programming';

  @override
  String get sampleGoal3 => 'Exercise regularly';

  @override
  String get sampleGoal4 => 'Read 12 books this year';

  @override
  String get save => 'Save';

  @override
  String get saveAndAdd => 'Save and add';

  @override
  String get saveAnyway => 'Save anyway';

  @override
  String get saveEvent => 'Save event';

  @override
  String get saveGoal => 'Save goal';

  @override
  String get saveOnly => 'Save only';

  @override
  String get savePlan => 'Save plan';

  @override
  String get saveTask => 'Save task';

  @override
  String get saveWorkout => 'Save workout';

  @override
  String get saved => 'Saved';

  @override
  String get saving => 'Saving…';

  @override
  String get scanBarcode => 'Barcode';

  @override
  String get scanOnPhone => 'Camera scanning is in the phone app';

  @override
  String get scanOnPhoneBody =>
      'Here you can type the number printed under the barcode.';

  @override
  String get scheduleGroup => 'When';

  @override
  String scoreOutOf(int score, int pass) {
    return 'You scored $score% (needed $pass%).';
  }

  @override
  String get search => 'Search';

  @override
  String get searchCity => 'Search for a city';

  @override
  String get searchFoods => 'Search foods';

  @override
  String get searchInstead => 'Search the list instead';

  @override
  String get secondsLabel => 'Seconds';

  @override
  String secondsN(int n) {
    return '$n s';
  }

  @override
  String secondsShort(int n) {
    return '$n s';
  }

  @override
  String get sectionsShown => 'Sections in the app';

  @override
  String get seeResult => 'See result';

  @override
  String get send => 'Send';

  @override
  String get sendResetLink => 'Send link';

  @override
  String get sessionCompleted => 'Completed';

  @override
  String get sessionLength => 'Session length';

  @override
  String get sessionPartial => 'Partly done';

  @override
  String get sessions => 'Sessions';

  @override
  String get sessionsLocal =>
      'Local mode has one session per device. Signing out ends it.';

  @override
  String get sessionsRemote =>
      'Signing out ends the session on this device. Changing your password signs out other devices when their session refreshes.';

  @override
  String setN(int n) {
    return 'Set $n';
  }

  @override
  String get setSalary => 'Set salary';

  @override
  String setsLogged(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n sets',
      one: '1 set',
    );
    return '$_temp0';
  }

  @override
  String setsProgress(int done, int total) {
    return '$done/$total sets';
  }

  @override
  String get sexAskTitle => 'Tell us about you';

  @override
  String get sexFemale => 'Female';

  @override
  String get sexLabel => 'Sex';

  @override
  String get sexMale => 'Male';

  @override
  String get sexWhy =>
      'Used only to tailor the health sections. You can change it from your profile.';

  @override
  String get shareActivitySub => 'Steps and active minutes of the last 7 days';

  @override
  String get shareCycleSub => 'Not used by the assistant yet; stays private';

  @override
  String get shareNotesSub => 'Off by default';

  @override
  String get shareNutritionSub => 'Daily food totals and water, no photos';

  @override
  String get shareSleepSub => 'Sleep length and how rested you felt';

  @override
  String get shareSub => 'Used to plan and summarize';

  @override
  String get shareVitalsSub => 'Weight, blood pressure and other measurements';

  @override
  String get showActive => 'Show active';

  @override
  String get showArchived => 'Show archived';

  @override
  String get showCompleted => 'Show completed & archived';

  @override
  String get showMyPlan => 'Show my plan';

  @override
  String get showNameGreeting => 'Show my name in the greeting';

  @override
  String get showPassword => 'Show password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInMethod => 'Sign-in method';

  @override
  String get signInSubtitle => 'Sign in to continue.';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutBody => 'Your data stays saved for when you sign in again.';

  @override
  String get signUpSubtitle => 'It takes less than a minute.';

  @override
  String get signUpTitle => 'Create your account';

  @override
  String get signedInAs => 'Signed in. Welcome to Sanad.';

  @override
  String get sixMonths => 'Last 6 months';

  @override
  String get skillGrammar => 'Grammar';

  @override
  String get skillReading => 'Reading';

  @override
  String get skillVocabulary => 'Vocabulary';

  @override
  String get skillsMeasuredNote =>
      'The app measures vocabulary, grammar and reading. Listening and speaking need audio tools and aren\'t assessed yet.';

  @override
  String get skip => 'Skip';

  @override
  String get skipRest => 'Skip';

  @override
  String get sleepAndRecovery => 'Sleep and recovery';

  @override
  String get sleepAndRecoverySub =>
      'Your nights, how rested you feel, a bedtime reminder';

  @override
  String get sleepGoldNote => 'Gold marks nights of 7 hours or more.';

  @override
  String get sleepInvalid =>
      'That doesn\'t fit: check the times (up to 24 hours, not in the future, not overlapping another night you added).';

  @override
  String sleepNightsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n nights',
      one: '1 night',
    );
    return '$_temp0';
  }

  @override
  String get sleepQuality => 'How did you sleep?';

  @override
  String sleepQualityN(int n) {
    return 'Quality $n of 5';
  }

  @override
  String sleepWindow(String from, String to) {
    return '$from – $to';
  }

  @override
  String get slotEvent => 'Appointments';

  @override
  String get slotFree => 'Free';

  @override
  String get slotPast => 'Passed';

  @override
  String get slotPrayer => 'Prayer';

  @override
  String get slotSleep => 'Sleep';

  @override
  String get slotTask => 'Tasks at a time';

  @override
  String sourceDataRemoved(String source) {
    return 'Removed data from $source';
  }

  @override
  String get sourceHealthConnect => 'Health Connect';

  @override
  String get sourceHealthKit => 'Apple Health';

  @override
  String get sourceManual => 'Added by hand';

  @override
  String get sourcePhone => 'Phone sensor';

  @override
  String get sources => 'Sources';

  @override
  String get sourcesWithData => 'Sources with your data';

  @override
  String get spending => 'Spending';

  @override
  String get spentMoreThanIncome =>
      'You spent more than you received this month.';

  @override
  String get splashFailed => 'We couldn\'t start Sanad.';

  @override
  String get splashTagline => 'Your whole life in one place';

  @override
  String get startDate => 'Start date';

  @override
  String get startFromBeginning => 'Start from the beginning';

  @override
  String get startLesson => 'Start lesson';

  @override
  String get startPath => 'Start my path';

  @override
  String get startProgram => 'Start';

  @override
  String get startQuiz => 'Take the short quiz';

  @override
  String get startTime => 'Starts';

  @override
  String get startWorkout => 'Start workout';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusDone => 'Done';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusLabel => 'Status';

  @override
  String get statusTodo => 'To do';

  @override
  String stepDaysN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days of steps',
      one: '1 day of steps',
    );
    return '$_temp0';
  }

  @override
  String get stepGoal => 'Daily step goal';

  @override
  String stepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get stepsInvalid => 'Up to 150,000';

  @override
  String get stepsLabel => 'Steps';

  @override
  String get stepsNoData => 'No steps yet today — tap to connect or add them';

  @override
  String stepsOfGoal(String steps, String goal) {
    return '$steps / $goal steps';
  }

  @override
  String get stepsOptional => 'Steps to reproduce (optional)';

  @override
  String stepsPerDay(String n) {
    return '$n steps a day';
  }

  @override
  String get stepsPermissionDenied =>
      'Steps access wasn\'t given. You can allow it from the health app\'s settings.';

  @override
  String get stepsToday => 'Steps today';

  @override
  String get stop => 'Stop';

  @override
  String get stopIf => 'Stop and get advice if you have';

  @override
  String streakDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n-day streak',
      one: '1-day streak',
      zero: 'No streak yet',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String get suggestedPill => 'Suggested';

  @override
  String get suggestedPlan => 'Suggested plan';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get switchLabel => 'Switch';

  @override
  String get switchToSignIn => 'Already have an account? Sign in';

  @override
  String get switchToSignUp => 'New here? Create an account';

  @override
  String get switchToVariableBody =>
      'Your fixed salary stops from the date you pick. Past months stay as they were.';

  @override
  String get switchToVariableTitle => 'Switch to variable income?';

  @override
  String get syAcne => 'Acne';

  @override
  String get syBackPain => 'Back pain';

  @override
  String get syBloating => 'Bloating';

  @override
  String get syBreastTenderness => 'Breast tenderness';

  @override
  String get syCramps => 'Cramps';

  @override
  String get syCravings => 'Cravings';

  @override
  String get syFatigue => 'Tiredness';

  @override
  String get syHeadache => 'Headache';

  @override
  String get syInsomnia => 'Poor sleep';

  @override
  String get syMoodSwings => 'Mood swings';

  @override
  String get syNausea => 'Nausea';

  @override
  String get sySpotting => 'Spotting';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get syncFailedShort => 'Couldn\'t read steps — try again';

  @override
  String get syncNever => 'Not synced yet';

  @override
  String get syncNow => 'Sync now';

  @override
  String syncOffline(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Offline — $n changes will sync when you\'re back online.',
      one: 'Offline — 1 change will sync when you\'re back online.',
      zero: 'Offline — showing saved data.',
    );
    return '$_temp0';
  }

  @override
  String syncPending(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n changes waiting to upload',
      one: '1 change waiting to upload',
    );
    return '$_temp0';
  }

  @override
  String get syncRejected =>
      'Some changes couldn\'t be saved to your account and were replaced with the saved version.';

  @override
  String get syncStatus => 'Sync';

  @override
  String syncUpToDate(String time) {
    return 'Up to date · $time';
  }

  @override
  String get systolic => 'Upper (systolic)';

  @override
  String get takeLevelCheck => 'Take the level check';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get takePlacement => 'Take the placement test';

  @override
  String get targetDate => 'Target date';

  @override
  String targetOn(String date) {
    return 'Target $date';
  }

  @override
  String get taskTitleRequired => 'Task title';

  @override
  String get tasksCompleted => 'Tasks completed';

  @override
  String tasksCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String tasksDoneOf(int done, int total) {
    return '$done/$total tasks done';
  }

  @override
  String get terms => 'Terms of use';

  @override
  String get termsText =>
      'Sanad — Terms of use (draft)\n\nSanad helps you organize your time, goals, habits, notes and expenses. Plans and suggestions are estimates, not guarantees. Sanad is not a banking, financial-advice or medical service. You are responsible for the data you enter and for decisions you make based on it.\n\nThis draft must be reviewed and replaced with the final terms before public launch.';

  @override
  String get testHistory => 'Test history';

  @override
  String get theme => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get thinking => 'Thinking…';

  @override
  String get thisDevice => 'This device';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisPhone => 'This phone';

  @override
  String get thisWeek => 'This week';

  @override
  String get time => 'Time';

  @override
  String timesN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n times',
      one: 'once',
    );
    return '$_temp0';
  }

  @override
  String get timezone => 'Time zone';

  @override
  String get timezoneDetected =>
      'Detected from your device. Times are shown in your device\'s time zone.';

  @override
  String get timezoneDeviceNote => 'follows your device';

  @override
  String get to => 'To';

  @override
  String get today => 'Today';

  @override
  String todayFrom(String source) {
    return 'Today: $source';
  }

  @override
  String get todayLogged => 'Today, logged';

  @override
  String get todayPlan => 'Today\'s plan';

  @override
  String get todaysHabits => 'Today\'s habits';

  @override
  String get todaysLesson => 'Today\'s lesson';

  @override
  String todaysWorkout(String focus) {
    return 'Today\'s workout: $focus';
  }

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get toolAddAppointment => 'Add health appointment';

  @override
  String get toolAddMilestones => 'Add milestones';

  @override
  String get toolAddNote => 'Add note';

  @override
  String get toolCreateGoal => 'Create goal';

  @override
  String get toolCreateTask => 'Create task';

  @override
  String get toolDeleteTask => 'Delete task';

  @override
  String get toolLogHabit => 'Log habit';

  @override
  String get toolLogWater => 'Log water';

  @override
  String get toolMoveTask => 'Change deadline';

  @override
  String get toolPlanTask => 'Set planned time';

  @override
  String get topPriorities => 'Top priorities';

  @override
  String get totalIncome => 'Total income';

  @override
  String get totalSpent => 'Total spent';

  @override
  String get tryAgain => 'Study it again';

  @override
  String turnOnSection(String section) {
    return 'Turn on $section in health settings first';
  }

  @override
  String typeToConfirm(String word) {
    return 'Type “$word” to confirm';
  }

  @override
  String get unarchive => 'Restore from archive';

  @override
  String get unarchived => 'Restored';

  @override
  String get undo => 'Undo';

  @override
  String unitHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n h',
      one: '1 h',
    );
    return '$_temp0';
  }

  @override
  String unitMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n min',
      one: '1 min',
    );
    return '$_temp0';
  }

  @override
  String get unlock => 'Unlock';

  @override
  String get unlockFailed => 'Not unlocked';

  @override
  String get unlockReason => 'Open your health sections in Sanad';

  @override
  String get unpin => 'Unpin';

  @override
  String get unread => 'Unread';

  @override
  String get unscheduled => 'Unscheduled';

  @override
  String get untilDeleted => 'Until I delete them';

  @override
  String get untitled => 'Untitled';

  @override
  String get upcoming => 'Upcoming';

  @override
  String upcomingSalary(String amount, String date) {
    return 'Salary of $amount due $date';
  }

  @override
  String get upgrade => 'Upgrade';

  @override
  String usageToday(int used, int limit) {
    return '$used/$limit assistant requests today';
  }

  @override
  String get use24h => '24-hour time';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String usuallyOnDay(int n) {
    return 'Usually on day $n of the cycle';
  }

  @override
  String get verificationLocal => 'Not required in local mode';

  @override
  String get viewAll => 'View all';

  @override
  String get viewAllGoals => 'View all goals';

  @override
  String get viewCalendar => 'Calendar';

  @override
  String get vitals => 'Measurements';

  @override
  String get vitalsFromDevices =>
      'Read weight and blood pressure from your phone\'s health app';

  @override
  String get vitalsNote =>
      'For your own record. These numbers aren\'t a diagnosis; read more in Health reading.';

  @override
  String get vitalsSub => 'Weight, waist, heart rate, blood pressure, body fat';

  @override
  String vsLastMonth(String amount) {
    return 'Last month: $amount';
  }

  @override
  String get vsPreviousPeriod => 'vs the previous period';

  @override
  String get wakeTime => 'I wake up at';

  @override
  String walkItem(int minutes) {
    return 'A $minutes-minute walk';
  }

  @override
  String get warnBleeding => 'Vaginal bleeding';

  @override
  String get warnCalf => 'Pain or swelling in a calf';

  @override
  String get warnChest => 'Chest pain or unusual shortness of breath';

  @override
  String get warnContractions => 'Regular, painful contractions';

  @override
  String get warnDizzy => 'Dizziness or feeling faint';

  @override
  String get warnFluid => 'Fluid leaking';

  @override
  String get warnHeadache => 'A bad headache';

  @override
  String get warnHeavyBleeding => 'Heavier bleeding than before';

  @override
  String get warnLeaking => 'Leaking urine during exercise';

  @override
  String get warnPain => 'Pain (not just effort)';

  @override
  String get warnPelvicHeaviness => 'Heaviness or bulging in the pelvis';

  @override
  String waterAverage(String ml) {
    return 'Water: $ml ml a day on average';
  }

  @override
  String get waterGoal => 'Daily water goal';

  @override
  String waterMl(String ml) {
    return '$ml ml';
  }

  @override
  String waterOfGoal(String ml, String goal) {
    return 'Water $ml / $goal ml';
  }

  @override
  String get wdFri => 'Fri';

  @override
  String get wdMon => 'Mon';

  @override
  String get wdSat => 'Sat';

  @override
  String get wdSun => 'Sun';

  @override
  String get wdThu => 'Thu';

  @override
  String get wdTue => 'Tue';

  @override
  String get wdWed => 'Wed';

  @override
  String get week => 'Week';

  @override
  String get weekAhead => 'Your next 7 days';

  @override
  String weekAverage(String value) {
    return 'Week average: $value';
  }

  @override
  String get weekBusy => 'Busy day';

  @override
  String weekEvents(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n events',
      one: '1 event',
      zero: 'No events',
    );
    return '$_temp0';
  }

  @override
  String get weekLoad => 'Planned load';

  @override
  String get weekReport => 'Weekly report';

  @override
  String get weekReportNote => 'Averages count only days you logged something.';

  @override
  String get weekStart => 'Week starts on';

  @override
  String weekTasks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tasks due',
      one: '1 task due',
      zero: 'No tasks due',
    );
    return '$_temp0';
  }

  @override
  String weekWorkouts(int done, int planned) {
    return '$done of $planned workouts done this week';
  }

  @override
  String get weeklyGoalQuestion => 'How many lessons a week?';

  @override
  String weeklyLessons(int done, int goal) {
    return '$done of $goal lessons this week';
  }

  @override
  String get weeklyPlan => 'Weekly plan';

  @override
  String get weightKg => 'kg';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get welcomeBody =>
      'Your time, goals, habits, notes and spending — in one place that plans with you.';

  @override
  String get welcomeTitle => 'Organize your life, step by step';

  @override
  String get wentToBed => 'Went to bed';

  @override
  String get whatThisPhoneReads => 'What this phone reads';

  @override
  String get whatWeStore => 'What Sanad stores';

  @override
  String get whatWeStoreBody =>
      'Your account (email and a salted password hash), preferences, tasks, events, goals, milestones, habits and their logs, notes, expenses and budgets, assistant chats (per your retention setting) and an action log without message content. In local mode all of this stays on this device.';

  @override
  String get whatWeStoreBodyRemote =>
      'Your account (email; the password is handled by our authentication service and never stored by the app), preferences, tasks, events, goals, milestones, habits and their logs, notes, expenses and budgets are stored in your account on our servers, readable only by you (row-level security), with a copy on this device for offline use. Assistant chats currently stay on this device, per your retention setting.';

  @override
  String get whichSourceCounts => 'Which source counts';

  @override
  String get whyOptional => 'Why it matters (optional)';

  @override
  String get woBasketball => 'Basketball';

  @override
  String get woCycling => 'Cycling';

  @override
  String get woElliptical => 'Elliptical';

  @override
  String get woFootball => 'Football';

  @override
  String get woHiit => 'Interval training';

  @override
  String get woHiking => 'Hiking';

  @override
  String get woOther => 'Workout';

  @override
  String get woPilates => 'Pilates';

  @override
  String get woRowing => 'Rowing';

  @override
  String get woRunning => 'Running';

  @override
  String get woStairs => 'Stairs';

  @override
  String get woStrength => 'Strength training';

  @override
  String get woSwimming => 'Swimming';

  @override
  String get woTennis => 'Tennis';

  @override
  String get woWalking => 'Walking';

  @override
  String get woYoga => 'Yoga';

  @override
  String get wokeUp => 'Woke up';

  @override
  String get wokeUpOn => 'Woke up on';

  @override
  String get womensUnavailable => 'This section is part of women\'s health.';

  @override
  String get wordsAddedToReview =>
      'This lesson\'s words are added to your reviews, starting tomorrow.';

  @override
  String get workBlock => 'Work / study';

  @override
  String get workDaysHint =>
      'Work/study hours apply on the selected days. Clear the start time to remove them.';

  @override
  String get workEnd => 'Until';

  @override
  String get workStart => 'Work/study from';

  @override
  String get workoutDoneToday => 'Today\'s workout is done';

  @override
  String get workoutNote => 'Note';

  @override
  String get workoutNoteHint => 'e.g. knee felt tight on lunges';

  @override
  String get workoutSaved => 'Workout saved. Well done!';

  @override
  String get workoutSavedPartial => 'Saved what you did. Every bit counts.';

  @override
  String workoutsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n workouts',
      one: '1 workout',
    );
    return '$_temp0';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String get yourData => 'Your data';

  @override
  String get yourSkills => 'Your skills (placement test)';
}
