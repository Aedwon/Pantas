import assert from 'node:assert/strict';
import {existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {spawnSync} from 'node:child_process';
import test from 'node:test';
import {createHash} from 'node:crypto';
import {FIXED_ADDRESS, fingerprints, listHash, stamp} from '../web/stamp_worker_version.mjs';
import {constantOf, writeBuild} from '../../test/web/fixtures/sw_fixture_build.mjs';
import {PINNED_ROOT_FILES, stampProblems as realProblems} from './check_worker_stamp.mjs';

const script = new URL('./check_worker_stamp.mjs', import.meta.url).pathname;
const repo = new URL('../../', import.meta.url).pathname;
const canvasKit = ['canvaskit.js', 'canvaskit.wasm', 'chromium/canvaskit.js', 'chromium/canvaskit.wasm'];
const sha = bytes => createHash('sha256').update(bytes).digest('hex');

// The RevenueCat script is 780 KB, too large to keep in the repository, so a fixture build
// carries stand-in bytes and the tests pin those. The real pin is checked against the
// locked package below.
const PURCHASES = FIXED_ADDRESS[0];
const FIXTURE_PURCHASES = 'purchases script as prod serves it';
const pins = {...PINNED_ROOT_FILES, [PURCHASES]: sha(FIXTURE_PURCHASES)};
const pinsFile = join(mkdtempSync(join(tmpdir(), 'stamp-pins-')), 'pins.json');
writeFileSync(pinsFile, JSON.stringify(pins));
const stampProblems = (dir, options = {}) => realProblems(dir, {pins, ...options});

// A release build as the staging and prod steps make it: CanvasKit is local.
function stamped({canvaskit = true} = {}) {
  const dir = mkdtempSync(join(tmpdir(), 'stamp-check-'));
  const files = Object.fromEntries(canvasKit.map(name => [`canvaskit/${name}`, `renderer ${name}`]));
  files[PURCHASES] = FIXTURE_PURCHASES;
  const served = writeBuild(dir, 'A', {files: canvaskit ? files : {[PURCHASES]: FIXTURE_PURCHASES}, localCanvasKit: canvaskit});
  return {dir, base: constantOf(served).base};
}
// Rewrites the worker's list to match the bytes now in the folder, keeping its build id.
function refreshList(dir) {
  const path = join(dir, 'pantas_sw.js');
  const files = fingerprints(dir);
  const text = readFileSync(path, 'utf8').replace(/\/\*pantas-build\*\/ (\{.*?\}) \/\*end-pantas-build\*\//s, (all, json) =>
    `/*pantas-build*/ ${JSON.stringify({...JSON.parse(json), list: listHash(files), files})} /*end-pantas-build*/`);
  writeFileSync(path, text);
}
const edit = (dir, name, change) => writeFileSync(join(dir, name), change(readFileSync(join(dir, name), 'utf8')));
const done = ({dir}) => rmSync(dir, {recursive: true});
const unstampedSource = readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8');
const todaysWorker = readFileSync(new URL('../../test/web/fixtures/pantas_sw_prod_a.js', import.meta.url), 'utf8');

test('a stamped build passes', () => {
  const build = stamped();
  assert.deepEqual(stampProblems(build.dir), []);
  const run = spawnSync('node', [script, build.dir, '--pins', pinsFile, '--target', 'prod']);
  assert.equal(run.status, 0, run.stderr.toString());
  done(build);
});

test('an unstamped worker is refused', () => {
  const build = stamped();
  writeFileSync(join(build.dir, 'pantas_sw.js'), unstampedSource);
  assert.match(stampProblems(build.dir)[0], /unstamped/);
  const run = spawnSync('node', [script, build.dir, '--pins', pinsFile, '--target', 'prod']);
  assert.equal(run.status, 1);
  assert.match(run.stderr.toString(), /Refusing/);
  done(build);
});

test('today\'s worker is refused, because the first release with build folders only rolls forward', () => {
  const build = stamped();
  writeFileSync(join(build.dir, 'pantas_sw.js'), todaysWorker);
  assert.match(stampProblems(build.dir).join('\n'), /one-way|only rolls forward/);
  done(build);
});

test('a startup file changed after the stamp is refused', () => {
  const build = stamped();
  edit(build.dir, `${build.base}main.dart.js`, text => text + '// edited');
  const problems = stampProblems(build.dir);
  assert.equal(problems.length, 2, problems.join('\n'));
  assert.equal(problems[0], `${build.base}main.dart.js changed after the stamp`);
  assert.match(problems[1], /build id .* does not match the bytes/);
  done(build);
});

test('a file added or removed after the stamp is refused', () => {
  const build = stamped();
  writeFileSync(join(build.dir, build.base, 'pantas_extra.js'), 'x');
  assert.match(stampProblems(build.dir).join(), /pantas_extra\.js is in the build but not in the worker/);
  rmSync(join(build.dir, build.base, 'pantas_extra.js'));
  rmSync(join(build.dir, 'drift_worker.js'));
  assert.match(stampProblems(build.dir).join(), /drift_worker\.js is in the worker's list but not in the build/);
  done(build);
});

test('a bootstrap or version.json from another build is refused', () => {
  const build = stamped();
  edit(build.dir, 'version.json', text => text.replace(/"pantasBuildVersion":"[^"]+"/, '"pantasBuildVersion":"other"'));
  assert.match(stampProblems(build.dir).join(), /version\.json names another build/);
  done(build);
});

test('restamping a changed build makes it pass again', () => {
  const build = stamped();
  edit(build.dir, `${build.base}main.dart.js`, text => text + '// edited');
  stamp(build.dir);
  assert.deepEqual(stampProblems(build.dir), []);
  done(build);
});

// ---- The required-file list (Revision 1, item 4) ----

const required = base => [
  'index.html', 'pantas_sw.js', 'version.json', 'manifest.json', 'drift_worker.js', PURCHASES,
  ...['flutter_bootstrap.js', 'main.dart.js', 'pantas_pwa.js', 'pantas_history.js', 'pantas_welcome.js', 'pantas_splash.js',
    'sqlite3.wasm', 'assets/AssetManifest.bin', 'assets/FontManifest.json',
    ...canvasKit.map(name => `canvaskit/${name}`)].map(name => base + name),
];

test('a freshly stamped tree missing a file the app needs is refused, by name', () => {
  const {base} = stamped();
  for (const name of required(base).filter(path => path !== 'pantas_sw.js')) {
    const build = stamped();
    rmSync(join(build.dir, name));
    // Stamped again after the file went missing: the stamp cannot know what the app needs.
    try {
      stamp(build.dir);
    } catch {
      // A build with no page or no bootstrap cannot be stamped at all; the guard sees what is left.
    }
    const problems = stampProblems(build.dir).join('\n');
    const short = name.startsWith(base) ? name.slice(base.length) : name;
    assert.match(problems, /required file missing/, `${name}: ${problems}`);
    assert.ok(problems.includes(short), `${name}: ${problems}`);
    done(build);
  }
});

test('a root file that prod serves today must keep prod\'s bytes (the worker that shipped before build folders serves it from its own cache)', () => {
  const build = stamped();
  edit(build.dir, 'drift_worker.js', text => text + '// a new drift worker');
  stamp(build.dir); // the stamp is honest about the new bytes; the guard still refuses them
  const problems = stampProblems(build.dir).join('\n');
  assert.match(problems, /drift_worker\.js differs from the file prod serves today/);
  done(build);
});

// ---- Fix list item 5 and audit 2, High 6 ----

test('item 5: the RevenueCat root script must be prod\'s bytes, and must be there', () => {
  const changed = stamped();
  edit(changed.dir, PURCHASES, text => text + '// a newer SDK');
  stamp(changed.dir);
  assert.match(stampProblems(changed.dir).join('\n'), /purchases_js_hybrid_mappings\.js differs from the file prod serves today/);
  done(changed);
  const missing = stamped();
  rmSync(join(missing.dir, PURCHASES));
  stamp(missing.dir);
  assert.match(stampProblems(missing.dir).join('\n'), /required file missing: assets\/packages\/purchases_flutter/);
  done(missing);
});

test('item 5: the pinned bytes are those of the locked purchases_flutter package, when the package is installed', t => {
  const lock = readFileSync(join(repo, 'pubspec.lock'), 'utf8');
  const version = /^  purchases_flutter:\n(?:    .*\n)*?    version: "([^"]+)"/m.exec(lock)[1];
  const cache = process.env.PUB_CACHE ?? join(process.env.HOME ?? '', '.pub-cache');
  const file = join(cache, 'hosted/pub.dev', `purchases_flutter-${version}`, 'assets/web/purchases_js_hybrid_mappings.js');
  if (!existsSync(file)) return t.skip(`purchases_flutter ${version} is not in the pub cache`);
  assert.equal(PINNED_ROOT_FILES[PURCHASES], sha(readFileSync(file)),
    `purchases_flutter is ${version}: a new SDK file is a new file at an address today's worker already caches; ` +
    'serve it under a new address or give the worker a rule before changing the pin');
});

test('High 6: a deferred part the app names but the build lacks is refused', () => {
  const build = stamped();
  edit(build.dir, `${build.base}main.dart.js`, text => text + "\nvar q = 'main.dart.js_3.part.js';");
  stamp(build.dir);
  assert.match(stampProblems(build.dir).join('\n'), /main\.dart\.js names main\.dart\.js_3\.part\.js, which is not in the build/);
  done(build);
});

test('High 6: a font the manifest names but the build lacks is refused', () => {
  const build = stamped();
  rmSync(join(build.dir, build.base, 'assets/assets/fonts/Geist-Regular.ttf'));
  stamp(build.dir);
  assert.match(stampProblems(build.dir).join('\n'), /FontManifest\.json names assets\/fonts\/Geist-Regular\.ttf, which is not in the build/);
  done(build);
});

test('High 6: changed Dart bytes under the same immutable build address are refused, even when the list was refreshed to match', () => {
  const build = stamped();
  edit(build.dir, `${build.base}main.dart.js`, text => text + '// changed after the stamp');
  refreshList(build.dir); // the list now agrees with the bytes; the build id, and so the folder, did not change
  const problems = stampProblems(build.dir).join('\n');
  assert.match(problems, /build id .* does not match the bytes of this build/);
  assert.doesNotMatch(problems, /changed after the stamp/, 'only the id check can catch this');
  done(build);
});

// Every flavor's code is in every build, so the flavor is told apart by the App Check
// site key the build step passes (staging's public key is in tool/deploy/staging_web.sh).
const STAGING_KEY = /APP_CHECK_WEB_SITE_KEY=(\S+)/.exec(readFileSync(join(repo, 'tool/deploy/staging_web.sh'), 'utf8'))[1];

test('High 6: the target flavor is checked, so a staging build cannot go to prod or the other way round', () => {
  const prodBuild = stamped();
  assert.deepEqual(stampProblems(prodBuild.dir, {target: 'prod'}), []);
  assert.match(stampProblems(prodBuild.dir, {target: 'staging'}).join('\n'), /not built for staging/);
  done(prodBuild);
  const stagingBuild = stamped();
  edit(stagingBuild.dir, `${stagingBuild.base}main.dart.js`, text => text + `\nvar k = "${STAGING_KEY}";`);
  stamp(stagingBuild.dir);
  assert.deepEqual(stampProblems(stagingBuild.dir, {target: 'staging'}), []);
  assert.match(stampProblems(stagingBuild.dir, {target: 'prod'}).join('\n'), /built for staging, not prod/);
  done(stagingBuild);
});

test('High 6: the command line needs a target, and only staging or prod', () => {
  const build = stamped();
  for (const args of [[], ['--target', 'dev'], ['--target']]) {
    const run = spawnSync('node', [script, build.dir, '--pins', pinsFile, ...args]);
    assert.equal(run.status, 2, `${args}: ${run.stderr}`);
    assert.match(run.stderr.toString(), /--target staging\|prod/);
  }
  const ok = spawnSync('node', [script, build.dir, '--pins', pinsFile, '--target', 'prod']);
  assert.equal(ok.status, 0, ok.stderr.toString());
  done(build);
});

test('High 6: the deploy scripts pass the target to the guard', () => {
  const cloudflare = readFileSync(join(repo, 'tool/cloudflare-app/deploy.sh'), 'utf8');
  assert.match(cloudflare, /check_worker_stamp\.mjs" "\$here\/dist" --target "\$env"/);
});

// The Firebase rollback used to publish build/web without the guard (audit 2, High 6).
const rollback = new URL('./firebase_rollback.sh', import.meta.url).pathname;

test('High 6: the Firebase rollback script runs the guard before it publishes anything', () => {
  const build = stamped();
  writeFileSync(join(build.dir, 'pantas_sw.js'), unstampedSource);
  for (const env of ['staging', 'prod']) {
    // No firebase in the path: only the guard can have stopped it.
    const run = spawnSync('/bin/bash', [rollback, env, build.dir], {encoding: 'utf8', env: {PATH: '/usr/bin:/bin:' + process.execPath.replace(/\/node$/, '')}});
    assert.equal(run.status, 1, run.stdout + run.stderr);
    assert.match(run.stderr, /Refusing .*unstamped/s);
    assert.doesNotMatch(run.stderr, /firebase: command not found/);
  }
  const source = readFileSync(rollback, 'utf8');
  assert.ok(source.indexOf('check_worker_stamp.mjs') < source.indexOf('firebase deploy'), 'the guard comes first');
  assert.match(source, /--target "\$env"/);
  done(build);
});

test('High 6: the documented rollback uses the guarded script, not a bare firebase deploy of build/web', () => {
  const doc = readFileSync(join(repo, 'docs/deploy-prod.md'), 'utf8');
  const section = doc.slice(doc.indexOf('- **Rollback**'), doc.indexOf('- **The tiny Firebase page**'));
  assert.match(section, /tool\/deploy\/firebase_rollback\.sh/);
  assert.doesNotMatch(section, /firebase deploy --only hosting:app --public build\/web/);
  assert.doesNotMatch(section, /hosting:clone/, 'a clone of the release before build folders would put the mixing back');
});

test('High 6: stamping again after a change gives a new build id, and the guard passes', () => {
  const build = stamped();
  edit(build.dir, `${build.base}main.dart.js`, text => text + '// changed');
  stamp(build.dir);
  assert.deepEqual(stampProblems(build.dir), []);
  done(build);
});

test('a build made without --no-web-resources-cdn is refused', () => {
  const build = stamped({canvaskit: false});
  const problems = stampProblems(build.dir).join('\n');
  assert.match(problems, /no-web-resources-cdn/);
  assert.match(problems, /canvaskit\/canvaskit\.wasm/);
  done(build);
});

test('a file the page loads that sits at the root is refused', () => {
  const build = stamped();
  writeFileSync(join(build.dir, 'main.dart.js'), 'old root file');
  writeFileSync(join(build.dir, 'pantas_helper.js'), 'old root file');
  const problems = stampProblems(build.dir).join('\n');
  assert.match(problems, /main\.dart\.js is at the root/);
  assert.match(problems, /pantas_helper\.js is at the root/);
  done(build);
});

test('a page that names a script outside the build folder is refused', () => {
  const build = stamped();
  edit(build.dir, 'index.html', text => text.replace(`${build.base}pantas_pwa.js`, 'pantas_pwa.js'));
  assert.match(stampProblems(build.dir).join('\n'), /index\.html .*pantas_pwa\.js/);
  done(build);
});

test('a worker whose list does not match its own hash, or a second build folder, is refused', () => {
  const build = stamped();
  edit(build.dir, 'pantas_sw.js', text => text.replace(/"list":"[0-9a-f]{12}"/, '"list":"000000000000"'));
  assert.match(stampProblems(build.dir).join('\n'), /list hash/);
  done(build);
  const second = stamped();
  mkdirSync(join(second.dir, 'b', 'other'), {recursive: true});
  writeFileSync(join(second.dir, 'b', 'other', 'main.dart.js'), 'x');
  assert.match(stampProblems(second.dir).join('\n'), /more than one build folder|other/);
  done(second);
});

// ---- The deploy script ----

const deploy = new URL('../cloudflare-app/deploy.sh', import.meta.url).pathname;

test('the Cloudflare deploy script refuses an unstamped build before it uploads anything', () => {
  const build = stamped();
  writeFileSync(join(build.dir, 'pantas_sw.js'), unstampedSource);
  for (const env of ['staging', 'prod']) {
    const run = spawnSync('bash', [deploy, env, build.dir], {encoding: 'utf8'});
    assert.equal(run.status, 1, run.stdout + run.stderr);
    assert.match(run.stderr, /Refusing .*unstamped/s);
  }
  done(build);
});

test('the deploy script checks the folder it stages, not only the one it was given', () => {
  const build = stamped();
  const source = readFileSync(deploy, 'utf8');
  const stage = source.indexOf('cp -R');
  const check = source.indexOf('check_worker_stamp.mjs', stage);
  assert.ok(stage > 0 && check > stage, 'the check runs on dist after it is staged');
  assert.ok(check < source.indexOf('npx -y wrangler'), 'and before anything is uploaded');
  assert.match(source, /check_worker_stamp\.mjs" "\$here\/dist"/);
  done(build);
});

test('the deploy script refuses a staged build that lacks a required file', () => {
  const build = stamped();
  rmSync(join(build.dir, 'drift_worker.js'));
  stamp(build.dir);
  const run = spawnSync('bash', [deploy, 'staging', build.dir], {encoding: 'utf8'});
  assert.equal(run.status, 1, run.stdout + run.stderr);
  assert.match(run.stderr, /drift_worker\.js/);
  done(build);
});

test('staging and prod builds ask Flutter for a local renderer, so the worker can store it', () => {
  const staging = readFileSync(join(repo, 'tool/deploy/staging_web.sh'), 'utf8');
  const prod = readFileSync(join(repo, 'docs/deploy-prod.md'), 'utf8');
  assert.match(staging.match(/flutter build web[^\n]*/)[0], /--no-web-resources-cdn/);
  assert.match(prod.match(/flutter build web[^\n]*lib\/main_prod\.dart/)[0], /--no-web-resources-cdn/);
});
