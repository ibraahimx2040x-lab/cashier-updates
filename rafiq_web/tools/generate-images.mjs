// Draws one anime picture per character with the deployed character-scene
// function and saves it to rafiq_web/images/<id>.webp, then rewrites
// images/manifest.js. Characters that already have a picture are skipped,
// so it can be re-run after a failure, or with ids to redo specific ones:
//
//   node rafiq_web/tools/generate-images.mjs            # all missing
//   node rafiq_web/tools/generate-images.mjs naruto l   # just these (overwrites)
//
// Needs Node 18+ and Playwright with Chromium (used only to shrink images).
// The Gemini key behind the function must have image generation enabled.

import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";
import { fileURLToPath } from "node:url";
import { createRequire } from "node:module";

const root = path.join(path.dirname(fileURLToPath(import.meta.url)), "..");
const imagesDir = path.join(root, "images");
const config = load(["config.js"]).RAFIQ_CONFIG;
const win = load(["portraits.js", "characters.js", "famous.js"]);
const characters = [...win.FAMOUS_CHARACTERS, ...win.SEED_CHARACTERS];

const only = process.argv.slice(2);
const existing = () => new Set(fs.readdirSync(imagesDir).filter(isImage).map((f) => f.replace(/\.[^.]+$/, "")));
const todo = characters.filter((c) => (only.length ? only.includes(c.id) : !existing().has(c.id)));
console.log(`${todo.length} to draw`);

// require() also finds a globally installed Playwright, which import() does not.
const { chromium } = createRequire(import.meta.url)("playwright");
const browser = await chromium.launch();
const page = await browser.newPage();

let failed = 0;
for (const c of todo) {
  process.stdout.write(`${c.id} … `);
  try {
    const png = await draw(c);
    const webp = await shrink(png);
    for (const f of fs.readdirSync(imagesDir)) if (f.replace(/\.[^.]+$/, "") === c.id && isImage(f)) fs.unlinkSync(path.join(imagesDir, f));
    fs.writeFileSync(path.join(imagesDir, `${c.id}.webp`), webp);
    console.log(`ok (${Math.round(webp.length / 1024)} KB)`);
  } catch (e) {
    failed++;
    console.log(`failed: ${e.message}`);
    if (e.message === "quota") break; // the key can't draw at all; no point continuing
  }
}
await browser.close();
writeManifest();
console.log(failed ? `${failed} failed` : "done");
process.exitCode = failed ? 1 : 0;

async function draw(c) {
  const name = c.name.en;
  const who = c.show ? `${name} from "${c.show.en}"` : name;
  const res = await fetch(config.sceneUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json", apikey: config.apiKey, Origin: "https://ibraahimx2040x-lab.github.io" },
    body: JSON.stringify({
      character: {
        name: who,
        appearance: c.look || (c.portrait ? win.Portrait.describe(c.portrait) : ""),
        scenario: c.scenario || "",
      },
      scene: `A character portrait of ${who}: upper body, facing the viewer with a characteristic expression and pose, ` +
        `in a softly blurred background from their own world. Faithful to the character's well-known design. Poster quality.`,
      message: c.tagline.en,
    }),
    signal: AbortSignal.timeout(120_000),
  });
  const out = await res.json().catch(() => ({}));
  if (!out.data) throw new Error(out.error || `HTTP ${res.status}`);
  return Buffer.from(out.data, "base64");
}

/** Centre-crop to 4:5, resize to 640×800 and encode as WebP in Chromium. */
async function shrink(buf) {
  const src = `data:image/png;base64,${buf.toString("base64")}`;
  const b64 = await page.evaluate(async (src) => {
    const img = new Image();
    img.src = src;
    await img.decode();
    const W = 640, H = 800, r = W / H;
    let sw = img.width, sh = img.height;
    if (sw / sh > r) sw = sh * r; else sh = sw / r;
    const cv = document.createElement("canvas");
    cv.width = W;
    cv.height = H;
    cv.getContext("2d").drawImage(img, (img.width - sw) / 2, (img.height - sh) / 2, sw, sh, 0, 0, W, H);
    return cv.toDataURL("image/webp", 0.82).split(",")[1];
  }, src);
  return Buffer.from(b64, "base64");
}

function writeManifest() {
  const lines = fs.readdirSync(imagesDir).filter(isImage).sort().map((f) => `  "${f.replace(/\.[^.]+$/, "")}": "images/${f}",`);
  fs.writeFileSync(path.join(imagesDir, "manifest.js"), `window.CHARACTER_IMAGES = {\n${lines.join("\n")}\n};\n`);
}

function isImage(f) {
  return /\.(jpe?g|png|webp)$/i.test(f);
}

/** Runs the site's plain browser scripts with a fake `window` and returns it. */
function load(files) {
  const window = { CATEGORIES: [] };
  const ctx = vm.createContext({ window, console, encodeURIComponent });
  for (const f of files) vm.runInContext(fs.readFileSync(path.join(root, f), "utf8"), ctx, { filename: f });
  return window;
}
