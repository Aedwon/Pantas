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

// Audit 2 leftover, kept open by audit 3: href = "..." (spaces around the equals sign) still pointed
// at a font the stamp had moved. Every spelling HTML allows for a reference must follow the file.
test('audit 3: every spelling of a local reference follows its file into the folder', () => {
  const font = 'assets/assets/fonts/Geist-Regular.ttf';
  const dir = pageWith(
    `<link rel="preload" href = "${font}" as="font">` +
    `<link rel="preload" href\n=\n'./${font}' as="font">` +
    `<link rel="preload" HREF=${font} as="font">` +
    `<link rel="preload" href=" ${font} " as="font">` +
    `<img srcset="icons/Icon-192.png 1x, ${font} 2x">` +
    `<style>@import "${font}"; @import './${font}'; @import url( ${font} );</style>` +
    '<div style="background: url( ./icons/Icon-192.png ); font-family: x"></div>' +
    '<script   src = "./flutter_bootstrap.js" ></script><script SRC=pantas_pwa.js></script>');
  const version = stamp(dir);
  const page = read(dir, 'index.html');
  assert.ok(!page.includes('./assets/') && !/["'= ]assets\/assets/.test(page), `a reference still points at the moved font: ${page}`);
  assert.equal(page.split(`b/${version}/${font}`).length - 1, 8, page);
  assert.ok(page.includes(`href = "b/${version}/${font}"`), 'the spacing the author wrote is kept');
  assert.ok(page.includes(`href=" b/${version}/${font} "`));
  assert.ok(page.includes(`HREF=b/${version}/${font}`));
  assert.ok(page.includes(`src = "./b/${version}/flutter_bootstrap.js"`));
  assert.ok(page.includes(`SRC=b/${version}/pantas_pwa.js`));
  assert.ok(page.includes('icons/Icon-192.png 1x'), 'a file at the root keeps its address');
  assert.equal(stamp(dir), version, 'stamping again is stable');
  assert.equal(read(dir, 'index.html'), page);
});

test('audit 3: a reference in a comment or an inline script is not a page reference', () => {
  const html = '<!-- <script src="gone.js"></script> --><script>var s = document.createElement("script"); s.src = "elsewhere.js"; a.href = "x.html";</script>' +
    '<script src="flutter_bootstrap.js"></script>';
  const dir = pageWith(html);
  const version = stamp(dir);
  assert.equal(read(dir, 'index.html'), html.replace('src="flutter_bootstrap.js"', `src="b/${version}/flutter_bootstrap.js"`));
});

test('audit 3: an unresolved reference in any spelling is refused, by name', () => {
  for (const html of [
    '<script src="flutter_bootstrap.js"></script><link href = "missing.css" rel="stylesheet">',
    '<script src="flutter_bootstrap.js"></script><link href=missing.css rel="stylesheet">',
    "<script src=\"flutter_bootstrap.js\"></script><link href\n=\n'./missing.css' rel=\"stylesheet\">",
    '<script src="flutter_bootstrap.js"></script><img srcset="missing.png 1x">',
    '<script src="flutter_bootstrap.js"></script><style>@import "missing.css";</style>',
    '<script src="flutter_bootstrap.js"></script><div style="background: url( missing.png )"></div>',
  ]) {
    assert.throws(() => stamp(pageWith(html)), /index\.html names .*missing.*, which is not in the build/, html);
  }
});

// Audit 4, Medium: the stamp moves a file into the build folder, and a reference that starts with a
// slash would keep pointing at the root, where the file no longer is. It is refused, in any spelling.
test('audit 4: a root-relative reference to a file the stamp moves is refused, by name', () => {
  for (const html of [
    '<script src="flutter_bootstrap.js"></script><link rel="preload" href="/assets/assets/fonts/Geist-Regular.ttf">',
    '<script src="flutter_bootstrap.js"></script><link rel="preload" href = /assets/assets/fonts/Geist-Regular.ttf>',
    '<script src="flutter_bootstrap.js"></script><style>@font-face { src: url(/assets/assets/fonts/Geist-Regular.ttf) }</style>',
  ]) {
    assert.throws(() => stamp(pageWith(html)), /index\.html names \/assets\/assets\/fonts\/Geist-Regular\.ttf, which the stamp moves/, html);
  }
  // A slash-first address of something that stays at the root, or an outside address, is left alone.
  const dir = pageWith('<script src="flutter_bootstrap.js"></script><link href="/manifest.json"><link href="//example.com/a.css">');
  writeFileSync(join(dir, 'manifest.json'), '{}');
  stamp(dir);
  assert.match(read(dir, 'index.html'), /href="\/manifest\.json"><link href="\/\/example\.com\/a\.css"/);
});

// E-210: the engine fetches this Roboto file from fonts.gstatic.com at every start, unless the font
// manifest already has a Roboto family. web/fonts holds the same bytes; the stamp registers them.
const ROBOTO = 'fonts/roboto/v32/KFOmCnqEu92Fr1Me4GZLCzYlKw.woff2';
const ROBOTO_BYTES = readFileSync(new URL(`../../web/${ROBOTO}`, import.meta.url));
function withRoboto(manifest = '[{"family":"Geist","fonts":[{"asset":"assets/fonts/Geist-Regular.ttf"}]}]') {
  const dir = build('code');
  mkdirSync(join(dir, 'fonts/roboto/v32'), {recursive: true});
  writeFileSync(join(dir, ROBOTO), ROBOTO_BYTES);
  mkdirSync(join(dir, 'assets'), {recursive: true});
  writeFileSync(join(dir, 'assets/FontManifest.json'), manifest);
  return dir;
}

test('the web build registers Roboto from its own folder, in the manifest, the set and the id', () => {
  const dir = withRoboto();
  const version = stamp(dir);
  const folder = `b/${version}/`;
  const manifest = JSON.parse(read(dir, `${folder}assets/FontManifest.json`));
  assert.deepEqual(manifest.find(family => family.family === 'Roboto'), {family: 'Roboto', fonts: [{asset: ROBOTO}]});
  assert.equal(manifest.length, 2, 'the other families stay');
  assert.ok(existsSync(join(dir, `${folder}assets/${ROBOTO}`)), 'the font is where the engine asks for it');
  assert.ok(!existsSync(join(dir, 'fonts')), 'nothing is left at the root');
  assert.equal(stampedOf(dir).files[`${folder}assets/${ROBOTO}`], sha(ROBOTO_BYTES), 'in the startup set, with its hash');
  assert.equal(stamp(dir), version, 'stamping again is stable');
  assert.equal(manifest.filter(family => family.family === 'Roboto').length, 1);
  // The manifest is part of the id: another font file gives another build.
  const other = withRoboto();
  writeFileSync(join(other, ROBOTO), 'other bytes');
  assert.notEqual(stamp(other), version);
});

test('a manifest that already has a Roboto family is left as it is', () => {
  const own = '[{"family":"Roboto","fonts":[{"asset":"fonts/own.ttf"}]}]';
  const dir = withRoboto(own);
  const version = stamp(dir);
  assert.equal(read(dir, `b/${version}/assets/FontManifest.json`), own);
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

test('canvaskit joins the set, full variant only, and only when the build serves it itself', () => {
  const cdn = withCanvasKit({local: false});
  stamp(cdn);
  assert.ok(!Object.keys(stampedOf(cdn).files).some(path => path.includes('canvaskit/')));
  const local = withCanvasKit({local: true});
  const version = stamp(local);
  const folder = `b/${version}/canvaskit/`;
  const {files} = stampedOf(local);
  assert.equal(stampedOf(local).variants, undefined);
  for (const path of ['canvaskit.js', 'canvaskit.wasm']) {
    assert.ok(folder + path in files, path);
  }
  // The bootstrap pins full CanvasKit in every browser (E-210, audit 2 High 5), so the
  // chromium variant is never asked for and is not downloaded by an update.
  for (const left of ['canvaskit.js.symbols', 'skwasm.wasm', 'chromium/canvaskit.js', 'chromium/canvaskit.wasm',
    'chromium/canvaskit.js.symbols']) {
    assert.ok(!(folder + left in files), `${left} is not in the set`);
  }
});

// E-210: the Firebase SDK files sit at root addresses named by the SDK version and are in the
// set (verified by hash, stored by the worker), so the app starts with no connection.
test('the Firebase SDK files stay at the root, in the set, and the page keeps its import map as written', () => {
  const dir = build('main code');
  const map = '{"imports":{"https://www.gstatic.com/firebasejs/1.0.0/firebase-app.js":"./firebase_sdk/1.0.0/firebase-app.js"}}';
  writeFileSync(join(dir, 'index.html'),
    `<html><script type="importmap">${map}</script><script src="pantas_pwa.js"></script></html>`);
  mkdirSync(join(dir, 'firebase_sdk', '1.0.0'), {recursive: true});
  writeFileSync(join(dir, 'firebase_sdk', '1.0.0', 'firebase-app.js'), 'sdk');
  const version = stamp(dir);
  assert.ok(existsSync(join(dir, 'firebase_sdk/1.0.0/firebase-app.js')), 'still at the root');
  assert.ok(!existsSync(join(dir, `b/${version}/firebase_sdk`)), 'not in the build folder');
  assert.ok('firebase_sdk/1.0.0/firebase-app.js' in stampedOf(dir).files, 'in the set');
  assert.ok(read(dir, 'index.html').includes(map), 'the import map is unchanged');
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
