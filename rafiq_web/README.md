# رفيق · Rafiq

موقع دردشة مع شخصيات خيالية (مو تطبيق) — تكتشف شخصيات، تسولف معها، وتصنع شخصيتك الخاصة.

A website for chatting with fictional AI characters: discover, chat, and create your own.

## الميزات
- **اكتشف**: شخصية مميزة يوميًا، تصنيفات (أصدقاء، مغامرة، أنمي، خيال، غموض، خيال علمي، رعب، تعلّم، حكايات)، وبحث.
- **المحادثة**: ردود تظهر حرفًا بحرف، الحركات بين نجمتين `*تبتسم*` تظهر مائلة، زر «رد ثاني»، نسخ، إيقاف، محادثة جديدة، حذف.
- **اصنع شخصيتك**: الاسم، الصورة (شكل أنمي تصممه: الشعر والعيون والبشرة واللبس والإكسسوار، أو إيموجي، أو صورة ترفعها)، الوصف، الشخصية، المشهد، أول رسالة، التصنيف.
- **المحادثات**: قائمة بآخر المحادثات.
- **حسابي**: اسمك في القصص، العربية/English، داكن/فاتح.
- يشتغل على الجوال والكمبيوتر، يمين لليسار ويسار لليمين.

الشخصيات والمحادثات تنحفظ في متصفح الزائر (localStorage)، بدون تسجيل دخول.

## كيف يشتغل
- `index.html`, `styles.css`, `app.js` — الموقع (HTML/CSS/JS بدون أي بناء).
- `characters.js` — الشخصيات الجاهزة (كلها أصلية).
- `portraits.js` — يرسم صور الأنمي للشخصيات (SVG)، وتقدر تصمم شكل شخصيتك منه.
- `config.js` — رابط دالة الدردشة.
- الردود من `supabase/functions/character-chat` (Gemini)، والمفتاح `GEMINI_API_KEY` في أسرار الدالة فقط.

## التشغيل محليًا
```sh
cd rafiq_web && python3 -m http.server 8080   # ثم افتح http://localhost:8080
```

## النشر
```sh
supabase functions deploy character-chat --no-verify-jwt
supabase secrets set ALLOWED_ORIGIN=https://ibraahimx2040x-lab.github.io   # اختياري: يحصر الطلبات على الموقع
```
وينشر GitHub Pages الموقع على `https://ibraahimx2040x-lab.github.io/cashier-updates/rafiq/` عند الدمج في `main`.
