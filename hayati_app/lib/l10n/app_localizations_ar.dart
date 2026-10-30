// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get accAddRule => 'أضف التزامًا';

  @override
  String get accAgree =>
      'أوافق على هذه القاعدة، وأقدر أعدّلها أو أوقفها متى ما أبي';

  @override
  String get accAgreedConsequence => 'اللي اتفقت عليه مسبقًا';

  @override
  String accAnsweredOn(String date) {
    return 'تم الرد $date';
  }

  @override
  String get accCloseTask => 'أغلق المهمة';

  @override
  String get accConfirm => 'تأكيد';

  @override
  String get accConsequenceAsTask =>
      'بتنضاف كمهمة صغيرة لليوم، والمهمة تاخذ الموعد الجديد تحت.';

  @override
  String get accCustomEmpty => 'اكتب وش توافق تسوي';

  @override
  String get accCustomLong => 'خلّها أقل من 200 حرف';

  @override
  String get accCustomUnsafe =>
      'اختر شي ما يمس النوم أو الأكل أو الصلاة أو الرعاية الصحية، ولا يضيف تمارين';

  @override
  String accDaysLate(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n يوم تأخير',
      few: '$n أيام تأخير',
      two: 'يومين تأخير',
      one: 'يوم تأخير',
    );
    return '$_temp0';
  }

  @override
  String get accDeleteRule => 'تحذف هذا الالتزام؟';

  @override
  String get accDeleteRuleBody =>
      'المهمة تبقى، والسجل السابق يبقى بدون القاعدة.';

  @override
  String get accDropNote =>
      'ما فيه مشكلة. بتنقفل المهمة وتتوقف قاعدتها، وما يصير شي ثاني.';

  @override
  String accDue(String date) {
    return 'الموعد $date';
  }

  @override
  String get accEditRule => 'تعديل الالتزام';

  @override
  String get accEmergencyNote =>
      'الطوارئ تصير. ما فيه أي نتيجة، بس اختر موعد جديد يناسبك.';

  @override
  String get accHistory => 'اللي صار قبل';

  @override
  String get accIllnessNote =>
      'صحتك أولًا. ما فيه أي نتيجة، اختر موعد جديد لما تكون جاهز.';

  @override
  String accLateBy(int n, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'متأخرة $n يوم عن $date',
      few: 'متأخرة $n أيام عن $date',
      two: 'متأخرة يومين عن $date',
      one: 'متأخرة يوم عن $date',
    );
    return '$_temp0';
  }

  @override
  String get accMakeupPlan => 'خطة التعويض: موعد جديد';

  @override
  String accMissedOn(String date) {
    return 'كان موعدها $date';
  }

  @override
  String get accNeedsAnswer => 'تحتاج ردّك';

  @override
  String get accNewDeadline => 'الموعد الجديد';

  @override
  String accNewDue(String date) {
    return 'الموعد الجديد $date';
  }

  @override
  String get accNoBlame => 'بدون لوم. قل لنا وش صار ونعدّل سوا.';

  @override
  String get accNoEligibleTasks => 'أضف مهمة مفتوحة لها موعد نهائي أولًا.';

  @override
  String get accNoRules => 'ما فيه التزامات للحين. أضف واحد لمهمة تأجلها دايم.';

  @override
  String get accNote => 'ملاحظة (اختياري)';

  @override
  String get accOpenTask => 'افتح المهمة';

  @override
  String get accPickTask => 'اختر مهمة';

  @override
  String get accPrinciple1 => 'أنت تختار النتيجة مسبقًا.';

  @override
  String get accPrinciple2 =>
      'بس التأجيل المتعمد يجيبها، أبدًا مو الطوارئ أو المرض.';

  @override
  String get accPrinciple3 => 'ما يتغير موعد أو تنقفل مهمة بدون موافقتك.';

  @override
  String get accPrinciple4 =>
      'أبدًا ما تمس النوم أو الأكل أو الصلاة أو الرعاية الصحية أو تمارين زيادة.';

  @override
  String get accRuleRemoved => 'القاعدة انحذفت، ما فيه شي زيادة.';

  @override
  String get accRuleSaved => 'انحفظ الالتزام';

  @override
  String accRuleSummary(int days, String consequence) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'بعد $days يوم تأخير',
      few: 'بعد $days أيام تأخير',
      two: 'بعد يومين تأخير',
      one: 'بعد يوم تأخير',
    );
    return '$_temp0: $consequence';
  }

  @override
  String get accRules => 'التزاماتك';

  @override
  String get accSafety =>
      'النتائج دايم آمنة: ما تاخذ من نومك أو أكلك أو صلاتك أو رعايتك الصحية، ولا تضيف تمارين.';

  @override
  String get accSaved => 'انحفظ. شكرًا على صراحتك.';

  @override
  String get accTitle => 'التزام بلطف';

  @override
  String get accWhatHappens => 'وش يصير بعدها؟';

  @override
  String get accWhenLate => 'متى تعتبر متأخرة؟';

  @override
  String get accWhichTask => 'أي مهمة؟';

  @override
  String get accWhy => 'ليش تأخرت؟';

  @override
  String get account => 'الحساب';

  @override
  String get actionLog => 'سجل الإجراءات';

  @override
  String get actionLogSub =>
      'ما غيّره المساعد ومتى. لا يُحفظ محتوى الرسائل هنا.';

  @override
  String get active => 'نشطة';

  @override
  String activeMinutesN(int n) {
    return '$n دقيقة نشاط';
  }

  @override
  String get activityNote =>
      'الخطوات من تطبيق الصحة في جوالك (Health Connect أو Apple Health) اللي يجمع الجوال والساعة بدون تكرار. المسافة تقديرية من الخطوات والطول.';

  @override
  String get activitySaved => 'انحفظت الخطوات';

  @override
  String get activityWebNote =>
      'في المتصفح تقدر تضيف الخطوات يدويًا فقط. العد التلقائي يشتغل في تطبيق الجوال.';

  @override
  String get addAppointment => 'أضف موعد';

  @override
  String get addCup => 'أضف كوب (250 مل)';

  @override
  String get addEvent => 'إضافة موعد';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get addFirstGoal => 'أضف هدفًا';

  @override
  String get addFirstTask => 'أضف أول مهمة';

  @override
  String get addFood => 'أضف أكل';

  @override
  String get addGoal => 'إضافة هدف';

  @override
  String get addHabit => 'إضافة عادة';

  @override
  String get addMeasurement => 'أضف قياس';

  @override
  String get addMilestone => 'إضافة مرحلة';

  @override
  String get addMyOwnFood => 'أضف أكلة من عندي';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get addPastPeriod => 'أضيفي دورة سابقة';

  @override
  String get addQuestion => 'أضف سؤال';

  @override
  String get addSleep => 'أضف نوم';

  @override
  String get addStepsManually => 'أضف خطوات';

  @override
  String get addTask => 'إضافة مهمة';

  @override
  String addTo(String meal) {
    return 'أضف إلى $meal';
  }

  @override
  String get addToDay => 'أضف';

  @override
  String get adherence30 => 'آخر 30 يومًا';

  @override
  String affectedItems(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n عنصرًا متأثرًا',
      few: '$n عناصر متأثرة',
      two: 'عنصران متأثران',
      one: 'عنصر واحد متأثر',
    );
    return '$_temp0';
  }

  @override
  String get agreePrefix => 'أوافق على ';

  @override
  String aiAskAmPm(int hour) {
    return 'هل تقصد الساعة $hour صباحًا أم مساءً؟';
  }

  @override
  String get aiAutoDone =>
      'نُفّذ تلقائيًا (بحسب الصلاحية التي منحتها في إعدادات المساعد).';

  @override
  String get aiChipAddTask => 'أضف مهمة جديدة';

  @override
  String get aiChipFreeTime => 'عندي نصف ساعة، ماذا أستطيع إنجازه؟';

  @override
  String get aiChipLate => 'تأخرت اليوم، رتّب لي بقية يومي';

  @override
  String get aiChipOverdue => 'رتّب مهامي المتأخرة';

  @override
  String get aiChipPlanDay => 'خطط لي يومي';

  @override
  String get aiChipReview => 'راجع تقدمي هذا الأسبوع';

  @override
  String get aiChipSplitGoal => 'ساعدني في تقسيم هدفي';

  @override
  String aiConflictWith(String title) {
    return 'هذا يتعارض مع «$title».';
  }

  @override
  String get aiData => 'المساعد وبياناتك';

  @override
  String get aiDataBody =>
      'في هذا الإصدار يعمل المساعد بالكامل على جهازك، ولا يُرسل شيء إلى مزود ذكاء اصطناعي. عند تفعيل المساعد السحابي، تُرسل الأقسام التي تسمح بها فقط إلى المزود عبر خادمنا للرد على طلبك.';

  @override
  String get aiDisabled => 'المساعد متوقف من إعدادات المساعد.';

  @override
  String get aiDraftsDisabled =>
      'إنشاء مسودات الخطط معطّل في إعدادات المساعد، لذلك لم أجهّز تغييرات.';

  @override
  String get aiExample1 => 'أضف مهمة مراجعة الإنجليزية غدًا الساعة 8 مساءً';

  @override
  String get aiExample2 => 'أبي أتعلم الإنجليزية 30 دقيقة كل يوم';

  @override
  String get aiExample3 => 'خطط لي يومي';

  @override
  String get aiExecFailed => 'تعذر التنفيذ، ولم يتغير شيء.';

  @override
  String get aiFailed =>
      'حدث خطأ ولم أستطع الرد. رسالتك محفوظة، حاول مرة أخرى.';

  @override
  String aiFreeTime(int minutes) {
    return 'عندك $minutes دقيقة. هذه مهام تناسبها:';
  }

  @override
  String aiFreeTimeItem(String title, int minutes) {
    return '• $title ($minutes دقيقة)';
  }

  @override
  String aiFreeTimeNone(int minutes) {
    return 'لا توجد مهمة مفتوحة بمدة محددة تناسب $minutes دقيقة. جرّب تقسيم مهمة أكبر، أو خذ استراحة.';
  }

  @override
  String get aiGoalFirstWeekOnly =>
      'تُنشأ جلسات الأسبوع الأول فقط، ويمكنك إضافة المزيد لاحقًا.';

  @override
  String get aiGoalNoSubject => 'ما الذي تريد تعلمه؟';

  @override
  String aiGoalReady(String subject, int minutes, int days) {
    return 'هذه خطة لتعلم $subject: جلسات يومية مدتها $minutes دقيقة لمدة $days يومًا، مع أربع مراحل وجلسات الأسبوع الأول. لن يُنشأ شيء قبل موافقتك.';
  }

  @override
  String aiGoalTitle(String subject) {
    return 'تعلم $subject';
  }

  @override
  String get aiGymAtHome => 'هذا تمرين النادي لليوم بنسخة منزلية:';

  @override
  String get aiGymAtHomeHint =>
      'افتح الرياضة واضغط «لا أستطيع الذهاب للنادي» لتبدأها.';

  @override
  String aiHabitLogged(String name) {
    return 'سأسجّل «$name» كمنجزة اليوم.';
  }

  @override
  String aiLessonSlot(String time) {
    return 'لديك وقت فارغ قرابة $time اليوم لهذا الدرس.';
  }

  @override
  String get aiLimitReached =>
      'وصلت إلى حد استخدام المساعد اليوم. بقية التطبيق يعمل كالمعتاد، ويتجدد الحد غدًا.';

  @override
  String aiMs1(String subject) {
    return 'تحديد المستوى واختيار مصادر $subject';
  }

  @override
  String aiMs2(String subject) {
    return 'تعلم أساسيات $subject';
  }

  @override
  String aiMs3(String subject) {
    return 'ممارسة $subject بانتظام';
  }

  @override
  String aiMs4(String subject) {
    return 'إنجاز مشروع صغير أو اختبار ذاتي في $subject';
  }

  @override
  String aiNeedsSharing(String section) {
    return 'لم تسمح لي بالاطلاع على $section. يمكنك تغيير ذلك من إعدادات المساعد.';
  }

  @override
  String aiNextLesson(String title, int minutes) {
    return 'الدرس التالي: $title (حوالي $minutes دقيقة).';
  }

  @override
  String get aiNoEnglishPath =>
      'لم تبدأ مسار الإنجليزية بعد. افتح قسم الإنجليزية لتجري اختبار تحديد المستوى.';

  @override
  String get aiNoGoalToSplit =>
      'لم أجد هدفًا نشطًا بلا مراحل. أنشئ هدفًا أولًا أو أخبرني بما تريد تعلمه.';

  @override
  String get aiNoGymPlan => 'ليس لديك خطة للنادي بعد. أنشئها من قسم الرياضة.';

  @override
  String get aiNoGymToday =>
      'اليوم ليس يوم نادٍ في خطتك، فلا شيء يحتاج بديلًا.';

  @override
  String get aiNoOverdue => 'لا توجد لديك مهام متأخرة. 🎉';

  @override
  String get aiNoSlotToday =>
      'لا يوجد وقت فارغ متبقٍ اليوم، ولا بأس بالغد؛ المسار ينتظرك.';

  @override
  String get aiNoteEmpty => 'ماذا تريد أن تكتب في الملاحظة؟';

  @override
  String get aiNoteReady => 'سأحفظ هذه الملاحظة.';

  @override
  String aiOverdueSummary(int total, int today, int tomorrow) {
    return 'لديك $total مهام متأخرة. يمكنني وضع $today منها اليوم، ونقل $tomorrow إلى الغد.';
  }

  @override
  String get aiPlanEstimated => 'بعض المهام بلا مدة، فافترضت لها 30 دقيقة.';

  @override
  String get aiPlanNoEvents =>
      'لا أستطيع رؤية مواعيدك (المشاركة معطلة)، لذا قد تتعارض الخطة معها.';

  @override
  String get aiPlanNothing => 'لا توجد مهام مفتوحة للتخطيط اليوم.';

  @override
  String aiPlanSummary(int planned, int hours, int minutes) {
    return 'هذه خطة مقترحة: $planned مهام في وقتك المتاح (حوالي $hours س و$minutes د). راجعها قبل اعتمادها.';
  }

  @override
  String aiPlanUnscheduled(int n) {
    return '$n مهام لا تتسع اليوم، فكّر في نقلها أو تقليل مدتها.';
  }

  @override
  String get aiReasonGoal => 'طلبت هدف تعلم مع ممارسة منتظمة.';

  @override
  String aiReasonHabit(String name) {
    return 'ذكرت أنك أنجزت «$name».';
  }

  @override
  String get aiReasonNote => 'طلبت إضافة ملاحظة.';

  @override
  String get aiReasonOverdue =>
      'إعادة جدولة المهام المتأخرة في وقت اليوم المتاح، ونقل الباقي إلى الغد.';

  @override
  String get aiReasonPlan =>
      'توزيع مهام اليوم المفتوحة حول الالتزامات الثابتة حسب الأولوية والموعد.';

  @override
  String aiReasonSplit(String title) {
    return 'تقسيم «$title» إلى مراحل واضحة.';
  }

  @override
  String get aiReasonTask => 'طلبت إضافة مهمة.';

  @override
  String get aiRefused =>
      'لا أستطيع المساعدة في هذا الطلب. جرّب صياغته بطريقة أخرى.';

  @override
  String aiReviewFirst(int n) {
    return 'ابدأ بمراجعة سريعة لـ $n كلمات، فهي تفيد أكثر من القفز للأمام.';
  }

  @override
  String aiReviewGoal(String title, int percent) {
    return '«$title» عند $percent%.';
  }

  @override
  String aiReviewHabits(int done, int total) {
    return 'العادات: سُجّل $done من $total مرات مستحقة.';
  }

  @override
  String get aiReviewNote =>
      'هذه أرقام وصفية مما سجلته، وليست استنتاجات عن الأسباب.';

  @override
  String aiReviewOverdue(int n) {
    return '$n مهام مستحقة هذا الأسبوع ما زالت مفتوحة بعد موعدها.';
  }

  @override
  String aiReviewRate(int percent, int total) {
    return 'أنجزت $percent% من $total مهام مستحقة هذا الأسبوع.';
  }

  @override
  String aiReviewTasks(int n) {
    return 'أنجزت هذا الأسبوع $n مهام.';
  }

  @override
  String aiSessionTitle(String subject, int n) {
    return '$subject — الجلسة $n';
  }

  @override
  String aiSplitReady(String title) {
    return 'هذا تقسيم مقترح لهدف «$title».';
  }

  @override
  String get aiTaskNoTitle =>
      'ما هي المهمة؟ مثال: «أضف مهمة مراجعة الإنجليزية غدًا الساعة 8 مساءً».';

  @override
  String aiTaskReady(String title) {
    return 'سأنشئ المهمة «$title».';
  }

  @override
  String get aiTimeInPast => 'هذا الوقت قد مضى.';

  @override
  String get aiUnsupported =>
      'لا أستطيع تنفيذ ذلك بعد. يمكنني تخطيط يومك، وترتيب المهام المتأخرة، وإضافة مهام أو ملاحظات، وتسجيل العادات، وتقسيم هدف إلى مراحل، ومراجعة أسبوعك.';

  @override
  String get allCategories => 'كل الفئات';

  @override
  String get allDoneToday => 'أنجزت كل ما خططت له اليوم.';

  @override
  String get allMilestonesDone =>
      'اكتملت جميع المراحل. هل تريد تحديد الهدف كمكتمل؟';

  @override
  String get allTasks => 'كل المهام';

  @override
  String get alreadyExecuted => 'طُبّق مسبقًا، ولم يُكرَّر شيء.';

  @override
  String get alternatives => 'البدائل';

  @override
  String get alwaysRequired => 'مطلوبة دائمًا ولا يمكن تعطيلها';

  @override
  String get amount => 'المبلغ';

  @override
  String get and => 'و';

  @override
  String andMore(int n) {
    return 'و$n أخرى';
  }

  @override
  String get answerRight => 'إجابة صحيحة!';

  @override
  String answerWrong(String answer) {
    return 'الإجابة الصحيحة: $answer';
  }

  @override
  String get any => 'الكل';

  @override
  String get apCheckup => 'كشف';

  @override
  String get apFollowup => 'متابعة';

  @override
  String get apOther => 'غير ذلك';

  @override
  String get apTest => 'تحليل أو فحص';

  @override
  String get appName => 'حياتي';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get appearance => 'المظهر';

  @override
  String get applyPlan => 'اعتماد الخطة';

  @override
  String applyPlanBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'ستحصل $n مهمة على أوقات مخططة:',
      few: 'ستحصل $n مهام على أوقات مخططة:',
      two: 'ستحصل مهمتان على أوقات مخططة:',
      one: 'ستحصل مهمة واحدة على وقت مخطط:',
    );
    return '$_temp0';
  }

  @override
  String get appointmentReminderNote =>
      'التذكير يقول «موعد صحي» والوقت فقط، بدون العنوان.';

  @override
  String get appointmentTitle => 'الموعد لأيش؟';

  @override
  String get appointments => 'المواعيد الصحية';

  @override
  String get appointmentsSub => 'الفحوصات والتحاليل والأسئلة للطبيب';

  @override
  String get approvals => 'اطلب الموافقة قبل';

  @override
  String get approve => 'اعتماد';

  @override
  String get approveBulk => 'التغييرات الجماعية';

  @override
  String get approveDelete => 'حذف أي شيء';

  @override
  String get approveReschedule => 'تغيير موعد أو وقت';

  @override
  String get approveRescheduleSub =>
      'موصى به. ينطبق على التغييرات الفردية فقط.';

  @override
  String get approved => 'بموافقتك';

  @override
  String get approx => 'تقريبي';

  @override
  String approximateSwap(String from, String to) {
    return '$from ← $to (بديل تقريبي)';
  }

  @override
  String get archive => 'أرشفة';

  @override
  String get archiveGoal => 'أرشفة';

  @override
  String get archived => 'تمت الأرشفة';

  @override
  String get archivedNotes => 'الملاحظات المؤرشفة';

  @override
  String get articleDisclaimer =>
      'معلومات عامة، مو تشخيص ولا علاج. راجع الطبيب عن صحتك، واتصل بالطوارئ إذا الوضع عاجل.';

  @override
  String get articleUnavailable => 'هذا المقال مو ضمن أقسامك الصحية.';

  @override
  String get askAssistantReplan => 'اطلب من المساعد إعادة ترتيب يومي';

  @override
  String get askAssistantReview => 'اسأل المساعد';

  @override
  String get askHayati => 'اسأل مساعد حياتي';

  @override
  String get assistantDisabled => 'المساعد معطّل';

  @override
  String get assistantDisabledBody =>
      'بقية أقسام حياتي تعمل كالمعتاد. يمكنك تفعيله من الإعدادات في أي وقت.';

  @override
  String get assistantHint => 'اطلب تخطيطًا أو إضافة أو مراجعة…';

  @override
  String get assistantIntroBody =>
      'أعمل على مهامك ومواعيدك وأهدافك. أجهّز التغييرات وأنت تقرر ما يُطبّق.';

  @override
  String get assistantIntroTitle => 'كيف أساعدك اليوم؟';

  @override
  String get assistantSettings => 'إعدادات المساعد';

  @override
  String get assistantSubtitle => 'أساعدك في تنظيم وقتك وأهدافك';

  @override
  String get assistantTitle => 'مساعد حياتي';

  @override
  String assistantUsage(int used, int limit) {
    return 'المساعد اليوم: $used من $limit';
  }

  @override
  String get atTime => 'في الموعد';

  @override
  String get auto => 'تلقائي';

  @override
  String get autoActions => 'يمكنه التنفيذ دون سؤال';

  @override
  String get autoActionsSub => 'كل صلاحية مستقلة ويمكن سحبها في أي وقت.';

  @override
  String get automatic => 'تلقائي';

  @override
  String get averageCycle => 'متوسط الدورة';

  @override
  String get averagePeriod => 'متوسط أيام الدورة';

  @override
  String avgKcalPerDay(String kcal) {
    return '$kcal سعرة يوميًا بالمتوسط';
  }

  @override
  String get back => 'السابق';

  @override
  String get backToPath => 'العودة إلى المسار';

  @override
  String get barcodeInvalid => 'الباركود من 6 إلى 14 رقم';

  @override
  String barcodeN(String code) {
    return 'الباركود $code';
  }

  @override
  String get barcodeNumber => 'رقم الباركود';

  @override
  String get bedtimeReminder => 'تذكير بوقت النوم';

  @override
  String get bedtimeReminderSub => 'تنبيه تبدأ تجهّز نفسك للنوم';

  @override
  String beforeMinutes(String duration) {
    return 'قبل $duration';
  }

  @override
  String get benefit1Body =>
      'توزّع المهام حول التزاماتك الثابتة وتترك مساحة للراحة.';

  @override
  String get benefit1Title => 'خطة يومية واقعية';

  @override
  String get benefit2Body => 'يتحدث التقدم بناءً على ما تنجزه فعلًا.';

  @override
  String get benefit2Title => 'أهداف تتقدم فعلًا';

  @override
  String get benefit3Body =>
      'يقترح ويجهّز، والتغييرات الحساسة تنتظر موافقتك دائمًا.';

  @override
  String get benefit3Title => 'مساعد تتحكم فيه';

  @override
  String get bestDay => 'أفضل يوم';

  @override
  String get bestLabel => 'الأفضل';

  @override
  String get billingNote =>
      'لا تُفعّل المزايا المدفوعة إلا بعد تحقق خادمنا من الشراء عبر المتجر.';

  @override
  String get bodyweight => 'وزن الجسم';

  @override
  String get bpSeeDoctor =>
      'متوسط آخر ثلاث قراءات للضغط 140/90 أو أعلى. يستاهل تراجع فيه الطبيب.';

  @override
  String get bpUrgent =>
      'آخر قراءة 180/120 أو أعلى. إذا معك ألم في الصدر أو ضيق تنفس أو صداع شديد أو تغيّر في النظر، اطلب مساعدة عاجلة الحين. وإلا ارتاح كم دقيقة وقِس مرة ثانية، وكلّم الطبيب اليوم.';

  @override
  String bpmN(int n) {
    return '$n نبضة/د';
  }

  @override
  String get breakEnd => 'إلى';

  @override
  String get breakStart => 'الاستراحة من';

  @override
  String get budget => 'الميزانية';

  @override
  String budgetUsed(String spent, String cap) {
    return '$spent من $cap';
  }

  @override
  String get builtinNote =>
      'القيم تقديرية لحصة واحدة، والوصفات والأحجام تختلف. غيّر الكمية، أو احفظ نسختك الخاصة.';

  @override
  String get byCategory => 'حسب الفئة';

  @override
  String get byMilestones => 'بالمراحل';

  @override
  String get byMilestonesHint =>
      'التقدم = المراحل المكتملة ÷ كل المراحل. تكتمل المرحلة عند تحديدها أو عند إنجاز كل مهامها.';

  @override
  String get calendar => 'التقويم';

  @override
  String get calories => 'السعرات (كيلو كالوري)';

  @override
  String get caloriesByDay => 'السعرات حسب اليوم';

  @override
  String get caloriesToday => 'السعرات';

  @override
  String get cameraUnavailable => 'الكاميرا غير متاحة. اكتب الرقم تحت.';

  @override
  String canMoveCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n مهمة لا تتسع اليوم ويمكن نقلها دون الإضرار بأهدافك',
      few: '$n مهام لا تتسع اليوم ويمكن نقلها دون الإضرار بأهدافك',
      two: 'مهمتان لا تتسعان اليوم ويمكن نقلهما دون الإضرار بأهدافك',
      one: 'مهمة لا تتسع اليوم ويمكن نقلها دون الإضرار بأهدافك',
    );
    return '$_temp0';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get cantGoToGym => 'لا أستطيع الذهاب للنادي';

  @override
  String get carbs => 'كربوهيدرات';

  @override
  String get carbsG => 'كربوهيدرات (غ)';

  @override
  String get catHealth => 'الصحة';

  @override
  String get catLearning => 'التعلم';

  @override
  String get catMoney => 'المال';

  @override
  String get catPersonal => 'شخصي';

  @override
  String get catWork => 'العمل';

  @override
  String get category => 'التصنيف';

  @override
  String get categoryOptional => 'التصنيف (اختياري)';

  @override
  String get cefrA1 => 'A1 · مبتدئ';

  @override
  String get cefrA2 => 'A2 · أساسي';

  @override
  String get cefrB1 => 'B1 · متوسط';

  @override
  String get cefrB2 => 'B2 · فوق المتوسط';

  @override
  String changeIn30Days(String change) {
    return '$change خلال 30 يوم';
  }

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String changesCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n تغييرًا',
      few: '$n تغييرات',
      two: 'تغييران',
      one: 'تغيير واحد',
    );
    return '$_temp0';
  }

  @override
  String get checkAnswer => 'تحقق';

  @override
  String get checkFields => 'راجع الحقول';

  @override
  String get checkinScale => '1 الأقل و5 الأعلى. ينحفظ مع كل ضغطة.';

  @override
  String checkinWeek(String energy, String recovery) {
    return 'هذا الأسبوع: الطاقة $energy والتعافي $recovery بالمتوسط';
  }

  @override
  String get clear => 'مسح';

  @override
  String get clearLog => 'مسح السجل';

  @override
  String get clearRead => 'مسح المقروءة';

  @override
  String get clearanceConfirm => 'طبيبي/طبيبتي سمح لي بالتمرين';

  @override
  String get clearancePostpartum =>
      'بعد الولادة — وخصوصًا بعد القيصرية أو ولادة متعبة — ابدئي فقط بعد ما يسمح لك الطبيب. برنامج الأسابيع الأولى لطيف، والعودة التدريجية بعد فحص ما بعد الولادة.';

  @override
  String get clearancePregnancy =>
      'الرياضة أثناء الحمل غالبًا آمنة ومفيدة، لكن بعض حالات الحمل تحتاج قيود. أكّدي إن طبيبك سمح لك.';

  @override
  String get clearanceTitle => 'موافقة الطبيب أولًا';

  @override
  String get cloudModeNotice =>
      'تُحفظ بياناتك في حسابك، مع نسخة على هذا الجهاز للعمل دون اتصال.';

  @override
  String cmN(String v) {
    return '$v سم';
  }

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get commonSymptoms => 'الأعراض الأكثر تسجيلًا';

  @override
  String get completedAndArchived => 'المكتملة والمؤرشفة';

  @override
  String get completedPerDay => 'المنجز يوميًا';

  @override
  String get completionRate => 'نسبة الإنجاز';

  @override
  String completionRateDef(int done, int total) {
    return '$done من $total مستحقة في الفترة (دون الملغاة)';
  }

  @override
  String get conCustom => 'شي من اختياري';

  @override
  String get conCustomHint => 'بكلامك، بشرط تكون آمنة.';

  @override
  String get conExtraReview => 'جلسة مراجعة إضافية';

  @override
  String get conExtraReviewHint => '20 دقيقة تشوف وش اللي معطّل المهمة.';

  @override
  String get conFirstStep => 'الخطوة الأولى قبل الترفيه';

  @override
  String get conFirstStepHint =>
      'سوّ أول خطوة 15 دقيقة قبل وقت الترفيه الاختياري.';

  @override
  String get conPlanning => 'جلسة تخطيط قصيرة';

  @override
  String get conPlanningHint => '15 دقيقة تقسّم فيها المهمة لخطوات صغيرة.';

  @override
  String conTaskFirstStep(String task) {
    return 'الخطوة الأولى: $task';
  }

  @override
  String conTaskPlanning(String task) {
    return 'خطّط الخطوات: $task';
  }

  @override
  String conTaskReview(String task) {
    return 'راجع وش المعطّل: $task';
  }

  @override
  String get confirmEmailSent =>
      'أُنشئ الحساب. أرسلنا رابط تأكيد إلى بريدك، افتحه ثم سجّل الدخول.';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get conflict => 'تعارض';

  @override
  String conflictKeep(String title) {
    return 'هذا الوقت يتعارض مع «$title». هل تريد الإبقاء عليه؟';
  }

  @override
  String conflictWith(String title) {
    return 'يتعارض مع «$title»';
  }

  @override
  String get connect => 'اربط';

  @override
  String get connectInDevices => 'اربط من الأجهزة والمصادر';

  @override
  String connectStepsBody(String store) {
    return 'حياتي يقرأ مجموع خطواتك اليومي من $store. يقرأ الخطوات فقط ولا يكتب أي شي.';
  }

  @override
  String connectStepsTitle(String store) {
    return 'عدّ الخطوات تلقائيًا من $store';
  }

  @override
  String connectedTo(String store) {
    return 'مربوط مع $store';
  }

  @override
  String get contactSupport => 'التواصل مع الدعم';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get couldNotFit => 'لم يتسع لها الوقت';

  @override
  String get courseComplete => 'أكملت مستوى B2!';

  @override
  String get createAccount => 'إنشاء الحساب';

  @override
  String get createFirstPlan => 'أنشئ خطتي الأولى';

  @override
  String get createMyPlan => 'إنشاء خطتي';

  @override
  String get currency => 'العملة';

  @override
  String get currencyChangeNote => 'تحتفظ المصروفات السابقة بعملتها الأصلية.';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get currentPlan => 'خطتك الحالية';

  @override
  String get currentStreak => 'السلسلة الحالية';

  @override
  String cycleDayN(int n) {
    return 'اليوم $n من دورتك';
  }

  @override
  String get cycleDisclaimer =>
      'تقديرات من اللي سجلتيه، مو نصيحة طبية ولا وسيلة لمنع الحمل أو التخطيط له.';

  @override
  String get cycleInsights => 'تحليلات الدورة';

  @override
  String get cycleLengthOverTime => 'طول الدورة مع الوقت';

  @override
  String get cycleLocalOnly => 'خلّي بيانات الدورة على هذا الجوال فقط';

  @override
  String get cycleLocalOnlyBody =>
      'دوراتك وتسجيلات أيامك تنحذف من حسابك وتبقى على هذا الجوال. لو حذفتي التطبيق أو غيرتي الجوال تروح.';

  @override
  String get cycleLocalOnlyOff =>
      'مطفي: تنحفظ في حسابك وتطلع في الأندرويد والآيفون والموقع.';

  @override
  String get cycleLocalOnlyOn =>
      'مفعّل: ما تنحفظ في حسابك وما تطلع في أجهزتك الثانية.';

  @override
  String get cycleLocalOnlyTitle => 'تخلينها على هذا الجوال فقط؟';

  @override
  String get cycleRange => 'المدى';

  @override
  String get cycleReminders => 'تذكير قبل الدورة الجاية';

  @override
  String get cycleRemindersSub =>
      'قبل النافذة المتوقعة بيومين. يقول «تذكير من حياتي» بس.';

  @override
  String get cycleStartBody =>
      'اضغطي «بدأت اليوم» في أول يوم من الدورة، أو أضيفي الدورات السابقة من تحت.';

  @override
  String get cycleStartTitle => 'تابعي دورتك';

  @override
  String get cycleSyncBody =>
      'اللي في هذا الجوال ينرفع لحسابك ويطلع في أجهزتك الثانية.';

  @override
  String get cycleSyncTitle => 'تحفظينها في حسابك؟';

  @override
  String get cyclesCounted => 'عدد الدورات';

  @override
  String get dailyAverage => 'المتوسط اليومي';

  @override
  String get dataAccess => 'ما يمكن للمساعد الاطلاع عليه';

  @override
  String get dataAccessSub => 'تُستخدم الأقسام المفعّلة فقط للرد عليك.';

  @override
  String get date => 'التاريخ';

  @override
  String get day => 'يوم';

  @override
  String get dayEnd => 'نهاية اليوم';

  @override
  String get daySchedule => 'جدول اليوم';

  @override
  String get dayScheduleDone => 'انتهى جدول اليوم';

  @override
  String get dayStart => 'بداية اليوم';

  @override
  String daysCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n يوم',
      many: '$n يومًا',
      few: '$n أيام',
      two: 'يومان',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String daysLoggedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n يوم مسجل',
      few: '$n أيام مسجلة',
      two: 'يومين مسجلة',
      one: 'يوم مسجل',
      zero: 'ما فيه أيام مسجلة',
    );
    return '$_temp0';
  }

  @override
  String daysN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n يوم',
      few: '$n أيام',
      two: 'يومين',
      one: 'يوم',
      zero: '0 يوم',
    );
    return '$_temp0';
  }

  @override
  String daysRange(int min, int max) {
    return '$min–$max يوم';
  }

  @override
  String get deadlineDate => 'الموعد النهائي';

  @override
  String get deadlineTime => 'وقت الاستحقاق';

  @override
  String get deadlineVsPlanned =>
      'الموعد النهائي = متى يجب أن تنتهي. الوقت المخطط = متى تنوي العمل عليها.';

  @override
  String get defaultCurrency => 'العملة الافتراضية';

  @override
  String get delete => 'حذف';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConsequences =>
      'سيُحذف حسابك وكل ما فيه نهائيًا من هذا الجهاز: المهام والمواعيد والأهداف والعادات والملاحظات والمصروفات ومحادثات المساعد. لا يمكن التراجع. يُنصح بتصدير بياناتك أولًا (الخصوصية وإدارة البيانات).';

  @override
  String get deleteAccountConsequencesRemote =>
      'سيُطلب حذف حسابك وكل ما فيه نهائيًا: المهام والمواعيد والأهداف والعادات والملاحظات والمصروفات ومحادثات المساعد. ستُسجَّل خارجًا الآن وتُحذف نسخة هذا الجهاز، ويحذف الخادم الباقي وفق سياسة الاحتفاظ. لا يمكن التراجع، ويُنصح بتصدير بياناتك أولًا.';

  @override
  String get deleteAccountSub => 'إزالة حسابك وبياناتك نهائيًا';

  @override
  String get deleteAllChats => 'حذف كل المحادثات';

  @override
  String get deleteAllChatsBody =>
      'ستُحذف كل المحادثات والاقتراحات المعلقة. التغييرات المطبقة تبقى.';

  @override
  String get deleteAppointmentBody => 'ملاحظاته وأسئلته بتنحذف معه.';

  @override
  String get deleteAppointmentTitle => 'تحذف هذا الموعد؟';

  @override
  String get deleteChatBody =>
      'ستُحذف المحادثة واقتراحاتها المعلقة. التغييرات التي اعتمدتها تبقى.';

  @override
  String get deleteChatTitle => 'حذف المحادثة؟';

  @override
  String get deleteConfirmWord => 'حذف';

  @override
  String get deleteDataRequest => 'طلب حذف البيانات';

  @override
  String get deleteDataRequestSub => 'يتم بحذف الحساب';

  @override
  String deleteEventBody(String title) {
    return 'سيُحذف «$title» نهائيًا.';
  }

  @override
  String get deleteEventTitle => 'حذف الموعد؟';

  @override
  String get deleteExpenseBody => 'سيُحذف هذا المصروف.';

  @override
  String get deleteExpenseTitle => 'حذف المصروف؟';

  @override
  String get deleteFood => 'تحذف هذي الأكلة؟';

  @override
  String get deleteFoodBody => 'الوجبات المسجلة فيها تبقى مثل ما هي.';

  @override
  String get deleteForever => 'حذف نهائي';

  @override
  String get deleteGoalBody =>
      'سيُحذف الهدف ومراحله. ستبقى المهام المرتبطة وتُفك من الهدف.';

  @override
  String get deleteGoalTitle => 'حذف الهدف؟';

  @override
  String get deleteHabitBody =>
      'ستُحذف العادة وسجلها بالكامل. يمكنك جعلها غير نشطة بدلًا من ذلك.';

  @override
  String get deleteHabitTitle => 'حذف العادة؟';

  @override
  String get deleteHealthData => 'حذف البيانات الصحية';

  @override
  String get deleteHealthDataBody =>
      'الخطوات والنوم والنبض وتمارين الساعة والأكل والماء والدورة والمواعيد تنحذف من كل أجهزتك. وما تقدر ترجعها.';

  @override
  String get deleteHealthDataSub => 'الأقسام الصحية بس، وباقي حسابك يبقى';

  @override
  String get deleteHealthDataTitle => 'تحذف كل البيانات الصحية؟';

  @override
  String get deleteNoteBody =>
      'ستُحذف الملاحظة نهائيًا. يمكنك أرشفتها بدلًا من ذلك.';

  @override
  String get deleteNoteTitle => 'حذف الملاحظة؟';

  @override
  String get deletePeriodBody => 'التقديرات بتنحسب من جديد بدونها.';

  @override
  String get deletePeriodTitle => 'تحذفين هذي الدورة؟';

  @override
  String deleteTaskBody(String title) {
    return 'ستُحذف «$title» نهائيًا. يمكنك أرشفتها بدلًا من ذلك.';
  }

  @override
  String get deleteTaskTitle => 'حذف المهمة؟';

  @override
  String get deleteWorkoutBody => 'ستُحذف المجموعات المسجلة فيه.';

  @override
  String get deleteWorkoutTitle => 'حذف هذا التمرين؟';

  @override
  String get deleted => 'تم الحذف';

  @override
  String get deletionRequested =>
      'سُجّل طلب الحذف، وستُزال بيانات حسابك من خوادمنا.';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get details => 'التفاصيل';

  @override
  String get devNotifBody => 'تصلك التذكيرات حتى لو كان التطبيق مغلقًا.';

  @override
  String get devNotifBodyWeb =>
      'اعرض التذكيرات كإشعارات المتصفح أثناء فتح التطبيق.';

  @override
  String get devNotifDenied =>
      'الإشعارات محظورة. لتصلك التذكيرات، اسمح بها لتطبيق حياتي من إعدادات جهازك أو متصفحك.';

  @override
  String get devNotifEnable => 'تفعيل';

  @override
  String get devNotifOn =>
      'مفعّلة — تصلك التذكيرات حتى والتطبيق مغلق (قد تتأخر دقائق قليلة).';

  @override
  String get devNotifOnWeb =>
      'مفعّلة — يعرض المتصفح التذكيرات أثناء فتح التطبيق فقط.';

  @override
  String get devNotifTitle => 'إشعارات الجهاز';

  @override
  String get devicesPrivacy =>
      'حياتي يقرأ فقط وما يكتب شي، ويقرأ اللي تشغّله بس. الأرقام تنحفظ في حسابك عشان تشوفها أجهزتك الثانية.';

  @override
  String devicesStoreBody(String store) {
    return 'هذا الجوال يقرأ من $store، اللي يجمع ما تسجله ساعتك وميزانك وتطبيقاتك. اختر وش تبي يجيب.';
  }

  @override
  String get devicesSub => 'الساعة والنوم والنبض ومن وين يجي كل رقم';

  @override
  String get devicesTitle => 'الأجهزة والمصادر';

  @override
  String get devicesWebBody =>
      'الربط يصير من تطبيق حياتي على الجوال: يقرأ من Health Connect في الأندرويد أو Apple Health في الآيفون، واللي يجيبه يطلع هنا بعد.';

  @override
  String get diastolic => 'الواطي (الانبساطي)';

  @override
  String get didYouEat => 'هل هي وحدة من هذي؟';

  @override
  String get diffEasy => 'سهل';

  @override
  String get diffHard => 'صعب';

  @override
  String get diffMedium => 'متوسط';

  @override
  String get discard => 'تجاهل';

  @override
  String get discardMessage =>
      'لديك تعديلات غير محفوظة. هل تريد الخروج دون حفظ؟';

  @override
  String get discardTitle => 'تجاهل التعديلات؟';

  @override
  String get disconnect => 'افصل';

  @override
  String get disconnectBody =>
      'الجوال يوقف القراءة. اللي انجاب يبقى، وتقدر تحذفه من تحت المصدر.';

  @override
  String get disconnectThisPhone => 'وقّف القراءة على هذا الجوال';

  @override
  String disconnectTitle(String store) {
    return 'توقف القراءة من $store؟';
  }

  @override
  String get dismiss => 'إخفاء';

  @override
  String get displayName => 'الاسم المعروض';

  @override
  String get displayNameOptional => 'اسمك (اختياري)';

  @override
  String distanceKm(String km) {
    return '$km كم';
  }

  @override
  String get documents => 'المستندات';

  @override
  String get done => 'تم';

  @override
  String get doneDays => 'منجز / مستحق';

  @override
  String get drEmergency => 'ظرف طارئ';

  @override
  String get drIllness => 'كنت مريض';

  @override
  String get drNotImportant => 'ما عادت مهمة';

  @override
  String get drPostponed => 'أجّلتها بنفسي';

  @override
  String get dragHint => 'اضغط مطولًا واسحب المهمة إلى ساعة لجدولتها.';

  @override
  String get due => 'الاستحقاق';

  @override
  String get dueShort => 'تستحق';

  @override
  String get edit => 'تعديل';

  @override
  String get editAppointment => 'تعديل الموعد';

  @override
  String get editEvent => 'تعديل الموعد';

  @override
  String get editFood => 'تعديل الأكلة';

  @override
  String get editGoal => 'الهدف';

  @override
  String get editHabit => 'تعديل العادة';

  @override
  String get editMilestone => 'تعديل المرحلة';

  @override
  String get editPlan => 'تعديل الخطة';

  @override
  String get editTask => 'تعديل المهمة';

  @override
  String effort(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '1': 'سهل',
      '2': 'سهل نسبيًا',
      '3': 'متوسط',
      '4': 'صعب',
      'other': 'صعب جدًا',
    });
    return '$_temp0';
  }

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailNotVerified => 'لم يُؤكَّد بعد';

  @override
  String get emailPassword => 'البريد وكلمة المرور';

  @override
  String get emailVerification => 'التحقق من البريد';

  @override
  String get emailVerified => 'مؤكَّد';

  @override
  String get emptyAll => 'لا توجد مهام بعد.';

  @override
  String get emptyArchived => 'لا يوجد شيء مؤرشف.';

  @override
  String get emptyCompleted => 'لا توجد مهام مكتملة بعد.';

  @override
  String get emptyOverdue => 'لا توجد مهام متأخرة.';

  @override
  String get emptyToday => 'لا يوجد شيء مستحق اليوم. أضف مهمة أو خطط مسبقًا.';

  @override
  String get emptyTodayDone => 'أنهيت جميع مهام اليوم. عمل رائع!';

  @override
  String get emptyUpcoming => 'لا توجد مهام قادمة لها موعد نهائي.';

  @override
  String get enableAssistant => 'المساعد الذكي';

  @override
  String get enableAssistantSub =>
      'تعطيله لا يؤثر في المهام أو التقويم أو بقية التطبيق.';

  @override
  String get endTime => 'النهاية';

  @override
  String get energy => 'الطاقة';

  @override
  String energyN(int n) {
    return 'طاقة $n/5';
  }

  @override
  String get energySplit => 'مصدر الطاقة (متوسط يومي)';

  @override
  String get englishIntroBody =>
      'اختبار قصير يحدد مستواك في المفردات والقواعد والقراءة، ثم درس يومي ومراجعة لما تعلمته.';

  @override
  String get englishIntroTitle => 'الإنجليزية خطوة بخطوة';

  @override
  String englishLessonItem(String title) {
    return 'الإنجليزية: $title';
  }

  @override
  String get eoAccepted => 'قبلت النتيجة';

  @override
  String get eoDropped => 'انقفلت المهمة';

  @override
  String get eoPending => 'بالانتظار';

  @override
  String get eoRescheduled => 'تأجلت بدون نتيجة';

  @override
  String get eqBands => 'حبال مطاطية';

  @override
  String get eqBench => 'بنش';

  @override
  String get eqDumbbells => 'دمبلز';

  @override
  String get eqKettlebell => 'كيتلبل';

  @override
  String get eqPullupBar => 'عقلة';

  @override
  String get errAgree => 'يرجى الموافقة على الشروط وسياسة الخصوصية';

  @override
  String get errCredentials => 'البريد أو كلمة المرور غير صحيحة';

  @override
  String get errCurrentPassword => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get errEmail => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get errEmailExists => 'يوجد حساب مسجل بهذا البريد';

  @override
  String get errEmailNotConfirmed =>
      'يرجى تأكيد بريدك أولًا عبر الرابط الذي أرسلناه.';

  @override
  String get errEndBeforeStart => 'يجب أن يكون وقت النهاية بعد البداية';

  @override
  String get errNetwork => 'مشكلة في الاتصال. حاول مرة أخرى.';

  @override
  String get errPasswordMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get errPasswordWeak =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل وتحتوي على حرف ورقم';

  @override
  String get errPickDays => 'اختر يومًا واحدًا على الأقل';

  @override
  String get errPositiveAmount => 'أدخل مبلغًا أكبر من صفر';

  @override
  String get errPositiveMinutes => 'أدخل عدد دقائق بين 1 و1440';

  @override
  String errRange(int max) {
    return 'بين 0 و$max';
  }

  @override
  String get errRateLimited => 'محاولات كثيرة. انتظر قليلًا ثم حاول مرة أخرى.';

  @override
  String get errRequired => 'هذا الحقل مطلوب';

  @override
  String get errSave => 'تعذر الحفظ. راجع الحقول وحاول مرة أخرى.';

  @override
  String get errSex => 'اختر ذكر أو أنثى';

  @override
  String get errTargetBeforeStart =>
      'يجب أن يكون التاريخ المستهدف بعد تاريخ البداية';

  @override
  String get estimateNote => 'تقدير — الحصص والوصفات تختلف.';

  @override
  String get estimatedDuration => 'مدة مقترحة 30 د';

  @override
  String get estimatedMinutes => 'المدة التقديرية (بالدقائق)';

  @override
  String get estimatedPill => 'مدة تقديرية';

  @override
  String estimatedWindow(String from, String to) {
    return 'النافذة المتوقعة: $from – $to';
  }

  @override
  String get eventTitle => 'عنوان الموعد';

  @override
  String get eventsLabel => 'المواعيد';

  @override
  String get everyDay => 'كل يوم';

  @override
  String everyMinutes(int m) {
    return 'كل $m دقيقة';
  }

  @override
  String get examples => 'أمثلة';

  @override
  String get execute => 'تنفيذ';

  @override
  String executedCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'تم — طُبّق $n تغييرًا',
      few: 'تم — طُبّقت $n تغييرات',
      two: 'تم — طُبّق تغييران',
      one: 'تم — طُبّق تغيير واحد',
    );
    return '$_temp0';
  }

  @override
  String exerciseCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n تمرينًا',
      few: '$n تمارين',
      two: 'تمرينان',
      one: 'تمرين واحد',
    );
    return '$_temp0';
  }

  @override
  String get expBills => 'الفواتير';

  @override
  String get expEducation => 'التعليم';

  @override
  String get expEntertainment => 'الترفيه';

  @override
  String get expFood => 'الطعام';

  @override
  String get expOther => 'أخرى';

  @override
  String get expShopping => 'التسوق';

  @override
  String get expTransport => 'النقل';

  @override
  String get expenseList => 'قائمة المصروفات';

  @override
  String get expensesManualNote =>
      'تُسجّل المصروفات يدويًا، ولا يُربط أي حساب بنكي.';

  @override
  String get explanation => 'الشرح';

  @override
  String exportCopied(int chars) {
    return 'تم النسخ ($chars حرفًا)';
  }

  @override
  String get exportData => 'تصدير بياناتي';

  @override
  String get exportDataSub => 'ينسخ كل بياناتك بصيغة JSON إلى الحافظة';

  @override
  String get exportHealthData => 'تصدير البيانات الصحية';

  @override
  String get exportHealthDataSub =>
      'الخطوات والنوم والأكل والدورة والمواعيد، تنسخ كملف JSON';

  @override
  String get extraLesson => 'درس إضافي';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get faq1a =>
      'الموعد النهائي هو متى يجب أن تنتهي المهمة. الوقت المخطط هو متى تنوي العمل عليها، ويضبطه المخطط ويمكنك تغييره.';

  @override
  String get faq1q => 'ما الفرق بين الموعد النهائي والوقت المخطط؟';

  @override
  String get faq2a =>
      'يستخدم كل هدف طريقة واحدة: المراحل المكتملة ÷ كل المراحل، أو نسبة تحددها يدويًا. لا يُعد الهدف مكتملًا لمجرد مرور تاريخه.';

  @override
  String get faq2q => 'كيف يُحسب تقدم الهدف؟';

  @override
  String get faq3a =>
      'فقط ما تسمح به في إعدادات المساعد، مثل إنشاء مهمة واحدة. الحذف والتغييرات الجماعية وإعادة جدولة عدة عناصر تحتاج موافقتك دائمًا.';

  @override
  String get faq3q => 'ماذا يستطيع المساعد فعله وحده؟';

  @override
  String get faq4a =>
      'فعّل إشعارات الجهاز من شاشة الإشعارات أو الإعدادات، وأضف للمهمة تذكيرًا مع موعد نهائي أو وقت مخطط. على الجوال تصلك التذكيرات حتى والتطبيق مغلق (قد تتأخر دقائق قليلة)، وفي المتصفح تظهر فقط أثناء فتح التطبيق.';

  @override
  String get faq4q => 'لا تصلني التذكيرات';

  @override
  String get faq5a =>
      'في الوضع المحلي على هذا الجهاز فقط. يمكنك تصديرها في أي وقت من الخصوصية وإدارة البيانات.';

  @override
  String get faq5aRemote =>
      'في حسابك على خوادمنا، محمية بحيث لا يقرؤها غيرك، مع نسخة على هذا الجهاز للعمل دون اتصال. يمكنك تصديرها في أي وقت من الخصوصية وإدارة البيانات.';

  @override
  String get faq5q => 'أين تُحفظ بياناتي؟';

  @override
  String get fat => 'دهون';

  @override
  String get fatG => 'دهون (غ)';

  @override
  String get fatigue => 'التعب';

  @override
  String get featAdvancedReports => 'تقارير وتحليلات أكثر تفصيلًا';

  @override
  String featAssistantLimited(int limit) {
    return 'المساعد: حتى $limit طلبًا يوميًا';
  }

  @override
  String get featBasicReports => 'تقارير أسبوعية أساسية';

  @override
  String get featCore =>
      'المهام والتقويم والأهداف والعادات والملاحظات والمصروفات';

  @override
  String get featMoreAssistant => 'استخدام أكبر للمساعد';

  @override
  String get featSmartPlanning => 'تخطيط ذكي متقدم';

  @override
  String get featTemplates => 'قوالب جاهزة للأهداف';

  @override
  String feltLike(String effort) {
    return 'الإحساس: $effort';
  }

  @override
  String get fgDairy => 'الألبان';

  @override
  String get fgDishes => 'الأطباق';

  @override
  String get fgDrinks => 'المشروبات';

  @override
  String get fgExtras => 'الإضافات';

  @override
  String get fgFatLoss => 'خسارة الدهون';

  @override
  String get fgFatLossHint =>
      'تمارين قوة مع نشاط هوائي. الغذاء هو الأهم، والتطبيق لا يقدم نصائح غذائية.';

  @override
  String get fgFruit => 'الفواكه';

  @override
  String get fgGeneral => 'لياقة عامة';

  @override
  String get fgGeneralHint => 'توازن بين القوة والنشاط الهوائي والحركة.';

  @override
  String get fgGrains => 'الخبز والحبوب';

  @override
  String get fgMobility => 'المرونة والحركة';

  @override
  String get fgMobilityHint => 'حصص لطيفة للمرونة والقوام والتعافي.';

  @override
  String get fgMuscle => 'بناء العضلات';

  @override
  String get fgMuscleHint => 'تكرارات متوسطة وحجم أسبوعي كافٍ لكل عضلة.';

  @override
  String get fgProtein => 'اللحوم والسمك والبيض';

  @override
  String get fgSnacks => 'السناكات والحلويات';

  @override
  String get fgStrength => 'زيادة القوة';

  @override
  String get fgStrengthHint =>
      'تكرارات أقل وراحة أطول وتقدم ثابت في التمارين الأساسية.';

  @override
  String get fgVegetables => 'الخضار';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterArchived => 'المؤرشفة';

  @override
  String get filterCompleted => 'المكتملة';

  @override
  String get filterOverdue => 'المتأخرة';

  @override
  String get filterToday => 'اليوم';

  @override
  String get filterUpcoming => 'القادمة';

  @override
  String get finishSetup => 'إنهاء الإعداد';

  @override
  String get finishWorkout => 'إنهاء التمرين';

  @override
  String get fitnessIntroBody =>
      'أجب عن أسئلة قليلة لتحصل على خطة للمنزل أو النادي أو كليهما، مع بدائل عند غياب المعدات.';

  @override
  String get fitnessIntroTitle => 'تمارين تناسب أسبوعك';

  @override
  String get fitnessSafety =>
      'يقدم التطبيق إرشادات تمارين عامة وليست نصيحة طبية. إن كانت لديك إصابة أو حالة صحية فاستشر مختصًا أولًا، وتوقف عند الشعور بالألم.';

  @override
  String get fitnessSetupTitle => 'خطتك الرياضية';

  @override
  String get fixedBlocks => 'التزامات ثابتة';

  @override
  String get fixedCommitments => 'الالتزامات الثابتة';

  @override
  String get flAdvanced => 'متقدم';

  @override
  String get flBeginner => 'مبتدئ';

  @override
  String get flIntermediate => 'متوسط';

  @override
  String get flow => 'الغزارة';

  @override
  String get flowHeavy => 'غزيرة';

  @override
  String get flowLight => 'خفيفة';

  @override
  String get flowMedium => 'متوسطة';

  @override
  String get flowNone => 'ما فيه';

  @override
  String get focusConditioning => 'لياقة هوائية';

  @override
  String get focusFullBody => 'الجسم كامل';

  @override
  String get focusLower => 'الجزء السفلي';

  @override
  String get focusMobility => 'مرونة وتعافٍ';

  @override
  String get focusUpper => 'الجزء العلوي';

  @override
  String foodAdded(String name) {
    return 'انضافت $name';
  }

  @override
  String get foodAndWater => 'الأكل والماء';

  @override
  String get foodName => 'الاسم';

  @override
  String get foodNoneYet => 'ما سجّلت أكل اليوم';

  @override
  String get foodRemoved => 'انحذفت';

  @override
  String get foodSaved => 'انحفظت في أكلاتك';

  @override
  String get forgotLocalMode =>
      'في هذا الإصدار تُحفظ الحسابات على هذا الجهاز فقط، لذا فإن استعادة كلمة المرور عبر البريد غير متاحة بعد. ستُفعّل عند ربط خدمة الحسابات السحابية.';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get forgotRemoteBody =>
      'أدخل بريدك وسنرسل لك رابطًا لتعيين كلمة مرور جديدة.';

  @override
  String get forgotTitle => 'استعادة الوصول';

  @override
  String get freeTime => 'الوقت المتاح';

  @override
  String get freeTimeNow => 'وقت حر';

  @override
  String get from => 'من';

  @override
  String get fromGallery => 'من المعرض';

  @override
  String get fromYourDevices => 'من ساعتك وتطبيقاتك';

  @override
  String get fsDays => 'عدد الأيام في الأسبوع';

  @override
  String get fsEquipment => 'المعدات في المنزل';

  @override
  String get fsEquipmentHint => 'اتركها فارغة للتمارين بوزن الجسم فقط.';

  @override
  String get fsGoal => 'ما هدفك الأساسي؟';

  @override
  String get fsLevel => 'مستوى خبرتك';

  @override
  String get fsMinutes => 'مدة الحصة';

  @override
  String fsPickDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'اختر $n يومًا آخر',
      few: 'اختر $n أيام أخرى',
      two: 'اختر يومين آخرين',
      one: 'اختر يومًا آخر',
    );
    return '$_temp0';
  }

  @override
  String get fsPlaces => 'أين ستتمرن؟';

  @override
  String get fsPlacesHint =>
      'اختر الاثنين لتحصل على خطتين وتنتقل بينهما في أي يوم.';

  @override
  String fsWhichDays(int n) {
    return 'اختر $n أيام';
  }

  @override
  String get futureDay => 'للحين ما جا';

  @override
  String get futureDayBody => 'تقدرين تسجلين اليوم لما يجي.';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get goBackOver => 'راجع هذه الدروس:';

  @override
  String get goalActive => 'نشط';

  @override
  String get goalArchived => 'مؤرشف';

  @override
  String get goalCompleted => 'مكتمل';

  @override
  String get goalDays => 'أيام تحقيق الهدف';

  @override
  String get goalPaused => 'متوقف';

  @override
  String get goalStepHint => 'اختر مثالًا أو اكتب هدفك. يمكنك تخطي هذه الخطوة.';

  @override
  String get goalStreak => 'أيام متتالية';

  @override
  String get goalTitle => 'عنوان الهدف';

  @override
  String get goalTitleHint => 'مثال: تعلم أساسيات Flutter';

  @override
  String get goalsEmptyBody =>
      'يمكن أن يكون للهدف مراحل ومهام مرتبطة، ويتحدث التقدم بحسب ما تنجزه.';

  @override
  String get goalsProgress => 'تقدم الأهداف';

  @override
  String get goalsSummary => 'ملخص الأهداف';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String gramsN(String g) {
    return '$g غ';
  }

  @override
  String get gramsOptional => 'الوزن بالغرام (اختياري)';

  @override
  String get habitAdherence => 'الالتزام بالعادات';

  @override
  String habitAdherenceDef(int done, int total) {
    return '$done من $total أيام مستحقة (دون غير المستحقة)';
  }

  @override
  String get habitDone => 'تم';

  @override
  String get habitDoneToday => 'تمت اليوم';

  @override
  String get habitDueToday => 'مستحقة اليوم';

  @override
  String get habitName => 'اسم العادة';

  @override
  String get habitNotDueToday => 'غير مستحقة اليوم';

  @override
  String habitsDoneOf(int done, int total) {
    return 'سُجّل $done من $total اليوم';
  }

  @override
  String get habitsEmptyBody =>
      'أضف عادة واختر الأيام المطلوبة فيها. الأيام غير المطلوبة لا تُحسب ضدك أبدًا.';

  @override
  String get hanafiAsr => 'العصر على المذهب الحنفي';

  @override
  String get hanafiAsrHint => 'وقت عصر متأخر (ظل الشيء مثليه).';

  @override
  String get hasBreak => 'إضافة استراحة يومية';

  @override
  String get hasWorkHours => 'لدي ساعات عمل أو دراسة ثابتة';

  @override
  String get haveAccount => 'لدي حساب';

  @override
  String get healthDataDeleted => 'انحذفت البيانات الصحية';

  @override
  String get healthDataTitle => 'بياناتك الصحية';

  @override
  String get healthLearn => 'توعية صحية';

  @override
  String get healthLearnSub => 'مقالات قصيرة من جهات صحية موثوقة';

  @override
  String get healthLock => 'القفل بالبصمة أو رمز الجوال';

  @override
  String get healthLockSub =>
      'الأقسام الصحية ما تنفتح إلا بقفل جوالك، وتنقفل من جديد لما تطلع من التطبيق.';

  @override
  String get healthLockUnavailable =>
      'غير متاح هنا: فعّل قفل الشاشة في جوالك أول. وفي الموقع كلمة مرور حسابك تحميه.';

  @override
  String get healthLocked => 'مقفول';

  @override
  String get healthLockedBody => 'افتحه ببصمتك أو وجهك أو رمز جوالك.';

  @override
  String get healthPermissionDenied =>
      'ما انعطى الإذن. تقدر تسمح فيه من إعدادات تطبيق الصحة.';

  @override
  String get healthPrivacy => 'خصوصية الصحة';

  @override
  String get healthPrivacyNote =>
      'بيانات الدورة ما تنشارك مع المساعد أبد، وتذكيراتها ما تقول عن أيش. وصحة المرأة تطلع فقط للحسابات المسجلة أنثى.';

  @override
  String get healthPrivacySub =>
      'القفل والشاشة الرئيسية والتذكيرات والتصدير والحذف';

  @override
  String get healthSections => 'الأقسام الصحية';

  @override
  String get healthSectionsNote =>
      'الأقسام المكتوب عليها «قريبًا» ينحفظ اختيارك لها وتظهر لما تجهز.';

  @override
  String get healthSetup => 'إعداد الصحة';

  @override
  String heartDaysN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'نبض $n يوم',
      few: 'نبض $n أيام',
      two: 'نبض يومين',
      one: 'نبض يوم',
    );
    return '$_temp0';
  }

  @override
  String get heartNote => 'قراءة ساعتك، لمتابعتك الشخصية. مو فحص طبي.';

  @override
  String get heightCm => 'الطول (سم)';

  @override
  String get heightForDistance => 'الطول';

  @override
  String get heightHelp => 'اختياري — يقرّب تقدير المسافة';

  @override
  String get heightInvalid => 'بين 80 و250 سم';

  @override
  String get helpTitle => 'المساعدة والدعم';

  @override
  String get hideFromHome => 'إخفاء من الشاشة الرئيسية';

  @override
  String get hideFromHomeSub => 'صحة المرأة ما تطلع في «يومي».';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get highlights => 'أبرز الإنجازات';

  @override
  String get history => 'السجل';

  @override
  String get historyHint =>
      'اضغط على يوم سابق لتصحيحه. الأيام غير المستحقة محايدة.';

  @override
  String get hkBody => 'الوزن والضغط';

  @override
  String get hkBodySub => 'قراءات الميزان الذكي أو جهاز الضغط';

  @override
  String get hkHeartRate => 'نبض الراحة';

  @override
  String get hkHeartRateSub => 'قيمة وحدة باليوم مثل ما تقيسها ساعتك';

  @override
  String get hkSleep => 'النوم';

  @override
  String get hkSleepSub => 'متى نمت وكم نمت';

  @override
  String get hkSteps => 'الخطوات';

  @override
  String get hkStepsSub => 'المجموع اليومي من الجوال وأي ساعة';

  @override
  String get hkWorkouts => 'التمارين';

  @override
  String get hkWorkoutsSub => 'الجري والمشي والسباحة وغيرها مما سجلته ساعتك';

  @override
  String get hmActivity => 'الخطوات والنشاط';

  @override
  String get hmMens => 'صحة الرجل';

  @override
  String get hmNutrition => 'الأكل والسعرات';

  @override
  String get hmSleep => 'النوم والتعافي';

  @override
  String get hmWomens => 'صحة المرأة';

  @override
  String get homeInstead => 'في المنزل بدلًا من النادي';

  @override
  String get homeSections => 'الصفحة الرئيسية';

  @override
  String get homeVersionBody =>
      'استُبدلت التمارين بما يمكنك أداؤه بمعداتك المنزلية. ليس لكل تمرين بديل مطابق تمامًا.';

  @override
  String get homeVersionTitle => 'تمرين النادي لليوم في المنزل';

  @override
  String get homeViewGoals => 'الأهداف';

  @override
  String get homeViewToday => 'اليوم';

  @override
  String get homeViewWeek => 'الأسبوع';

  @override
  String get howDidItFeel => 'كيف كان التمرين؟ (اختياري)';

  @override
  String get howIsToday => 'كيف يومك؟';

  @override
  String get howIsTodaySub => 'الغزارة والألم والأعراض والمزاج والطاقة';

  @override
  String get howMuch => 'كم الكمية؟';

  @override
  String get howRested => 'كيف حاسّ اليوم؟';

  @override
  String get howTo => 'طريقة الأداء';

  @override
  String inDuration(String duration) {
    return 'بعد $duration';
  }

  @override
  String get inactiveHabits => 'غير نشطة';

  @override
  String get includeTechInfo => 'إرفاق معلومات تقنية';

  @override
  String get initialTasks => 'المهام الأولية';

  @override
  String get install => 'ثبّت';

  @override
  String get installHealthConnect => 'ثبّت Health Connect';

  @override
  String get installHealthConnectBody =>
      'أندرويد يحفظ خطوات الجوال والساعة في Health Connect. ثبّته أو حدّثه وارجع اربطه.';

  @override
  String get interestsHint =>
      'اختر ما يناسبك، ويمكنك التغيير لاحقًا. الأقسام غير المختارة تُخفى ولا تُحذف.';

  @override
  String get irregularNote =>
      'دوراتك المسجلة تختلف كثير، أو بعضها قصير أو طويل بشكل غير معتاد. هذا لحاله ما يعني إن فيه مشكلة، بس يستاهل تذكرينه للطبيبة.';

  @override
  String get itemGone => 'هذا العنصر لم يعد موجودًا.';

  @override
  String get kcalGoalOn => 'هدف سعرات يومي';

  @override
  String get kcalGoalSub => 'اختياري. حط رقمك أنت، التطبيق ما يقترح رقم.';

  @override
  String kcalN(String kcal) {
    return '$kcal سعرة';
  }

  @override
  String kcalOfGoal(String kcal, String goal) {
    return '$kcal / $goal سعرة';
  }

  @override
  String get keepAnyway => 'الإبقاء عليه';

  @override
  String get keepChats => 'الاحتفاظ بالمحادثات';

  @override
  String kgN(String v) {
    return '$v كغ';
  }

  @override
  String kgTimesReps(String kg, int reps) {
    return '$kg كغ × $reps';
  }

  @override
  String get kindAssistant => 'المساعد';

  @override
  String get kindBug => 'خلل';

  @override
  String get kindNotifications => 'الإشعارات';

  @override
  String get kindOther => 'أخرى';

  @override
  String get language => 'اللغة';

  @override
  String get lastLabel => 'الأخير';

  @override
  String get lastSevenDays => 'آخر 7 أيام';

  @override
  String lastSyncAt(String time) {
    return 'آخر مزامنة $time';
  }

  @override
  String get lastTwoWeeks => 'آخر أسبوعين';

  @override
  String get lastWeek => 'الأسبوع الماضي';

  @override
  String latestOn(String date) {
    return 'آخر شي: $date';
  }

  @override
  String get learnIntro =>
      'قراءات قصيرة وعامة من جهات صحية رسمية. مو نصيحة شخصية لك، والطبيب هو اللي يقول لك وش يناسبك.';

  @override
  String get leave => 'خروج';

  @override
  String get leaveTestBody => 'ستضيع إجاباتك حتى الآن.';

  @override
  String get leaveTestTitle => 'الخروج من الاختبار؟';

  @override
  String get leaveWithoutSaving => 'الخروج دون حفظ';

  @override
  String get legendEstimated => 'متوقعة';

  @override
  String get legendLogged => 'يوم مسجّل';

  @override
  String get legendPeriod => 'الدورة';

  @override
  String get less => 'أقل';

  @override
  String get lessonAgain =>
      'لم تتقنه بعد (المطلوب 80%). سنعيد هذا الدرس قبل الانتقال.';

  @override
  String get lessonDoneToday => 'أنجزت درس الإنجليزية اليوم';

  @override
  String get lessonMastered => 'أتقنت الدرس. إلى التالي!';

  @override
  String lessonMinutes(int n) {
    return 'حوالي $n دقيقة';
  }

  @override
  String get levelCheckBody =>
      'أتقنت كل دروس هذا المستوى. أجرِ اختبار المستوى للانتقال.';

  @override
  String get levelCheckIntro =>
      'أسئلة من هذا المستوى. تحتاج 75% للانتقال، وإلا سنرشدك للدروس التي تحتاج مراجعة.';

  @override
  String get levelCheckReady => 'اختبار المستوى جاهز';

  @override
  String levelCheckTitle(String level) {
    return 'اختبار المستوى: $level';
  }

  @override
  String levelComplete(String level) {
    return 'اكتملت دروس $level';
  }

  @override
  String levelLessons(String level) {
    return 'دروس $level';
  }

  @override
  String levelNotYet(String level) {
    return 'لم تجتز بعد: $level';
  }

  @override
  String levelPassed(String level) {
    return 'اجتزت: $level';
  }

  @override
  String levelUp(String level) {
    return 'انتقلت إلى $level!';
  }

  @override
  String get limit => 'الحد';

  @override
  String get linkTask => 'ربط مهمة';

  @override
  String get linkedGoal => 'الهدف';

  @override
  String get linkedGoalOptional => 'الهدف المرتبط (اختياري)';

  @override
  String get linkedMilestoneOptional => 'المرحلة (اختياري)';

  @override
  String get linkedTasks => 'المهام المرتبطة';

  @override
  String get localModeNotice =>
      'الوضع المحلي: حسابك وبياناتك محفوظة على هذا الجهاز.';

  @override
  String get locationDenied =>
      'لم يُسمح بالوصول إلى الموقع. يمكنك اختيار مدينة بدلًا من ذلك.';

  @override
  String get locationError => 'تعذّر تحديد موقعك. حاول مرة أخرى أو اختر مدينة.';

  @override
  String get locationOff => 'خدمات الموقع متوقفة على هذا الجهاز.';

  @override
  String get locationOptional => 'المكان (اختياري)';

  @override
  String get locationPrivacy =>
      'يُستخدم موقعك لحساب المواقيت فقط، ويُحفظ كإحداثيات في إعداداتك.';

  @override
  String get lookUp => 'ابحث';

  @override
  String get lookupNetwork =>
      'ما قدرنا نوصل لقاعدة المنتجات. تأكد من النت وجرّب مرة ثانية.';

  @override
  String macroLine(String kcal, String p, String c, String f) {
    return '$kcal سعرة · ب $p · ك $c · د $f';
  }

  @override
  String get manageAssistantAccess => 'إدارة صلاحيات المساعد';

  @override
  String get manageDevices => 'الأجهزة والمصادر';

  @override
  String get manual => 'يدويًا';

  @override
  String get manualHint => 'أنت من يحدد النسبة بنفسك.';

  @override
  String get manualStepsNote =>
      'إذا كان تطبيق الجوال مربوط، يُعتمد رقمه لهذا اليوم.';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String markDone(String title) {
    return 'تحديد «$title» كمنجزة';
  }

  @override
  String get markGoalComplete => 'تحديد كمكتمل';

  @override
  String get markRead => 'تحديد كمقروء';

  @override
  String masteredScore(int n) {
    return 'متقن · أفضل نتيجة $n%';
  }

  @override
  String get mealBreakfast => 'الفطور';

  @override
  String get mealDinner => 'العشاء';

  @override
  String get mealLunch => 'الغداء';

  @override
  String get mealPhoto => 'صوّر الوجبة';

  @override
  String get mealSnack => 'وجبات خفيفة';

  @override
  String measurementsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n قياس',
      few: '$n قياسات',
      two: 'قياسين',
      one: 'قياس',
    );
    return '$_temp0';
  }

  @override
  String get memberSince => 'تاريخ إنشاء الحساب';

  @override
  String get menu => 'القائمة';

  @override
  String get methodEgyptian => 'الهيئة المصرية العامة للمساحة';

  @override
  String get methodGulf => 'منطقة الخليج';

  @override
  String get methodIsna => 'الجمعية الإسلامية لأمريكا الشمالية';

  @override
  String get methodKarachi => 'جامعة العلوم الإسلامية بكراتشي';

  @override
  String get methodKuwait => 'الكويت';

  @override
  String get methodMwl => 'رابطة العالم الإسلامي';

  @override
  String get methodQatar => 'قطر';

  @override
  String get methodUmmAlQura => 'أم القرى (مكة)';

  @override
  String metricOutOfRange(int min, int max) {
    return 'اكتب رقم بين $min و$max';
  }

  @override
  String get milestone => 'مرحلة';

  @override
  String get milestoneHint => 'مثال: فهم أساسيات Dart';

  @override
  String get milestones => 'المراحل';

  @override
  String milestonesDone(int done, int total) {
    return '$done/$total مراحل';
  }

  @override
  String get mkBloodPressure => 'ضغط الدم';

  @override
  String get mkBodyFat => 'نسبة الدهون';

  @override
  String get mkBodyFatPct => 'نسبة الدهون (%)';

  @override
  String get mkHeartBpm => 'نبض الراحة (نبضة/د)';

  @override
  String get mkWaist => 'محيط الخصر';

  @override
  String get mkWaistCm => 'محيط الخصر (سم)';

  @override
  String get mkWeight => 'الوزن';

  @override
  String get mkWeightKg => 'الوزن (كغ)';

  @override
  String mmHgN(int sys, int dia) {
    return '$sys/$dia ملم زئبق';
  }

  @override
  String get modExpenses => 'المصروفات';

  @override
  String get modHabits => 'العادات';

  @override
  String get modLearning => 'التعلم';

  @override
  String get modNotes => 'الملاحظات';

  @override
  String get modTime => 'تنظيم الوقت';

  @override
  String get modelSaw => 'اللي شافه الجوال (اضغط للبحث):';

  @override
  String get month => 'شهر';

  @override
  String get monthlyBudget => 'الميزانية الشهرية';

  @override
  String get mood => 'المزاج';

  @override
  String get moodAnxious => 'قلقانة';

  @override
  String get moodCalm => 'هادئة';

  @override
  String get moodHappy => 'مبسوطة';

  @override
  String get moodIrritable => 'معصّبة';

  @override
  String get moodLow => 'متضايقة';

  @override
  String get more => 'المزيد';

  @override
  String get moreFilters => 'تصفية إضافية';

  @override
  String get moreOptions => 'خيارات إضافية';

  @override
  String get mostLogged => 'الأكثر تسجيلًا';

  @override
  String get moveReminders => 'تذكير بالحركة';

  @override
  String get moveRemindersOn => 'ذكّرني أتحرك';

  @override
  String get moveRemindersSub => 'يتوقف لليوم إذا حققت هدفك';

  @override
  String get moveTomorrow => 'نقل إلى الغد';

  @override
  String movedTo(String time) {
    return 'نُقلت إلى $time';
  }

  @override
  String get movedTomorrow => 'نُقلت إلى الغد';

  @override
  String get muArms => 'الذراعان';

  @override
  String get muBack => 'الظهر';

  @override
  String get muBalance => 'التوازن';

  @override
  String get muCardio => 'هوائي';

  @override
  String get muChest => 'الصدر';

  @override
  String get muCore => 'الجذع';

  @override
  String get muFullBody => 'الجسم كامل';

  @override
  String get muGlutes => 'الأرداف';

  @override
  String get muLegs => 'الأرجل';

  @override
  String get muMobility => 'مرونة';

  @override
  String get muPelvicFloor => 'قاع الحوض';

  @override
  String get muShoulders => 'الأكتاف';

  @override
  String get multiCurrencyNote =>
      'يُجمع كل مبلغ بعملته — لا تُجمع العملات المختلفة معًا.';

  @override
  String get myFoods => 'أكلاتي';

  @override
  String get myGoals => 'أهدافي';

  @override
  String get myLocation => 'موقعي';

  @override
  String get myNotes => 'ملاحظاتي';

  @override
  String nOfM(int n, int m) {
    return '$n من $m';
  }

  @override
  String get navAccountability => 'الالتزام';

  @override
  String get navActivity => 'الخطوات';

  @override
  String get navAssistant => 'المساعد';

  @override
  String get navEnglish => 'الإنجليزية';

  @override
  String get navExpenses => 'المصروفات';

  @override
  String get navFitness => 'الرياضة';

  @override
  String get navGoals => 'أهدافي';

  @override
  String get navHabits => 'العادات';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navNotes => 'الملاحظات';

  @override
  String get navNotifications => 'الإشعارات';

  @override
  String get navNutrition => 'الأكل';

  @override
  String get navPrayer => 'الصلاة';

  @override
  String get navProgress => 'تقدمي';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navTasks => 'المهام';

  @override
  String get navTime => 'وقتي';

  @override
  String get navWomens => 'صحة المرأة';

  @override
  String get needMoreData =>
      'نحتاج دورتين مسجلتين على الأقل عشان نقدّر الجاية. وتقدرين تحددين طول دورتك المعتاد.';

  @override
  String get neededTime => 'تحتاج المهام';

  @override
  String needsReviewScore(int n) {
    return 'يحتاج إعادة · أفضل نتيجة $n%';
  }

  @override
  String get neverAddedUp =>
      'إذا مصدرين فيهم نفس اليوم، نعرض واحد بس وما نجمعهم، لأن الجوال والساعة غالبًا يحسبون نفس المشي.';

  @override
  String get newChat => 'محادثة جديدة';

  @override
  String get newEvent => 'موعد جديد';

  @override
  String get newGoal => 'هدف جديد';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get newTask => 'مهمة جديدة';

  @override
  String get newUserBody =>
      'ابدأ بمهمة واحدة وهدف واحد، ثم اطلب من المساعد تخطيط يومك.';

  @override
  String get newUserTitle => 'أهلًا بك في حياتي 👋';

  @override
  String get newWords => 'كلمات جديدة';

  @override
  String get next => 'التالي';

  @override
  String get nextDay => 'اليوم التالي';

  @override
  String get nextPeriod => 'التالي';

  @override
  String nextPeriodIn(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'الدورة الجاية بعد $n يوم تقريبًا',
      few: 'الدورة الجاية بعد $n أيام تقريبًا',
      two: 'الدورة الجاية بعد يومين تقريبًا',
      one: 'الدورة الجاية بعد يوم تقريبًا',
    );
    return '$_temp0';
  }

  @override
  String nextPrayerIs(String name) {
    return 'الصلاة القادمة: $name';
  }

  @override
  String get nextUp => 'التالي';

  @override
  String get noActions => 'لا توجد إجراءات بعد.';

  @override
  String get noActiveGoals => 'لا توجد أهداف نشطة حاليًا.';

  @override
  String get noAppointments => 'ما فيه مواعيد';

  @override
  String get noAppointmentsBody =>
      'أضف الكشوفات والتحاليل، ومعها اللي تبي تسأل عنه.';

  @override
  String get noConversations => 'لا توجد محادثات سابقة.';

  @override
  String get noExpensesPeriod => 'لا توجد مصروفات في هذه الفترة';

  @override
  String get noFoodFound => 'ما لقينا شي';

  @override
  String get noFoodFoundBody => 'أضفها مرة كأكلة من عندك وتنحفظ للمرة الجاية.';

  @override
  String get noGoalsYet => 'لا توجد أهداف بعد';

  @override
  String get noHabitsDueToday => 'لا توجد عادات مستحقة اليوم.';

  @override
  String get noHabitsYet => 'لا توجد عادات بعد';

  @override
  String get noHeartYet => 'ما فيه نبض راحة للحين';

  @override
  String noHomeAlternative(String name) {
    return '$name: لا يوجد بديل منزلي، يُتخطى اليوم';
  }

  @override
  String get noLinkedTasks => 'لا توجد مهام مرتبطة بهذا الهدف بعد.';

  @override
  String get noMeasurementYet => 'ما فيه للحين — اضغط عشان تضيف';

  @override
  String get noMilestones => 'لا توجد مراحل بعد.';

  @override
  String get noNotesYet => 'لا توجد ملاحظات بعد';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get noPeriodsYet => 'ما فيه دورات مسجلة للحين.';

  @override
  String get noProgressYet => 'ما فيه مجموعات مسجلة للحين';

  @override
  String get noProgressYetBody => 'خلّص تمرين أو برنامج ويظهر تقدمك هنا.';

  @override
  String get noReminder => 'بدون تذكير';

  @override
  String get noReviewsDue => 'لا توجد مراجعة الآن.';

  @override
  String get noSearchResults => 'لا توجد نتائج';

  @override
  String get noSetsBody => 'لن يُحفظ شيء. هل تريد الخروج من التمرين؟';

  @override
  String get noSetsTitle => 'لم تحدد أي مجموعة';

  @override
  String get noSleepYet => 'ما فيه نوم مسجل';

  @override
  String get noSleepYetBody =>
      'أضف ليلة يدويًا، أو اقرأ النوم من تطبيق الصحة في «الأجهزة والمصادر».';

  @override
  String get noSourcesYet =>
      'ما فيه شي للحين. اربط من تطبيق حياتي على الجوال، أو أضف خطواتك يدويًا.';

  @override
  String get noSymptomsYet => 'ما سجلتي أعراض للحين.';

  @override
  String get noTasksToday => 'لا توجد مهام لليوم.';

  @override
  String get noUnread => 'لا توجد إشعارات غير مقروءة';

  @override
  String get noUpcoming => 'لا توجد مواعيد قادمة.';

  @override
  String get noWorkoutThatDay => 'لا يوجد تمرين مخطط لذلك اليوم.';

  @override
  String get none => 'بدون';

  @override
  String get notDue => 'غير مستحق';

  @override
  String get notLogged => 'لم يُسجّل';

  @override
  String get notSet => 'غير محدد';

  @override
  String get notStarted => 'لم يبدأ';

  @override
  String get notSyncedYet => 'ما تمت مزامنة للحين';

  @override
  String get noteBody => 'اكتب ملاحظتك…';

  @override
  String get noteTitle => 'العنوان';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get nothingLogged => 'ما فيه شي للحين';

  @override
  String get nothingScheduled => 'لا يوجد شيء مجدول';

  @override
  String get nothingScheduledNow => 'لا شيء مجدول اليوم';

  @override
  String get nothingThisWeek => 'ما فيه تسجيل هالأسبوع';

  @override
  String get nothingToPlan => 'لا توجد مهام مفتوحة للتخطيط لهذا اليوم.';

  @override
  String notifAccountability(String task) {
    return '«$task» متأخرة';
  }

  @override
  String get notifAccountabilityBody =>
      'بدون لوم، قل لنا وش صار واختر الخطوة الجاية.';

  @override
  String get notifAppointmentTitle => 'موعد صحي';

  @override
  String get notifBedtimeBody => 'خفّف الشاشات والإضاءة';

  @override
  String get notifBedtimeTitle => 'وقت تجهّز للنوم';

  @override
  String get notifDue => 'راجع موعدها في المهام.';

  @override
  String notifEventBody(int minutes) {
    return 'يبدأ خلال $minutes دقيقة';
  }

  @override
  String notifEventTitle(String title) {
    return 'موعد قادم: $title';
  }

  @override
  String notifHabitTitle(String name) {
    return 'تذكير بالعادة: $name';
  }

  @override
  String get notifMoveBody => 'مشي قصير أو تمدد بسيط لدقائق.';

  @override
  String get notifMoveTitle => 'وقت الحركة';

  @override
  String get notifNeutralBody => 'افتح التطبيق عشان تشوفه';

  @override
  String get notifNeutralTitle => 'تذكير من حياتي';

  @override
  String notifPrayerSoon(String name, int minutes) {
    return 'صلاة $name بعد $minutes دقيقة';
  }

  @override
  String notifPrayerTitle(String name) {
    return 'حان وقت صلاة $name';
  }

  @override
  String notifTaskTitle(String title) {
    return 'تذكير: $title';
  }

  @override
  String get nowLabel => 'الآن';

  @override
  String nowUntil(String time) {
    return 'حتى $time';
  }

  @override
  String get nutritionNote =>
      'الأرقام تقديرية تساعدك تلاحظ عاداتك، وليست نصيحة طبية أو حمية.';

  @override
  String get obStep1 => 'اللغة والمنطقة';

  @override
  String get obStep2 => 'ما الذي تريد تنظيمه؟';

  @override
  String get obStep3 => 'هدف أول (اختياري)';

  @override
  String get obStep4 => 'يومك';

  @override
  String get obsFew =>
      'أُنجز أقل من نصف المهام المستحقة. قد يساعد تخطيط مهام أقل لكل يوم.';

  @override
  String get obsHalf => 'أنجزت نحو نصف المهام المستحقة في هذه الفترة.';

  @override
  String get obsMost => 'أنجزت معظم المهام التي حددتها لهذه الفترة.';

  @override
  String obsNoDeadlines(int n) {
    return 'أنجزت $n مهام. لم يكن لأي منها موعد نهائي في هذه الفترة، لذا لا توجد نسبة إنجاز.';
  }

  @override
  String get observations => 'ملاحظات';

  @override
  String ofStepGoal(String goal) {
    return 'من $goal';
  }

  @override
  String get offNote =>
      'بيانات المنتجات من Open Food Facts، قاعدة مفتوحة ومجانية. يُرسل رقم الباركود فقط. راجع الملصق قبل الحفظ.';

  @override
  String get ok => 'حسنًا';

  @override
  String get onboardingNoAuto =>
      'لن يُنشأ أو يُجدول أي شيء تلقائيًا. أنت من يختار ما يضيفه بعد ذلك.';

  @override
  String get oneSourceEach => 'كل نوع له مصدر واحد للحين، فما فيه شي تختاره.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get orTypeBarcode => 'أو اكتب رقم الباركود';

  @override
  String get organizeGroup => 'التنظيم';

  @override
  String get otherSymptoms => 'شي ثاني';

  @override
  String get overBudget => 'تجاوز الميزانية';

  @override
  String get overCapacity =>
      'مهامك تحتاج وقتًا أكثر من المتاح. بعضها لن يتسع اليوم، انقلها أو قلّل مدتها.';

  @override
  String get overdue => 'متأخرة';

  @override
  String get overdueDef => 'مستحقة في الفترة، فات موعدها وما زالت مفتوحة';

  @override
  String get overdueTasks => 'المتأخرة';

  @override
  String get pain => 'الألم';

  @override
  String painN(int n) {
    return 'ألم $n/10';
  }

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور';

  @override
  String get passwordRule => '8 أحرف على الأقل، تحتوي على حرف ورقم';

  @override
  String get past => 'السابقة';

  @override
  String get pastDay => 'هذا اليوم انقضى.';

  @override
  String get pathStarted => 'بدأ مسارك من المستوى A1.';

  @override
  String get pauseGoal => 'إيقاف مؤقت';

  @override
  String get perOnePortion => 'لحصة واحدة';

  @override
  String perPortion(String portion) {
    return 'للحصة: $portion';
  }

  @override
  String perWeek(int n) {
    return '$n أسبوعيًا';
  }

  @override
  String percentN(String v) {
    return '$v%';
  }

  @override
  String periodCovers(String from, String to) {
    return 'الفترة من $from إلى $to';
  }

  @override
  String periodDayN(int n) {
    return 'الدورة، اليوم $n';
  }

  @override
  String get periodDueAbout => 'ممكن تبدأ الدورة في هالأيام';

  @override
  String get periodEnded => 'انحفظ: انتهت الدورة';

  @override
  String get periodEndedToday => 'انتهت اليوم';

  @override
  String get periodInvalid =>
      'ما ينفع: راجعي التواريخ (بدون أيام جاية، بدون تداخل، وبحد أقصى 15 يوم).';

  @override
  String periodLateBy(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'متأخرة $n يوم عن النافذة المتوقعة',
      few: 'متأخرة $n أيام عن النافذة المتوقعة',
      two: 'متأخرة يومين عن النافذة المتوقعة',
      one: 'متأخرة يوم عن النافذة المتوقعة',
    );
    return '$_temp0';
  }

  @override
  String get periodSaved => 'انحفظت الدورة';

  @override
  String periodSinceDate(String date) {
    return 'من $date (مستمرة)';
  }

  @override
  String get periodStarted => 'انحفظ: بدأت الدورة';

  @override
  String get periodStartedToday => 'بدأت اليوم';

  @override
  String get permAddNotes => 'إضافة الملاحظات';

  @override
  String get permAddNotesSub => 'حفظ ملاحظة تمليها.';

  @override
  String get permCreateTasks => 'إنشاء مهمة واحدة';

  @override
  String get permCreateTasksSub =>
      'من طلب واضح مثل «أضف مهمة … غدًا الساعة 8 مساءً».';

  @override
  String get permDraftPlans => 'إنشاء مسودات الخطط';

  @override
  String get permDraftPlansSub =>
      'تجهيز خطط لتراجعها. لا تُطبّق المسودات دون موافقتك.';

  @override
  String get permLogHabits => 'تسجيل إنجاز العادات';

  @override
  String get permLogHabitsSub => 'عندما تذكر أنك أنجزت عادة اليوم.';

  @override
  String get photoFailed => 'ما قدرنا نقرأ الصورة. جرّب صورة ثانية، أو ابحث.';

  @override
  String get photoIntro =>
      'صوّر وجبتك والجوال يقترح وش هي. أنت تختار الأكلة والكمية.';

  @override
  String get photoNoMatch =>
      'ما لقينا شي قريب في القائمة. جرّب البحث، أو أضفها كأكلة من عندك.';

  @override
  String get photoPrivacy => 'الصورة تنقرأ على جوالك فقط. ما ترتفع ولا تنحفظ.';

  @override
  String get photoStep1 => 'صوّر الصحن';

  @override
  String get photoStep2 => 'اختر الأكلة المطابقة من الاقتراحات';

  @override
  String get photoStep3 => 'حدد الكمية وخلاص';

  @override
  String get pickCity => 'اختر مدينة';

  @override
  String get pin => 'تثبيت';

  @override
  String get placeGym => 'النادي';

  @override
  String get placeHome => 'المنزل';

  @override
  String get placementExplain =>
      'مستوى البداية هو الأوسط بين مستويات مهاراتك الثلاث. يمكنك إعادة الاختبار في أي وقت.';

  @override
  String get placementIntro =>
      '24 سؤالًا قصيرًا من السهل إلى الأصعب. أجب بما تعرفه؛ التخمين يقلل دقة النتيجة فقط.';

  @override
  String get placementNoPeek =>
      'لا تظهر الإجابات سؤالًا بسؤال، بل تظهر النتيجة في النهاية.';

  @override
  String placementResult(String level) {
    return 'مستواك: $level';
  }

  @override
  String get placementTitle => 'اختبار تحديد المستوى';

  @override
  String get planApplied => 'تم اعتماد الخطة';

  @override
  String get planEmptyToday => 'لا شيء مخطط لليوم بعد.';

  @override
  String get planExplain =>
      'تُبنى الخطة من إجاباتك: الجسم كامل حتى 3 أيام أسبوعيًا، وعلوي/سفلي من 4 أيام، مع تمارين الجذع في كل حصة وأيام راحة بين الحصص الشاقة. عند الحفظ تبقى خطتك السابقة كإصدار سابق.';

  @override
  String planFor(String place) {
    return 'خطة $place';
  }

  @override
  String get planFree => 'المجانية';

  @override
  String get planIsEstimate =>
      'هذه الخطة تقديرية بناءً على المدد والأولويات، وتترك وقتًا للراحة والطوارئ.';

  @override
  String get planLabel => 'الخطة';

  @override
  String get planPro => 'حياتي برو';

  @override
  String get planSaved => 'حُفظت الخطة';

  @override
  String planSummary(int done, int total) {
    return 'أنجزت $done من $total مهام اليوم';
  }

  @override
  String planVersion(int version, String date) {
    return 'الخطة: الإصدار $version · أُنشئت في $date';
  }

  @override
  String get planWithAssistant => 'خطط مع المساعد';

  @override
  String get plannedDate => 'يوم العمل عليها';

  @override
  String get plannedShort => 'مخطط';

  @override
  String get plannedTime => 'الوقت المخطط';

  @override
  String get planner => 'التخطيط';

  @override
  String get planningHint =>
      'يساعد هذا المخطط على وضع المهام في وقتك المتاح فعلًا.';

  @override
  String get planningPrefs => 'تفضيلات التخطيط';

  @override
  String get pointAtBarcode => 'وجّه الكاميرا على الباركود';

  @override
  String get portionHint => 'مثل: قطعة، كوب، علبة 330 مل';

  @override
  String get portionName => 'الحصة';

  @override
  String portionsN(String n) {
    return '$n × حصة';
  }

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerBlock => 'وقت محجوز للصلاة';

  @override
  String get prayerBlockHint => 'لا يضع المخطط مهامًا في هذا الوقت.';

  @override
  String get prayerCalcNote =>
      'المواقيت محسوبة فلكيًا وقد تختلف دقيقة أو دقيقتين عن أذان مسجدك. يمكنك تغيير طريقة الحساب من الإعدادات.';

  @override
  String get prayerCalculation => 'طريقة الحساب';

  @override
  String get prayerCurrent => 'وقت الصلاة الحالية';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerEnable => 'عرض مواقيت الصلاة';

  @override
  String get prayerEnableHint => 'في الرئيسية وفي خطة يومك وكتنبيهات.';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get prayerLocation => 'الموقع';

  @override
  String get prayerLogHint =>
      'حدّدها بنفسك بعد أن تصلي. التطبيق لا يفترض ذلك أبدًا.';

  @override
  String prayerLogLabel(String name) {
    return 'صلّيت $name';
  }

  @override
  String get prayerLogToggle => 'سجل الصلوات';

  @override
  String get prayerLogToggleHint => 'اختياري. لا يُسجّل إلا ما تحدده بنفسك.';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerMethodLabel => 'الطريقة';

  @override
  String get prayerNoLocation => 'لم يُحدد موقع بعد';

  @override
  String get prayerNotify => 'نبّهني عند كل صلاة';

  @override
  String get prayerPreview => 'مواقيت اليوم';

  @override
  String get prayerRemindBefore => 'وذكّرني قبلها بـ';

  @override
  String get prayerReminders => 'التنبيهات والتخطيط';

  @override
  String get prayerSettingsTitle => 'إعدادات مواقيت الصلاة';

  @override
  String get prayerSetupAction => 'إعداد';

  @override
  String get prayerSetupBody => 'اختر مدينتك لعرض المواقيت وتنظيم يومك حولها.';

  @override
  String get prayerSetupTitle => 'مواقيت الصلاة';

  @override
  String prayerWeekLogged(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'سجّلت $n صلاة في آخر 7 أيام.',
      few: 'سجّلت $n صلوات في آخر 7 أيام.',
      two: 'سجّلت صلاتين في آخر 7 أيام.',
      one: 'سجّلت صلاة واحدة في آخر 7 أيام.',
      zero: 'لم تسجّل أي صلاة في آخر 7 أيام.',
    );
    return '$_temp0';
  }

  @override
  String get previous => 'السابق';

  @override
  String get previousChats => 'المحادثات السابقة';

  @override
  String get previousDay => 'اليوم السابق';

  @override
  String get pricingNotSet =>
      'سيُعرض السعر وفترة الفوترة والضرائب وشروط التجديد بوضوح هنا قبل تفعيل الشراء.';

  @override
  String get priorityHigh => 'عالية';

  @override
  String get priorityLabel => 'الأولوية';

  @override
  String get priorityLow => 'منخفضة';

  @override
  String get priorityMedium => 'متوسطة';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get privacyRetention => 'سجل المحادثات';

  @override
  String get privacyText =>
      'حياتي — سياسة الخصوصية (مسودة الوضع المحلي)\n\n1. ما نجمعه: ما تدخله فقط — بريدك، وبصمة مملّحة لكلمة المرور، وتفضيلاتك، ومهامك ومواعيدك وأهدافك وعاداتك وملاحظاتك ومصروفاتك ومحادثات المساعد.\n\n2. مكان الحفظ: على هذا الجهاز. لا يُرسل شيء إلى خوادمنا أو إلى مزود ذكاء اصطناعي في هذا الإصدار.\n\n3. المساعد: يعمل على جهازك ويطّلع فقط على الأقسام التي تسمح بها في إعدادات المساعد.\n\n4. تحكمك: يمكنك تصدير كل بياناتك وحذف المحادثات وحذف حسابك في أي وقت.\n\n5. بلاغات الدعم لا تتضمن محادثاتك أو ملاحظاتك أو مصروفاتك، وتُضاف المعلومات التقنية فقط إذا اخترت ذلك.\n\nيجب مراجعة هذه المسودة واستبدالها بالسياسة النهائية قبل الإطلاق العام.';

  @override
  String get privacyTitle => 'الخصوصية وإدارة البيانات';

  @override
  String get problemDescription => 'ما المشكلة؟';

  @override
  String get productFound =>
      'لقيناه في Open Food Facts. طابق الأرقام مع الملصق قبل الحفظ.';

  @override
  String get productNotFound =>
      'مو موجود في القاعدة — أدخله مرة من الملصق وينحفظ.';

  @override
  String get profileTitle => 'الملف الشخصي والحساب';

  @override
  String get programDisclaimer =>
      'إرشادات عامة وليست نصيحة طبية. إذا حسيت بشي غير طبيعي، وقّف واسأل طبيبك.';

  @override
  String get programExercises => 'التمارين';

  @override
  String get programStages => 'اختر المرحلة';

  @override
  String get programUnavailable => 'غير متاح';

  @override
  String get programUnavailableBody => 'هذا البرنامج مو ضمن أقسامك الصحية.';

  @override
  String get programs => 'البرامج';

  @override
  String get programsForMen => 'خاص بالرجل';

  @override
  String get programsForWomen => 'خاص بالمرأة';

  @override
  String get progress => 'التقدم';

  @override
  String get progressLog => 'سجل التقدم';

  @override
  String get progressLogSub => 'أفضل وآخر مجموعاتك لكل تمرين';

  @override
  String get progressManual => 'تقدم يدوي';

  @override
  String get progressMethod => 'كيف يُقاس التقدم؟';

  @override
  String get progressNotMeasured => 'لم يُقَس بعد';

  @override
  String get progressNote =>
      'من المجموعات اللي سجلتها: الوزن × التكرار إذا أدخلت وزن، وإلا التكرارات أو الوقت. الذهبي = أفضل جلسة.';

  @override
  String get proposalExecuted => 'تم التنفيذ';

  @override
  String get proposalFailed => 'فشل، ولم يتغير شيء';

  @override
  String get proposalNotFound => 'هذا الاقتراح لم يعد موجودًا.';

  @override
  String get proposalRejected => 'مرفوض';

  @override
  String get proposalStale =>
      'تغيرت بياناتك منذ هذا الاقتراح. اطلب اقتراحًا جديدًا.';

  @override
  String get protein => 'بروتين';

  @override
  String get proteinG => 'بروتين (غ)';

  @override
  String questionOf(int current, int total) {
    return '$current من $total';
  }

  @override
  String get questionsForDoctor => 'أسئلة للطبيب';

  @override
  String questionsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n سؤال',
      few: '$n أسئلة',
      two: 'سؤالين',
      one: 'سؤال',
    );
    return '$_temp0';
  }

  @override
  String get quickAdd => 'إضافة سريعة';

  @override
  String readOnlyNote(String store) {
    return 'كل مفتاح يطلب الإذن من $store أول مرة. إذا طفيته يوقف القراءة، واللي انجاب يبقى.';
  }

  @override
  String get readSleepBasics => 'اقرأ: أساسيات النوم';

  @override
  String get readThis => 'اقرأ:';

  @override
  String get reason => 'السبب';

  @override
  String get reasonDeadline => 'ستنتهي بعد وقت استحقاقها';

  @override
  String get reasonNoSlot => 'لا توجد فترة فارغة طويلة بما يكفي';

  @override
  String get reasonNoTime => 'لا يكفي الوقت المتبقي اليوم';

  @override
  String get recentFoods => 'الأخيرة';

  @override
  String get recentNights => 'الليالي الأخيرة';

  @override
  String get recentWorkouts => 'آخر التمارين';

  @override
  String get recordedPeriods => 'الدورات المسجلة';

  @override
  String get recovery => 'التعافي';

  @override
  String get recoveryWarning =>
      'حصتان شاقتان في يومين متتاليين. يُفضّل يوم راحة بينهما.';

  @override
  String get regional => 'المنطقة والوقت';

  @override
  String get reject => 'رفض';

  @override
  String get remind3HoursBefore => 'قبلها بـ3 ساعات';

  @override
  String remindBeforeN(int n) {
    return 'قبلها بـ$n دقيقة';
  }

  @override
  String get remindDayBefore => 'قبلها بيوم';

  @override
  String get remindHourBefore => 'قبلها بساعة';

  @override
  String get reminder => 'التذكير';

  @override
  String get reminderNeedsTime =>
      'حدد موعدًا نهائيًا أو وقتًا مخططًا لضبط التذكير.';

  @override
  String get reminderTimeOptional => 'وقت التذكير (اختياري)';

  @override
  String get removeCup => 'شيل كوب';

  @override
  String get removeFromPlan => 'إزالة من خطة اليوم';

  @override
  String get removeItem => 'إزالة هذا التغيير';

  @override
  String get removeSourceData => 'احذف بيانات هذا المصدر';

  @override
  String removeSourceDataBody(String source) {
    return 'الخطوات والنوم والنبض والتمارين اللي جت من $source تنحذف من حياتي في كل أجهزتك. ما يتغير شي في $source نفسه.';
  }

  @override
  String removeSourceDataTitle(String source) {
    return 'تحذف بيانات $source؟';
  }

  @override
  String get removedFromPlan => 'أزيلت من هذه الخطة';

  @override
  String get reorder => 'إعادة الترتيب';

  @override
  String get reorderHint => 'اسحب لتغيير الترتيب، وستُعاد حساب الأوقات.';

  @override
  String get repeatDays => 'أيام التكرار';

  @override
  String get reportNoData => 'لا توجد بيانات كافية لهذه الفترة.';

  @override
  String get reportPrivacy =>
      'لا تُرفق محادثاتك أو ملاحظاتك أو مصروفاتك بالبلاغ أبدًا.';

  @override
  String get reportProblem => 'الإبلاغ عن مشكلة';

  @override
  String get reportProblemSub => 'صف ما حدث';

  @override
  String get reportSaved => 'حُفظ البلاغ، وسيُرسل عند ربط خدمة الدعم.';

  @override
  String get repsLabel => 'التكرارات';

  @override
  String repsN(int n) {
    return '$n تكرار';
  }

  @override
  String get resetLinkSent =>
      'إن وُجد حساب بهذا البريد فسيصله رابط إعادة التعيين.';

  @override
  String get restBlock => 'استراحة';

  @override
  String get restDayBody => 'التعافي جزء من الخطة. يكفي مشي أو إطالة خفيفة.';

  @override
  String get restDayTitle => 'يوم راحة';

  @override
  String restFor(int n) {
    return 'راحة $n ث';
  }

  @override
  String get restOfDayFree => 'بقية اليوم لك.';

  @override
  String restSeconds(int n) {
    return 'راحة $n ث';
  }

  @override
  String get restingHeartRate => 'نبض الراحة';

  @override
  String get restore => 'استعادة';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get resumeGoal => 'تفعيل';

  @override
  String get retakePlacement => 'أعد الاختبار';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get reviewChanges => 'مراجعة التغييرات';

  @override
  String reviewDone(int right, int total) {
    return '$right من $total صحيحة. الكلمات التي أخطأت فيها تعود غدًا.';
  }

  @override
  String reviewDue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n كلمة للمراجعة',
      few: '$n كلمات للمراجعة',
      two: 'كلمتان للمراجعة',
      one: 'كلمة للمراجعة',
    );
    return '$_temp0';
  }

  @override
  String get reviewMyPlan => 'راجع خطتي';

  @override
  String get reviewTitle => 'مراجعة الكلمات';

  @override
  String get reviewWhy =>
      'الكلمات التي تعلمتها تعود على فترات متزايدة لتثبت في الذاكرة.';

  @override
  String get sampleGoal1 => 'تعلم الإنجليزية';

  @override
  String get sampleGoal2 => 'تعلم البرمجة';

  @override
  String get sampleGoal3 => 'ممارسة الرياضة بانتظام';

  @override
  String get sampleGoal4 => 'قراءة 12 كتابًا هذا العام';

  @override
  String get save => 'حفظ';

  @override
  String get saveAndAdd => 'احفظ وأضف';

  @override
  String get saveEvent => 'حفظ الموعد';

  @override
  String get saveGoal => 'حفظ الهدف';

  @override
  String get saveOnly => 'احفظ فقط';

  @override
  String get savePlan => 'حفظ الخطة';

  @override
  String get saveTask => 'حفظ المهمة';

  @override
  String get saveWorkout => 'حفظ التمرين';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get saving => 'جارٍ الحفظ…';

  @override
  String get scanBarcode => 'الباركود';

  @override
  String get scanOnPhone => 'المسح بالكاميرا في تطبيق الجوال';

  @override
  String get scanOnPhoneBody => 'هنا تقدر تكتب الرقم المطبوع تحت الباركود.';

  @override
  String get scheduleGroup => 'الموعد';

  @override
  String scoreOutOf(int score, int pass) {
    return 'نتيجتك $score% (المطلوب $pass%).';
  }

  @override
  String get search => 'بحث';

  @override
  String get searchCity => 'ابحث عن مدينة';

  @override
  String get searchFoods => 'ابحث عن أكلة';

  @override
  String get searchInstead => 'ابحث في القائمة بدلًا من ذلك';

  @override
  String get secondsLabel => 'الثواني';

  @override
  String secondsN(int n) {
    return '$n ث';
  }

  @override
  String secondsShort(int n) {
    return '$n ث';
  }

  @override
  String get sectionsShown => 'الأقسام الظاهرة في التطبيق';

  @override
  String get seeResult => 'اعرض النتيجة';

  @override
  String get send => 'إرسال';

  @override
  String get sendResetLink => 'إرسال الرابط';

  @override
  String get sessionCompleted => 'مكتمل';

  @override
  String get sessionLength => 'مدة الجلسة';

  @override
  String get sessionPartial => 'منجز جزئيًا';

  @override
  String get sessions => 'الجلسات';

  @override
  String get sessionsLocal =>
      'في الوضع المحلي جلسة واحدة لكل جهاز، وتسجيل الخروج ينهيها.';

  @override
  String get sessionsRemote =>
      'تسجيل الخروج ينهي الجلسة على هذا الجهاز. تغيير كلمة المرور يُخرج الأجهزة الأخرى عند تجديد جلستها.';

  @override
  String setN(int n) {
    return 'مجموعة $n';
  }

  @override
  String setsLogged(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n مجموعة',
      few: '$n مجموعات',
      two: 'مجموعتان',
      one: 'مجموعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String setsProgress(int done, int total) {
    return '$done/$total مجموعة';
  }

  @override
  String get sexAskTitle => 'عرّفنا عليك';

  @override
  String get sexFemale => 'أنثى';

  @override
  String get sexLabel => 'الجنس';

  @override
  String get sexMale => 'ذكر';

  @override
  String get sexWhy =>
      'يُستخدم لتخصيص الأقسام الصحية فقط، وتقدر تغيّره من حسابك.';

  @override
  String get shareNotesSub => 'معطّل افتراضيًا';

  @override
  String get shareSub => 'يُستخدم للتخطيط والتلخيص';

  @override
  String get showActive => 'عرض النشطة';

  @override
  String get showArchived => 'عرض المؤرشفة';

  @override
  String get showCompleted => 'عرض المكتملة والمؤرشفة';

  @override
  String get showMyPlan => 'اعرض خطتي';

  @override
  String get showNameGreeting => 'إظهار اسمي في التحية';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signInMethod => 'طريقة الدخول';

  @override
  String get signInSubtitle => 'سجّل الدخول للمتابعة.';

  @override
  String get signInTitle => 'مرحبًا بعودتك';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutBody => 'تبقى بياناتك محفوظة لحين تسجيل دخولك مرة أخرى.';

  @override
  String get signUpSubtitle => 'لن يستغرق الأمر أكثر من دقيقة.';

  @override
  String get signUpTitle => 'إنشاء حساب';

  @override
  String get skillGrammar => 'القواعد';

  @override
  String get skillReading => 'القراءة';

  @override
  String get skillVocabulary => 'المفردات';

  @override
  String get skillsMeasuredNote =>
      'يقيس التطبيق المفردات والقواعد والقراءة. أما الاستماع والمحادثة فيحتاجان أدوات صوتية ولا يُقيّمان بعد.';

  @override
  String get skip => 'تخطٍ';

  @override
  String get skipRest => 'تخطَّ';

  @override
  String get sleepAndRecovery => 'النوم والتعافي';

  @override
  String get sleepAndRecoverySub => 'لياليك، وكيف ترتاح، وتذكير بوقت النوم';

  @override
  String get sleepGoldNote => 'الذهبي يعني ليلة 7 ساعات أو أكثر.';

  @override
  String get sleepInvalid =>
      'ما ينفع: راجع الأوقات (حتى 24 ساعة، مو في المستقبل، وما يتداخل مع ليلة أضفتها).';

  @override
  String sleepNightsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ليلة',
      few: '$n ليالي',
      two: 'ليلتين',
      one: 'ليلة',
    );
    return '$_temp0';
  }

  @override
  String get sleepQuality => 'كيف كان نومك؟';

  @override
  String sleepQualityN(int n) {
    return 'الجودة $n من 5';
  }

  @override
  String sleepWindow(String from, String to) {
    return '$from – $to';
  }

  @override
  String sourceDataRemoved(String source) {
    return 'انحذفت بيانات $source';
  }

  @override
  String get sourceHealthConnect => 'Health Connect';

  @override
  String get sourceHealthKit => 'Apple Health';

  @override
  String get sourceManual => 'إدخال يدوي';

  @override
  String get sourcePhone => 'حساس الجوال';

  @override
  String get sources => 'المصادر';

  @override
  String get sourcesWithData => 'المصادر اللي فيها بياناتك';

  @override
  String get spending => 'المصروفات';

  @override
  String get splashFailed => 'تعذر تشغيل حياتي.';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get startFromBeginning => 'ابدأ من البداية';

  @override
  String get startLesson => 'ابدأ الدرس';

  @override
  String get startPath => 'ابدأ مساري';

  @override
  String get startProgram => 'ابدأ';

  @override
  String get startQuiz => 'ابدأ الاختبار القصير';

  @override
  String get startTime => 'البداية';

  @override
  String get startWorkout => 'ابدأ التمرين';

  @override
  String get statusCancelled => 'ملغاة';

  @override
  String get statusDone => 'منجزة';

  @override
  String get statusInProgress => 'قيد التنفيذ';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get statusTodo => 'لم تبدأ';

  @override
  String stepDaysN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'خطوات $n يوم',
      few: 'خطوات $n أيام',
      two: 'خطوات يومين',
      one: 'خطوات يوم',
    );
    return '$_temp0';
  }

  @override
  String get stepGoal => 'هدف الخطوات اليومي';

  @override
  String stepOf(int step, int total) {
    return 'الخطوة $step من $total';
  }

  @override
  String get stepsInvalid => 'حتى 150,000';

  @override
  String get stepsLabel => 'عدد الخطوات';

  @override
  String get stepsNoData => 'ما فيه خطوات اليوم للحين — اضغط للربط أو الإضافة';

  @override
  String stepsOfGoal(String steps, String goal) {
    return '$steps / $goal خطوة';
  }

  @override
  String get stepsOptional => 'خطوات تكرار المشكلة (اختياري)';

  @override
  String stepsPerDay(String n) {
    return '$n خطوة يوميًا';
  }

  @override
  String get stepsPermissionDenied =>
      'ما انعطى إذن قراءة الخطوات. تقدر تسمح له من إعدادات تطبيق الصحة.';

  @override
  String get stepsToday => 'خطوات اليوم';

  @override
  String get stop => 'إيقاف';

  @override
  String get stopIf => 'وقّف واستشر إذا صار عندك';

  @override
  String streakDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'سلسلة $n يوم',
      many: 'سلسلة $n يومًا',
      few: 'سلسلة $n أيام',
      two: 'سلسلة يومين',
      one: 'سلسلة يوم واحد',
      zero: 'لا توجد سلسلة بعد',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionTitle => 'الاشتراك';

  @override
  String get suggestedPill => 'مقترح';

  @override
  String get suggestedPlan => 'الخطة المقترحة';

  @override
  String get sunrise => 'الشروق';

  @override
  String get switchToSignIn => 'لديك حساب؟ سجّل الدخول';

  @override
  String get switchToSignUp => 'جديد هنا؟ أنشئ حسابًا';

  @override
  String get syAcne => 'حبوب';

  @override
  String get syBackPain => 'ألم الظهر';

  @override
  String get syBloating => 'انتفاخ';

  @override
  String get syBreastTenderness => 'ألم الصدر';

  @override
  String get syCramps => 'تقلصات';

  @override
  String get syCravings => 'اشتهاء أكل';

  @override
  String get syFatigue => 'تعب';

  @override
  String get syHeadache => 'صداع';

  @override
  String get syInsomnia => 'قلة نوم';

  @override
  String get syMoodSwings => 'تقلب المزاج';

  @override
  String get syNausea => 'غثيان';

  @override
  String get sySpotting => 'تبقيع';

  @override
  String get symptoms => 'الأعراض';

  @override
  String get syncFailedShort => 'ما قدرنا نقرأ الخطوات — جرّب مرة ثانية';

  @override
  String get syncNever => 'لم تتم المزامنة بعد';

  @override
  String get syncNow => 'زامن الآن';

  @override
  String syncOffline(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'لا يوجد اتصال — سيُرفع $n تغييرًا عند عودة الاتصال.',
      few: 'لا يوجد اتصال — ستُرفع $n تغييرات عند عودة الاتصال.',
      two: 'لا يوجد اتصال — سيُرفع تغييران عند عودة الاتصال.',
      one: 'لا يوجد اتصال — سيُرفع تغيير واحد عند عودة الاتصال.',
      zero: 'لا يوجد اتصال — تُعرض البيانات المحفوظة.',
    );
    return '$_temp0';
  }

  @override
  String syncPending(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n تغييرًا بانتظار الرفع',
      few: '$n تغييرات بانتظار الرفع',
      two: 'تغييران بانتظار الرفع',
      one: 'تغيير واحد بانتظار الرفع',
    );
    return '$_temp0';
  }

  @override
  String get syncRejected =>
      'تعذر حفظ بعض التغييرات في حسابك، فاستُبدلت بالنسخة المحفوظة.';

  @override
  String get syncStatus => 'المزامنة';

  @override
  String syncUpToDate(String time) {
    return 'محدّثة · $time';
  }

  @override
  String get systolic => 'العالي (الانقباضي)';

  @override
  String get takeLevelCheck => 'أجرِ اختبار المستوى';

  @override
  String get takePhoto => 'صوّر';

  @override
  String get takePlacement => 'اختبار تحديد المستوى';

  @override
  String get targetDate => 'التاريخ المستهدف';

  @override
  String targetOn(String date) {
    return 'الهدف $date';
  }

  @override
  String get taskTitleRequired => 'عنوان المهمة';

  @override
  String get tasksCompleted => 'المهام المنجزة';

  @override
  String tasksCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n مهمة',
      many: '$n مهمة',
      few: '$n مهام',
      two: 'مهمتان',
      one: 'مهمة واحدة',
    );
    return '$_temp0';
  }

  @override
  String tasksDoneOf(int done, int total) {
    return 'أُنجزت $done من $total مهام';
  }

  @override
  String get terms => 'شروط الاستخدام';

  @override
  String get termsText =>
      'حياتي — شروط الاستخدام (مسودة)\n\nيساعدك حياتي في تنظيم وقتك وأهدافك وعاداتك وملاحظاتك ومصروفاتك. الخطط والاقتراحات تقديرية وليست ضمانات. حياتي ليس خدمة مصرفية أو استشارة مالية أو طبية. أنت مسؤول عن البيانات التي تدخلها وعن القرارات التي تتخذها بناءً عليها.\n\nيجب مراجعة هذه المسودة واستبدالها بالشروط النهائية قبل الإطلاق العام.';

  @override
  String get testHistory => 'سجل الاختبارات';

  @override
  String get theme => 'السمة';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get thinking => 'جارٍ التفكير…';

  @override
  String get thisDevice => 'هذا الجهاز';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get thisPhone => 'هذا الجوال';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get time => 'الوقت';

  @override
  String timesN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n مرة',
      few: '$n مرات',
      two: 'مرتين',
      one: 'مرة',
    );
    return '$_temp0';
  }

  @override
  String get timezone => 'المنطقة الزمنية';

  @override
  String get timezoneDetected =>
      'مكتشفة من جهازك. تُعرض الأوقات وفق المنطقة الزمنية للجهاز.';

  @override
  String get timezoneDeviceNote => 'يتبع إعداد الجهاز';

  @override
  String get to => 'إلى';

  @override
  String get today => 'اليوم';

  @override
  String todayFrom(String source) {
    return 'اليوم من: $source';
  }

  @override
  String get todayLogged => 'اليوم مسجّل';

  @override
  String get todayPlan => 'خطة اليوم';

  @override
  String get todaysHabits => 'عادات اليوم';

  @override
  String get todaysLesson => 'درس اليوم';

  @override
  String todaysWorkout(String focus) {
    return 'تمرين اليوم: $focus';
  }

  @override
  String get tomorrow => 'غدًا';

  @override
  String get toolAddMilestones => 'إضافة مراحل';

  @override
  String get toolAddNote => 'إضافة ملاحظة';

  @override
  String get toolCreateGoal => 'إنشاء هدف';

  @override
  String get toolCreateTask => 'إنشاء مهمة';

  @override
  String get toolDeleteTask => 'حذف مهمة';

  @override
  String get toolLogHabit => 'تسجيل عادة';

  @override
  String get toolMoveTask => 'تغيير الموعد النهائي';

  @override
  String get toolPlanTask => 'تحديد وقت العمل';

  @override
  String get topPriorities => 'الأولويات الثلاث';

  @override
  String get totalSpent => 'إجمالي المصروفات';

  @override
  String get tryAgain => 'ذاكره مرة أخرى';

  @override
  String turnOnSection(String section) {
    return 'شغّل قسم $section من إعدادات الصحة أول';
  }

  @override
  String typeToConfirm(String word) {
    return 'اكتب «$word» للتأكيد';
  }

  @override
  String get unarchive => 'إلغاء الأرشفة';

  @override
  String get unarchived => 'تمت الاستعادة';

  @override
  String get undo => 'تراجع';

  @override
  String unitHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ساعة',
      many: '$n ساعة',
      few: '$n ساعات',
      two: 'ساعتان',
      one: 'ساعة',
    );
    return '$_temp0';
  }

  @override
  String unitMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n دقيقة',
      many: '$n دقيقة',
      few: '$n دقائق',
      two: 'دقيقتان',
      one: 'دقيقة',
      zero: '0 دقيقة',
    );
    return '$_temp0';
  }

  @override
  String get unlock => 'افتح';

  @override
  String get unlockFailed => 'ما انفتح';

  @override
  String get unlockReason => 'افتح الأقسام الصحية في حياتي';

  @override
  String get unpin => 'إلغاء التثبيت';

  @override
  String get unread => 'غير المقروءة';

  @override
  String get unscheduled => 'غير مجدولة';

  @override
  String get untilDeleted => 'حتى أحذفها';

  @override
  String get untitled => 'بلا عنوان';

  @override
  String get upcoming => 'المواعيد القادمة';

  @override
  String get upgrade => 'الترقية';

  @override
  String usageToday(int used, int limit) {
    return '$used/$limit طلبات للمساعد اليوم';
  }

  @override
  String get use24h => 'نظام 24 ساعة';

  @override
  String get useMyLocation => 'استخدم موقعي';

  @override
  String usuallyOnDay(int n) {
    return 'عادة في اليوم $n من الدورة';
  }

  @override
  String get verificationLocal => 'غير مطلوب في الوضع المحلي';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get viewAllGoals => 'عرض كل الأهداف';

  @override
  String get viewCalendar => 'التقويم';

  @override
  String get vitals => 'القياسات';

  @override
  String get vitalsFromDevices => 'اقرأ الوزن والضغط من تطبيق الصحة في جوالك';

  @override
  String get vitalsNote =>
      'لمتابعتك الشخصية. هذي الأرقام مو تشخيص، واقرأ أكثر في «توعية صحية».';

  @override
  String get vitalsSub => 'الوزن والخصر والنبض والضغط والدهون';

  @override
  String vsLastMonth(String amount) {
    return 'الشهر الماضي: $amount';
  }

  @override
  String get warnBleeding => 'نزيف مهبلي';

  @override
  String get warnCalf => 'ألم أو تورم في السمانة';

  @override
  String get warnChest => 'ألم في الصدر أو ضيق نفس غير معتاد';

  @override
  String get warnContractions => 'انقباضات منتظمة ومؤلمة';

  @override
  String get warnDizzy => 'دوخة أو شعور بالإغماء';

  @override
  String get warnFluid => 'نزول سوائل';

  @override
  String get warnHeadache => 'صداع شديد';

  @override
  String get warnHeavyBleeding => 'نزيف أكثر من قبل';

  @override
  String get warnLeaking => 'تسرّب البول أثناء التمرين';

  @override
  String get warnPain => 'ألم (مو مجرد تعب)';

  @override
  String get warnPelvicHeaviness => 'ثقل أو بروز في منطقة الحوض';

  @override
  String waterAverage(String ml) {
    return 'الماء: $ml مل يوميًا بالمتوسط';
  }

  @override
  String get waterGoal => 'هدف الماء اليومي';

  @override
  String waterMl(String ml) {
    return '$ml مل';
  }

  @override
  String waterOfGoal(String ml, String goal) {
    return 'الماء $ml / $goal مل';
  }

  @override
  String get wdFri => 'الجمعة';

  @override
  String get wdMon => 'الإثنين';

  @override
  String get wdSat => 'السبت';

  @override
  String get wdSun => 'الأحد';

  @override
  String get wdThu => 'الخميس';

  @override
  String get wdTue => 'الثلاثاء';

  @override
  String get wdWed => 'الأربعاء';

  @override
  String get week => 'أسبوع';

  @override
  String get weekAhead => 'أيامك السبعة القادمة';

  @override
  String weekAverage(String value) {
    return 'متوسط الأسبوع: $value';
  }

  @override
  String get weekBusy => 'يوم مزدحم';

  @override
  String weekEvents(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n موعدًا',
      few: '$n مواعيد',
      two: 'موعدان',
      one: 'موعد واحد',
      zero: 'لا مواعيد',
    );
    return '$_temp0';
  }

  @override
  String get weekLoad => 'حجم الالتزامات';

  @override
  String get weekReport => 'التقرير الأسبوعي';

  @override
  String get weekReportNote => 'المتوسطات تحسب الأيام اللي سجلت فيها بس.';

  @override
  String get weekStart => 'بداية الأسبوع';

  @override
  String weekTasks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n مهمة مستحقة',
      few: '$n مهام مستحقة',
      two: 'مهمتان مستحقتان',
      one: 'مهمة مستحقة',
      zero: 'لا مهام مستحقة',
    );
    return '$_temp0';
  }

  @override
  String weekWorkouts(int done, int planned) {
    return 'أنجزت $done من $planned تمارين هذا الأسبوع';
  }

  @override
  String get weeklyGoalQuestion => 'كم درسًا في الأسبوع؟';

  @override
  String weeklyLessons(int done, int goal) {
    return '$done من $goal دروس هذا الأسبوع';
  }

  @override
  String get weeklyPlan => 'خطة الأسبوع';

  @override
  String get weightKg => 'كجم';

  @override
  String get welcomeBody =>
      'وقتك وأهدافك وعاداتك وملاحظاتك ومصروفاتك في مكان واحد يخطط معك.';

  @override
  String get welcomeTitle => 'رتّب حياتك، خطوة بخطوة';

  @override
  String get wentToBed => 'وقت النوم';

  @override
  String get whatThisPhoneReads => 'وش يقرأ هذا الجوال';

  @override
  String get whatWeStore => 'ما الذي يحفظه حياتي';

  @override
  String get whatWeStoreBody =>
      'حسابك (البريد وبصمة مملّحة لكلمة المرور)، وتفضيلاتك، والمهام والمواعيد والأهداف ومراحلها، والعادات وسجلاتها، والملاحظات، والمصروفات والميزانيات، ومحادثات المساعد (بحسب إعداد الاحتفاظ)، وسجل إجراءات دون محتوى الرسائل. في الوضع المحلي يبقى كل ذلك على هذا الجهاز.';

  @override
  String get whatWeStoreBodyRemote =>
      'حسابك (البريد؛ وكلمة المرور تديرها خدمة المصادقة ولا يحفظها التطبيق)، وتفضيلاتك، والمهام والمواعيد والأهداف ومراحلها، والعادات وسجلاتها، والملاحظات، والمصروفات والميزانيات، تُحفظ في حسابك على خوادمنا ولا يقرؤها غيرك (أمان على مستوى الصف)، مع نسخة على هذا الجهاز للعمل دون اتصال. محادثات المساعد تبقى حاليًا على هذا الجهاز بحسب إعداد الاحتفاظ.';

  @override
  String get whichSourceCounts => 'أي مصدر يُعتمد';

  @override
  String get whyOptional => 'لماذا هذا الهدف مهم؟ (اختياري)';

  @override
  String get woBasketball => 'كرة سلة';

  @override
  String get woCycling => 'دراجة';

  @override
  String get woElliptical => 'جهاز الإليبتيكال';

  @override
  String get woFootball => 'كرة قدم';

  @override
  String get woHiit => 'تمارين متقطعة عالية الشدة';

  @override
  String get woHiking => 'هايكنج';

  @override
  String get woOther => 'تمرين';

  @override
  String get woPilates => 'بيلاتس';

  @override
  String get woRowing => 'تجديف';

  @override
  String get woRunning => 'جري';

  @override
  String get woStairs => 'درج';

  @override
  String get woStrength => 'تمارين قوة';

  @override
  String get woSwimming => 'سباحة';

  @override
  String get woTennis => 'تنس';

  @override
  String get woWalking => 'مشي';

  @override
  String get woYoga => 'يوغا';

  @override
  String get wokeUp => 'وقت الصحيان';

  @override
  String get wokeUpOn => 'يوم الصحيان';

  @override
  String get womensUnavailable => 'هذا القسم ضمن صحة المرأة.';

  @override
  String get wordsAddedToReview =>
      'أُضيفت كلمات هذا الدرس إلى مراجعاتك بدءًا من الغد.';

  @override
  String get workBlock => 'العمل / الدراسة';

  @override
  String get workDaysHint =>
      'تنطبق ساعات العمل/الدراسة على الأيام المحددة. امسح وقت البداية لإزالتها.';

  @override
  String get workEnd => 'إلى';

  @override
  String get workStart => 'العمل/الدراسة من';

  @override
  String get workoutDoneToday => 'أنجزت تمرين اليوم';

  @override
  String get workoutNote => 'ملاحظة';

  @override
  String get workoutNoteHint => 'مثال: شعرت بشد في الركبة مع الطعن';

  @override
  String get workoutSaved => 'حُفظ التمرين. أحسنت!';

  @override
  String get workoutSavedPartial => 'حُفظ ما أنجزته. كل جهد يُحسب.';

  @override
  String workoutsN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n تمرين',
      few: '$n تمارين',
      two: 'تمرينين',
      one: 'تمرين',
    );
    return '$_temp0';
  }

  @override
  String get yesterday => 'أمس';

  @override
  String get yourData => 'بياناتك';

  @override
  String get yourSkills => 'مهاراتك (اختبار تحديد المستوى)';
}
