// Run after `flutter build web`. The stamp turns the build into a release:
//
// 1. Build folder. Every file a page loads moves into b/<id>/ (the helper scripts,
//    flutter_bootstrap.js, main.dart.js and its parts, sqlite3.wasm,
//    assets/, canvaskit/) and the page names those URLs. The root keeps only what the
//    browser or a link needs at a fixed address: the page, the service worker,
//    version.json, manifest.json, the icons, the database worker (one address for
//    every build, see ROOT_FILES) and a few files nothing loads. A page
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
import {cpSync, existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, renameSync, rmSync, rmdirSync, statSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
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
// drift_worker.js stays at its root address in every build (fix list item 1, Nov 26): a
// browser keys a shared worker by address and name, so one address means one database
// owner across builds, and the worker that shipped before build folders (which caches it
// at that address) serves identical bytes. The deploy guard pins those bytes.
const ROOT_FILES = new Set([
  PAGE, WORKER, 'version.json', 'manifest.json', 'favicon.png', 'og-image.png',
  'flutter_service_worker.js', 'drift_worker.js',
]);
// Files no deploy serves: tool/cloudflare-app/deploy.sh removes them from the folder it stages
// (the Firebase rollback publishes the folder as given and ignores hidden files). The stamp
// neither moves, lists nor hashes them, so removing them cannot change a build's id (audit 3).
// The deploy guard uses the same list, through buildHash.
export const NOT_SERVED = ['README.md', '.last_build_id', '__/'];
export const isServed = name => !NOT_SERVED.some(entry => (entry.endsWith('/') ? name.startsWith(entry) : name === entry));
// A package asks for this file by a fixed address relative to the page (purchases_flutter's
// web plugin hard-codes it), so it cannot follow the folder. It is in the startup set, so a
// controlled page gets the copy its build verified.
export const FIXED_ADDRESS = ['assets/packages/purchases_flutter/assets/web/purchases_js_hybrid_mappings.js'];
// The Firebase SDK files: the page's import map names them at these root addresses, which carry
// the SDK version, so every build shares one copy and the map (and the page's security policy
// hash for it) does not change with the build (E-210, tool/web/firebase_sdk.mjs).
const SDK_ROOT = 'firebase_sdk/';
const atRoot = name => !isServed(name) || ROOT_FILES.has(name) || name.startsWith('icons/') || name.startsWith(SDK_ROOT) || FIXED_ADDRESS.includes(name);

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
// canvaskit file except the full variant (below).
const EXACT = new Set([
  'flutter.js', 'flutter_bootstrap.js', 'main.dart.js', 'main.dart.mjs', 'main.dart.wasm', 'sqlite3.wasm',
]);
// At the root and in the set: the page, what a fixed address needs, and (below) the Firebase SDK.
const ROOT_SET = new Set([PAGE, 'manifest.json', 'favicon.png', 'drift_worker.js']);
const PARTS = /^main\.dart\.(js|mjs)_\d+\.part\.(js|mjs)$|^main\.dart\.wasm_\d+\.part\.wasm$/;
const HELPERS = /^pantas_(?!sw\.js$)[\w-]+\.js$/;
const EXCLUDED = new Set(['assets/NOTICES']);
// The one CanvasKit build the app uses: full, in every browser. web/flutter_bootstrap.js pins it
// (canvasKitVariant), so Flutter never asks for the chromium variant, which a browser would
// otherwise get on Flutter's own checks that a service worker cannot all make (audit 2, High 5).
// Storing only this one halves the renderer bytes an update downloads.
const RENDERER = ['canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm'];

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
  const canvasKit = new Set(localCanvasKit(dir, folder) ? RENDERER : []);
  return files(dir).filter(path => {
    if (!folder || !path.startsWith(folder)) {
      return ROOT_SET.has(path) || path.startsWith('icons/') || path.startsWith(SDK_ROOT) || FIXED_ADDRESS.includes(path);
    }
    const name = path.slice(folder.length);
    if (EXCLUDED.has(name) || name.endsWith('.map')) return false;
    return EXACT.has(name) || PARTS.test(name) || HELPERS.test(name) || name.startsWith('assets/') || canvasKit.has(name);
  });
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
  for (const name of files(dir).filter(isServed)) {
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

// The Roboto file the Flutter web engine fetches from fonts.gstatic.com at every start, unless the
// font manifest already has a Roboto family (canvaskit/fonts.dart, loadAssetFonts). web/fonts holds
// the same bytes; the stamp registers them as an asset of the build, so cold start asks no font host
// and the file is verified and stored like every other. Web only: pubspec.yaml is not touched.
export const ROBOTO = {
  file: 'fonts/roboto/v32/KFOmCnqEu92Fr1Me4GZLCzYlKw.woff2',
  sha256: '35b02ca266b79eb4996590f15817425a1ce9ebf48f84471843233ff614656bf2',
};

// Moves the font from the root (where web/ puts it) into assets/, where the engine looks for a
// manifest font, and adds the family to assets/FontManifest.json. Safe to run again.
function registerRoboto(dir) {
  const manifestPath = join(dir, 'assets/FontManifest.json');
  if (existsSync(join(dir, ROBOTO.file))) move(dir, ROBOTO.file, `assets/${ROBOTO.file}`);
  if (!existsSync(join(dir, 'assets', ROBOTO.file)) || !existsSync(manifestPath)) return;
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  if (manifest.some(family => family.family === 'Roboto')) return;
  manifest.push({family: 'Roboto', fonts: [{asset: ROBOTO.file}]});
  writeFileSync(manifestPath, JSON.stringify(manifest));
}

/** True for a reference to a file of this build: not a scheme address, a path from the root or a fragment. */
export const isLocal = target => target !== '' && !/^([a-z][a-z0-9+.-]*:|\/|#)/i.test(target);

/**
 * Calls `change(reference)` for every reference to a file in a page and puts back what it returns:
 * `src`, `href` and `poster` attributes (any case, any spaces or line breaks around the equals sign,
 * either quote or none, and spaces inside the quotes), each address of a `srcset`, and `url()` and
 * `@import "..."` in style blocks and style attributes. Comments, and the text of scripts, are left alone.
 * Shared by the stamp (which rewrites) and the deploy guard (which checks what is left).
 */
export function mapReferences(html, change) {
  const value = /(?:"([^"]*)"|'([^']*)'|([^\s"'<>`=]+))/;
  const attribute = new RegExp(`(\\b(?:src|href|poster)\\s*=\\s*)${value.source}`, 'gi');
  const srcset = new RegExp(`(\\bsrcset\\s*=\\s*)(?:"([^"]*)"|'([^']*)')`, 'gi');
  const url = /\burl\((\s*)(["']?)([^"')]*?)\2(\s*)\)/g;
  const imported = /(@import\s*)(["'])([^"']*)\2/g;
  const quoted = (head, double, single, bare) => {
    if (bare !== undefined) return head + change(bare);
    const quote = double !== undefined ? '"' : "'";
    return `${head}${quote}${change(double ?? single)}${quote}`;
  };
  const inTag = tag => tag
    .replace(attribute, (all, head, double, single, bare) => quoted(head, double, single, bare))
    .replace(srcset, (all, head, double, single) => {
      const quote = double !== undefined ? '"' : "'";
      const candidates = (double ?? single).split(',').map(candidate => {
        const [, before, address, after] = /^(\s*)(\S*)([\s\S]*)$/.exec(candidate);
        return before + (address ? change(address) : address) + after;
      });
      return `${head}${quote}${candidates.join(',')}${quote}`;
    })
    .replace(url, (all, before, quote, target, after) => `url(${before}${quote}${change(target)}${quote}${after})`);
  const inStyle = text => text
    .replace(url, (all, before, quote, target, after) => `url(${before}${quote}${change(target)}${quote}${after})`)
    .replace(imported, (all, head, quote, target) => `${head}${quote}${change(target)}${quote}`);
  // Comments and script text are copied as they are; a start tag gets its attributes read;
  // everything else outside a script (style blocks) gets its url() and @import read.
  return html.replace(/(<!--[\s\S]*?-->)|(<script\b[^>]*>[\s\S]*?<\/script\s*>)|(<[a-zA-Z][^>]*>)|([^<]+)/gi,
    (all, comment, script, tag, text) => {
      if (comment) return comment;
      if (script) {
        const [, open, body, close] = /^(<script\b[^>]*>)([\s\S]*?)(<\/script\s*>)$/i.exec(script);
        return inTag(open) + body + close;
      }
      if (tag) return inTag(tag);
      return text === undefined ? all : inStyle(text);
    });
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

/**
 * The version the stamp would give this tree now: the bytes of a stamped build, put back
 * the way Flutter wrote them (in a copy) and hashed. The deploy guard compares it with the
 * version the build carries, so changed bytes under an unchanged immutable address show.
 */
export function recomputedVersion(dir) {
  const copy = mkdtempSync(join(tmpdir(), 'pantas-version-'));
  try {
    cpSync(dir, copy, {recursive: true});
    unstamp(copy);
    const match = readFileSync(join(copy, BOOTSTRAP), 'utf8').match(TOKEN);
    if (!match) throw new Error(`No registerWorker("...") version in ${BOOTSTRAP}.`);
    return `${match[1].split('-')[0]}-${buildHash(copy)}`;
  } finally {
    rmSync(copy, {recursive: true, force: true});
  }
}

export function stamp(dir) {
  for (const name of [PAGE, WORKER]) {
    if (!existsSync(join(dir, name))) throw new Error(`No ${name} in ${dir}.`);
  }
  unstamp(dir);
  registerRoboto(dir);
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
  // Every local reference in the page, in any valid form (see mapReferences), follows its file
  // into the folder. One that names nothing is refused: it would be left pointing at the
  // root, where the file no longer is.
  // The folder goes in after any ./ prefix and the rest of the text stays as written, so
  // removing the folder gives the page back exactly (stamping again keeps the same id).
  const follow = reference => {
    const [, lead, body, tail] = /^(\s*)([\s\S]*?)(\s*)$/.exec(reference);
    const [, path, suffix] = /^([^?#]*)(.*)$/s.exec(body);
    if (!isLocal(path)) return reference;
    const [, prefix, name] = /^((?:\.\/)*)(.*)$/s.exec(path);
    if (movedSet.has(name)) return lead + prefix + folder + name + suffix + tail;
    if (existsSync(join(dir, name)) && statSync(join(dir, name)).isFile()) return reference;
    throw new Error(`${PAGE} names ${name}, which is not in the build.`);
  };
  writeFileSync(pagePath, mapReferences(readFileSync(pagePath, 'utf8'), follow));
  for (const name of moved) move(dir, name, folder + name);
  // Last: every file is final, so these are the hashes the worker verifies.
  const list = fingerprints(dir);
  const constant = {id: version, base: folder, list: listHash(list), files: list};
  writeFileSync(workerPath, worker.replace(BUILD, () => `/*pantas-build*/ ${JSON.stringify(constant)} /*end-pantas-build*/`));
  return version;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const dir = process.argv[2] ?? 'build/web';
  console.log(`Service worker version: ${stamp(dir)}`);
  const inSet = new Set(startupSet(dir));
  const bytes = [...inSet].reduce((sum, name) => sum + statSync(join(dir, name)).size, 0);
  console.log(`Startup set: ${inSet.size} files, ${(bytes / 1048576).toFixed(1)} MB (full CanvasKit only, pinned in every browser)`);
  console.log(`Left out: ${files(dir).filter(name => !inSet.has(name)).join(', ')}`);
}
