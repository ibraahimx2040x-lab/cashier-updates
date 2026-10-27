import '../../data/models/fitness.dart';
import '../../data/models/health.dart';
import '../../data/models/settings.dart';

/// Who a program is for. Women's and men's programs are shown only to that
/// sex (as chosen at sign-up) and only while that health section is on.
enum Audience { all, female, male }

/// Programs that need the user to confirm a doctor's go-ahead first.
enum Clearance { none, pregnancy, postpartum }

/// A short, fixed routine for one purpose (flexibility, balance, pelvic
/// floor, pregnancy…), separate from the weekly plan. Done through the same
/// session screen and saved as a session with its id.
class Program {
  const Program({
    required this.id,
    required this.audience,
    required this.ar,
    required this.en,
    required this.aboutAr,
    required this.aboutEn,
    required this.items,
    this.clearance = Clearance.none,
    this.group,
  });

  final String id;
  final Audience audience;
  final String ar;
  final String en;
  final String aboutAr;
  final String aboutEn;
  final List<PlannedExercise> items;
  final Clearance clearance;

  /// Variants shown together (pregnancy trimesters, postpartum stages).
  final String? group;

  String name(String lang) => lang == 'ar' ? ar : en;
  String about(String lang) => lang == 'ar' ? aboutAr : aboutEn;

  /// Rough length: work plus rest, rounded up to whole minutes.
  int get minutes {
    var s = 0;
    for (final x in items) {
      s += x.sets * ((x.seconds ?? (x.reps ?? 10) * 4) + x.restSeconds);
    }
    return (s / 60).ceil();
  }

  /// As a day for the session screen.
  WorkoutDay asDay(int weekday) => WorkoutDay(weekday: weekday, focus: DayFocus.mobility, exercises: items, minutes: minutes);
}

PlannedExercise _r(String id, int sets, int reps, {int rest = 30}) => PlannedExercise(exerciseId: id, sets: sets, reps: reps, restSeconds: rest);
PlannedExercise _t(String id, int sets, int seconds, {int rest = 20}) =>
    PlannedExercise(exerciseId: id, sets: sets, seconds: seconds, restSeconds: rest);

final programs = <Program>[
  // ---------------------------------------------------------------- shared
  Program(
    id: 'flexibility', audience: Audience.all,
    ar: 'المرونة والإطالة', en: 'Flexibility and stretching',
    aboutAr: 'إطالات لطيفة لكامل الجسم بعد الجلوس الطويل أو بعد التمرين.',
    aboutEn: 'Gentle whole-body stretches for after long sitting or after training.',
    items: [
      _t('cat_cow', 1, 45), _t('hamstring_stretch', 2, 30), _t('quad_stretch', 2, 30), _t('hip_flexor_stretch', 2, 30),
      _t('figure_four_stretch', 2, 30), _t('chest_doorway_stretch', 2, 30), _t('calf_stretch', 2, 30), _t('neck_stretch', 2, 20),
      _t('childs_pose', 1, 45),
    ],
  ),
  Program(
    id: 'balance', audience: Audience.all,
    ar: 'التوازن', en: 'Balance',
    aboutAr: 'تمارين تقوّي الثبات وتقلل التعثر، بجانب كرسي أو حائط.',
    aboutEn: 'Steadiness work that helps prevent trips and falls, next to a chair or wall.',
    items: [
      _t('single_leg_stand', 2, 30), _t('tandem_stance', 2, 30), _t('heel_toe_walk', 2, 30), _r('standing_side_leg_raise', 2, 10),
      _r('single_leg_rdl_bw', 2, 8), _r('calf_raise', 2, 12),
    ],
  ),
  // ------------------------------------------------------------- women's
  Program(
    id: 'pelvic_floor_women', audience: Audience.female,
    ar: 'قاع الحوض للمرأة', en: 'Pelvic floor for women',
    aboutAr: 'لدعم المثانة والتحكم والثبات، في أي عمر. ابدئي بالجلوس أو الاستلقاء.',
    aboutEn: 'Supports bladder control and stability at any age. Start sitting or lying down.',
    items: [
      _t('diaphragmatic_breathing', 1, 60), _r('pelvic_floor_hold', 3, 10), _r('pelvic_floor_quick', 2, 10), _r('glute_bridge', 2, 10),
      _r('clamshell', 2, 10), _r('bird_dog', 2, 8),
    ],
  ),
  Program(
    id: 'pregnancy_t1', audience: Audience.female, clearance: Clearance.pregnancy, group: 'pregnancy',
    ar: 'الحمل — الثلث الأول', en: 'Pregnancy — first trimester',
    aboutAr: 'نشاط معتدل يناسب أغلب حالات الحمل الطبيعي بعد موافقة الطبيب.',
    aboutEn: 'Moderate activity suited to most uncomplicated pregnancies, with your doctor\'s go-ahead.',
    items: [
      _t('brisk_walk', 1, 600, rest: 60), _r('sit_to_stand', 2, 10), _r('incline_pushup', 2, 8), _r('bird_dog', 2, 8),
      _t('cat_cow', 1, 45), _r('pelvic_floor_hold', 2, 10), _t('diaphragmatic_breathing', 1, 60),
    ],
  ),
  Program(
    id: 'pregnancy_t2', audience: Audience.female, clearance: Clearance.pregnancy, group: 'pregnancy',
    ar: 'الحمل — الثلث الثاني', en: 'Pregnancy — second trimester',
    aboutAr: 'بدون استلقاء طويل على الظهر؛ تمارين واقفة وعلى الجنب.',
    aboutEn: 'No long stretches lying on your back; standing and side-lying work.',
    items: [
      _t('brisk_walk', 1, 600, rest: 60), _r('sit_to_stand', 2, 10), _r('incline_pushup', 2, 8), _r('clamshell', 2, 10),
      _r('pelvic_tilt_wall', 2, 10), _t('cat_cow', 1, 45), _r('pelvic_floor_hold', 2, 10), _t('diaphragmatic_breathing', 1, 60),
    ],
  ),
  Program(
    id: 'pregnancy_t3', audience: Audience.female, clearance: Clearance.pregnancy, group: 'pregnancy',
    ar: 'الحمل — الثلث الأخير', en: 'Pregnancy — third trimester',
    aboutAr: 'أخف وأقصر، مع التنفس وقاع الحوض. خففي أكثر إذا تعبتِ.',
    aboutEn: 'Lighter and shorter, with breathing and pelvic floor. Ease off further if tired.',
    items: [
      _t('brisk_walk', 1, 480, rest: 60), _r('sit_to_stand', 2, 8), _r('pelvic_tilt_wall', 2, 8), _r('clamshell', 2, 8),
      _t('cat_cow', 1, 40), _r('pelvic_floor_hold', 2, 8), _t('diaphragmatic_breathing', 2, 60),
    ],
  ),
  Program(
    id: 'postpartum_early', audience: Audience.female, clearance: Clearance.postpartum, group: 'postpartum',
    ar: 'بعد الولادة — الأسابيع الأولى', en: 'After birth — the first weeks',
    aboutAr: 'تنفّس وقاع الحوض ومشي قصير فقط. بعد القيصرية التزمي بتعليمات طبيبك.',
    aboutEn: 'Breathing, pelvic floor and short walks only. After a caesarean, follow your doctor\'s advice.',
    items: [
      _t('diaphragmatic_breathing', 2, 60), _r('pelvic_floor_hold', 2, 8), _r('pelvic_floor_quick', 1, 8), _r('heel_slide', 2, 6),
      _t('brisk_walk', 1, 300, rest: 60),
    ],
  ),
  Program(
    id: 'postpartum_return', audience: Audience.female, clearance: Clearance.postpartum, group: 'postpartum',
    ar: 'بعد الولادة — العودة التدريجية', en: 'After birth — gradual return',
    aboutAr: 'بعد فحص ما بعد الولادة (عادة 6 أسابيع أو أكثر) وموافقة الطبيب.',
    aboutEn: 'After your postnatal check (usually six weeks or later) and your doctor\'s go-ahead.',
    items: [
      _t('diaphragmatic_breathing', 1, 60), _r('pelvic_floor_hold', 2, 10), _r('glute_bridge', 2, 10), _r('bird_dog', 2, 8),
      _r('dead_bug', 2, 6), _r('bw_squat', 2, 10), _r('clamshell', 2, 10), _r('incline_pushup', 2, 8),
    ],
  ),
  // --------------------------------------------------------------- men's
  Program(
    id: 'pelvic_floor_men', audience: Audience.male,
    ar: 'قاع الحوض للرجل', en: 'Pelvic floor for men',
    aboutAr: 'تمارين تدعم التحكم بالمثانة، وتنفع بعد جراحة البروستاتا بإشراف الطبيب.',
    aboutEn: 'Supports bladder control; also used after prostate surgery under medical guidance.',
    items: [
      _t('diaphragmatic_breathing', 1, 60), _r('pelvic_floor_hold', 3, 10), _r('pelvic_floor_quick', 2, 10), _r('glute_bridge', 2, 12),
      _r('bird_dog', 2, 8),
    ],
  ),
  Program(
    id: 'back_posture_men', audience: Audience.male,
    ar: 'الظهر والقوام', en: 'Back and posture',
    aboutAr: 'لمن يجلس طويلًا أمام المكتب أو القيادة: ظهر أقوى وصدر مفتوح.',
    aboutEn: 'For long hours at a desk or driving: a stronger back and an open chest.',
    items: [
      _r('chin_tuck', 2, 10), _t('cat_cow', 1, 45), _r('prone_y_raise', 3, 10), _r('superman', 2, 10), _r('bird_dog', 2, 10),
      _r('glute_bridge', 2, 12), _t('chest_doorway_stretch', 2, 30), _t('hip_flexor_stretch', 2, 30), _t('thoracic_rotation', 2, 30),
    ],
  ),
];

Program? programById(String? id) => id == null ? null : programs.where((p) => p.id == id).firstOrNull;

/// Whether [s] may see [p]: shared programs always; women's only for a
/// woman with the women's section on, men's only for a man with the men's
/// section on. No sex chosen: shared only.
bool programVisible(Program p, UserSettings s) => switch (p.audience) {
      Audience.all => true,
      Audience.female => s.sex == Sex.female && s.health.has(HealthModule.womens),
      Audience.male => s.sex == Sex.male && s.health.has(HealthModule.mens),
    };

List<Program> programsFor(UserSettings s) => [for (final p in programs) if (programVisible(p, s)) p];

bool clearedFor(Program p, HealthSettings h) => switch (p.clearance) {
      Clearance.none => true,
      Clearance.pregnancy => h.pregnancyCleared,
      Clearance.postpartum => h.postpartumCleared,
    };
