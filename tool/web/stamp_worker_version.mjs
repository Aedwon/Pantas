// Run after `flutter build web`. Flutter's service worker version does not
// change when only Dart code changes, so pantas_sw.js kept serving the old
// main.dart.js from its cache after such a deploy. This appends a hash of every
// built file to the version in flutter_bootstrap.js, so each build gets its own
// worker and cache.
//
// It also writes the decoded size of main.dart.js into flutter_bootstrap.js, as
// window.pantasLoadTotal, for the loading percent. The page holds the total; the
// service worker script stays the same for every build and knows no sizes.
//
// It also writes the build id and the SHA-256 of every file in the startup set
// into pantas_sw.js (between the pantas-build markers). The worker installs only
// when every file it fetches matches, so a page never boots one build's shell
// with another build's Dart code (service worker build mix, E-184). Files left
// out of the set are listed in startupSet below; the worker never stores them.
//
// Usage: node tool/web/stamp_worker_version.mjs [build/web]
import {createHash} from 'node:crypto';
import {existsSync, readdirSync, readFileSync, statSync, writeFileSync} from 'node:fs';
import {join, relative} from 'node:path';

const BOOTSTRAP = 'flutter_bootstrap.js';
const MAIN = 'main.dart.js';
const WORKER = 'pantas_sw.js';
const PAGE = 'index.html';
// The worker holds the build constant between these markers. The shipped source
// has `null` there, which means an unstamped (dev) worker.
const BUILD = /\/\*pantas-build\*\/ [\s\S]*? \/\*end-pantas-build\*\//;
const UNSTAMPED = '/*pantas-build*/ null /*end-pantas-build*/';
const TOTAL = /^window\.pantasLoadTotal = \d+;\n/m;
const TOKEN = /registerWorker\("([^"]*)"/;

function files(dir, root = dir) {
  return readdirSync(dir).sort().flatMap(name => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? files(path, root) : [relative(root, path)];
  });
}

// The startup set: what the app needs to boot to Home with no connection. An
// explicit include list, so a new file in the build is left out until named here.
// Left out on purpose: version.json (network only: the app reads it to find a
// new build), the worker itself (the browser updates it), og-image.png (link
// previews), README.md, .last_build_id, flutter_service_worker.js (Flutter's own
// worker, never registered), assets/NOTICES (the licenses page only), source maps,
// and canvaskit/ unless the build serves CanvasKit itself (release builds load it
// from Google's CDN, which the worker never handles).
const EXACT = new Set([
  'index.html', 'flutter.js', 'flutter_bootstrap.js', 'main.dart.js', 'main.dart.mjs', 'main.dart.wasm',
  'drift_worker.js', 'sqlite3.wasm', 'manifest.json', 'favicon.png',
]);
const PARTS = /^main\.dart\.(js|mjs)_\d+\.part\.(js|mjs)$|^main\.dart\.wasm_\d+\.part\.wasm$/;
const HELPERS = /^pantas_(?!sw\.js$)[\w-]+\.js$/;
const EXCLUDED = new Set(['assets/NOTICES']);

export function startupSet(dir) {
  const bootstrap = readFileSync(join(dir, BOOTSTRAP), 'utf8');
  const localCanvasKit = /"useLocalCanvasKit"\s*:\s*true/.test(bootstrap);
  return files(dir).filter(name => {
    if (EXCLUDED.has(name) || name.endsWith('.map')) return false;
    if (EXACT.has(name) || PARTS.test(name) || HELPERS.test(name)) return true;
    if (name.startsWith('icons/') || name.startsWith('assets/')) return true;
    return localCanvasKit && name.startsWith('canvaskit/') && !name.endsWith('.symbols');
  });
}

const sha256 = bytes => createHash('sha256').update(bytes).digest('hex');

// path (relative to the scope; '' is the page as served at /) -> SHA-256.
export function fingerprints(dir) {
  const list = {};
  for (const name of startupSet(dir)) list[name] = sha256(readFileSync(join(dir, name)));
  list[''] = list[PAGE];
  return Object.fromEntries(Object.entries(list).sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0)));
}

// The build constant as it stands in a worker, or null for an unstamped worker.
export function workerBuild(source) {
  const match = source.match(BUILD);
  if (!match) throw new Error(`${WORKER} has no build constant between the pantas-build markers.`);
  const text = match[0].slice('/*pantas-build*/ '.length, -' /*end-pantas-build*/'.length);
  return text === 'null' ? null : JSON.parse(text);
}

export function buildHash(dir) {
  const hash = createHash('sha256');
  for (const name of files(dir)) {
    if (name === BOOTSTRAP) continue;
    let bytes = readFileSync(join(dir, name));
    // The worker is stamped with this hash's result, so hash its source without the stamp.
    if (name === WORKER) bytes = readFileSync(join(dir, name), 'utf8').replace(BUILD, UNSTAMPED);
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

export function stamp(dir) {
  for (const name of [PAGE, WORKER]) {
    if (!existsSync(join(dir, name))) throw new Error(`No ${name} in ${dir}.`);
  }
  const workerPath = join(dir, WORKER);
  const worker = readFileSync(workerPath, 'utf8');
  workerBuild(worker); // throws when the markers are missing
  const path = join(dir, BOOTSTRAP);
  const source = readFileSync(path, 'utf8');
  const match = source.match(TOKEN);
  if (!match) throw new Error(`No registerWorker("...") version in ${path}.`);
  const base = match[1].split('-')[0];
  const version = `${base}-${buildHash(dir)}`;
  // The bootstrap is left out of the hash, so its total line cannot change the
  // version. No main script means no total, and the page shows the spinner only.
  const main = join(dir, MAIN);
  const total = existsSync(main) ? `window.pantasLoadTotal = ${statSync(main).size};\n` : '';
  const stamped = source.replace(TOTAL, '').replace(TOKEN, `registerWorker("${version}"`);
  writeFileSync(path, total + stamped);
  const metadataPath = join(dir, 'version.json');
  if (existsSync(metadataPath)) {
    const metadata = JSON.parse(readFileSync(metadataPath, 'utf8'));
    metadata.pantasBuildVersion = version;
    writeFileSync(metadataPath, JSON.stringify(metadata));
  }
  // Last: the bootstrap is final, so its hash is the one the worker verifies.
  const constant = `/*pantas-build*/ ${JSON.stringify({id: version, files: fingerprints(dir)})} /*end-pantas-build*/`;
  writeFileSync(workerPath, worker.replace(BUILD, () => constant));
  return version;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const dir = process.argv[2] ?? 'build/web';
  console.log(`Service worker version: ${stamp(dir)}`);
  const inSet = new Set(startupSet(dir));
  const bytes = [...inSet].reduce((sum, name) => sum + statSync(join(dir, name)).size, 0);
  console.log(`Startup set: ${inSet.size} files, ${(bytes / 1048576).toFixed(1)} MB`);
  console.log(`Left out: ${files(dir).filter(name => !inSet.has(name)).join(', ')}`);
}
