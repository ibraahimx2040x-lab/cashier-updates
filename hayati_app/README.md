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

## الوضع الحالي: «الوضع المحلي»

النسخة الحالية تعمل بالكامل على الجهاز: الحسابات (بكلمات مرور مملّحة ومُجزّأة) والبيانات محفوظة محليًا، ومعزولة لكل حساب. المساعد في التطبيق محرك قواعد محلي يفهم مجموعة محددة من الطلبات بالعربية والإنجليزية، ولا يرسل أي بيانات خارج الجهاز.

الخادم (Supabase/PostgreSQL مع RLS، ودالة المساعد السحابية التي تستدعي Claude) جاهز في مجلد `../supabase`، لكنه **غير موصول بالتطبيق بعد**. راجع `../docs/ROADMAP.md`.

## البنية

```
lib/
  core/theme      الألوان والخطوط والمسافات (القسم 7–10 من الوثيقة)
  core/router     التنقل وحماية المسارات (GoRouter)
  core/utils      التواريخ والتنسيق والتسميات
  data/           النماذج، التخزين، المصادقة، DataController (كل قواعد التحقق)
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

## ما تتحقق منه الاختبارات (53 اختبارًا)

- المخطط: يضع المهام حول المواعيد الثابتة وساعات العمل، لا يحشر ما لا يتسع، يعلّم المدد المقترحة، ويحترم الترتيب اليدوي.
- المساعد: فهم «أضف مهمة … غدًا الساعة 8 مساءً»، السؤال عند غموض الساعة، اقتراح هدف تعلم بمراحل، احترام صلاحيات الاطلاع، رفض الأدوات والمعاملات المجهولة.
- المنفّذ: تنفيذ الاقتراح مرة واحدة فقط، رفض الاقتراح القديم، التراجع الكامل عند فشل أي جزء.
- البيانات: عزل الحسابات، عدم تكرار سجل العادة، رفض المبالغ غير الموجبة، عدم جمع العملات المختلفة، اكتمال المرحلة مع مهامها.
- الواجهة: التسجيل ← الإعداد ← الرئيسية بالعربية والإنجليزية، وفتح كل شاشة مع بيانات على الجوال وسطح المكتب دون أخطاء تخطيط.
