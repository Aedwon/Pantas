import assert from 'node:assert/strict';
import {mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {spawnSync} from 'node:child_process';
import test from 'node:test';
import {stamp} from '../web/stamp_worker_version.mjs';
import {constantOf, writeBuild} from '../../test/web/fixtures/sw_fixture_build.mjs';
import {stampProblems} from './check_worker_stamp.mjs';

const script = new URL('./check_worker_stamp.mjs', import.meta.url).pathname;
const repo = new URL('../../', import.meta.url).pathname;
const canvasKit = ['canvaskit.js', 'canvaskit.wasm', 'chromium/canvaskit.js', 'chromium/canvaskit.wasm'];

// A release build as the staging and prod steps make it: CanvasKit is local.
function stamped({canvaskit = true} = {}) {
  const dir = mkdtempSync(join(tmpdir(), 'stamp-check-'));
  const files = Object.fromEntries(canvasKit.map(name => [`canvaskit/${name}`, `renderer ${name}`]));
  const served = writeBuild(dir, 'A', {files: canvaskit ? files : {}, localCanvasKit: canvaskit});
  return {dir, base: constantOf(served).base};
}
const edit = (dir, name, change) => writeFileSync(join(dir, name), change(readFileSync(join(dir, name), 'utf8')));
const done = ({dir}) => rmSync(dir, {recursive: true});
const unstampedSource = readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8');
const todaysWorker = readFileSync(new URL('../../test/web/fixtures/pantas_sw_prod_a.js', import.meta.url), 'utf8');

test('a stamped build passes', () => {
  const build = stamped();
  assert.deepEqual(stampProblems(build.dir), []);
  const run = spawnSync('node', [script, build.dir]);
  assert.equal(run.status, 0, run.stderr.toString());
  done(build);
});

test('an unstamped worker is refused', () => {
  const build = stamped();
  writeFileSync(join(build.dir, 'pantas_sw.js'), unstampedSource);
  assert.match(stampProblems(build.dir)[0], /unstamped/);
  const run = spawnSync('node', [script, build.dir]);
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
  assert.deepEqual(stampProblems(build.dir), [`${build.base}main.dart.js changed after the stamp`]);
  done(build);
});

test('a file added or removed after the stamp is refused', () => {
  const build = stamped();
  writeFileSync(join(build.dir, build.base, 'pantas_extra.js'), 'x');
  assert.match(stampProblems(build.dir).join(), /pantas_extra\.js is in the build but not in the worker/);
  rmSync(join(build.dir, build.base, 'pantas_extra.js'));
  rmSync(join(build.dir, build.base, 'drift_worker.js'));
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
  'index.html', 'pantas_sw.js', 'version.json', 'manifest.json',
  ...['flutter_bootstrap.js', 'main.dart.js', 'pantas_pwa.js', 'pantas_history.js', 'pantas_welcome.js', 'pantas_splash.js',
    'drift_worker.js', 'sqlite3.wasm', 'assets/AssetManifest.bin', 'assets/FontManifest.json',
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
  rmSync(join(build.dir, build.base, 'drift_worker.js'));
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
