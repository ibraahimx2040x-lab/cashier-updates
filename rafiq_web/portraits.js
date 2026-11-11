// Anime-style portraits drawn as SVG. Every character (built-in or made by a
// visitor) is described by a small set of options, so no image files are needed.
(() => {
  "use strict";

  // ------------------------------------------------------------ colour helpers
  const hex2rgb = (h) => {
    const n = parseInt(h.slice(1), 16);
    return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
  };
  const rgb2hex = (r, g, b) => "#" + [r, g, b].map((v) => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, "0")).join("");
  /** amt < 0 darkens towards black, amt > 0 lightens towards white. */
  const shade = (h, amt) => {
    const [r, g, b] = hex2rgb(h);
    const t = amt < 0 ? 0 : 255, p = Math.abs(amt);
    return rgb2hex(r + (t - r) * p, g + (t - g) * p, b + (t - b) * p);
  };

  const SKINS = ["#ffe6d6", "#f8d3b8", "#eebd98", "#d39a72", "#a8704d", "#7a4a33"];
  const HAIRS = ["#2a2230", "#4a3226", "#7a4a2a", "#c98b4f", "#f1d38a", "#e9e4ef", "#b3b9c9", "#d9475f", "#ff8fb8", "#8f6cff", "#3f7cff", "#2fbf9a", "#4caf50"];
  const EYES = ["#6b3f2a", "#3a6ea5", "#2f9e6e", "#8a5cf6", "#d94a6a", "#d99a2b", "#22b8d6", "#c0392b", "#555c70"];
  const STYLES = ["short", "spiky", "long", "bob", "ponytail", "hijab", "bald"];
  const OUTFITS = ["shirt", "hoodie", "coat", "kimono", "dress", "jacket"];
  const ACCESSORIES = ["none", "glasses", "headband", "hairclip", "fedora", "pirate", "horns", "headset", "flower", "strawhat", "ninjaband", "blindfold", "scarf", "cap"];
  const EXPRESSIONS = ["smile", "grin", "calm", "stern", "shy", "happy", "cat"];

  // ------------------------------------------------------------ geometry
  const FACE = "M66,88 C66,56 134,56 134,88 C134,105 131,115 124,123 C116,132 107,138 100,139 C93,138 84,132 76,123 C69,115 66,105 66,88 Z";

  /** Bang line from the right side back to the left: tips hang down, valleys go up. */
  function bangLine(pts) {
    let d = "";
    for (let i = 1; i < pts.length; i++) {
      const [px, py] = pts[i - 1], [qx, qy] = pts[i];
      const cx = px + (qx - px) * 0.25, cy = py + (qy - py) * 0.85;
      d += ` Q${cx.toFixed(1)},${cy.toFixed(1)} ${qx},${qy}`;
    }
    return d;
  }

  const CAP = "M58,102 C50,60 68,33 100,31 C132,33 150,60 142,102";
  const SPIKY_CAP = "M58,102 C54,82 50,72 38,60 C52,58 56,52 54,34 C66,42 74,40 80,18 C88,32 94,34 102,12 C108,30 114,32 124,16 C126,34 132,40 150,34 C146,48 148,56 162,62 C150,70 146,80 142,102";

  const BANGS = {
    short: [[142, 102], [137, 106], [134, 80], [128, 94], [121, 72], [112, 92], [104, 70], [95, 93], [88, 73], [79, 91], [72, 76], [66, 92], [63, 106], [58, 102]],
    spiky: [[142, 102], [139, 110], [135, 78], [129, 98], [121, 70], [113, 96], [104, 66], [95, 97], [87, 70], [78, 95], [70, 74], [65, 98], [61, 110], [58, 102]],
    soft: [[142, 102], [139, 114], [134, 80], [125, 97], [117, 70], [108, 95], [101, 68], [92, 90], [84, 70], [76, 89], [70, 75], [64, 98], [61, 114], [58, 102]],
  };

  const front = (style) => {
    if (style === "spiky") return SPIKY_CAP + bangLine(BANGS.spiky) + " Z";
    if (style === "short") return CAP + bangLine(BANGS.short) + " Z";
    return CAP + bangLine(BANGS.soft) + " Z";
  };

  const BACK = {
    short: "M60,96 C58,112 64,124 72,128 L128,128 C136,124 142,112 140,96 Z",
    spiky: "M60,96 C56,114 60,126 70,132 L130,132 C140,126 144,114 140,96 Z",
    long: "M60,66 C46,110 52,160 40,196 L160,196 C148,160 154,110 140,66 Z",
    bob: "M60,66 C50,98 52,128 56,142 C70,146 130,146 144,142 C148,128 150,98 140,66 Z",
    ponytail: "M60,96 C58,112 64,124 72,128 L128,128 C136,124 142,112 140,96 Z M120,46 C162,44 174,96 166,146 C162,170 154,182 148,190 C152,150 150,104 124,72 Z",
  };

  const SIDE_LOCKS = {
    long: "M61,92 C56,124 60,152 52,182 L64,178 C70,148 70,118 68,96 Z M139,92 C144,124 140,152 148,182 L136,178 C130,148 130,118 132,96 Z",
    bob: "M60,92 C57,116 57,132 62,144 L74,141 C70,122 70,106 68,96 Z M140,92 C143,116 143,132 138,144 L126,141 C130,122 130,106 132,96 Z",
  };

  // ------------------------------------------------------------ parts
  function eye(cx, cy, o, side, id) {
    const lash = shade(o.hair, -0.55) === o.hair ? "#1d1626" : "#241a2c";
    if (o.expression === "happy") {
      return `<path d="M${cx - 9},${cy + 3} Q${cx},${cy - 7} ${cx + 9},${cy + 3}" fill="none" stroke="${lash}" stroke-width="3.2" stroke-linecap="round"/>`;
    }
    const lid = o.expression === "calm" ? 6 : o.expression === "stern" ? 3.5 : o.expression === "shy" ? 2 : 0;
    const top = cy - 11 + lid;
    const iris = o.eyes;
    const glow = o.accessory === "headset";
    const outer = side === "L" ? -1 : 1;
    return `
      <clipPath id="${id}"><path d="M${cx - 11},${cy} Q${cx - 11},${top} ${cx},${top} Q${cx + 11},${top} ${cx + 11},${cy} Q${cx + 10},${cy + 12} ${cx},${cy + 12} Q${cx - 10},${cy + 12} ${cx - 11},${cy} Z"/></clipPath>
      <g clip-path="url(#${id})">
        <rect x="${cx - 12}" y="${cy - 14}" width="24" height="28" fill="#fff"/>
        <ellipse cx="${cx}" cy="${cy + 2}" rx="7.6" ry="9.6" fill="url(#iris)"/>
        <ellipse cx="${cx}" cy="${cy + 1.5}" rx="3.4" ry="${glow ? 3.4 : 5}" fill="${glow ? "#e9fdff" : shade(iris, -0.72)}"/>
        ${glow ? `<circle cx="${cx}" cy="${cy + 2}" r="6" fill="none" stroke="#e9fdff" stroke-width=".8" opacity=".8"/>` : ""}
        <rect x="${cx - 12}" y="${top - 2}" width="24" height="4" fill="${shade(o.skin, -0.18)}" opacity=".35"/>
        <circle cx="${cx - 3}" cy="${cy - 2 + lid * 0.5}" r="2.7" fill="#fff"/>
        <circle cx="${cx + 3.2}" cy="${cy + 5.5}" r="1.3" fill="#fff" opacity=".85"/>
      </g>
      <path d="M${cx - 12.5},${cy + 1} Q${cx - 11},${top - 1.5} ${cx},${top - 1.5} Q${cx + 11},${top - 1.5} ${cx + 12.5},${cy + 1} L${cx + 11},${cy + 1} Q${cx + 9},${top + 1.6} ${cx},${top + 1.6} Q${cx - 9},${top + 1.6} ${cx - 11},${cy + 1} Z" fill="${lash}"/>
      <path d="M${cx + outer * 11},${cy - 1} L${cx + outer * 15},${cy - 4.5} L${cx + outer * 12},${cy + 2} Z" fill="${lash}"/>
      <path d="M${cx - 7},${cy + 12.4} Q${cx},${cy + 13.6} ${cx + 7},${cy + 12.4}" fill="none" stroke="${lash}" stroke-width="1" opacity=".45" stroke-linecap="round"/>`;
  }

  function brows(o) {
    const c = shade(o.hair, -0.35);
    const set = {
      stern: [[74, 82, 93, 87], [107, 87, 126, 82]],
      shy: [[74, 84, 93, 81], [107, 81, 126, 84]],
      calm: [[74, 84, 93, 83], [107, 83, 126, 84]],
    }[o.expression] ?? [[74, 82, 93, 81], [107, 81, 126, 82]];
    return set.map(([x1, y1, x2, y2]) => `<path d="M${x1},${y1} Q${(x1 + x2) / 2},${Math.min(y1, y2) - 2.5} ${x2},${y2}" fill="none" stroke="${c}" stroke-width="2.6" stroke-linecap="round"/>`).join("");
  }

  function mouth(o) {
    const lip = "#b4555a";
    switch (o.expression) {
      case "grin":
        return `<path d="M90,119 Q100,134 110,119 Z" fill="#7d2633"/><path d="M93,124 Q100,131 107,124 Q100,127 93,124 Z" fill="#ff8e9e"/><path d="M90.5,119.2 L109.5,119.2 L108,122 L92,122 Z" fill="#fff"/>`;
      case "calm":
      case "stern":
        return `<path d="M95,123 Q100,${o.expression === "stern" ? 121.5 : 124} 105,123" fill="none" stroke="${lip}" stroke-width="1.9" stroke-linecap="round"/>`;
      case "shy":
        return `<path d="M96,123 Q100,125.5 104,123" fill="none" stroke="${lip}" stroke-width="1.9" stroke-linecap="round"/>`;
      case "cat":
        return `<path d="M92,121 Q96,125.5 100,121 Q104,125.5 108,121" fill="none" stroke="${lip}" stroke-width="1.9" stroke-linecap="round"/><path d="M103.5,123 L105,127 L106.5,122.6 Z" fill="#fff"/>`;
      case "happy":
        return `<path d="M91,119 Q100,131 109,119 Q100,123 91,119 Z" fill="#7d2633"/><path d="M95,124.5 Q100,128.5 105,124.5 Q100,126 95,124.5 Z" fill="#ff8e9e"/>`;
      default:
        return `<path d="M92,121 Q100,128 108,121" fill="none" stroke="${lip}" stroke-width="2" stroke-linecap="round"/>`;
    }
  }

  function body(o) {
    const c = o.outfit, d = shade(c, -0.25), l = shade(c, 0.35);
    const base = `<path d="M18,200 C22,166 52,151 78,147 L122,147 C148,151 178,166 182,200 Z" fill="${c}"/>`;
    const neck = `<path d="M86,118 L86,150 C92,157 108,157 114,150 L114,118 Z" fill="${o.skin}"/><path d="M86,124 C94,138 106,138 114,124 L114,118 L86,118 Z" fill="${shade(o.skin, -0.14)}"/>`;
    let extra = "";
    switch (o.outfitStyle) {
      case "hoodie":
        extra = `<path d="M66,152 C76,172 124,172 134,152 C126,144 74,144 66,152 Z" fill="${d}"/><path d="M93,166 L91,186 M107,166 L109,186" stroke="${l}" stroke-width="2.4" stroke-linecap="round"/>`;
        break;
      case "coat":
        extra = `<path d="M88,148 L100,200 L112,148 Z" fill="#f4f1f8"/><path d="M97,158 L100,153 L103,158 L101.5,184 L100,188 L98.5,184 Z" fill="#7b1e2b"/><path d="M78,147 L100,200 L82,200 L70,160 L86,150 Z" fill="${d}"/><path d="M122,147 L100,200 L118,200 L130,160 L114,150 Z" fill="${d}"/>`;
        break;
      case "kimono":
        extra = `<path d="M84,147 L114,200 L124,200 L94,147 Z" fill="#f2eef6"/><path d="M116,147 L86,200 L76,200 L106,147 Z" fill="${d}"/><path d="M109,147 L80,200" stroke="${l}" stroke-width="1.5" opacity=".6"/>`;
        break;
      case "dress":
        extra = `<path d="M80,148 C88,168 112,168 120,148 Z" fill="${o.skin}"/><path d="M80,148 C88,168 112,168 120,148" fill="none" stroke="${l}" stroke-width="3"/><circle cx="100" cy="166" r="3" fill="${l}"/>`;
        break;
      case "jacket":
        extra = `<path d="M88,148 L100,176 L112,148 Z" fill="#20192b"/><path d="M80,147 L100,178 L94,200 L86,200 L72,158 Z" fill="${d}"/><path d="M120,147 L100,178 L106,200 L114,200 L128,158 Z" fill="${d}"/><path d="M80,147 L100,178 L120,147" fill="none" stroke="#e7c35a" stroke-width="2"/><circle cx="84" cy="186" r="2.2" fill="#e7c35a"/><circle cx="116" cy="186" r="2.2" fill="#e7c35a"/>`;
        break;
      default: // shirt
        extra = `<path d="M90,147 L100,166 L110,147 Z" fill="${o.skin}"/><path d="M80,146 L100,168 L92,146 Z M120,146 L100,168 L108,146 Z" fill="${l}"/>`;
    }
    return (o.hairStyle === "hijab" ? "" : neck) + base + extra;
  }

  function hijab(o) {
    const c = o.hair, d = shade(c, -0.2);
    const outer = `<path d="M54,100 C48,50 72,30 100,30 C128,30 152,50 146,100 C146,120 150,140 160,160 C170,175 176,190 178,200 L22,200 C24,190 30,175 40,160 C50,140 54,120 54,100 Z" fill="${c}"/>
      <path d="M78,134 Q100,156 122,134" fill="none" stroke="${d}" stroke-width="2.4"/><path d="M60,150 Q100,182 140,150" fill="none" stroke="${d}" stroke-width="2" opacity=".6"/>`;
    const band = `<path d="M63,86 C64,54 136,54 137,86 C130,66 70,66 63,86 Z" fill="${d}"/><path d="M68,64 Q100,46 132,64" fill="none" stroke="${shade(c, 0.3)}" stroke-width="3" opacity=".5" stroke-linecap="round"/>`;
    return { outer, band };
  }

  function accessory(o, layer) {
    const a = o.accessory;
    if (layer === "neck") {
      if (a === "scarf") {
        return `<path d="M70,140 C80,156 120,156 130,140 L136,150 C122,170 78,170 64,150 Z" fill="#c4202f"/><path d="M110,156 L120,192 L106,194 L100,160 Z" fill="#a51a27"/><path d="M72,148 C84,160 116,160 128,148" fill="none" stroke="#8f1520" stroke-width="1.5" opacity=".7"/>`;
      }
      return "";
    }
    if (layer === "back") {
      if (a === "horns") {
        const h = "#f3e6c8", s = "#c9a96a";
        return `<path d="M76,46 C66,34 64,20 70,6 C74,22 82,32 88,40 Z" fill="${h}" stroke="${s}" stroke-width="1.5"/><path d="M124,46 C134,34 136,20 130,6 C126,22 118,32 112,40 Z" fill="${h}" stroke="${s}" stroke-width="1.5"/>`;
      }
      return "";
    }
    switch (a) {
      case "cap":
        return `<path d="M64,66 C62,30 138,30 136,66 Z" fill="#d6283a"/><path d="M86,38 Q100,33 114,38 L116,64 L84,64 Z" fill="#f4f1f8"/><path d="M93,46 Q100,42 107,46 L106,56 Q100,58 94,56 Z" fill="#2fa36b"/><ellipse cx="100" cy="66" rx="44" ry="7" fill="#b51f30"/><path d="M60,64 Q100,58 140,64" fill="none" stroke="#8f1520" stroke-width="1.5"/>`;
      case "strawhat":
        return `<ellipse cx="100" cy="62" rx="66" ry="13" fill="#e8c56a"/><ellipse cx="100" cy="62" rx="66" ry="13" fill="none" stroke="#c9a24a" stroke-width="1.5"/><path d="M68,62 C68,30 132,30 132,62 Z" fill="#f0d27c"/><path d="M68,54 C90,58 110,58 132,54 L132,62 C110,66 90,66 68,62 Z" fill="#d6283a"/><path d="M80,40 Q100,34 120,40" fill="none" stroke="#c9a24a" stroke-width="1.5" opacity=".7"/>`;
      case "ninjaband":
        return `<path d="M58,70 C80,60 120,60 142,70 L142,82 C120,72 80,72 58,82 Z" fill="#23356b"/><rect x="82" y="64" width="36" height="14" rx="3" fill="#cfd6e2" stroke="#8d97a8" stroke-width="1.2"/><circle cx="86" cy="71" r="1.2" fill="#8d97a8"/><circle cx="114" cy="71" r="1.2" fill="#8d97a8"/><path d="M95,71 Q100,66 105,71 Q100,75 95,71 Z" fill="none" stroke="#8d97a8" stroke-width="1.2"/><path d="M142,72 L156,88 L150,90 M142,76 L152,96" stroke="#23356b" stroke-width="4" stroke-linecap="round"/>`;
      case "blindfold":
        return `<path d="M62,88 C80,84 120,84 138,88 L138,108 C120,104 80,104 62,108 Z" fill="#15121c"/><path d="M66,92 C84,88 116,88 134,92" fill="none" stroke="#3a3346" stroke-width="1.5"/>`;
      case "glasses":
        return `<g fill="none" stroke="#2b2337" stroke-width="2.2"><rect x="70" y="88" width="28" height="22" rx="8"/><rect x="102" y="88" width="28" height="22" rx="8"/><path d="M98,97 Q100,95 102,97 M70,96 L64,94 M130,96 L136,94"/></g><path d="M74,92 L80,92" stroke="#fff" stroke-width="2" opacity=".7" stroke-linecap="round"/>`;
      case "headband":
        return `<path d="M60,74 C80,62 120,62 140,74 L140,83 C120,71 80,71 60,83 Z" fill="#e8384f"/><path d="M60,78 C80,66 120,66 140,78" fill="none" stroke="#fff" stroke-width="1.6" opacity=".8"/>`;
      case "hairclip":
        return `<path d="M120,66 L132,62 L130,68 Z" fill="#ffd166"/><circle cx="128" cy="64" r="4.5" fill="#ff6b9a"/><circle cx="127" cy="63" r="1.5" fill="#fff"/>`;
      case "flower":
        return `<g transform="translate(130 64)">${[0, 72, 144, 216, 288].map((r) => `<ellipse rx="4" ry="7" cy="-6" fill="#ff9ec4" transform="rotate(${r})"/>`).join("")}<circle r="3.5" fill="#ffd166"/></g>`;
      case "fedora":
        return `<ellipse cx="100" cy="60" rx="62" ry="11" fill="#3b3140"/><path d="M68,60 C66,26 134,26 132,60 Z" fill="#4a3f50"/><path d="M68,52 C90,56 110,56 132,52 L132,60 C110,64 90,64 68,60 Z" fill="#7b1e2b"/><path d="M84,36 Q100,30 116,36" fill="none" stroke="#5c5063" stroke-width="2.5"/>`;
      case "pirate":
        return `<path d="M34,64 C56,38 80,52 100,36 C120,52 144,38 166,64 C154,60 142,70 130,66 C120,78 80,78 70,66 C58,70 46,60 34,64 Z" fill="#2c2233"/><path d="M34,64 C46,60 58,70 70,66 C80,78 120,78 130,66 C142,70 154,60 166,64" fill="none" stroke="#e7c35a" stroke-width="2.5"/><circle cx="100" cy="56" r="6" fill="#f4efe6"/><circle cx="98" cy="55" r="1.4" fill="#2c2233"/><circle cx="102" cy="55" r="1.4" fill="#2c2233"/><path d="M92,64 L108,70 M108,64 L92,70" stroke="#f4efe6" stroke-width="2" stroke-linecap="round"/>`;
      case "headset":
        return `<path d="M58,96 C52,36 148,36 142,96" fill="none" stroke="#d6dee9" stroke-width="5"/><rect x="51" y="86" width="14" height="24" rx="6" fill="#d6dee9"/><rect x="135" y="86" width="14" height="24" rx="6" fill="#d6dee9"/><rect x="138" y="92" width="8" height="12" rx="3" fill="#2fe3ff"/><path d="M58,108 C62,124 74,130 86,128" fill="none" stroke="#d6dee9" stroke-width="2.5"/><circle cx="87" cy="128" r="2.6" fill="#2fe3ff"/><path d="M126,114 L132,114 L134,118" fill="none" stroke="#2fe3ff" stroke-width="1.2" opacity=".8"/>`;
      default:
        return "";
    }
  }

  function sparkles(hue) {
    const star = (x, y, s, op) => `<path d="M${x},${y - s} Q${x},${y} ${x + s},${y} Q${x},${y} ${x},${y + s} Q${x},${y} ${x - s},${y} Q${x},${y} ${x},${y - s} Z" fill="#fff" opacity="${op}"/>`;
    return star(30, 40, 7, 0.55) + star(170, 30, 5, 0.45) + star(178, 110, 4, 0.35) + star(22, 120, 4, 0.3) +
      `<circle cx="160" cy="70" r="26" fill="hsl(${hue} 90% 85%)" opacity=".18"/><circle cx="36" cy="80" r="18" fill="hsl(${hue} 90% 85%)" opacity=".14"/>`;
  }

  // ------------------------------------------------------------ assemble
  function normalize(p = {}) {
    return {
      skin: p.skin || SKINS[1],
      hair: p.hair || HAIRS[1],
      eyes: p.eyes || EYES[0],
      hairStyle: STYLES.includes(p.hairStyle) ? p.hairStyle : "short",
      outfit: p.outfit || "#6c5ce7",
      outfitStyle: OUTFITS.includes(p.outfitStyle) ? p.outfitStyle : "shirt",
      accessory: ACCESSORIES.includes(p.accessory) ? p.accessory : "none",
      expression: EXPRESSIONS.includes(p.expression) ? p.expression : "smile",
      bg: Number.isFinite(p.bg) ? p.bg : 260,
      ghost: !!p.ghost,
      scar: !!p.scar,
    };
  }

  function svg(input) {
    const o = normalize(input);
    const hairD = shade(o.hair, -0.22);
    const skinS = shade(o.skin, -0.13);
    const isHijab = o.hairStyle === "hijab";
    const isBald = o.hairStyle === "bald";
    const hj = isHijab ? hijab(o) : null;
    const fr = isHijab || isBald ? "" : front(o.hairStyle);

    const character = `
      ${isHijab ? "" : BACK[o.hairStyle] ? `<path d="${BACK[o.hairStyle]}" fill="${hairD}"/>` : ""}
      ${accessory(o, "back")}
      ${body(o)}
      ${accessory(o, "neck")}
      ${isHijab ? hj.outer : ""}
      ${isBald ? `<ellipse cx="100" cy="84" rx="35" ry="46" fill="${o.skin}"/><ellipse cx="88" cy="52" rx="10" ry="5" fill="#fff" opacity=".35" transform="rotate(-20 88 52)"/>` : ""}
      ${isHijab ? "" : `<ellipse cx="66" cy="101" rx="5" ry="8" fill="${skinS}"/><ellipse cx="134" cy="101" rx="5" ry="8" fill="${skinS}"/>`}
      <path d="${FACE}" fill="${o.skin}"/>
      ${fr ? `<g clip-path="url(#face)"><path d="${fr}" transform="translate(0 6)" fill="${skinS}" opacity=".75"/></g>` : ""}
      <g filter="url(#soft)"><ellipse cx="78" cy="115" rx="7.5" ry="3.6" fill="#ff7b9c" opacity="${o.expression === "shy" ? 0.6 : 0.32}"/><ellipse cx="122" cy="115" rx="7.5" ry="3.6" fill="#ff7b9c" opacity="${o.expression === "shy" ? 0.6 : 0.32}"/></g>
      ${eye(84, 100, o, "L", "eL")}${eye(116, 100, o, "R", "eR")}
      ${brows(o)}
      <path d="M100.5,108 L98.8,112.3 L101.6,112.6" fill="none" stroke="${shade(o.skin, -0.3)}" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
      ${mouth(o)}
      ${o.scar ? `<path d="M118,112 L127,107 M120,115 L123,109" stroke="${shade(o.skin, -0.3)}" stroke-width="1.3" stroke-linecap="round"/>` : ""}
      ${SIDE_LOCKS[o.hairStyle] ? `<path d="${SIDE_LOCKS[o.hairStyle]}" fill="${o.hair}"/>` : ""}
      ${fr ? `<path d="${fr}" fill="${o.hair}"/><path d="M72,54 Q100,40 128,54" fill="none" stroke="${shade(o.hair, 0.45)}" stroke-width="4" opacity=".55" stroke-linecap="round"/><path d="M104,72 Q103,84 100,92 M86,76 Q84,86 82,90 M120,76 Q121,86 124,92" fill="none" stroke="${hairD}" stroke-width="1.3" opacity=".6"/>` : ""}
      ${isHijab ? hj.band : ""}
      ${accessory(o, "front")}`;

    const ghost = o.ghost
      ? `<g mask="url(#fade)" opacity=".82">${character}</g><rect width="200" height="200" fill="#9fb8ff" opacity=".14"/>` +
        `<circle cx="40" cy="150" r="5" fill="#cfe0ff" opacity=".6" filter="url(#glow)"/><circle cx="164" cy="132" r="4" fill="#cfe0ff" opacity=".5" filter="url(#glow)"/><circle cx="150" cy="170" r="3" fill="#cfe0ff" opacity=".5" filter="url(#glow)"/>`
      : character;

    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="14 18 172 172">
      <defs>
        <radialGradient id="bg" cx="50%" cy="38%" r="75%"><stop offset="0" stop-color="hsl(${o.bg} 80% 78%)"/><stop offset="1" stop-color="hsl(${o.bg} 45% 32%)"/></radialGradient>
        <linearGradient id="iris" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${shade(o.eyes, -0.55)}"/><stop offset=".55" stop-color="${o.eyes}"/><stop offset="1" stop-color="${shade(o.eyes, 0.45)}"/></linearGradient>
        <clipPath id="face"><path d="${FACE}"/></clipPath>
        <filter id="soft" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="1.6"/></filter>
        <filter id="glow" x="-100%" y="-100%" width="300%" height="300%"><feGaussianBlur stdDeviation="2"/></filter>
        <linearGradient id="fadeG" x1="0" y1="0" x2="0" y2="1"><stop offset=".55" stop-color="#fff"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></linearGradient>
        <mask id="fade"><rect width="200" height="200" fill="url(#fadeG)"/></mask>
      </defs>
      <rect width="200" height="200" fill="url(#bg)"/>
      ${sparkles(o.bg)}
      ${ghost}
    </svg>`;
  }

  const cache = new Map();
  function url(p) {
    const key = JSON.stringify(p);
    if (!cache.has(key)) cache.set(key, "data:image/svg+xml;charset=utf-8," + encodeURIComponent(svg(p).replace(/\s+/g, " ")));
    return cache.get(key);
  }

  const pick = (a) => a[Math.floor(Math.random() * a.length)];
  function random() {
    const style = pick(["short", "spiky", "long", "long", "bob", "ponytail", "hijab"]);
    return {
      skin: pick(SKINS.slice(0, 5)),
      hair: style === "hijab" ? pick(["#2b2433", "#5b4a7a", "#c26b8a", "#3d6a8a", "#efe7dc", "#7a5c48"]) : pick(HAIRS),
      eyes: pick(EYES),
      hairStyle: style,
      outfit: `#${Math.floor(Math.random() * 0xffffff).toString(16).padStart(6, "0")}`,
      outfitStyle: pick(OUTFITS),
      accessory: Math.random() < 0.55 ? "none" : pick(["glasses", "headband", "hairclip", "flower", "horns", "headset"]),
      expression: pick(["smile", "smile", "grin", "calm", "shy", "happy", "cat"]),
      bg: Math.floor(Math.random() * 360),
    };
  }

  /** Plain-English appearance, sent with scene drawings. */
  function describe(input) {
    const o = normalize(input);
    const name = (h, list) => {
      const names = { "#2a2230": "black", "#4a3226": "dark brown", "#7a4a2a": "brown", "#c98b4f": "light brown", "#f1d38a": "blonde", "#e9e4ef": "white", "#b3b9c9": "silver", "#d9475f": "red", "#ff8fb8": "pink", "#8f6cff": "purple", "#3f7cff": "blue", "#2fbf9a": "teal", "#4caf50": "green",
        "#6b3f2a": "brown", "#3a6ea5": "blue", "#2f9e6e": "green", "#8a5cf6": "violet", "#d94a6a": "pink-red", "#d99a2b": "golden", "#22b8d6": "glowing cyan", "#c0392b": "red", "#555c70": "grey" };
      return names[h.toLowerCase()] || `colour ${h}`;
    };
    const hair = o.hairStyle === "bald" ? "completely bald head" : o.hairStyle === "hijab" ? `wears a hijab (headscarf, colour ${o.hair}) covering the hair` : `${o.hairStyle === "spiky" ? "spiky" : o.hairStyle === "ponytail" ? "ponytail" : o.hairStyle} ${name(o.hair)} hair`;
    const acc = { none: "", glasses: "round glasses", headband: "a red sports headband", hairclip: "a small hair clip", fedora: "a dark detective fedora", pirate: "a black pirate tricorn hat", horns: "small ivory dragon horns", headset: "a futuristic white headset", flower: "a pink flower in the hair", strawhat: "a straw hat with a red band", cap: "a red and white baseball cap", ninjaband: "a blue ninja forehead protector with a metal plate", blindfold: "a black blindfold over the eyes", scarf: "a red scarf around the neck" }[o.accessory];
    return [hair, `${name(o.eyes)} eyes`, `skin tone ${o.skin}`, `wearing a ${o.outfitStyle} (colour ${o.outfit})`, acc, o.ghost ? "a translucent, pale ghost" : "", o.scar ? "a small scar on the cheek" : ""].filter(Boolean).join(", ");
  }

  window.Portrait = { svg, url, random, normalize, describe, SKINS, HAIRS, EYES, STYLES, OUTFITS, ACCESSORIES, EXPRESSIONS };
})();
