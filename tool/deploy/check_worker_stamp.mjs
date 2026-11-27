// Refuses a web build that is not a complete stamped release: a worker stamped for
// exactly the files in it, every file a page loads inside the build folder b/<id>/,
// and every file the app needs to boot present. An unstamped worker (the dev behavior
// or the one that shipped before build folders), a build changed after the stamp, and
// a build missing a renderer or database file would leave phones with a worker that
// cannot verify its own app or an app that cannot start. Run by
// tool/cloudflare-app/deploy.sh on the exact folder it stages, before anything is uploaded.
//
// The first release with build folders only rolls forward: the worker that shipped
// before them is refused here, because once phones hold a stamped build, deploying
// the old worker would put the mixing back. Roll back by deploying an earlier
// stamped build.
// Usage: node tool/deploy/check_worker_stamp.mjs [build/web] --target staging|prod [--pins pins.json]
// Run by tool/cloudflare-app/deploy.sh and tool/deploy/firebase_rollback.sh.
// `--pins` replaces PINNED_ROOT_FILES; the tests use it with stand-in bytes.
import {createHash} from 'node:crypto';
import {existsSync, readdirSync, readFileSync, statSync} from 'node:fs';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {buildFolder, FIXED_ADDRESS, fingerprints, listHash, recomputedVersion, workerBuild} from '../web/stamp_worker_version.mjs';

// What the app cannot boot without, inside the build folder.
const REQUIRED = [
  'flutter_bootstrap.js', 'main.dart.js', 'pantas_pwa.js', 'pantas_history.js', 'pantas_welcome.js', 'pantas_splash.js',
  'sqlite3.wasm', 'assets/AssetManifest.bin', 'assets/FontManifest.json',
  'canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm', 'canvaskit/chromium/canvaskit.js', 'canvaskit/chromium/canvaskit.wasm',
];
// At the root, and in the worker's list. The database worker keeps one address for every build.
const REQUIRED_AT_ROOT = ['index.html', 'pantas_sw.js', 'version.json', 'manifest.json', 'drift_worker.js', FIXED_ADDRESS[0]];
const ROOT_IN_LIST = ['drift_worker.js', FIXED_ADDRESS[0]];
// Root files that prod serves today and that every build must serve byte for byte. The worker
// that shipped before build folders caches them at these addresses and serves them to a page
// of the new build, so any other bytes would be a mix (fix list items 1 and 5, Nov 26).
// drift_worker.js: unchanged since the first web commit (5cd9f119c).
// The RevenueCat script: the file of the locked purchases_flutter 10.8.0 (pubspec.lock). It is
// pinned from the locked package, because nothing here may read prod; a test checks the pin
// against the package whenever it is installed. A new SDK needs a new address first.
export const PINNED_ROOT_FILES = {
  'drift_worker.js': '88a90a723fd84013c92fe5106fd0b4d324279224195f94ea33bcae94477ef2a0',
  [FIXED_ADDRESS[0]]: '58dce52022d4ddfd7154fde667bc1343e87b6b6bbdc3a596dade262125248010',
};
// Every flavor's code is in every build, so the flavor shows only in what the build step
// passes in: the App Check site key. This is staging's public key (tool/deploy/staging_web.sh).
const STAGING_SITE_KEY = '6Lcp8xUuAAAAAICQRMX8-J2JYzU5dxKsj8Qp3sQa';
// Files a page loads. None may sit at the root of a release.
const LOADED_AT_ROOT = /^(main\.dart\.[\w.]+|flutter(_bootstrap)?\.js|sqlite3\.wasm|pantas_(?!sw\.js$)[\w-]+\.js|assets\/.*|canvaskit\/.*)$/;
const sha256 = bytes => createHash('sha256').update(bytes).digest('hex');

function listFiles(dir, root = dir) {
  return readdirSync(dir).flatMap(name => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? listFiles(path, root) : [path.slice(root.length + 1)];
  });
}

/** Returns a list of problems; empty means the worker matches the build and the build is complete. */
export function stampProblems(dir, {pins = PINNED_ROOT_FILES, target = null} = {}) {
  const path = join(dir, 'pantas_sw.js');
  if (!existsSync(path)) return ['pantas_sw.js is missing'];
  let build;
  try {
    build = workerBuild(readFileSync(path, 'utf8'));
  } catch (error) {
    return [`${error.message} That is the worker that shipped before build folders, or another file. The first release with build folders only rolls forward (one-way): ` +
      'a build with the old worker is refused; roll back with an earlier stamped build.'];
  }
  if (!build) {
    return ['pantas_sw.js is unstamped (dev, or the worker that shipped before build folders): run node tool/web/stamp_worker_version.mjs after the build. ' +
      'The first release with build folders is one-way, so a build with the old worker is refused; roll back with an earlier stamped build.'];
  }
  const problems = [];
  const folders = existsSync(join(dir, 'b')) ? readdirSync(join(dir, 'b')) : [];
  const folder = buildFolder(dir);
  if (!build.base || !build.list) {
    return ['pantas_sw.js was stamped before build folders (it has no build folder or list hash): run node tool/web/stamp_worker_version.mjs again'];
  }
  if (folders.length !== 1) problems.push(`the build must hold exactly one build folder under b/, not ${folders.length ? `more than one build folder: ${folders.join(', ')}` : 'none'}`);
  if (folder !== build.base) problems.push(`the worker names ${build.base} but the build folder is ${folder || 'missing'}`);
  if (build.list !== listHash(build.files)) problems.push("the worker's list hash does not match its list");
  const expected = fingerprints(dir);
  for (const name of new Set([...Object.keys(expected), ...Object.keys(build.files)])) {
    if (!(name in build.files)) problems.push(`${name || 'page'} is in the build but not in the worker's list`);
    else if (!(name in expected)) problems.push(`${name} is in the worker's list but not in the build`);
    else if (build.files[name] !== expected[name]) problems.push(`${name} changed after the stamp`);
  }
  for (const name of REQUIRED_AT_ROOT) {
    if (!existsSync(join(dir, name))) problems.push(`required file missing: ${name}`);
  }
  for (const name of ROOT_IN_LIST) {
    if (existsSync(join(dir, name)) && !(name in build.files)) problems.push(`required file missing from the worker's list: ${name}`);
  }
  for (const [name, hash] of Object.entries(pins)) {
    if (existsSync(join(dir, name)) && sha256(readFileSync(join(dir, name))) !== hash) {
      problems.push(`${name} differs from the file prod serves today: the worker that shipped before build folders would serve its own copy to this build's page`);
    }
  }
  for (const name of REQUIRED) {
    if (!existsSync(join(dir, build.base, name))) problems.push(`required file missing: ${build.base}${name}`);
    else if (!(build.base + name in build.files)) problems.push(`required file missing from the worker's list: ${build.base}${name}`);
  }
  for (const name of listFiles(dir)) {
    if (LOADED_AT_ROOT.test(name) && !FIXED_ADDRESS.includes(name)) problems.push(`${name} is at the root: every file a page loads belongs in ${build.base}`);
  }
  if (existsSync(join(dir, build.base, 'flutter_bootstrap.js'))) {
    const bootstrap = readFileSync(join(dir, build.base, 'flutter_bootstrap.js'), 'utf8');
    if (!bootstrap.includes(`registerWorker("${build.id}"`)) problems.push('flutter_bootstrap.js names another build than the worker');
    if (!bootstrap.includes(`window.pantasBuildBase = "${build.base}";`)) problems.push('flutter_bootstrap.js does not name the build folder');
    if (!/"useLocalCanvasKit"\s*:\s*true/.test(bootstrap)) {
      problems.push('the build loads CanvasKit from Google\'s servers: build with flutter build web --release --no-web-resources-cdn so the renderer can be stored');
    }
  }
  if (existsSync(join(dir, 'index.html'))) {
    const page = readFileSync(join(dir, 'index.html'), 'utf8');
    for (const [, name] of page.matchAll(/<script[^>]*\bsrc=["']([^"']+)["']/g)) {
      if (!name.replace(/^(\.\/)+/, '').startsWith(build.base)) problems.push(`index.html loads ${name} from outside ${build.base}`);
    }
    for (const name of ['pantas_pwa.js', 'flutter_bootstrap.js']) {
      if (!new RegExp(`["'](\\./)*${build.base}${name.replace('.', '\\.')}["']`).test(page)) problems.push(`index.html does not load ${build.base}${name}`);
    }
  }
  const metadata = join(dir, 'version.json');
  if (existsSync(metadata) && JSON.parse(readFileSync(metadata, 'utf8')).pantasBuildVersion !== build.id) {
    problems.push('version.json names another build than the worker');
  }
  problems.push(...runtimeProblems(dir, build));
  // The build id names an address that browsers keep for a year. Bytes that changed under an
  // unchanged id would be served to phones that hold the old ones, even with a refreshed list.
  if (folders.length === 1) {
    try {
      if (recomputedVersion(dir) !== build.id) {
        problems.push(`the build id ${build.id} does not match the bytes of this build: run node tool/web/stamp_worker_version.mjs again`);
      }
    } catch (error) {
      problems.push(`the build id could not be checked: ${error.message}`);
    }
  }
  if (target) problems.push(...targetProblems(dir, build, target));
  return problems;
}

// What the running app asks for by name: the deferred parts main.dart.js names and the fonts
// FontManifest.json names. Each must be in the build and in the worker's list, or the app
// would stop at that screen or font, online or offline.
function runtimeProblems(dir, build) {
  const problems = [];
  const need = (what, file) => {
    if (!existsSync(join(dir, build.base, file))) problems.push(`${what}, which is not in the build`);
    else if (!(build.base + file in build.files)) problems.push(`${what}, which is not in the worker's list`);
  };
  const main = join(dir, build.base, 'main.dart.js');
  if (existsSync(main)) {
    const names = new Set(readFileSync(main, 'utf8').match(/main\.dart\.js_\d+\.part\.js/g) ?? []);
    for (const name of names) need(`main.dart.js names ${name}`, name);
  }
  const manifest = join(dir, build.base, 'assets/FontManifest.json');
  if (existsSync(manifest)) {
    let fonts = [];
    try {
      fonts = JSON.parse(readFileSync(manifest, 'utf8')).flatMap(family => family.fonts ?? []);
    } catch {
      problems.push('FontManifest.json is not a font list');
    }
    for (const {asset} of fonts) need(`FontManifest.json names ${asset}`, `assets/${asset}`);
  }
  return problems;
}

function targetProblems(dir, build, target) {
  const main = join(dir, build.base, 'main.dart.js');
  if (!existsSync(main)) return [];
  const forStaging = readFileSync(main, 'utf8').includes(STAGING_SITE_KEY);
  if (target === 'staging' && !forStaging) return ['this build was not built for staging (it lacks staging\'s App Check site key): rebuild with tool/deploy/staging_web.sh'];
  if (target === 'prod' && forStaging) return ['this build was built for staging, not prod (it carries staging\'s App Check site key)'];
  return [];
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const args = process.argv.slice(2);
  const option = name => (args.includes(name) ? args[args.indexOf(name) + 1] : undefined);
  const dir = args.find((arg, index) => !arg.startsWith('--') && !(index > 0 && args[index - 1].startsWith('--'))) ?? 'build/web';
  const target = option('--target');
  if (!['staging', 'prod'].includes(target)) {
    console.error('Usage: node tool/deploy/check_worker_stamp.mjs [build/web] --target staging|prod [--pins pins.json]');
    process.exit(2);
  }
  const pinsFile = option('--pins');
  const pins = pinsFile ? JSON.parse(readFileSync(pinsFile, 'utf8')) : PINNED_ROOT_FILES;
  const problems = stampProblems(dir, {pins, target});
  if (problems.length) {
    console.error(`Refusing ${dir}:\n- ${problems.join('\n- ')}`);
    process.exit(1);
  }
  console.log(`Worker stamp matches ${dir} (${target})`);
}
