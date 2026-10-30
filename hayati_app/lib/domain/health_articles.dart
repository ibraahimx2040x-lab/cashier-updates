import '../data/models/settings.dart';
import 'fitness/programs.dart' show Audience, programAudienceVisible;

/// Screen 47 — short, optional health reading. General information from
/// named public-health sources, opened only when the user chooses. Never
/// advice for a person, never a diagnosis.
class HealthArticle {
  const HealthArticle({
    required this.id,
    required this.audience,
    required this.ar,
    required this.en,
    required this.summaryAr,
    required this.summaryEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.sources,
  });

  final String id;
  final Audience audience;
  final String ar;
  final String en;
  final String summaryAr;
  final String summaryEn;
  final List<String> bodyAr;
  final List<String> bodyEn;

  /// (organisation and page, site).
  final List<(String, String)> sources;

  String title(String lang) => lang == 'ar' ? ar : en;
  String summary(String lang) => lang == 'ar' ? summaryAr : summaryEn;
  List<String> body(String lang) => lang == 'ar' ? bodyAr : bodyEn;
}

const healthArticles = <HealthArticle>[
  HealthArticle(
    id: 'sleep_basics',
    audience: Audience.all,
    ar: 'أساسيات النوم',
    en: 'Sleep basics',
    summaryAr: 'كم ساعة يحتاج البالغ، وعادات تساعد على نوم أفضل.',
    summaryEn: 'How much adults need, and habits that help.',
    bodyAr: [
      'توصي مراكز مكافحة الأمراض الأمريكية (CDC) البالغين من 18 إلى 60 سنة بالنوم 7 ساعات أو أكثر كل ليلة.',
      'ثبّت موعد النوم والاستيقاظ قدر الإمكان، حتى في الإجازات.',
      'خلّ غرفة النوم مظلمة وهادئة ومعتدلة الحرارة، وقلّل الشاشات قبل النوم.',
      'تجنّب الكافيين والوجبات الثقيلة قرب وقت النوم، والحركة خلال النهار تساعد.',
      'إذا استمرت صعوبة النوم أسابيع وأثّرت على يومك، أو لاحظ أحد شخيرًا عاليًا مع توقف في التنفس أثناء النوم، فراجع الطبيب.',
    ],
    bodyEn: [
      'The US Centers for Disease Control and Prevention (CDC) recommends that adults aged 18 to 60 sleep 7 or more hours a night.',
      'Keep regular times for going to bed and getting up, weekends included.',
      'Keep the bedroom dark, quiet and comfortably cool, and cut down on screens before bed.',
      'Avoid caffeine and heavy meals close to bedtime; being active during the day helps.',
      'See a doctor if poor sleep lasts for weeks and affects your days, or if someone notices loud snoring with pauses in breathing.',
    ],
    sources: [('CDC — Sleep', 'cdc.gov'), ('NHS — How to get to sleep', 'nhs.uk')],
  ),
  HealthArticle(
    id: 'blood_pressure',
    audience: Audience.all,
    ar: 'ضغط الدم: وش تعني الأرقام',
    en: 'Blood pressure: what the numbers mean',
    summaryAr: 'القراءة المثالية، ومتى يُعدّ مرتفعًا، وكيف تقيسه صح.',
    summaryEn: 'The ideal range, when it counts as high, and measuring it well.',
    bodyAr: [
      'الرقم الأول (الانقباضي) ضغط الدم عند انقباض القلب، والثاني (الانبساطي) بين النبضات.',
      'حسب هيئة الخدمات الصحية البريطانية (NHS): المثالي بين 90/60 و120/80، ويُعدّ مرتفعًا من 140/90 فأكثر في العيادة، أو 135/85 فأكثر في القياس المنزلي.',
      'الضغط المرتفع غالبًا بدون أعراض، فالقياس هو الطريقة الوحيدة لمعرفته.',
      'للقياس: اجلس مرتاحًا 5 دقائق، الذراع على مستوى القلب، بدون كافيين أو رياضة قبلها بنصف ساعة، وخذ قراءتين بينهما دقيقة.',
      'قراءة 180/120 أو أعلى، خصوصًا مع ألم في الصدر أو ضيق تنفس أو صداع شديد أو تغيّر في النظر، تحتاج مساعدة طبية عاجلة.',
    ],
    bodyEn: [
      'The first number (systolic) is the pressure as the heart beats; the second (diastolic) is between beats.',
      "According to the UK's NHS, ideal is between 90/60 and 120/80; 140/90 or higher at a clinic, or 135/85 or higher at home, counts as high.",
      'High blood pressure usually has no symptoms, so measuring is the only way to know.',
      'To measure: sit quietly for 5 minutes, arm at heart level, no caffeine or exercise for half an hour before, and take two readings a minute apart.',
      'A reading of 180/120 or higher, especially with chest pain, shortness of breath, a severe headache or changes in vision, needs urgent medical help.',
    ],
    sources: [('NHS — High blood pressure', 'nhs.uk'), ('American Heart Association — Understanding blood pressure readings', 'heart.org')],
  ),
  HealthArticle(
    id: 'resting_heart_rate',
    audience: Audience.all,
    ar: 'نبض الراحة',
    en: 'Resting heart rate',
    summaryAr: 'المعدل المعتاد للبالغين، ومتى تستشير الطبيب.',
    summaryEn: 'The usual range for adults, and when to check with a doctor.',
    bodyAr: [
      'عند أغلب البالغين يكون نبض الراحة بين 60 و100 نبضة في الدقيقة.',
      'الرياضيون وأصحاب اللياقة العالية قد يكون نبضهم أقل من 60 وهذا طبيعي عندهم.',
      'يرتفع النبض مؤقتًا مع القهوة والتوتر والحرارة والمرض وقلة النوم.',
      'راجع الطبيب إذا كان نبض الراحة باستمرار فوق 100، أو تحت 60 مع دوخة أو إغماء أو ضيق تنفس. ألم الصدر يحتاج مساعدة عاجلة.',
    ],
    bodyEn: [
      'For most adults, the resting heart rate is between 60 and 100 beats a minute.',
      'Athletes and very fit people may be below 60, which is normal for them.',
      'Coffee, stress, heat, illness and short sleep raise it for a while.',
      'See a doctor if it is often above 100 at rest, or below 60 with dizziness, fainting or breathlessness. Chest pain needs urgent help.',
    ],
    sources: [('NHS — How to check your pulse', 'nhs.uk'), ('American Heart Association — All about heart rate', 'heart.org')],
  ),
  HealthArticle(
    id: 'pelvic_floor_women',
    audience: Audience.female,
    ar: 'عضلات قاع الحوض للمرأة',
    en: "Pelvic floor muscles for women",
    summaryAr: 'وش هي، وكيف تتمرنين عليها.',
    summaryEn: 'What they are and how to exercise them.',
    bodyAr: [
      'عضلات قاع الحوض تسند المثانة والأمعاء والرحم، وتضعف مع الحمل والولادة والتقدم في العمر.',
      'التمرين: شدّي العضلات كأنك توقفين البول والغازات معًا، ثبّتي، ثم أرخي تمامًا. لا تحبسين النفس ولا تشدّين البطن أو الفخذين.',
      'الهدف تقريبًا 10 شدّات بطيئة (تثبيت حتى 10 ثوانٍ) و10 سريعة، ثلاث مرات في اليوم.',
      'النتيجة تحتاج عادة بضعة أشهر من الانتظام. إذا استمر تسرّب البول، راجعي الطبيبة أو أخصائية علاج طبيعي لقاع الحوض.',
    ],
    bodyEn: [
      'The pelvic floor muscles support the bladder, bowel and womb; pregnancy, childbirth and age can weaken them.',
      'How: squeeze as if stopping both wee and wind, hold, then fully relax. Keep breathing and keep your tummy and thighs relaxed.',
      'Aim for about 10 slow squeezes (hold up to 10 seconds) and 10 quick ones, three times a day.',
      "It usually takes a few months of regular practice. If leaks continue, see a doctor or a pelvic health physiotherapist.",
    ],
    sources: [('NHS — Pelvic floor exercises', 'nhs.uk')],
  ),
  HealthArticle(
    id: 'exercise_pregnancy',
    audience: Audience.female,
    ar: 'الرياضة في الحمل وبعد الولادة',
    en: 'Exercise in pregnancy and after birth',
    summaryAr: 'كم يُنصح، ومتى تتوقفين.',
    summaryEn: 'How much is advised, and when to stop.',
    bodyAr: [
      'توصي منظمة الصحة العالمية الحوامل وبعد الولادة، إذا ما فيه مانع طبي، بـ150 دقيقة على الأقل أسبوعيًا من نشاط معتدل، مع تمارين تقوية.',
      'استشيري طبيبتك قبل البدء أو الزيادة، خصوصًا مع أي حالة صحية أو حمل عالي الخطورة.',
      'توقفي واطلبي المساعدة مع النزيف، أو انقباضات منتظمة، أو نزول سائل، أو دوخة، أو ألم في الصدر، أو صداع شديد، أو ألم وتورم في الساق.',
      'بعد الولادة: المشي الخفيف وتمارين قاع الحوض من الأيام الأولى إذا كنتِ بخير، والتمارين الأقوى بعد فحص ما بعد الولادة (حوالي 6 إلى 8 أسابيع)، وأطول بعد القيصرية.',
    ],
    bodyEn: [
      'The World Health Organization advises at least 150 minutes a week of moderate activity, with muscle strengthening, during pregnancy and after birth when there is no medical reason not to.',
      'Check with your doctor or midwife before starting or doing more, especially with a health condition or a high-risk pregnancy.',
      'Stop and get help for bleeding, regular contractions, leaking fluid, dizziness, chest pain, a severe headache, or calf pain and swelling.',
      'After birth: gentle walks and pelvic floor exercises from the first days if you feel well; more demanding exercise after your postnatal check (around 6 to 8 weeks), longer after a caesarean.',
    ],
    sources: [('WHO — Guidelines on physical activity and sedentary behaviour (2020)', 'who.int'), ('NHS — Exercise in pregnancy', 'nhs.uk')],
  ),
  HealthArticle(
    id: 'pelvic_floor_men',
    audience: Audience.male,
    ar: 'عضلات قاع الحوض للرجل',
    en: 'Pelvic floor muscles for men',
    summaryAr: 'تساعد في التحكم بالمثانة، خصوصًا بعد عمليات البروستاتا.',
    summaryEn: 'They help bladder control, especially after prostate surgery.',
    bodyAr: [
      'عند الرجل أيضًا عضلات قاع حوض تسند المثانة والأمعاء، وتساعد في التحكم بالبول.',
      'التمرين: شدّ العضلات كأنك توقف البول وتمسك الغازات، ثبّت، ثم أرخِ تمامًا، بدون حبس النفس أو شدّ البطن والأرداف.',
      'الهدف تقريبًا 10 شدّات بطيئة و10 سريعة، ثلاث مرات في اليوم.',
      'يُنصح بها كثيرًا بعد عمليات البروستاتا. إذا استمر التسرّب أو صعوبة التحكم، راجع الطبيب.',
    ],
    bodyEn: [
      'Men have pelvic floor muscles too; they support the bladder and bowel and help with bladder control.',
      'How: squeeze as if stopping wee and holding in wind, hold, then fully relax, without holding your breath or tightening your tummy or buttocks.',
      'Aim for about 10 slow and 10 quick squeezes, three times a day.',
      "They're often advised after prostate surgery. If leaks or poor control continue, see a doctor.",
    ],
    sources: [('NHS — Urinary incontinence: treatment', 'nhs.uk')],
  ),
  HealthArticle(
    id: 'prostate_urinary',
    audience: Audience.male,
    ar: 'البروستاتا والمسالك البولية: متى تراجع الطبيب',
    en: 'Prostate and urinary health: when to see a doctor',
    summaryAr: 'علامات تستاهل فحص، وأغلبها مو خطيرة.',
    summaryEn: "Signs worth a check, most of them not serious.",
    bodyAr: [
      'راجع الطبيب إذا صرت تحتاج تتبول أكثر من المعتاد خصوصًا في الليل، أو صعب عليك تبدأ، أو صار التدفق ضعيفًا، أو تحس إن المثانة ما فرغت.',
      'هذي الأعراض كثيرًا سببها تضخم البروستاتا الحميد، وهو مو سرطان، لكن الفحص يحدد السبب.',
      'الدم في البول أو السائل المنوي يحتاج مراجعة الطبيب قريبًا.',
      'ألم شديد أو عدم القدرة على التبول أبدًا يحتاج مساعدة عاجلة.',
    ],
    bodyEn: [
      'See a doctor if you need to pee more often than usual, especially at night, find it hard to start, have a weak flow, or feel your bladder hasn’t emptied.',
      'These are often caused by an enlarged prostate, which is not cancer, but a check finds the cause.',
      'Blood in your urine or semen needs a doctor soon.',
      'Severe pain or being unable to pee at all needs urgent help.',
    ],
    sources: [('NHS — Benign prostate enlargement', 'nhs.uk'), ('NHS — Prostate cancer: symptoms', 'nhs.uk')],
  ),
  HealthArticle(
    id: 'testicular_check',
    audience: Audience.male,
    ar: 'الفحص الذاتي للخصيتين',
    en: 'Checking your testicles',
    summaryAr: 'مرة في الشهر، وكيف تسويه.',
    summaryEn: 'Once a month, and how.',
    bodyAr: [
      'افحص مرة في الشهر تقريبًا، وأسهل وقت بعد الاستحمام بماء دافئ.',
      'افحص كل خصية لحالها بين أصابعك بلطف، وانتبه لأي كتلة أو تورم أو تغيّر في الحجم أو الملمس.',
      'وجود أنبوب ناعم خلف الخصية (البربخ) طبيعي.',
      'أغلب الكتل مو سرطان، لكن أي تغيّر يستاهل مراجعة الطبيب بدون تأخير.',
    ],
    bodyEn: [
      'Check about once a month; after a warm bath or shower is easiest.',
      'Gently roll each testicle between your fingers and look for any lump, swelling, or change in size or feel.',
      'A soft tube at the back (the epididymis) is normal.',
      'Most lumps are not cancer, but any change is worth seeing a doctor about without delay.',
    ],
    sources: [('NHS — Testicular cancer: symptoms', 'nhs.uk')],
  ),
];

/// Articles for this user: shared ones, and the ones for their sex only.
List<HealthArticle> articlesFor(UserSettings s) => [for (final a in healthArticles) if (programAudienceVisible(a.audience, s)) a];

HealthArticle? articleById(String? id) => healthArticles.where((a) => a.id == id).firstOrNull;
