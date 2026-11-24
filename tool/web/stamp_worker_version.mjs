// Run after `flutter build web`. Flutter's service worker version does not
// change when only Dart code changes, so pantas_sw.js kept serving the old
// main.dart.js from its cache after such a deploy. This appends a hash of every
// built file to the version in flutter_bootstrap.js, so each build gets its own
// worker and cache.
//
// It also writes the decoded size of each file the page loads from this
// origin before the first frame into pantas_sw.js, as its LOAD_SIZES constant.
// The service worker divides the bytes it delivers by that fixed total for the
// loading percent. An unstamped worker (null) shows the spinner only.
//
// Usage: node tool/web/stamp_worker_version.mjs [build/web]
import {createHash} from 'node:crypto';
import {existsSync, readdirSync, readFileSync, statSync, writeFileSync} from 'node:fs';
import {join, relative} from 'node:path';

const BOOTSTRAP = 'flutter_bootstrap.js';
const WORKER = 'pantas_sw.js';
const MAIN = 'main.dart.js';
const SIZES_LINE = /^const LOAD_SIZES = .*$/m;
const SIZES_COMMENT = '// stamped by tool/web/stamp_worker_version.mjs';
// The files Flutter's chromium CanvasKit build loads. Which build a browser
// takes depends on the browser, so only a build that serves CanvasKit from its
// own origin lists these, and then only for the chromium one.
const CANVASKIT = [
  'canvaskit/chromium/canvaskit.js',
  'canvaskit/chromium/canvaskit.wasm',
];
const TOKEN = /registerWorker\("([^"]*)"/;

function files(dir, root = dir) {
  return readdirSync(dir).sort().flatMap(name => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? files(path, root) : [relative(root, path)];
  });
}

export function buildHash(dir) {
  const hash = createHash('sha256');
  for (const name of files(dir)) {
    if (name === BOOTSTRAP) continue;
    let bytes = readFileSync(join(dir, name));
    // Ignore our own output so stamping twice preserves the build identity.
    if (name === 'version.json') {
      const metadata = JSON.parse(bytes.toString());
      delete metadata.pantasBuildVersion;
      bytes = JSON.stringify(metadata);
    }
    // The stamped sizes are this hash's own output; hash the unstamped line.
    if (name === WORKER) bytes = Buffer.from(bytes.toString().replace(SIZES_LINE, () => `const LOAD_SIZES = null; ${SIZES_COMMENT}`));
    hash.update(name).update('\0').update(bytes).update('\0');
  }
  return hash.digest('hex').slice(0, 12);
}

// True when the build config says CanvasKit is served from this build's own
// folder (flutter build web --no-web-resources-cdn). Anything else, or a config
// that cannot be read, counts as the CDN, which only lowers the total.
function loadsCanvasKitLocally(dir) {
  const path = join(dir, BOOTSTRAP);
  return existsSync(path) && /"useLocalCanvasKit"\s*:\s*true/.test(readFileSync(path, 'utf8'));
}

// Writes the sizes of the files this build loads from its own origin before the
// first frame into the worker script, or null when there is no main script.
export function writeLoadSizes(dir) {
  const path = join(dir, WORKER);
  if (!existsSync(path)) return null;
  const size = name => (existsSync(join(dir, name)) ? statSync(join(dir, name)).size : null);
  let sizes = null;
  if (size(MAIN) !== null) {
    sizes = {[MAIN]: size(MAIN)};
    if (loadsCanvasKitLocally(dir) && CANVASKIT.every(name => size(name) !== null)) {
      for (const name of CANVASKIT) sizes[name] = size(name);
    }
  }
  const line = `const LOAD_SIZES = ${JSON.stringify(sizes)}; ${SIZES_COMMENT}`;
  writeFileSync(path, readFileSync(path, 'utf8').replace(SIZES_LINE, () => line));
  return sizes;
}

export function stamp(dir) {
  const path = join(dir, BOOTSTRAP);
  const source = readFileSync(path, 'utf8');
  const match = source.match(TOKEN);
  if (!match) throw new Error(`No registerWorker("...") version in ${path}.`);
  const base = match[1].split('-')[0];
  const version = `${base}-${buildHash(dir)}`;
  writeFileSync(path, source.replace(TOKEN, `registerWorker("${version}"`));
  writeLoadSizes(dir);
  const metadataPath = join(dir, 'version.json');
  if (existsSync(metadataPath)) {
    const metadata = JSON.parse(readFileSync(metadataPath, 'utf8'));
    metadata.pantasBuildVersion = version;
    writeFileSync(metadataPath, JSON.stringify(metadata));
  }
  return version;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  console.log(`Service worker version: ${stamp(process.argv[2] ?? 'build/web')}`);
}
