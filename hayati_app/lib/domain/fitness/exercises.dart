import '../../data/models/fitness.dart';

/// Movement patterns used to build balanced days.
enum Pattern { squat, hinge, lunge, glute, calf, pushH, pushV, pullH, pullV, biceps, triceps, core, cardio, mobility }

/// Muscle group shown to the user.
enum Muscle { chest, back, legs, glutes, shoulders, arms, core, fullBody, cardio, mobility }

/// A gym-only machine or barbell: never available at home.
const _gym = {'gym'};

class Exercise {
  const Exercise({
    required this.id,
    required this.ar,
    required this.en,
    required this.pattern,
    required this.muscle,
    required this.difficulty,
    this.equipment = const {},
    this.gymOnly = const {},
    this.timed = false,
    required this.stepsAr,
    required this.stepsEn,
    required this.tipAr,
    required this.tipEn,
    this.alternatives = const [],
  });

  final String id;
  final String ar;
  final String en;
  final Pattern pattern;
  final Muscle muscle;

  /// 1 = easy … 3 = hard.
  final int difficulty;

  /// Home equipment needed (all of it). Empty = body weight.
  final Set<Equipment> equipment;

  /// Non-empty for gym machines, barbells and cables.
  final Set<String> gymOnly;

  /// Held or done for time instead of counted reps.
  final bool timed;
  final List<String> stepsAr;
  final List<String> stepsEn;

  /// Safety cue.
  final String tipAr;
  final String tipEn;

  /// Similar exercises, closest first.
  final List<String> alternatives;

  bool availableAt(WorkoutPlace place, Set<Equipment> home) =>
      place == WorkoutPlace.gym || (gymOnly.isEmpty && home.containsAll(equipment));

  String name(String lang) => lang == 'ar' ? ar : en;
  List<String> steps(String lang) => lang == 'ar' ? stepsAr : stepsEn;
  String tip(String lang) => lang == 'ar' ? tipAr : tipEn;
}

Exercise? exerciseById(String id) => exercises.where((e) => e.id == id).firstOrNull;

const exercises = <Exercise>[
  // ------------------------------------------------------------- legs
  Exercise(
    id: 'bw_squat', ar: 'سكوات بوزن الجسم', en: 'Bodyweight squat', pattern: Pattern.squat, muscle: Muscle.legs, difficulty: 1,
    stepsAr: ['قف والقدمان بعرض الكتفين.', 'انزل بالورك للخلف والأسفل كأنك تجلس على كرسي.', 'ادفع الأرض بقدميك لتعود واقفًا.'],
    stepsEn: ['Stand with feet shoulder-width apart.', 'Sit your hips back and down as if onto a chair.', 'Push through your feet to stand up.'],
    tipAr: 'أبقِ الركبتين في اتجاه أصابع القدم والظهر مستقيمًا.', tipEn: 'Keep knees in line with toes and your back straight.',
    alternatives: ['goblet_squat', 'leg_press', 'step_up'],
  ),
  Exercise(
    id: 'goblet_squat', ar: 'سكوات بالدمبل (جوبلت)', en: 'Goblet squat', pattern: Pattern.squat, muscle: Muscle.legs, difficulty: 2,
    equipment: {Equipment.dumbbells},
    stepsAr: ['أمسك دمبل عموديًا أمام صدرك.', 'انزل بالورك حتى يصبح الفخذ موازيًا للأرض أو أقل براحة.', 'اصعد مع إبقاء الصدر مرفوعًا.'],
    stepsEn: ['Hold a dumbbell upright at your chest.', 'Squat until thighs are about parallel, or as low as is comfortable.', 'Stand up keeping your chest tall.'],
    tipAr: 'ابدأ بوزن خفيف وزد تدريجيًا.', tipEn: 'Start light and add weight gradually.',
    alternatives: ['bw_squat', 'barbell_squat', 'leg_press'],
  ),
  Exercise(
    id: 'barbell_squat', ar: 'سكوات بالبار', en: 'Barbell back squat', pattern: Pattern.squat, muscle: Muscle.legs, difficulty: 3,
    gymOnly: _gym,
    stepsAr: ['ضع البار على أعلى الظهر داخل القفص.', 'انزل بثبات مع شد البطن.', 'اصعد بدفع الأرض.'],
    stepsEn: ['Set the bar on your upper back in a rack.', 'Squat down under control, core braced.', 'Drive up through your feet.'],
    tipAr: 'استخدم مساند الأمان، واطلب مساعدة إن كانت أول مرة.', tipEn: 'Use the safety pins, and ask for coaching the first time.',
    alternatives: ['goblet_squat', 'leg_press', 'bw_squat'],
  ),
  Exercise(
    id: 'leg_press', ar: 'جهاز دفع الأرجل', en: 'Leg press', pattern: Pattern.squat, muscle: Muscle.legs, difficulty: 1,
    gymOnly: _gym,
    stepsAr: ['اجلس وضع قدميك بعرض الكتفين على اللوح.', 'اثنِ الركبتين ببطء.', 'ادفع دون قفل الركبتين في الأعلى.'],
    stepsEn: ['Sit and place feet shoulder-width on the platform.', 'Lower by bending your knees slowly.', 'Press back up without locking your knees.'],
    tipAr: 'أبقِ أسفل الظهر ملاصقًا للمسند.', tipEn: 'Keep your lower back against the pad.',
    alternatives: ['goblet_squat', 'bw_squat'],
  ),
  Exercise(
    id: 'reverse_lunge', ar: 'طعن للخلف', en: 'Reverse lunge', pattern: Pattern.lunge, muscle: Muscle.legs, difficulty: 1,
    stepsAr: ['قف معتدلًا.', 'ارجع بقدم خطوة للخلف وانزل حتى تقترب الركبة من الأرض.', 'عد للوقوف وبدّل الرجل.'],
    stepsEn: ['Stand tall.', 'Step one foot back and lower until the back knee nears the floor.', 'Return and switch legs.'],
    tipAr: 'اجعل الخطوة طويلة بما يكفي لتبقى الركبة الأمامية فوق القدم.', tipEn: 'Step far enough that your front knee stays over your foot.',
    alternatives: ['step_up', 'split_squat', 'bw_squat'],
  ),
  Exercise(
    id: 'split_squat', ar: 'سكوات بلغاري', en: 'Bulgarian split squat', pattern: Pattern.lunge, muscle: Muscle.legs, difficulty: 2,
    stepsAr: ['ضع ظهر قدمك الخلفية على كرسي ثابت.', 'انزل بالرجل الأمامية بثبات.', 'اصعد وأكمل العدد ثم بدّل.'],
    stepsEn: ['Rest the top of your back foot on a sturdy chair.', 'Lower on your front leg under control.', 'Rise, finish the reps, then switch.'],
    tipAr: 'استخدم كرسيًا لا ينزلق، وتمسك بجدار إن احتجت للتوازن.', tipEn: 'Use a chair that won\'t slide; hold a wall for balance if needed.',
    alternatives: ['reverse_lunge', 'step_up'],
  ),
  Exercise(
    id: 'step_up', ar: 'صعود على درجة', en: 'Step-up', pattern: Pattern.lunge, muscle: Muscle.legs, difficulty: 1,
    stepsAr: ['قف أمام درجة أو صندوق ثابت.', 'اصعد بقدم واحدة ودفعها حتى تقف عليها.', 'انزل ببطء وبدّل.'],
    stepsEn: ['Face a sturdy step or box.', 'Step up with one foot and stand on it.', 'Step down slowly and switch.'],
    tipAr: 'اختر ارتفاعًا يسمح بإبقاء الركبة مستقرة.', tipEn: 'Choose a height that keeps your knee stable.',
    alternatives: ['reverse_lunge', 'bw_squat'],
  ),
  Exercise(
    id: 'glute_bridge', ar: 'جسر الأرداف', en: 'Glute bridge', pattern: Pattern.glute, muscle: Muscle.glutes, difficulty: 1,
    stepsAr: ['استلقِ على ظهرك والركبتان مثنيتان.', 'ارفع الورك حتى يستقيم الجسم من الكتف للركبة.', 'انزل ببطء.'],
    stepsEn: ['Lie on your back, knees bent.', 'Lift your hips until shoulders to knees form a line.', 'Lower slowly.'],
    tipAr: 'اضغط الأرداف في الأعلى ولا تقوّس أسفل الظهر.', tipEn: 'Squeeze your glutes at the top; don\'t arch your lower back.',
    alternatives: ['db_rdl', 'kb_swing'],
  ),
  Exercise(
    id: 'db_rdl', ar: 'رفعة رومانية بالدمبل', en: 'Dumbbell Romanian deadlift', pattern: Pattern.hinge, muscle: Muscle.legs, difficulty: 2,
    equipment: {Equipment.dumbbells},
    stepsAr: ['أمسك دمبلين أمام الفخذين.', 'ادفع الورك للخلف وانزل بالأوزان قرب الساقين مع ثني بسيط للركبتين.', 'عد بدفع الورك للأمام.'],
    stepsEn: ['Hold dumbbells in front of your thighs.', 'Push hips back, sliding the weights down your legs, knees soft.', 'Return by driving hips forward.'],
    tipAr: 'أبقِ الظهر مستقيمًا، وتوقف عندما تشعر بشد في خلف الفخذ.', tipEn: 'Keep your back flat; stop when you feel a hamstring stretch.',
    alternatives: ['glute_bridge', 'kb_swing', 'barbell_deadlift'],
  ),
  Exercise(
    id: 'kb_swing', ar: 'أرجحة الكيتلبل', en: 'Kettlebell swing', pattern: Pattern.hinge, muscle: Muscle.glutes, difficulty: 2,
    equipment: {Equipment.kettlebell},
    stepsAr: ['قف والكيتلبل أمامك على الأرض.', 'أرجحه بين الساقين بثني الورك.', 'ادفع الورك بقوة ليرتفع إلى مستوى الصدر.'],
    stepsEn: ['Stand with the kettlebell in front of you.', 'Hike it back between your legs by hinging.', 'Snap your hips forward to swing it to chest height.'],
    tipAr: 'الحركة من الورك لا من الذراعين.', tipEn: 'Power comes from the hips, not the arms.',
    alternatives: ['db_rdl', 'glute_bridge'],
  ),
  Exercise(
    id: 'barbell_deadlift', ar: 'الرفعة الميتة بالبار', en: 'Barbell deadlift', pattern: Pattern.hinge, muscle: Muscle.back, difficulty: 3,
    gymOnly: _gym,
    stepsAr: ['قف والبار فوق منتصف القدم.', 'امسك البار مع ظهر مستقيم وشد البطن.', 'ارفع بدفع الأرض حتى تقف معتدلًا.'],
    stepsEn: ['Stand with the bar over mid-foot.', 'Grip it with a flat back and braced core.', 'Push the floor away until you stand tall.'],
    tipAr: 'تعلّم الأسلوب بوزن خفيف أولًا.', tipEn: 'Learn the technique with a light weight first.',
    alternatives: ['db_rdl', 'kb_swing'],
  ),
  Exercise(
    id: 'leg_curl', ar: 'جهاز ثني الأرجل', en: 'Leg curl machine', pattern: Pattern.hinge, muscle: Muscle.legs, difficulty: 1,
    gymOnly: _gym,
    stepsAr: ['اضبط الجهاز على طولك.', 'اثنِ الركبتين لسحب المسند.', 'عد ببطء.'],
    stepsEn: ['Adjust the machine to your height.', 'Bend your knees to curl the pad.', 'Return slowly.'],
    tipAr: 'تحكّم في النزول ولا تستخدم الاندفاع.', tipEn: 'Control the return; don\'t swing.',
    alternatives: ['glute_bridge', 'db_rdl'],
  ),
  Exercise(
    id: 'calf_raise', ar: 'رفع السمانة', en: 'Calf raise', pattern: Pattern.calf, muscle: Muscle.legs, difficulty: 1,
    stepsAr: ['قف على حافة درجة أو على الأرض.', 'ارتفع على أطراف أصابعك.', 'انزل ببطء.'],
    stepsEn: ['Stand on a step edge or the floor.', 'Rise onto your toes.', 'Lower slowly.'],
    tipAr: 'أمسك بشيء ثابت للتوازن.', tipEn: 'Hold onto something for balance.',
  ),
  // ----------------------------------------------------------- push
  Exercise(
    id: 'incline_pushup', ar: 'ضغط مائل على طاولة', en: 'Incline push-up', pattern: Pattern.pushH, muscle: Muscle.chest, difficulty: 1,
    stepsAr: ['ضع يديك على طاولة أو حافة ثابتة.', 'انزل بالصدر نحوها مع شد الجسم.', 'ادفع للعودة.'],
    stepsEn: ['Hands on a sturdy table or ledge.', 'Lower your chest toward it with a straight body.', 'Push back up.'],
    tipAr: 'كلما ارتفع السطح سهل التمرين.', tipEn: 'The higher the surface, the easier it is.',
    alternatives: ['pushup', 'db_floor_press'],
  ),
  Exercise(
    id: 'pushup', ar: 'ضغط', en: 'Push-up', pattern: Pattern.pushH, muscle: Muscle.chest, difficulty: 2,
    stepsAr: ['ضع يديك أوسع قليلًا من الكتفين.', 'انزل بجسم مستقيم حتى يقترب الصدر من الأرض.', 'ادفع للأعلى.'],
    stepsEn: ['Hands slightly wider than shoulders.', 'Lower with a straight body until your chest nears the floor.', 'Push back up.'],
    tipAr: 'إن صعب عليك، استخدم الضغط المائل.', tipEn: 'If it\'s too hard, use the incline version.',
    alternatives: ['incline_pushup', 'db_bench_press', 'machine_chest_press'],
  ),
  Exercise(
    id: 'db_floor_press', ar: 'ضغط دمبل على الأرض', en: 'Dumbbell floor press', pattern: Pattern.pushH, muscle: Muscle.chest, difficulty: 1,
    equipment: {Equipment.dumbbells},
    stepsAr: ['استلقِ والدمبلان فوق صدرك.', 'انزل حتى يلمس المرفقان الأرض.', 'ادفع للأعلى.'],
    stepsEn: ['Lie down holding dumbbells above your chest.', 'Lower until your elbows touch the floor.', 'Press up.'],
    tipAr: 'أبقِ المرفقين بزاوية مريحة بعيدًا عن الأذنين.', tipEn: 'Keep elbows at a comfortable angle, not flared to the ears.',
    alternatives: ['pushup', 'db_bench_press'],
  ),
  Exercise(
    id: 'db_bench_press', ar: 'ضغط دمبل على بنش', en: 'Dumbbell bench press', pattern: Pattern.pushH, muscle: Muscle.chest, difficulty: 2,
    equipment: {Equipment.dumbbells, Equipment.bench},
    stepsAr: ['استلقِ على البنش والدمبلان عند الصدر.', 'ادفع للأعلى.', 'انزل ببطء.'],
    stepsEn: ['Lie on the bench, dumbbells at chest level.', 'Press up.', 'Lower slowly.'],
    tipAr: 'ثبّت القدمين على الأرض.', tipEn: 'Keep your feet planted.',
    alternatives: ['db_floor_press', 'pushup', 'machine_chest_press'],
  ),
  Exercise(
    id: 'machine_chest_press', ar: 'جهاز ضغط الصدر', en: 'Chest press machine', pattern: Pattern.pushH, muscle: Muscle.chest, difficulty: 1,
    gymOnly: _gym,
    stepsAr: ['اضبط المقعد لتكون المقابض عند منتصف الصدر.', 'ادفع للأمام.', 'عد ببطء.'],
    stepsEn: ['Set the seat so handles are at mid-chest.', 'Press forward.', 'Return slowly.'],
    tipAr: 'لا تقفل المرفقين في النهاية.', tipEn: 'Don\'t lock your elbows at the end.',
    alternatives: ['pushup', 'db_floor_press'],
  ),
  Exercise(
    id: 'pike_pushup', ar: 'ضغط الكتف (بايك)', en: 'Pike push-up', pattern: Pattern.pushV, muscle: Muscle.shoulders, difficulty: 2,
    stepsAr: ['ابدأ بوضع الضغط ثم ارفع الورك للأعلى.', 'انزل بالرأس نحو الأرض بين اليدين.', 'ادفع للعودة.'],
    stepsEn: ['From a push-up position, lift your hips high.', 'Lower your head toward the floor between your hands.', 'Push back up.'],
    tipAr: 'تحكّم في النزول ولا تضغط على الرقبة.', tipEn: 'Lower under control; no pressure on the neck.',
    alternatives: ['band_press', 'db_shoulder_press'],
  ),
  Exercise(
    id: 'band_press', ar: 'ضغط كتف بالمطاط', en: 'Band shoulder press', pattern: Pattern.pushV, muscle: Muscle.shoulders, difficulty: 1,
    equipment: {Equipment.bands},
    stepsAr: ['قف على المطاط وأمسك طرفيه عند الكتفين.', 'ادفع للأعلى فوق الرأس.', 'انزل ببطء.'],
    stepsEn: ['Stand on the band, ends at your shoulders.', 'Press overhead.', 'Lower slowly.'],
    tipAr: 'شدّ البطن ولا تقوّس الظهر.', tipEn: 'Brace your core; don\'t arch your back.',
    alternatives: ['db_shoulder_press', 'pike_pushup'],
  ),
  Exercise(
    id: 'db_shoulder_press', ar: 'ضغط كتف بالدمبل', en: 'Dumbbell shoulder press', pattern: Pattern.pushV, muscle: Muscle.shoulders, difficulty: 2,
    equipment: {Equipment.dumbbells},
    stepsAr: ['اجلس أو قف والدمبلان عند الكتفين.', 'ادفع للأعلى.', 'انزل ببطء.'],
    stepsEn: ['Sit or stand, dumbbells at your shoulders.', 'Press overhead.', 'Lower slowly.'],
    tipAr: 'ابدأ بوزن تستطيع التحكم به كاملًا.', tipEn: 'Start with a weight you fully control.',
    alternatives: ['band_press', 'pike_pushup'],
  ),
  Exercise(
    id: 'chair_dip', ar: 'غطس على كرسي', en: 'Chair dip', pattern: Pattern.triceps, muscle: Muscle.arms, difficulty: 2,
    stepsAr: ['ضع يديك على حافة كرسي ثابت خلفك.', 'انزل بثني المرفقين.', 'ادفع للأعلى.'],
    stepsEn: ['Hands on the edge of a sturdy chair behind you.', 'Lower by bending your elbows.', 'Push back up.'],
    tipAr: 'انزل بمدى مريح للكتف وتوقف عند أي ألم.', tipEn: 'Use a range that\'s comfortable for your shoulders; stop if it hurts.',
    alternatives: ['db_overhead_triceps', 'triceps_pushdown'],
  ),
  Exercise(
    id: 'db_overhead_triceps', ar: 'تراي فوق الرأس بالدمبل', en: 'Overhead dumbbell triceps extension', pattern: Pattern.triceps, muscle: Muscle.arms, difficulty: 1,
    equipment: {Equipment.dumbbells},
    stepsAr: ['أمسك دمبلًا بيديك فوق رأسك.', 'انزل به خلف الرأس بثني المرفقين.', 'مدّ الذراعين.'],
    stepsEn: ['Hold one dumbbell overhead with both hands.', 'Lower it behind your head by bending your elbows.', 'Extend your arms.'],
    tipAr: 'أبقِ المرفقين قريبين من الرأس.', tipEn: 'Keep elbows close to your head.',
    alternatives: ['chair_dip', 'triceps_pushdown'],
  ),
  Exercise(
    id: 'triceps_pushdown', ar: 'تراي على الكيبل', en: 'Cable triceps pushdown', pattern: Pattern.triceps, muscle: Muscle.arms, difficulty: 1,
    gymOnly: _gym,
    stepsAr: ['أمسك المقبض أمام صدرك.', 'ادفع للأسفل حتى تستقيم الذراعان.', 'عد ببطء.'],
    stepsEn: ['Hold the handle at chest level.', 'Push down until your arms are straight.', 'Return slowly.'],
    tipAr: 'ثبّت المرفقين بجانب الجسم.', tipEn: 'Keep elbows pinned to your sides.',
    alternatives: ['db_overhead_triceps', 'chair_dip'],
  ),
  // ----------------------------------------------------------- pull
  Exercise(
    id: 'band_row', ar: 'سحب بالمطاط', en: 'Band row', pattern: Pattern.pullH, muscle: Muscle.back, difficulty: 1,
    equipment: {Equipment.bands},
    stepsAr: ['ثبّت المطاط أمامك أو حول قدميك وأنت جالس.', 'اسحب نحو بطنك مع ضم لوحي الكتف.', 'عد ببطء.'],
    stepsEn: ['Anchor the band in front of you or around your feet while seated.', 'Pull toward your belly, squeezing shoulder blades.', 'Return slowly.'],
    tipAr: 'لا تميل للخلف لتسحب.', tipEn: 'Don\'t lean back to pull.',
    alternatives: ['db_row', 'cable_row'],
  ),
  Exercise(
    id: 'db_row', ar: 'سحب دمبل بيد واحدة', en: 'One-arm dumbbell row', pattern: Pattern.pullH, muscle: Muscle.back, difficulty: 1,
    equipment: {Equipment.dumbbells},
    stepsAr: ['اسند يدًا وركبة على كرسي أو بنش.', 'اسحب الدمبل نحو الورك.', 'انزل ببطء ثم بدّل.'],
    stepsEn: ['Support one hand and knee on a chair or bench.', 'Row the dumbbell toward your hip.', 'Lower slowly, then switch.'],
    tipAr: 'أبقِ الظهر مستقيمًا.', tipEn: 'Keep your back flat.',
    alternatives: ['band_row', 'cable_row'],
  ),
  Exercise(
    id: 'cable_row', ar: 'سحب أرضي على الكيبل', en: 'Seated cable row', pattern: Pattern.pullH, muscle: Muscle.back, difficulty: 1,
    gymOnly: _gym,
    stepsAr: ['اجلس والقدمان على المسند.', 'اسحب المقبض نحو البطن.', 'عد ببطء.'],
    stepsEn: ['Sit with feet on the platform.', 'Pull the handle to your belly.', 'Return slowly.'],
    tipAr: 'حافظ على صدر مرفوع.', tipEn: 'Keep your chest up.',
    alternatives: ['db_row', 'band_row'],
  ),
  Exercise(
    id: 'superman', ar: 'السوبرمان', en: 'Superman', pattern: Pattern.pullH, muscle: Muscle.back, difficulty: 1, timed: true,
    stepsAr: ['استلقِ على بطنك والذراعان ممدودتان.', 'ارفع الذراعين والصدر والساقين قليلًا.', 'اثبت ثم انزل.'],
    stepsEn: ['Lie face down, arms extended.', 'Lift arms, chest and legs slightly.', 'Hold, then lower.'],
    tipAr: 'ارفع قليلًا فقط ولا تضغط على الرقبة.', tipEn: 'Lift only a little; keep your neck relaxed.',
    alternatives: ['band_row', 'db_row'],
  ),
  Exercise(
    id: 'band_pulldown', ar: 'سحب علوي بالمطاط', en: 'Band lat pulldown', pattern: Pattern.pullV, muscle: Muscle.back, difficulty: 1,
    equipment: {Equipment.bands},
    stepsAr: ['ثبّت المطاط في مكان مرتفع.', 'اسحبه نحو أعلى صدرك.', 'عد ببطء.'],
    stepsEn: ['Anchor the band high.', 'Pull it down to your upper chest.', 'Return slowly.'],
    tipAr: 'تأكد من تثبيت المطاط جيدًا.', tipEn: 'Make sure the band is anchored securely.',
    alternatives: ['lat_pulldown', 'pullup'],
  ),
  Exercise(
    id: 'pullup', ar: 'عقلة', en: 'Pull-up', pattern: Pattern.pullV, muscle: Muscle.back, difficulty: 3,
    equipment: {Equipment.pullupBar},
    stepsAr: ['تعلّق بالعقلة واليدان بعرض الكتفين.', 'اسحب جسمك حتى يتجاوز الذقن العقلة.', 'انزل ببطء.'],
    stepsEn: ['Hang with hands shoulder-width apart.', 'Pull until your chin clears the bar.', 'Lower slowly.'],
    tipAr: 'إن لم تستطع بعد، ابدأ بالنزول البطيء فقط.', tipEn: 'If you can\'t yet, start with slow lowering only.',
    alternatives: ['lat_pulldown', 'band_pulldown'],
  ),
  Exercise(
    id: 'lat_pulldown', ar: 'جهاز السحب العلوي', en: 'Lat pulldown', pattern: Pattern.pullV, muscle: Muscle.back, difficulty: 1,
    gymOnly: _gym,
    stepsAr: ['اجلس وثبّت الفخذين تحت المسند.', 'اسحب البار نحو أعلى الصدر.', 'عد ببطء.'],
    stepsEn: ['Sit with thighs under the pad.', 'Pull the bar to your upper chest.', 'Return slowly.'],
    tipAr: 'لا تسحب خلف الرقبة.', tipEn: 'Don\'t pull behind your neck.',
    alternatives: ['band_pulldown', 'pullup'],
  ),
  Exercise(
    id: 'db_curl', ar: 'بايسبس بالدمبل', en: 'Dumbbell curl', pattern: Pattern.biceps, muscle: Muscle.arms, difficulty: 1,
    equipment: {Equipment.dumbbells},
    stepsAr: ['قف والدمبلان بجانبك.', 'اثنِ المرفقين لرفع الأوزان.', 'انزل ببطء.'],
    stepsEn: ['Stand holding dumbbells at your sides.', 'Bend your elbows to curl the weights up.', 'Lower slowly.'],
    tipAr: 'لا تتأرجح بالجسم.', tipEn: 'Don\'t swing your body.',
    alternatives: ['band_curl'],
  ),
  Exercise(
    id: 'band_curl', ar: 'بايسبس بالمطاط', en: 'Band curl', pattern: Pattern.biceps, muscle: Muscle.arms, difficulty: 1,
    equipment: {Equipment.bands},
    stepsAr: ['قف على المطاط وأمسك طرفيه.', 'اثنِ المرفقين.', 'انزل ببطء.'],
    stepsEn: ['Stand on the band holding both ends.', 'Bend your elbows.', 'Lower slowly.'],
    tipAr: 'ثبّت المرفقين بجانب الجسم.', tipEn: 'Keep elbows at your sides.',
    alternatives: ['db_curl'],
  ),
  // ----------------------------------------------------------- core
  Exercise(
    id: 'plank', ar: 'البلانك', en: 'Plank', pattern: Pattern.core, muscle: Muscle.core, difficulty: 1, timed: true,
    stepsAr: ['اسند جسمك على الساعدين وأطراف القدمين.', 'اجعل جسمك خطًا مستقيمًا.', 'اثبت وتنفس بانتظام.'],
    stepsEn: ['Support yourself on forearms and toes.', 'Keep your body in a straight line.', 'Hold and breathe steadily.'],
    tipAr: 'لا ترفع الورك ولا تتركه يهبط.', tipEn: 'Don\'t let your hips rise or sag.',
    alternatives: ['dead_bug', 'bird_dog'],
  ),
  Exercise(
    id: 'side_plank', ar: 'البلانك الجانبي', en: 'Side plank', pattern: Pattern.core, muscle: Muscle.core, difficulty: 2, timed: true,
    stepsAr: ['اسند جسمك على ساعد واحد وجانب القدم.', 'ارفع الورك حتى يستقيم الجسم.', 'اثبت ثم بدّل الجهة.'],
    stepsEn: ['Support yourself on one forearm and the side of your foot.', 'Lift your hips into a straight line.', 'Hold, then switch sides.'],
    tipAr: 'يمكنك إنزال الركبة السفلى لتسهيله.', tipEn: 'Drop the bottom knee to make it easier.',
    alternatives: ['plank', 'dead_bug'],
  ),
  Exercise(
    id: 'dead_bug', ar: 'الحشرة الميتة', en: 'Dead bug', pattern: Pattern.core, muscle: Muscle.core, difficulty: 1,
    stepsAr: ['استلقِ على ظهرك والذراعان للأعلى والركبتان مثنيتان فوق الورك.', 'مدّ ذراعًا والرجل المعاكسة ببطء.', 'عد وبدّل.'],
    stepsEn: ['Lie on your back, arms up, knees bent over hips.', 'Slowly extend one arm and the opposite leg.', 'Return and switch.'],
    tipAr: 'أبقِ أسفل الظهر ملامسًا للأرض.', tipEn: 'Keep your lower back on the floor.',
    alternatives: ['bird_dog', 'plank'],
  ),
  Exercise(
    id: 'bird_dog', ar: 'الطائر والكلب', en: 'Bird dog', pattern: Pattern.core, muscle: Muscle.core, difficulty: 1,
    stepsAr: ['ابدأ على اليدين والركبتين.', 'مدّ ذراعًا والرجل المعاكسة.', 'عد وبدّل.'],
    stepsEn: ['Start on hands and knees.', 'Extend one arm and the opposite leg.', 'Return and switch.'],
    tipAr: 'تحرك ببطء دون أن يميل الورك.', tipEn: 'Move slowly without tilting your hips.',
    alternatives: ['dead_bug', 'plank'],
  ),
  Exercise(
    id: 'hanging_knee_raise', ar: 'رفع الركبتين معلّقًا', en: 'Hanging knee raise', pattern: Pattern.core, muscle: Muscle.core, difficulty: 2,
    equipment: {Equipment.pullupBar},
    stepsAr: ['تعلّق بالعقلة.', 'ارفع الركبتين نحو الصدر.', 'انزل ببطء دون أرجحة.'],
    stepsEn: ['Hang from the bar.', 'Raise your knees toward your chest.', 'Lower slowly without swinging.'],
    tipAr: 'توقف إن شعرت بألم في الكتف.', tipEn: 'Stop if your shoulders hurt.',
    alternatives: ['dead_bug', 'plank'],
  ),
  // ---------------------------------------------------------- cardio
  Exercise(
    id: 'brisk_walk', ar: 'مشي سريع', en: 'Brisk walk', pattern: Pattern.cardio, muscle: Muscle.cardio, difficulty: 1, timed: true,
    stepsAr: ['امشِ بخطى سريعة.', 'حافظ على وتيرة تستطيع معها الكلام بجمل قصيرة.', 'اختم بدقيقتين أبطأ.'],
    stepsEn: ['Walk at a brisk pace.', 'Keep a pace where you can still talk in short sentences.', 'Finish with two easier minutes.'],
    tipAr: 'اشرب ماءً وتجنب الحر الشديد.', tipEn: 'Drink water and avoid extreme heat.',
    alternatives: ['jumping_jacks', 'treadmill'],
  ),
  Exercise(
    id: 'jumping_jacks', ar: 'قفز فتح وضم', en: 'Jumping jacks', pattern: Pattern.cardio, muscle: Muscle.cardio, difficulty: 1, timed: true,
    stepsAr: ['قف والقدمان متلاصقتان.', 'اقفز مع فتح القدمين ورفع الذراعين.', 'عد وكرر بإيقاع ثابت.'],
    stepsEn: ['Stand with feet together.', 'Jump feet out while raising your arms.', 'Return and repeat at a steady rhythm.'],
    tipAr: 'يمكنك الخطو بدل القفز لتخفيف الضغط على الركبتين.', tipEn: 'Step instead of jumping to go easier on your knees.',
    alternatives: ['brisk_walk', 'bike'],
  ),
  Exercise(
    id: 'treadmill', ar: 'سير كهربائي', en: 'Treadmill', pattern: Pattern.cardio, muscle: Muscle.cardio, difficulty: 1, timed: true,
    gymOnly: _gym,
    stepsAr: ['ابدأ بسرعة مشي هادئة.', 'زد السرعة أو الميل تدريجيًا.', 'اختم بتهدئة.'],
    stepsEn: ['Start at an easy walking speed.', 'Raise speed or incline gradually.', 'Finish with a cool-down.'],
    tipAr: 'استخدم مشبك الأمان.', tipEn: 'Use the safety clip.',
    alternatives: ['bike', 'brisk_walk'],
  ),
  Exercise(
    id: 'bike', ar: 'دراجة ثابتة', en: 'Stationary bike', pattern: Pattern.cardio, muscle: Muscle.cardio, difficulty: 1, timed: true,
    gymOnly: _gym,
    stepsAr: ['اضبط ارتفاع المقعد.', 'دوّس بإيقاع مريح.', 'زد المقاومة تدريجيًا.'],
    stepsEn: ['Adjust the seat height.', 'Pedal at a comfortable rhythm.', 'Increase resistance gradually.'],
    tipAr: 'يجب أن تكون الركبة مثنية قليلًا في أسفل الدورة.', tipEn: 'Your knee should stay slightly bent at the bottom.',
    alternatives: ['treadmill', 'jumping_jacks', 'brisk_walk'],
  ),
  // -------------------------------------------------------- mobility
  Exercise(
    id: 'cat_cow', ar: 'القط والبقرة', en: 'Cat-cow', pattern: Pattern.mobility, muscle: Muscle.mobility, difficulty: 1, timed: true,
    stepsAr: ['ابدأ على اليدين والركبتين.', 'قوّس ظهرك للأعلى ثم اخفضه ببطء.', 'نسّق الحركة مع التنفس.'],
    stepsEn: ['Start on hands and knees.', 'Round your back up, then let it dip slowly.', 'Move with your breath.'],
    tipAr: 'تحرك في مدى مريح.', tipEn: 'Stay within a comfortable range.',
  ),
  Exercise(
    id: 'hip_flexor_stretch', ar: 'إطالة مثنيات الورك', en: 'Hip flexor stretch', pattern: Pattern.mobility, muscle: Muscle.mobility, difficulty: 1, timed: true,
    stepsAr: ['انزل على ركبة واحدة والقدم الأخرى أمامك.', 'ادفع الورك للأمام بلطف.', 'اثبت ثم بدّل.'],
    stepsEn: ['Kneel on one knee, other foot in front.', 'Gently push your hips forward.', 'Hold, then switch.'],
    tipAr: 'ضع وسادة تحت الركبة.', tipEn: 'Put a cushion under your knee.',
  ),
  Exercise(
    id: 'thoracic_rotation', ar: 'تدوير أعلى الظهر', en: 'Thoracic rotation', pattern: Pattern.mobility, muscle: Muscle.mobility, difficulty: 1, timed: true,
    stepsAr: ['استلقِ على جنبك والركبتان مثنيتان.', 'افتح الذراع العلوية للخلف مع دوران الصدر.', 'عد وكرر ثم بدّل.'],
    stepsEn: ['Lie on your side, knees bent.', 'Open your top arm back, rotating your chest.', 'Return, repeat, then switch sides.'],
    tipAr: 'أبقِ الركبتين معًا على الأرض.', tipEn: 'Keep your knees together on the floor.',
  ),
  Exercise(
    id: 'hamstring_stretch', ar: 'إطالة خلف الفخذ', en: 'Hamstring stretch', pattern: Pattern.mobility, muscle: Muscle.mobility, difficulty: 1, timed: true,
    stepsAr: ['اجلس ورجل ممدودة أمامك.', 'مِل للأمام من الورك بظهر مستقيم.', 'اثبت ثم بدّل.'],
    stepsEn: ['Sit with one leg straight in front.', 'Lean forward from the hips, back straight.', 'Hold, then switch.'],
    tipAr: 'شد خفيف فقط، دون ألم.', tipEn: 'A gentle stretch only, never pain.',
  ),
  Exercise(
    id: 'childs_pose', ar: 'وضعية الطفل', en: 'Child\'s pose', pattern: Pattern.mobility, muscle: Muscle.mobility, difficulty: 1, timed: true,
    stepsAr: ['اجلس على كعبيك.', 'مِل للأمام ومدّ الذراعين على الأرض.', 'تنفس ببطء.'],
    stepsEn: ['Sit back on your heels.', 'Fold forward, arms stretched on the floor.', 'Breathe slowly.'],
    tipAr: 'باعد الركبتين إن كان ذلك أريح.', tipEn: 'Widen your knees if that\'s more comfortable.',
  ),
];
