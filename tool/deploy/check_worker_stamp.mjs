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
// Usage: node tool/deploy/check_worker_stamp.mjs [build/web]
import {existsSync, readdirSync, readFileSync, statSync} from 'node:fs';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {buildFolder, fingerprints, listHash, workerBuild} from '../web/stamp_worker_version.mjs';

// What the app cannot boot without, inside the build folder.
const REQUIRED = [
  'flutter_bootstrap.js', 'main.dart.js', 'pantas_pwa.js', 'pantas_history.js', 'pantas_welcome.js', 'pantas_splash.js',
  'drift_worker.js', 'sqlite3.wasm', 'assets/AssetManifest.bin', 'assets/FontManifest.json',
  'canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm', 'canvaskit/chromium/canvaskit.js', 'canvaskit/chromium/canvaskit.wasm',
];
const REQUIRED_AT_ROOT = ['index.html', 'pantas_sw.js', 'version.json', 'manifest.json'];
// Files a page loads. None may sit at the root of a release.
const LOADED_AT_ROOT = /^(main\.dart\.[\w.]+|flutter(_bootstrap)?\.js|drift_worker\.js|sqlite3\.wasm|pantas_(?!sw\.js$)[\w-]+\.js|assets\/.*|canvaskit\/.*)$/;

function listFiles(dir, root = dir) {
  return readdirSync(dir).flatMap(name => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? listFiles(path, root) : [path.slice(root.length + 1)];
  });
}

/** Returns a list of problems; empty means the worker matches the build and the build is complete. */
export function stampProblems(dir) {
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
  for (const name of REQUIRED) {
    if (!existsSync(join(dir, build.base, name))) problems.push(`required file missing: ${build.base}${name}`);
    else if (!(build.base + name in build.files)) problems.push(`required file missing from the worker's list: ${build.base}${name}`);
  }
  for (const name of listFiles(dir)) {
    if (LOADED_AT_ROOT.test(name)) problems.push(`${name} is at the root: every file a page loads belongs in ${build.base}`);
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
    for (const [, name] of page.matchAll(/<script[^>]*\bsrc="([^"]+)"/g)) {
      if (!name.startsWith(build.base)) problems.push(`index.html loads ${name} from outside ${build.base}`);
    }
    for (const name of ['pantas_pwa.js', 'flutter_bootstrap.js']) {
      if (!page.includes(`"${build.base}${name}"`)) problems.push(`index.html does not load ${build.base}${name}`);
    }
  }
  const metadata = join(dir, 'version.json');
  if (existsSync(metadata) && JSON.parse(readFileSync(metadata, 'utf8')).pantasBuildVersion !== build.id) {
    problems.push('version.json names another build than the worker');
  }
  return problems;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const dir = process.argv[2] ?? 'build/web';
  const problems = stampProblems(dir);
  if (problems.length) {
    console.error(`Refusing ${dir}:\n- ${problems.join('\n- ')}`);
    process.exit(1);
  }
  console.log(`Worker stamp matches ${dir}`);
}
