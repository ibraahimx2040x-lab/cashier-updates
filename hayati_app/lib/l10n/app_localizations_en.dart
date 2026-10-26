// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get addEvent => 'Add event';

  @override
  String get addExpense => 'Add expense';

  @override
  String get addFirstGoal => 'Add a goal';

  @override
  String get addFirstTask => 'Add your first task';

  @override
  String get addGoal => 'Add goal';

  @override
  String get addHabit => 'Add habit';

  @override
  String get addMilestone => 'Add milestone';

  @override
  String get addNote => 'Add note';

  @override
  String get addTask => 'Add task';

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
  String aiAskAmPm(int hour) {
    return 'Do you mean $hour in the morning or in the evening?';
  }

  @override
  String get aiAutoDone =>
      'Done automatically (you allowed this in assistant settings).';

  @override
  String get aiChipAddTask => 'Add a new task';

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
  String aiHabitLogged(String name) {
    return 'I\'ll log “$name” as done today.';
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
  String get aiNoGoalToSplit =>
      'I didn\'t find an active goal without milestones. Create a goal first or tell me what you want to learn.';

  @override
  String get aiNoOverdue => 'You have no overdue tasks. 🎉';

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
  String get any => 'Any';

  @override
  String get appName => 'Hayati';

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
  String get archive => 'Archive';

  @override
  String get archiveGoal => 'Archive';

  @override
  String get archived => 'Archived';

  @override
  String get archivedNotes => 'Archived notes';

  @override
  String get askAssistantReplan => 'Ask the assistant to rearrange my day';

  @override
  String get askAssistantReview => 'Ask the assistant';

  @override
  String get assistantDisabled => 'The assistant is turned off';

  @override
  String get assistantDisabledBody =>
      'Everything else in Hayati keeps working. Turn it on in settings any time.';

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
  String get assistantTitle => 'Hayati assistant';

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
  String get back => 'Back';

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
  String get billingNote =>
      'Paid features are only enabled after your purchase is verified by our server through the app store.';

  @override
  String get breakEnd => 'Until';

  @override
  String get breakStart => 'Break from';

  @override
  String get budget => 'Budget';

  @override
  String budgetUsed(String spent, String cap) {
    return '$spent of $cap';
  }

  @override
  String get byCategory => 'By category';

  @override
  String get byMilestones => 'By milestones';

  @override
  String get byMilestonesHint =>
      'Progress = completed milestones ÷ all milestones. A milestone completes when you check it or when all its tasks are done.';

  @override
  String get calendar => 'Calendar';

  @override
  String get cancel => 'Cancel';

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
  String get changePassword => 'Change password';

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
  String get clear => 'Clear';

  @override
  String get clearLog => 'Clear log';

  @override
  String get clearRead => 'Clear read notifications';

  @override
  String get cloudModeNotice =>
      'Your data is saved to your account and kept on this device for offline use.';

  @override
  String get comingSoon => 'Coming soon';

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
  String get contactSupport => 'Contact support';

  @override
  String get couldNotFit => 'Couldn\'t fit';

  @override
  String get createAccount => 'Create account';

  @override
  String get createFirstPlan => 'Create my first plan';

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
  String get currentStreak => 'Current streak';

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
  String get deleteNoteBody =>
      'This note will be permanently deleted. You can archive it instead.';

  @override
  String get deleteNoteTitle => 'Delete note?';

  @override
  String deleteTaskBody(String title) {
    return '“$title” will be permanently deleted. You can archive it instead.';
  }

  @override
  String get deleteTaskTitle => 'Delete task?';

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
  String get discard => 'Discard';

  @override
  String get discardMessage =>
      'You have unsaved changes. Leave without saving?';

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get displayName => 'Display name';

  @override
  String get displayNameOptional => 'Your name (optional)';

  @override
  String get documents => 'Documents';

  @override
  String get doneDays => 'Done / due';

  @override
  String get dragHint => 'Long-press and drag a task onto an hour to plan it.';

  @override
  String get due => 'Due';

  @override
  String get dueShort => 'due';

  @override
  String get edit => 'Edit';

  @override
  String get editEvent => 'Edit event';

  @override
  String get editGoal => 'Goal';

  @override
  String get editHabit => 'Edit habit';

  @override
  String get editMilestone => 'Edit milestone';

  @override
  String get editTask => 'Edit task';

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
  String get endTime => 'Ends';

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
  String get errRateLimited =>
      'Too many attempts. Please wait a little and try again.';

  @override
  String get errRequired => 'This field is required';

  @override
  String get errSave => 'Couldn\'t save. Check the fields and try again.';

  @override
  String get errTargetBeforeStart => 'Target date must be after the start date';

  @override
  String get estimatedDuration => 'Estimated 30 min';

  @override
  String get estimatedMinutes => 'Estimated duration (minutes)';

  @override
  String get eventTitle => 'Event title';

  @override
  String get eventsLabel => 'Events';

  @override
  String get everyDay => 'Every day';

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
  String get expenseList => 'Expenses';

  @override
  String get expensesManualNote =>
      'Expenses are entered manually. No bank accounts are linked.';

  @override
  String exportCopied(int chars) {
    return 'Copied ($chars characters)';
  }

  @override
  String get exportData => 'Export my data';

  @override
  String get exportDataSub => 'Copies all your data as JSON to the clipboard';

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
      'In this version reminders appear in the notification centre while the app is open. Make sure the task has a reminder and a deadline or planned time.';

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
  String get finishSetup => 'Finish setup';

  @override
  String get fixedBlocks => 'Fixed blocks';

  @override
  String get fixedCommitments => 'Fixed commitments';

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
  String get freeTime => 'Free time';

  @override
  String get getStarted => 'Get started';

  @override
  String get goalActive => 'Active';

  @override
  String get goalArchived => 'Archived';

  @override
  String get goalCompleted => 'Completed';

  @override
  String get goalPaused => 'Paused';

  @override
  String get goalStepHint =>
      'Choose an example or write your own. You can skip this.';

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
  String get hasBreak => 'Add a daily break';

  @override
  String get hasWorkHours => 'I have fixed work or study hours';

  @override
  String get haveAccount => 'I have an account';

  @override
  String get helpTitle => 'Help & support';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get highlights => 'Highlights';

  @override
  String get historyHint =>
      'Tap a past day to correct it. Days the habit isn\'t due are neutral.';

  @override
  String get homeSections => 'Home screen';

  @override
  String get inactiveHabits => 'Inactive';

  @override
  String get includeTechInfo => 'Include technical info';

  @override
  String get initialTasks => 'First tasks';

  @override
  String get interestsHint =>
      'Pick any — you can change this later. Sections you don\'t pick are hidden, not deleted.';

  @override
  String get itemGone => 'This item no longer exists.';

  @override
  String get keepAnyway => 'Keep anyway';

  @override
  String get keepChats => 'Keep chats for';

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
  String get lastWeek => 'Last week';

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
  String get locationOptional => 'Location (optional)';

  @override
  String get manageAssistantAccess => 'Manage assistant permissions';

  @override
  String get manual => 'Manually';

  @override
  String get manualHint => 'You set the percentage yourself.';

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
  String get memberSince => 'Member since';

  @override
  String get menu => 'Menu';

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
  String get month => 'Month';

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String get more => 'More';

  @override
  String get moreFilters => 'More filters';

  @override
  String get moreOptions => 'More options';

  @override
  String get moveTomorrow => 'Move to tomorrow';

  @override
  String movedTo(String time) {
    return 'Moved to $time';
  }

  @override
  String get movedTomorrow => 'Moved to tomorrow';

  @override
  String get multiCurrencyNote =>
      'Each currency is totalled separately — amounts are never combined across currencies.';

  @override
  String get myGoals => 'My goals';

  @override
  String get myNotes => 'My notes';

  @override
  String get navAssistant => 'Assistant';

  @override
  String get navExpenses => 'Expenses';

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
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navTime => 'My time';

  @override
  String get neededTime => 'Tasks need';

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
  String get newUserTitle => 'Welcome to Hayati 👋';

  @override
  String get next => 'Next';

  @override
  String get nextPeriod => 'Next';

  @override
  String get noActions => 'No actions yet.';

  @override
  String get noActiveGoals => 'No active goals right now.';

  @override
  String get noConversations => 'No previous chats.';

  @override
  String get noExpensesPeriod => 'No expenses in this period';

  @override
  String get noGoalsYet => 'No goals yet';

  @override
  String get noHabitsDueToday => 'No habits are due today.';

  @override
  String get noHabitsYet => 'No habits yet';

  @override
  String get noLinkedTasks => 'No tasks linked to this goal yet.';

  @override
  String get noMilestones => 'No milestones yet.';

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noReminder => 'No reminder';

  @override
  String get noSearchResults => 'No results';

  @override
  String get noTasksToday => 'No tasks for today.';

  @override
  String get noUnread => 'You\'re all caught up';

  @override
  String get noUpcoming => 'No upcoming events.';

  @override
  String get none => 'None';

  @override
  String get notDue => 'Not due';

  @override
  String get notLogged => 'Not logged';

  @override
  String get notSet => 'Not set';

  @override
  String get noteBody => 'Write your note…';

  @override
  String get noteTitle => 'Title';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get nothingScheduled => 'Nothing scheduled';

  @override
  String get nothingToPlan => 'No open tasks to plan for this day.';

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
  String notifHabitTitle(String name) {
    return 'Habit reminder: $name';
  }

  @override
  String notifTaskTitle(String title) {
    return 'Reminder: $title';
  }

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
  String get ok => 'OK';

  @override
  String get onboardingNoAuto =>
      'Nothing is created or scheduled automatically. You\'ll choose what to add next.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get organizeGroup => 'Organize';

  @override
  String get osNotificationsNote =>
      'Reminders appear here while Hayati is open. Phone/system notifications will be added with the cloud service.';

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
  String get password => 'Password';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get passwordRule =>
      'At least 8 characters, with a letter and a number';

  @override
  String get pastDay => 'This day has passed.';

  @override
  String get pauseGoal => 'Pause';

  @override
  String periodCovers(String from, String to) {
    return 'Covers $from – $to';
  }

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
  String get pin => 'Pin';

  @override
  String get planApplied => 'Plan applied';

  @override
  String get planEmptyToday => 'Nothing planned for today yet.';

  @override
  String get planFree => 'Free';

  @override
  String get planIsEstimate =>
      'This plan is an estimate based on durations and priorities. It keeps some free time for breaks and surprises.';

  @override
  String get planLabel => 'Plan';

  @override
  String get planPro => 'Hayati Pro';

  @override
  String planSummary(int done, int total) {
    return '$done of $total tasks done today';
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
  String get previous => 'Previous';

  @override
  String get previousChats => 'Previous chats';

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
      'Hayati — Privacy policy (local mode draft)\n\n1. What we collect: only what you enter — your email, a salted hash of your password, your preferences, tasks, events, goals, habits, notes, expenses and assistant chats.\n\n2. Where it\'s stored: on this device. Nothing is sent to our servers or to an AI provider in this version.\n\n3. The assistant: it runs on your device and reads only the sections you allow in assistant settings.\n\n4. Your control: you can export all your data, delete chats, and delete your account at any time.\n\n5. Support reports never include your chats, notes or expenses; technical info is added only if you choose.\n\nThis draft must be reviewed and replaced with the final policy before public launch.';

  @override
  String get privacyTitle => 'Privacy & data';

  @override
  String get problemDescription => 'What went wrong?';

  @override
  String get profileTitle => 'Profile & account';

  @override
  String get progress => 'Progress';

  @override
  String get progressManual => 'Manual progress';

  @override
  String get progressMethod => 'How is progress measured?';

  @override
  String get progressNotMeasured => 'Not measured yet';

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
  String get quickAdd => 'Quick add';

  @override
  String get reason => 'Why';

  @override
  String get reasonDeadline => 'Would finish after its deadline time';

  @override
  String get reasonNoSlot => 'No free slot is long enough';

  @override
  String get reasonNoTime => 'Not enough free time left today';

  @override
  String get regional => 'Region & time';

  @override
  String get reject => 'Reject';

  @override
  String get reminder => 'Reminder';

  @override
  String get reminderNeedsTime =>
      'Set a deadline or a planned time for the reminder.';

  @override
  String get reminderTimeOptional => 'Reminder time (optional)';

  @override
  String get removeFromPlan => 'Remove from today\'s plan';

  @override
  String get removeItem => 'Remove this change';

  @override
  String get removedFromPlan => 'Removed from this plan';

  @override
  String get reorder => 'Reorder';

  @override
  String get reorderHint => 'Drag to change the order; times are recalculated.';

  @override
  String get repeatDays => 'Days';

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
  String get resetLinkSent =>
      'If an account exists for this email, a reset link is on its way.';

  @override
  String get restBlock => 'Break';

  @override
  String get restore => 'Restore';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get resumeGoal => 'Make active';

  @override
  String get retry => 'Try again';

  @override
  String get reviewChanges => 'Review changes';

  @override
  String get reviewMyPlan => 'Review my plan';

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
  String get saveEvent => 'Save event';

  @override
  String get saveGoal => 'Save goal';

  @override
  String get saveTask => 'Save task';

  @override
  String get saved => 'Saved';

  @override
  String get saving => 'Saving…';

  @override
  String get scheduleGroup => 'When';

  @override
  String get search => 'Search';

  @override
  String get sectionsShown => 'Sections in the app';

  @override
  String get send => 'Send';

  @override
  String get sendResetLink => 'Send link';

  @override
  String get sessionLength => 'Session length';

  @override
  String get sessions => 'Sessions';

  @override
  String get sessionsLocal =>
      'Local mode has one session per device. Signing out ends it.';

  @override
  String get sessionsRemote =>
      'Signing out ends the session on this device. Changing your password signs out other devices when their session refreshes.';

  @override
  String get shareNotesSub => 'Off by default';

  @override
  String get shareSub => 'Used to plan and summarize';

  @override
  String get showActive => 'Show active';

  @override
  String get showArchived => 'Show archived';

  @override
  String get showCompleted => 'Show completed & archived';

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
  String get skip => 'Skip';

  @override
  String get spending => 'Spending';

  @override
  String get splashFailed => 'We couldn\'t start Hayati.';

  @override
  String get startDate => 'Start date';

  @override
  String get startTime => 'Starts';

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
  String stepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get stepsOptional => 'Steps to reproduce (optional)';

  @override
  String get stop => 'Stop';

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
  String get suggestedPlan => 'Suggested plan';

  @override
  String get switchToSignIn => 'Already have an account? Sign in';

  @override
  String get switchToSignUp => 'New here? Create an account';

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
      'Hayati — Terms of use (draft)\n\nHayati helps you organize your time, goals, habits, notes and expenses. Plans and suggestions are estimates, not guarantees. Hayati is not a banking, financial-advice or medical service. You are responsible for the data you enter and for decisions you make based on it.\n\nThis draft must be reviewed and replaced with the final terms before public launch.';

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
  String get thisWeek => 'This week';

  @override
  String get time => 'Time';

  @override
  String get timezone => 'Time zone';

  @override
  String get timezoneDetected =>
      'Detected from your device. Times are shown in your device\'s time zone.';

  @override
  String get timezoneDeviceNote => 'follows your device';

  @override
  String get today => 'Today';

  @override
  String get todayPlan => 'Today\'s plan';

  @override
  String get todaysHabits => 'Today\'s habits';

  @override
  String get tomorrow => 'Tomorrow';

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
  String get toolMoveTask => 'Change deadline';

  @override
  String get toolPlanTask => 'Set planned time';

  @override
  String get topPriorities => 'Top priorities';

  @override
  String get totalSpent => 'Total spent';

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
  String get upgrade => 'Upgrade';

  @override
  String usageToday(int used, int limit) {
    return '$used/$limit assistant requests today';
  }

  @override
  String get use24h => '24-hour time';

  @override
  String get verificationLocal => 'Not required in local mode';

  @override
  String get viewAll => 'View all';

  @override
  String get viewAllGoals => 'View all goals';

  @override
  String get viewCalendar => 'Calendar';

  @override
  String vsLastMonth(String amount) {
    return 'Last month: $amount';
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
  String get weekStart => 'Week starts on';

  @override
  String get welcomeBody =>
      'Your time, goals, habits, notes and spending — in one place that plans with you.';

  @override
  String get welcomeTitle => 'Organize your life, step by step';

  @override
  String get whatWeStore => 'What Hayati stores';

  @override
  String get whatWeStoreBody =>
      'Your account (email and a salted password hash), preferences, tasks, events, goals, milestones, habits and their logs, notes, expenses and budgets, assistant chats (per your retention setting) and an action log without message content. In local mode all of this stays on this device.';

  @override
  String get whatWeStoreBodyRemote =>
      'Your account (email; the password is handled by our authentication service and never stored by the app), preferences, tasks, events, goals, milestones, habits and their logs, notes, expenses and budgets are stored in your account on our servers, readable only by you (row-level security), with a copy on this device for offline use. Assistant chats currently stay on this device, per your retention setting.';

  @override
  String get whyOptional => 'Why it matters (optional)';

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
  String get yourData => 'Your data';
}
