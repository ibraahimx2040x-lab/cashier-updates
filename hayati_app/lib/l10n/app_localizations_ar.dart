// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

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
  String get addEvent => 'إضافة موعد';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get addFirstGoal => 'أضف هدفًا';

  @override
  String get addFirstTask => 'أضف أول مهمة';

  @override
  String get addGoal => 'إضافة هدف';

  @override
  String get addHabit => 'إضافة عادة';

  @override
  String get addMilestone => 'إضافة مرحلة';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get addTask => 'إضافة مهمة';

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
  String aiHabitLogged(String name) {
    return 'سأسجّل «$name» كمنجزة اليوم.';
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
  String get aiNoGoalToSplit =>
      'لم أجد هدفًا نشطًا بلا مراحل. أنشئ هدفًا أولًا أو أخبرني بما تريد تعلمه.';

  @override
  String get aiNoOverdue => 'لا توجد لديك مهام متأخرة. 🎉';

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
  String get any => 'الكل';

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
  String get archive => 'أرشفة';

  @override
  String get archiveGoal => 'أرشفة';

  @override
  String get archived => 'تمت الأرشفة';

  @override
  String get archivedNotes => 'الملاحظات المؤرشفة';

  @override
  String get askAssistantReplan => 'اطلب من المساعد إعادة ترتيب يومي';

  @override
  String get askAssistantReview => 'اسأل المساعد';

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
  String get back => 'السابق';

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
  String get billingNote =>
      'لا تُفعّل المزايا المدفوعة إلا بعد تحقق خادمنا من الشراء عبر المتجر.';

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
  String get byCategory => 'حسب الفئة';

  @override
  String get byMilestones => 'بالمراحل';

  @override
  String get byMilestonesHint =>
      'التقدم = المراحل المكتملة ÷ كل المراحل. تكتمل المرحلة عند تحديدها أو عند إنجاز كل مهامها.';

  @override
  String get calendar => 'التقويم';

  @override
  String get cancel => 'إلغاء';

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
  String get clear => 'مسح';

  @override
  String get clearLog => 'مسح السجل';

  @override
  String get clearRead => 'مسح المقروءة';

  @override
  String get comingSoon => 'قريبًا';

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
  String get contactSupport => 'التواصل مع الدعم';

  @override
  String get couldNotFit => 'لم يتسع لها الوقت';

  @override
  String get createAccount => 'إنشاء الحساب';

  @override
  String get createFirstPlan => 'أنشئ خطتي الأولى';

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
  String get deleteAccountSub => 'إزالة حسابك وبياناتك نهائيًا';

  @override
  String get deleteAllChats => 'حذف كل المحادثات';

  @override
  String get deleteAllChatsBody =>
      'ستُحذف كل المحادثات والاقتراحات المعلقة. التغييرات المطبقة تبقى.';

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
  String get deleteNoteBody =>
      'ستُحذف الملاحظة نهائيًا. يمكنك أرشفتها بدلًا من ذلك.';

  @override
  String get deleteNoteTitle => 'حذف الملاحظة؟';

  @override
  String deleteTaskBody(String title) {
    return 'ستُحذف «$title» نهائيًا. يمكنك أرشفتها بدلًا من ذلك.';
  }

  @override
  String get deleteTaskTitle => 'حذف المهمة؟';

  @override
  String get deleted => 'تم الحذف';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get details => 'التفاصيل';

  @override
  String get discard => 'تجاهل';

  @override
  String get discardMessage =>
      'لديك تعديلات غير محفوظة. هل تريد الخروج دون حفظ؟';

  @override
  String get discardTitle => 'تجاهل التعديلات؟';

  @override
  String get displayName => 'الاسم المعروض';

  @override
  String get displayNameOptional => 'اسمك (اختياري)';

  @override
  String get documents => 'المستندات';

  @override
  String get doneDays => 'منجز / مستحق';

  @override
  String get dragHint => 'اضغط مطولًا واسحب المهمة إلى ساعة لجدولتها.';

  @override
  String get due => 'الاستحقاق';

  @override
  String get dueShort => 'تستحق';

  @override
  String get edit => 'تعديل';

  @override
  String get editEvent => 'تعديل الموعد';

  @override
  String get editGoal => 'الهدف';

  @override
  String get editHabit => 'تعديل العادة';

  @override
  String get editMilestone => 'تعديل المرحلة';

  @override
  String get editTask => 'تعديل المهمة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailPassword => 'البريد وكلمة المرور';

  @override
  String get emailVerification => 'التحقق من البريد';

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
  String get errRequired => 'هذا الحقل مطلوب';

  @override
  String get errSave => 'تعذر الحفظ. راجع الحقول وحاول مرة أخرى.';

  @override
  String get errTargetBeforeStart =>
      'يجب أن يكون التاريخ المستهدف بعد تاريخ البداية';

  @override
  String get estimatedDuration => 'مدة مقترحة 30 د';

  @override
  String get estimatedMinutes => 'المدة التقديرية (بالدقائق)';

  @override
  String get eventTitle => 'عنوان الموعد';

  @override
  String get eventsLabel => 'المواعيد';

  @override
  String get everyDay => 'كل يوم';

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
  String exportCopied(int chars) {
    return 'تم النسخ ($chars حرفًا)';
  }

  @override
  String get exportData => 'تصدير بياناتي';

  @override
  String get exportDataSub => 'ينسخ كل بياناتك بصيغة JSON إلى الحافظة';

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
      'في هذا الإصدار تظهر التذكيرات في مركز الإشعارات أثناء فتح التطبيق. تأكد أن للمهمة تذكيرًا وموعدًا نهائيًا أو وقتًا مخططًا.';

  @override
  String get faq4q => 'لا تصلني التذكيرات';

  @override
  String get faq5a =>
      'في الوضع المحلي على هذا الجهاز فقط. يمكنك تصديرها في أي وقت من الخصوصية وإدارة البيانات.';

  @override
  String get faq5q => 'أين تُحفظ بياناتي؟';

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
  String get fixedBlocks => 'التزامات ثابتة';

  @override
  String get fixedCommitments => 'الالتزامات الثابتة';

  @override
  String get forgotLocalMode =>
      'في هذا الإصدار تُحفظ الحسابات على هذا الجهاز فقط، لذا فإن استعادة كلمة المرور عبر البريد غير متاحة بعد. ستُفعّل عند ربط خدمة الحسابات السحابية.';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get forgotTitle => 'استعادة الوصول';

  @override
  String get freeTime => 'الوقت المتاح';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get goalActive => 'نشط';

  @override
  String get goalArchived => 'مؤرشف';

  @override
  String get goalCompleted => 'مكتمل';

  @override
  String get goalPaused => 'متوقف';

  @override
  String get goalStepHint => 'اختر مثالًا أو اكتب هدفك. يمكنك تخطي هذه الخطوة.';

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
  String get hasBreak => 'إضافة استراحة يومية';

  @override
  String get hasWorkHours => 'لدي ساعات عمل أو دراسة ثابتة';

  @override
  String get haveAccount => 'لدي حساب';

  @override
  String get helpTitle => 'المساعدة والدعم';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get highlights => 'أبرز الإنجازات';

  @override
  String get historyHint =>
      'اضغط على يوم سابق لتصحيحه. الأيام غير المستحقة محايدة.';

  @override
  String get homeSections => 'الصفحة الرئيسية';

  @override
  String get inactiveHabits => 'غير نشطة';

  @override
  String get includeTechInfo => 'إرفاق معلومات تقنية';

  @override
  String get initialTasks => 'المهام الأولية';

  @override
  String get interestsHint =>
      'اختر ما يناسبك، ويمكنك التغيير لاحقًا. الأقسام غير المختارة تُخفى ولا تُحذف.';

  @override
  String get itemGone => 'هذا العنصر لم يعد موجودًا.';

  @override
  String get keepAnyway => 'الإبقاء عليه';

  @override
  String get keepChats => 'الاحتفاظ بالمحادثات';

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
  String get lastWeek => 'الأسبوع الماضي';

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
  String get locationOptional => 'المكان (اختياري)';

  @override
  String get manageAssistantAccess => 'إدارة صلاحيات المساعد';

  @override
  String get manual => 'يدويًا';

  @override
  String get manualHint => 'أنت من يحدد النسبة بنفسك.';

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
  String get memberSince => 'تاريخ إنشاء الحساب';

  @override
  String get menu => 'القائمة';

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
  String get month => 'شهر';

  @override
  String get monthlyBudget => 'الميزانية الشهرية';

  @override
  String get more => 'المزيد';

  @override
  String get moreFilters => 'تصفية إضافية';

  @override
  String get moreOptions => 'خيارات إضافية';

  @override
  String get moveTomorrow => 'نقل إلى الغد';

  @override
  String movedTo(String time) {
    return 'نُقلت إلى $time';
  }

  @override
  String get movedTomorrow => 'نُقلت إلى الغد';

  @override
  String get multiCurrencyNote =>
      'يُجمع كل مبلغ بعملته — لا تُجمع العملات المختلفة معًا.';

  @override
  String get myGoals => 'أهدافي';

  @override
  String get myNotes => 'ملاحظاتي';

  @override
  String get navAssistant => 'المساعد';

  @override
  String get navExpenses => 'المصروفات';

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
  String get navProgress => 'تقدمي';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navTasks => 'المهام';

  @override
  String get navTime => 'وقتي';

  @override
  String get neededTime => 'تحتاج المهام';

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
  String get next => 'التالي';

  @override
  String get nextPeriod => 'التالي';

  @override
  String get noActions => 'لا توجد إجراءات بعد.';

  @override
  String get noActiveGoals => 'لا توجد أهداف نشطة حاليًا.';

  @override
  String get noConversations => 'لا توجد محادثات سابقة.';

  @override
  String get noExpensesPeriod => 'لا توجد مصروفات في هذه الفترة';

  @override
  String get noGoalsYet => 'لا توجد أهداف بعد';

  @override
  String get noHabitsDueToday => 'لا توجد عادات مستحقة اليوم.';

  @override
  String get noHabitsYet => 'لا توجد عادات بعد';

  @override
  String get noLinkedTasks => 'لا توجد مهام مرتبطة بهذا الهدف بعد.';

  @override
  String get noMilestones => 'لا توجد مراحل بعد.';

  @override
  String get noNotesYet => 'لا توجد ملاحظات بعد';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get noReminder => 'بدون تذكير';

  @override
  String get noSearchResults => 'لا توجد نتائج';

  @override
  String get noTasksToday => 'لا توجد مهام لليوم.';

  @override
  String get noUnread => 'لا توجد إشعارات غير مقروءة';

  @override
  String get noUpcoming => 'لا توجد مواعيد قادمة.';

  @override
  String get none => 'بدون';

  @override
  String get notDue => 'غير مستحق';

  @override
  String get notLogged => 'لم يُسجّل';

  @override
  String get notSet => 'غير محدد';

  @override
  String get noteBody => 'اكتب ملاحظتك…';

  @override
  String get noteTitle => 'العنوان';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get nothingScheduled => 'لا يوجد شيء مجدول';

  @override
  String get nothingToPlan => 'لا توجد مهام مفتوحة للتخطيط لهذا اليوم.';

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
  String notifTaskTitle(String title) {
    return 'تذكير: $title';
  }

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
  String get ok => 'حسنًا';

  @override
  String get onboardingNoAuto =>
      'لن يُنشأ أو يُجدول أي شيء تلقائيًا. أنت من يختار ما يضيفه بعد ذلك.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get organizeGroup => 'التنظيم';

  @override
  String get osNotificationsNote =>
      'تظهر التذكيرات هنا أثناء فتح التطبيق. ستُضاف إشعارات الجهاز مع الخدمة السحابية.';

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
  String get password => 'كلمة المرور';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور';

  @override
  String get passwordRule => '8 أحرف على الأقل، تحتوي على حرف ورقم';

  @override
  String get pastDay => 'هذا اليوم انقضى.';

  @override
  String get pauseGoal => 'إيقاف مؤقت';

  @override
  String periodCovers(String from, String to) {
    return 'الفترة من $from إلى $to';
  }

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
  String get pin => 'تثبيت';

  @override
  String get planApplied => 'تم اعتماد الخطة';

  @override
  String get planEmptyToday => 'لا شيء مخطط لليوم بعد.';

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
  String planSummary(int done, int total) {
    return 'أنجزت $done من $total مهام اليوم';
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
  String get previous => 'السابق';

  @override
  String get previousChats => 'المحادثات السابقة';

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
  String get profileTitle => 'الملف الشخصي والحساب';

  @override
  String get progress => 'التقدم';

  @override
  String get progressManual => 'تقدم يدوي';

  @override
  String get progressMethod => 'كيف يُقاس التقدم؟';

  @override
  String get progressNotMeasured => 'لم يُقَس بعد';

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
  String get quickAdd => 'إضافة سريعة';

  @override
  String get reason => 'السبب';

  @override
  String get reasonDeadline => 'ستنتهي بعد وقت استحقاقها';

  @override
  String get reasonNoSlot => 'لا توجد فترة فارغة طويلة بما يكفي';

  @override
  String get reasonNoTime => 'لا يكفي الوقت المتبقي اليوم';

  @override
  String get regional => 'المنطقة والوقت';

  @override
  String get reject => 'رفض';

  @override
  String get reminder => 'التذكير';

  @override
  String get reminderNeedsTime =>
      'حدد موعدًا نهائيًا أو وقتًا مخططًا لضبط التذكير.';

  @override
  String get reminderTimeOptional => 'وقت التذكير (اختياري)';

  @override
  String get removeFromPlan => 'إزالة من خطة اليوم';

  @override
  String get removeItem => 'إزالة هذا التغيير';

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
  String get restBlock => 'استراحة';

  @override
  String get restore => 'استعادة';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get resumeGoal => 'تفعيل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get reviewChanges => 'مراجعة التغييرات';

  @override
  String get reviewMyPlan => 'راجع خطتي';

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
  String get saveEvent => 'حفظ الموعد';

  @override
  String get saveGoal => 'حفظ الهدف';

  @override
  String get saveTask => 'حفظ المهمة';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get saving => 'جارٍ الحفظ…';

  @override
  String get scheduleGroup => 'الموعد';

  @override
  String get search => 'بحث';

  @override
  String get sectionsShown => 'الأقسام الظاهرة في التطبيق';

  @override
  String get send => 'إرسال';

  @override
  String get sessionLength => 'مدة الجلسة';

  @override
  String get sessions => 'الجلسات';

  @override
  String get sessionsLocal =>
      'في الوضع المحلي جلسة واحدة لكل جهاز، وتسجيل الخروج ينهيها.';

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
  String get skip => 'تخطٍ';

  @override
  String get spending => 'المصروفات';

  @override
  String get splashFailed => 'تعذر تشغيل حياتي.';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get startTime => 'البداية';

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
  String stepOf(int step, int total) {
    return 'الخطوة $step من $total';
  }

  @override
  String get stepsOptional => 'خطوات تكرار المشكلة (اختياري)';

  @override
  String get stop => 'إيقاف';

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
  String get suggestedPlan => 'الخطة المقترحة';

  @override
  String get switchToSignIn => 'لديك حساب؟ سجّل الدخول';

  @override
  String get switchToSignUp => 'جديد هنا؟ أنشئ حسابًا';

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
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get time => 'الوقت';

  @override
  String get timezone => 'المنطقة الزمنية';

  @override
  String get timezoneDetected =>
      'مكتشفة من جهازك. تُعرض الأوقات وفق المنطقة الزمنية للجهاز.';

  @override
  String get timezoneDeviceNote => 'يتبع إعداد الجهاز';

  @override
  String get today => 'اليوم';

  @override
  String get todayPlan => 'خطة اليوم';

  @override
  String get todaysHabits => 'عادات اليوم';

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
  String get verificationLocal => 'غير مطلوب في الوضع المحلي';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get viewAllGoals => 'عرض كل الأهداف';

  @override
  String get viewCalendar => 'التقويم';

  @override
  String vsLastMonth(String amount) {
    return 'الشهر الماضي: $amount';
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
  String get weekStart => 'بداية الأسبوع';

  @override
  String get welcomeBody =>
      'وقتك وأهدافك وعاداتك وملاحظاتك ومصروفاتك في مكان واحد يخطط معك.';

  @override
  String get welcomeTitle => 'رتّب حياتك، خطوة بخطوة';

  @override
  String get whatWeStore => 'ما الذي يحفظه حياتي';

  @override
  String get whatWeStoreBody =>
      'حسابك (البريد وبصمة مملّحة لكلمة المرور)، وتفضيلاتك، والمهام والمواعيد والأهداف ومراحلها، والعادات وسجلاتها، والملاحظات، والمصروفات والميزانيات، ومحادثات المساعد (بحسب إعداد الاحتفاظ)، وسجل إجراءات دون محتوى الرسائل. في الوضع المحلي يبقى كل ذلك على هذا الجهاز.';

  @override
  String get whyOptional => 'لماذا هذا الهدف مهم؟ (اختياري)';

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
  String get yourData => 'بياناتك';
}
