import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {existsSync, mkdtempSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import test from 'node:test';
import {stamp} from '../../tool/web/stamp_worker_version.mjs';

// The worker as the repository ships it: an empty build constant between markers.
const SHIPPED = readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8');
const sha = bytes => createHash('sha256').update(bytes).digest('hex');
const stampedOf = dir => JSON.parse(
  /\/\*pantas-build\*\/ (.*?) \/\*end-pantas-build\*\//s.exec(readFileSync(join(dir, 'pantas_sw.js'), 'utf8'))[1]);
const folderOf = dir => `b/${stampedOf(dir).id}/`;
const bootstrapOf = dir => join(dir, folderOf(dir), 'flutter_bootstrap.js');
const read = (dir, name) => readFileSync(join(dir, name), 'utf8');

function build(mainJs) {
  const dir = mkdtempSync(join(tmpdir(), 'stamp-'));
  mkdirSync(join(dir, 'icons'));
  writeFileSync(join(dir, 'pantas_sw.js'), SHIPPED);
  writeFileSync(join(dir, 'index.html'),
    '<html><link rel="manifest" href="manifest.json"><link rel="icon" href="favicon.png">' +
    '<script src="pantas_pwa.js"></script><script src="flutter_bootstrap.js" async></script></html>');
  writeFileSync(join(dir, 'pantas_pwa.js'), 'pwa');
  writeFileSync(join(dir, 'manifest.json'), '{}');
  writeFileSync(join(dir, 'favicon.png'), 'fav');
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
  assert.match(readFileSync(bootstrapOf(dir), 'utf8'), new RegExp(`registerWorker\\("${first}"`));
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
  assert.deepEqual(JSON.parse(read(dir, 'version.json')), {
    version: '1.0.0', build_number: '4', pantasBuildVersion: first,
  });
  assert.equal(stamp(dir), first);
});

// The size the loading percent divides by goes into the bootstrap, which is
// rewritten for every build anyway.
const total = dir => {
  const match = readFileSync(bootstrapOf(dir), 'utf8').match(/^window\.pantasLoadTotal = (\d+);/m);
  return match ? Number(match[1]) : null;
};

test('the main script size is written into the bootstrap', () => {
  const dir = build('twelve bytes');
  stamp(dir);
  assert.equal(total(dir), 12);
});

test('stamping twice keeps one total line, one base line and the same version', () => {
  const dir = build('main code');
  const first = stamp(dir);
  const text = readFileSync(bootstrapOf(dir), 'utf8');
  assert.equal(stamp(dir), first);
  assert.equal(readFileSync(bootstrapOf(dir), 'utf8'), text);
  assert.equal((text.match(/pantasLoadTotal/g) || []).length, 1);
  assert.equal((text.match(/pantasBuildBase/g) || []).length, 1);
});

test('a build with no main script gets no total, so the page shows the spinner only', () => {
  const dir = build('main code');
  rmSync(join(dir, 'main.dart.js'));
  stamp(dir);
  assert.equal(total(dir), null);
  assert.ok(!/pantasLoadTotal/.test(readFileSync(bootstrapOf(dir), 'utf8')));
});

test('a stale total is removed when the main script is gone', () => {
  const dir = build('main code');
  stamp(dir);
  rmSync(join(dir, folderOf(dir), 'main.dart.js'));
  stamp(dir);
  assert.equal(total(dir), null);
});

test('the bootstrap keeps its worker version token and its other lines', () => {
  const dir = build('main code');
  const version = stamp(dir);
  assert.match(readFileSync(bootstrapOf(dir), 'utf8'), new RegExp(`registerWorker\\("${version}"`));
});

// ---- Build folders (Revision 1, item 1) ----

test('every file a page loads moves into b/<id>/, and the root keeps only the page, worker, metadata and icons', () => {
  const dir = build('code');
  mkdirSync(join(dir, 'assets/assets'), {recursive: true});
  writeFileSync(join(dir, 'assets/FontManifest.json'), '[]');
  writeFileSync(join(dir, 'assets/assets/x.png'), 'x');
  writeFileSync(join(dir, 'drift_worker.js'), 'worker');
  writeFileSync(join(dir, 'sqlite3.wasm'), 'wasm');
  writeFileSync(join(dir, 'main.dart.js_1.part.js'), 'part');
  writeFileSync(join(dir, 'version.json'), '{}');
  writeFileSync(join(dir, 'og-image.png'), 'og');
  const version = stamp(dir);
  const folder = `b/${version}/`;
  const root = readdirSync(dir).sort();
  // drift_worker.js keeps its root address (fix list item 1): see the next test.
  assert.deepEqual(root, ['b', 'drift_worker.js', 'favicon.png', 'icons', 'index.html', 'manifest.json', 'og-image.png', 'pantas_sw.js', 'version.json']);
  for (const name of ['flutter_bootstrap.js', 'pantas_pwa.js', 'main.dart.js', 'main.dart.js_1.part.js',
    'sqlite3.wasm', 'assets/FontManifest.json', 'assets/assets/x.png']) {
    assert.ok(existsSync(join(dir, folder, name)), `${folder}${name}`);
    assert.ok(!existsSync(join(dir, name)), `${name} is not at the root`);
  }
  assert.deepEqual(readdirSync(join(dir, 'b')), [version]);
});

test('the database worker stays at the root address in every build and is in the verified set', () => {
  // Browsers key a shared worker by its address and name. Two builds at two addresses
  // would run two workers that each believe they own the same database.
  const dir = build('code');
  writeFileSync(join(dir, 'drift_worker.js'), 'worker');
  const version = stamp(dir);
  assert.equal(read(dir, 'drift_worker.js'), 'worker');
  assert.ok(!existsSync(join(dir, `b/${version}/drift_worker.js`)));
  assert.equal(stampedOf(dir).files['drift_worker.js'], sha('worker'));
  assert.equal(stamp(dir), version, 'stamping again is stable');
  assert.equal(read(dir, 'drift_worker.js'), 'worker');
});

test('the page names the build folder for every script it loads and nothing else', () => {
  const dir = build('code');
  const version = stamp(dir);
  const page = read(dir, 'index.html');
  assert.match(page, new RegExp(`<script src="b/${version}/pantas_pwa\\.js">`));
  assert.match(page, new RegExp(`<script src="b/${version}/flutter_bootstrap\\.js" async>`));
  assert.match(page, /<link rel="manifest" href="manifest\.json">/);
  assert.match(page, /<link rel="icon" href="favicon\.png">/);
});

test('the bootstrap tells the page and the app where the build folder is', () => {
  const dir = build('code');
  const version = stamp(dir);
  assert.match(readFileSync(bootstrapOf(dir), 'utf8'), new RegExp(`^window\\.pantasBuildBase = "b/${version}/";$`, 'm'));
});

test('restamping a build changed inside its folder moves it back and stamps it again', () => {
  const dir = build('code');
  const first = stamp(dir);
  writeFileSync(join(dir, folderOf(dir), 'main.dart.js'), 'edited code');
  const second = stamp(dir);
  assert.notEqual(second, first);
  assert.deepEqual(readdirSync(join(dir, 'b')), [second]);
  assert.equal(read(dir, `b/${second}/main.dart.js`), 'edited code');
  assert.match(read(dir, 'index.html'), new RegExp(`b/${second}/pantas_pwa\\.js`));
  assert.ok(!read(dir, 'index.html').includes(first));
});

test('a font url() in the page styles follows the folder, so the welcome screen finds its fonts', () => {
  const dir = build('code');
  mkdirSync(join(dir, 'assets/assets/fonts'), {recursive: true});
  writeFileSync(join(dir, 'assets/assets/fonts/Geist-Regular.ttf'), 'ttf');
  writeFileSync(join(dir, 'index.html'),
    "<style>@font-face { src: url('assets/assets/fonts/Geist-Regular.ttf') format('truetype'); }</style>" +
    '<style>.x { background: url(icons/Icon-192.png) }</style><script src="flutter_bootstrap.js"></script>');
  const version = stamp(dir);
  const page = read(dir, 'index.html');
  assert.ok(page.includes(`url('b/${version}/assets/assets/fonts/Geist-Regular.ttf')`), page);
  assert.ok(page.includes('url(icons/Icon-192.png)'), 'a file at the root keeps its address');
  assert.ok(existsSync(join(dir, `b/${version}/assets/assets/fonts/Geist-Regular.ttf`)));
  assert.equal(stamp(dir), version, 'stamping again is stable');
  assert.ok(read(dir, 'index.html').includes(`url('b/${version}/assets/assets/fonts/Geist-Regular.ttf')`));
});

// ---- Local references in the page, in any valid form (audit 2, new Medium) ----

function pageWith(html) {
  const dir = build('code');
  mkdirSync(join(dir, 'assets/assets/fonts'), {recursive: true});
  writeFileSync(join(dir, 'assets/assets/fonts/Geist-Regular.ttf'), 'ttf');
  writeFileSync(join(dir, 'assets/assets/fonts/Geist Bold.ttf'), 'ttf');
  writeFileSync(join(dir, 'index.html'), html);
  return dir;
}

test('url() with spaces, a ./ prefix, either quote or none follows the folder', () => {
  const dir = pageWith(
    '<style>@font-face { src: url( ./assets/assets/fonts/Geist-Regular.ttf ) }' +
    '@font-face { src: url( "./assets/assets/fonts/Geist-Regular.ttf" ) }' +
    "@font-face { src: url(  './assets/assets/fonts/Geist-Regular.ttf'  ) format('truetype') }" +
    '.x { background: url( ./icons/Icon-192.png ) }</style>' +
    '<script src="./flutter_bootstrap.js"></script><script src=\'pantas_pwa.js\'></script>' +
    '<link rel="manifest" href="./manifest.json">');
  const version = stamp(dir);
  const page = read(dir, 'index.html');
  const font = `b/${version}/assets/assets/fonts/Geist-Regular.ttf`;
  assert.equal(page.split(font).length - 1, 3, page);
  assert.ok(!page.includes('./assets/'), 'no reference still points at the root');
  assert.ok(page.includes(`src="./b/${version}/flutter_bootstrap.js"`), page);
  assert.ok(page.includes(`src='b/${version}/pantas_pwa.js'`), page);
  assert.ok(page.includes('href="./manifest.json"'), 'a root file keeps resolving');
  assert.ok(page.includes('icons/Icon-192.png'), 'a file at the root keeps its address');
  assert.equal(stamp(dir), version, 'stamping again is stable');
  assert.equal(read(dir, 'index.html'), page);
});

test('a query or fragment after a local file is kept', () => {
  const dir = pageWith('<script src="flutter_bootstrap.js?x=1"></script><link href="manifest.json#a" rel="manifest">');
  const version = stamp(dir);
  const page = read(dir, 'index.html');
  assert.ok(page.includes(`src="b/${version}/flutter_bootstrap.js?x=1"`), page);
  assert.ok(page.includes('manifest.json#a'));
});

test('external addresses, data URIs, absolute paths and fragments are left alone', () => {
  const html = '<link rel="preconnect" href="https://www.gstatic.com"><link href="//cdn.test/x.css" rel="stylesheet">' +
    '<base href="/"><a href="#top">x</a><style>.a { background: url(data:image/png;base64,AAAA) } .b { fill: url(#clip) }</style>' +
    '<script src="flutter_bootstrap.js"></script>';
  const dir = pageWith(html);
  const version = stamp(dir);
  assert.equal(read(dir, 'index.html'), html.replace('src="flutter_bootstrap.js"', `src="b/${version}/flutter_bootstrap.js"`));
});

test('a local reference that points at nothing is refused, by name, instead of left to break at the root', () => {
  for (const html of [
    '<script src="flutter_bootstrap.js"></script><script src="missing.js"></script>',
    '<script src="flutter_bootstrap.js"></script><style>@font-face { src: url( ./assets/nothing.ttf ) }</style>',
    '<script src="flutter_bootstrap.js"></script><link href="icons/Nope.png" rel="icon">',
  ]) {
    assert.throws(() => stamp(pageWith(html)), /index\.html names .*, which is not in the build/, html);
  }
});

const PURCHASES = 'assets/packages/purchases_flutter/assets/web/purchases_js_hybrid_mappings.js';

test('the one file a package asks for by a fixed root address stays there, and is in the startup set', () => {
  const dir = build('code');
  mkdirSync(join(dir, 'assets/packages/purchases_flutter/assets/web'), {recursive: true});
  writeFileSync(join(dir, PURCHASES), 'purchases');
  writeFileSync(join(dir, 'assets/FontManifest.json'), '[]');
  const version = stamp(dir);
  assert.equal(read(dir, PURCHASES), 'purchases');
  assert.ok(!existsSync(join(dir, `b/${version}/${PURCHASES}`)));
  assert.equal(stampedOf(dir).files[PURCHASES], sha('purchases'));
  assert.ok(existsSync(join(dir, `b/${version}/assets/FontManifest.json`)), 'other assets still move');
  assert.equal(stamp(dir), version);
  assert.equal(read(dir, PURCHASES), 'purchases');
});

// ---- The fingerprint list (service worker build mix, E-184) ----

test('the stamp writes the build id and the SHA-256 of every startup file, keyed by final path', () => {
  const dir = build('main code');
  writeFileSync(join(dir, 'main.dart.js_1.part.js'), 'part one');
  const version = stamp(dir);
  const {id, files} = stampedOf(dir);
  const folder = `b/${version}/`;
  assert.equal(id, version);
  const expected = {
    '': 'index.html', 'index.html': 'index.html', 'manifest.json': 'manifest.json', 'favicon.png': 'favicon.png',
    'icons/Icon-192.png': 'icons/Icon-192.png',
  };
  for (const name of ['flutter_bootstrap.js', 'main.dart.js', 'main.dart.js_1.part.js', 'pantas_pwa.js']) {
    expected[folder + name] = folder + name;
  }
  for (const [path, file] of Object.entries(expected)) {
    assert.equal(files[path], sha(readFileSync(join(dir, file))), path || 'the page');
  }
});

test('the startup set leaves out version.json, the worker itself and files the first frame does not need', () => {
  const dir = build('main code');
  mkdirSync(join(dir, 'assets'), {recursive: true});
  writeFileSync(join(dir, 'assets/NOTICES'), 'licenses');
  writeFileSync(join(dir, 'assets/FontManifest.json'), '[]');
  writeFileSync(join(dir, 'version.json'), '{}');
  for (const name of ['og-image.png', 'README.md', 'flutter_service_worker.js', '.last_build_id', 'other.txt']) {
    writeFileSync(join(dir, name), name);
  }
  const version = stamp(dir);
  const paths = Object.keys(stampedOf(dir).files);
  for (const left of ['version.json', 'pantas_sw.js', 'og-image.png', 'README.md', 'flutter_service_worker.js', '.last_build_id',
    'other.txt', `b/${version}/other.txt`, `b/${version}/assets/NOTICES`]) {
    assert.ok(!paths.includes(left), `${left} is not in the set`);
  }
  assert.ok(paths.includes(`b/${version}/assets/FontManifest.json`));
});

function withCanvasKit({local}) {
  const dir = build('main code');
  for (const name of ['canvaskit.js', 'canvaskit.wasm', 'canvaskit.js.symbols', 'skwasm.wasm', 'chromium/canvaskit.js',
    'chromium/canvaskit.wasm', 'chromium/canvaskit.js.symbols']) {
    mkdirSync(join(dir, 'canvaskit', name.includes('/') ? 'chromium' : '.'), {recursive: true});
    writeFileSync(join(dir, 'canvaskit', name), name);
  }
  if (local) {
    writeFileSync(join(dir, 'flutter_bootstrap.js'),
      '_flutter.buildConfig = {"useLocalCanvasKit":true};\nawait pwa.registerWorker("1" /* note */);');
  }
  return dir;
}

test('canvaskit joins the set, both variants, only when the build serves it itself', () => {
  const cdn = withCanvasKit({local: false});
  stamp(cdn);
  assert.ok(!Object.keys(stampedOf(cdn).files).some(path => path.includes('canvaskit/')));
  const local = withCanvasKit({local: true});
  const version = stamp(local);
  const folder = `b/${version}/canvaskit/`;
  const {files} = stampedOf(local);
  // Every browser installs both (audit 2, High 5), so the constant carries no variant list.
  assert.equal(stampedOf(local).variants, undefined);
  for (const path of ['canvaskit.js', 'canvaskit.wasm', 'chromium/canvaskit.js', 'chromium/canvaskit.wasm']) {
    assert.ok(folder + path in files, path);
  }
  for (const left of ['canvaskit.js.symbols', 'skwasm.wasm', 'chromium/canvaskit.js.symbols']) {
    assert.ok(!(folder + left in files), `${left} is not in the set`);
  }
});

test('the list matches the build output after the bootstrap is stamped', () => {
  const dir = build('main code');
  stamp(dir);
  assert.equal(stampedOf(dir).files[folderOf(dir) + 'flutter_bootstrap.js'], sha(readFileSync(bootstrapOf(dir))));
});

test('running the stamp twice gives the same worker bytes, bootstrap, page and list', () => {
  const dir = build('main code');
  stamp(dir);
  const names = ['pantas_sw.js', 'index.html', `${folderOf(dir)}flutter_bootstrap.js`];
  const first = names.map(name => read(dir, name));
  stamp(dir);
  assert.deepEqual(names.map(name => read(dir, name)), first);
});

test('the worker bytes differ for each build, so the browser installs a new worker', () => {
  const a = build('one');
  const b = build('two');
  stamp(a);
  stamp(b);
  assert.notEqual(read(a, 'pantas_sw.js'), read(b, 'pantas_sw.js'));
});

test('a change to the worker source alone changes the build id', () => {
  const a = build('main code');
  const b = build('main code');
  writeFileSync(join(b, 'pantas_sw.js'), SHIPPED + '\n// changed\n');
  assert.notEqual(stamp(a), stamp(b));
});

test('a change to the bootstrap alone changes the build id, the cache name and the list hash (restamp)', () => {
  const a = build('main code');
  const b = build('main code');
  writeFileSync(join(b, 'flutter_bootstrap.js'), 'await pwa.registerWorker("213919009" /* note */);\n// other line');
  const first = stamp(a);
  const second = stamp(b);
  assert.notEqual(first, second);
  assert.notEqual(stampedOf(a).list, stampedOf(b).list);
});

test('the build constant carries a short hash of its own list', () => {
  const dir = build('main code');
  stamp(dir);
  const {files, list} = stampedOf(dir);
  assert.match(list, /^[0-9a-f]{12}$/);
  assert.equal(list, sha(JSON.stringify(files)).slice(0, 12));
});

test('a worker without the build markers is refused', () => {
  const dir = build('main code');
  writeFileSync(join(dir, 'pantas_sw.js'), "'use strict';\nconst VERSION = 1;\n");
  assert.throws(() => stamp(dir), /build constant/);
});

test('a build without a page is refused', () => {
  const dir = build('main code');
  rmSync(join(dir, 'index.html'));
  assert.throws(() => stamp(dir), /index\.html/);
});
