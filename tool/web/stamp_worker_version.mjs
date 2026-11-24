// Run after `flutter build web`. Flutter's service worker version does not
// change when only Dart code changes, so pantas_sw.js kept serving the old
// main.dart.js from its cache after such a deploy. This appends a hash of every
// built file to the version in flutter_bootstrap.js, so each build gets its own
// worker and cache.
//
// It also writes pantas_load_sizes.json before hashing: the decoded size of each
// file the Flutter loader fetches before the first frame. The service worker
// divides the bytes it has passed on by these sizes for the loading percent.
//
// Usage: node tool/web/stamp_worker_version.mjs [build/web]
import {createHash} from 'node:crypto';
import {existsSync, readdirSync, readFileSync, rmSync, statSync, writeFileSync} from 'node:fs';
import {join, relative} from 'node:path';

const BOOTSTRAP = 'flutter_bootstrap.js';
export const LOAD_SIZES = 'pantas_load_sizes.json';
const MAIN = 'main.dart.js';
// Flutter picks one canvaskit build at run time: the chromium one on browsers
// that support it, the full one elsewhere. The page fetches one of the two.
const CANVASKIT = [
  ['canvaskit/chromium/canvaskit.js', 'canvaskit/chromium/canvaskit.wasm'],
  ['canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm'],
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
    hash.update(name).update('\0').update(bytes).update('\0');
  }
  return hash.digest('hex').slice(0, 12);
}

// Writes the size list, or removes a stale one when the build has no main
// script. Without the list the page shows the spinner only.
export function writeLoadSizes(dir) {
  const path = join(dir, LOAD_SIZES);
  const size = name => {
    const file = join(dir, name);
    return existsSync(file) ? statSync(file).size : null;
  };
  if (size(MAIN) === null) {
    rmSync(path, {force: true});
    return null;
  }
  const files = {[MAIN]: size(MAIN)};
  const alternatives = [];
  const variants = CANVASKIT.filter(group => group.every(name => size(name) !== null));
  for (const group of variants) for (const name of group) files[name] = size(name);
  if (variants.length > 0) alternatives.push(variants);
  const list = {v: 1, files, alternatives};
  writeFileSync(path, JSON.stringify(list));
  return list;
}

export function stamp(dir) {
  writeLoadSizes(dir);
  const path = join(dir, BOOTSTRAP);
  const source = readFileSync(path, 'utf8');
  const match = source.match(TOKEN);
  if (!match) throw new Error(`No registerWorker("...") version in ${path}.`);
  const base = match[1].split('-')[0];
  const version = `${base}-${buildHash(dir)}`;
  writeFileSync(path, source.replace(TOKEN, `registerWorker("${version}"`));
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
