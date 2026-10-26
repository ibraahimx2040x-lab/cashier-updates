import '../../data/models/learning.dart';

/// The built-in English course: placement questions, short reading
/// passages, and ordered lessons per CEFR level. Explanations are in Arabic
/// for Arabic-speaking learners; examples and questions are in English.

class Word {
  const Word(this.id, this.en, this.ar, this.example);
  final String id;
  final String en;
  final String ar;
  final String example;
}

class Passage {
  const Passage(this.id, this.text);
  final String id;
  final String text;
}

class Question {
  const Question({
    required this.id,
    required this.skill,
    required this.level,
    required this.prompt,
    required this.options,
    required this.answer,
    this.passageId,
  });
  final String id;
  final Skill skill;
  final Cefr level;
  final String prompt;
  final List<String> options;

  /// Index into [options].
  final int answer;
  final String? passageId;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.level,
    required this.titleAr,
    required this.titleEn,
    required this.explainAr,
    required this.examples,
    required this.words,
    required this.quiz,
    this.minutes = 15,
  });
  final String id;
  final Cefr level;
  final String titleAr;
  final String titleEn;
  final List<String> explainAr;

  /// (English, Arabic) pairs.
  final List<(String, String)> examples;
  final List<Word> words;
  final List<Question> quiz;
  final int minutes;

  String title(String lang) => lang == 'ar' ? isolateLatin(titleAr) : titleEn;
}

final _latin = RegExp(r"[A-Za-z][A-Za-z0-9 '’.,!?()/+:\-]*[A-Za-z0-9.!?]|[A-Za-z]");

/// Wraps English runs inside Arabic text in Unicode isolates, so mixed
/// lines like "استخدم by: The book was written by…" keep their order.
String isolateLatin(String s) => s.replaceAllMapped(_latin, (m) => '\u2066${m[0]}\u2069');

Lesson? lessonById(String id) => lessons.where((l) => l.id == id).firstOrNull;
Word? wordById(String id) => [for (final l in lessons) ...l.words].where((w) => w.id == id).firstOrNull;
Passage? passageById(String? id) => passages.where((p) => p.id == id).firstOrNull;
List<Lesson> lessonsAt(Cefr level) => lessons.where((l) => l.level == level).toList();

Question _q(String id, Skill s, Cefr l, String prompt, List<String> options, int answer, [String? passage]) =>
    Question(id: id, skill: s, level: l, prompt: prompt, options: options, answer: answer, passageId: passage);

// ---------------------------------------------------------------- reading

const passages = <Passage>[
  Passage('p_a1',
      'My name is Sara. I am a student. I live in Jeddah with my family. Every morning I drink tea and go to school by bus. I like English and science.'),
  Passage('p_a2',
      'Last weekend Omar visited his grandparents in Abha. The weather was cooler than in Riyadh, so they walked in the park every evening. On Sunday he took the plane home because the drive is very long.'),
  Passage('p_b1',
      'Many people have started working from home in recent years. Some enjoy the extra time with their families, while others miss talking to colleagues. Experts say that a fixed daily routine and regular breaks help remote workers stay productive.'),
  Passage('p_b2',
      'Although the new metro line was expected to reduce traffic, early figures suggest the effect has been modest. Critics argue that the stations are too far from residential areas; supporters, however, insist that ridership will grow once connecting bus routes are introduced.'),
];

// -------------------------------------------------------------- placement

final placementQuestions = <Question>[
  // A1
  _q('pa1v1', Skill.vocabulary, Cefr.a1, 'The opposite of "big" is ___.', ['small', 'tall', 'long', 'new'], 0),
  _q('pa1v2', Skill.vocabulary, Cefr.a1, 'We sleep in the ___.', ['kitchen', 'bedroom', 'garden', 'office'], 1),
  _q('pa1g1', Skill.grammar, Cefr.a1, 'She ___ a teacher.', ['am', 'is', 'are', 'be'], 1),
  _q('pa1g2', Skill.grammar, Cefr.a1, 'They ___ from Egypt.', ['is', 'am', 'are', 'be'], 2),
  _q('pa1r1', Skill.reading, Cefr.a1, 'How does Sara go to school?', ['By car', 'On foot', 'By bus', 'By train'], 2, 'p_a1'),
  _q('pa1r2', Skill.reading, Cefr.a1, 'What does Sara drink in the morning?', ['Coffee', 'Tea', 'Milk', 'Juice'], 1, 'p_a1'),
  // A2
  _q('pa2v1', Skill.vocabulary, Cefr.a2, 'I need to ___ an appointment with the dentist.', ['make', 'do', 'take', 'go'], 0),
  _q('pa2v2', Skill.vocabulary, Cefr.a2, 'The shop is ___ — it doesn\'t open on Fridays.', ['closed', 'busy', 'cheap', 'empty'], 0),
  _q('pa2g1', Skill.grammar, Cefr.a2, 'Yesterday we ___ to the beach.', ['go', 'goes', 'went', 'gone'], 2),
  _q('pa2g2', Skill.grammar, Cefr.a2, 'This phone is ___ than my old one.', ['cheap', 'cheaper', 'cheapest', 'more cheap'], 1),
  _q('pa2r1', Skill.reading, Cefr.a2, 'Why did Omar fly home?', ['The plane was cheap.', 'The drive is very long.', 'It was raining.', 'He was late.'], 1, 'p_a2'),
  _q('pa2r2', Skill.reading, Cefr.a2, 'What was the weather like in Abha?', ['Hotter than Riyadh', 'Cooler than Riyadh', 'Very windy', 'Rainy'], 1, 'p_a2'),
  // B1
  _q('pb1v1', Skill.vocabulary, Cefr.b1, 'Could you ___ me a favour?', ['make', 'do', 'give', 'take'], 1),
  _q('pb1v2', Skill.vocabulary, Cefr.b1, 'She was ___ to hear she had passed the exam.', ['relieved', 'bored', 'annoyed', 'tired'], 0),
  _q('pb1g1', Skill.grammar, Cefr.b1, 'I ___ here since 2020.', ['live', 'lived', 'have lived', 'am living'], 2),
  _q('pb1g2', Skill.grammar, Cefr.b1, 'If it rains tomorrow, we ___ at home.', ['stay', 'will stay', 'would stay', 'stayed'], 1),
  _q('pb1r1', Skill.reading, Cefr.b1, 'According to experts, what helps remote workers?', ['Working longer hours', 'A fixed routine and breaks', 'Meeting colleagues daily', 'Moving to a bigger home'], 1, 'p_b1'),
  _q('pb1r2', Skill.reading, Cefr.b1, 'What do some remote workers miss?', ['Their families', 'Talking to colleagues', 'Free time', 'Their routine'], 1, 'p_b1'),
  // B2
  _q('pb2v1', Skill.vocabulary, Cefr.b2, 'The results were ___: not good, not bad.', ['modest', 'outstanding', 'disastrous', 'reluctant'], 0),
  _q('pb2v2', Skill.vocabulary, Cefr.b2, 'The company decided to ___ the launch until next year.', ['postpone', 'precede', 'pretend', 'prevent'], 0),
  _q('pb2g1', Skill.grammar, Cefr.b2, 'If I had known, I ___ you.', ['would tell', 'will tell', 'would have told', 'had told'], 2),
  _q('pb2g2', Skill.grammar, Cefr.b2, 'She said that she ___ tired.', ['is', 'was', 'were', 'has been'], 1),
  _q('pb2r1', Skill.reading, Cefr.b2, 'What do critics say about the metro?', ['It is too expensive.', 'Stations are far from homes.', 'Trains are too slow.', 'It has no buses.'], 1, 'p_b2'),
  _q('pb2r2', Skill.reading, Cefr.b2, 'What do supporters expect?', ['Fewer bus routes', 'Ridership will grow', 'Traffic will increase', 'The line will close'], 1, 'p_b2'),
];

// ---------------------------------------------------------------- lessons

final lessons = <Lesson>[
  // ------------------------------------------------------------------- A1
  Lesson(
    id: 'a1_be',
    level: Cefr.a1,
    titleAr: 'فعل الكينونة: am / is / are',
    titleEn: 'The verb "to be"',
    explainAr: [
      'نستخدم am وis وare لنقول من نحن، وما صفاتنا، وأين نحن.',
      'I ← am، وhe / she / it ← is، وyou / we / they ← are.',
      'النفي بإضافة not: I am not، she is not (isn\'t)، they are not (aren\'t). والسؤال بتقديم الفعل: Are you ready?',
    ],
    examples: [('I am a student.', 'أنا طالب.'), ('She isn\'t at home.', 'هي ليست في البيت.'), ('Are they your friends?', 'هل هم أصدقاؤك؟')],
    words: [
      Word('w_student', 'student', 'طالب', 'He is a student at the university.'),
      Word('w_teacher', 'teacher', 'معلّم', 'My teacher is very kind.'),
      Word('w_tired', 'tired', 'متعب', 'I am tired today.'),
      Word('w_ready', 'ready', 'جاهز', 'Are you ready?'),
      Word('w_friend', 'friend', 'صديق', 'She is my best friend.'),
    ],
    quiz: [
      _q('a1_be_1', Skill.grammar, Cefr.a1, 'I ___ happy today.', ['is', 'am', 'are'], 1),
      _q('a1_be_2', Skill.grammar, Cefr.a1, 'We ___ in the classroom.', ['are', 'is', 'am'], 0),
      _q('a1_be_3', Skill.grammar, Cefr.a1, 'He ___ not a doctor.', ['are', 'am', 'is'], 2),
      _q('a1_be_4', Skill.grammar, Cefr.a1, '___ you tired?', ['Is', 'Are', 'Am'], 1),
      _q('a1_be_5', Skill.vocabulary, Cefr.a1, '"جاهز" in English is ___.', ['ready', 'tired', 'friend'], 0),
    ],
  ),
  Lesson(
    id: 'a1_present',
    level: Cefr.a1,
    titleAr: 'المضارع البسيط والروتين اليومي',
    titleEn: 'Present simple: daily routine',
    explainAr: [
      'نستخدم المضارع البسيط للعادات والأشياء التي تتكرر: I work every day.',
      'مع he / she / it نضيف s للفعل: she works، he drinks. وأفعال تنتهي بـ o أو ch أو sh نضيف es: goes، watches.',
      'النفي بـ don\'t / doesn\'t والسؤال بـ Do / Does، ويعود الفعل لأصله: She doesn\'t work. Does he drink tea?',
    ],
    examples: [('I wake up at six.', 'أستيقظ في السادسة.'), ('He goes to work by car.', 'يذهب إلى العمل بالسيارة.'), ('Does she like coffee?', 'هل تحب القهوة؟')],
    words: [
      Word('w_wake', 'wake up', 'يستيقظ', 'I wake up early.'),
      Word('w_breakfast', 'breakfast', 'الفطور', 'We have breakfast at seven.'),
      Word('w_usually', 'usually', 'عادةً', 'I usually walk to work.'),
      Word('w_never', 'never', 'أبدًا', 'He never drinks coffee.'),
      Word('w_evening', 'evening', 'المساء', 'We read in the evening.'),
    ],
    quiz: [
      _q('a1_pr_1', Skill.grammar, Cefr.a1, 'She ___ to school every day.', ['go', 'goes', 'going'], 1),
      _q('a1_pr_2', Skill.grammar, Cefr.a1, 'They ___ like fish.', ['doesn\'t', 'don\'t', 'isn\'t'], 1),
      _q('a1_pr_3', Skill.grammar, Cefr.a1, '___ he play football?', ['Do', 'Is', 'Does'], 2),
      _q('a1_pr_4', Skill.grammar, Cefr.a1, 'My father ___ TV in the evening.', ['watchs', 'watches', 'watch'], 1),
      _q('a1_pr_5', Skill.vocabulary, Cefr.a1, '"عادةً" in English is ___.', ['never', 'usually', 'evening'], 1),
    ],
  ),
  Lesson(
    id: 'a1_there',
    level: Cefr.a1,
    titleAr: 'There is / There are والبيت',
    titleEn: 'There is / there are',
    explainAr: [
      'نستخدم There is مع المفرد وThere are مع الجمع لنقول إن شيئًا موجود.',
      'There is a table. There are two chairs.',
      'النفي: There isn\'t / There aren\'t any. والسؤال: Is there…? Are there any…?',
    ],
    examples: [('There is a sofa in the living room.', 'توجد أريكة في غرفة الجلوس.'), ('There are three windows.', 'توجد ثلاث نوافذ.'), ('Is there a bank near here?', 'هل يوجد بنك قريب من هنا؟')],
    words: [
      Word('w_kitchen', 'kitchen', 'مطبخ', 'There is a fridge in the kitchen.'),
      Word('w_window', 'window', 'نافذة', 'Open the window, please.'),
      Word('w_near', 'near', 'قريب من', 'The shop is near my house.'),
      Word('w_chair', 'chair', 'كرسي', 'There are four chairs.'),
      Word('w_floor', 'floor', 'أرضية / طابق', 'I live on the second floor.'),
    ],
    quiz: [
      _q('a1_th_1', Skill.grammar, Cefr.a1, 'There ___ a book on the table.', ['is', 'are', 'be'], 0),
      _q('a1_th_2', Skill.grammar, Cefr.a1, 'There ___ two cats in the garden.', ['is', 'are', 'am'], 1),
      _q('a1_th_3', Skill.grammar, Cefr.a1, '___ there a park near here?', ['Are', 'Is', 'Do'], 1),
      _q('a1_th_4', Skill.grammar, Cefr.a1, 'There aren\'t ___ shops in my street.', ['some', 'a', 'any'], 2),
      _q('a1_th_5', Skill.vocabulary, Cefr.a1, '"نافذة" in English is ___.', ['floor', 'window', 'kitchen'], 1),
    ],
  ),
  Lesson(
    id: 'a1_can',
    level: Cefr.a1,
    titleAr: 'Can و can\'t للقدرة',
    titleEn: 'Can and can\'t',
    explainAr: [
      'نستخدم can لنقول إننا نستطيع فعل شيء، وcan\'t لعدم الاستطاعة.',
      'لا تتغير can مع الضمائر، والفعل بعدها بلا to وبلا s: She can swim (وليس cans أو to swim).',
      'السؤال بتقديم can: Can you drive? Yes, I can. / No, I can\'t.',
    ],
    examples: [('I can speak Arabic and English.', 'أستطيع التحدث بالعربية والإنجليزية.'), ('He can\'t cook.', 'لا يستطيع الطبخ.'), ('Can you help me?', 'هل يمكنك مساعدتي؟')],
    words: [
      Word('w_swim', 'swim', 'يسبح', 'Can you swim?'),
      Word('w_drive', 'drive', 'يقود', 'She can drive a car.'),
      Word('w_cook', 'cook', 'يطبخ', 'My brother can cook rice.'),
      Word('w_help', 'help', 'يساعد', 'Can I help you?'),
      Word('w_well', 'well', 'جيدًا', 'He speaks English well.'),
    ],
    quiz: [
      _q('a1_can_1', Skill.grammar, Cefr.a1, 'She can ___ very fast.', ['runs', 'run', 'to run'], 1),
      _q('a1_can_2', Skill.grammar, Cefr.a1, '___ you speak French?', ['Do', 'Can', 'Are'], 1),
      _q('a1_can_3', Skill.grammar, Cefr.a1, 'I can\'t ___ the piano.', ['play', 'plays', 'playing'], 0),
      _q('a1_can_4', Skill.grammar, Cefr.a1, 'Can he drive? No, he ___.', ['doesn\'t', 'isn\'t', 'can\'t'], 2),
      _q('a1_can_5', Skill.vocabulary, Cefr.a1, '"يطبخ" in English is ___.', ['cook', 'swim', 'drive'], 0),
    ],
  ),
  // ------------------------------------------------------------------- A2
  Lesson(
    id: 'a2_past',
    level: Cefr.a2,
    titleAr: 'الماضي البسيط',
    titleEn: 'Past simple',
    explainAr: [
      'نستخدم الماضي البسيط لأحداث انتهت في وقت محدد: yesterday، last week، in 2020.',
      'الأفعال المنتظمة نضيف لها ed: work ← worked، visit ← visited. والشاذة لها صيغ خاصة نحفظها: go ← went، see ← saw، have ← had.',
      'النفي والسؤال بـ did / didn\'t مع الفعل في أصله: I didn\'t go. Did you see it?',
    ],
    examples: [('We visited Madinah last year.', 'زرنا المدينة العام الماضي.'), ('She didn\'t come yesterday.', 'لم تأتِ أمس.'), ('Did you buy the tickets?', 'هل اشتريت التذاكر؟')],
    words: [
      Word('w_yesterday', 'yesterday', 'أمس', 'I saw him yesterday.'),
      Word('w_trip', 'trip', 'رحلة', 'The trip was fun.'),
      Word('w_bought', 'bought', 'اشترى (ماضي buy)', 'She bought a new bag.'),
      Word('w_arrive', 'arrive', 'يصل', 'We arrived at noon.'),
      Word('w_ago', 'ago', 'مضى / منذ', 'He left two hours ago.'),
    ],
    quiz: [
      _q('a2_pa_1', Skill.grammar, Cefr.a2, 'I ___ my grandmother last Friday.', ['visit', 'visited', 'visits'], 1),
      _q('a2_pa_2', Skill.grammar, Cefr.a2, 'They ___ to Dubai in 2023.', ['go', 'goed', 'went'], 2),
      _q('a2_pa_3', Skill.grammar, Cefr.a2, 'She didn\'t ___ the email.', ['saw', 'see', 'seen'], 1),
      _q('a2_pa_4', Skill.grammar, Cefr.a2, '___ you finish your homework?', ['Did', 'Do', 'Were'], 0),
      _q('a2_pa_5', Skill.vocabulary, Cefr.a2, '"أمس" in English is ___.', ['ago', 'yesterday', 'trip'], 1),
    ],
  ),
  Lesson(
    id: 'a2_compare',
    level: Cefr.a2,
    titleAr: 'المقارنة والتفضيل',
    titleEn: 'Comparatives and superlatives',
    explainAr: [
      'للمقارنة بين شيئين: الصفات القصيرة نضيف لها er + than: tall ← taller than. والطويلة نسبقها بـ more: more expensive than.',
      'للتفضيل بين أكثر من اثنين: the + est أو the most: the tallest، the most expensive.',
      'صيغ شاذة: good ← better ← the best، bad ← worse ← the worst.',
    ],
    examples: [('Riyadh is bigger than Abha.', 'الرياض أكبر من أبها.'), ('This is the most interesting book.', 'هذا أمتع كتاب.'), ('Her English is better than mine.', 'إنجليزيتها أفضل من إنجليزيتي.')],
    words: [
      Word('w_expensive', 'expensive', 'غالٍ', 'This car is expensive.'),
      Word('w_cheap', 'cheap', 'رخيص', 'The bus is cheaper than a taxi.'),
      Word('w_crowded', 'crowded', 'مزدحم', 'The market is crowded.'),
      Word('w_quiet', 'quiet', 'هادئ', 'The library is quiet.'),
      Word('w_comfortable', 'comfortable', 'مريح', 'This chair is more comfortable.'),
    ],
    quiz: [
      _q('a2_cm_1', Skill.grammar, Cefr.a2, 'My brother is ___ than me.', ['tall', 'taller', 'tallest'], 1),
      _q('a2_cm_2', Skill.grammar, Cefr.a2, 'This is the ___ hotel in the city.', ['more expensive', 'expensivest', 'most expensive'], 2),
      _q('a2_cm_3', Skill.grammar, Cefr.a2, 'Today is ___ than yesterday.', ['better', 'gooder', 'best'], 0),
      _q('a2_cm_4', Skill.grammar, Cefr.a2, 'It was the ___ day of my life.', ['worse', 'worst', 'baddest'], 1),
      _q('a2_cm_5', Skill.vocabulary, Cefr.a2, '"مزدحم" in English is ___.', ['quiet', 'crowded', 'cheap'], 1),
    ],
  ),
  Lesson(
    id: 'a2_future',
    level: Cefr.a2,
    titleAr: 'المستقبل: going to و will',
    titleEn: 'Future: going to and will',
    explainAr: [
      'going to للخطط التي قررناها مسبقًا: I\'m going to study medicine.',
      'will للقرارات الفورية والتوقعات والوعود: It\'s cold — I\'ll close the window. I think it will rain.',
      'النفي: I\'m not going to…، I won\'t (will not)…',
    ],
    examples: [('We are going to travel next month.', 'سنسافر الشهر القادم (خطة).'), ('I\'ll call you later.', 'سأتصل بك لاحقًا.'), ('She won\'t be late.', 'لن تتأخر.')],
    words: [
      Word('w_plan', 'plan', 'خطة / يخطط', 'What are your plans for the weekend?'),
      Word('w_promise', 'promise', 'يعد / وعد', 'I promise I\'ll help.'),
      Word('w_tomorrow', 'tomorrow', 'غدًا', 'See you tomorrow.'),
      Word('w_probably', 'probably', 'على الأرجح', 'It will probably rain.'),
      Word('w_decide', 'decide', 'يقرر', 'She decided to stay.'),
    ],
    quiz: [
      _q('a2_fu_1', Skill.grammar, Cefr.a2, 'Look at the clouds! It ___ rain.', ['is going to', 'goes to', 'will to'], 0),
      _q('a2_fu_2', Skill.grammar, Cefr.a2, 'The phone is ringing. I ___ answer it.', ['am going', 'will', 'going to'], 1),
      _q('a2_fu_3', Skill.grammar, Cefr.a2, 'We ___ visit Taif next summer. We booked a hotel.', ['will', 'are going to', 'go to'], 1),
      _q('a2_fu_4', Skill.grammar, Cefr.a2, 'I promise I ___ tell anyone.', ['won\'t', 'don\'t', 'am not'], 0),
      _q('a2_fu_5', Skill.vocabulary, Cefr.a2, '"على الأرجح" in English is ___.', ['probably', 'tomorrow', 'promise'], 0),
    ],
  ),
  Lesson(
    id: 'a2_quantity',
    level: Cefr.a2,
    titleAr: 'المعدود وغير المعدود: some / any / much / many',
    titleEn: 'Countable and uncountable nouns',
    explainAr: [
      'المعدود له جمع (apples، books)، وغير المعدود لا يُجمع عادة (water، rice، information).',
      'some في الإثبات، وany في النفي والسؤال: I have some rice. Do you have any eggs?',
      'many مع المعدود وmuch مع غير المعدود: How many books? How much water?',
    ],
    examples: [('There is some milk in the fridge.', 'يوجد بعض الحليب في الثلاجة.'), ('We don\'t have any bread.', 'ليس لدينا أي خبز.'), ('How much time do we have?', 'كم لدينا من الوقت؟')],
    words: [
      Word('w_information', 'information', 'معلومات', 'I need more information.'),
      Word('w_advice', 'advice', 'نصيحة', 'Can you give me some advice?'),
      Word('w_luggage', 'luggage', 'أمتعة', 'How much luggage do you have?'),
      Word('w_enough', 'enough', 'كافٍ', 'We have enough chairs.'),
      Word('w_few', 'a few', 'قليل (معدود)', 'I have a few questions.'),
    ],
    quiz: [
      _q('a2_qt_1', Skill.grammar, Cefr.a2, 'How ___ apples do you want?', ['much', 'many', 'any'], 1),
      _q('a2_qt_2', Skill.grammar, Cefr.a2, 'Is there ___ sugar in my tea?', ['many', 'any', 'a'], 1),
      _q('a2_qt_3', Skill.grammar, Cefr.a2, 'How ___ money did it cost?', ['many', 'much', 'few'], 1),
      _q('a2_qt_4', Skill.grammar, Cefr.a2, 'She gave me some good ___.', ['advices', 'advice', 'an advice'], 1),
      _q('a2_qt_5', Skill.vocabulary, Cefr.a2, '"أمتعة" in English is ___.', ['luggage', 'enough', 'information'], 0),
    ],
  ),
  // ------------------------------------------------------------------- B1
  Lesson(
    id: 'b1_perfect',
    level: Cefr.b1,
    titleAr: 'المضارع التام مقابل الماضي البسيط',
    titleEn: 'Present perfect vs past simple',
    explainAr: [
      'المضارع التام (have / has + التصريف الثالث) يربط الماضي بالحاضر: تجربة دون وقت محدد، أو أمر بدأ ولا يزال مستمرًا، أو نتيجة حاضرة.',
      'I have visited London (تجربة). She has lived here since 2019 / for five years (مستمر).',
      'إذا ذكرنا وقتًا منتهيًا (yesterday، in 2019، last week) نستخدم الماضي البسيط: I visited London in 2019.',
    ],
    examples: [('Have you ever eaten sushi?', 'هل سبق أن أكلت السوشي؟'), ('I\'ve just finished the report.', 'أنهيت التقرير للتو.'), ('We met in 2018.', 'التقينا في 2018.')],
    words: [
      Word('w_already', 'already', 'بالفعل / سابقًا', 'I\'ve already eaten.'),
      Word('w_yet', 'yet', 'بعد (في النفي والسؤال)', 'Have you finished yet?'),
      Word('w_since', 'since', 'منذ (نقطة زمنية)', 'I\'ve known her since 2015.'),
      Word('w_experience', 'experience', 'خبرة / تجربة', 'It was a great experience.'),
      Word('w_achieve', 'achieve', 'يحقق', 'She has achieved a lot.'),
    ],
    quiz: [
      _q('b1_pf_1', Skill.grammar, Cefr.b1, 'I ___ this film three times.', ['saw', 'have seen', 'see'], 1),
      _q('b1_pf_2', Skill.grammar, Cefr.b1, 'She ___ to Cairo last month.', ['has gone', 'went', 'has been'], 1),
      _q('b1_pf_3', Skill.grammar, Cefr.b1, 'They have worked here ___ ten years.', ['since', 'for', 'ago'], 1),
      _q('b1_pf_4', Skill.grammar, Cefr.b1, 'Have you finished your homework ___?', ['already', 'yet', 'since'], 1),
      _q('b1_pf_5', Skill.vocabulary, Cefr.b1, '"يحقق" in English is ___.', ['achieve', 'experience', 'already'], 0),
    ],
  ),
  Lesson(
    id: 'b1_conditional',
    level: Cefr.b1,
    titleAr: 'الجمل الشرطية الأولى والثانية',
    titleEn: 'First and second conditionals',
    explainAr: [
      'الشرطية الأولى لاحتمال حقيقي في المستقبل: If + مضارع بسيط، will + فعل: If it rains, we will stay home.',
      'الشرطية الثانية لموقف خيالي أو بعيد الاحتمال الآن: If + ماضٍ بسيط، would + فعل: If I had more time, I would learn Japanese.',
      'في الثانية نقول عادةً If I were (حتى مع I وhe): If I were you, I would accept.',
    ],
    examples: [('If you study, you will pass.', 'إذا ذاكرت ستنجح.'), ('If I won the lottery, I would travel.', 'لو ربحت اليانصيب لسافرت.'), ('If I were you, I\'d call her.', 'لو كنت مكانك لاتصلت بها.')],
    words: [
      Word('w_unless', 'unless', 'إلا إذا', 'You won\'t pass unless you study.'),
      Word('w_afford', 'afford', 'يستطيع تحمّل التكلفة', 'I can\'t afford a new car.'),
      Word('w_opportunity', 'opportunity', 'فرصة', 'This is a great opportunity.'),
      Word('w_accept', 'accept', 'يقبل', 'She accepted the job offer.'),
      Word('w_situation', 'situation', 'موقف / وضع', 'It\'s a difficult situation.'),
    ],
    quiz: [
      _q('b1_cd_1', Skill.grammar, Cefr.b1, 'If you don\'t hurry, you ___ the train.', ['miss', 'will miss', 'would miss'], 1),
      _q('b1_cd_2', Skill.grammar, Cefr.b1, 'If she calls, I ___ you.', ['would tell', 'will tell', 'told'], 1),
      _q('b1_cd_3', Skill.grammar, Cefr.b1, 'If I ___ rich, I would buy a house by the sea.', ['am', 'were', 'will be'], 1),
      _q('b1_cd_4', Skill.grammar, Cefr.b1, 'We would go out if it ___ so hot.', ['isn\'t', 'won\'t be', 'weren\'t'], 2),
      _q('b1_cd_5', Skill.vocabulary, Cefr.b1, '"فرصة" in English is ___.', ['situation', 'opportunity', 'unless'], 1),
    ],
  ),
  Lesson(
    id: 'b1_passive',
    level: Cefr.b1,
    titleAr: 'المبني للمجهول',
    titleEn: 'The passive voice',
    explainAr: [
      'نستخدم المبني للمجهول عندما يهمنا الحدث أو الشيء أكثر من الفاعل: The bridge was built in 1990.',
      'التركيب: be (بالزمن المناسب) + التصريف الثالث. المضارع: is made، والماضي: was made.',
      'لذكر الفاعل نستخدم by: The book was written by Naguib Mahfouz.',
    ],
    examples: [('English is spoken in many countries.', 'تُتحدث الإنجليزية في دول كثيرة.'), ('The museum was opened in 2010.', 'افتُتح المتحف في 2010.'), ('The emails are checked every morning.', 'تُراجع الرسائل كل صباح.')],
    words: [
      Word('w_build', 'built', 'بُني (تصريف build)', 'The tower was built last year.'),
      Word('w_produce', 'produce', 'ينتج', 'Dates are produced in Al-Ahsa.'),
      Word('w_invent', 'invent', 'يخترع', 'The telephone was invented in 1876.'),
      Word('w_damage', 'damage', 'يتلف / ضرر', 'The car was damaged in the storm.'),
      Word('w_deliver', 'deliver', 'يوصّل', 'The parcel was delivered today.'),
    ],
    quiz: [
      _q('b1_ps_1', Skill.grammar, Cefr.b1, 'This car ___ in Japan.', ['made', 'is made', 'is make'], 1),
      _q('b1_ps_2', Skill.grammar, Cefr.b1, 'The letter ___ yesterday.', ['was sent', 'is sent', 'sent'], 0),
      _q('b1_ps_3', Skill.grammar, Cefr.b1, 'The house was designed ___ a famous architect.', ['from', 'by', 'with'], 1),
      _q('b1_ps_4', Skill.grammar, Cefr.b1, 'Rice ___ in many Asian countries.', ['grows', 'is grown', 'is grow'], 1),
      _q('b1_ps_5', Skill.vocabulary, Cefr.b1, '"يخترع" in English is ___.', ['invent', 'deliver', 'produce'], 0),
    ],
  ),
  Lesson(
    id: 'b1_relative',
    level: Cefr.b1,
    titleAr: 'جمل الصلة: who / which / that / where',
    titleEn: 'Relative clauses',
    explainAr: [
      'نستخدم جمل الصلة لنصف الاسم دون بدء جملة جديدة.',
      'who للأشخاص، وwhich للأشياء، وthat للاثنين في الجمل المحددة، وwhere للأماكن.',
      'The man who lives next door is a pilot. The phone which/that I bought is great. This is the café where we met.',
    ],
    examples: [('She\'s the teacher who helped me.', 'هي المعلمة التي ساعدتني.'), ('I lost the keys that you gave me.', 'أضعت المفاتيح التي أعطيتني إياها.'), ('That\'s the hospital where I was born.', 'هذا المستشفى الذي وُلدت فيه.')],
    words: [
      Word('w_neighbour', 'neighbour', 'جار', 'My neighbour is very friendly.'),
      Word('w_colleague', 'colleague', 'زميل عمل', 'A colleague helped me.'),
      Word('w_describe', 'describe', 'يصف', 'Can you describe the man?'),
      Word('w_recommend', 'recommend', 'يوصي بـ', 'Can you recommend a restaurant?'),
      Word('w_borrow', 'borrow', 'يستعير', 'Can I borrow your pen?'),
    ],
    quiz: [
      _q('b1_rl_1', Skill.grammar, Cefr.b1, 'The woman ___ called you is my aunt.', ['which', 'who', 'where'], 1),
      _q('b1_rl_2', Skill.grammar, Cefr.b1, 'This is the book ___ I told you about.', ['who', 'where', 'that'], 2),
      _q('b1_rl_3', Skill.grammar, Cefr.b1, 'That\'s the restaurant ___ we had dinner.', ['where', 'which', 'who'], 0),
      _q('b1_rl_4', Skill.grammar, Cefr.b1, 'I like films ___ make me laugh.', ['who', 'which', 'where'], 1),
      _q('b1_rl_5', Skill.vocabulary, Cefr.b1, '"زميل عمل" in English is ___.', ['neighbour', 'colleague', 'borrow'], 1),
    ],
  ),
  // ------------------------------------------------------------------- B2
  Lesson(
    id: 'b2_third',
    level: Cefr.b2,
    titleAr: 'الشرطية الثالثة وwish',
    titleEn: 'Third conditional and wishes',
    explainAr: [
      'الشرطية الثالثة لماضٍ لم يحدث ونتيجته المتخيلة: If + had + التصريف الثالث، would have + التصريف الثالث.',
      'If I had left earlier, I wouldn\'t have missed the flight. (لكني لم أغادر مبكرًا ففاتتني الرحلة).',
      'wish + ماضٍ بسيط لأمنية عن الحاضر: I wish I had more time. وwish + had + تصريف ثالث لندم على الماضي: I wish I had studied harder.',
    ],
    examples: [('If she had asked, I would have helped.', 'لو طلبت لساعدتها.'), ('I wish I lived closer to work.', 'أتمنى لو كنت أسكن أقرب إلى العمل.'), ('He wishes he hadn\'t said that.', 'يتمنى لو لم يقل ذلك.')],
    words: [
      Word('w_regret', 'regret', 'يندم / ندم', 'I regret not studying more.'),
      Word('w_miss', 'miss', 'يفوّت', 'We missed the bus.'),
      Word('w_otherwise', 'otherwise', 'وإلا', 'Hurry, otherwise we\'ll be late.'),
      Word('w_consequence', 'consequence', 'عاقبة / نتيجة', 'Every choice has consequences.'),
      Word('w_avoid', 'avoid', 'يتجنب', 'We could have avoided the problem.'),
    ],
    quiz: [
      _q('b2_tc_1', Skill.grammar, Cefr.b2, 'If we had taken a taxi, we ___ on time.', ['would arrive', 'would have arrived', 'had arrived'], 1),
      _q('b2_tc_2', Skill.grammar, Cefr.b2, 'If he ___ harder, he would have passed.', ['studied', 'had studied', 'would study'], 1),
      _q('b2_tc_3', Skill.grammar, Cefr.b2, 'I wish I ___ speak Spanish. (now)', ['can', 'could', 'could have'], 1),
      _q('b2_tc_4', Skill.grammar, Cefr.b2, 'She wishes she ___ the job offer last year.', ['accepted', 'had accepted', 'would accept'], 1),
      _q('b2_tc_5', Skill.vocabulary, Cefr.b2, '"يتجنب" in English is ___.', ['avoid', 'regret', 'miss'], 0),
    ],
  ),
  Lesson(
    id: 'b2_reported',
    level: Cefr.b2,
    titleAr: 'الكلام المنقول',
    titleEn: 'Reported speech',
    explainAr: [
      'عند نقل كلام شخص بعد said أو told غالبًا نرجع الزمن خطوة للوراء: "I am tired" ← She said (that) she was tired.',
      'will ← would، can ← could، والماضي البسيط ← الماضي التام: "I saw it" ← He said he had seen it.',
      'الأسئلة المنقولة بترتيب الجملة الخبرية: "Where do you live?" ← She asked where I lived. والأوامر بـ told + to: He told me to wait.',
    ],
    examples: [('He said he would call later.', 'قال إنه سيتصل لاحقًا.'), ('She told me she had finished.', 'أخبرتني أنها انتهت.'), ('They asked if I was ready.', 'سألوا إن كنت جاهزًا.')],
    words: [
      Word('w_mention', 'mention', 'يذكر', 'He mentioned a new project.'),
      Word('w_claim', 'claim', 'يدّعي', 'She claimed she was innocent.'),
      Word('w_admit', 'admit', 'يعترف', 'He admitted his mistake.'),
      Word('w_explain', 'explain', 'يشرح', 'Can you explain the rule?'),
      Word('w_insist', 'insist', 'يُصرّ', 'They insisted on paying.'),
    ],
    quiz: [
      _q('b2_rp_1', Skill.grammar, Cefr.b2, '"I am busy." → He said he ___ busy.', ['is', 'was', 'has been'], 1),
      _q('b2_rp_2', Skill.grammar, Cefr.b2, '"I will help you." → She said she ___ help me.', ['will', 'would', 'can'], 1),
      _q('b2_rp_3', Skill.grammar, Cefr.b2, '"Where is the station?" → He asked where the station ___.', ['is it', 'was', 'was it'], 1),
      _q('b2_rp_4', Skill.grammar, Cefr.b2, '"Close the door." → She told me ___ the door.', ['close', 'to close', 'closing'], 1),
      _q('b2_rp_5', Skill.vocabulary, Cefr.b2, '"يعترف" in English is ___.', ['claim', 'admit', 'insist'], 1),
    ],
  ),
  Lesson(
    id: 'b2_deduction',
    level: Cefr.b2,
    titleAr: 'أفعال الاستنتاج: must / might / can\'t',
    titleEn: 'Modals of deduction',
    explainAr: [
      'نستخدمها لنقول مدى تأكدنا من شيء. must = متأكد أنه صحيح، might / may / could = ممكن، can\'t = متأكد أنه غير صحيح.',
      'عن الحاضر: She must be at home (أنوارها مضاءة). It can\'t be true.',
      'عن الماضي نضيف have + التصريف الثالث: He must have forgotten. They might have left already. She can\'t have seen us.',
    ],
    examples: [('You must be tired after the trip.', 'لا بد أنك متعب بعد الرحلة.'), ('He might be in a meeting.', 'ربما هو في اجتماع.'), ('They can\'t have finished so quickly.', 'لا يمكن أنهم انتهوا بهذه السرعة.')],
    words: [
      Word('w_evidence', 'evidence', 'دليل', 'There is no evidence.'),
      Word('w_obviously', 'obviously', 'بوضوح', 'He was obviously upset.'),
      Word('w_certain', 'certain', 'متأكد', 'I\'m not certain.'),
      Word('w_assume', 'assume', 'يفترض', 'I assume you know her.'),
      Word('w_likely', 'likely', 'مرجّح', 'It\'s likely to rain.'),
    ],
    quiz: [
      _q('b2_dd_1', Skill.grammar, Cefr.b2, 'She hasn\'t eaten all day. She ___ be hungry.', ['can\'t', 'must', 'might not'], 1),
      _q('b2_dd_2', Skill.grammar, Cefr.b2, 'That ___ be Ali — he\'s in London this week.', ['must', 'can\'t', 'might'], 1),
      _q('b2_dd_3', Skill.grammar, Cefr.b2, 'The door is open. Someone ___ forgotten to lock it.', ['must have', 'can\'t have', 'must'], 0),
      _q('b2_dd_4', Skill.grammar, Cefr.b2, 'I\'m not sure where he is. He ___ be at the gym.', ['must', 'can\'t', 'might'], 2),
      _q('b2_dd_5', Skill.vocabulary, Cefr.b2, '"دليل" in English is ___.', ['evidence', 'certain', 'likely'], 0),
    ],
  ),
  Lesson(
    id: 'b2_linking',
    level: Cefr.b2,
    titleAr: 'أدوات الربط: although / despite / however / therefore',
    titleEn: 'Linking words',
    explainAr: [
      'although وeven though تليهما جملة كاملة: Although it was late, we kept working.',
      'despite وin spite of يليهما اسم أو فعل بـ ing: Despite the rain, we went out. Despite feeling tired, she finished.',
      'however للتناقض بين جملتين (بعد نقطة أو فاصلة منقوطة)، وtherefore للنتيجة: It was expensive; however, it was worth it. He was ill; therefore, he stayed home.',
    ],
    examples: [('Although he is young, he is very wise.', 'رغم أنه صغير، فهو حكيم جدًا.'), ('Despite the traffic, we arrived on time.', 'رغم الزحام وصلنا في الوقت.'), ('Prices rose; therefore, sales fell.', 'ارتفعت الأسعار، لذلك انخفضت المبيعات.')],
    words: [
      Word('w_despite', 'despite', 'على الرغم من', 'Despite the cold, they swam.'),
      Word('w_therefore', 'therefore', 'لذلك', 'It rained; therefore, the match was cancelled.'),
      Word('w_moreover', 'moreover', 'علاوة على ذلك', 'It\'s cheap; moreover, it\'s fast.'),
      Word('w_whereas', 'whereas', 'بينما', 'He likes tea, whereas she likes coffee.'),
      Word('w_overall', 'overall', 'إجمالًا', 'Overall, it was a good year.'),
    ],
    quiz: [
      _q('b2_lk_1', Skill.grammar, Cefr.b2, '___ the bad weather, the flight left on time.', ['Although', 'Despite', 'However'], 1),
      _q('b2_lk_2', Skill.grammar, Cefr.b2, '___ she was tired, she helped us.', ['Despite', 'Although', 'Therefore'], 1),
      _q('b2_lk_3', Skill.grammar, Cefr.b2, 'The test was hard; ___, most students passed.', ['however', 'although', 'despite'], 0),
      _q('b2_lk_4', Skill.grammar, Cefr.b2, 'He missed the bus; ___, he was late.', ['whereas', 'therefore', 'despite'], 1),
      _q('b2_lk_5', Skill.vocabulary, Cefr.b2, '"بينما" (للمقابلة) in English is ___.', ['whereas', 'moreover', 'overall'], 0),
    ],
  ),
];
