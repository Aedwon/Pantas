// A tiny fake `build/web` tree for service worker tests, so no Flutter build is
// needed. Every file carries the marker @build:<id>@ so a test can tell which
// build a body came from. The page, bootstrap, main script and its part also push
// "<id>:<name>" onto window.__boot, which the real-browser rollout test reads.
//
// A build is stamped by the real stamp tool, with the real web/pantas_sw.js, the
// real web/pantas_pwa.js and the real web/flutter_bootstrap.js (Flutter's own
// loader is a small stand-in that loads main.dart.js from the build folder, the
// way Flutter's entrypointBaseUrl does). `prod: true` leaves today's production worker
// (fixtures/pantas_sw_prod_a.js) in place and stamps nothing, like a build that
// shipped before the fingerprint list.
import {mkdirSync, readFileSync, readdirSync, statSync, writeFileSync} from 'node:fs';
import {dirname, join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {stamp} from '../../../tool/web/stamp_worker_version.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const repo = join(here, '..', '..', '..');
export const marker = id => `@build:${id}@`;
export const buildOf = text => /@build:([A-Za-z0-9]+)@/.exec(text)?.[1] ?? null;

const push = (id, name) => `(window.__boot=window.__boot||[]).push(${JSON.stringify(`${id}:${name}`)});`;

const stubLoader = `window._flutter = {loader: {load: function (options) {
  var config = (options && options.config) || {};
  var s = document.createElement('script'); s.src = (config.entrypointBaseUrl || '') + 'main.dart.js'; document.head.appendChild(s);
}}};`;
// `prod` builds carry the page helper and bootstrap that ship today (copied from
// origin/main on Nov 26), because those are the ones already on phones.
function bootstrap(id, prod) {
  const source = prod ? join(here, 'flutter_bootstrap_prod_a.js') : join(repo, 'web/flutter_bootstrap.js');
  return `// ${marker(id)}\n${push(id, 'bootstrap')}\n` + readFileSync(source, 'utf8')
    .replace('{{flutter_js}}', stubLoader).replace('{{flutter_build_config}}', '')
    .replace('{{flutter_service_worker_version}}', `"1-${id}"`);
}

// The files a build holds. Paths in `startup` are part of the startup set; the
// rest are in the build output but left out of it.
export function buildFiles(id, prod = false) {
  const m = marker(id);
  const base = `// ${m}\n`;
  return {
    'index.html': `<!doctype html><!-- ${m} --><script>${push(id, 'index')}</script>` +
      `<script src="pantas_pwa.js"></script><script src="flutter_bootstrap.js"></script>`,
    'flutter_bootstrap.js': bootstrap(id, prod),
    'flutter.js': `${base}`,
    // Like dart2js: a deferred part is found next to the script that asks for it.
    'main.dart.js': `${base}${push(id, 'main')}\n` +
      `var p = document.createElement('script'); p.src = document.currentScript.src.replace(/main\\.dart\\.js.*$/, '') + 'main.dart.js_1.part.js'; document.head.appendChild(p);\n`,
    'main.dart.js_1.part.js': `${base}${push(id, 'part')}\n`,
    // A second deferred part that no page requests while it boots, so a test can ask
    // for one that was genuinely never loaded (audit 2, Medium 9).
    'main.dart.js_2.part.js': `${base}${push(id, 'part2')}\n`,
    'pantas_pwa.js': `${readFileSync(prod ? join(here, 'pantas_pwa_prod_a.js') : join(repo, 'web/pantas_pwa.js'), 'utf8')}\n// ${m}\n${push(id, 'pwa')}\n`,
    'pantas_history.js': base,
    'pantas_splash.js': base,
    'pantas_welcome.js': base,
    // The real database worker: it keeps one root address and the same bytes in every build
    // (fix list item 1), so it carries no build marker and a test can see it is shared.
    'drift_worker.js': readFileSync(join(repo, 'web/drift_worker.js'), 'utf8'),
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

// Writes one build to `dir` and stamps it (or leaves today's worker for `prod`).
// Returns the build's files as served: path -> text, with '' for the page.
export function writeBuild(dir, id, {prod = false, files = {}, localCanvasKit = false} = {}) {
  const all = {...buildFiles(id, prod), ...files};
  all['pantas_sw.js'] = readFileSync(
    join(prod ? here : join(repo, 'web'), prod ? 'pantas_sw_prod_a.js' : 'pantas_sw.js'), 'utf8');
  for (const [path, body] of Object.entries(all)) {
    mkdirSync(dirname(join(dir, path)), {recursive: true});
    writeFileSync(join(dir, path), body);
  }
  if (localCanvasKit) {
    // The line Flutter's build config writes when the build ships CanvasKit itself.
    const path = join(dir, 'flutter_bootstrap.js');
    writeFileSync(path, `_flutter.buildConfig = {"useLocalCanvasKit":true};\n${readFileSync(path, 'utf8')}`);
  }
  if (prod) {
    // Today's production build: its version rides on the bootstrap token only.
    const path = join(dir, 'flutter_bootstrap.js');
    writeFileSync(path, readFileSync(path, 'utf8').replace(`"1-${id}"`, `"${id}"`));
    writeFileSync(join(dir, 'version.json'), JSON.stringify({app_name: 'pantas', note: marker(id), pantasBuildVersion: id}));
  } else {
    stamp(dir);
  }
  // Everything the build serves, by final path ('' is the page).
  const served = {};
  const walk = (folder, prefix = '') => {
    for (const name of readdirSync(folder)) {
      const path = prefix + name;
      if (statSync(join(folder, name)).isDirectory()) walk(join(folder, name), path + '/');
      else served[path] = readFileSync(join(folder, name), 'utf8');
    }
  };
  walk(dir);
  served[''] = served['index.html'];
  return served;
}

/** The stamped constant of a served build, or null for today's production worker. */
export function constantOf(served) {
  const match = /\/\*pantas-build\*\/ (\{.*?\}) \/\*end-pantas-build\*\//s.exec(served['pantas_sw.js']);
  return match ? JSON.parse(match[1]) : null;
}
