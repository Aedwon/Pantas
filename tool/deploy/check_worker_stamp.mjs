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
// Usage: node tool/deploy/check_worker_stamp.mjs [build/web] --target staging|prod
// Run by tool/cloudflare-app/deploy.sh and tool/deploy/firebase_rollback.sh.
// The command line cannot change the pinned bytes. Tests give stampProblems their own pins.
import {createHash} from 'node:crypto';
import {existsSync, readdirSync, readFileSync, statSync} from 'node:fs';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {buildFolder, FIXED_ADDRESS, fingerprints, isLocal, listHash, mapReferences, recomputedVersion, rootRelativeName, ROBOTO, workerBuild} from '../web/stamp_worker_version.mjs';
import {importMap, SDK_FILES, SDK_FOLDER, SDK_PATHS} from '../web/firebase_sdk.mjs';

// What the app cannot boot without, inside the build folder.
const REQUIRED = [
  'flutter_bootstrap.js', 'main.dart.js', 'pantas_pwa.js', 'pantas_history.js', 'pantas_welcome.js', 'pantas_splash.js',
  'sqlite3.wasm', 'assets/AssetManifest.bin', 'assets/FontManifest.json', `assets/${ROBOTO.file}`,
  // Full CanvasKit only: the bootstrap pins it in every browser, so the chromium variant is never asked for.
  'canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm',
];
// At the root, and in the worker's list. The database worker keeps one address for every build.
// The Firebase SDK files sit at root addresses that carry the SDK version (E-210): the page's
// import map sends FlutterFire's imports there, and the worker stores them, so the app starts
// with no connection.
const REQUIRED_AT_ROOT = ['index.html', 'pantas_sw.js', 'version.json', 'manifest.json', 'drift_worker.js', FIXED_ADDRESS[0], ...SDK_PATHS];
const ROOT_IN_LIST = ['drift_worker.js', FIXED_ADDRESS[0], ...SDK_PATHS];
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
  // The Firebase SDK: Google's bytes for the version FlutterFire pins (tool/web/firebase_sdk.mjs).
  ...Object.fromEntries(Object.entries(SDK_FILES).map(([name, hash]) => [SDK_FOLDER + name, hash])),
};
// Every flavor's code is in every build, so the flavor shows only in what the build step
// passes in: the App Check site key. This is staging's public key (tool/deploy/staging_web.sh).
const STAGING_SITE_KEY = '6Lcp8xUuAAAAAICQRMX8-J2JYzU5dxKsj8Qp3sQa';
// Prod's public key: every prod page serves it (the opening build, build_prod.sh).
const PROD_SITE_KEY = '6LejBBIuAAAAAEMg6326sPwsk_Ipi9DN6-BDX5jH';
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
      problems.push(SDK_PATHS.includes(name)
        ? `${name} differs from the pinned Firebase SDK file: the page would run SDK code nobody checked`
        : `${name} differs from the file prod serves today: the worker that shipped before build folders would serve its own copy to this build's page`);
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
    for (const [, name] of page.matchAll(/<script[^>]*\bsrc\s*=\s*["']?([^"'\s>]+)/g)) {
      if (!name.replace(/^(\.\/)+/, '').startsWith(build.base)) problems.push(`index.html loads ${name} from outside ${build.base}`);
    }
    // Every local reference, in any spelling, names a file the build has. The stamp rewrites them and
    // refuses a missing one; this is the same reading of the page applied to the folder that ships.
    mapReferences(page, reference => {
      const [, , body] = /^(\s*)([\s\S]*?)\s*$/.exec(reference);
      const path = /^([^?#]*)/.exec(body)[1];
      const name = path.replace(/^(\.\/)+/, '');
      const rooted = rootRelativeName(path);
      if (rooted !== null && !existsSync(join(dir, rooted)) && existsSync(join(dir, build.base, rooted))) {
        problems.push(`index.html names /${rooted}, which the stamp moved into ${build.base}: the page would look for it at the root`);
      }
      if (isLocal(path) && !(existsSync(join(dir, name)) && statSync(join(dir, name)).isFile())) {
        problems.push(`index.html names ${name}, which is not in the build`);
      }
      return reference;
    });
    // FlutterFire imports each SDK file from gstatic; the import map sends every one of those
    // addresses to our copy. A missing or changed map sends the app to Google again, and a
    // phone with no connection to Google never opens its storage (E-210).
    const map = /<script type="importmap">\s*([\s\S]*?)\s*<\/script>/.exec(page);
    if (!map) problems.push('index.html has no import map for the Firebase SDK: the app would load it from Google, and fail with no connection');
    else {
      let imports = {};
      try {
        imports = JSON.parse(map[1]).imports ?? {};
      } catch {
        problems.push('the import map in index.html is not JSON');
      }
      for (const [address, target] of Object.entries(importMap().imports)) {
        if (imports[address] !== target) problems.push(`the import map does not send ${address} to ${target}`);
      }
    }
    for (const name of ['pantas_pwa.js', 'flutter_bootstrap.js']) {
      if (!new RegExp(`["'](\\./)*${build.base}${name.replace('.', '\\.')}["']`).test(page)) problems.push(`index.html does not load ${build.base}${name}`);
    }
  }
  const metadata = join(dir, 'version.json');
  if (existsSync(metadata) && JSON.parse(readFileSync(metadata, 'utf8')).pantasBuildVersion !== build.id) {
    problems.push('version.json names another build than the worker');
  }
  problems.push(...runtimeProblems(dir, build, pins));
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
function runtimeProblems(dir, build, pins) {
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
    // Without a Roboto family the engine asks fonts.gstatic.com for it at every start (E-210).
    if (!fonts.some(({asset}) => asset === ROBOTO.file)) {
      problems.push(`FontManifest.json has no Roboto family: the engine would fetch it from fonts.gstatic.com at every start (the stamp adds ${ROBOTO.file})`);
    }
    const font = join(dir, build.base, 'assets', ROBOTO.file);
    if (existsSync(font) && sha256(readFileSync(font)) !== (pins[`assets/${ROBOTO.file}`] ?? ROBOTO.sha256)) {
      problems.push(`assets/${ROBOTO.file} differs from the Roboto file the engine fetches: the text would look different`);
    }
  }
  return problems;
}

function targetProblems(dir, build, target) {
  const main = join(dir, build.base, 'main.dart.js');
  if (!existsSync(main)) return [];
  const text = readFileSync(main, 'utf8');
  const forStaging = text.includes(STAGING_SITE_KEY);
  if (target === 'staging' && !forStaging) return ['this build was not built for staging (it lacks staging\'s App Check site key): rebuild with tool/deploy/staging_web.sh'];
  if (target === 'prod' && forStaging) return ['this build was built for staging, not prod (it carries staging\'s App Check site key)'];
  // A prod build must carry prod's exact key, as a quoted string (Dart folds the define in as a
  // literal). A release web build without it throws before storage opens
  // (lib/core/platform/app_check.dart), and any other key fails App Check for every student.
  if (target === 'prod' && !text.includes(`"${PROD_SITE_KEY}"`) && !text.includes(`'${PROD_SITE_KEY}'`)) {
    return [`this build does not carry prod's App Check site key (a release web build without it cannot start): rebuild with --dart-define=APP_CHECK_WEB_SITE_KEY=${PROD_SITE_KEY}`];
  }
  return [];
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const args = process.argv.slice(2);
  const option = name => (args.includes(name) ? args[args.indexOf(name) + 1] : undefined);
  const dir = args.find((arg, index) => !arg.startsWith('--') && !(index > 0 && args[index - 1].startsWith('--'))) ?? 'build/web';
  const target = option('--target');
  // The pinned bytes cannot be swapped from the command line: only --target is an option.
  if (!['staging', 'prod'].includes(target) || args.some(arg => arg.startsWith('--') && arg !== '--target')) {
    const unknown = args.filter(arg => arg.startsWith('--') && arg !== '--target');
    if (unknown.length) console.error(`Unknown option ${unknown.join(', ')}`);
    console.error('Usage: node tool/deploy/check_worker_stamp.mjs [build/web] --target staging|prod');
    process.exit(2);
  }
  const problems = stampProblems(dir, {target});
  if (problems.length) {
    console.error(`Refusing ${dir}:\n- ${problems.join('\n- ')}`);
    process.exit(1);
  }
  console.log(`Worker stamp matches ${dir} (${target})`);
}
