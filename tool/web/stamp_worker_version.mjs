// Run after `flutter build web`. The stamp turns the build into a release:
//
// 1. Build folder. Every file a page loads moves into b/<id>/ (the helper scripts,
//    flutter_bootstrap.js, main.dart.js and its parts, the database worker, sqlite3.wasm,
//    assets/, canvaskit/) and the page names those URLs. The root keeps only what the
//    browser or a link needs at a fixed address: the page, the service worker,
//    version.json, manifest.json, the icons and a few files nothing loads. A page
//    can therefore only ever run the files of the build it names, whatever worker
//    or HTTP cache is in between (service worker build mix, E-184).
// 2. Version. The id covers the final bytes of everything except the stamp's own
//    lines, so a change to any file, the bootstrap included, gives a new id, a new
//    worker and a new cache. Stamping again moves the folder back and starts over.
// 3. Size. The decoded size of main.dart.js goes into the bootstrap as
//    window.pantasLoadTotal for the loading percent. The page holds the total; the
//    service worker script stays the same for every build and knows no sizes.
// 4. Fingerprints. The build id and the SHA-256 of every file in the startup set go
//    into pantas_sw.js (between the pantas-build markers). The worker installs only
//    when every file it fetches matches. Files left out of the set are never stored.
//
// Usage: node tool/web/stamp_worker_version.mjs [build/web]
import {createHash} from 'node:crypto';
import {existsSync, mkdirSync, readdirSync, readFileSync, renameSync, rmSync, rmdirSync, statSync, writeFileSync} from 'node:fs';
import {dirname, join, relative} from 'node:path';

const BOOTSTRAP = 'flutter_bootstrap.js';
const MAIN = 'main.dart.js';
const WORKER = 'pantas_sw.js';
const PAGE = 'index.html';
// The worker holds the build constant between these markers. The shipped source
// has `null` there, which means an unstamped (dev) worker.
const BUILD = /\/\*pantas-build\*\/ [\s\S]*? \/\*end-pantas-build\*\//;
const UNSTAMPED = '/*pantas-build*/ null /*end-pantas-build*/';
const TOTAL = /^window\.pantasLoadTotal = \d+;\n/m;
const BASE_LINE = /^window\.pantasBuildBase = "[^"]*";\n/m;
const TOKEN = /registerWorker\("([^"]*)"/;
const FOLDERS = 'b';

// What stays at the root: the page, the worker, version.json (network only), what
// a fixed address needs (manifest, favicon, icons) and files no page loads.
const ROOT_FILES = new Set([
  PAGE, WORKER, 'version.json', 'manifest.json', 'favicon.png', 'og-image.png', 'README.md', '.last_build_id',
  'flutter_service_worker.js',
]);
// A package asks for this file by a fixed address relative to the page (purchases_flutter's
// web plugin hard-codes it), so it cannot follow the folder. It is in the startup set, so a
// controlled page gets the copy its build verified.
export const FIXED_ADDRESS = ['assets/packages/purchases_flutter/assets/web/purchases_js_hybrid_mappings.js'];
const atRoot = name => ROOT_FILES.has(name) || name.startsWith('icons/') || FIXED_ADDRESS.includes(name);

function files(dir, root = dir) {
  if (!existsSync(dir)) return [];
  return readdirSync(dir).sort().flatMap(name => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? files(path, root) : [relative(root, path)];
  });
}

// The startup set: what the app needs to boot to Home with no connection. An
// explicit include list, so a new file in the build is left out until named here.
// Left out on purpose: version.json (network only: the app reads it to find a new
// build), the worker itself (the browser updates it), og-image.png (link previews),
// README.md, .last_build_id, flutter_service_worker.js (Flutter's own worker, never
// registered), assets/NOTICES (the licenses page only), source maps, and every
// canvaskit file except the two variants a dart2js build can use (below).
const EXACT = new Set([
  'flutter.js', 'flutter_bootstrap.js', 'main.dart.js', 'main.dart.mjs', 'main.dart.wasm', 'drift_worker.js', 'sqlite3.wasm',
]);
const ROOT_SET = new Set([PAGE, 'manifest.json', 'favicon.png']);
const PARTS = /^main\.dart\.(js|mjs)_\d+\.part\.(js|mjs)$|^main\.dart\.wasm_\d+\.part\.wasm$/;
const HELPERS = /^pantas_(?!sw\.js$)[\w-]+\.js$/;
const EXCLUDED = new Set(['assets/NOTICES']);
// The two CanvasKit builds Flutter picks from. A browser that runs Chromium's
// engine uses the smaller one; the worker installs only the one its browser uses.
const VARIANTS = {
  standard: ['canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm'],
  chromium: ['canvaskit/chromium/canvaskit.js', 'canvaskit/chromium/canvaskit.wasm'],
};

/** The build folder inside `dir` ('b/<id>/'), or '' for a tree that is not stamped. */
export function buildFolder(dir) {
  const parent = join(dir, FOLDERS);
  if (!existsSync(parent)) return '';
  const names = readdirSync(parent).filter(name => statSync(join(parent, name)).isDirectory());
  return names.length === 1 ? `${FOLDERS}/${names[0]}/` : '';
}

function localCanvasKit(dir, folder) {
  const path = join(dir, folder, BOOTSTRAP);
  return existsSync(path) && /"useLocalCanvasKit"\s*:\s*true/.test(readFileSync(path, 'utf8'));
}

/** The final paths (relative to the scope) of the startup set of a stamped tree. */
export function startupSet(dir) {
  const folder = buildFolder(dir);
  const canvasKit = new Set(localCanvasKit(dir, folder) ? Object.values(VARIANTS).flat() : []);
  return files(dir).filter(path => {
    if (!folder || !path.startsWith(folder)) return ROOT_SET.has(path) || path.startsWith('icons/') || FIXED_ADDRESS.includes(path);
    const name = path.slice(folder.length);
    if (EXCLUDED.has(name) || name.endsWith('.map')) return false;
    return EXACT.has(name) || PARTS.test(name) || HELPERS.test(name) || name.startsWith('assets/') || canvasKit.has(name);
  });
}

/** The renderer files of each variant as final paths, or null when the build has none. */
export function variantPaths(dir) {
  const folder = buildFolder(dir);
  if (!folder || !localCanvasKit(dir, folder)) return null;
  return Object.fromEntries(Object.entries(VARIANTS).map(([name, list]) => [name, list.map(file => folder + file)]));
}

const sha256 = bytes => createHash('sha256').update(bytes).digest('hex');

// path (relative to the scope; '' is the page as served at /) -> SHA-256.
export function fingerprints(dir) {
  const list = {};
  for (const path of startupSet(dir)) list[path] = sha256(readFileSync(join(dir, path)));
  list[''] = list[PAGE];
  return Object.fromEntries(Object.entries(list).sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0)));
}

/** A short hash of the list, so a cache can never be mistaken for another list's. */
export const listHash = list => sha256(JSON.stringify(list)).slice(0, 12);

// The build constant as it stands in a worker, or null for an unstamped worker.
export function workerBuild(source) {
  const match = source.match(BUILD);
  if (!match) throw new Error(`${WORKER} has no build constant between the pantas-build markers.`);
  const text = match[0].slice('/*pantas-build*/ '.length, -' /*end-pantas-build*/'.length);
  return text === 'null' ? null : JSON.parse(text);
}

// The final bytes of every file except the stamp's own output: the worker's
// constant, the bootstrap's total, base and version, and version.json's identity.
// Everything else, the bootstrap included, is in the id.
export function buildHash(dir) {
  const hash = createHash('sha256');
  for (const name of files(dir)) {
    let bytes = readFileSync(join(dir, name));
    if (name === WORKER) bytes = bytes.toString('utf8').replace(BUILD, UNSTAMPED);
    if (name === BOOTSTRAP) {
      const text = bytes.toString('utf8');
      const base = (text.match(TOKEN) ?? [, ''])[1].split('-')[0];
      bytes = text.replace(TOTAL, '').replace(BASE_LINE, '').replace(TOKEN, `registerWorker("${base}"`);
    }
    // Ignore our own output so stamping twice preserves the build identity.
    if (name === 'version.json') {
      const metadata = JSON.parse(bytes.toString());
      delete metadata.pantasBuildVersion;
      bytes = JSON.stringify(metadata);
    }
    hash.update(name).update('\0').update(bytes).update('\0');
  }
  return hash.digest('hex').slice(0, 12);
}

const move = (dir, from, to) => {
  mkdirSync(dirname(join(dir, to)), {recursive: true});
  renameSync(join(dir, from), join(dir, to));
  // A move leaves empty folders behind; the root must keep no trace of a moved file.
  for (let old = dirname(from); old !== '.' && !readdirSync(join(dir, old)).length; old = dirname(old)) {
    rmdirSync(join(dir, old));
  }
};

// Puts a stamped tree back the way Flutter wrote it, so stamping starts over.
function unstamp(dir) {
  const folder = buildFolder(dir);
  if (!folder) return;
  for (const name of files(join(dir, folder))) move(dir, folder + name, name);
  rmSync(join(dir, FOLDERS), {recursive: true, force: true});
  const page = join(dir, PAGE);
  writeFileSync(page, readFileSync(page, 'utf8').split(folder).join(''));
}

export function stamp(dir) {
  for (const name of [PAGE, WORKER]) {
    if (!existsSync(join(dir, name))) throw new Error(`No ${name} in ${dir}.`);
  }
  unstamp(dir);
  const workerPath = join(dir, WORKER);
  const worker = readFileSync(workerPath, 'utf8');
  workerBuild(worker); // throws when the markers are missing
  const path = join(dir, BOOTSTRAP);
  const source = readFileSync(path, 'utf8');
  const match = source.match(TOKEN);
  if (!match) throw new Error(`No registerWorker("...") version in ${path}.`);
  const base = match[1].split('-')[0];
  const version = `${base}-${buildHash(dir)}`;
  const folder = `${FOLDERS}/${version}/`;
  // No main script means no total, and the page shows the spinner only.
  const main = join(dir, MAIN);
  const total = existsSync(main) ? `window.pantasLoadTotal = ${statSync(main).size};\n` : '';
  const stamped = source.replace(TOTAL, '').replace(BASE_LINE, '').replace(TOKEN, `registerWorker("${version}"`);
  writeFileSync(path, `${total}window.pantasBuildBase = "${folder}";\n${stamped}`);
  const metadataPath = join(dir, 'version.json');
  if (existsSync(metadataPath)) {
    const metadata = JSON.parse(readFileSync(metadataPath, 'utf8'));
    metadata.pantasBuildVersion = version;
    writeFileSync(metadataPath, JSON.stringify(metadata));
  }
  // The page names the build folder for every file it loads.
  const moved = files(dir).filter(name => !atRoot(name));
  const movedSet = new Set(moved);
  const pagePath = join(dir, PAGE);
  const follow = target => (movedSet.has(target) ? folder + target : target);
  // Scripts and links, and url() in the page's own styles (the welcome and splash fonts).
  writeFileSync(pagePath, readFileSync(pagePath, 'utf8')
    .replace(/\b(src|href)="([^"#?]+)"/g, (all, attribute, target) => `${attribute}="${follow(target)}"`)
    .replace(/\burl\((['"]?)([^'")#?]+)\1\)/g, (all, quote, target) => `url(${quote}${follow(target)}${quote})`));
  for (const name of moved) move(dir, name, folder + name);
  // Last: every file is final, so these are the hashes the worker verifies.
  const list = fingerprints(dir);
  const constant = {id: version, base: folder, list: listHash(list), files: list};
  const variants = variantPaths(dir);
  if (variants) constant.variants = variants;
  writeFileSync(workerPath, worker.replace(BUILD, () => `/*pantas-build*/ ${JSON.stringify(constant)} /*end-pantas-build*/`));
  return version;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const dir = process.argv[2] ?? 'build/web';
  console.log(`Service worker version: ${stamp(dir)}`);
  const inSet = new Set(startupSet(dir));
  const bytes = [...inSet].reduce((sum, name) => sum + statSync(join(dir, name)).size, 0);
  console.log(`Startup set: ${inSet.size} files, ${(bytes / 1048576).toFixed(1)} MB (both renderer variants; one is installed)`);
  console.log(`Left out: ${files(dir).filter(name => !inSet.has(name)).join(', ')}`);
}
