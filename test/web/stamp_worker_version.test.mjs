import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import test from 'node:test';
import {stamp} from '../../tool/web/stamp_worker_version.mjs';

// The worker as the repository ships it: an empty build constant between markers.
const SHIPPED = readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8');
const sha = bytes => createHash('sha256').update(bytes).digest('hex');
const stampedOf = dir => JSON.parse(
  /\/\*pantas-build\*\/ (.*?) \/\*end-pantas-build\*\//s.exec(readFileSync(join(dir, 'pantas_sw.js'), 'utf8'))[1]);

function build(mainJs) {
  const dir = mkdtempSync(join(tmpdir(), 'stamp-'));
  mkdirSync(join(dir, 'icons'));
  writeFileSync(join(dir, 'pantas_sw.js'), SHIPPED);
  writeFileSync(join(dir, 'index.html'), '<html>page</html>');
  writeFileSync(join(dir, 'main.dart.js'), mainJs);
  writeFileSync(join(dir, 'icons', 'Icon-192.png'), 'png');
  writeFileSync(join(dir, 'flutter_bootstrap.js'),
    'await pwa.registerWorker("213919009" /* note */);');
  return dir;
}

test('a Dart-only change gives the worker a new version', () => {
  const a = stamp(build('old code'));
  const b = stamp(build('new code'));
  assert.match(a, /^213919009-[0-9a-f]{12}$/);
  assert.notEqual(a, b);
});

test('the same build always gets the same version, and stamping twice is stable', () => {
  const dir = build('same code');
  const first = stamp(dir);
  assert.equal(stamp(dir), first);
  assert.equal(stamp(build('same code')), first);
  assert.match(readFileSync(join(dir, 'flutter_bootstrap.js'), 'utf8'), new RegExp(`registerWorker\\("${first}"`));
});

test('a bootstrap without the version token is refused', () => {
  const dir = build('code');
  writeFileSync(join(dir, 'flutter_bootstrap.js'), 'nothing here');
  assert.throws(() => stamp(dir), /No registerWorker/);
});

test('version metadata adds only the comparable stamped build identity', () => {
  const dir = build('code');
  writeFileSync(join(dir, 'version.json'), '{"version":"1.0.0","build_number":"4"}');
  const first = stamp(dir);
  assert.deepEqual(JSON.parse(readFileSync(join(dir, 'version.json'), 'utf8')), {
    version: '1.0.0', build_number: '4', pantasBuildVersion: first,
  });
  assert.equal(stamp(dir), first);
});

// The size the loading percent divides by goes into flutter_bootstrap.js, which
// is rewritten for every build anyway.
function bigBuild({main = 'main code'} = {}) {
  return build(main);
}

const total = dir => {
  const match = readFileSync(join(dir, 'flutter_bootstrap.js'), 'utf8').match(/^window\.pantasLoadTotal = (\d+);/m);
  return match ? Number(match[1]) : null;
};

test('the main script size is written into the bootstrap', () => {
  const dir = bigBuild({main: 'twelve bytes'});
  stamp(dir);
  assert.equal(total(dir), 12);
});

test('stamping twice keeps one total line and the same version', () => {
  const dir = bigBuild();
  const first = stamp(dir);
  const text = readFileSync(join(dir, 'flutter_bootstrap.js'), 'utf8');
  assert.equal(stamp(dir), first);
  assert.equal(readFileSync(join(dir, 'flutter_bootstrap.js'), 'utf8'), text);
  assert.equal((text.match(/pantasLoadTotal/g) || []).length, 1);
});

test('a build with no main script gets no total, so the page shows the spinner only', () => {
  const dir = bigBuild();
  rmSync(join(dir, 'main.dart.js'));
  stamp(dir);
  assert.equal(total(dir), null);
  assert.ok(!/pantasLoadTotal/.test(readFileSync(join(dir, 'flutter_bootstrap.js'), 'utf8')));
});

test('a stale total is removed when the main script is gone', () => {
  const dir = bigBuild();
  stamp(dir);
  rmSync(join(dir, 'main.dart.js'));
  stamp(dir);
  assert.equal(total(dir), null);
});

test('the bootstrap keeps its worker version token and its other lines', () => {
  const dir = bigBuild();
  const version = stamp(dir);
  const text = readFileSync(join(dir, 'flutter_bootstrap.js'), 'utf8');
  assert.match(text, new RegExp(`registerWorker\\("${version}"`));
});

// ---- The fingerprint list (service worker build mix, E-184) ----

test('the stamp writes the build id and the SHA-256 of every startup file, keyed by path', () => {
  const dir = bigBuild();
  writeFileSync(join(dir, 'main.dart.js_1.part.js'), 'part one');
  writeFileSync(join(dir, 'pantas_pwa.js'), 'pwa');
  const version = stamp(dir);
  const {id, files} = stampedOf(dir);
  assert.equal(id, version);
  for (const path of ['', 'index.html', 'flutter_bootstrap.js', 'main.dart.js', 'main.dart.js_1.part.js', 'pantas_pwa.js', 'icons/Icon-192.png']) {
    const file = path === '' ? 'index.html' : path;
    assert.equal(files[path], sha(readFileSync(join(dir, file))), path || 'the page');
  }
});

test('the startup set leaves out version.json, the worker itself and files the first frame does not need', () => {
  const dir = bigBuild();
  mkdirSync(join(dir, 'assets'), {recursive: true});
  writeFileSync(join(dir, 'assets/NOTICES'), 'licenses');
  writeFileSync(join(dir, 'assets/FontManifest.json'), '[]');
  writeFileSync(join(dir, 'version.json'), '{}');
  for (const name of ['og-image.png', 'README.md', 'flutter_service_worker.js', '.last_build_id', 'other.txt']) {
    writeFileSync(join(dir, name), name);
  }
  stamp(dir);
  const paths = Object.keys(stampedOf(dir).files);
  for (const left of ['version.json', 'pantas_sw.js', 'og-image.png', 'README.md', 'flutter_service_worker.js', '.last_build_id', 'other.txt', 'assets/NOTICES']) {
    assert.ok(!paths.includes(left), `${left} is not in the set`);
  }
  assert.ok(paths.includes('assets/FontManifest.json'));
});

test('canvaskit files join the set only when the build serves them itself', () => {
  const cdn = bigBuild();
  mkdirSync(join(cdn, 'canvaskit'));
  writeFileSync(join(cdn, 'canvaskit/canvaskit.wasm'), 'wasm');
  stamp(cdn);
  assert.ok(!Object.keys(stampedOf(cdn).files).some(path => path.startsWith('canvaskit/')));
  const local = bigBuild();
  mkdirSync(join(local, 'canvaskit'));
  writeFileSync(join(local, 'canvaskit/canvaskit.wasm'), 'wasm');
  writeFileSync(join(local, 'canvaskit/canvaskit.js.symbols'), 'symbols');
  writeFileSync(join(local, 'flutter_bootstrap.js'),
    '_flutter.buildConfig = {"useLocalCanvasKit":true};\nawait pwa.registerWorker("1" /* note */);');
  stamp(local);
  const paths = Object.keys(stampedOf(local).files);
  assert.ok(paths.includes('canvaskit/canvaskit.wasm'));
  assert.ok(!paths.includes('canvaskit/canvaskit.js.symbols'));
});

test('the list matches the build output after the bootstrap is stamped', () => {
  const dir = bigBuild();
  stamp(dir);
  const {files} = stampedOf(dir);
  assert.equal(files['flutter_bootstrap.js'], sha(readFileSync(join(dir, 'flutter_bootstrap.js'))));
});

test('running the stamp twice gives the same worker bytes, bootstrap and list', () => {
  const dir = bigBuild();
  stamp(dir);
  const first = ['pantas_sw.js', 'flutter_bootstrap.js'].map(name => readFileSync(join(dir, name), 'utf8'));
  stamp(dir);
  assert.deepEqual(['pantas_sw.js', 'flutter_bootstrap.js'].map(name => readFileSync(join(dir, name), 'utf8')), first);
});

test('the worker bytes differ for each build, so the browser installs a new worker', () => {
  const a = bigBuild({main: 'one'});
  const b = bigBuild({main: 'two'});
  stamp(a);
  stamp(b);
  assert.notEqual(readFileSync(join(a, 'pantas_sw.js'), 'utf8'), readFileSync(join(b, 'pantas_sw.js'), 'utf8'));
});

test('a change to the worker source alone changes the build id', () => {
  const a = bigBuild();
  const b = bigBuild();
  writeFileSync(join(b, 'pantas_sw.js'), SHIPPED + '\n// changed\n');
  assert.notEqual(stamp(a), stamp(b));
});

test('a worker without the build markers is refused', () => {
  const dir = bigBuild();
  writeFileSync(join(dir, 'pantas_sw.js'), "'use strict';\nconst VERSION = 1;\n");
  assert.throws(() => stamp(dir), /build constant/);
});

test('a build without a page is refused', () => {
  const dir = bigBuild();
  rmSync(join(dir, 'index.html'));
  assert.throws(() => stamp(dir), /index\.html/);
});
