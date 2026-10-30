import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @accAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add a commitment'**
  String get accAddRule;

  /// No description provided for @accAgree.
  ///
  /// In en, this message translates to:
  /// **'I agree to this rule, and I can edit or pause it anytime'**
  String get accAgree;

  /// No description provided for @accAgreedConsequence.
  ///
  /// In en, this message translates to:
  /// **'What you agreed to'**
  String get accAgreedConsequence;

  /// No description provided for @accAnsweredOn.
  ///
  /// In en, this message translates to:
  /// **'Answered {date}'**
  String accAnsweredOn(String date);

  /// No description provided for @accCloseTask.
  ///
  /// In en, this message translates to:
  /// **'Close the task'**
  String get accCloseTask;

  /// No description provided for @accConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get accConfirm;

  /// No description provided for @accConsequenceAsTask.
  ///
  /// In en, this message translates to:
  /// **'It will be added as a small task for today, and the task gets the new deadline below.'**
  String get accConsequenceAsTask;

  /// No description provided for @accCustomEmpty.
  ///
  /// In en, this message translates to:
  /// **'Write what you agree to do'**
  String get accCustomEmpty;

  /// No description provided for @accCustomLong.
  ///
  /// In en, this message translates to:
  /// **'Keep it under 200 characters'**
  String get accCustomLong;

  /// No description provided for @accCustomUnsafe.
  ///
  /// In en, this message translates to:
  /// **'Choose something that doesn\'t touch sleep, food, prayer, health care, or add exercise'**
  String get accCustomUnsafe;

  /// No description provided for @accDaysLate.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day late} other{{n} days late}}'**
  String accDaysLate(int n);

  /// No description provided for @accDeleteRule.
  ///
  /// In en, this message translates to:
  /// **'Delete this commitment?'**
  String get accDeleteRule;

  /// No description provided for @accDeleteRuleBody.
  ///
  /// In en, this message translates to:
  /// **'The task stays. Past records are kept without the rule.'**
  String get accDeleteRuleBody;

  /// No description provided for @accDropNote.
  ///
  /// In en, this message translates to:
  /// **'No problem. The task will be closed and its rule paused. Nothing else happens.'**
  String get accDropNote;

  /// No description provided for @accDue.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String accDue(String date);

  /// No description provided for @accEditRule.
  ///
  /// In en, this message translates to:
  /// **'Edit commitment'**
  String get accEditRule;

  /// No description provided for @accEmergencyNote.
  ///
  /// In en, this message translates to:
  /// **'Emergencies happen. No consequence — just pick a new deadline that works.'**
  String get accEmergencyNote;

  /// No description provided for @accHistory.
  ///
  /// In en, this message translates to:
  /// **'What happened before'**
  String get accHistory;

  /// No description provided for @accIllnessNote.
  ///
  /// In en, this message translates to:
  /// **'Your health comes first. No consequence — pick a new deadline when you\'re ready.'**
  String get accIllnessNote;

  /// No description provided for @accLateBy.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day past {date}} other{{n} days past {date}}}'**
  String accLateBy(int n, String date);

  /// No description provided for @accMakeupPlan.
  ///
  /// In en, this message translates to:
  /// **'Make-up plan: a new deadline'**
  String get accMakeupPlan;

  /// No description provided for @accMissedOn.
  ///
  /// In en, this message translates to:
  /// **'Was due {date}'**
  String accMissedOn(String date);

  /// No description provided for @accNeedsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Needs your answer'**
  String get accNeedsAnswer;

  /// No description provided for @accNewDeadline.
  ///
  /// In en, this message translates to:
  /// **'New deadline'**
  String get accNewDeadline;

  /// No description provided for @accNewDue.
  ///
  /// In en, this message translates to:
  /// **'New deadline {date}'**
  String accNewDue(String date);

  /// No description provided for @accNoBlame.
  ///
  /// In en, this message translates to:
  /// **'No blame. Tell us what happened and we\'ll adjust together.'**
  String get accNoBlame;

  /// No description provided for @accNoEligibleTasks.
  ///
  /// In en, this message translates to:
  /// **'Add an open task with a deadline first.'**
  String get accNoEligibleTasks;

  /// No description provided for @accNoRules.
  ///
  /// In en, this message translates to:
  /// **'No commitments yet. Add one for a task you keep putting off.'**
  String get accNoRules;

  /// No description provided for @accNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get accNote;

  /// No description provided for @accOpenTask.
  ///
  /// In en, this message translates to:
  /// **'Open the task'**
  String get accOpenTask;

  /// No description provided for @accPickTask.
  ///
  /// In en, this message translates to:
  /// **'Pick a task'**
  String get accPickTask;

  /// No description provided for @accPrinciple1.
  ///
  /// In en, this message translates to:
  /// **'You choose the consequence in advance.'**
  String get accPrinciple1;

  /// No description provided for @accPrinciple2.
  ///
  /// In en, this message translates to:
  /// **'Only a deliberate postponement brings it — never an emergency or illness.'**
  String get accPrinciple2;

  /// No description provided for @accPrinciple3.
  ///
  /// In en, this message translates to:
  /// **'Nothing is rescheduled or closed without your OK.'**
  String get accPrinciple3;

  /// No description provided for @accPrinciple4.
  ///
  /// In en, this message translates to:
  /// **'Never sleep, food, prayer, health care, or extra exercise.'**
  String get accPrinciple4;

  /// No description provided for @accRuleRemoved.
  ///
  /// In en, this message translates to:
  /// **'The rule was removed — nothing extra.'**
  String get accRuleRemoved;

  /// No description provided for @accRuleSaved.
  ///
  /// In en, this message translates to:
  /// **'Commitment saved'**
  String get accRuleSaved;

  /// No description provided for @accRuleSummary.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{After 1 day late} other{After {days} days late}}: {consequence}'**
  String accRuleSummary(int days, String consequence);

  /// No description provided for @accRules.
  ///
  /// In en, this message translates to:
  /// **'Your commitments'**
  String get accRules;

  /// No description provided for @accSafety.
  ///
  /// In en, this message translates to:
  /// **'Consequences are always harmless: they never take away sleep, food, prayer or health care, and never add exercise.'**
  String get accSafety;

  /// No description provided for @accSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. Thanks for being honest.'**
  String get accSaved;

  /// No description provided for @accTitle.
  ///
  /// In en, this message translates to:
  /// **'Commitments, kindly'**
  String get accTitle;

  /// No description provided for @accWhatHappens.
  ///
  /// In en, this message translates to:
  /// **'Then what?'**
  String get accWhatHappens;

  /// No description provided for @accWhenLate.
  ///
  /// In en, this message translates to:
  /// **'When is it late?'**
  String get accWhenLate;

  /// No description provided for @accWhichTask.
  ///
  /// In en, this message translates to:
  /// **'Which task?'**
  String get accWhichTask;

  /// No description provided for @accWhy.
  ///
  /// In en, this message translates to:
  /// **'Why was it late?'**
  String get accWhy;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @actionLog.
  ///
  /// In en, this message translates to:
  /// **'Action log'**
  String get actionLog;

  /// No description provided for @actionLogSub.
  ///
  /// In en, this message translates to:
  /// **'What the assistant changed, and when. No message content is stored here.'**
  String get actionLogSub;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @activeMinutesN.
  ///
  /// In en, this message translates to:
  /// **'{n} active minutes'**
  String activeMinutesN(int n);

  /// No description provided for @activityNote.
  ///
  /// In en, this message translates to:
  /// **'Steps come from your phone\'s health app (Health Connect or Apple Health), which already combines your phone and watch. Distance is estimated from steps and height.'**
  String get activityNote;

  /// No description provided for @activitySaved.
  ///
  /// In en, this message translates to:
  /// **'Steps saved'**
  String get activitySaved;

  /// No description provided for @activityWebNote.
  ///
  /// In en, this message translates to:
  /// **'In the browser steps can only be added by hand. Automatic counting works in the phone app.'**
  String get activityWebNote;

  /// No description provided for @addAppointment.
  ///
  /// In en, this message translates to:
  /// **'Add appointment'**
  String get addAppointment;

  /// No description provided for @addBreak.
  ///
  /// In en, this message translates to:
  /// **'Add a break'**
  String get addBreak;

  /// No description provided for @addCup.
  ///
  /// In en, this message translates to:
  /// **'Add a glass (250 ml)'**
  String get addCup;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEvent;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @addFirstGoal.
  ///
  /// In en, this message translates to:
  /// **'Add a goal'**
  String get addFirstGoal;

  /// No description provided for @addFirstTask.
  ///
  /// In en, this message translates to:
  /// **'Add your first task'**
  String get addFirstTask;

  /// No description provided for @addFood.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get addFood;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get addGoal;

  /// No description provided for @addHabit.
  ///
  /// In en, this message translates to:
  /// **'Add habit'**
  String get addHabit;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get addIncome;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add measurement'**
  String get addMeasurement;

  /// No description provided for @addMilestone.
  ///
  /// In en, this message translates to:
  /// **'Add milestone'**
  String get addMilestone;

  /// No description provided for @addMonthlyExpense.
  ///
  /// In en, this message translates to:
  /// **'Add a monthly expense'**
  String get addMonthlyExpense;

  /// No description provided for @addMonthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Add monthly income'**
  String get addMonthlyIncome;

  /// No description provided for @addMyOwnFood.
  ///
  /// In en, this message translates to:
  /// **'Add my own food'**
  String get addMyOwnFood;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @addPastPeriod.
  ///
  /// In en, this message translates to:
  /// **'Add a past period'**
  String get addPastPeriod;

  /// No description provided for @addQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add a question'**
  String get addQuestion;

  /// No description provided for @addSleep.
  ///
  /// In en, this message translates to:
  /// **'Add sleep'**
  String get addSleep;

  /// No description provided for @addStepsManually.
  ///
  /// In en, this message translates to:
  /// **'Add steps'**
  String get addStepsManually;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTask;

  /// No description provided for @addTo.
  ///
  /// In en, this message translates to:
  /// **'Add to {meal}'**
  String addTo(String meal);

  /// No description provided for @addToDay.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addToDay;

  /// No description provided for @adherence30.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get adherence30;

  /// No description provided for @affectedItems.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 item affected} other{{n} items affected}}'**
  String affectedItems(int n);

  /// No description provided for @agreePrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreePrefix;

  /// No description provided for @aiAppointmentNoTime.
  ///
  /// In en, this message translates to:
  /// **'No time given: set for 9:00, change it after'**
  String get aiAppointmentNoTime;

  /// No description provided for @aiAppointmentReady.
  ///
  /// In en, this message translates to:
  /// **'“{title}” is ready to add to your health appointments.'**
  String aiAppointmentReady(String title);

  /// No description provided for @aiAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor appointment'**
  String get aiAppointmentTitle;

  /// No description provided for @aiAppointmentWhen.
  ///
  /// In en, this message translates to:
  /// **'When is it? For example: “doctor appointment on Thursday at 10”.'**
  String get aiAppointmentWhen;

  /// No description provided for @aiAskAmPm.
  ///
  /// In en, this message translates to:
  /// **'Do you mean {hour} in the morning or in the evening?'**
  String aiAskAmPm(int hour);

  /// No description provided for @aiAutoDone.
  ///
  /// In en, this message translates to:
  /// **'Done automatically (you allowed this in assistant settings).'**
  String get aiAutoDone;

  /// No description provided for @aiChipAddTask.
  ///
  /// In en, this message translates to:
  /// **'Add a new task'**
  String get aiChipAddTask;

  /// No description provided for @aiChipFreeTime.
  ///
  /// In en, this message translates to:
  /// **'I have half an hour, what can I get done?'**
  String get aiChipFreeTime;

  /// No description provided for @aiChipLate.
  ///
  /// In en, this message translates to:
  /// **'I\'m running late, rearrange the rest of my day'**
  String get aiChipLate;

  /// No description provided for @aiChipOverdue.
  ///
  /// In en, this message translates to:
  /// **'Sort my overdue tasks'**
  String get aiChipOverdue;

  /// No description provided for @aiChipPlanDay.
  ///
  /// In en, this message translates to:
  /// **'Plan my day'**
  String get aiChipPlanDay;

  /// No description provided for @aiChipReview.
  ///
  /// In en, this message translates to:
  /// **'Review my progress this week'**
  String get aiChipReview;

  /// No description provided for @aiChipSplitGoal.
  ///
  /// In en, this message translates to:
  /// **'Help me break down my goal'**
  String get aiChipSplitGoal;

  /// No description provided for @aiConflictWith.
  ///
  /// In en, this message translates to:
  /// **'This overlaps with “{title}”.'**
  String aiConflictWith(String title);

  /// No description provided for @aiData.
  ///
  /// In en, this message translates to:
  /// **'Assistant and your data'**
  String get aiData;

  /// No description provided for @aiDataBody.
  ///
  /// In en, this message translates to:
  /// **'In this version the assistant runs entirely on your device; nothing is sent to an AI provider. When the cloud assistant is enabled, only the sections you allow will be sent to the provider through our server, to answer your request.'**
  String get aiDataBody;

  /// No description provided for @aiDisabled.
  ///
  /// In en, this message translates to:
  /// **'The assistant is turned off in assistant settings.'**
  String get aiDisabled;

  /// No description provided for @aiDraftsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Drafting plans is turned off in assistant settings, so I didn\'t prepare changes.'**
  String get aiDraftsDisabled;

  /// No description provided for @aiExample1.
  ///
  /// In en, this message translates to:
  /// **'Add a task to review English tomorrow at 8 pm'**
  String get aiExample1;

  /// No description provided for @aiExample2.
  ///
  /// In en, this message translates to:
  /// **'I want to learn English, 30 minutes every day'**
  String get aiExample2;

  /// No description provided for @aiExample3.
  ///
  /// In en, this message translates to:
  /// **'Plan my day'**
  String get aiExample3;

  /// No description provided for @aiExecFailed.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t apply that. Nothing was changed.'**
  String get aiExecFailed;

  /// No description provided for @aiFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong and I couldn\'t answer. Your message is kept — try again.'**
  String get aiFailed;

  /// No description provided for @aiFoodToday.
  ///
  /// In en, this message translates to:
  /// **'Today: about {kcal} kcal and {water} ml of water.'**
  String aiFoodToday(int kcal, int water);

  /// No description provided for @aiFreeTime.
  ///
  /// In en, this message translates to:
  /// **'You have {minutes} min. These tasks fit:'**
  String aiFreeTime(int minutes);

  /// No description provided for @aiFreeTimeItem.
  ///
  /// In en, this message translates to:
  /// **'• {title} ({minutes} min)'**
  String aiFreeTimeItem(String title, int minutes);

  /// No description provided for @aiFreeTimeNone.
  ///
  /// In en, this message translates to:
  /// **'No open task with an estimate fits {minutes} min. Try splitting a bigger task, or take a break.'**
  String aiFreeTimeNone(int minutes);

  /// No description provided for @aiGoalFirstWeekOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the first week of sessions is created; you can add more later.'**
  String get aiGoalFirstWeekOnly;

  /// No description provided for @aiGoalNoSubject.
  ///
  /// In en, this message translates to:
  /// **'What would you like to learn?'**
  String get aiGoalNoSubject;

  /// No description provided for @aiGoalReady.
  ///
  /// In en, this message translates to:
  /// **'Here\'s a plan to learn {subject}: {minutes}-minute daily sessions over {days} days, with four milestones and your first week of sessions. Nothing is created until you approve.'**
  String aiGoalReady(String subject, int minutes, int days);

  /// No description provided for @aiGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn {subject}'**
  String aiGoalTitle(String subject);

  /// No description provided for @aiGymAtHome.
  ///
  /// In en, this message translates to:
  /// **'Here\'s today\'s gym workout at home:'**
  String get aiGymAtHome;

  /// No description provided for @aiGymAtHomeHint.
  ///
  /// In en, this message translates to:
  /// **'Open Fitness and tap \"Can\'t go to the gym\" to start it.'**
  String get aiGymAtHomeHint;

  /// No description provided for @aiHabitLogged.
  ///
  /// In en, this message translates to:
  /// **'I\'ll log “{name}” as done today.'**
  String aiHabitLogged(String name);

  /// No description provided for @aiLessonSlot.
  ///
  /// In en, this message translates to:
  /// **'You have free time around {time} today for it.'**
  String aiLessonSlot(String time);

  /// No description provided for @aiLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached today\'s assistant limit. Everything else keeps working; the limit resets tomorrow.'**
  String get aiLimitReached;

  /// No description provided for @aiMs1.
  ///
  /// In en, this message translates to:
  /// **'Assess your level and pick resources for {subject}'**
  String aiMs1(String subject);

  /// No description provided for @aiMs2.
  ///
  /// In en, this message translates to:
  /// **'Learn the fundamentals of {subject}'**
  String aiMs2(String subject);

  /// No description provided for @aiMs3.
  ///
  /// In en, this message translates to:
  /// **'Practice {subject} regularly'**
  String aiMs3(String subject);

  /// No description provided for @aiMs4.
  ///
  /// In en, this message translates to:
  /// **'Complete a small project or self-test in {subject}'**
  String aiMs4(String subject);

  /// No description provided for @aiNeedsSharing.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t allowed me to read your {section}. You can change this in assistant settings.'**
  String aiNeedsSharing(String section);

  /// No description provided for @aiNextLesson.
  ///
  /// In en, this message translates to:
  /// **'Next lesson: {title} (about {minutes} min).'**
  String aiNextLesson(String title, int minutes);

  /// No description provided for @aiNoEnglishPath.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t started the English path yet. Open English to take the placement test.'**
  String get aiNoEnglishPath;

  /// No description provided for @aiNoGoalToSplit.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t find an active goal without milestones. Create a goal first or tell me what you want to learn.'**
  String get aiNoGoalToSplit;

  /// No description provided for @aiNoGymPlan.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a gym plan yet. Set one up in Fitness.'**
  String get aiNoGymPlan;

  /// No description provided for @aiNoGymToday.
  ///
  /// In en, this message translates to:
  /// **'Today isn\'t a gym day in your plan, so there\'s nothing to replace.'**
  String get aiNoGymToday;

  /// No description provided for @aiNoOverdue.
  ///
  /// In en, this message translates to:
  /// **'You have no overdue tasks. 🎉'**
  String get aiNoOverdue;

  /// No description provided for @aiNoSlotToday.
  ///
  /// In en, this message translates to:
  /// **'There\'s no free slot left today; tomorrow is fine — the path waits for you.'**
  String get aiNoSlotToday;

  /// No description provided for @aiNoStepsYet.
  ///
  /// In en, this message translates to:
  /// **'No steps recorded today yet.'**
  String get aiNoStepsYet;

  /// No description provided for @aiNoteEmpty.
  ///
  /// In en, this message translates to:
  /// **'What should the note say?'**
  String get aiNoteEmpty;

  /// No description provided for @aiNoteReady.
  ///
  /// In en, this message translates to:
  /// **'I\'ll save this note.'**
  String get aiNoteReady;

  /// No description provided for @aiOverdueSummary.
  ///
  /// In en, this message translates to:
  /// **'You have {total} overdue tasks. I can fit {today} today; {tomorrow} would move to tomorrow.'**
  String aiOverdueSummary(int total, int today, int tomorrow);

  /// No description provided for @aiPlanEstimated.
  ///
  /// In en, this message translates to:
  /// **'Some tasks have no duration; I assumed 30 minutes for them.'**
  String get aiPlanEstimated;

  /// No description provided for @aiPlanNoEvents.
  ///
  /// In en, this message translates to:
  /// **'I can\'t see your events (sharing is off), so the plan may overlap them.'**
  String get aiPlanNoEvents;

  /// No description provided for @aiPlanNothing.
  ///
  /// In en, this message translates to:
  /// **'There are no open tasks to plan for today.'**
  String get aiPlanNothing;

  /// No description provided for @aiPlanSummary.
  ///
  /// In en, this message translates to:
  /// **'Here\'s a suggested plan: {planned} tasks in your free time (about {hours} h {minutes} min available). Review it before applying.'**
  String aiPlanSummary(int planned, int hours, int minutes);

  /// No description provided for @aiPlanUnscheduled.
  ///
  /// In en, this message translates to:
  /// **'{n} tasks don\'t fit today — consider moving them or shortening them.'**
  String aiPlanUnscheduled(int n);

  /// No description provided for @aiReasonAppointment.
  ///
  /// In en, this message translates to:
  /// **'You mentioned an appointment'**
  String get aiReasonAppointment;

  /// No description provided for @aiReasonGoal.
  ///
  /// In en, this message translates to:
  /// **'You asked for a learning goal with regular practice.'**
  String get aiReasonGoal;

  /// No description provided for @aiReasonHabit.
  ///
  /// In en, this message translates to:
  /// **'You said you completed “{name}”.'**
  String aiReasonHabit(String name);

  /// No description provided for @aiReasonNote.
  ///
  /// In en, this message translates to:
  /// **'You asked to add a note.'**
  String get aiReasonNote;

  /// No description provided for @aiReasonOverdue.
  ///
  /// In en, this message translates to:
  /// **'Reschedule overdue tasks into today\'s free time, moving the rest to tomorrow.'**
  String get aiReasonOverdue;

  /// No description provided for @aiReasonPlan.
  ///
  /// In en, this message translates to:
  /// **'Distribute today\'s open tasks around fixed commitments, by priority and deadline.'**
  String get aiReasonPlan;

  /// No description provided for @aiReasonSplit.
  ///
  /// In en, this message translates to:
  /// **'Break “{title}” into clear milestones.'**
  String aiReasonSplit(String title);

  /// No description provided for @aiReasonTask.
  ///
  /// In en, this message translates to:
  /// **'You asked to add a task.'**
  String get aiReasonTask;

  /// No description provided for @aiReasonWater.
  ///
  /// In en, this message translates to:
  /// **'You asked to log water'**
  String get aiReasonWater;

  /// No description provided for @aiRefused.
  ///
  /// In en, this message translates to:
  /// **'I can\'t help with that request. Try asking in a different way.'**
  String get aiRefused;

  /// No description provided for @aiReviewFirst.
  ///
  /// In en, this message translates to:
  /// **'Start with a quick review of {n} words — it helps more than skipping ahead.'**
  String aiReviewFirst(int n);

  /// No description provided for @aiReviewGoal.
  ///
  /// In en, this message translates to:
  /// **'“{title}” is at {percent}%.'**
  String aiReviewGoal(String title, int percent);

  /// No description provided for @aiReviewHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits: {done} of {total} due check-ins logged.'**
  String aiReviewHabits(int done, int total);

  /// No description provided for @aiReviewNote.
  ///
  /// In en, this message translates to:
  /// **'These are descriptive numbers from what you recorded — not judgments about why.'**
  String get aiReviewNote;

  /// No description provided for @aiReviewOverdue.
  ///
  /// In en, this message translates to:
  /// **'{n} tasks due this week are still open past their deadline.'**
  String aiReviewOverdue(int n);

  /// No description provided for @aiReviewRate.
  ///
  /// In en, this message translates to:
  /// **'You finished {percent}% of the {total} tasks due this week.'**
  String aiReviewRate(int percent, int total);

  /// No description provided for @aiReviewTasks.
  ///
  /// In en, this message translates to:
  /// **'This week you completed {n} tasks.'**
  String aiReviewTasks(int n);

  /// No description provided for @aiSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'{subject} — session {n}'**
  String aiSessionTitle(String subject, int n);

  /// No description provided for @aiSplitReady.
  ///
  /// In en, this message translates to:
  /// **'Here\'s a suggested breakdown for “{title}”.'**
  String aiSplitReady(String title);

  /// No description provided for @aiStepsGoalMet.
  ///
  /// In en, this message translates to:
  /// **'{steps} steps today: your goal of {goal} is reached.'**
  String aiStepsGoalMet(int steps, int goal);

  /// No description provided for @aiStepsToday.
  ///
  /// In en, this message translates to:
  /// **'{steps} steps today, {left} to your goal of {goal}.'**
  String aiStepsToday(int steps, int goal, int left);

  /// No description provided for @aiTaskNoTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s the task? For example: “Add task review English tomorrow at 8 pm”.'**
  String get aiTaskNoTitle;

  /// No description provided for @aiTaskReady.
  ///
  /// In en, this message translates to:
  /// **'I\'ll create the task “{title}”.'**
  String aiTaskReady(String title);

  /// No description provided for @aiTimeInPast.
  ///
  /// In en, this message translates to:
  /// **'That time has already passed.'**
  String get aiTimeInPast;

  /// No description provided for @aiUnsupported.
  ///
  /// In en, this message translates to:
  /// **'I can\'t do that yet. I can plan your day, sort overdue tasks, add tasks or notes, log habits, break a goal into milestones, or review your week.'**
  String get aiUnsupported;

  /// No description provided for @aiWaterLogged.
  ///
  /// In en, this message translates to:
  /// **'Logging {ml} ml of water for today.'**
  String aiWaterLogged(int ml);

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @allDoneToday.
  ///
  /// In en, this message translates to:
  /// **'You\'ve finished everything planned for today.'**
  String get allDoneToday;

  /// No description provided for @allMilestonesDone.
  ///
  /// In en, this message translates to:
  /// **'All milestones are done. Mark the goal as completed?'**
  String get allMilestonesDone;

  /// No description provided for @allTasks.
  ///
  /// In en, this message translates to:
  /// **'All tasks'**
  String get allTasks;

  /// No description provided for @alreadyExecuted.
  ///
  /// In en, this message translates to:
  /// **'Already applied — nothing was repeated.'**
  String get alreadyExecuted;

  /// No description provided for @alternatives.
  ///
  /// In en, this message translates to:
  /// **'Alternatives'**
  String get alternatives;

  /// No description provided for @alwaysRequired.
  ///
  /// In en, this message translates to:
  /// **'Always required — cannot be turned off'**
  String get alwaysRequired;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @andMore.
  ///
  /// In en, this message translates to:
  /// **'and {n} more'**
  String andMore(int n);

  /// No description provided for @answerRight.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get answerRight;

  /// No description provided for @answerWrong.
  ///
  /// In en, this message translates to:
  /// **'The right answer: {answer}'**
  String answerWrong(String answer);

  /// No description provided for @any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// No description provided for @apCheckup.
  ///
  /// In en, this message translates to:
  /// **'Checkup'**
  String get apCheckup;

  /// No description provided for @apFollowup.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get apFollowup;

  /// No description provided for @apOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get apOther;

  /// No description provided for @apTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get apTest;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Hayati'**
  String get appName;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @applyPlan.
  ///
  /// In en, this message translates to:
  /// **'Apply plan'**
  String get applyPlan;

  /// No description provided for @applyPlanBody.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 task will get a planned time:} other{{n} tasks will get planned times:}}'**
  String applyPlanBody(int n);

  /// No description provided for @appointmentReminderNote.
  ///
  /// In en, this message translates to:
  /// **'The reminder says “Health appointment” and the time only, not the title.'**
  String get appointmentReminderNote;

  /// No description provided for @appointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'What is it for?'**
  String get appointmentTitle;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Health appointments'**
  String get appointments;

  /// No description provided for @appointmentsSub.
  ///
  /// In en, this message translates to:
  /// **'Checkups, tests and questions for the doctor'**
  String get appointmentsSub;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Always ask before'**
  String get approvals;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @approveBulk.
  ///
  /// In en, this message translates to:
  /// **'Changes to several items at once'**
  String get approveBulk;

  /// No description provided for @approveDelete.
  ///
  /// In en, this message translates to:
  /// **'Deleting anything'**
  String get approveDelete;

  /// No description provided for @approveReschedule.
  ///
  /// In en, this message translates to:
  /// **'Changing a time or deadline'**
  String get approveReschedule;

  /// No description provided for @approveRescheduleSub.
  ///
  /// In en, this message translates to:
  /// **'Recommended. Applies to single changes only.'**
  String get approveRescheduleSub;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @approx.
  ///
  /// In en, this message translates to:
  /// **'approx.'**
  String get approx;

  /// No description provided for @approximateSwap.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to} (approximate)'**
  String approximateSwap(String from, String to);

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @archiveGoal.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveGoal;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @archivedNotes.
  ///
  /// In en, this message translates to:
  /// **'Archived notes'**
  String get archivedNotes;

  /// No description provided for @articleDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'General information, not a diagnosis or treatment. Contact a doctor about your own health, and emergency services if it\'s urgent.'**
  String get articleDisclaimer;

  /// No description provided for @articleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This article isn\'t in your health sections.'**
  String get articleUnavailable;

  /// No description provided for @askAssistantReplan.
  ///
  /// In en, this message translates to:
  /// **'Ask the assistant to rearrange my day'**
  String get askAssistantReplan;

  /// No description provided for @askAssistantReview.
  ///
  /// In en, this message translates to:
  /// **'Ask the assistant'**
  String get askAssistantReview;

  /// No description provided for @askHayati.
  ///
  /// In en, this message translates to:
  /// **'Ask Hayati'**
  String get askHayati;

  /// No description provided for @assistantDisabled.
  ///
  /// In en, this message translates to:
  /// **'The assistant is turned off'**
  String get assistantDisabled;

  /// No description provided for @assistantDisabledBody.
  ///
  /// In en, this message translates to:
  /// **'Everything else in Hayati keeps working. Turn it on in settings any time.'**
  String get assistantDisabledBody;

  /// No description provided for @assistantHint.
  ///
  /// In en, this message translates to:
  /// **'Ask me to plan, add or review…'**
  String get assistantHint;

  /// No description provided for @assistantIntroBody.
  ///
  /// In en, this message translates to:
  /// **'I work with your own tasks, events and goals. I prepare changes; you decide what gets applied.'**
  String get assistantIntroBody;

  /// No description provided for @assistantIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'How can I help today?'**
  String get assistantIntroTitle;

  /// No description provided for @assistantSettings.
  ///
  /// In en, this message translates to:
  /// **'Assistant settings'**
  String get assistantSettings;

  /// No description provided for @assistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I help you organize your time and goals'**
  String get assistantSubtitle;

  /// No description provided for @assistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Hayati assistant'**
  String get assistantTitle;

  /// No description provided for @assistantUsage.
  ///
  /// In en, this message translates to:
  /// **'Assistant today: {used} of {limit}'**
  String assistantUsage(int used, int limit);

  /// No description provided for @atTime.
  ///
  /// In en, this message translates to:
  /// **'At the time'**
  String get atTime;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get auto;

  /// No description provided for @autoActions.
  ///
  /// In en, this message translates to:
  /// **'May do without asking'**
  String get autoActions;

  /// No description provided for @autoActionsSub.
  ///
  /// In en, this message translates to:
  /// **'Each permission is separate and can be withdrawn at any time.'**
  String get autoActionsSub;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @averageCycle.
  ///
  /// In en, this message translates to:
  /// **'Average cycle'**
  String get averageCycle;

  /// No description provided for @averagePeriod.
  ///
  /// In en, this message translates to:
  /// **'Average period'**
  String get averagePeriod;

  /// No description provided for @avgKcalPerDay.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal a day on average'**
  String avgKcalPerDay(String kcal);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @backToPath.
  ///
  /// In en, this message translates to:
  /// **'Back to the path'**
  String get backToPath;

  /// No description provided for @barcodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'A barcode is 6 to 14 digits'**
  String get barcodeInvalid;

  /// No description provided for @barcodeN.
  ///
  /// In en, this message translates to:
  /// **'Barcode {code}'**
  String barcodeN(String code);

  /// No description provided for @barcodeNumber.
  ///
  /// In en, this message translates to:
  /// **'Barcode number'**
  String get barcodeNumber;

  /// No description provided for @bedTime.
  ///
  /// In en, this message translates to:
  /// **'I go to sleep at'**
  String get bedTime;

  /// No description provided for @bedTimeHint.
  ///
  /// In en, this message translates to:
  /// **'A bedtime after midnight counts as the same night. Outside these hours nothing counts as free time.'**
  String get bedTimeHint;

  /// No description provided for @bedtimeReminder.
  ///
  /// In en, this message translates to:
  /// **'Bedtime reminder'**
  String get bedtimeReminder;

  /// No description provided for @bedtimeReminderSub.
  ///
  /// In en, this message translates to:
  /// **'A nudge to start winding down'**
  String get bedtimeReminderSub;

  /// No description provided for @beforeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{duration} before'**
  String beforeMinutes(String duration);

  /// No description provided for @benefit1Body.
  ///
  /// In en, this message translates to:
  /// **'Fits tasks around your fixed commitments and leaves room to breathe.'**
  String get benefit1Body;

  /// No description provided for @benefit1Title.
  ///
  /// In en, this message translates to:
  /// **'A realistic daily plan'**
  String get benefit1Title;

  /// No description provided for @benefit2Body.
  ///
  /// In en, this message translates to:
  /// **'Progress updates from what you actually complete.'**
  String get benefit2Body;

  /// No description provided for @benefit2Title.
  ///
  /// In en, this message translates to:
  /// **'Goals that move forward'**
  String get benefit2Title;

  /// No description provided for @benefit3Body.
  ///
  /// In en, this message translates to:
  /// **'Suggests and prepares; sensitive changes always wait for your approval.'**
  String get benefit3Body;

  /// No description provided for @benefit3Title.
  ///
  /// In en, this message translates to:
  /// **'An assistant you control'**
  String get benefit3Title;

  /// No description provided for @bestDay.
  ///
  /// In en, this message translates to:
  /// **'Best day'**
  String get bestDay;

  /// No description provided for @bestLabel.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get bestLabel;

  /// No description provided for @billingNote.
  ///
  /// In en, this message translates to:
  /// **'Paid features are only enabled after your purchase is verified by our server through the app store.'**
  String get billingNote;

  /// No description provided for @bodyweight.
  ///
  /// In en, this message translates to:
  /// **'Body weight'**
  String get bodyweight;

  /// No description provided for @bpSeeDoctor.
  ///
  /// In en, this message translates to:
  /// **'Your last three blood pressure readings average 140/90 or higher. That\'s worth checking with a doctor.'**
  String get bpSeeDoctor;

  /// No description provided for @bpUrgent.
  ///
  /// In en, this message translates to:
  /// **'Your last reading is 180/120 or higher. If you have chest pain, shortness of breath, a severe headache or changes in vision, get urgent help now. Otherwise rest a few minutes, measure again, and contact a doctor today.'**
  String get bpUrgent;

  /// No description provided for @bpmN.
  ///
  /// In en, this message translates to:
  /// **'{n} bpm'**
  String bpmN(int n);

  /// No description provided for @breakEnd.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get breakEnd;

  /// No description provided for @breakStart.
  ///
  /// In en, this message translates to:
  /// **'Break from'**
  String get breakStart;

  /// No description provided for @breaksTitle.
  ///
  /// In en, this message translates to:
  /// **'Breaks'**
  String get breaksTitle;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @budgetUsed.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {cap}'**
  String budgetUsed(String spent, String cap);

  /// No description provided for @builtinNote.
  ///
  /// In en, this message translates to:
  /// **'Values are typical estimates for one portion; home recipes and sizes vary. Change the amount, or save your own version.'**
  String get builtinNote;

  /// No description provided for @busyTime.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get busyTime;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @byMilestones.
  ///
  /// In en, this message translates to:
  /// **'By milestones'**
  String get byMilestones;

  /// No description provided for @byMilestonesHint.
  ///
  /// In en, this message translates to:
  /// **'Progress = completed milestones ÷ all milestones. A milestone completes when you check it or when all its tasks are done.'**
  String get byMilestonesHint;

  /// No description provided for @byMonth.
  ///
  /// In en, this message translates to:
  /// **'By month'**
  String get byMonth;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get calories;

  /// No description provided for @caloriesByDay.
  ///
  /// In en, this message translates to:
  /// **'Calories by day'**
  String get caloriesByDay;

  /// No description provided for @caloriesToday.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get caloriesToday;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The camera isn\'t available. Type the number below.'**
  String get cameraUnavailable;

  /// No description provided for @canMoveCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 task doesn\'t fit today and can move without hurting your goals} other{{n} tasks don\'t fit today and can move without hurting your goals}}'**
  String canMoveCount(int n);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cantGoToGym.
  ///
  /// In en, this message translates to:
  /// **'Can\'t go to the gym'**
  String get cantGoToGym;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @carbsG.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get carbsG;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get catLearning;

  /// No description provided for @catMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get catMoney;

  /// No description provided for @catPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get catPersonal;

  /// No description provided for @catWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get catWork;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categoryOptional.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get categoryOptional;

  /// No description provided for @cefrA1.
  ///
  /// In en, this message translates to:
  /// **'A1 · Beginner'**
  String get cefrA1;

  /// No description provided for @cefrA2.
  ///
  /// In en, this message translates to:
  /// **'A2 · Elementary'**
  String get cefrA2;

  /// No description provided for @cefrB1.
  ///
  /// In en, this message translates to:
  /// **'B1 · Intermediate'**
  String get cefrB1;

  /// No description provided for @cefrB2.
  ///
  /// In en, this message translates to:
  /// **'B2 · Upper intermediate'**
  String get cefrB2;

  /// No description provided for @changeDown.
  ///
  /// In en, this message translates to:
  /// **'{pct}% less'**
  String changeDown(int pct);

  /// No description provided for @changeIn30Days.
  ///
  /// In en, this message translates to:
  /// **'{change} in 30 days'**
  String changeIn30Days(String change);

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changeSalary.
  ///
  /// In en, this message translates to:
  /// **'Change salary'**
  String get changeSalary;

  /// No description provided for @changeSame.
  ///
  /// In en, this message translates to:
  /// **'Same as last month'**
  String get changeSame;

  /// No description provided for @changeUp.
  ///
  /// In en, this message translates to:
  /// **'{pct}% more'**
  String changeUp(int pct);

  /// No description provided for @changesCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 change} other{{n} changes}}'**
  String changesCount(int n);

  /// No description provided for @chartCurrencyNote.
  ///
  /// In en, this message translates to:
  /// **'Amounts in {currency} only'**
  String chartCurrencyNote(String currency);

  /// No description provided for @chartNeedsData.
  ///
  /// In en, this message translates to:
  /// **'The chart shows once two months have records.'**
  String get chartNeedsData;

  /// No description provided for @checkAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get checkAnswer;

  /// No description provided for @checkFields.
  ///
  /// In en, this message translates to:
  /// **'Check the fields'**
  String get checkFields;

  /// No description provided for @checkinScale.
  ///
  /// In en, this message translates to:
  /// **'1 is the lowest, 5 the highest. Saved as you tap.'**
  String get checkinScale;

  /// No description provided for @checkinWeek.
  ///
  /// In en, this message translates to:
  /// **'This week: energy {energy}, recovery {recovery} on average'**
  String checkinWeek(String energy, String recovery);

  /// No description provided for @clashItem.
  ///
  /// In en, this message translates to:
  /// **'“{a}” and “{b}” at {time}'**
  String clashItem(String a, String b, String time);

  /// No description provided for @clashSave.
  ///
  /// In en, this message translates to:
  /// **'This time clashes with {what}. Save anyway?'**
  String clashSave(String what);

  /// No description provided for @clashSleep.
  ///
  /// In en, this message translates to:
  /// **'your sleep time'**
  String get clashSleep;

  /// No description provided for @clashesTitle.
  ///
  /// In en, this message translates to:
  /// **'Clashes'**
  String get clashesTitle;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearLog.
  ///
  /// In en, this message translates to:
  /// **'Clear log'**
  String get clearLog;

  /// No description provided for @clearRead.
  ///
  /// In en, this message translates to:
  /// **'Clear read notifications'**
  String get clearRead;

  /// No description provided for @clearanceConfirm.
  ///
  /// In en, this message translates to:
  /// **'My doctor has said exercise is fine for me'**
  String get clearanceConfirm;

  /// No description provided for @clearancePostpartum.
  ///
  /// In en, this message translates to:
  /// **'After giving birth — and especially after a caesarean or a difficult delivery — start only once your doctor says it\'s fine. The early-weeks program is gentle; the gradual return is for after your postnatal check.'**
  String get clearancePostpartum;

  /// No description provided for @clearancePregnancy.
  ///
  /// In en, this message translates to:
  /// **'Exercise in pregnancy is usually safe and helpful, but some pregnancies need limits. Please confirm your doctor has said it\'s fine for you.'**
  String get clearancePregnancy;

  /// No description provided for @clearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Your doctor\'s go-ahead first'**
  String get clearanceTitle;

  /// No description provided for @cloudModeNotice.
  ///
  /// In en, this message translates to:
  /// **'Your data is saved to your account and kept on this device for offline use.'**
  String get cloudModeNotice;

  /// No description provided for @cmN.
  ///
  /// In en, this message translates to:
  /// **'{v} cm'**
  String cmN(String v);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @commonSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms you log most'**
  String get commonSymptoms;

  /// No description provided for @compareLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Compared with last month'**
  String get compareLastMonth;

  /// No description provided for @completedAndArchived.
  ///
  /// In en, this message translates to:
  /// **'Completed & archived'**
  String get completedAndArchived;

  /// No description provided for @completedPerDay.
  ///
  /// In en, this message translates to:
  /// **'Completed per day'**
  String get completedPerDay;

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion rate'**
  String get completionRate;

  /// No description provided for @completionRateDef.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} due in period (cancelled excluded)'**
  String completionRateDef(int done, int total);

  /// No description provided for @conCustom.
  ///
  /// In en, this message translates to:
  /// **'Something of my own'**
  String get conCustom;

  /// No description provided for @conCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Your own harmless wording.'**
  String get conCustomHint;

  /// No description provided for @conExtraReview.
  ///
  /// In en, this message translates to:
  /// **'An extra review session'**
  String get conExtraReview;

  /// No description provided for @conExtraReviewHint.
  ///
  /// In en, this message translates to:
  /// **'20 minutes to look at what\'s blocking the task.'**
  String get conExtraReviewHint;

  /// No description provided for @conFirstStep.
  ///
  /// In en, this message translates to:
  /// **'First step before leisure'**
  String get conFirstStep;

  /// No description provided for @conFirstStepHint.
  ///
  /// In en, this message translates to:
  /// **'Do a 15-minute first step before optional leisure time.'**
  String get conFirstStepHint;

  /// No description provided for @conPlanning.
  ///
  /// In en, this message translates to:
  /// **'A short planning session'**
  String get conPlanning;

  /// No description provided for @conPlanningHint.
  ///
  /// In en, this message translates to:
  /// **'15 minutes to break the task into small steps.'**
  String get conPlanningHint;

  /// No description provided for @conTaskFirstStep.
  ///
  /// In en, this message translates to:
  /// **'First step: {task}'**
  String conTaskFirstStep(String task);

  /// No description provided for @conTaskPlanning.
  ///
  /// In en, this message translates to:
  /// **'Plan the steps: {task}'**
  String conTaskPlanning(String task);

  /// No description provided for @conTaskReview.
  ///
  /// In en, this message translates to:
  /// **'Review what\'s blocking: {task}'**
  String conTaskReview(String task);

  /// No description provided for @confirmEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Account created. We sent a confirmation link to your email — open it, then sign in.'**
  String get confirmEmailSent;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @conflict.
  ///
  /// In en, this message translates to:
  /// **'Conflict'**
  String get conflict;

  /// No description provided for @conflictKeep.
  ///
  /// In en, this message translates to:
  /// **'This time overlaps with “{title}”. Keep it anyway?'**
  String conflictKeep(String title);

  /// No description provided for @conflictWith.
  ///
  /// In en, this message translates to:
  /// **'Overlaps with “{title}”'**
  String conflictWith(String title);

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @connectInDevices.
  ///
  /// In en, this message translates to:
  /// **'Connect in Devices and sources'**
  String get connectInDevices;

  /// No description provided for @connectStepsBody.
  ///
  /// In en, this message translates to:
  /// **'Hayati reads your daily step total from {store}. It only reads steps and never writes anything.'**
  String connectStepsBody(String store);

  /// No description provided for @connectStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Count steps automatically from {store}'**
  String connectStepsTitle(String store);

  /// No description provided for @connectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to {store}'**
  String connectedTo(String store);

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @couldNotFit.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t fit'**
  String get couldNotFit;

  /// No description provided for @courseComplete.
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed the B2 course!'**
  String get courseComplete;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @createFirstPlan.
  ///
  /// In en, this message translates to:
  /// **'Create my first plan'**
  String get createFirstPlan;

  /// No description provided for @createMyPlan.
  ///
  /// In en, this message translates to:
  /// **'Create my plan'**
  String get createMyPlan;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currencyChangeNote.
  ///
  /// In en, this message translates to:
  /// **'Existing expenses keep their original currency.'**
  String get currencyChangeNote;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get currentPlan;

  /// No description provided for @currentSalary.
  ///
  /// In en, this message translates to:
  /// **'Current salary'**
  String get currentSalary;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom dates'**
  String get customRange;

  /// No description provided for @cycleDayN.
  ///
  /// In en, this message translates to:
  /// **'Day {n} of your cycle'**
  String cycleDayN(int n);

  /// No description provided for @cycleDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Estimates from what you recorded, not medical advice and not a way to prevent or plan pregnancy.'**
  String get cycleDisclaimer;

  /// No description provided for @cycleInsights.
  ///
  /// In en, this message translates to:
  /// **'Cycle insights'**
  String get cycleInsights;

  /// No description provided for @cycleLengthOverTime.
  ///
  /// In en, this message translates to:
  /// **'Cycle length over time'**
  String get cycleLengthOverTime;

  /// No description provided for @cycleLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Keep cycle data on this phone only'**
  String get cycleLocalOnly;

  /// No description provided for @cycleLocalOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'Your periods and day logs are removed from your account and stay on this phone. If you delete the app or change phones, they are gone.'**
  String get cycleLocalOnlyBody;

  /// No description provided for @cycleLocalOnlyOff.
  ///
  /// In en, this message translates to:
  /// **'Off: saved to your account, so it appears on your phone, iPhone and the web.'**
  String get cycleLocalOnlyOff;

  /// No description provided for @cycleLocalOnlyOn.
  ///
  /// In en, this message translates to:
  /// **'On: it isn\'t saved to your account and doesn\'t appear on your other devices.'**
  String get cycleLocalOnlyOn;

  /// No description provided for @cycleLocalOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep it on this phone only?'**
  String get cycleLocalOnlyTitle;

  /// No description provided for @cycleRange.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get cycleRange;

  /// No description provided for @cycleReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminder before the next period'**
  String get cycleReminders;

  /// No description provided for @cycleRemindersSub.
  ///
  /// In en, this message translates to:
  /// **'Two days before the estimated window. It only says “Hayati reminder”.'**
  String get cycleRemindersSub;

  /// No description provided for @cycleStartBody.
  ///
  /// In en, this message translates to:
  /// **'Tap “It started today” on the first day of your period, or add past ones below.'**
  String get cycleStartBody;

  /// No description provided for @cycleStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your cycle'**
  String get cycleStartTitle;

  /// No description provided for @cycleSyncBody.
  ///
  /// In en, this message translates to:
  /// **'What this phone holds is uploaded to your account and appears on your other devices.'**
  String get cycleSyncBody;

  /// No description provided for @cycleSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Save it to your account?'**
  String get cycleSyncTitle;

  /// No description provided for @cyclesCounted.
  ///
  /// In en, this message translates to:
  /// **'Cycles counted'**
  String get cyclesCounted;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// No description provided for @dataAccess.
  ///
  /// In en, this message translates to:
  /// **'What the assistant can read'**
  String get dataAccess;

  /// No description provided for @dataAccessSub.
  ///
  /// In en, this message translates to:
  /// **'Only enabled sections are used to answer you.'**
  String get dataAccessSub;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @dayEnd.
  ///
  /// In en, this message translates to:
  /// **'Day ends'**
  String get dayEnd;

  /// No description provided for @dayFits.
  ///
  /// In en, this message translates to:
  /// **'Tasks due fit in the free time.'**
  String get dayFits;

  /// No description provided for @dayFreeLeft.
  ///
  /// In en, this message translates to:
  /// **'{free} free'**
  String dayFreeLeft(String free);

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of the month'**
  String get dayOfMonth;

  /// No description provided for @dayOfMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of each month'**
  String dayOfMonthLabel(int day);

  /// No description provided for @dayOverview.
  ///
  /// In en, this message translates to:
  /// **'Your day in hours'**
  String get dayOverview;

  /// No description provided for @daySchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s schedule'**
  String get daySchedule;

  /// No description provided for @dayScheduleDone.
  ///
  /// In en, this message translates to:
  /// **'Today\'s schedule is done'**
  String get dayScheduleDone;

  /// No description provided for @dayStart.
  ///
  /// In en, this message translates to:
  /// **'Day starts'**
  String get dayStart;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day} other{{n} days}}'**
  String daysCount(int n);

  /// No description provided for @daysLoggedN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{No days logged} =1{1 day logged} other{{n} days logged}}'**
  String daysLoggedN(int n);

  /// No description provided for @daysN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day} other{{n} days}}'**
  String daysN(int n);

  /// No description provided for @daysRange.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} days'**
  String daysRange(int min, int max);

  /// No description provided for @deadlineDate.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadlineDate;

  /// No description provided for @deadlineTime.
  ///
  /// In en, this message translates to:
  /// **'Deadline time'**
  String get deadlineTime;

  /// No description provided for @deadlineVsPlanned.
  ///
  /// In en, this message translates to:
  /// **'Deadline = when it must be done. Planned time = when you intend to work on it.'**
  String get deadlineVsPlanned;

  /// No description provided for @defaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get defaultCurrency;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConsequences.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and everything in it from this device: tasks, events, goals, habits, notes, expenses and assistant chats. This can\'t be undone. Consider exporting your data first (Privacy & data).'**
  String get deleteAccountConsequences;

  /// No description provided for @deleteAccountConsequencesRemote.
  ///
  /// In en, this message translates to:
  /// **'This requests permanent deletion of your account and everything in it: tasks, events, goals, habits, notes, expenses and assistant chats. You\'ll be signed out now and this device\'s copy will be removed; the server removes the rest per our retention policy. This can\'t be undone. Consider exporting your data first.'**
  String get deleteAccountConsequencesRemote;

  /// No description provided for @deleteAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account and data'**
  String get deleteAccountSub;

  /// No description provided for @deleteAllChats.
  ///
  /// In en, this message translates to:
  /// **'Delete all chats'**
  String get deleteAllChats;

  /// No description provided for @deleteAllChatsBody.
  ///
  /// In en, this message translates to:
  /// **'All conversations and pending suggestions will be deleted. Applied changes stay.'**
  String get deleteAllChatsBody;

  /// No description provided for @deleteAppointmentBody.
  ///
  /// In en, this message translates to:
  /// **'Its notes and questions go too.'**
  String get deleteAppointmentBody;

  /// No description provided for @deleteAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this appointment?'**
  String get deleteAppointmentTitle;

  /// No description provided for @deleteChatBody.
  ///
  /// In en, this message translates to:
  /// **'This chat and its pending suggestions will be deleted. Changes you already applied stay.'**
  String get deleteChatBody;

  /// No description provided for @deleteChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete chat?'**
  String get deleteChatTitle;

  /// No description provided for @deleteConfirmWord.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteConfirmWord;

  /// No description provided for @deleteDataRequest.
  ///
  /// In en, this message translates to:
  /// **'Delete my data'**
  String get deleteDataRequest;

  /// No description provided for @deleteDataRequestSub.
  ///
  /// In en, this message translates to:
  /// **'Done by deleting your account'**
  String get deleteDataRequestSub;

  /// No description provided for @deleteEventBody.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be permanently deleted.'**
  String deleteEventBody(String title);

  /// No description provided for @deleteEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete event?'**
  String get deleteEventTitle;

  /// No description provided for @deleteExpenseBody.
  ///
  /// In en, this message translates to:
  /// **'This expense will be deleted.'**
  String get deleteExpenseBody;

  /// No description provided for @deleteExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete expense?'**
  String get deleteExpenseTitle;

  /// No description provided for @deleteFood.
  ///
  /// In en, this message translates to:
  /// **'Delete this food?'**
  String get deleteFood;

  /// No description provided for @deleteFoodBody.
  ///
  /// In en, this message translates to:
  /// **'Meals already logged with it stay as they are.'**
  String get deleteFoodBody;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteForever;

  /// No description provided for @deleteGoalBody.
  ///
  /// In en, this message translates to:
  /// **'The goal and its milestones will be deleted. Linked tasks are kept and unlinked.'**
  String get deleteGoalBody;

  /// No description provided for @deleteGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete goal?'**
  String get deleteGoalTitle;

  /// No description provided for @deleteHabitBody.
  ///
  /// In en, this message translates to:
  /// **'The habit and its whole history will be deleted. You can make it inactive instead.'**
  String get deleteHabitBody;

  /// No description provided for @deleteHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete habit?'**
  String get deleteHabitTitle;

  /// No description provided for @deleteHealthData.
  ///
  /// In en, this message translates to:
  /// **'Delete health data'**
  String get deleteHealthData;

  /// No description provided for @deleteHealthDataBody.
  ///
  /// In en, this message translates to:
  /// **'Steps, sleep, heart rate, workouts from your watch, food, water, cycle and appointments are removed from all your devices. This can\'t be undone.'**
  String get deleteHealthDataBody;

  /// No description provided for @deleteHealthDataSub.
  ///
  /// In en, this message translates to:
  /// **'Only the health sections; the rest of your account stays'**
  String get deleteHealthDataSub;

  /// No description provided for @deleteHealthDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all health data?'**
  String get deleteHealthDataTitle;

  /// No description provided for @deleteIncomeBody.
  ///
  /// In en, this message translates to:
  /// **'It will no longer count in your totals.'**
  String get deleteIncomeBody;

  /// No description provided for @deleteIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this income?'**
  String get deleteIncomeTitle;

  /// No description provided for @deleteMonthlyBody.
  ///
  /// In en, this message translates to:
  /// **'Months already recorded stay in your records.'**
  String get deleteMonthlyBody;

  /// No description provided for @deleteMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this monthly item?'**
  String get deleteMonthlyTitle;

  /// No description provided for @deleteNoteBody.
  ///
  /// In en, this message translates to:
  /// **'This note will be permanently deleted. You can archive it instead.'**
  String get deleteNoteBody;

  /// No description provided for @deleteNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get deleteNoteTitle;

  /// No description provided for @deletePeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Estimates will be worked out again without it.'**
  String get deletePeriodBody;

  /// No description provided for @deletePeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this period?'**
  String get deletePeriodTitle;

  /// No description provided for @deleteSalaryBody.
  ///
  /// In en, this message translates to:
  /// **'The months it covered will use the salary before it.'**
  String get deleteSalaryBody;

  /// No description provided for @deleteSalaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this salary change?'**
  String get deleteSalaryTitle;

  /// No description provided for @deleteTaskBody.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be permanently deleted. You can archive it instead.'**
  String deleteTaskBody(String title);

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task?'**
  String get deleteTaskTitle;

  /// No description provided for @deleteWorkoutBody.
  ///
  /// In en, this message translates to:
  /// **'Its logged sets will be removed.'**
  String get deleteWorkoutBody;

  /// No description provided for @deleteWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this workout?'**
  String get deleteWorkoutTitle;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @deletionRequested.
  ///
  /// In en, this message translates to:
  /// **'Deletion requested. Your account and data will be removed from our servers.'**
  String get deletionRequested;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @devNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Get reminders even when Hayati is closed.'**
  String get devNotifBody;

  /// No description provided for @devNotifBodyWeb.
  ///
  /// In en, this message translates to:
  /// **'Show reminders as browser notifications while Hayati is open.'**
  String get devNotifBodyWeb;

  /// No description provided for @devNotifDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. To get reminders, allow them for Hayati in your device or browser settings.'**
  String get devNotifDenied;

  /// No description provided for @devNotifEnable.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get devNotifEnable;

  /// No description provided for @devNotifOn.
  ///
  /// In en, this message translates to:
  /// **'On — reminders arrive even when Hayati is closed (sometimes a few minutes late).'**
  String get devNotifOn;

  /// No description provided for @devNotifOnWeb.
  ///
  /// In en, this message translates to:
  /// **'On — browsers show reminders only while Hayati is open.'**
  String get devNotifOnWeb;

  /// No description provided for @devNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone notifications'**
  String get devNotifTitle;

  /// No description provided for @devicesPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Hayati only reads, never writes, and only what you turn on. The numbers are saved to your account so your other devices see them.'**
  String get devicesPrivacy;

  /// No description provided for @devicesStoreBody.
  ///
  /// In en, this message translates to:
  /// **'This phone reads from {store}, which gathers what your watch, scale and apps record. Choose what to bring in.'**
  String devicesStoreBody(String store);

  /// No description provided for @devicesSub.
  ///
  /// In en, this message translates to:
  /// **'Watch, sleep, heart rate and where each number comes from'**
  String get devicesSub;

  /// No description provided for @devicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Devices and sources'**
  String get devicesTitle;

  /// No description provided for @devicesWebBody.
  ///
  /// In en, this message translates to:
  /// **'Connecting happens in the Hayati phone app: it reads from Health Connect on Android or Apple Health on iPhone. What it brings in shows here too.'**
  String get devicesWebBody;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Lower (diastolic)'**
  String get diastolic;

  /// No description provided for @didYouEat.
  ///
  /// In en, this message translates to:
  /// **'Is it one of these?'**
  String get didYouEat;

  /// No description provided for @diffEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get diffEasy;

  /// No description provided for @diffHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get diffHard;

  /// No description provided for @diffMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get diffMedium;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @discardMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Leave without saving?'**
  String get discardMessage;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardTitle;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @disconnectBody.
  ///
  /// In en, this message translates to:
  /// **'This phone stops reading. What it already brought in stays; you can remove it under the source.'**
  String get disconnectBody;

  /// No description provided for @disconnectThisPhone.
  ///
  /// In en, this message translates to:
  /// **'Stop reading on this phone'**
  String get disconnectThisPhone;

  /// No description provided for @disconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop reading from {store}?'**
  String disconnectTitle(String store);

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @displayNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Your name (optional)'**
  String get displayNameOptional;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String distanceKm(String km);

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @doneDays.
  ///
  /// In en, this message translates to:
  /// **'Done / due'**
  String get doneDays;

  /// No description provided for @drEmergency.
  ///
  /// In en, this message translates to:
  /// **'An emergency'**
  String get drEmergency;

  /// No description provided for @drIllness.
  ///
  /// In en, this message translates to:
  /// **'I was ill'**
  String get drIllness;

  /// No description provided for @drNotImportant.
  ///
  /// In en, this message translates to:
  /// **'It\'s no longer important'**
  String get drNotImportant;

  /// No description provided for @drPostponed.
  ///
  /// In en, this message translates to:
  /// **'I put it off on purpose'**
  String get drPostponed;

  /// No description provided for @dragHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press and drag a task onto an hour to plan it.'**
  String get dragHint;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @dueNeeds.
  ///
  /// In en, this message translates to:
  /// **'Tasks due need {need}; only {free} is free.'**
  String dueNeeds(String need, String free);

  /// No description provided for @dueShort.
  ///
  /// In en, this message translates to:
  /// **'due'**
  String get dueShort;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editAppointment.
  ///
  /// In en, this message translates to:
  /// **'Edit appointment'**
  String get editAppointment;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEvent;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpense;

  /// No description provided for @editFood.
  ///
  /// In en, this message translates to:
  /// **'Edit food'**
  String get editFood;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get editGoal;

  /// No description provided for @editHabit.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get editHabit;

  /// No description provided for @editIncome.
  ///
  /// In en, this message translates to:
  /// **'Edit income'**
  String get editIncome;

  /// No description provided for @editMilestone.
  ///
  /// In en, this message translates to:
  /// **'Edit milestone'**
  String get editMilestone;

  /// No description provided for @editPlan.
  ///
  /// In en, this message translates to:
  /// **'Change plan'**
  String get editPlan;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @effectiveFrom.
  ///
  /// In en, this message translates to:
  /// **'Starts from'**
  String get effectiveFrom;

  /// No description provided for @effort.
  ///
  /// In en, this message translates to:
  /// **'{n, select, 1{easy} 2{fairly easy} 3{moderate} 4{hard} other{very hard}}'**
  String effort(String n);

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified yet'**
  String get emailNotVerified;

  /// No description provided for @emailPassword.
  ///
  /// In en, this message translates to:
  /// **'Email and password'**
  String get emailPassword;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email verification'**
  String get emailVerification;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get emailVerified;

  /// No description provided for @emptyAll.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet.'**
  String get emptyAll;

  /// No description provided for @emptyArchived.
  ///
  /// In en, this message translates to:
  /// **'Nothing archived.'**
  String get emptyArchived;

  /// No description provided for @emptyCompleted.
  ///
  /// In en, this message translates to:
  /// **'No completed tasks yet.'**
  String get emptyCompleted;

  /// No description provided for @emptyOverdue.
  ///
  /// In en, this message translates to:
  /// **'Nothing overdue.'**
  String get emptyOverdue;

  /// No description provided for @emptyToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing due today. Add a task or plan ahead.'**
  String get emptyToday;

  /// No description provided for @emptyTodayDone.
  ///
  /// In en, this message translates to:
  /// **'All of today\'s tasks are done. Nice work!'**
  String get emptyTodayDone;

  /// No description provided for @emptyUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No upcoming tasks with a deadline.'**
  String get emptyUpcoming;

  /// No description provided for @enableAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get enableAssistant;

  /// No description provided for @enableAssistantSub.
  ///
  /// In en, this message translates to:
  /// **'Turning it off doesn\'t affect tasks, calendar or anything else.'**
  String get enableAssistantSub;

  /// No description provided for @endDateOptional.
  ///
  /// In en, this message translates to:
  /// **'End date (optional)'**
  String get endDateOptional;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endTime;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @energyN.
  ///
  /// In en, this message translates to:
  /// **'Energy {n}/5'**
  String energyN(int n);

  /// No description provided for @energySplit.
  ///
  /// In en, this message translates to:
  /// **'Where the energy came from (daily average)'**
  String get energySplit;

  /// No description provided for @englishIntroBody.
  ///
  /// In en, this message translates to:
  /// **'A short placement test finds your level in vocabulary, grammar and reading, then you get a lesson a day and reviews of what you learned.'**
  String get englishIntroBody;

  /// No description provided for @englishIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'English, step by step'**
  String get englishIntroTitle;

  /// No description provided for @englishLessonItem.
  ///
  /// In en, this message translates to:
  /// **'English: {title}'**
  String englishLessonItem(String title);

  /// No description provided for @eoAccepted.
  ///
  /// In en, this message translates to:
  /// **'Consequence accepted'**
  String get eoAccepted;

  /// No description provided for @eoDropped.
  ///
  /// In en, this message translates to:
  /// **'Task closed'**
  String get eoDropped;

  /// No description provided for @eoPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get eoPending;

  /// No description provided for @eoRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled'**
  String get eoRescheduled;

  /// No description provided for @eqBands.
  ///
  /// In en, this message translates to:
  /// **'Resistance bands'**
  String get eqBands;

  /// No description provided for @eqBench.
  ///
  /// In en, this message translates to:
  /// **'Bench'**
  String get eqBench;

  /// No description provided for @eqDumbbells.
  ///
  /// In en, this message translates to:
  /// **'Dumbbells'**
  String get eqDumbbells;

  /// No description provided for @eqKettlebell.
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get eqKettlebell;

  /// No description provided for @eqPullupBar.
  ///
  /// In en, this message translates to:
  /// **'Pull-up bar'**
  String get eqPullupBar;

  /// No description provided for @errAgree.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms and privacy policy'**
  String get errAgree;

  /// No description provided for @errCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect'**
  String get errCredentials;

  /// No description provided for @errCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get errCurrentPassword;

  /// No description provided for @errEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get errEmail;

  /// No description provided for @errEmailExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists'**
  String get errEmailExists;

  /// No description provided for @errEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email first using the link we sent.'**
  String get errEmailNotConfirmed;

  /// No description provided for @errEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after the start time'**
  String get errEndBeforeStart;

  /// No description provided for @errEndDateBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The end date is before the start'**
  String get errEndDateBeforeStart;

  /// No description provided for @errFutureIncome.
  ///
  /// In en, this message translates to:
  /// **'Income can\'t be dated in the future'**
  String get errFutureIncome;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connection problem. Please try again.'**
  String get errNetwork;

  /// No description provided for @errPasswordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get errPasswordMatch;

  /// No description provided for @errPasswordWeak.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters and include a letter and a number'**
  String get errPasswordWeak;

  /// No description provided for @errPickDays.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day'**
  String get errPickDays;

  /// No description provided for @errPositiveAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get errPositiveAmount;

  /// No description provided for @errPositiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'Enter minutes between 1 and 1440'**
  String get errPositiveMinutes;

  /// No description provided for @errRange.
  ///
  /// In en, this message translates to:
  /// **'Between 0 and {max}'**
  String errRange(int max);

  /// No description provided for @errRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a little and try again.'**
  String get errRateLimited;

  /// No description provided for @errRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errRequired;

  /// No description provided for @errSave.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Check the fields and try again.'**
  String get errSave;

  /// No description provided for @errSex.
  ///
  /// In en, this message translates to:
  /// **'Choose male or female'**
  String get errSex;

  /// No description provided for @errTargetBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'Target date must be after the start date'**
  String get errTargetBeforeStart;

  /// No description provided for @estimateNote.
  ///
  /// In en, this message translates to:
  /// **'An estimate — portions and recipes vary.'**
  String get estimateNote;

  /// No description provided for @estimatedDuration.
  ///
  /// In en, this message translates to:
  /// **'Estimated 30 min'**
  String get estimatedDuration;

  /// No description provided for @estimatedMinutes.
  ///
  /// In en, this message translates to:
  /// **'Estimated duration (minutes)'**
  String get estimatedMinutes;

  /// No description provided for @estimatedPill.
  ///
  /// In en, this message translates to:
  /// **'Estimated length'**
  String get estimatedPill;

  /// No description provided for @estimatedWindow.
  ///
  /// In en, this message translates to:
  /// **'Estimated window: {from} – {to}'**
  String estimatedWindow(String from, String to);

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event title'**
  String get eventTitle;

  /// No description provided for @eventsLabel.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsLabel;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @everyMinutes.
  ///
  /// In en, this message translates to:
  /// **'Every {m} min'**
  String everyMinutes(int m);

  /// No description provided for @examples.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get examples;

  /// No description provided for @execute.
  ///
  /// In en, this message translates to:
  /// **'Apply changes'**
  String get execute;

  /// No description provided for @executedCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Done — 1 change applied} other{Done — {n} changes applied}}'**
  String executedCount(int n);

  /// No description provided for @exerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 exercise} other{{n} exercises}}'**
  String exerciseCount(int n);

  /// No description provided for @expBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get expBills;

  /// No description provided for @expEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get expEducation;

  /// No description provided for @expEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get expEntertainment;

  /// No description provided for @expFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get expFood;

  /// No description provided for @expOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expOther;

  /// No description provided for @expShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get expShopping;

  /// No description provided for @expTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get expTransport;

  /// No description provided for @expectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get expectedLabel;

  /// No description provided for @expenseList.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenseList;

  /// No description provided for @expensesManualNote.
  ///
  /// In en, this message translates to:
  /// **'Expenses are entered manually. No bank accounts are linked.'**
  String get expensesManualNote;

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @exportCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied ({chars} characters)'**
  String exportCopied(int chars);

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get exportData;

  /// No description provided for @exportDataSub.
  ///
  /// In en, this message translates to:
  /// **'Copies all your data as JSON to the clipboard'**
  String get exportDataSub;

  /// No description provided for @exportHealthData.
  ///
  /// In en, this message translates to:
  /// **'Export health data'**
  String get exportHealthData;

  /// No description provided for @exportHealthDataSub.
  ///
  /// In en, this message translates to:
  /// **'Steps, sleep, food, cycle and appointments, copied as JSON'**
  String get exportHealthDataSub;

  /// No description provided for @extraLesson.
  ///
  /// In en, this message translates to:
  /// **'Extra lesson'**
  String get extraLesson;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faq;

  /// No description provided for @faq1a.
  ///
  /// In en, this message translates to:
  /// **'The deadline is when a task must be finished. Planned time is when you intend to work on it — the planner sets it, and you can change it.'**
  String get faq1a;

  /// No description provided for @faq1q.
  ///
  /// In en, this message translates to:
  /// **'What\'s the difference between a deadline and planned time?'**
  String get faq1q;

  /// No description provided for @faq2a.
  ///
  /// In en, this message translates to:
  /// **'Each goal uses one method: completed milestones ÷ all milestones, or a percentage you set manually. A goal is never marked complete just because its date passed.'**
  String get faq2a;

  /// No description provided for @faq2q.
  ///
  /// In en, this message translates to:
  /// **'How is goal progress calculated?'**
  String get faq2q;

  /// No description provided for @faq3a.
  ///
  /// In en, this message translates to:
  /// **'Only what you allow in assistant settings — e.g. creating a single task. Deleting, bulk changes and rescheduling many items always need your approval.'**
  String get faq3a;

  /// No description provided for @faq3q.
  ///
  /// In en, this message translates to:
  /// **'What can the assistant do on its own?'**
  String get faq3q;

  /// No description provided for @faq4a.
  ///
  /// In en, this message translates to:
  /// **'Turn on phone notifications from the Notifications screen or Settings, and give the task a reminder plus a deadline or planned time. On phones, reminders arrive even when the app is closed (sometimes a few minutes late); in a browser they only appear while Hayati is open.'**
  String get faq4a;

  /// No description provided for @faq4q.
  ///
  /// In en, this message translates to:
  /// **'I\'m not getting reminders'**
  String get faq4q;

  /// No description provided for @faq5a.
  ///
  /// In en, this message translates to:
  /// **'In local mode, on this device only. You can export it any time from Privacy & data.'**
  String get faq5a;

  /// No description provided for @faq5aRemote.
  ///
  /// In en, this message translates to:
  /// **'In your account on our servers, protected so only you can read it, with a copy on this device for offline use. You can export it any time from Privacy & data.'**
  String get faq5aRemote;

  /// No description provided for @faq5q.
  ///
  /// In en, this message translates to:
  /// **'Where is my data stored?'**
  String get faq5q;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @fatG.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get fatG;

  /// No description provided for @fatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get fatigue;

  /// No description provided for @featAdvancedReports.
  ///
  /// In en, this message translates to:
  /// **'Detailed reports and insights'**
  String get featAdvancedReports;

  /// No description provided for @featAssistantLimited.
  ///
  /// In en, this message translates to:
  /// **'Assistant: up to {limit} requests a day'**
  String featAssistantLimited(int limit);

  /// No description provided for @featBasicReports.
  ///
  /// In en, this message translates to:
  /// **'Basic weekly reports'**
  String get featBasicReports;

  /// No description provided for @featCore.
  ///
  /// In en, this message translates to:
  /// **'Tasks, calendar, goals, habits, notes and expenses'**
  String get featCore;

  /// No description provided for @featMoreAssistant.
  ///
  /// In en, this message translates to:
  /// **'More assistant usage'**
  String get featMoreAssistant;

  /// No description provided for @featSmartPlanning.
  ///
  /// In en, this message translates to:
  /// **'Advanced smart planning'**
  String get featSmartPlanning;

  /// No description provided for @featTemplates.
  ///
  /// In en, this message translates to:
  /// **'Goal templates'**
  String get featTemplates;

  /// No description provided for @feltLike.
  ///
  /// In en, this message translates to:
  /// **'felt {effort}'**
  String feltLike(String effort);

  /// No description provided for @fgDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get fgDairy;

  /// No description provided for @fgDishes.
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get fgDishes;

  /// No description provided for @fgDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get fgDrinks;

  /// No description provided for @fgExtras.
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get fgExtras;

  /// No description provided for @fgFatLoss.
  ///
  /// In en, this message translates to:
  /// **'Lose fat'**
  String get fgFatLoss;

  /// No description provided for @fgFatLossHint.
  ///
  /// In en, this message translates to:
  /// **'Strength work plus cardio. Food matters most; the app gives no diet advice.'**
  String get fgFatLossHint;

  /// No description provided for @fgFruit.
  ///
  /// In en, this message translates to:
  /// **'Fruit'**
  String get fgFruit;

  /// No description provided for @fgGeneral.
  ///
  /// In en, this message translates to:
  /// **'General fitness'**
  String get fgGeneral;

  /// No description provided for @fgGeneralHint.
  ///
  /// In en, this message translates to:
  /// **'Balanced strength, cardio and movement.'**
  String get fgGeneralHint;

  /// No description provided for @fgGrains.
  ///
  /// In en, this message translates to:
  /// **'Bread and grains'**
  String get fgGrains;

  /// No description provided for @fgMobility.
  ///
  /// In en, this message translates to:
  /// **'Mobility and moving better'**
  String get fgMobility;

  /// No description provided for @fgMobilityHint.
  ///
  /// In en, this message translates to:
  /// **'Gentle sessions for flexibility, posture and recovery.'**
  String get fgMobilityHint;

  /// No description provided for @fgMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get fgMuscle;

  /// No description provided for @fgMuscleHint.
  ///
  /// In en, this message translates to:
  /// **'Moderate reps and enough weekly volume for each muscle.'**
  String get fgMuscleHint;

  /// No description provided for @fgProtein.
  ///
  /// In en, this message translates to:
  /// **'Meat, fish and eggs'**
  String get fgProtein;

  /// No description provided for @fgSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks and sweets'**
  String get fgSnacks;

  /// No description provided for @fgStrength.
  ///
  /// In en, this message translates to:
  /// **'Get stronger'**
  String get fgStrength;

  /// No description provided for @fgStrengthHint.
  ///
  /// In en, this message translates to:
  /// **'Fewer reps, longer rest, steady progress on key lifts.'**
  String get fgStrengthHint;

  /// No description provided for @fgVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get fgVegetables;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get filterArchived;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @filterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get filterOverdue;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// No description provided for @filterUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get filterUpcoming;

  /// No description provided for @filteredTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get filteredTotal;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get finishSetup;

  /// No description provided for @finishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish workout'**
  String get finishWorkout;

  /// No description provided for @fitnessIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Answer a few questions and get a plan for home, the gym, or both — with alternatives when equipment is missing.'**
  String get fitnessIntroBody;

  /// No description provided for @fitnessIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Training that fits your week'**
  String get fitnessIntroTitle;

  /// No description provided for @fitnessSafety.
  ///
  /// In en, this message translates to:
  /// **'Hayati gives general exercise guidance, not medical advice. If you have an injury or health condition, check with a professional first, and stop if something hurts.'**
  String get fitnessSafety;

  /// No description provided for @fitnessSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Your training plan'**
  String get fitnessSetupTitle;

  /// No description provided for @fixedBlocks.
  ///
  /// In en, this message translates to:
  /// **'Fixed blocks'**
  String get fixedBlocks;

  /// No description provided for @fixedCommitments.
  ///
  /// In en, this message translates to:
  /// **'Fixed commitments'**
  String get fixedCommitments;

  /// No description provided for @flAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get flAdvanced;

  /// No description provided for @flBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get flBeginner;

  /// No description provided for @flIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get flIntermediate;

  /// No description provided for @flow.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get flow;

  /// No description provided for @flowHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get flowHeavy;

  /// No description provided for @flowLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get flowLight;

  /// No description provided for @flowMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get flowMedium;

  /// No description provided for @flowNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get flowNone;

  /// No description provided for @focusConditioning.
  ///
  /// In en, this message translates to:
  /// **'Conditioning'**
  String get focusConditioning;

  /// No description provided for @focusFullBody.
  ///
  /// In en, this message translates to:
  /// **'Full body'**
  String get focusFullBody;

  /// No description provided for @focusLower.
  ///
  /// In en, this message translates to:
  /// **'Lower body'**
  String get focusLower;

  /// No description provided for @focusMobility.
  ///
  /// In en, this message translates to:
  /// **'Mobility and recovery'**
  String get focusMobility;

  /// No description provided for @focusUpper.
  ///
  /// In en, this message translates to:
  /// **'Upper body'**
  String get focusUpper;

  /// No description provided for @foodAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {name}'**
  String foodAdded(String name);

  /// No description provided for @foodAndWater.
  ///
  /// In en, this message translates to:
  /// **'Food and water'**
  String get foodAndWater;

  /// No description provided for @foodName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get foodName;

  /// No description provided for @foodNoneYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged today'**
  String get foodNoneYet;

  /// No description provided for @foodRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get foodRemoved;

  /// No description provided for @foodSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to your foods'**
  String get foodSaved;

  /// No description provided for @forgotLocalMode.
  ///
  /// In en, this message translates to:
  /// **'In this version, accounts are stored on this device only, so password reset by email isn\'t available yet. It will be enabled once the cloud account service is connected.'**
  String get forgotLocalMode;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotRemoteBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to set a new password.'**
  String get forgotRemoteBody;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover access'**
  String get forgotTitle;

  /// No description provided for @freeSlotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Free times'**
  String get freeSlotsTitle;

  /// No description provided for @freeTime.
  ///
  /// In en, this message translates to:
  /// **'Free time'**
  String get freeTime;

  /// No description provided for @freeTimeNow.
  ///
  /// In en, this message translates to:
  /// **'Free time'**
  String get freeTimeNow;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'From gallery'**
  String get fromGallery;

  /// No description provided for @fromYourDevices.
  ///
  /// In en, this message translates to:
  /// **'From your watch and apps'**
  String get fromYourDevices;

  /// No description provided for @fsDays.
  ///
  /// In en, this message translates to:
  /// **'Days per week'**
  String get fsDays;

  /// No description provided for @fsEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment at home'**
  String get fsEquipment;

  /// No description provided for @fsEquipmentHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for body-weight only.'**
  String get fsEquipmentHint;

  /// No description provided for @fsGoal.
  ///
  /// In en, this message translates to:
  /// **'What\'s your main goal?'**
  String get fsGoal;

  /// No description provided for @fsLevel.
  ///
  /// In en, this message translates to:
  /// **'Your experience'**
  String get fsLevel;

  /// No description provided for @fsMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes per session'**
  String get fsMinutes;

  /// No description provided for @fsPickDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Pick 1 more day} other{Pick {n} more days}}'**
  String fsPickDays(int n);

  /// No description provided for @fsPlaces.
  ///
  /// In en, this message translates to:
  /// **'Where will you train?'**
  String get fsPlaces;

  /// No description provided for @fsPlacesHint.
  ///
  /// In en, this message translates to:
  /// **'Choose both to get two plans and switch between them any day.'**
  String get fsPlacesHint;

  /// No description provided for @fsWhichDays.
  ///
  /// In en, this message translates to:
  /// **'Pick {n} days'**
  String fsWhichDays(int n);

  /// No description provided for @futureDay.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get futureDay;

  /// No description provided for @futureDayBody.
  ///
  /// In en, this message translates to:
  /// **'Days can be logged once they come.'**
  String get futureDayBody;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @goBackOver.
  ///
  /// In en, this message translates to:
  /// **'Go back over these lessons:'**
  String get goBackOver;

  /// No description provided for @goalActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get goalActive;

  /// No description provided for @goalArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get goalArchived;

  /// No description provided for @goalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get goalCompleted;

  /// No description provided for @goalDays.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get goalDays;

  /// No description provided for @goalPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get goalPaused;

  /// No description provided for @goalStepHint.
  ///
  /// In en, this message translates to:
  /// **'Choose an example or write your own. You can skip this.'**
  String get goalStepHint;

  /// No description provided for @goalStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get goalStreak;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal title'**
  String get goalTitle;

  /// No description provided for @goalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Learn Flutter basics'**
  String get goalTitleHint;

  /// No description provided for @goalsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'A goal can have milestones and linked tasks. Progress follows what you complete.'**
  String get goalsEmptyBody;

  /// No description provided for @goalsProgress.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsProgress;

  /// No description provided for @goalsSummary.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsSummary;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @gramsN.
  ///
  /// In en, this message translates to:
  /// **'{g} g'**
  String gramsN(String g);

  /// No description provided for @gramsOptional.
  ///
  /// In en, this message translates to:
  /// **'Grams (optional)'**
  String get gramsOptional;

  /// No description provided for @habitAdherence.
  ///
  /// In en, this message translates to:
  /// **'Habit check-ins'**
  String get habitAdherence;

  /// No description provided for @habitAdherenceDef.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} due days (non-due days excluded)'**
  String habitAdherenceDef(int done, int total);

  /// No description provided for @habitDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get habitDone;

  /// No description provided for @habitDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get habitDoneToday;

  /// No description provided for @habitDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get habitDueToday;

  /// No description provided for @habitName.
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get habitName;

  /// No description provided for @habitNotDueToday.
  ///
  /// In en, this message translates to:
  /// **'Not due today'**
  String get habitNotDueToday;

  /// No description provided for @habitsDoneOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} logged today'**
  String habitsDoneOf(int done, int total);

  /// No description provided for @habitsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a habit and choose which days it\'s expected. Days it isn\'t due never count against you.'**
  String get habitsEmptyBody;

  /// No description provided for @hanafiAsr.
  ///
  /// In en, this message translates to:
  /// **'Hanafi Asr'**
  String get hanafiAsr;

  /// No description provided for @hanafiAsrHint.
  ///
  /// In en, this message translates to:
  /// **'Later Asr time (shadow twice an object\'s length).'**
  String get hanafiAsrHint;

  /// No description provided for @hasBreak.
  ///
  /// In en, this message translates to:
  /// **'Add a daily break'**
  String get hasBreak;

  /// No description provided for @hasWorkHours.
  ///
  /// In en, this message translates to:
  /// **'I have fixed work or study hours'**
  String get hasWorkHours;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'I have an account'**
  String get haveAccount;

  /// No description provided for @healthDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Health data deleted'**
  String get healthDataDeleted;

  /// No description provided for @healthDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Your health data'**
  String get healthDataTitle;

  /// No description provided for @healthLearn.
  ///
  /// In en, this message translates to:
  /// **'Health reading'**
  String get healthLearn;

  /// No description provided for @healthLearnSub.
  ///
  /// In en, this message translates to:
  /// **'Short articles from public health sources'**
  String get healthLearnSub;

  /// No description provided for @healthLock.
  ///
  /// In en, this message translates to:
  /// **'Lock with fingerprint or passcode'**
  String get healthLock;

  /// No description provided for @healthLockSub.
  ///
  /// In en, this message translates to:
  /// **'Health sections open only after your phone\'s unlock. Locks again when you leave the app.'**
  String get healthLockSub;

  /// No description provided for @healthLockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available here: set up a screen lock on your phone first. On the web your account password protects it.'**
  String get healthLockUnavailable;

  /// No description provided for @healthLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get healthLocked;

  /// No description provided for @healthLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock with your fingerprint, face or phone passcode.'**
  String get healthLockedBody;

  /// No description provided for @healthPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission wasn\'t given. You can allow it from the health app\'s settings.'**
  String get healthPermissionDenied;

  /// No description provided for @healthPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Health privacy'**
  String get healthPrivacy;

  /// No description provided for @healthPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Cycle data is never shared with the assistant, and its reminders never say what they\'re about. Women\'s health shows only on accounts registered as female.'**
  String get healthPrivacyNote;

  /// No description provided for @healthPrivacySub.
  ///
  /// In en, this message translates to:
  /// **'Lock, home screen, reminders, export and delete'**
  String get healthPrivacySub;

  /// No description provided for @healthSections.
  ///
  /// In en, this message translates to:
  /// **'Health sections'**
  String get healthSections;

  /// No description provided for @healthSectionsNote.
  ///
  /// In en, this message translates to:
  /// **'Sections marked “coming soon” are saved now and appear when they\'re ready.'**
  String get healthSectionsNote;

  /// No description provided for @healthSetup.
  ///
  /// In en, this message translates to:
  /// **'Health setup'**
  String get healthSetup;

  /// No description provided for @healthSharing.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthSharing;

  /// No description provided for @healthSharingSub.
  ///
  /// In en, this message translates to:
  /// **'Summaries only. Measurements and the cycle are off until you turn them on.'**
  String get healthSharingSub;

  /// No description provided for @healthThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthThisPeriod;

  /// No description provided for @heartDaysN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{heart rate on 1 day} other{heart rate on {n} days}}'**
  String heartDaysN(int n);

  /// No description provided for @heartNote.
  ///
  /// In en, this message translates to:
  /// **'Your watch\'s reading, for your own record. It isn\'t a medical test.'**
  String get heartNote;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @heightForDistance.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightForDistance;

  /// No description provided for @heightHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional — makes the distance estimate closer'**
  String get heightHelp;

  /// No description provided for @heightInvalid.
  ///
  /// In en, this message translates to:
  /// **'Between 80 and 250 cm'**
  String get heightInvalid;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpTitle;

  /// No description provided for @hideFromHome.
  ///
  /// In en, this message translates to:
  /// **'Hide from the home screen'**
  String get hideFromHome;

  /// No description provided for @hideFromHomeSub.
  ///
  /// In en, this message translates to:
  /// **'Women\'s health won\'t appear on “My day”.'**
  String get hideFromHomeSub;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get highlights;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @historyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a past day to correct it. Days the habit isn\'t due are neutral.'**
  String get historyHint;

  /// No description provided for @hkBody.
  ///
  /// In en, this message translates to:
  /// **'Weight and blood pressure'**
  String get hkBody;

  /// No description provided for @hkBodySub.
  ///
  /// In en, this message translates to:
  /// **'Readings from a smart scale or blood pressure monitor'**
  String get hkBodySub;

  /// No description provided for @hkHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Resting heart rate'**
  String get hkHeartRate;

  /// No description provided for @hkHeartRateSub.
  ///
  /// In en, this message translates to:
  /// **'One value a day, as your watch measures it'**
  String get hkHeartRateSub;

  /// No description provided for @hkSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get hkSleep;

  /// No description provided for @hkSleepSub.
  ///
  /// In en, this message translates to:
  /// **'When you slept and for how long'**
  String get hkSleepSub;

  /// No description provided for @hkSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get hkSteps;

  /// No description provided for @hkStepsSub.
  ///
  /// In en, this message translates to:
  /// **'Daily total, from the phone and any watch'**
  String get hkStepsSub;

  /// No description provided for @hkWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get hkWorkouts;

  /// No description provided for @hkWorkoutsSub.
  ///
  /// In en, this message translates to:
  /// **'Runs, walks, swims and other sessions your watch recorded'**
  String get hkWorkoutsSub;

  /// No description provided for @hmActivity.
  ///
  /// In en, this message translates to:
  /// **'Steps and activity'**
  String get hmActivity;

  /// No description provided for @hmMens.
  ///
  /// In en, this message translates to:
  /// **'Men\'s health'**
  String get hmMens;

  /// No description provided for @hmNutrition.
  ///
  /// In en, this message translates to:
  /// **'Food and calories'**
  String get hmNutrition;

  /// No description provided for @hmSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep and recovery'**
  String get hmSleep;

  /// No description provided for @hmWomens.
  ///
  /// In en, this message translates to:
  /// **'Women\'s health'**
  String get hmWomens;

  /// No description provided for @homeInstead.
  ///
  /// In en, this message translates to:
  /// **'At home instead'**
  String get homeInstead;

  /// No description provided for @homeSections.
  ///
  /// In en, this message translates to:
  /// **'Home screen'**
  String get homeSections;

  /// No description provided for @homeVersionBody.
  ///
  /// In en, this message translates to:
  /// **'Exercises are swapped for ones you can do with your home equipment. Not every exercise has an exact match.'**
  String get homeVersionBody;

  /// No description provided for @homeVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s gym workout, at home'**
  String get homeVersionTitle;

  /// No description provided for @homeViewGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get homeViewGoals;

  /// No description provided for @homeViewToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeViewToday;

  /// No description provided for @homeViewWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get homeViewWeek;

  /// No description provided for @howDidItFeel.
  ///
  /// In en, this message translates to:
  /// **'How did it feel? (optional)'**
  String get howDidItFeel;

  /// No description provided for @howIsToday.
  ///
  /// In en, this message translates to:
  /// **'How\'s today?'**
  String get howIsToday;

  /// No description provided for @howIsTodaySub.
  ///
  /// In en, this message translates to:
  /// **'Flow, pain, symptoms, mood, energy'**
  String get howIsTodaySub;

  /// No description provided for @howMuch.
  ///
  /// In en, this message translates to:
  /// **'How much?'**
  String get howMuch;

  /// No description provided for @howRested.
  ///
  /// In en, this message translates to:
  /// **'How do you feel today?'**
  String get howRested;

  /// No description provided for @howTo.
  ///
  /// In en, this message translates to:
  /// **'How to do it'**
  String get howTo;

  /// No description provided for @inDuration.
  ///
  /// In en, this message translates to:
  /// **'in {duration}'**
  String inDuration(String duration);

  /// No description provided for @inactiveHabits.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveHabits;

  /// No description provided for @includeTechInfo.
  ///
  /// In en, this message translates to:
  /// **'Include technical info'**
  String get includeTechInfo;

  /// No description provided for @incomeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed salary'**
  String get incomeFixed;

  /// No description provided for @incomeKindExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra'**
  String get incomeKindExtra;

  /// No description provided for @incomeKindPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get incomeKindPay;

  /// No description provided for @incomeSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get incomeSource;

  /// No description provided for @incomeSourceHint.
  ///
  /// In en, this message translates to:
  /// **'For example: freelance, rent'**
  String get incomeSourceHint;

  /// No description provided for @incomeType.
  ///
  /// In en, this message translates to:
  /// **'Income type'**
  String get incomeType;

  /// No description provided for @incomeVariable.
  ///
  /// In en, this message translates to:
  /// **'Variable'**
  String get incomeVariable;

  /// No description provided for @incomeVariableSub.
  ///
  /// In en, this message translates to:
  /// **'Record each amount when you receive it.'**
  String get incomeVariableSub;

  /// No description provided for @initialTasks.
  ///
  /// In en, this message translates to:
  /// **'First tasks'**
  String get initialTasks;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @installHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Install Health Connect'**
  String get installHealthConnect;

  /// No description provided for @installHealthConnectBody.
  ///
  /// In en, this message translates to:
  /// **'Android keeps steps from your phone and watch in Health Connect. Install or update it, then come back and connect.'**
  String get installHealthConnectBody;

  /// No description provided for @interestsHint.
  ///
  /// In en, this message translates to:
  /// **'Pick any — you can change this later. Sections you don\'t pick are hidden, not deleted.'**
  String get interestsHint;

  /// No description provided for @irregularNote.
  ///
  /// In en, this message translates to:
  /// **'Your recorded cycles vary a lot, or some are unusually short or long. This alone doesn\'t mean anything is wrong, but it\'s worth mentioning to a doctor.'**
  String get irregularNote;

  /// No description provided for @itemGone.
  ///
  /// In en, this message translates to:
  /// **'This item no longer exists.'**
  String get itemGone;

  /// No description provided for @kcalGoalOn.
  ///
  /// In en, this message translates to:
  /// **'Daily calorie target'**
  String get kcalGoalOn;

  /// No description provided for @kcalGoalSub.
  ///
  /// In en, this message translates to:
  /// **'Optional. Set your own number; the app doesn\'t suggest one.'**
  String get kcalGoalSub;

  /// No description provided for @kcalN.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal'**
  String kcalN(String kcal);

  /// No description provided for @kcalOfGoal.
  ///
  /// In en, this message translates to:
  /// **'{kcal} / {goal} kcal'**
  String kcalOfGoal(String kcal, String goal);

  /// No description provided for @keepAnyway.
  ///
  /// In en, this message translates to:
  /// **'Keep anyway'**
  String get keepAnyway;

  /// No description provided for @keepChats.
  ///
  /// In en, this message translates to:
  /// **'Keep chats for'**
  String get keepChats;

  /// No description provided for @kgN.
  ///
  /// In en, this message translates to:
  /// **'{v} kg'**
  String kgN(String v);

  /// No description provided for @kgTimesReps.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg × {reps}'**
  String kgTimesReps(String kg, int reps);

  /// No description provided for @kindAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get kindAssistant;

  /// No description provided for @kindBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get kindBug;

  /// No description provided for @kindNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get kindNotifications;

  /// No description provided for @kindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get kindOther;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @lastLabel.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get lastLabel;

  /// No description provided for @lastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get lastSevenDays;

  /// No description provided for @lastSyncAt.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String lastSyncAt(String time);

  /// No description provided for @lastTwoWeeks.
  ///
  /// In en, this message translates to:
  /// **'Last two weeks'**
  String get lastTwoWeeks;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get lastWeek;

  /// No description provided for @latestOn.
  ///
  /// In en, this message translates to:
  /// **'Latest: {date}'**
  String latestOn(String date);

  /// No description provided for @learnIntro.
  ///
  /// In en, this message translates to:
  /// **'Short, general reading from public health organisations. It isn\'t advice for you personally; a doctor can tell you what applies to you.'**
  String get learnIntro;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @leaveTestBody.
  ///
  /// In en, this message translates to:
  /// **'Your answers so far will be lost.'**
  String get leaveTestBody;

  /// No description provided for @leaveTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave the test?'**
  String get leaveTestTitle;

  /// No description provided for @leaveWithoutSaving.
  ///
  /// In en, this message translates to:
  /// **'Leave without saving'**
  String get leaveWithoutSaving;

  /// No description provided for @legendEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get legendEstimated;

  /// No description provided for @legendLogged.
  ///
  /// In en, this message translates to:
  /// **'Day logged'**
  String get legendLogged;

  /// No description provided for @legendPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get legendPeriod;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @lessonAgain.
  ///
  /// In en, this message translates to:
  /// **'Not mastered yet (80% needed). We\'ll repeat this lesson before moving on.'**
  String get lessonAgain;

  /// No description provided for @lessonDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s English lesson is done'**
  String get lessonDoneToday;

  /// No description provided for @lessonMastered.
  ///
  /// In en, this message translates to:
  /// **'Lesson mastered. On to the next!'**
  String get lessonMastered;

  /// No description provided for @lessonMinutes.
  ///
  /// In en, this message translates to:
  /// **'About {n} minutes'**
  String lessonMinutes(int n);

  /// No description provided for @levelCheckBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve mastered every lesson at this level. Take the level check to move up.'**
  String get levelCheckBody;

  /// No description provided for @levelCheckIntro.
  ///
  /// In en, this message translates to:
  /// **'Questions from this level. You need 75% to move up; otherwise we\'ll point you to lessons to revisit.'**
  String get levelCheckIntro;

  /// No description provided for @levelCheckReady.
  ///
  /// In en, this message translates to:
  /// **'Level check ready'**
  String get levelCheckReady;

  /// No description provided for @levelCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Level check: {level}'**
  String levelCheckTitle(String level);

  /// No description provided for @levelComplete.
  ///
  /// In en, this message translates to:
  /// **'{level} lessons complete'**
  String levelComplete(String level);

  /// No description provided for @levelLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons: {level}'**
  String levelLessons(String level);

  /// No description provided for @levelNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet: {level}'**
  String levelNotYet(String level);

  /// No description provided for @levelPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed: {level}'**
  String levelPassed(String level);

  /// No description provided for @levelUp.
  ///
  /// In en, this message translates to:
  /// **'Moving up to {level}!'**
  String levelUp(String level);

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @linkTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get linkTask;

  /// No description provided for @linkedGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get linkedGoal;

  /// No description provided for @linkedGoalOptional.
  ///
  /// In en, this message translates to:
  /// **'Linked goal (optional)'**
  String get linkedGoalOptional;

  /// No description provided for @linkedMilestoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Milestone (optional)'**
  String get linkedMilestoneOptional;

  /// No description provided for @linkedTasks.
  ///
  /// In en, this message translates to:
  /// **'Linked tasks'**
  String get linkedTasks;

  /// No description provided for @localModeNotice.
  ///
  /// In en, this message translates to:
  /// **'Local mode: your account and data are stored on this device.'**
  String get localModeNotice;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. You can pick a city instead.'**
  String get locationDenied;

  /// No description provided for @locationError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your location. Try again or pick a city.'**
  String get locationError;

  /// No description provided for @locationOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are off on this device.'**
  String get locationOff;

  /// No description provided for @locationOptional.
  ///
  /// In en, this message translates to:
  /// **'Location (optional)'**
  String get locationOptional;

  /// No description provided for @locationPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your location is used on this device to calculate times and saved only as coordinates in your settings.'**
  String get locationPrivacy;

  /// No description provided for @lookUp.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get lookUp;

  /// No description provided for @lookupNetwork.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the product database. Check the connection and try again.'**
  String get lookupNetwork;

  /// No description provided for @macroLine.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal · P {p} · C {c} · F {f}'**
  String macroLine(String kcal, String p, String c, String f);

  /// No description provided for @manageAssistantAccess.
  ///
  /// In en, this message translates to:
  /// **'Manage assistant permissions'**
  String get manageAssistantAccess;

  /// No description provided for @manageDevices.
  ///
  /// In en, this message translates to:
  /// **'Devices and sources'**
  String get manageDevices;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manually'**
  String get manual;

  /// No description provided for @manualHint.
  ///
  /// In en, this message translates to:
  /// **'You set the percentage yourself.'**
  String get manualHint;

  /// No description provided for @manualStepsNote.
  ///
  /// In en, this message translates to:
  /// **'If the phone app is connected, its number is used for that day.'**
  String get manualStepsNote;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark “{title}” done'**
  String markDone(String title);

  /// No description provided for @markGoalComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get markGoalComplete;

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markRead;

  /// No description provided for @masteredScore.
  ///
  /// In en, this message translates to:
  /// **'Mastered · best {n}%'**
  String masteredScore(int n);

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealPhoto.
  ///
  /// In en, this message translates to:
  /// **'Meal photo'**
  String get mealPhoto;

  /// No description provided for @mealSnack.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get mealSnack;

  /// No description provided for @measurementsN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 measurement} other{{n} measurements}}'**
  String measurementsN(int n);

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @methodEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority'**
  String get methodEgyptian;

  /// No description provided for @methodGulf.
  ///
  /// In en, this message translates to:
  /// **'Gulf region'**
  String get methodGulf;

  /// No description provided for @methodIsna.
  ///
  /// In en, this message translates to:
  /// **'ISNA (North America)'**
  String get methodIsna;

  /// No description provided for @methodKarachi.
  ///
  /// In en, this message translates to:
  /// **'University of Islamic Sciences, Karachi'**
  String get methodKarachi;

  /// No description provided for @methodKuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get methodKuwait;

  /// No description provided for @methodMwl.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get methodMwl;

  /// No description provided for @methodQatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get methodQatar;

  /// No description provided for @methodUmmAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura (Makkah)'**
  String get methodUmmAlQura;

  /// No description provided for @metricOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between {min} and {max}'**
  String metricOutOfRange(int min, int max);

  /// No description provided for @milestone.
  ///
  /// In en, this message translates to:
  /// **'Milestone'**
  String get milestone;

  /// No description provided for @milestoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Understand Dart basics'**
  String get milestoneHint;

  /// No description provided for @milestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestones;

  /// No description provided for @milestonesDone.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} milestones'**
  String milestonesDone(int done, int total);

  /// No description provided for @mkBloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get mkBloodPressure;

  /// No description provided for @mkBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get mkBodyFat;

  /// No description provided for @mkBodyFatPct.
  ///
  /// In en, this message translates to:
  /// **'Body fat (%)'**
  String get mkBodyFatPct;

  /// No description provided for @mkHeartBpm.
  ///
  /// In en, this message translates to:
  /// **'Resting heart rate (bpm)'**
  String get mkHeartBpm;

  /// No description provided for @mkWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get mkWaist;

  /// No description provided for @mkWaistCm.
  ///
  /// In en, this message translates to:
  /// **'Waist (cm)'**
  String get mkWaistCm;

  /// No description provided for @mkWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get mkWeight;

  /// No description provided for @mkWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get mkWeightKg;

  /// No description provided for @mmHgN.
  ///
  /// In en, this message translates to:
  /// **'{sys}/{dia} mmHg'**
  String mmHgN(int sys, int dia);

  /// No description provided for @modExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get modExpenses;

  /// No description provided for @modHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get modHabits;

  /// No description provided for @modLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get modLearning;

  /// No description provided for @modNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get modNotes;

  /// No description provided for @modTime.
  ///
  /// In en, this message translates to:
  /// **'Time management'**
  String get modTime;

  /// No description provided for @modelSaw.
  ///
  /// In en, this message translates to:
  /// **'What the phone saw (tap to search):'**
  String get modelSaw;

  /// No description provided for @moneyTabExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get moneyTabExpenses;

  /// No description provided for @moneyTabIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get moneyTabIncome;

  /// No description provided for @moneyTabSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get moneyTabSummary;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudget;

  /// No description provided for @monthlyEditNote.
  ///
  /// In en, this message translates to:
  /// **'Changes apply to the months to come. Months already recorded stay as they are.'**
  String get monthlyEditNote;

  /// No description provided for @monthlyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly expenses'**
  String get monthlyExpenses;

  /// No description provided for @monthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly income'**
  String get monthlyIncome;

  /// No description provided for @monthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyLabel;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodIrritable.
  ///
  /// In en, this message translates to:
  /// **'Irritable'**
  String get moodIrritable;

  /// No description provided for @moodLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get moodLow;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @moreFilters.
  ///
  /// In en, this message translates to:
  /// **'More filters'**
  String get moreFilters;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @mostLogged.
  ///
  /// In en, this message translates to:
  /// **'Most logged'**
  String get mostLogged;

  /// No description provided for @moveReminders.
  ///
  /// In en, this message translates to:
  /// **'Move reminders'**
  String get moveReminders;

  /// No description provided for @moveRemindersOn.
  ///
  /// In en, this message translates to:
  /// **'Remind me to move'**
  String get moveRemindersOn;

  /// No description provided for @moveRemindersSub.
  ///
  /// In en, this message translates to:
  /// **'Stops for the day once you reach your goal'**
  String get moveRemindersSub;

  /// No description provided for @moveTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Move to tomorrow'**
  String get moveTomorrow;

  /// No description provided for @movedTo.
  ///
  /// In en, this message translates to:
  /// **'Moved to {time}'**
  String movedTo(String time);

  /// No description provided for @movedTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Moved to tomorrow'**
  String get movedTomorrow;

  /// No description provided for @muArms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get muArms;

  /// No description provided for @muBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get muBack;

  /// No description provided for @muBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get muBalance;

  /// No description provided for @muCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get muCardio;

  /// No description provided for @muChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muChest;

  /// No description provided for @muCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get muCore;

  /// No description provided for @muFullBody.
  ///
  /// In en, this message translates to:
  /// **'Full body'**
  String get muFullBody;

  /// No description provided for @muGlutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get muGlutes;

  /// No description provided for @muLegs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get muLegs;

  /// No description provided for @muMobility.
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get muMobility;

  /// No description provided for @muPelvicFloor.
  ///
  /// In en, this message translates to:
  /// **'Pelvic floor'**
  String get muPelvicFloor;

  /// No description provided for @muShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muShoulders;

  /// No description provided for @multiCurrencyNote.
  ///
  /// In en, this message translates to:
  /// **'Each currency is totalled separately — amounts are never combined across currencies.'**
  String get multiCurrencyNote;

  /// No description provided for @myFoods.
  ///
  /// In en, this message translates to:
  /// **'My foods'**
  String get myFoods;

  /// No description provided for @myGoals.
  ///
  /// In en, this message translates to:
  /// **'My goals'**
  String get myGoals;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @myNotes.
  ///
  /// In en, this message translates to:
  /// **'My notes'**
  String get myNotes;

  /// No description provided for @nOfM.
  ///
  /// In en, this message translates to:
  /// **'{n} of {m}'**
  String nOfM(int n, int m);

  /// No description provided for @navAccountability.
  ///
  /// In en, this message translates to:
  /// **'Commitments'**
  String get navAccountability;

  /// No description provided for @navActivity.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get navActivity;

  /// No description provided for @navAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get navAssistant;

  /// No description provided for @navEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get navEnglish;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get navExpenses;

  /// No description provided for @navFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get navFitness;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navGoals;

  /// No description provided for @navHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get navHabits;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get navNotes;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navNutrition.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get navNutrition;

  /// No description provided for @navPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get navPrayer;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navTime.
  ///
  /// In en, this message translates to:
  /// **'My time'**
  String get navTime;

  /// No description provided for @navWomens.
  ///
  /// In en, this message translates to:
  /// **'Women\'s health'**
  String get navWomens;

  /// No description provided for @needMoreData.
  ///
  /// In en, this message translates to:
  /// **'Two recorded periods are needed to estimate the next one. You can also set your usual cycle length.'**
  String get needMoreData;

  /// No description provided for @neededTime.
  ///
  /// In en, this message translates to:
  /// **'Tasks need'**
  String get neededTime;

  /// No description provided for @needsReviewScore.
  ///
  /// In en, this message translates to:
  /// **'Needs another go · best {n}%'**
  String needsReviewScore(int n);

  /// No description provided for @neverAddedUp.
  ///
  /// In en, this message translates to:
  /// **'When two sources have the same day, one is shown, never both added up — a phone and a watch often count the same walk.'**
  String get neverAddedUp;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @newEvent.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get newEvent;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get newGoal;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// No description provided for @newUserBody.
  ///
  /// In en, this message translates to:
  /// **'Start with one task and one goal. Then ask the assistant to plan your day.'**
  String get newUserBody;

  /// No description provided for @newUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Hayati 👋'**
  String get newUserTitle;

  /// No description provided for @newWords.
  ///
  /// In en, this message translates to:
  /// **'New words'**
  String get newWords;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @nextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextPeriod;

  /// No description provided for @nextPeriodIn.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Next period in about a day} other{Next period in about {n} days}}'**
  String nextPeriodIn(int n);

  /// No description provided for @nextPrayerIs.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}'**
  String nextPrayerIs(String name);

  /// No description provided for @nextUp.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextUp;

  /// No description provided for @noActions.
  ///
  /// In en, this message translates to:
  /// **'No actions yet.'**
  String get noActions;

  /// No description provided for @noActiveGoals.
  ///
  /// In en, this message translates to:
  /// **'No active goals right now.'**
  String get noActiveGoals;

  /// No description provided for @noAppointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments'**
  String get noAppointments;

  /// No description provided for @noAppointmentsBody.
  ///
  /// In en, this message translates to:
  /// **'Add checkups and tests, with what you want to ask.'**
  String get noAppointmentsBody;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No previous chats.'**
  String get noConversations;

  /// No description provided for @noExpensesPeriod.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period'**
  String get noExpensesPeriod;

  /// No description provided for @noFoodFound.
  ///
  /// In en, this message translates to:
  /// **'No match'**
  String get noFoodFound;

  /// No description provided for @noFoodFoundBody.
  ///
  /// In en, this message translates to:
  /// **'Add it once as your own food and it\'s kept for next time.'**
  String get noFoodFoundBody;

  /// No description provided for @noFreeSlots.
  ///
  /// In en, this message translates to:
  /// **'No free time left on this day.'**
  String get noFreeSlots;

  /// No description provided for @noGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get noGoalsYet;

  /// No description provided for @noHabitsDueToday.
  ///
  /// In en, this message translates to:
  /// **'No habits are due today.'**
  String get noHabitsDueToday;

  /// No description provided for @noHabitsYet.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get noHabitsYet;

  /// No description provided for @noHeartYet.
  ///
  /// In en, this message translates to:
  /// **'No resting heart rate yet'**
  String get noHeartYet;

  /// No description provided for @noHomeAlternative.
  ///
  /// In en, this message translates to:
  /// **'{name}: no home alternative, skipped today'**
  String noHomeAlternative(String name);

  /// No description provided for @noIncomeMonth.
  ///
  /// In en, this message translates to:
  /// **'No income recorded this month'**
  String get noIncomeMonth;

  /// No description provided for @noLinkedTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks linked to this goal yet.'**
  String get noLinkedTasks;

  /// No description provided for @noMeasurementYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet — tap to add'**
  String get noMeasurementYet;

  /// No description provided for @noMilestones.
  ///
  /// In en, this message translates to:
  /// **'No milestones yet.'**
  String get noMilestones;

  /// No description provided for @noMoneyYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded this month'**
  String get noMoneyYet;

  /// No description provided for @noMoneyYetBody.
  ///
  /// In en, this message translates to:
  /// **'Add your salary or income and your expenses to see what\'s left.'**
  String get noMoneyYetBody;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotesYet;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @noPeriodsYet.
  ///
  /// In en, this message translates to:
  /// **'None recorded yet.'**
  String get noPeriodsYet;

  /// No description provided for @noProgressYet.
  ///
  /// In en, this message translates to:
  /// **'No logged sets yet'**
  String get noProgressYet;

  /// No description provided for @noProgressYetBody.
  ///
  /// In en, this message translates to:
  /// **'Finish a workout or a program and your progress shows here.'**
  String get noProgressYetBody;

  /// No description provided for @noReminder.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get noReminder;

  /// No description provided for @noReviewsDue.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review right now.'**
  String get noReviewsDue;

  /// No description provided for @noSalaryYet.
  ///
  /// In en, this message translates to:
  /// **'No salary recorded yet'**
  String get noSalaryYet;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noSearchResults;

  /// No description provided for @noSetsBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing will be saved. Leave the workout?'**
  String get noSetsBody;

  /// No description provided for @noSetsTitle.
  ///
  /// In en, this message translates to:
  /// **'No sets ticked'**
  String get noSetsTitle;

  /// No description provided for @noSleepYet.
  ///
  /// In en, this message translates to:
  /// **'No sleep recorded'**
  String get noSleepYet;

  /// No description provided for @noSleepYetBody.
  ///
  /// In en, this message translates to:
  /// **'Add a night by hand, or read sleep from your phone\'s health app in Devices and sources.'**
  String get noSleepYetBody;

  /// No description provided for @noSourcesYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet. Connect from the Hayati phone app, or add steps by hand.'**
  String get noSourcesYet;

  /// No description provided for @noSymptomsYet.
  ///
  /// In en, this message translates to:
  /// **'No symptoms logged yet.'**
  String get noSymptomsYet;

  /// No description provided for @noTasksToday.
  ///
  /// In en, this message translates to:
  /// **'No tasks for today.'**
  String get noTasksToday;

  /// No description provided for @noUnread.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get noUnread;

  /// No description provided for @noUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events.'**
  String get noUpcoming;

  /// No description provided for @noWorkoutThatDay.
  ///
  /// In en, this message translates to:
  /// **'No workout is planned for that day.'**
  String get noWorkoutThatDay;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @notDue.
  ///
  /// In en, this message translates to:
  /// **'Not due'**
  String get notDue;

  /// No description provided for @notEnoughToCompare.
  ///
  /// In en, this message translates to:
  /// **'Not enough records last month to compare.'**
  String get notEnoughToCompare;

  /// No description provided for @notLogged.
  ///
  /// In en, this message translates to:
  /// **'Not logged'**
  String get notLogged;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get notStarted;

  /// No description provided for @notSyncedYet.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get notSyncedYet;

  /// No description provided for @noteBody.
  ///
  /// In en, this message translates to:
  /// **'Write your note…'**
  String get noteBody;

  /// No description provided for @noteTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get noteTitle;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @nothingLogged.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet'**
  String get nothingLogged;

  /// No description provided for @nothingScheduled.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled'**
  String get nothingScheduled;

  /// No description provided for @nothingScheduledNow.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled today'**
  String get nothingScheduledNow;

  /// No description provided for @nothingThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged this week'**
  String get nothingThisWeek;

  /// No description provided for @nothingToPlan.
  ///
  /// In en, this message translates to:
  /// **'No open tasks to plan for this day.'**
  String get nothingToPlan;

  /// No description provided for @notifAccountability.
  ///
  /// In en, this message translates to:
  /// **'\"{task}\" is late'**
  String notifAccountability(String task);

  /// No description provided for @notifAccountabilityBody.
  ///
  /// In en, this message translates to:
  /// **'No blame — tell us what happened and pick what\'s next.'**
  String get notifAccountabilityBody;

  /// No description provided for @notifAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Health appointment'**
  String get notifAppointmentTitle;

  /// No description provided for @notifBedtimeBody.
  ///
  /// In en, this message translates to:
  /// **'Screens down, lights low'**
  String get notifBedtimeBody;

  /// No description provided for @notifBedtimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to wind down'**
  String get notifBedtimeTitle;

  /// No description provided for @notifDue.
  ///
  /// In en, this message translates to:
  /// **'Check its deadline in your tasks.'**
  String get notifDue;

  /// No description provided for @notifEventBody.
  ///
  /// In en, this message translates to:
  /// **'Starts in {minutes} min'**
  String notifEventBody(int minutes);

  /// No description provided for @notifEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming: {title}'**
  String notifEventTitle(String title);

  /// No description provided for @notifHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit reminder: {name}'**
  String notifHabitTitle(String name);

  /// No description provided for @notifMoveBody.
  ///
  /// In en, this message translates to:
  /// **'A short walk or a few minutes of stretching.'**
  String get notifMoveBody;

  /// No description provided for @notifMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to move'**
  String get notifMoveTitle;

  /// No description provided for @notifNeutralBody.
  ///
  /// In en, this message translates to:
  /// **'Open the app to see it'**
  String get notifNeutralBody;

  /// No description provided for @notifNeutralTitle.
  ///
  /// In en, this message translates to:
  /// **'Hayati reminder'**
  String get notifNeutralTitle;

  /// No description provided for @notifPrayerSoon.
  ///
  /// In en, this message translates to:
  /// **'{name} prayer in {minutes} min'**
  String notifPrayerSoon(String name, int minutes);

  /// No description provided for @notifPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for {name} prayer'**
  String notifPrayerTitle(String name);

  /// No description provided for @notifTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder: {title}'**
  String notifTaskTitle(String title);

  /// No description provided for @nowLabel.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get nowLabel;

  /// No description provided for @nowUntil.
  ///
  /// In en, this message translates to:
  /// **'Until {time}'**
  String nowUntil(String time);

  /// No description provided for @nutritionNote.
  ///
  /// In en, this message translates to:
  /// **'Numbers are estimates to help you notice patterns, not medical or diet advice.'**
  String get nutritionNote;

  /// No description provided for @obStep1.
  ///
  /// In en, this message translates to:
  /// **'Language and region'**
  String get obStep1;

  /// No description provided for @obStep2.
  ///
  /// In en, this message translates to:
  /// **'What would you like to organize?'**
  String get obStep2;

  /// No description provided for @obStep3.
  ///
  /// In en, this message translates to:
  /// **'A first goal (optional)'**
  String get obStep3;

  /// No description provided for @obStep4.
  ///
  /// In en, this message translates to:
  /// **'Your day'**
  String get obStep4;

  /// No description provided for @obsFew.
  ///
  /// In en, this message translates to:
  /// **'Fewer than half of the tasks due were completed. Planning fewer tasks per day may help.'**
  String get obsFew;

  /// No description provided for @obsHalf.
  ///
  /// In en, this message translates to:
  /// **'You completed about half of the tasks due in this period.'**
  String get obsHalf;

  /// No description provided for @obsMost.
  ///
  /// In en, this message translates to:
  /// **'You completed most of the tasks you set for this period.'**
  String get obsMost;

  /// No description provided for @obsNoDeadlines.
  ///
  /// In en, this message translates to:
  /// **'You completed {n} tasks. None had a deadline in this period, so there\'s no completion rate.'**
  String obsNoDeadlines(int n);

  /// No description provided for @observations.
  ///
  /// In en, this message translates to:
  /// **'Observations'**
  String get observations;

  /// No description provided for @ofStepGoal.
  ///
  /// In en, this message translates to:
  /// **'of {goal}'**
  String ofStepGoal(String goal);

  /// No description provided for @offNote.
  ///
  /// In en, this message translates to:
  /// **'Product data comes from Open Food Facts, a free open database. Only the barcode is sent. Check the label before saving.'**
  String get offNote;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @onboardingNoAuto.
  ///
  /// In en, this message translates to:
  /// **'Nothing is created or scheduled automatically. You\'ll choose what to add next.'**
  String get onboardingNoAuto;

  /// No description provided for @oneSourceEach.
  ///
  /// In en, this message translates to:
  /// **'Each type has one source so far, so there\'s nothing to choose.'**
  String get oneSourceEach;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @orTypeBarcode.
  ///
  /// In en, this message translates to:
  /// **'Or type the barcode number'**
  String get orTypeBarcode;

  /// No description provided for @organizeGroup.
  ///
  /// In en, this message translates to:
  /// **'Organize'**
  String get organizeGroup;

  /// No description provided for @otherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other income'**
  String get otherIncome;

  /// No description provided for @otherSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get otherSymptoms;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get overBudget;

  /// No description provided for @overCapacity.
  ///
  /// In en, this message translates to:
  /// **'Your tasks need more time than you have. Some can\'t fit today — move them or shorten them.'**
  String get overCapacity;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @overdueDef.
  ///
  /// In en, this message translates to:
  /// **'Due in period, deadline passed, still open'**
  String get overdueDef;

  /// No description provided for @overdueTasks.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdueTasks;

  /// No description provided for @paidOnDay.
  ///
  /// In en, this message translates to:
  /// **'Paid on day {day}'**
  String paidOnDay(int day);

  /// No description provided for @pain.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get pain;

  /// No description provided for @painN.
  ///
  /// In en, this message translates to:
  /// **'Pain {n}/10'**
  String painN(int n);

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @passwordRule.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters, with a letter and a number'**
  String get passwordRule;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @pastDay.
  ///
  /// In en, this message translates to:
  /// **'This day has passed.'**
  String get pastDay;

  /// No description provided for @pathStarted.
  ///
  /// In en, this message translates to:
  /// **'Your path starts at A1.'**
  String get pathStarted;

  /// No description provided for @pauseGoal.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseGoal;

  /// No description provided for @pausedLabel.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedLabel;

  /// No description provided for @payDay.
  ///
  /// In en, this message translates to:
  /// **'Pay day'**
  String get payDay;

  /// No description provided for @perOnePortion.
  ///
  /// In en, this message translates to:
  /// **'For one portion'**
  String get perOnePortion;

  /// No description provided for @perPortion.
  ///
  /// In en, this message translates to:
  /// **'Per portion: {portion}'**
  String perPortion(String portion);

  /// No description provided for @perWeek.
  ///
  /// In en, this message translates to:
  /// **'{n} a week'**
  String perWeek(int n);

  /// No description provided for @percentN.
  ///
  /// In en, this message translates to:
  /// **'{v}%'**
  String percentN(String v);

  /// No description provided for @periodCovers.
  ///
  /// In en, this message translates to:
  /// **'Covers {from} – {to}'**
  String periodCovers(String from, String to);

  /// No description provided for @periodDayN.
  ///
  /// In en, this message translates to:
  /// **'Period, day {n}'**
  String periodDayN(int n);

  /// No description provided for @periodDueAbout.
  ///
  /// In en, this message translates to:
  /// **'Your period may start about now'**
  String get periodDueAbout;

  /// No description provided for @periodEnded.
  ///
  /// In en, this message translates to:
  /// **'Saved: period ended'**
  String get periodEnded;

  /// No description provided for @periodEndedToday.
  ///
  /// In en, this message translates to:
  /// **'It ended today'**
  String get periodEndedToday;

  /// No description provided for @periodInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t fit: check the dates (no future days, no overlap, 15 days at most).'**
  String get periodInvalid;

  /// No description provided for @periodLateBy.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{A day past the estimated window} other{{n} days past the estimated window}}'**
  String periodLateBy(int n);

  /// No description provided for @periodSaved.
  ///
  /// In en, this message translates to:
  /// **'Period saved'**
  String get periodSaved;

  /// No description provided for @periodSinceDate.
  ///
  /// In en, this message translates to:
  /// **'Since {date} (going on)'**
  String periodSinceDate(String date);

  /// No description provided for @periodStarted.
  ///
  /// In en, this message translates to:
  /// **'Saved: period started'**
  String get periodStarted;

  /// No description provided for @periodStartedToday.
  ///
  /// In en, this message translates to:
  /// **'It started today'**
  String get periodStartedToday;

  /// No description provided for @permAddNotes.
  ///
  /// In en, this message translates to:
  /// **'Add notes'**
  String get permAddNotes;

  /// No description provided for @permAddNotesSub.
  ///
  /// In en, this message translates to:
  /// **'Save a note you dictate.'**
  String get permAddNotesSub;

  /// No description provided for @permCreateTasks.
  ///
  /// In en, this message translates to:
  /// **'Create a single task'**
  String get permCreateTasks;

  /// No description provided for @permCreateTasksSub.
  ///
  /// In en, this message translates to:
  /// **'From a clear request like “add task … tomorrow at 8 pm”.'**
  String get permCreateTasksSub;

  /// No description provided for @permDraftPlans.
  ///
  /// In en, this message translates to:
  /// **'Draft plans'**
  String get permDraftPlans;

  /// No description provided for @permDraftPlansSub.
  ///
  /// In en, this message translates to:
  /// **'Prepare plans for you to review. Drafts are never applied without approval.'**
  String get permDraftPlansSub;

  /// No description provided for @permLogHabits.
  ///
  /// In en, this message translates to:
  /// **'Log habit completion'**
  String get permLogHabits;

  /// No description provided for @permLogHabitsSub.
  ///
  /// In en, this message translates to:
  /// **'When you say you did a habit today.'**
  String get permLogHabitsSub;

  /// No description provided for @photoFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the photo. Try another one, or search instead.'**
  String get photoFailed;

  /// No description provided for @photoIntro.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your meal and the phone suggests what it is. You choose the food and the amount.'**
  String get photoIntro;

  /// No description provided for @photoNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No close match in the food list. Try a search, or add it as your own food.'**
  String get photoNoMatch;

  /// No description provided for @photoPrivacy.
  ///
  /// In en, this message translates to:
  /// **'The photo is read on your phone only. It isn\'t uploaded or kept.'**
  String get photoPrivacy;

  /// No description provided for @photoStep1.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the plate'**
  String get photoStep1;

  /// No description provided for @photoStep2.
  ///
  /// In en, this message translates to:
  /// **'Pick the matching food from the suggestions'**
  String get photoStep2;

  /// No description provided for @photoStep3.
  ///
  /// In en, this message translates to:
  /// **'Choose the amount — that\'s it'**
  String get photoStep3;

  /// No description provided for @pickCity.
  ///
  /// In en, this message translates to:
  /// **'Choose a city'**
  String get pickCity;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @placeGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get placeGym;

  /// No description provided for @placeHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get placeHome;

  /// No description provided for @placementExplain.
  ///
  /// In en, this message translates to:
  /// **'Your start level is the middle of your three skill levels. You can retake the test any time.'**
  String get placementExplain;

  /// No description provided for @placementIntro.
  ///
  /// In en, this message translates to:
  /// **'24 short questions from easy to harder. Answer what you can; guessing only makes the result less accurate.'**
  String get placementIntro;

  /// No description provided for @placementNoPeek.
  ///
  /// In en, this message translates to:
  /// **'Answers are shown at the end as your level, not one by one.'**
  String get placementNoPeek;

  /// No description provided for @placementResult.
  ///
  /// In en, this message translates to:
  /// **'Your level: {level}'**
  String placementResult(String level);

  /// No description provided for @placementTitle.
  ///
  /// In en, this message translates to:
  /// **'Placement test'**
  String get placementTitle;

  /// No description provided for @planApplied.
  ///
  /// In en, this message translates to:
  /// **'Plan applied'**
  String get planApplied;

  /// No description provided for @planEmptyToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for today yet.'**
  String get planEmptyToday;

  /// No description provided for @planExplain.
  ///
  /// In en, this message translates to:
  /// **'Plans are built from your answers: full body up to 3 days a week, upper/lower from 4, with core work in every session and rest days between hard ones. Saving keeps your previous plan as an earlier version.'**
  String get planExplain;

  /// No description provided for @planFor.
  ///
  /// In en, this message translates to:
  /// **'Plan: {place}'**
  String planFor(String place);

  /// No description provided for @planFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planFree;

  /// No description provided for @planIsEstimate.
  ///
  /// In en, this message translates to:
  /// **'This plan is an estimate based on durations and priorities. It keeps some free time for breaks and surprises.'**
  String get planIsEstimate;

  /// No description provided for @planLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planLabel;

  /// No description provided for @planPro.
  ///
  /// In en, this message translates to:
  /// **'Hayati Pro'**
  String get planPro;

  /// No description provided for @planSaved.
  ///
  /// In en, this message translates to:
  /// **'Plan saved'**
  String get planSaved;

  /// No description provided for @planSummary.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} tasks done today'**
  String planSummary(int done, int total);

  /// No description provided for @planVersion.
  ///
  /// In en, this message translates to:
  /// **'Plan version {version} · created {date}'**
  String planVersion(int version, String date);

  /// No description provided for @planWithAssistant.
  ///
  /// In en, this message translates to:
  /// **'Plan with assistant'**
  String get planWithAssistant;

  /// No description provided for @plannedDate.
  ///
  /// In en, this message translates to:
  /// **'Planned day'**
  String get plannedDate;

  /// No description provided for @plannedShort.
  ///
  /// In en, this message translates to:
  /// **'planned'**
  String get plannedShort;

  /// No description provided for @plannedTime.
  ///
  /// In en, this message translates to:
  /// **'Planned time'**
  String get plannedTime;

  /// No description provided for @planner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get planner;

  /// No description provided for @planningHint.
  ///
  /// In en, this message translates to:
  /// **'This helps the planner place tasks in time you actually have.'**
  String get planningHint;

  /// No description provided for @planningPrefs.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get planningPrefs;

  /// No description provided for @pointAtBarcode.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the barcode'**
  String get pointAtBarcode;

  /// No description provided for @portionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. piece, cup, 330 ml can'**
  String get portionHint;

  /// No description provided for @portionName.
  ///
  /// In en, this message translates to:
  /// **'Portion'**
  String get portionName;

  /// No description provided for @portionsN.
  ///
  /// In en, this message translates to:
  /// **'{n} × portion'**
  String portionsN(String n);

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerBlock.
  ///
  /// In en, this message translates to:
  /// **'Keep time free for prayer'**
  String get prayerBlock;

  /// No description provided for @prayerBlockHint.
  ///
  /// In en, this message translates to:
  /// **'The planner won\'t put tasks in this time.'**
  String get prayerBlockHint;

  /// No description provided for @prayerCalcNote.
  ///
  /// In en, this message translates to:
  /// **'Times are calculated astronomically and may differ by a minute or two from your local mosque. You can change the method in settings.'**
  String get prayerCalcNote;

  /// No description provided for @prayerCalculation.
  ///
  /// In en, this message translates to:
  /// **'Calculation'**
  String get prayerCalculation;

  /// No description provided for @prayerCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current prayer time'**
  String get prayerCurrent;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerEnable.
  ///
  /// In en, this message translates to:
  /// **'Show prayer times'**
  String get prayerEnable;

  /// No description provided for @prayerEnableHint.
  ///
  /// In en, this message translates to:
  /// **'On the home screen, in your day plan and as reminders.'**
  String get prayerEnableHint;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @prayerLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get prayerLocation;

  /// No description provided for @prayerLogHint.
  ///
  /// In en, this message translates to:
  /// **'Mark it yourself after you pray. Hayati never assumes.'**
  String get prayerLogHint;

  /// No description provided for @prayerLogLabel.
  ///
  /// In en, this message translates to:
  /// **'I prayed {name}'**
  String prayerLogLabel(String name);

  /// No description provided for @prayerLogToggle.
  ///
  /// In en, this message translates to:
  /// **'Prayer log'**
  String get prayerLogToggle;

  /// No description provided for @prayerLogToggleHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Only what you mark yourself is recorded.'**
  String get prayerLogToggleHint;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get prayerMethodLabel;

  /// No description provided for @prayerNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No location set yet'**
  String get prayerNoLocation;

  /// No description provided for @prayerNotify.
  ///
  /// In en, this message translates to:
  /// **'Notify me at each prayer time'**
  String get prayerNotify;

  /// No description provided for @prayerPreview.
  ///
  /// In en, this message translates to:
  /// **'Today\'s times'**
  String get prayerPreview;

  /// No description provided for @prayerRemindBefore.
  ///
  /// In en, this message translates to:
  /// **'Also remind me before'**
  String get prayerRemindBefore;

  /// No description provided for @prayerReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders and planning'**
  String get prayerReminders;

  /// No description provided for @prayerSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer times settings'**
  String get prayerSettingsTitle;

  /// No description provided for @prayerSetupAction.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get prayerSetupAction;

  /// No description provided for @prayerSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Choose your city to see prayer times and plan your day around them.'**
  String get prayerSetupBody;

  /// No description provided for @prayerSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get prayerSetupTitle;

  /// No description provided for @prayerWeekLogged.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{You haven\'t logged any prayers in the last 7 days.} =1{You logged 1 prayer in the last 7 days.} other{You logged {n} prayers in the last 7 days.}}'**
  String prayerWeekLogged(int n);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @previousChats.
  ///
  /// In en, this message translates to:
  /// **'Previous chats'**
  String get previousChats;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @pricingNotSet.
  ///
  /// In en, this message translates to:
  /// **'Price, billing period, taxes and renewal terms will be shown clearly here before purchase is enabled.'**
  String get pricingNotSet;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @privacyRetention.
  ///
  /// In en, this message translates to:
  /// **'Chat history'**
  String get privacyRetention;

  /// No description provided for @privacyText.
  ///
  /// In en, this message translates to:
  /// **'Hayati — Privacy policy (local mode draft)\n\n1. What we collect: only what you enter — your email, a salted hash of your password, your preferences, tasks, events, goals, habits, notes, expenses and assistant chats.\n\n2. Where it\'s stored: on this device. Nothing is sent to our servers or to an AI provider in this version.\n\n3. The assistant: it runs on your device and reads only the sections you allow in assistant settings.\n\n4. Your control: you can export all your data, delete chats, and delete your account at any time.\n\n5. Support reports never include your chats, notes or expenses; technical info is added only if you choose.\n\nThis draft must be reviewed and replaced with the final policy before public launch.'**
  String get privacyText;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get privacyTitle;

  /// No description provided for @problemDescription.
  ///
  /// In en, this message translates to:
  /// **'What went wrong?'**
  String get problemDescription;

  /// No description provided for @productFound.
  ///
  /// In en, this message translates to:
  /// **'Found in Open Food Facts. Check the numbers against the label before saving.'**
  String get productFound;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not in the database yet — enter it once from the label and it\'s kept.'**
  String get productNotFound;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & account'**
  String get profileTitle;

  /// No description provided for @programDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'General guidance, not medical advice. If something doesn\'t feel right, stop and ask your doctor.'**
  String get programDisclaimer;

  /// No description provided for @programExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get programExercises;

  /// No description provided for @programStages.
  ///
  /// In en, this message translates to:
  /// **'Choose your stage'**
  String get programStages;

  /// No description provided for @programUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get programUnavailable;

  /// No description provided for @programUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This program isn\'t part of your health sections.'**
  String get programUnavailableBody;

  /// No description provided for @programs.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get programs;

  /// No description provided for @programsForMen.
  ///
  /// In en, this message translates to:
  /// **'For men'**
  String get programsForMen;

  /// No description provided for @programsForWomen.
  ///
  /// In en, this message translates to:
  /// **'For women'**
  String get programsForWomen;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @progressLog.
  ///
  /// In en, this message translates to:
  /// **'Progress log'**
  String get progressLog;

  /// No description provided for @progressLogSub.
  ///
  /// In en, this message translates to:
  /// **'Your best and latest sets for each exercise'**
  String get progressLogSub;

  /// No description provided for @progressManual.
  ///
  /// In en, this message translates to:
  /// **'Manual progress'**
  String get progressManual;

  /// No description provided for @progressMethod.
  ///
  /// In en, this message translates to:
  /// **'How is progress measured?'**
  String get progressMethod;

  /// No description provided for @progressNotMeasured.
  ///
  /// In en, this message translates to:
  /// **'Not measured yet'**
  String get progressNotMeasured;

  /// No description provided for @progressNote.
  ///
  /// In en, this message translates to:
  /// **'From the sets you logged: weight × reps when you entered a weight, otherwise reps or time. Gold marks the best session.'**
  String get progressNote;

  /// No description provided for @proposalExecuted.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get proposalExecuted;

  /// No description provided for @proposalFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed — nothing was changed'**
  String get proposalFailed;

  /// No description provided for @proposalNotFound.
  ///
  /// In en, this message translates to:
  /// **'This suggestion no longer exists.'**
  String get proposalNotFound;

  /// No description provided for @proposalRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get proposalRejected;

  /// No description provided for @proposalStale.
  ///
  /// In en, this message translates to:
  /// **'Your data changed since this was suggested. Ask again for a fresh suggestion.'**
  String get proposalStale;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @proteinG.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get proteinG;

  /// No description provided for @questionOf.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String questionOf(int current, int total);

  /// No description provided for @questionsForDoctor.
  ///
  /// In en, this message translates to:
  /// **'Questions for the doctor'**
  String get questionsForDoctor;

  /// No description provided for @questionsN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 question} other{{n} questions}}'**
  String questionsN(int n);

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAdd;

  /// No description provided for @readOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Each switch asks {store} for permission the first time. Turning one off stops reading; what came in stays.'**
  String readOnlyNote(String store);

  /// No description provided for @readSleepBasics.
  ///
  /// In en, this message translates to:
  /// **'Read: sleep basics'**
  String get readSleepBasics;

  /// No description provided for @readThis.
  ///
  /// In en, this message translates to:
  /// **'Read:'**
  String get readThis;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Why'**
  String get reason;

  /// No description provided for @reasonDeadline.
  ///
  /// In en, this message translates to:
  /// **'Would finish after its deadline time'**
  String get reasonDeadline;

  /// No description provided for @reasonNoSlot.
  ///
  /// In en, this message translates to:
  /// **'No free slot is long enough'**
  String get reasonNoSlot;

  /// No description provided for @reasonNoTime.
  ///
  /// In en, this message translates to:
  /// **'Not enough free time left today'**
  String get reasonNoTime;

  /// No description provided for @receivedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get receivedThisMonth;

  /// No description provided for @recentFoods.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentFoods;

  /// No description provided for @recentNights.
  ///
  /// In en, this message translates to:
  /// **'Recent nights'**
  String get recentNights;

  /// No description provided for @recentWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Recent workouts'**
  String get recentWorkouts;

  /// No description provided for @recordedPeriods.
  ///
  /// In en, this message translates to:
  /// **'Recorded periods'**
  String get recordedPeriods;

  /// No description provided for @recovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get recovery;

  /// No description provided for @recoveryWarning.
  ///
  /// In en, this message translates to:
  /// **'Two demanding sessions fall on back-to-back days. Consider a rest day between them.'**
  String get recoveryWarning;

  /// No description provided for @recurringActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get recurringActive;

  /// No description provided for @regional.
  ///
  /// In en, this message translates to:
  /// **'Region & time'**
  String get regional;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @remainingFormula.
  ///
  /// In en, this message translates to:
  /// **'Income − expenses'**
  String get remainingFormula;

  /// No description provided for @remind3HoursBefore.
  ///
  /// In en, this message translates to:
  /// **'3 hours before'**
  String get remind3HoursBefore;

  /// No description provided for @remindBeforeN.
  ///
  /// In en, this message translates to:
  /// **'{n} min before'**
  String remindBeforeN(int n);

  /// No description provided for @remindDayBefore.
  ///
  /// In en, this message translates to:
  /// **'A day before'**
  String get remindDayBefore;

  /// No description provided for @remindHourBefore.
  ///
  /// In en, this message translates to:
  /// **'An hour before'**
  String get remindHourBefore;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @reminderNeedsTime.
  ///
  /// In en, this message translates to:
  /// **'Set a deadline or a planned time for the reminder.'**
  String get reminderNeedsTime;

  /// No description provided for @reminderTimeOptional.
  ///
  /// In en, this message translates to:
  /// **'Reminder time (optional)'**
  String get reminderTimeOptional;

  /// No description provided for @removeCup.
  ///
  /// In en, this message translates to:
  /// **'Remove a glass'**
  String get removeCup;

  /// No description provided for @removeFromPlan.
  ///
  /// In en, this message translates to:
  /// **'Remove from today\'s plan'**
  String get removeFromPlan;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove this change'**
  String get removeItem;

  /// No description provided for @removeSourceData.
  ///
  /// In en, this message translates to:
  /// **'Remove this source\'s data'**
  String get removeSourceData;

  /// No description provided for @removeSourceDataBody.
  ///
  /// In en, this message translates to:
  /// **'Steps, sleep, heart rate and workouts that came from {source} are removed from Hayati on all your devices. Nothing changes in {source} itself.'**
  String removeSourceDataBody(String source);

  /// No description provided for @removeSourceDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove data from {source}?'**
  String removeSourceDataTitle(String source);

  /// No description provided for @removedFromPlan.
  ///
  /// In en, this message translates to:
  /// **'Removed from this plan'**
  String get removedFromPlan;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @reorderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to change the order; times are recalculated.'**
  String get reorderHint;

  /// No description provided for @repeatDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get repeatDays;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Repeat every month'**
  String get repeatMonthly;

  /// No description provided for @repeatMonthlySub.
  ///
  /// In en, this message translates to:
  /// **'Recorded on this day each month'**
  String get repeatMonthlySub;

  /// No description provided for @reportFood.
  ///
  /// In en, this message translates to:
  /// **'Food logged on {days} days, about {kcal} kcal a day'**
  String reportFood(int days, String kcal);

  /// No description provided for @reportNoData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data for this period yet.'**
  String get reportNoData;

  /// No description provided for @reportPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your chats, notes and expenses are never included in reports.'**
  String get reportPrivacy;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportProblem;

  /// No description provided for @reportProblemSub.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened'**
  String get reportProblemSub;

  /// No description provided for @reportSaved.
  ///
  /// In en, this message translates to:
  /// **'Report saved. It will be sent when the support service is connected.'**
  String get reportSaved;

  /// No description provided for @reportSleep.
  ///
  /// In en, this message translates to:
  /// **'Slept {avg} on average ({nights} nights recorded)'**
  String reportSleep(String avg, int nights);

  /// No description provided for @reportStepGoal.
  ///
  /// In en, this message translates to:
  /// **'Step goal reached {days} of {total} days'**
  String reportStepGoal(int days, int total);

  /// No description provided for @repsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsLabel;

  /// No description provided for @repsN.
  ///
  /// In en, this message translates to:
  /// **'{n} reps'**
  String repsN(int n);

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email, a reset link is on its way.'**
  String get resetLinkSent;

  /// No description provided for @restBlock.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get restBlock;

  /// No description provided for @restDayBody.
  ///
  /// In en, this message translates to:
  /// **'Recovery is part of the plan. A walk or light stretching is plenty.'**
  String get restDayBody;

  /// No description provided for @restDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get restDayTitle;

  /// No description provided for @restFor.
  ///
  /// In en, this message translates to:
  /// **'Rest {n} s'**
  String restFor(int n);

  /// No description provided for @restOfDayFree.
  ///
  /// In en, this message translates to:
  /// **'The rest of the day is yours.'**
  String get restOfDayFree;

  /// No description provided for @restSeconds.
  ///
  /// In en, this message translates to:
  /// **'rest {n} s'**
  String restSeconds(int n);

  /// No description provided for @restingHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Resting heart rate'**
  String get restingHeartRate;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @resumeGoal.
  ///
  /// In en, this message translates to:
  /// **'Make active'**
  String get resumeGoal;

  /// No description provided for @retakePlacement.
  ///
  /// In en, this message translates to:
  /// **'Retake test'**
  String get retakePlacement;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @reviewChanges.
  ///
  /// In en, this message translates to:
  /// **'Review changes'**
  String get reviewChanges;

  /// No description provided for @reviewDone.
  ///
  /// In en, this message translates to:
  /// **'{right} of {total} right. Missed words come back tomorrow.'**
  String reviewDone(int right, int total);

  /// No description provided for @reviewDue.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 word to review} other{{n} words to review}}'**
  String reviewDue(int n);

  /// No description provided for @reviewMyPlan.
  ///
  /// In en, this message translates to:
  /// **'Review my plan'**
  String get reviewMyPlan;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Word review'**
  String get reviewTitle;

  /// No description provided for @reviewWhy.
  ///
  /// In en, this message translates to:
  /// **'Words you learned come back at growing intervals so they stick.'**
  String get reviewWhy;

  /// No description provided for @salaryChangeNote.
  ///
  /// In en, this message translates to:
  /// **'Months before this date keep the salary they had.'**
  String get salaryChangeNote;

  /// No description provided for @salaryHistory.
  ///
  /// In en, this message translates to:
  /// **'Salary history'**
  String get salaryHistory;

  /// No description provided for @salaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salaryLabel;

  /// No description provided for @salarySince.
  ///
  /// In en, this message translates to:
  /// **'{amount} from {date}'**
  String salarySince(String amount, String date);

  /// No description provided for @salaryStoppedSince.
  ///
  /// In en, this message translates to:
  /// **'Variable income from {date}'**
  String salaryStoppedSince(String date);

  /// No description provided for @sampleGoal1.
  ///
  /// In en, this message translates to:
  /// **'Learn English'**
  String get sampleGoal1;

  /// No description provided for @sampleGoal2.
  ///
  /// In en, this message translates to:
  /// **'Learn programming'**
  String get sampleGoal2;

  /// No description provided for @sampleGoal3.
  ///
  /// In en, this message translates to:
  /// **'Exercise regularly'**
  String get sampleGoal3;

  /// No description provided for @sampleGoal4.
  ///
  /// In en, this message translates to:
  /// **'Read 12 books this year'**
  String get sampleGoal4;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAndAdd.
  ///
  /// In en, this message translates to:
  /// **'Save and add'**
  String get saveAndAdd;

  /// No description provided for @saveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get saveAnyway;

  /// No description provided for @saveEvent.
  ///
  /// In en, this message translates to:
  /// **'Save event'**
  String get saveEvent;

  /// No description provided for @saveGoal.
  ///
  /// In en, this message translates to:
  /// **'Save goal'**
  String get saveGoal;

  /// No description provided for @saveOnly.
  ///
  /// In en, this message translates to:
  /// **'Save only'**
  String get saveOnly;

  /// No description provided for @savePlan.
  ///
  /// In en, this message translates to:
  /// **'Save plan'**
  String get savePlan;

  /// No description provided for @saveTask.
  ///
  /// In en, this message translates to:
  /// **'Save task'**
  String get saveTask;

  /// No description provided for @saveWorkout.
  ///
  /// In en, this message translates to:
  /// **'Save workout'**
  String get saveWorkout;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get scanBarcode;

  /// No description provided for @scanOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Camera scanning is in the phone app'**
  String get scanOnPhone;

  /// No description provided for @scanOnPhoneBody.
  ///
  /// In en, this message translates to:
  /// **'Here you can type the number printed under the barcode.'**
  String get scanOnPhoneBody;

  /// No description provided for @scheduleGroup.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get scheduleGroup;

  /// No description provided for @scoreOutOf.
  ///
  /// In en, this message translates to:
  /// **'You scored {score}% (needed {pass}%).'**
  String scoreOutOf(int score, int pass);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search for a city'**
  String get searchCity;

  /// No description provided for @searchFoods.
  ///
  /// In en, this message translates to:
  /// **'Search foods'**
  String get searchFoods;

  /// No description provided for @searchInstead.
  ///
  /// In en, this message translates to:
  /// **'Search the list instead'**
  String get searchInstead;

  /// No description provided for @secondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get secondsLabel;

  /// No description provided for @secondsN.
  ///
  /// In en, this message translates to:
  /// **'{n} s'**
  String secondsN(int n);

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{n} s'**
  String secondsShort(int n);

  /// No description provided for @sectionsShown.
  ///
  /// In en, this message translates to:
  /// **'Sections in the app'**
  String get sectionsShown;

  /// No description provided for @seeResult.
  ///
  /// In en, this message translates to:
  /// **'See result'**
  String get seeResult;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendResetLink;

  /// No description provided for @sessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get sessionCompleted;

  /// No description provided for @sessionLength.
  ///
  /// In en, this message translates to:
  /// **'Session length'**
  String get sessionLength;

  /// No description provided for @sessionPartial.
  ///
  /// In en, this message translates to:
  /// **'Partly done'**
  String get sessionPartial;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @sessionsLocal.
  ///
  /// In en, this message translates to:
  /// **'Local mode has one session per device. Signing out ends it.'**
  String get sessionsLocal;

  /// No description provided for @sessionsRemote.
  ///
  /// In en, this message translates to:
  /// **'Signing out ends the session on this device. Changing your password signs out other devices when their session refreshes.'**
  String get sessionsRemote;

  /// No description provided for @setN.
  ///
  /// In en, this message translates to:
  /// **'Set {n}'**
  String setN(int n);

  /// No description provided for @setSalary.
  ///
  /// In en, this message translates to:
  /// **'Set salary'**
  String get setSalary;

  /// No description provided for @setsLogged.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 set} other{{n} sets}}'**
  String setsLogged(int n);

  /// No description provided for @setsProgress.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} sets'**
  String setsProgress(int done, int total);

  /// No description provided for @sexAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get sexAskTitle;

  /// No description provided for @sexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get sexFemale;

  /// No description provided for @sexLabel.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sexLabel;

  /// No description provided for @sexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get sexMale;

  /// No description provided for @sexWhy.
  ///
  /// In en, this message translates to:
  /// **'Used only to tailor the health sections. You can change it from your profile.'**
  String get sexWhy;

  /// No description provided for @shareActivitySub.
  ///
  /// In en, this message translates to:
  /// **'Steps and active minutes of the last 7 days'**
  String get shareActivitySub;

  /// No description provided for @shareCycleSub.
  ///
  /// In en, this message translates to:
  /// **'Not used by the assistant yet; stays private'**
  String get shareCycleSub;

  /// No description provided for @shareNotesSub.
  ///
  /// In en, this message translates to:
  /// **'Off by default'**
  String get shareNotesSub;

  /// No description provided for @shareNutritionSub.
  ///
  /// In en, this message translates to:
  /// **'Daily food totals and water, no photos'**
  String get shareNutritionSub;

  /// No description provided for @shareSleepSub.
  ///
  /// In en, this message translates to:
  /// **'Sleep length and how rested you felt'**
  String get shareSleepSub;

  /// No description provided for @shareSub.
  ///
  /// In en, this message translates to:
  /// **'Used to plan and summarize'**
  String get shareSub;

  /// No description provided for @shareVitalsSub.
  ///
  /// In en, this message translates to:
  /// **'Weight, blood pressure and other measurements'**
  String get shareVitalsSub;

  /// No description provided for @showActive.
  ///
  /// In en, this message translates to:
  /// **'Show active'**
  String get showActive;

  /// No description provided for @showArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get showArchived;

  /// No description provided for @showCompleted.
  ///
  /// In en, this message translates to:
  /// **'Show completed & archived'**
  String get showCompleted;

  /// No description provided for @showMyPlan.
  ///
  /// In en, this message translates to:
  /// **'Show my plan'**
  String get showMyPlan;

  /// No description provided for @showNameGreeting.
  ///
  /// In en, this message translates to:
  /// **'Show my name in the greeting'**
  String get showNameGreeting;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInMethod.
  ///
  /// In en, this message translates to:
  /// **'Sign-in method'**
  String get signInMethod;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue.'**
  String get signInSubtitle;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your data stays saved for when you sign in again.'**
  String get signOutBody;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It takes less than a minute.'**
  String get signUpSubtitle;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signUpTitle;

  /// No description provided for @sixMonths.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get sixMonths;

  /// No description provided for @skillGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get skillGrammar;

  /// No description provided for @skillReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get skillReading;

  /// No description provided for @skillVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get skillVocabulary;

  /// No description provided for @skillsMeasuredNote.
  ///
  /// In en, this message translates to:
  /// **'The app measures vocabulary, grammar and reading. Listening and speaking need audio tools and aren\'t assessed yet.'**
  String get skillsMeasuredNote;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @skipRest.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipRest;

  /// No description provided for @sleepAndRecovery.
  ///
  /// In en, this message translates to:
  /// **'Sleep and recovery'**
  String get sleepAndRecovery;

  /// No description provided for @sleepAndRecoverySub.
  ///
  /// In en, this message translates to:
  /// **'Your nights, how rested you feel, a bedtime reminder'**
  String get sleepAndRecoverySub;

  /// No description provided for @sleepGoldNote.
  ///
  /// In en, this message translates to:
  /// **'Gold marks nights of 7 hours or more.'**
  String get sleepGoldNote;

  /// No description provided for @sleepInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t fit: check the times (up to 24 hours, not in the future, not overlapping another night you added).'**
  String get sleepInvalid;

  /// No description provided for @sleepNightsN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 night} other{{n} nights}}'**
  String sleepNightsN(int n);

  /// No description provided for @sleepQuality.
  ///
  /// In en, this message translates to:
  /// **'How did you sleep?'**
  String get sleepQuality;

  /// No description provided for @sleepQualityN.
  ///
  /// In en, this message translates to:
  /// **'Quality {n} of 5'**
  String sleepQualityN(int n);

  /// No description provided for @sleepWindow.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String sleepWindow(String from, String to);

  /// No description provided for @slotEvent.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get slotEvent;

  /// No description provided for @slotFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get slotFree;

  /// No description provided for @slotPast.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get slotPast;

  /// No description provided for @slotPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get slotPrayer;

  /// No description provided for @slotSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get slotSleep;

  /// No description provided for @slotTask.
  ///
  /// In en, this message translates to:
  /// **'Tasks at a time'**
  String get slotTask;

  /// No description provided for @sourceDataRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed data from {source}'**
  String sourceDataRemoved(String source);

  /// No description provided for @sourceHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Health Connect'**
  String get sourceHealthConnect;

  /// No description provided for @sourceHealthKit.
  ///
  /// In en, this message translates to:
  /// **'Apple Health'**
  String get sourceHealthKit;

  /// No description provided for @sourceManual.
  ///
  /// In en, this message translates to:
  /// **'Added by hand'**
  String get sourceManual;

  /// No description provided for @sourcePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone sensor'**
  String get sourcePhone;

  /// No description provided for @sources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sources;

  /// No description provided for @sourcesWithData.
  ///
  /// In en, this message translates to:
  /// **'Sources with your data'**
  String get sourcesWithData;

  /// No description provided for @spending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get spending;

  /// No description provided for @spentMoreThanIncome.
  ///
  /// In en, this message translates to:
  /// **'You spent more than you received this month.'**
  String get spentMoreThanIncome;

  /// No description provided for @splashFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t start Hayati.'**
  String get splashFailed;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @startFromBeginning.
  ///
  /// In en, this message translates to:
  /// **'Start from the beginning'**
  String get startFromBeginning;

  /// No description provided for @startLesson.
  ///
  /// In en, this message translates to:
  /// **'Start lesson'**
  String get startLesson;

  /// No description provided for @startPath.
  ///
  /// In en, this message translates to:
  /// **'Start my path'**
  String get startPath;

  /// No description provided for @startProgram.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startProgram;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take the short quiz'**
  String get startQuiz;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get startTime;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get startWorkout;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @statusTodo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get statusTodo;

  /// No description provided for @stepDaysN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day of steps} other{{n} days of steps}}'**
  String stepDaysN(int n);

  /// No description provided for @stepGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily step goal'**
  String get stepGoal;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepOf(int step, int total);

  /// No description provided for @stepsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Up to 150,000'**
  String get stepsInvalid;

  /// No description provided for @stepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stepsLabel;

  /// No description provided for @stepsNoData.
  ///
  /// In en, this message translates to:
  /// **'No steps yet today — tap to connect or add them'**
  String get stepsNoData;

  /// No description provided for @stepsOfGoal.
  ///
  /// In en, this message translates to:
  /// **'{steps} / {goal} steps'**
  String stepsOfGoal(String steps, String goal);

  /// No description provided for @stepsOptional.
  ///
  /// In en, this message translates to:
  /// **'Steps to reproduce (optional)'**
  String get stepsOptional;

  /// No description provided for @stepsPerDay.
  ///
  /// In en, this message translates to:
  /// **'{n} steps a day'**
  String stepsPerDay(String n);

  /// No description provided for @stepsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Steps access wasn\'t given. You can allow it from the health app\'s settings.'**
  String get stepsPermissionDenied;

  /// No description provided for @stepsToday.
  ///
  /// In en, this message translates to:
  /// **'Steps today'**
  String get stepsToday;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @stopIf.
  ///
  /// In en, this message translates to:
  /// **'Stop and get advice if you have'**
  String get stopIf;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{No streak yet} =1{1-day streak} other{{n}-day streak}}'**
  String streakDays(int n);

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// No description provided for @suggestedPill.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get suggestedPill;

  /// No description provided for @suggestedPlan.
  ///
  /// In en, this message translates to:
  /// **'Suggested plan'**
  String get suggestedPlan;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @switchLabel.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchLabel;

  /// No description provided for @switchToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get switchToSignIn;

  /// No description provided for @switchToSignUp.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get switchToSignUp;

  /// No description provided for @switchToVariableBody.
  ///
  /// In en, this message translates to:
  /// **'Your fixed salary stops from the date you pick. Past months stay as they were.'**
  String get switchToVariableBody;

  /// No description provided for @switchToVariableTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to variable income?'**
  String get switchToVariableTitle;

  /// No description provided for @syAcne.
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get syAcne;

  /// No description provided for @syBackPain.
  ///
  /// In en, this message translates to:
  /// **'Back pain'**
  String get syBackPain;

  /// No description provided for @syBloating.
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get syBloating;

  /// No description provided for @syBreastTenderness.
  ///
  /// In en, this message translates to:
  /// **'Breast tenderness'**
  String get syBreastTenderness;

  /// No description provided for @syCramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get syCramps;

  /// No description provided for @syCravings.
  ///
  /// In en, this message translates to:
  /// **'Cravings'**
  String get syCravings;

  /// No description provided for @syFatigue.
  ///
  /// In en, this message translates to:
  /// **'Tiredness'**
  String get syFatigue;

  /// No description provided for @syHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get syHeadache;

  /// No description provided for @syInsomnia.
  ///
  /// In en, this message translates to:
  /// **'Poor sleep'**
  String get syInsomnia;

  /// No description provided for @syMoodSwings.
  ///
  /// In en, this message translates to:
  /// **'Mood swings'**
  String get syMoodSwings;

  /// No description provided for @syNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get syNausea;

  /// No description provided for @sySpotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get sySpotting;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @syncFailedShort.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read steps — try again'**
  String get syncFailedShort;

  /// No description provided for @syncNever.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get syncNever;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{Offline — showing saved data.} =1{Offline — 1 change will sync when you\'re back online.} other{Offline — {n} changes will sync when you\'re back online.}}'**
  String syncOffline(int n);

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 change waiting to upload} other{{n} changes waiting to upload}}'**
  String syncPending(int n);

  /// No description provided for @syncRejected.
  ///
  /// In en, this message translates to:
  /// **'Some changes couldn\'t be saved to your account and were replaced with the saved version.'**
  String get syncRejected;

  /// No description provided for @syncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncStatus;

  /// No description provided for @syncUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date · {time}'**
  String syncUpToDate(String time);

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Upper (systolic)'**
  String get systolic;

  /// No description provided for @takeLevelCheck.
  ///
  /// In en, this message translates to:
  /// **'Take the level check'**
  String get takeLevelCheck;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @takePlacement.
  ///
  /// In en, this message translates to:
  /// **'Take the placement test'**
  String get takePlacement;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target date'**
  String get targetDate;

  /// No description provided for @targetOn.
  ///
  /// In en, this message translates to:
  /// **'Target {date}'**
  String targetOn(String date);

  /// No description provided for @taskTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitleRequired;

  /// No description provided for @tasksCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tasks completed'**
  String get tasksCompleted;

  /// No description provided for @tasksCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 task} other{{n} tasks}}'**
  String tasksCount(int n);

  /// No description provided for @tasksDoneOf.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} tasks done'**
  String tasksDoneOf(int done, int total);

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get terms;

  /// No description provided for @termsText.
  ///
  /// In en, this message translates to:
  /// **'Hayati — Terms of use (draft)\n\nHayati helps you organize your time, goals, habits, notes and expenses. Plans and suggestions are estimates, not guarantees. Hayati is not a banking, financial-advice or medical service. You are responsible for the data you enter and for decisions you make based on it.\n\nThis draft must be reviewed and replaced with the final terms before public launch.'**
  String get termsText;

  /// No description provided for @testHistory.
  ///
  /// In en, this message translates to:
  /// **'Test history'**
  String get testHistory;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get thinking;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get thisDevice;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @thisPhone.
  ///
  /// In en, this message translates to:
  /// **'This phone'**
  String get thisPhone;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @timesN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{once} other{{n} times}}'**
  String timesN(int n);

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get timezone;

  /// No description provided for @timezoneDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected from your device. Times are shown in your device\'s time zone.'**
  String get timezoneDetected;

  /// No description provided for @timezoneDeviceNote.
  ///
  /// In en, this message translates to:
  /// **'follows your device'**
  String get timezoneDeviceNote;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @todayFrom.
  ///
  /// In en, this message translates to:
  /// **'Today: {source}'**
  String todayFrom(String source);

  /// No description provided for @todayLogged.
  ///
  /// In en, this message translates to:
  /// **'Today, logged'**
  String get todayLogged;

  /// No description provided for @todayPlan.
  ///
  /// In en, this message translates to:
  /// **'Today\'s plan'**
  String get todayPlan;

  /// No description provided for @todaysHabits.
  ///
  /// In en, this message translates to:
  /// **'Today\'s habits'**
  String get todaysHabits;

  /// No description provided for @todaysLesson.
  ///
  /// In en, this message translates to:
  /// **'Today\'s lesson'**
  String get todaysLesson;

  /// No description provided for @todaysWorkout.
  ///
  /// In en, this message translates to:
  /// **'Today\'s workout: {focus}'**
  String todaysWorkout(String focus);

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @toolAddAppointment.
  ///
  /// In en, this message translates to:
  /// **'Add health appointment'**
  String get toolAddAppointment;

  /// No description provided for @toolAddMilestones.
  ///
  /// In en, this message translates to:
  /// **'Add milestones'**
  String get toolAddMilestones;

  /// No description provided for @toolAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get toolAddNote;

  /// No description provided for @toolCreateGoal.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get toolCreateGoal;

  /// No description provided for @toolCreateTask.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get toolCreateTask;

  /// No description provided for @toolDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get toolDeleteTask;

  /// No description provided for @toolLogHabit.
  ///
  /// In en, this message translates to:
  /// **'Log habit'**
  String get toolLogHabit;

  /// No description provided for @toolLogWater.
  ///
  /// In en, this message translates to:
  /// **'Log water'**
  String get toolLogWater;

  /// No description provided for @toolMoveTask.
  ///
  /// In en, this message translates to:
  /// **'Change deadline'**
  String get toolMoveTask;

  /// No description provided for @toolPlanTask.
  ///
  /// In en, this message translates to:
  /// **'Set planned time'**
  String get toolPlanTask;

  /// No description provided for @topPriorities.
  ///
  /// In en, this message translates to:
  /// **'Top priorities'**
  String get topPriorities;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get totalIncome;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalSpent;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Study it again'**
  String get tryAgain;

  /// No description provided for @turnOnSection.
  ///
  /// In en, this message translates to:
  /// **'Turn on {section} in health settings first'**
  String turnOnSection(String section);

  /// No description provided for @typeToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type “{word}” to confirm'**
  String typeToConfirm(String word);

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Restore from archive'**
  String get unarchive;

  /// No description provided for @unarchived.
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get unarchived;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @unitHours.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 h} other{{n} h}}'**
  String unitHours(int n);

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 min} other{{n} min}}'**
  String unitMinutes(int n);

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @unlockFailed.
  ///
  /// In en, this message translates to:
  /// **'Not unlocked'**
  String get unlockFailed;

  /// No description provided for @unlockReason.
  ///
  /// In en, this message translates to:
  /// **'Open your health sections in Hayati'**
  String get unlockReason;

  /// No description provided for @unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @unscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get unscheduled;

  /// No description provided for @untilDeleted.
  ///
  /// In en, this message translates to:
  /// **'Until I delete them'**
  String get untilDeleted;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @upcomingSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary of {amount} due {date}'**
  String upcomingSalary(String amount, String date);

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @usageToday.
  ///
  /// In en, this message translates to:
  /// **'{used}/{limit} assistant requests today'**
  String usageToday(int used, int limit);

  /// No description provided for @use24h.
  ///
  /// In en, this message translates to:
  /// **'24-hour time'**
  String get use24h;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @usuallyOnDay.
  ///
  /// In en, this message translates to:
  /// **'Usually on day {n} of the cycle'**
  String usuallyOnDay(int n);

  /// No description provided for @verificationLocal.
  ///
  /// In en, this message translates to:
  /// **'Not required in local mode'**
  String get verificationLocal;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @viewAllGoals.
  ///
  /// In en, this message translates to:
  /// **'View all goals'**
  String get viewAllGoals;

  /// No description provided for @viewCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get viewCalendar;

  /// No description provided for @vitals.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get vitals;

  /// No description provided for @vitalsFromDevices.
  ///
  /// In en, this message translates to:
  /// **'Read weight and blood pressure from your phone\'s health app'**
  String get vitalsFromDevices;

  /// No description provided for @vitalsNote.
  ///
  /// In en, this message translates to:
  /// **'For your own record. These numbers aren\'t a diagnosis; read more in Health reading.'**
  String get vitalsNote;

  /// No description provided for @vitalsSub.
  ///
  /// In en, this message translates to:
  /// **'Weight, waist, heart rate, blood pressure, body fat'**
  String get vitalsSub;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month: {amount}'**
  String vsLastMonth(String amount);

  /// No description provided for @wakeTime.
  ///
  /// In en, this message translates to:
  /// **'I wake up at'**
  String get wakeTime;

  /// No description provided for @walkItem.
  ///
  /// In en, this message translates to:
  /// **'A {minutes}-minute walk'**
  String walkItem(int minutes);

  /// No description provided for @warnBleeding.
  ///
  /// In en, this message translates to:
  /// **'Vaginal bleeding'**
  String get warnBleeding;

  /// No description provided for @warnCalf.
  ///
  /// In en, this message translates to:
  /// **'Pain or swelling in a calf'**
  String get warnCalf;

  /// No description provided for @warnChest.
  ///
  /// In en, this message translates to:
  /// **'Chest pain or unusual shortness of breath'**
  String get warnChest;

  /// No description provided for @warnContractions.
  ///
  /// In en, this message translates to:
  /// **'Regular, painful contractions'**
  String get warnContractions;

  /// No description provided for @warnDizzy.
  ///
  /// In en, this message translates to:
  /// **'Dizziness or feeling faint'**
  String get warnDizzy;

  /// No description provided for @warnFluid.
  ///
  /// In en, this message translates to:
  /// **'Fluid leaking'**
  String get warnFluid;

  /// No description provided for @warnHeadache.
  ///
  /// In en, this message translates to:
  /// **'A bad headache'**
  String get warnHeadache;

  /// No description provided for @warnHeavyBleeding.
  ///
  /// In en, this message translates to:
  /// **'Heavier bleeding than before'**
  String get warnHeavyBleeding;

  /// No description provided for @warnLeaking.
  ///
  /// In en, this message translates to:
  /// **'Leaking urine during exercise'**
  String get warnLeaking;

  /// No description provided for @warnPain.
  ///
  /// In en, this message translates to:
  /// **'Pain (not just effort)'**
  String get warnPain;

  /// No description provided for @warnPelvicHeaviness.
  ///
  /// In en, this message translates to:
  /// **'Heaviness or bulging in the pelvis'**
  String get warnPelvicHeaviness;

  /// No description provided for @waterAverage.
  ///
  /// In en, this message translates to:
  /// **'Water: {ml} ml a day on average'**
  String waterAverage(String ml);

  /// No description provided for @waterGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily water goal'**
  String get waterGoal;

  /// No description provided for @waterMl.
  ///
  /// In en, this message translates to:
  /// **'{ml} ml'**
  String waterMl(String ml);

  /// No description provided for @waterOfGoal.
  ///
  /// In en, this message translates to:
  /// **'Water {ml} / {goal} ml'**
  String waterOfGoal(String ml, String goal);

  /// No description provided for @wdFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get wdFri;

  /// No description provided for @wdMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get wdMon;

  /// No description provided for @wdSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get wdSat;

  /// No description provided for @wdSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get wdSun;

  /// No description provided for @wdThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get wdThu;

  /// No description provided for @wdTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get wdTue;

  /// No description provided for @wdWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wdWed;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @weekAhead.
  ///
  /// In en, this message translates to:
  /// **'Your next 7 days'**
  String get weekAhead;

  /// No description provided for @weekAverage.
  ///
  /// In en, this message translates to:
  /// **'Week average: {value}'**
  String weekAverage(String value);

  /// No description provided for @weekBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy day'**
  String get weekBusy;

  /// No description provided for @weekEvents.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{No events} =1{1 event} other{{n} events}}'**
  String weekEvents(int n);

  /// No description provided for @weekLoad.
  ///
  /// In en, this message translates to:
  /// **'Planned load'**
  String get weekLoad;

  /// No description provided for @weekReport.
  ///
  /// In en, this message translates to:
  /// **'Weekly report'**
  String get weekReport;

  /// No description provided for @weekReportNote.
  ///
  /// In en, this message translates to:
  /// **'Averages count only days you logged something.'**
  String get weekReportNote;

  /// No description provided for @weekStart.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get weekStart;

  /// No description provided for @weekTasks.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{No tasks due} =1{1 task due} other{{n} tasks due}}'**
  String weekTasks(int n);

  /// No description provided for @weekWorkouts.
  ///
  /// In en, this message translates to:
  /// **'{done} of {planned} workouts done this week'**
  String weekWorkouts(int done, int planned);

  /// No description provided for @weeklyGoalQuestion.
  ///
  /// In en, this message translates to:
  /// **'How many lessons a week?'**
  String get weeklyGoalQuestion;

  /// No description provided for @weeklyLessons.
  ///
  /// In en, this message translates to:
  /// **'{done} of {goal} lessons this week'**
  String weeklyLessons(int done, int goal);

  /// No description provided for @weeklyPlan.
  ///
  /// In en, this message translates to:
  /// **'Weekly plan'**
  String get weeklyPlan;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get weightKg;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your time, goals, habits, notes and spending — in one place that plans with you.'**
  String get welcomeBody;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your life, step by step'**
  String get welcomeTitle;

  /// No description provided for @wentToBed.
  ///
  /// In en, this message translates to:
  /// **'Went to bed'**
  String get wentToBed;

  /// No description provided for @whatThisPhoneReads.
  ///
  /// In en, this message translates to:
  /// **'What this phone reads'**
  String get whatThisPhoneReads;

  /// No description provided for @whatWeStore.
  ///
  /// In en, this message translates to:
  /// **'What Hayati stores'**
  String get whatWeStore;

  /// No description provided for @whatWeStoreBody.
  ///
  /// In en, this message translates to:
  /// **'Your account (email and a salted password hash), preferences, tasks, events, goals, milestones, habits and their logs, notes, expenses and budgets, assistant chats (per your retention setting) and an action log without message content. In local mode all of this stays on this device.'**
  String get whatWeStoreBody;

  /// No description provided for @whatWeStoreBodyRemote.
  ///
  /// In en, this message translates to:
  /// **'Your account (email; the password is handled by our authentication service and never stored by the app), preferences, tasks, events, goals, milestones, habits and their logs, notes, expenses and budgets are stored in your account on our servers, readable only by you (row-level security), with a copy on this device for offline use. Assistant chats currently stay on this device, per your retention setting.'**
  String get whatWeStoreBodyRemote;

  /// No description provided for @whichSourceCounts.
  ///
  /// In en, this message translates to:
  /// **'Which source counts'**
  String get whichSourceCounts;

  /// No description provided for @whyOptional.
  ///
  /// In en, this message translates to:
  /// **'Why it matters (optional)'**
  String get whyOptional;

  /// No description provided for @woBasketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get woBasketball;

  /// No description provided for @woCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get woCycling;

  /// No description provided for @woElliptical.
  ///
  /// In en, this message translates to:
  /// **'Elliptical'**
  String get woElliptical;

  /// No description provided for @woFootball.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get woFootball;

  /// No description provided for @woHiit.
  ///
  /// In en, this message translates to:
  /// **'Interval training'**
  String get woHiit;

  /// No description provided for @woHiking.
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get woHiking;

  /// No description provided for @woOther.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get woOther;

  /// No description provided for @woPilates.
  ///
  /// In en, this message translates to:
  /// **'Pilates'**
  String get woPilates;

  /// No description provided for @woRowing.
  ///
  /// In en, this message translates to:
  /// **'Rowing'**
  String get woRowing;

  /// No description provided for @woRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get woRunning;

  /// No description provided for @woStairs.
  ///
  /// In en, this message translates to:
  /// **'Stairs'**
  String get woStairs;

  /// No description provided for @woStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength training'**
  String get woStrength;

  /// No description provided for @woSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get woSwimming;

  /// No description provided for @woTennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get woTennis;

  /// No description provided for @woWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get woWalking;

  /// No description provided for @woYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get woYoga;

  /// No description provided for @wokeUp.
  ///
  /// In en, this message translates to:
  /// **'Woke up'**
  String get wokeUp;

  /// No description provided for @wokeUpOn.
  ///
  /// In en, this message translates to:
  /// **'Woke up on'**
  String get wokeUpOn;

  /// No description provided for @womensUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This section is part of women\'s health.'**
  String get womensUnavailable;

  /// No description provided for @wordsAddedToReview.
  ///
  /// In en, this message translates to:
  /// **'This lesson\'s words are added to your reviews, starting tomorrow.'**
  String get wordsAddedToReview;

  /// No description provided for @workBlock.
  ///
  /// In en, this message translates to:
  /// **'Work / study'**
  String get workBlock;

  /// No description provided for @workDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Work/study hours apply on the selected days. Clear the start time to remove them.'**
  String get workDaysHint;

  /// No description provided for @workEnd.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get workEnd;

  /// No description provided for @workStart.
  ///
  /// In en, this message translates to:
  /// **'Work/study from'**
  String get workStart;

  /// No description provided for @workoutDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s workout is done'**
  String get workoutDoneToday;

  /// No description provided for @workoutNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get workoutNote;

  /// No description provided for @workoutNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. knee felt tight on lunges'**
  String get workoutNoteHint;

  /// No description provided for @workoutSaved.
  ///
  /// In en, this message translates to:
  /// **'Workout saved. Well done!'**
  String get workoutSaved;

  /// No description provided for @workoutSavedPartial.
  ///
  /// In en, this message translates to:
  /// **'Saved what you did. Every bit counts.'**
  String get workoutSavedPartial;

  /// No description provided for @workoutsN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 workout} other{{n} workouts}}'**
  String workoutsN(int n);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get yourData;

  /// No description provided for @yourSkills.
  ///
  /// In en, this message translates to:
  /// **'Your skills (placement test)'**
  String get yourSkills;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
