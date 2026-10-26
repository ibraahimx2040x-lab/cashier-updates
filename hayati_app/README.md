# حياتي · Hayati — تطبيق Flutter

نظام شخصي لإدارة الوقت والمهام والأهداف والعادات والملاحظات والمصروفات، مع مساعد ذكي مقيّد بالصلاحيات. يعمل على Android وiOS والويب، بالعربية (RTL) والإنجليزية (LTR)، وبالوضعين الفاتح والداكن.

## التشغيل

```bash
flutter pub get
flutter run                 # جهاز أو محاكي
flutter run -d chrome       # الويب
flutter analyze && flutter test
```

يتطلب Flutter 3.47 أو أحدث. ملفات الترجمة تُولَّد تلقائيًا من `lib/l10n/*.arb`.

## وضعا التشغيل

**الوضع المحلي (افتراضي):** دون أي إعداد. الحسابات (بكلمات مرور مملّحة ومُجزّأة) والبيانات على الجهاز فقط، معزولة لكل حساب.

**الوضع المتصل بـ Supabase:** مرّر عنوان المشروع والمفتاح العام عند البناء:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<project>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon/publishable key>
```

مشروع حياتي الحالي:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://ldptcpbqbgarypzplbwy.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_gxM3jE1D_xIAjgChGATTXg_HQp3knyD
```

في هذا الوضع:
- تسجيل الدخول عبر Supabase Auth: تأكيد البريد (إن كان مفعّلًا في المشروع)، رابط استعادة كلمة المرور، وتغييرها.
- المهام والمواعيد والأهداف ومراحلها والعادات وسجلاتها والملاحظات والمصروفات والميزانيات والإعدادات تُحفظ في الخادم، مع نسخة على الجهاز تجعل التطبيق يفتح ويعمل دون اتصال.
- كل تعديل يُحفظ فورًا على الجهاز ويوضع في طابور رفع محفوظ؛ إن انقطع الاتصال يُعاد تلقائيًا ويظهر شريط يوضح عدد التغييرات المعلقة. بعد الرفع يُحمَّل أحدث ما في الخادم، فتظهر تعديلات الأجهزة الأخرى.
- إذا رفض الخادم تغييرًا (قيد في قاعدة البيانات) يُستبدل بنسخة الخادم ويُبلَّغ المستخدم.
- حذف الحساب يسجّل طلب حذف في الخادم ثم يمسح نسخة الجهاز.

ما زال على الجهاز فقط حتى الآن: محادثات المساعد (المساعد ما زال المحرك المحلي)، الإشعارات، وبلاغات الدعم.

المفتاح العام آمن في التطبيق لأن كل الجداول محمية بـ RLS. لا تضع مفتاح service-role في التطبيق أبدًا.

### اختبارات التكامل مع Supabase

```bash
cd ..            # جذر المستودع
supabase start   # يطبّق supabase/migrations
cd hayati_app
SUPABASE_TEST_URL=http://127.0.0.1:54321 SUPABASE_TEST_ANON_KEY=<ANON_KEY من supabase status> \
  flutter test test/supabase_integration_test.dart
```

تحاكي جهازين لحساب واحد وحسابًا آخر: التسجيل، رفع البيانات، تحميلها على جهاز جديد، الحذف بين الأجهزة، عزل الحسابات، رفض الخادم لتغيير متعارض، أخطاء الدخول، وحذف الحساب.

## البنية

```
lib/
  core/theme      الألوان والخطوط والمسافات (القسم 7–10 من الوثيقة)
  core/router     التنقل وحماية المسارات (GoRouter)
  core/utils      التواريخ والتنسيق والتسميات
  data/           النماذج، التخزين، المصادقة، DataController (كل قواعد التحقق)
  data/remote/    Supabase: المصادقة، تحويل الصفوف، محرك المزامنة
  domain/         المخطط اليومي، المقاييس والتقارير، التذكيرات
  domain/assistant  الأدوات المسموحة، سياسة الصلاحيات، المنفّذ الذري، المحرك المحلي
  features/       الشاشات
  widgets/        المكونات المشتركة (القسم 11)
  l10n/           العربية والإنجليزية (ARB)
test/             اختبارات الوحدات وتدفقات الواجهة
```

## الشاشات الأربع والعشرون

| # | الشاشة | الملف |
|---|---|---|
| 1 | البداية | `features/auth/splash_screen.dart` |
| 2 | الترحيب | `features/auth/welcome_screen.dart` |
| 3 | إنشاء الحساب / الدخول | `features/auth/auth_screen.dart` |
| 4 | الإعداد الأولي | `features/auth/onboarding_screen.dart` |
| 5 | الرئيسية «يومي» | `features/home/home_screen.dart` |
| 6 | المهام | `features/time/tasks_view.dart` |
| 7 | إضافة/تعديل مهمة | `features/time/task_edit_screen.dart` |
| 8 | التقويم (+ محرر المواعيد) | `features/time/calendar_view.dart`, `event_edit_screen.dart` |
| 9 | تخطيط اليوم | `features/time/planner_view.dart` |
| 10 | الأهداف | `features/goals/goals_screen.dart` |
| 11 | إنشاء/تعديل هدف | `features/goals/goal_edit_screen.dart` |
| 12 | العادات وسجلها | `features/habits/habits_screen.dart` |
| 13 | المساعد | `features/assistant/assistant_screen.dart` |
| 14 | مراجعة التغييرات | `features/assistant/review_screen.dart` |
| 15 | الملاحظات | `features/notes/notes_screen.dart`, `note_editor_screen.dart` |
| 16 | المصروفات والميزانية | `features/expenses/expenses_screen.dart` |
| 17 | تقدمي والتقرير | `features/progress/progress_screen.dart` |
| 18 | الإشعارات | `features/notifications/notifications_screen.dart` |
| 19 | الإعدادات العامة | `features/settings/settings_screen.dart` |
| 20 | إعدادات المساعد | `features/settings/assistant_settings_screen.dart` |
| 21 | الملف الشخصي والحساب | `features/settings/profile_screen.dart` |
| 22 | الاشتراك | `features/settings/subscription_screen.dart` |
| 23 | المساعدة والدعم | `features/settings/help_screen.dart` |
| 24 | الخصوصية والبيانات | `features/settings/privacy_screen.dart` |

## ما تتحقق منه الاختبارات (53 اختبارًا + 6 تكامل)

- المخطط: يضع المهام حول المواعيد الثابتة وساعات العمل، لا يحشر ما لا يتسع، يعلّم المدد المقترحة، ويحترم الترتيب اليدوي.
- المساعد: فهم «أضف مهمة … غدًا الساعة 8 مساءً»، السؤال عند غموض الساعة، اقتراح هدف تعلم بمراحل، احترام صلاحيات الاطلاع، رفض الأدوات والمعاملات المجهولة.
- المنفّذ: تنفيذ الاقتراح مرة واحدة فقط، رفض الاقتراح القديم، التراجع الكامل عند فشل أي جزء.
- البيانات: عزل الحسابات، عدم تكرار سجل العادة، رفض المبالغ غير الموجبة، عدم جمع العملات المختلفة، اكتمال المرحلة مع مهامها.
- الواجهة: التسجيل ← الإعداد ← الرئيسية بالعربية والإنجليزية، وفتح كل شاشة مع بيانات على الجوال وسطح المكتب دون أخطاء تخطيط.
