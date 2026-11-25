// A tiny fake `build/web` tree for service worker tests, so no Flutter build is
// needed. Every file carries the marker @build:<id>@ so a test can tell which
// build a body came from. The page, bootstrap, main script and its part also push
// "<id>:<name>" onto window.__boot, which the real-browser rollout test reads.
//
// A build is stamped by the real stamp tool, with the real web/pantas_sw.js and
// the real web/pantas_pwa.js. `prod: true` leaves today's production worker
// (fixtures/pantas_sw_prod_a.js) in place and stamps nothing, like a build that
// shipped before the fingerprint list.
import {mkdirSync, readFileSync, writeFileSync} from 'node:fs';
import {dirname, join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {stamp} from '../../../tool/web/stamp_worker_version.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const repo = join(here, '..', '..', '..');
export const marker = id => `@build:${id}@`;
export const buildOf = text => /@build:([A-Za-z0-9]+)@/.exec(text)?.[1] ?? null;

const push = (id, name) => `(window.__boot=window.__boot||[]).push(${JSON.stringify(`${id}:${name}`)});`;

// The files a build holds. Paths in `startup` are part of the startup set; the
// rest are in the build output but left out of it.
export function buildFiles(id) {
  const m = marker(id);
  const base = `// ${m}\n`;
  return {
    'index.html': `<!doctype html><!-- ${m} --><script>${push(id, 'index')}</script>` +
      `<script src="pantas_pwa.js"></script><script src="flutter_bootstrap.js"></script>`,
    'flutter_bootstrap.js': `${base}${push(id, 'bootstrap')}\n(async function () {\n` +
      `  await window.pantasPwa.registerWorker("1-${id}" /* note */);\n` +
      `  var s = document.createElement('script'); s.src = 'main.dart.js'; document.head.appendChild(s);\n})();\n`,
    'flutter.js': `${base}`,
    'main.dart.js': `${base}${push(id, 'main')}\n` +
      `var p = document.createElement('script'); p.src = 'main.dart.js_1.part.js'; document.head.appendChild(p);\n`,
    'main.dart.js_1.part.js': `${base}${push(id, 'part')}\n`,
    'pantas_pwa.js': `${readFileSync(join(repo, 'web/pantas_pwa.js'), 'utf8')}\n// ${m}\n${push(id, 'pwa')}\n`,
    'pantas_history.js': base,
    'pantas_splash.js': base,
    'pantas_welcome.js': base,
    'drift_worker.js': base,
    'sqlite3.wasm': `\0asm${m}`,
    'manifest.json': JSON.stringify({name: 'Pantas', note: m, icons: [{src: 'icons/Icon-192.png'}]}),
    'favicon.png': `png ${m}`,
    'icons/Icon-192.png': `png ${m}`,
    'assets/AssetManifest.bin': `bin ${m}`,
    'assets/AssetManifest.bin.json': JSON.stringify({note: m}),
    'assets/FontManifest.json': JSON.stringify({note: m}),
    'assets/fonts/MaterialIcons-Regular.otf': `otf ${m}`,
    'assets/assets/fonts/Geist-Regular.ttf': `ttf ${m}`,
    // In the build output, not in the startup set.
    'version.json': JSON.stringify({app_name: 'pantas', note: m}),
    'og-image.png': `png ${m}`,
    'README.md': m,
    'flutter_service_worker.js': base,
    'assets/NOTICES': m,
  };
}

export const STARTUP = [
  'flutter_bootstrap.js', 'flutter.js', 'main.dart.js', 'main.dart.js_1.part.js', 'pantas_pwa.js',
  'pantas_history.js', 'pantas_splash.js', 'pantas_welcome.js', 'drift_worker.js', 'sqlite3.wasm',
  'manifest.json', 'favicon.png', 'icons/Icon-192.png', 'assets/AssetManifest.bin',
  'assets/AssetManifest.bin.json', 'assets/FontManifest.json', 'assets/fonts/MaterialIcons-Regular.otf',
  'assets/assets/fonts/Geist-Regular.ttf', 'index.html',
];

// Writes one build to `dir` and stamps it (or leaves today's worker for `prod`).
// Returns the build's files as served: path -> text, with '' for the page.
export function writeBuild(dir, id, {prod = false, files = {}} = {}) {
  const all = {...buildFiles(id), ...files};
  all['pantas_sw.js'] = readFileSync(
    join(prod ? here : join(repo, 'web'), prod ? 'pantas_sw_prod_a.js' : 'pantas_sw.js'), 'utf8');
  for (const [path, body] of Object.entries(all)) {
    mkdirSync(dirname(join(dir, path)), {recursive: true});
    writeFileSync(join(dir, path), body);
  }
  if (prod) {
    // Today's production build: its version rides on the bootstrap token only.
    const path = join(dir, 'flutter_bootstrap.js');
    writeFileSync(path, readFileSync(path, 'utf8').replace(`"1-${id}"`, `"${id}"`));
    writeFileSync(join(dir, 'version.json'), JSON.stringify({app_name: 'pantas', note: marker(id), pantasBuildVersion: id}));
  } else {
    stamp(dir);
  }
  const served = {};
  for (const path of [...Object.keys(all), 'version.json']) {
    served[path] = readFileSync(join(dir, path), 'utf8');
  }
  served[''] = served['index.html'];
  return served;
}
