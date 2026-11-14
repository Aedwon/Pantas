// Builds the side-by-side review gallery (guardrails layer 3) as one static
// page, build/gallery/index.html, with every image copied beside it so the
// page uses relative paths only and can be zipped or uploaded as is.
//
//   node tool/design_system/build_gallery.mjs <app-png-folder>
//
// <app-png-folder> holds the app goldens as CI renders them: component sheets
// as <name>.png and key screens as screens/<name>_<width>.png (the layout of
// test/goldens/files). The system references come from build/ds-reference
// (capture_reference.mjs) and the approved boards from build/ds-boards
// (capture_boards.mjs, with its map.json).
//
// Per component: the system reference in light and dark beside the app sheet
// (which shows light and dark). Per screen: the board or boards beside the
// app golden, at each width the golden has.
import {copyFileSync, existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync} from 'node:fs';
import {basename, dirname, join, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const appDir = process.argv[2] ? resolve(process.argv[2]) : null;
if (!appDir || !existsSync(appDir)) {
  console.error('usage: node tool/design_system/build_gallery.mjs <app-png-folder>');
  process.exit(2);
}
const refDir = join(root, 'build/ds-reference');
const boardDir = join(root, 'build/ds-boards');
const out = join(root, 'build/gallery');
rmSync(out, {recursive: true, force: true});
for (const sub of ['app', 'ref', 'boards']) mkdirSync(join(out, sub), {recursive: true});

const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;'}[c]));
const copy = (from, sub, name) => {
  if (!existsSync(from)) return null;
  copyFileSync(from, join(out, sub, name));
  return `${sub}/${encodeURIComponent(name)}`;
};
const pascal = (snake) => snake.split('_').map((w) => w[0].toUpperCase() + w.slice(1)).join('');
const figure = (src, caption) => src
  ? `<figure><img src="${src}" alt="${esc(caption)}" loading="lazy"><figcaption>${esc(caption)}</figcaption></figure>`
  : `<figure class="missing"><div>no image</div><figcaption>${esc(caption)}</figcaption></figure>`;

// Components: every sheet in the folder, in name order.
const sheets = readdirSync(appDir).filter((f) => f.endsWith('.png')).sort();
const componentHtml = [];
const noSystem = [];
for (const file of sheets) {
  const key = basename(file, '.png');
  const system = pascal(key);
  const light = copy(join(refDir, `${system}-light.png`), 'ref', `${system}-light.png`);
  const dark = copy(join(refDir, `${system}-dark.png`), 'ref', `${system}-dark.png`);
  if (!light && !dark) noSystem.push(key);
  componentHtml.push(`<section id="c-${esc(key)}"><h3>${esc(system)} <small>${esc(key)}</small></h3>
<div class="row">${figure(light, 'System, light')}${figure(dark, 'System, dark')}${figure(copy(join(appDir, file), 'app', file), 'App sheet, light and dark')}</div></section>`);
}

// Screens: app goldens at <name>_<width>.png, with the mapped boards.
const screenDir = existsSync(join(appDir, 'screens')) ? join(appDir, 'screens') : appDir;
const map = existsSync(join(boardDir, 'map.json')) ? JSON.parse(readFileSync(join(boardDir, 'map.json'), 'utf8')) : {};
const shots = readdirSync(screenDir).filter((f) => /_\d+\.png$/.test(f)).sort();
const screens = new Map();
for (const f of shots) {
  const [, name, width] = f.match(/^(.*)_(\d+)\.png$/);
  if (!screens.has(name)) screens.set(name, []);
  screens.get(name).push({width: Number(width), file: f});
}
const screenHtml = [];
const noBoard = [];
for (const [name, list] of [...screens].sort(([a], [b]) => a.localeCompare(b))) {
  const rows = [];
  for (const {width, file} of list.sort((a, b) => a.width - b.width)) {
    const kind = width >= 1024 ? 'web' : 'mobile';
    const boards = (map[name]?.[kind] ?? []);
    if (!boards.length) noBoard.push(`${name} at ${width}`);
    const boardFigs = boards.map((b) => figure(copy(join(boardDir, `${b}-${kind}.png`), 'boards', `${b}-${kind}.png`), `Board ${b}`));
    rows.push(`<div class="row">${boardFigs.join('') || figure(null, 'No board for this screen')}${figure(copy(join(screenDir, file), 'app', `screens-${file}`), `App at ${width}`)}</div>`);
  }
  screenHtml.push(`<section id="s-${esc(name)}"><h3>${esc(name)}</h3>${rows.join('')}</section>`);
}

const html = `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Pantas design system gallery</title>
<style>
:root{color-scheme:light dark;--bg:#f5f5f7;--fg:#1d1d1f;--muted:#6e6e73;--line:#d2d2d7}
@media(prefers-color-scheme:dark){:root{--bg:#151515;--fg:#f5f5f5;--muted:#a3a3a3;--line:#3d3d3d}}
body{margin:0;padding:16px;background:var(--bg);color:var(--fg);font:15px/1.45 system-ui,sans-serif}
h1{margin:0 0 4px}h2{margin:32px 0 8px;border-top:1px solid var(--line);padding-top:16px}h3{margin:20px 0 8px}small{color:var(--muted);font-weight:400}
.row{display:flex;gap:12px;align-items:flex-start;flex-wrap:wrap;margin-bottom:12px}
figure{margin:0;flex:0 1 auto;max-width:100%}figure img{display:block;max-width:100%;height:auto;border:1px solid var(--line)}
figcaption{color:var(--muted);font-size:13px;margin-top:4px}.missing div{padding:24px;border:1px dashed var(--line);color:var(--muted)}
nav a{margin-right:12px}
</style></head><body>
<h1>Pantas design system gallery</h1>
<p>${componentHtml.length} components, ${screens.size} screens. System on the left, app on the right.</p>
<nav><a href="#components">Components</a><a href="#screens">Screens</a></nav>
${noSystem.length ? `<p>Sheets with no system reference: ${esc(noSystem.join(', '))}.</p>` : ''}
${noBoard.length ? `<p>Screens with no board: ${esc(noBoard.join(', '))}.</p>` : ''}
<h2 id="components">Components</h2>
${componentHtml.join('\n')}
<h2 id="screens">Screens</h2>
${screenHtml.join('\n')}
</body></html>
`;
writeFileSync(join(out, 'index.html'), html);
console.log(`gallery: ${componentHtml.length} components, ${screens.size} screens -> ${join(out, 'index.html')}`);
if (noSystem.length) console.log(`no system reference: ${noSystem.join(', ')}`);
if (noBoard.length) console.log(`no board: ${noBoard.join(', ')}`);
