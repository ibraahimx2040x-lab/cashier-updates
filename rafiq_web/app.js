(() => {
  "use strict";

  // ---------------------------------------------------------------- storage
  const store = {
    get(key, fallback) {
      try {
        const v = localStorage.getItem("rafiq." + key);
        return v == null ? fallback : JSON.parse(v);
      } catch {
        return fallback;
      }
    },
    set(key, value) {
      try {
        localStorage.setItem("rafiq." + key, JSON.stringify(value));
        return true;
      } catch {
        toast(tr("storageFull"));
        return false;
      }
    },
  };

  const settings = Object.assign(
    { lang: (navigator.language || "ar").startsWith("ar") ? "ar" : "en", theme: "dark", persona: "" },
    store.get("settings", {}),
  );
  let custom = store.get("custom", []);
  let chats = store.get("chats", {});

  const saveSettings = () => store.set("settings", settings);
  const saveCustom = () => store.set("custom", custom);
  const saveChats = () => store.set("chats", chats);

  // ---------------------------------------------------------------- i18n
  const I18N = {
    ar: {
      brand: "رفيق", discover: "اكتشف", chats: "المحادثات", create: "اصنع", me: "حسابي",
      search: "ابحث عن شخصية…", featured: "شخصية مميزة", startChat: "ابدأ المحادثة", continueChat: "كمّل المحادثة",
      famous: "شخصيات أنمي وكرتون مشهورة", originals: "شخصيات رفيق الأصلية", fanNote: "شخصيات من أعمال مشهورة، كتبها المعجبون للتسلية. الحقوق لأصحابها.",
      forYou: "شخصيات لك", mine: "شخصياتي", noResults: "ما لقينا شخصية بهذا الاسم", yours: "لك",
      firstMessage: "أول رسالة", edit: "تعديل", close: "إغلاق",
      typeMessage: "اكتب رسالة…", send: "إرسال", action: "أضف حركة بين نجمتين", regenerate: "رد ثاني", copy: "نسخ", copied: "تم النسخ",
      stop: "إيقاف", profile: "ملف الشخصية", newChat: "محادثة جديدة", deleteChat: "حذف المحادثة",
      confirmNew: "تبدأ محادثة جديدة؟ بتنحذف المحادثة الحالية.", confirmDelete: "تحذف هذي المحادثة؟",
      fiction: "كل ما تقوله الشخصيات خيالي من صنع الذكاء الاصطناعي.",
      noChats: "ما عندك محادثات للحين", noChatsHint: "اختر شخصية وابدأ أول سوالف.", explore: "اكتشف الشخصيات",
      createTitle: "اصنع شخصيتك", editTitle: "عدّل الشخصية", avatar: "الصورة", upload: "ارفع صورة", removeImage: "شيل الصورة",
      name: "الاسم", namePh: "مثلًا: سلمى", tagline: "وصف قصير", taglinePh: "جملة تعرّف بالشخصية في البطاقة",
      personality: "الشخصية", personalityPh: "من هي؟ كيف تتكلم؟ وش تحب ووش تكره؟ وش قصتها؟",
      personalityHint: "كل ما كان الوصف أوضح، كانت الشخصية أقرب للي تبيه.",
      scenario: "المشهد (اختياري)", scenarioPh: "وين تبدأ القصة؟ وش علاقتك بالشخصية؟",
      greeting: "أول رسالة", greetingPh: "*تلتفت لك* هلا! …", category: "التصنيف",
      save: "احفظ", saved: "تم الحفظ", deleteChar: "احذف الشخصية", confirmDeleteChar: "تحذف الشخصية ومحادثتها؟", required: "الاسم والشخصية مطلوبة",
      settingsTitle: "حسابي", yourName: "اسمك في القصص", yourNamePh: "مثلًا: عبدالله", language: "اللغة", theme: "المظهر",
      dark: "داكن", light: "فاتح", clearAll: "امسح كل بياناتي", confirmClear: "تمسح كل الشخصيات اللي صنعتها وكل المحادثات؟ ما تقدر ترجعها.",
      cleared: "تم المسح", localNote: "شخصياتك ومحادثاتك محفوظة في هذا المتصفح فقط.",
      err_provider_error: "صار خطأ في الاتصال. جرّب مرة ثانية.", err_busy: "الضغط عالي الحين، جرّب بعد شوي.",
      err_refusal: "الشخصية ما تقدر ترد على هذا. جرّب تكمّل القصة بطريقة ثانية.", err_empty: "ما وصل رد. جرّب مرة ثانية.",
      err_not_configured: "الخادم غير مهيأ بعد.", err_network: "تأكد من الإنترنت وجرّب مرة ثانية.", retry: "أعد المحاولة",
      storageFull: "المساحة ممتلئة في المتصفح. احذف محادثات قديمة أو صور.", justNow: "الحين",
      notFound: "الشخصية غير موجودة", back: "رجوع", more: "المزيد",
      err_sceneRefusal: "ما قدرنا نرسم هذا المشهد. جرّب مشهد ثاني.",
      err_quota: "الخدمة وصلت حدها الحين. جرّب بعدين.",
      drawScene: "ارسم المشهد", drawing: "يرسم المشهد…", viewScene: "رسمة المشهد", download: "تحميل", redraw: "ارسم من جديد",
      anime: "أنمي", emoji: "إيموجي", photo: "صورة", randomLook: "شكل عشوائي",
      hairStyle: "الشعر", expression: "التعبير", outfitStyle: "اللبس", accessory: "إكسسوار",
      hairColor: "لون الشعر", eyeColor: "لون العيون", skinColor: "لون البشرة", outfitColor: "لون اللبس", background: "الخلفية",
      look: {
        bald: "أصلع", cap: "كاب", strawhat: "قبعة قش", ninjaband: "عصابة نينجا", blindfold: "عصابة عين", scarf: "وشاح",
        short: "قصير", spiky: "منفوش", long: "طويل", bob: "بوب", ponytail: "ذيل حصان", hijab: "حجاب",
        smile: "مبتسم", grin: "ضحكة", calm: "هادي", stern: "جاد", shy: "خجول", happy: "فرحان", cat: "شقي",
        shirt: "قميص", hoodie: "هودي", coat: "معطف", kimono: "كيمونو", dress: "فستان", jacket: "جاكيت",
        none: "بدون", glasses: "نظارة", headband: "عصابة رأس", hairclip: "مشبك", fedora: "قبعة محقق", pirate: "قبعة قرصان", horns: "قرون", headset: "سماعة", flower: "وردة",
      },
    },
    en: {
      brand: "Rafiq", discover: "Discover", chats: "Chats", create: "Create", me: "Me",
      search: "Search characters…", featured: "Featured", startChat: "Start chat", continueChat: "Continue chat",
      famous: "Famous anime & cartoon characters", originals: "Rafiq originals", fanNote: "Fan-made role-play of characters from well-known works. All rights belong to their creators.",
      forYou: "For you", mine: "My characters", noResults: "No characters match that", yours: "Yours",
      firstMessage: "First message", edit: "Edit", close: "Close",
      typeMessage: "Type a message…", send: "Send", action: "Add an *action*", regenerate: "Regenerate", copy: "Copy", copied: "Copied",
      stop: "Stop", profile: "Character profile", newChat: "New chat", deleteChat: "Delete chat",
      confirmNew: "Start a new chat? The current one will be deleted.", confirmDelete: "Delete this chat?",
      fiction: "Everything characters say is AI-generated fiction.",
      noChats: "No chats yet", noChatsHint: "Pick a character and say hi.", explore: "Explore characters",
      createTitle: "Create a character", editTitle: "Edit character", avatar: "Avatar", upload: "Upload image", removeImage: "Remove image",
      name: "Name", namePh: "e.g. Selma", tagline: "Tagline", taglinePh: "One line shown on the card",
      personality: "Personality", personalityPh: "Who are they? How do they talk? Likes, dislikes, backstory?",
      personalityHint: "The clearer the description, the closer the character feels.",
      scenario: "Scenario (optional)", scenarioPh: "Where does the story start? How do you know each other?",
      greeting: "First message", greetingPh: "*looks up* Oh, hi! …", category: "Category",
      save: "Save", saved: "Saved", deleteChar: "Delete character", confirmDeleteChar: "Delete this character and its chat?", required: "Name and personality are required",
      settingsTitle: "Me", yourName: "Your name in stories", yourNamePh: "e.g. Alex", language: "Language", theme: "Theme",
      dark: "Dark", light: "Light", clearAll: "Clear all my data", confirmClear: "Delete all characters you made and all chats? This can't be undone.",
      cleared: "Cleared", localNote: "Your characters and chats are saved in this browser only.",
      err_provider_error: "Something went wrong. Try again.", err_busy: "It's busy right now. Try again in a moment.",
      err_refusal: "The character can't respond to that. Try taking the story another way.", err_empty: "No reply came back. Try again.",
      err_not_configured: "The server isn't set up yet.", err_network: "Check your connection and try again.", retry: "Retry",
      storageFull: "Browser storage is full. Delete old chats or images.", justNow: "now",
      notFound: "Character not found", back: "Back", more: "More",
      err_sceneRefusal: "This scene couldn't be drawn. Try another one.",
      err_quota: "The service has reached its limit for now. Try again later.",
      drawScene: "Draw scene", drawing: "Drawing the scene…", viewScene: "Scene drawing", download: "Download", redraw: "Redraw",
      anime: "Anime", emoji: "Emoji", photo: "Photo", randomLook: "Random look",
      hairStyle: "Hair", expression: "Expression", outfitStyle: "Outfit", accessory: "Accessory",
      hairColor: "Hair colour", eyeColor: "Eye colour", skinColor: "Skin tone", outfitColor: "Outfit colour", background: "Background",
      look: {
        bald: "Bald", cap: "Cap", strawhat: "Straw hat", ninjaband: "Ninja headband", blindfold: "Blindfold", scarf: "Scarf",
        short: "Short", spiky: "Spiky", long: "Long", bob: "Bob", ponytail: "Ponytail", hijab: "Hijab",
        smile: "Smile", grin: "Grin", calm: "Calm", stern: "Serious", shy: "Shy", happy: "Happy", cat: "Playful",
        shirt: "Shirt", hoodie: "Hoodie", coat: "Coat", kimono: "Kimono", dress: "Dress", jacket: "Jacket",
        none: "None", glasses: "Glasses", headband: "Headband", hairclip: "Hair clip", fedora: "Detective hat", pirate: "Pirate hat", horns: "Horns", headset: "Headset", flower: "Flower",
      },
    },
  };
  const tr = (k) => I18N[settings.lang][k] ?? I18N.en[k] ?? k;
  const loc = (v) => (v && typeof v === "object" ? v[settings.lang] ?? v.en ?? v.ar ?? "" : v ?? "");

  // ---------------------------------------------------------------- icons
  const ICON = {
    compass: '<path d="M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z"/><path d="m15.5 8.5-2 5-5 2 2-5 5-2Z"/>',
    chat: '<path d="M20 12a8 8 0 0 1-11.6 7.1L4 20l.9-4.4A8 8 0 1 1 20 12Z"/>',
    plus: '<path d="M12 5v14M5 12h14"/>',
    user: '<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>',
    search: '<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>',
    back: '<path d="m15 18-6-6 6-6"/>',
    send: '<path d="M4 12h14M13 6l6 6-6 6"/>',
    stop: '<rect x="7" y="7" width="10" height="10" rx="2"/>',
    dots: '<circle cx="12" cy="5" r="1.4"/><circle cx="12" cy="12" r="1.4"/><circle cx="12" cy="19" r="1.4"/>',
    x: '<path d="M6 6l12 12M18 6 6 18"/>',
    refresh: '<path d="M20 11a8 8 0 1 0-2.3 5.7M20 4v7h-7"/>',
    copy: '<rect x="9" y="9" width="11" height="11" rx="2"/><path d="M5 15V5a2 2 0 0 1 2-2h8"/>',
    trash: '<path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13"/>',
    info: '<circle cx="12" cy="12" r="9"/><path d="M12 11v6M12 7.5v.5"/>',
    edit: '<path d="M4 20h4L19 9l-4-4L4 16v4Z"/>',
    sparkle: '<path d="M12 3v4M12 17v4M3 12h4M17 12h4M6 6l2.5 2.5M15.5 15.5 18 18M6 18l2.5-2.5M15.5 8.5 18 6"/>',
  };
  const icon = (name, cls = "") =>
    `<svg class="${cls}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${ICON[name]}</svg>`;

  // ---------------------------------------------------------------- helpers
  const $ = (sel, root = document) => root.querySelector(sel);
  const esc = (s) => String(s ?? "").replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]);
  const uid = () => "u_" + Date.now().toString(36) + Math.random().toString(36).slice(2, 7);

  function fmt(text) {
    return esc(text)
      .replace(/\*\*([^*\n]+)\*\*/g, "<strong>$1</strong>")
      .replace(/\*([^*\n]+)\*/g, '<em class="act">$1</em>')
      .replace(/\n/g, "<br>");
  }

  let toastTimer;
  function toast(msg) {
    const el = $("#toast");
    el.textContent = msg;
    el.classList.add("show");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => el.classList.remove("show"), 2200);
  }

  function ago(ts) {
    const s = (Date.now() - ts) / 1000;
    if (s < 60) return tr("justNow");
    const rtf = new Intl.RelativeTimeFormat(settings.lang, { numeric: "auto", style: "narrow" });
    if (s < 3600) return rtf.format(-Math.round(s / 60), "minute");
    if (s < 86400) return rtf.format(-Math.round(s / 3600), "hour");
    if (s < 86400 * 7) return rtf.format(-Math.round(s / 86400), "day");
    return new Date(ts).toLocaleDateString(settings.lang);
  }

  const allCharacters = () => [...custom, ...window.FAMOUS_CHARACTERS, ...window.SEED_CHARACTERS];
  const findChar = (id) => allCharacters().find((c) => c.id === id);

  const hueOf = (c) => (c.portrait && !c.avatar?.image ? window.Portrait.normalize(c.portrait).bg : c.avatar?.hue ?? 260);
  const imageOf = (c) => c.avatar?.image || (c.portrait ? window.Portrait.url(c.portrait) : "");

  function avatar(c, size) {
    const a = c.avatar || {};
    const img = imageOf(c);
    const inner = img ? `<img src="${esc(img)}" alt="">` : esc(a.emoji || "🙂");
    return `<span class="avatar" style="width:${size}px;height:${size}px;font-size:${Math.round(size * 0.52)}px;background:hsl(${hueOf(c)} 45% 30%)">${inner}</span>`;
  }
  const coverInner = (c) => (imageOf(c) ? `<img src="${esc(imageOf(c))}" alt="" loading="lazy">` : esc(c.avatar?.emoji || "🙂"));

  // ---------------------------------------------------------------- shell
  function applyShell() {
    document.documentElement.lang = settings.lang;
    document.documentElement.dir = settings.lang === "ar" ? "rtl" : "ltr";
    document.documentElement.dataset.theme = settings.theme;
    $('meta[name="theme-color"]').content = settings.theme === "light" ? "#f7f5fc" : "#0f0d17";
    document.title = settings.lang === "ar" ? "رفيق · دردش مع الشخصيات" : "Rafiq · Chat with characters";
  }

  function renderNav(active) {
    const item = (href, ic, label, key, extra = "") =>
      `<a href="${href}" class="nav-item ${extra} ${active === key ? "active" : ""}" ${active === key ? 'aria-current="page"' : ""}>${icon(ic)}<span>${label}</span></a>`;
    $("#nav").innerHTML = `
      <a href="#/" class="brand"><span class="logo">💬</span><span>${tr("brand")}</span></a>
      ${item("#/", "compass", tr("discover"), "discover")}
      ${item("#/chats", "chat", tr("chats"), "chats")}
      ${item("#/create", "plus", tr("create"), "create", "create")}
      ${item("#/me", "user", tr("me"), "me")}`;
  }

  // ---------------------------------------------------------------- discover
  const ui = { category: "all", query: "" };

  function viewDiscover() {
    const seeds = window.SEED_CHARACTERS;
    const famous = window.FAMOUS_CHARACTERS;
    const day = Math.floor(Date.now() / 86400000);
    const feat = famous[day % famous.length];
    const hasChat = (c) => chats[c.id]?.messages?.length;

    $("#view").innerHTML = `
      <div class="page">
        <div class="topbar"><h1>${tr("discover")}</h1></div>
        <label class="search">${icon("search")}<input id="q" type="search" placeholder="${tr("search")}" value="${esc(ui.query)}" autocomplete="off"></label>
        <div class="chips" role="tablist">
          ${window.CATEGORIES.map((k) => `<button class="chip ${ui.category === k.id ? "active" : ""}" data-cat="${k.id}" role="tab" aria-selected="${ui.category === k.id}">${k.icon} ${esc(k[settings.lang])}</button>`).join("")}
        </div>
        <div id="feat-wrap"></div>
        <div id="results"></div>
      </div>`;

    const featHTML = `
      <section class="featured" style="--h:${hueOf(feat)}">
        <div class="big-emoji">${coverInner(feat)}</div>
        <div class="info">
          <div class="kicker">✨ ${tr("featured")} · ${esc(loc(feat.show))}</div>
          <h2>${esc(loc(feat.name))}</h2>
          <p>${esc(loc(feat.tagline))}</p>
          <button class="btn" data-open="${feat.id}">${hasChat(feat) ? tr("continueChat") : tr("startChat")}</button>
        </div>
      </section>`;

    const card = (c) => `
      <button class="card" data-open="${esc(c.id)}">
        <div class="cover" style="--h:${hueOf(c)}">${coverInner(c)}</div>
        <div class="body">
          <div class="name">${esc(loc(c.name))}${c.custom ? `<span class="badge">${tr("yours")}</span>` : ""}</div>
          ${c.show ? `<div class="show">${esc(loc(c.show))}</div>` : ""}
          <div class="tag">${esc(loc(c.tagline))}</div>
        </div>
      </button>`;

    const draw = () => {
      const q = ui.query.trim().toLowerCase();
      const match = (c) =>
        (ui.category === "all" || c.category === ui.category) &&
        (!q || [c.name, c.tagline, c.show].some((f) => (typeof f === "object" ? Object.values(f).join(" ") : f || "").toLowerCase().includes(q)));
      const mine = custom.filter(match);
      const list = seeds.filter(match);
      const fam = famous.filter(match);
      $("#feat-wrap").innerHTML = !q && ui.category === "all" ? featHTML : "";
      let html = "";
      if (mine.length) html += `<div class="section-title">🎨 ${tr("mine")}</div><div class="grid">${mine.map(card).join("")}</div>`;
      if (fam.length) html += `<div class="section-title">🔥 ${tr("famous")}</div><div class="grid">${fam.map(card).join("")}</div>`;
      if (list.length) html += `<div class="section-title">💫 ${tr("originals")}</div><div class="grid">${list.map(card).join("")}</div>`;
      if (!html) html = `<div class="empty"><div class="em">🔎</div>${tr("noResults")}</div>`;
      $("#results").innerHTML = html;
    };
    draw();

    $("#q").addEventListener("input", (e) => {
      ui.query = e.target.value;
      draw();
    });
    $("#view").addEventListener("click", (e) => {
      const chip = e.target.closest("[data-cat]");
      if (chip) {
        ui.category = chip.dataset.cat;
        document.querySelectorAll(".chip").forEach((b) => {
          b.classList.toggle("active", b === chip);
          b.setAttribute("aria-selected", b === chip);
        });
        draw();
        return;
      }
      const open = e.target.closest("[data-open]");
      if (open) openSheet(open.dataset.open);
    });
  }

  // ---------------------------------------------------------------- profile sheet
  function openSheet(id) {
    const c = findChar(id);
    if (!c) return;
    const has = chats[c.id]?.messages?.length;
    const root = $("#sheet-root");
    const previouslyFocused = document.activeElement;
    root.innerHTML = `
      <div class="sheet-backdrop">
        <div class="sheet" role="dialog" aria-modal="true" aria-labelledby="sheet-title" style="--h:${hueOf(c)}">
          <div class="hero">
            <button class="icon-btn close" data-close aria-label="${tr("close")}">${icon("x")}</button>
            ${avatar(c, 112)}
            <h2 id="sheet-title">${esc(loc(c.name))}</h2>
          </div>
          <div class="content">
            <p class="desc">${c.show ? `<b>${esc(loc(c.show))}</b> · ` : ""}${esc(loc(c.tagline))}</p>
            <div class="greet"><div class="lbl">${tr("firstMessage")}</div>${fmt(loc(c.greeting))}</div>
            ${c.show ? `<p class="fan-note">${tr("fanNote")}</p>` : ""}
            <div class="row">
              ${c.custom ? `<a class="btn ghost" href="#/create/${esc(c.id)}">${icon("edit")}${tr("edit")}</a>` : ""}
              <a class="btn" href="#/chat/${esc(c.id)}">${has ? tr("continueChat") : tr("startChat")}</a>
            </div>
          </div>
        </div>
      </div>`;
    const close = () => {
      root.innerHTML = "";
      document.removeEventListener("keydown", onKey);
      previouslyFocused?.focus?.();
    };
    const onKey = (e) => e.key === "Escape" && close();
    document.addEventListener("keydown", onKey);
    root.querySelector(".sheet-backdrop").addEventListener("click", (e) => {
      if (e.target.classList.contains("sheet-backdrop") || e.target.closest("[data-close]")) close();
      else if (e.target.closest("a")) root.innerHTML = "";
    });
    root.querySelector(".sheet a.btn:last-child").focus();
  }
  const closeSheet = () => ($("#sheet-root").innerHTML = "");

  // ---------------------------------------------------------------- chat
  let streaming = null; // { controller, charId }
  const drawing = new Set(); // messages whose scene is being drawn

  /** The character's portrait or photo as a small JPEG, for the scene drawing to match. */
  async function referenceImage(c) {
    const src = imageOf(c);
    if (!src) return null;
    try {
      const url = await shrinkDataUrl(src, 384, 0.9);
      return { mimeType: "image/jpeg", data: url.split(",")[1] };
    } catch {
      return null;
    }
  }

  function shrinkDataUrl(src, max, quality = 0.84) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => {
        const scale = Math.min(1, max / Math.max(img.naturalWidth || max, img.naturalHeight || max));
        const w = Math.round((img.naturalWidth || max) * scale), h = Math.round((img.naturalHeight || max) * scale);
        const cv = document.createElement("canvas");
        cv.width = w;
        cv.height = h;
        const g = cv.getContext("2d");
        g.fillStyle = "#fff";
        g.fillRect(0, 0, w, h);
        g.drawImage(img, 0, 0, w, h);
        resolve(cv.toDataURL("image/jpeg", quality));
      };
      img.onerror = () => reject(new Error("bad image"));
      img.src = src;
    });
  }

  function getChat(c) {
    if (!chats[c.id]) chats[c.id] = { greeting: loc(c.greeting), messages: [], updated: Date.now() };
    return chats[c.id];
  }

  function viewChat(id) {
    const c = findChar(id);
    if (!c) return viewMissing();
    const chat = getChat(c);
    document.body.classList.add("in-chat");

    $("#view").innerHTML = `
      <div class="chat">
        <header class="chat-head">
          <a class="icon-btn" href="#/chats" aria-label="${tr("back")}">${icon("back", "flip-rtl")}</a>
          <button class="who" data-act="profile">${avatar(c, 40)}<span style="min-width:0"><b>${esc(loc(c.name))}</b><small>${esc(loc(c.tagline))}</small></span></button>
          <button class="icon-btn" data-act="menu" aria-label="${tr("more")}" aria-haspopup="menu">${icon("dots")}</button>
        </header>
        <div class="msgs" id="msgs" aria-live="polite"></div>
        <form class="composer" id="composer">
          <button type="button" class="act-btn" data-act="star" title="${tr("action")}" aria-label="${tr("action")}">*</button>
          <textarea id="input" rows="1" placeholder="${tr("typeMessage")}" maxlength="2000" aria-label="${tr("typeMessage")}"></textarea>
          <button class="send" id="send" type="submit" aria-label="${tr("send")}">${icon("send", "flip-rtl")}</button>
        </form>
      </div>`;
    // Back/send arrows point the reading direction.
    document.querySelectorAll(".flip-rtl").forEach((s) => {
      if (document.documentElement.dir === "rtl") s.style.transform = "scaleX(-1)";
    });

    const msgsEl = $("#msgs");
    const input = $("#input");
    const sendBtn = $("#send");

    const hasAction = (t) => /\*[^*\n]+\*/.test(t);
    const sceneOf = (i) => (i < 0 ? chat.greetingScene : chat.messages[i]?.scene);
    const isDrawing = (i) => drawing.has(i < 0 ? "greeting" : chat.messages[i]);

    const bubble = (m, i) => {
      const isChar = m.role === "char";
      const isLastChar = isChar && i === chat.messages.length - 1;
      const scene = isChar ? sceneOf(i) : null;
      return `
        <div data-msg="${i}">
          <div class="msg ${m.role}">
            ${isChar ? avatar(c, 32) : ""}
            <div class="bubble">${fmt(m.text)}</div>
          </div>
          ${isDrawing(i) ? `<div class="scene loading"><span class="typing"><i></i><i></i><i></i></span>${tr("drawing")}</div>`
            : scene ? `<button class="scene" data-act="view" data-i="${i}" aria-label="${tr("viewScene")}"><img src="${scene}" alt="${tr("viewScene")}"></button>` : ""}
          ${isChar ? `<div class="msg-tools">
            ${hasAction(m.text) && !scene && !isDrawing(i) ? `<button data-act="scene" data-i="${i}" class="draw">🎨 ${tr("drawScene")}</button>` : ""}
            <button data-act="copy" data-i="${i}">${icon("copy")}${tr("copy")}</button>
            ${isLastChar ? `<button data-act="regen">${icon("refresh")}${tr("regenerate")}</button>` : ""}
          </div>` : ""}
        </div>`;
    };

    const draw = (keepScroll = false) => {
      const top = msgsEl.scrollTop;
      msgsEl.innerHTML =
        `<div class="intro">${tr("fiction")}</div>` +
        (chat.greeting ? bubble({ role: "char", text: chat.greeting }, -1) : "") +
        chat.messages.map(bubble).join("");
      msgsEl.scrollTop = keepScroll ? top : msgsEl.scrollHeight;
    };
    draw();

    const setBusy = (busy) => {
      sendBtn.innerHTML = busy ? icon("stop") : icon("send", "flip-rtl");
      sendBtn.setAttribute("aria-label", busy ? tr("stop") : tr("send"));
      if (!busy && document.documentElement.dir === "rtl") sendBtn.querySelector("svg").style.transform = "scaleX(-1)";
    };

    const autosize = () => {
      input.style.height = "auto";
      input.style.height = Math.min(input.scrollHeight, 140) + "px";
    };
    input.addEventListener("input", autosize);
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey && !e.isComposing && matchMedia("(hover: hover)").matches) {
        e.preventDefault();
        $("#composer").requestSubmit();
      }
    });

    async function drawScene(i) {
      const key = i < 0 ? "greeting" : chat.messages[i];
      if (!key || drawing.has(key)) return;
      const text = i < 0 ? chat.greeting : key.text;
      const actions = (text.match(/\*[^*\n]+\*/g) || []).map((a) => a.slice(1, -1).trim()).join(" … ");
      drawing.add(key);
      draw(true);
      let error = null;
      try {
        const reference = await referenceImage(c);
        const res = await fetch(window.RAFIQ_CONFIG.sceneUrl, {
          method: "POST",
          headers: { "Content-Type": "application/json", apikey: window.RAFIQ_CONFIG.apiKey },
          body: JSON.stringify({
            character: { name: loc(c.name), appearance: c.look || (c.portrait ? window.Portrait.describe(c.portrait) : ""), scenario: c.scenario || "" },
            reference,
            scene: actions,
            message: text,
          }),
        });
        let out = {};
        try {
          out = await res.json();
        } catch {}
        if (!out.data) throw Object.assign(new Error("scene"), { code: out.error || "provider_error" });
        const url = await shrinkDataUrl(`data:${out.mimeType || "image/png"};base64,${out.data}`, 768);
        if (i < 0) chat.greetingScene = url;
        else key.scene = url;
        saveChats();
      } catch (e) {
        error = e.code === "refusal" ? "sceneRefusal" : e.code || "network";
      }
      drawing.delete(key);
      if (!document.body.contains(msgsEl)) return;
      draw(true);
      if (error) toast(I18N[settings.lang]["err_" + error] ? tr("err_" + error) : tr("err_provider_error"));
    }

    function viewScene(i) {
      const url = sceneOf(i);
      if (!url) return;
      const root = $("#sheet-root");
      root.innerHTML = `
        <div class="sheet-backdrop viewer">
          <div class="viewer-box" role="dialog" aria-modal="true" aria-label="${tr("viewScene")}">
            <img src="${url}" alt="">
            <div class="row">
              <a class="btn ghost" href="${url}" download="${esc(loc(c.name))}-scene.jpg">${tr("download")}</a>
              <button class="btn ghost" data-v="redraw">🎨 ${tr("redraw")}</button>
              <button class="btn" data-v="close">${tr("close")}</button>
            </div>
          </div>
        </div>`;
      const close = () => {
        root.innerHTML = "";
        document.removeEventListener("keydown", onKey);
      };
      const onKey = (e) => e.key === "Escape" && close();
      document.addEventListener("keydown", onKey);
      root.firstElementChild.addEventListener("click", (e) => {
        const v = e.target.closest("[data-v]")?.dataset.v;
        if (v === "redraw") {
          close();
          if (i < 0) delete chat.greetingScene;
          else delete chat.messages[i].scene;
          drawScene(i);
        } else if (v === "close" || e.target.classList.contains("sheet-backdrop")) close();
      });
    }

    async function reply() {
      const controller = new AbortController();
      streaming = { controller, charId: c.id };
      setBusy(true);

      const wrap = document.createElement("div");
      wrap.innerHTML = `<div class="msg char">${avatar(c, 32)}<div class="bubble"><span class="typing"><i></i><i></i><i></i></span></div></div>`;
      msgsEl.appendChild(wrap);
      msgsEl.scrollTop = msgsEl.scrollHeight;
      const b = wrap.querySelector(".bubble");

      let text = "";
      let error = null;
      try {
        const res = await fetch(window.RAFIQ_CONFIG.chatUrl, {
          method: "POST",
          headers: { "Content-Type": "application/json", apikey: window.RAFIQ_CONFIG.apiKey },
          body: JSON.stringify({
            character: { name: loc(c.name), personality: c.personality, scenario: c.scenario || "", greeting: chat.greeting || "" },
            persona: { name: settings.persona },
            lang: settings.lang,
            messages: chat.messages.slice(-40).map((m) => ({ role: m.role, text: m.text })),
          }),
          signal: controller.signal,
        });
        if (!res.ok || !res.body) {
          let code = "provider_error";
          try {
            code = (await res.json()).error || code;
          } catch {}
          throw Object.assign(new Error(code), { code });
        }
        const reader = res.body.pipeThrough(new TextDecoderStream()).getReader();
        while (true) {
          const { value, done } = await reader.read();
          if (done) break;
          text += value;
          const nul = text.indexOf("\u0000");
          if (nul >= 0) {
            error = text.slice(nul + 1).trim() || "provider_error";
            text = text.slice(0, nul);
            break;
          }
          b.innerHTML = fmt(text);
          const nearBottom = msgsEl.scrollHeight - msgsEl.scrollTop - msgsEl.clientHeight < 140;
          if (nearBottom) msgsEl.scrollTop = msgsEl.scrollHeight;
        }
      } catch (e) {
        if (e.name !== "AbortError") error = e.code || "network";
      }

      streaming = null;
      if (!document.body.contains(msgsEl)) {
        // Left the chat while it was replying: keep whatever arrived.
        if (text.trim() && chats[c.id]) {
          chats[c.id].messages.push({ role: "char", text: text.trim(), ts: Date.now() });
          saveChats();
        }
        return;
      }
      setBusy(false);
      if (text.trim()) {
        chat.messages.push({ role: "char", text: text.trim(), ts: Date.now() });
        chat.updated = Date.now();
        saveChats();
        draw();
      } else {
        wrap.remove();
      }
      if (error && !text.trim()) {
        const err = document.createElement("div");
        err.innerHTML = `<div class="msg char">${avatar(c, 32)}<div class="bubble error">${esc(I18N[settings.lang]["err_" + error] ? tr("err_" + error) : tr("err_provider_error"))}</div></div>
          <div class="msg-tools"><button data-act="retry">${icon("refresh")}${tr("retry")}</button></div>`;
        msgsEl.appendChild(err);
        msgsEl.scrollTop = msgsEl.scrollHeight;
      }
    }

    $("#composer").addEventListener("submit", (e) => {
      e.preventDefault();
      if (streaming) {
        streaming.controller.abort();
        return;
      }
      const text = input.value.trim();
      if (!text) return;
      chat.messages.push({ role: "user", text, ts: Date.now() });
      chat.updated = Date.now();
      saveChats();
      input.value = "";
      autosize();
      draw();
      reply();
    });

    $("#view").addEventListener("click", async (e) => {
      const btn = e.target.closest("[data-act]");
      if (!btn) {
        if (!e.target.closest(".menu")) $(".menu")?.remove();
        return;
      }
      const act = btn.dataset.act;
      if (act !== "menu") $(".menu")?.remove();
      if (act === "profile") openSheet(c.id);
      else if (act === "star") {
        const s = input.selectionStart, en = input.selectionEnd, v = input.value;
        input.value = v.slice(0, s) + "*" + v.slice(s, en) + "*" + v.slice(en);
        input.focus();
        input.setSelectionRange(s + 1, en + 1);
      } else if (act === "scene") {
        drawScene(+btn.dataset.i);
      } else if (act === "view") {
        viewScene(+btn.dataset.i);
      } else if (act === "copy") {
        const i = +btn.dataset.i;
        const t = i < 0 ? chat.greeting : chat.messages[i]?.text;
        try {
          await navigator.clipboard.writeText(t);
          toast(tr("copied"));
        } catch {}
      } else if (act === "regen") {
        if (streaming) return;
        if (chat.messages.at(-1)?.role === "char") chat.messages.pop();
        saveChats();
        draw();
        if (chat.messages.length) reply();
      } else if (act === "retry") {
        if (streaming) return;
        draw();
        if (chat.messages.at(-1)?.role === "user") reply();
      } else if (act === "menu") {
        if ($(".menu")) return $(".menu").remove();
        const m = document.createElement("div");
        m.className = "menu";
        m.setAttribute("role", "menu");
        m.innerHTML = `
          <button role="menuitem" data-act="profile">${icon("info")}${tr("profile")}</button>
          <button role="menuitem" data-act="new">${icon("sparkle")}${tr("newChat")}</button>
          <button role="menuitem" class="danger" data-act="delete">${icon("trash")}${tr("deleteChat")}</button>`;
        $(".chat").style.position = "relative";
        $(".chat").appendChild(m);
      } else if (act === "new") {
        if (!confirm(tr("confirmNew"))) return;
        streaming?.controller.abort();
        delete chats[c.id];
        saveChats();
        viewChat(c.id);
      } else if (act === "delete") {
        if (!confirm(tr("confirmDelete"))) return;
        streaming?.controller.abort();
        delete chats[c.id];
        saveChats();
        location.hash = "#/chats";
      }
    });

    // A chat that ends with an unanswered message (e.g. the page was closed mid-reply) can be retried.
    if (chat.messages.at(-1)?.role === "user") {
      const err = document.createElement("div");
      err.innerHTML = `<div class="msg-tools" style="padding-inline-start:0;justify-content:center"><button data-act="retry">${icon("refresh")}${tr("retry")}</button></div>`;
      msgsEl.appendChild(err);
    }
    if (matchMedia("(hover: hover)").matches) input.focus();
  }

  // ---------------------------------------------------------------- chats list
  function viewChats() {
    const rows = Object.entries(chats)
      .map(([id, ch]) => ({ c: findChar(id), ch }))
      .filter((r) => r.c && r.ch.messages.length)
      .sort((a, b) => b.ch.updated - a.ch.updated);

    $("#view").innerHTML = `
      <div class="page">
        <div class="topbar"><h1>${tr("chats")}</h1></div>
        ${rows.length ? `<div class="list">${rows.map(({ c, ch }) => {
          const last = ch.messages.at(-1);
          const preview = (last.role === "user" ? "↩ " : "") + last.text.replace(/\*/g, "");
          return `<a class="row-item" href="#/chat/${esc(c.id)}">
              ${avatar(c, 52)}
              <span class="mid"><b>${esc(loc(c.name))}</b><span class="last">${esc(preview)}</span></span>
              <time>${ago(ch.updated)}</time>
            </a>`;
        }).join("")}</div>` : `<div class="empty"><div class="em">💬</div><b>${tr("noChats")}</b><div>${tr("noChatsHint")}</div><a class="btn" href="#/">${tr("explore")}</a></div>`}
      </div>`;
  }

  // ---------------------------------------------------------------- create / edit
  const EMOJIS = ["🙂", "😎", "🥰", "🤓", "😈", "🧙", "🧛", "🧜‍♀️", "🦊", "🐱", "🐺", "🦄", "🐉", "🤖", "👽", "👻", "🥷", "🧑‍🚀", "👑", "🌹", "🌙", "🔥", "🎮", "🎧", "☕", "📚", "⚽", "🎨"];

  function viewCreate(editId) {
    const existing = editId ? custom.find((c) => c.id === editId) : null;
    if (editId && !existing) return viewMissing();
    const d = existing
      ? structuredClone(existing)
      : { avatar: { emoji: "🙂", hue: Math.floor(Math.random() * 360) }, portrait: window.Portrait.random(), category: "friend", name: "", tagline: "", personality: "", scenario: "", greeting: "" };

    const P = window.Portrait;
    const LOOK = I18N[settings.lang].look;
    const lookSelect = (key, label, options) => `
      <label class="field small"><span>${label}</span>
        <select data-p="${key}">${options.map((v) => `<option value="${v}">${esc(LOOK[v] ?? v)}</option>`).join("")}</select></label>`;
    const swatches = (key, label, colors) => `
      <div class="look-row"><span>${label}</span><div class="swatches" data-sw="${key}">${colors.map((c) => `<button type="button" data-c="${c}" style="background:${c}" aria-label="${c}"></button>`).join("")}</div></div>`;
    const field = (key, label, ph, { area = false, max = 200, hint = "" } = {}) => `
      <div class="field">
        <label for="f-${key}">${label} <span class="counter" data-for="${key}">${(d[key] || "").length}/${max}</span></label>
        ${area
          ? `<textarea id="f-${key}" name="${key}" maxlength="${max}" placeholder="${esc(ph)}">${esc(d[key])}</textarea>`
          : `<input type="text" id="f-${key}" name="${key}" maxlength="${max}" placeholder="${esc(ph)}" value="${esc(d[key])}">`}
        ${hint ? `<div class="hint">${hint}</div>` : ""}
      </div>`;

    $("#view").innerHTML = `
      <div class="page">
        <div class="topbar"><h1>${existing ? tr("editTitle") : tr("createTitle")}</h1></div>
        <form class="form" id="cform" novalidate>
          <div class="field">
            <label>${tr("avatar")}</label>
            <div class="avatar-pick">
              <span id="av-preview"></span>
              <div style="flex:1;min-width:220px">
                <div class="seg" id="av-mode">
                  <button type="button" data-mode="anime">✨ ${tr("anime")}</button>
                  <button type="button" data-mode="emoji">🙂 ${tr("emoji")}</button>
                  <label class="seg-upload" data-mode="photo">📷 ${tr("photo")}<input type="file" id="file" accept="image/*"></label>
                </div>
              </div>
            </div>
            <div id="av-anime" class="look">
              <button type="button" class="btn ghost" id="dice">🎲 ${tr("randomLook")}</button>
              <div class="look-grid">
                ${lookSelect("hairStyle", tr("hairStyle"), P.STYLES)}
                ${lookSelect("expression", tr("expression"), P.EXPRESSIONS)}
                ${lookSelect("outfitStyle", tr("outfitStyle"), P.OUTFITS)}
                ${lookSelect("accessory", tr("accessory"), P.ACCESSORIES)}
              </div>
              ${swatches("hair", tr("hairColor"), P.HAIRS)}
              ${swatches("eyes", tr("eyeColor"), P.EYES)}
              ${swatches("skin", tr("skinColor"), P.SKINS)}
              <div class="look-row"><span>${tr("outfitColor")}</span><input type="color" data-p="outfit" aria-label="${tr("outfitColor")}"></div>
              <div class="look-row"><span>${tr("background")}</span><input class="hue" type="range" min="0" max="359" data-p="bg" aria-label="${tr("background")}"></div>
            </div>
            <div id="av-emoji">
              <div class="emoji-row" id="emojis">${EMOJIS.map((e) => `<button type="button" data-emoji="${e}" aria-label="${e}">${e}</button>`).join("")}</div>
              <input class="hue" id="hue" type="range" min="0" max="359" value="${d.avatar?.hue ?? 260}" aria-label="color">
            </div>
          </div>
          ${field("name", tr("name"), tr("namePh"), { max: 40 })}
          ${field("tagline", tr("tagline"), tr("taglinePh"), { max: 120 })}
          ${field("personality", tr("personality"), tr("personalityPh"), { area: true, max: 2500, hint: tr("personalityHint") })}
          ${field("scenario", tr("scenario"), tr("scenarioPh"), { area: true, max: 1000 })}
          ${field("greeting", tr("greeting"), tr("greetingPh"), { area: true, max: 1000 })}
          <div class="field">
            <label for="f-category">${tr("category")}</label>
            <select id="f-category" name="category">
              ${window.CATEGORIES.filter((k) => k.id !== "all").map((k) => `<option value="${k.id}" ${d.category === k.id ? "selected" : ""}>${k.icon} ${esc(k[settings.lang])}</option>`).join("")}
            </select>
          </div>
          <button class="btn block" type="submit">${tr("save")}</button>
          ${existing ? `<button class="btn danger block" type="button" id="del">${icon("trash")}${tr("deleteChar")}</button>` : ""}
        </form>
      </div>`;

    const mode = () => (d.avatar.image ? "photo" : d.portrait ? "anime" : "emoji");
    const drawAvatar = () => {
      $("#av-preview").innerHTML = avatar(d, 120);
      const m = mode();
      document.querySelectorAll("#av-mode [data-mode]").forEach((b) => b.classList.toggle("on", b.dataset.mode === m));
      $("#av-anime").hidden = m !== "anime";
      $("#av-emoji").hidden = m !== "emoji";
      document.querySelectorAll("#emojis button").forEach((b) => b.classList.toggle("on", b.dataset.emoji === d.avatar.emoji));
      if (d.portrait) {
        const p = P.normalize(d.portrait);
        document.querySelectorAll("#av-anime [data-p]").forEach((el) => (el.value = p[el.dataset.p]));
        document.querySelectorAll("[data-sw]").forEach((row) =>
          row.querySelectorAll("button").forEach((b) => b.classList.toggle("on", b.dataset.c.toLowerCase() === String(p[row.dataset.sw]).toLowerCase())),
        );
      }
    };
    drawAvatar();

    let lastPortrait = d.portrait || P.random();
    $("#av-mode").addEventListener("click", (e) => {
      const b = e.target.closest("button[data-mode]");
      if (!b) return;
      delete d.avatar.image;
      if (b.dataset.mode === "anime") d.portrait = d.portrait || lastPortrait;
      else {
        if (d.portrait) lastPortrait = d.portrait;
        delete d.portrait;
      }
      drawAvatar();
    });
    $("#dice").addEventListener("click", () => {
      d.portrait = P.random();
      drawAvatar();
    });
    $("#av-anime").addEventListener("input", (e) => {
      const k = e.target.dataset.p;
      if (!k) return;
      d.portrait = { ...P.normalize(d.portrait), [k]: k === "bg" ? +e.target.value : e.target.value };
      drawAvatar();
    });
    $("#av-anime").addEventListener("click", (e) => {
      const b = e.target.closest("[data-c]");
      if (!b) return;
      d.portrait = { ...P.normalize(d.portrait), [b.parentElement.dataset.sw]: b.dataset.c };
      drawAvatar();
    });

    $("#emojis").addEventListener("click", (e) => {
      const b = e.target.closest("[data-emoji]");
      if (!b) return;
      d.avatar.emoji = b.dataset.emoji;
      drawAvatar();
    });
    $("#hue").addEventListener("input", (e) => {
      d.avatar.hue = +e.target.value;
      drawAvatar();
    });
    $("#file").addEventListener("change", async (e) => {
      const f = e.target.files?.[0];
      if (!f) return;
      try {
        d.avatar.image = await shrinkImage(f, 384);
        drawAvatar();
      } catch {
        toast(tr("err_provider_error"));
      }
    });
    $("#cform").addEventListener("input", (e) => {
      const el = e.target;
      if (!el.name) return;
      d[el.name] = el.value;
      const ctr = document.querySelector(`.counter[data-for="${el.name}"]`);
      if (ctr) ctr.textContent = `${el.value.length}/${el.maxLength}`;
    });
    $("#cform").addEventListener("submit", (e) => {
      e.preventDefault();
      d.category = $("#f-category").value;
      for (const k of ["name", "tagline", "personality", "scenario", "greeting"]) d[k] = (d[k] || "").trim();
      if (!d.name || !d.personality) {
        toast(tr("required"));
        (d.name ? $("#f-personality") : $("#f-name")).focus();
        return;
      }
      d.custom = true;
      if (!d.greeting) d.greeting = settings.lang === "ar" ? `*يبتسم* هلا! أنا ${d.name}.` : `*smiles* Hi! I'm ${d.name}.`;
      if (existing) {
        custom = custom.map((c) => (c.id === existing.id ? d : c));
      } else {
        d.id = uid();
        custom.unshift(d);
      }
      if (!saveCustom()) return;
      toast(tr("saved"));
      location.hash = "#/chat/" + d.id;
    });
    $("#del")?.addEventListener("click", () => {
      if (!confirm(tr("confirmDeleteChar"))) return;
      custom = custom.filter((c) => c.id !== existing.id);
      delete chats[existing.id];
      saveCustom();
      saveChats();
      location.hash = "#/";
    });
  }

  function shrinkImage(file, max) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      const url = URL.createObjectURL(file);
      img.onload = () => {
        const s = Math.min(img.width, img.height);
        const size = Math.min(max, s);
        const cv = document.createElement("canvas");
        cv.width = cv.height = size;
        // Centre-crop to a square.
        cv.getContext("2d").drawImage(img, (img.width - s) / 2, (img.height - s) / 2, s, s, 0, 0, size, size);
        URL.revokeObjectURL(url);
        resolve(cv.toDataURL("image/jpeg", 0.82));
      };
      img.onerror = () => {
        URL.revokeObjectURL(url);
        reject(new Error("bad image"));
      };
      img.src = url;
    });
  }

  // ---------------------------------------------------------------- settings
  function viewMe() {
    $("#view").innerHTML = `
      <div class="page">
        <div class="topbar"><h1>${tr("settingsTitle")}</h1></div>
        <div class="settings">
          <label class="set-row"><span>${tr("yourName")}</span><input type="text" id="persona" maxlength="40" placeholder="${tr("yourNamePh")}" value="${esc(settings.persona)}"></label>
          <div class="set-row"><span>${tr("language")}</span>
            <div class="seg" data-set="lang"><button data-v="ar" class="${settings.lang === "ar" ? "on" : ""}">العربية</button><button data-v="en" class="${settings.lang === "en" ? "on" : ""}">English</button></div></div>
          <div class="set-row"><span>${tr("theme")}</span>
            <div class="seg" data-set="theme"><button data-v="dark" class="${settings.theme === "dark" ? "on" : ""}">${tr("dark")}</button><button data-v="light" class="${settings.theme === "light" ? "on" : ""}">${tr("light")}</button></div></div>
          <p class="muted" style="font-size:13px;margin:4px 4px 8px">${tr("localNote")}</p>
          <button class="btn danger" id="clear">${icon("trash")}${tr("clearAll")}</button>
        </div>
      </div>`;
    $("#persona").addEventListener("change", (e) => {
      settings.persona = e.target.value.trim();
      saveSettings();
      toast(tr("saved"));
    });
    document.querySelectorAll("[data-set] button").forEach((b) =>
      b.addEventListener("click", () => {
        settings[b.parentElement.dataset.set] = b.dataset.v;
        saveSettings();
        applyShell();
        route();
      }),
    );
    $("#clear").addEventListener("click", () => {
      if (!confirm(tr("confirmClear"))) return;
      custom = [];
      chats = {};
      saveCustom();
      saveChats();
      toast(tr("cleared"));
    });
  }

  function viewMissing() {
    $("#view").innerHTML = `<div class="page"><div class="empty"><div class="em">🫥</div><b>${tr("notFound")}</b><br><a class="btn" href="#/">${tr("explore")}</a></div></div>`;
  }

  // ---------------------------------------------------------------- router
  function route() {
    const old = $("#view");
    const fresh = old.cloneNode(false); // drop listeners from the previous view
    old.replaceWith(fresh);
    if (streaming) {
      // Keep streaming in the background is not worth the complexity; stop it.
      streaming.controller.abort();
      streaming = null;
    }
    document.body.classList.remove("in-chat");
    closeSheet();

    const parts = location.hash.replace(/^#\/?/, "").split("/");
    const [page, arg] = [parts[0] || "", decodeURIComponent(parts[1] || "")];
    const nav = { "": "discover", chat: "chats", chats: "chats", create: "create", me: "me" }[page] ?? "discover";
    renderNav(nav);
    if (page === "chat" && arg) viewChat(arg);
    else if (page === "chats") viewChats();
    else if (page === "create") viewCreate(arg || null);
    else if (page === "me") viewMe();
    else viewDiscover();
    window.scrollTo(0, 0);
  }

  window.addEventListener("hashchange", route);
  window.addEventListener("storage", (e) => {
    if (!e.key?.startsWith("rafiq.")) return;
    custom = store.get("custom", []);
    chats = store.get("chats", {});
  });
  applyShell();
  route();
})();
