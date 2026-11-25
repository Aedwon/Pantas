// Real-browser rollout test for the service worker (E-184, plan
// docs/superpowers/plans/2026-11-25-sw-build-mix-option1.md). Headless Chromium,
// a local static server, fixture builds (no Flutter build, no hosted calls). For
// every page load it asserts that every boot file the page ran came from one
// build: the page, the bootstrap, pantas_pwa.js, main.dart.js and its part.
//
//   PW_MODULE=/path/to/node_modules/playwright node test/web/pantas_sw_rollout.browser.mjs
//
// PW_MODULE is the same variable tool/design_system/capture_boards.mjs reads; the
// default is build/pw/node_modules/playwright. Not a *.test.mjs file, so
// `node --test` does not need a browser.
import assert from 'node:assert/strict';
import {createServer} from 'node:http';
import {createRequire} from 'node:module';
import {mkdtempSync, readFileSync, rmSync, statSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {dirname, extname, join, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {writeBuild} from './fixtures/sw_fixture_build.mjs';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const {chromium} = createRequire(import.meta.url)(process.env.PW_MODULE ?? join(root, 'build/pw/node_modules/playwright'));

const scratch = mkdtempSync(join(tmpdir(), 'sw-rollout-'));
const dirs = {};
function build(name, id, options) {
  dirs[name] = join(scratch, name);
  writeBuild(dirs[name], id, options);
}
// Today's production worker builds: A and the rollback target. New worker builds: the rest.
build('A-prod', 'A', {prod: true});
build('B', 'B');
build('C', 'C');
build('A-new', 'A');

const types = {
  '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json', '.wasm': 'application/wasm',
  '.png': 'image/png', '.otf': 'font/otf', '.ttf': 'font/ttf', '.bin': 'application/octet-stream',
};
// Like the Cloudflare headers: root files revalidate, files in folders and wasm cache for an hour.
const longCache = path => path.startsWith('/assets/') || path.startsWith('/icons/') || path === '/sqlite3.wasm' || path === '/favicon.png';

const state = {build: 'A-prod', down: false, requests: []};
const server = createServer((request, response) => {
  if (state.down) return request.socket.destroy();
  const path = new URL(request.url, 'http://x').pathname;
  state.requests.push(path);
  let file = path === '/' ? 'index.html' : path.slice(1);
  let full = join(dirs[state.build], file);
  try {
    if (!statSync(full).isFile()) throw new Error();
  } catch {
    if (extname(file)) { response.writeHead(404); return response.end(); }
    full = join(dirs[state.build], 'index.html'); // single-page rewrite
    file = 'index.html';
  }
  response.writeHead(200, {
    'Content-Type': types[extname(file)] ?? 'application/octet-stream',
    'Cache-Control': longCache(path) ? 'max-age=3600' : 'no-cache',
  });
  response.end(readFileSync(full));
});
await new Promise(done => server.listen(0, '127.0.0.1', done));
const base = `http://127.0.0.1:${server.address().port}/`;

const browser = await chromium.launch({args: ['--use-mock-keychain', '--password-store=basic']});
const results = [];
let failed = 0;

async function scenario(name, run) {
  const context = await browser.newContext();
  const page = await context.newPage();
  state.down = false;
  try {
    await run(page, context);
    results.push(`ok   ${name}`);
  } catch (error) {
    failed++;
    results.push(`FAIL ${name}: ${error.message}`);
  } finally {
    await context.close();
  }
}

// Waits for the app's boot files to have run and returns the builds they came from.
async function boot(page, label) {
  await page.waitForFunction(() => (window.__boot || []).some(entry => entry.endsWith(':part')), null, {timeout: 20000});
  const log = await page.evaluate(() => window.__boot);
  const builds = [...new Set(log.map(entry => entry.split(':')[0]))];
  assert.equal(builds.length, 1, `${label}: boot files from ${builds.join(' and ')}: ${log.join(' ')}`);
  assert.equal(log.length, 5, `${label}: expected 5 boot files, got ${log.join(' ')}`);
  return builds[0];
}

const controlled = page => page.waitForFunction(() => navigator.serviceWorker.controller !== null, null, {timeout: 20000});
const settle = page => page.evaluate(() => navigator.serviceWorker.ready.then(() => true));
const pause = ms => new Promise(done => setTimeout(done, ms));

async function reload(page, label, expected) {
  await page.reload();
  assert.equal(await boot(page, label), expected, `${label}: wrong build`);
}

async function offline(page, label, expected) {
  state.down = true;
  try {
    await reload(page, `${label} (offline)`, expected);
  } finally {
    state.down = false;
  }
}

// First visit and a second visit, so the worker controls the page.
async function visit(page, name, expected) {
  state.build = name;
  await page.goto(base);
  assert.equal(await boot(page, `first load of ${name}`), expected);
  await settle(page);
  await controlled(page);
  await pause(500);
  await reload(page, `second load of ${name}`, expected);
}

await scenario('prod A, deploy B, reload online, reload offline', async page => {
  await visit(page, 'A-prod', 'A');
  state.build = 'B';
  await reload(page, 'B online', 'B');
  await pause(800);
  await offline(page, 'B', 'B');
  await reload(page, 'B online again', 'B');
});

await scenario('prod A, deploy B, go offline before B was ever loaded: still one build (A)', async page => {
  await visit(page, 'A-prod', 'A');
  state.build = 'B';
  await offline(page, 'A offline after B deployed', 'A');
});

await scenario('B to A rollback to today\'s worker, online then offline', async page => {
  await visit(page, 'A-prod', 'A');
  state.build = 'B';
  await reload(page, 'B online', 'B');
  await pause(800);
  state.build = 'A-prod';
  await reload(page, 'rollback deployed, B worker still in charge', 'B');
  await pause(1500);
  await reload(page, 'rollback online after today\'s worker took over', 'A');
  await pause(800);
  await offline(page, 'rollback', 'A');
});

await scenario('B to C to B with the new worker never mixes, online and offline', async page => {
  await visit(page, 'B', 'B');
  state.build = 'C';
  await reload(page, 'C deployed, B page still served', 'B'); // C reaches the page through its worker
  await pause(1500);
  await reload(page, 'C after its worker took over', 'C');
  await offline(page, 'C', 'C');
  state.build = 'B';
  await reload(page, 'rollback to B, C worker still in charge', 'C');
  await pause(1500);
  await reload(page, 'B after its worker took over again', 'B');
  await offline(page, 'B again', 'B');
});

await scenario('B to A-new rollback with the new worker', async page => {
  await visit(page, 'B', 'B');
  state.build = 'A-new';
  await pause(200);
  await reload(page, 'A deployed', 'B');
  await pause(1500);
  await reload(page, 'A after its worker took over', 'A');
  await offline(page, 'A', 'A');
});

await scenario('an open page finds the update, and the worker takes over before apply', async page => {
  await visit(page, 'B', 'B');
  state.build = 'C';
  const found = await page.evaluate(() => window.pantasUpdate.check());
  assert.equal(found.available, true);
  await page.waitForFunction(() => navigator.serviceWorker.controller.scriptURL.length > 0, null, {timeout: 5000});
  await pause(1500);
  await page.evaluate(() => window.pantasUpdate.apply());
  await page.waitForLoadState('load');
  assert.equal(await boot(page, 'after apply'), 'C');
});

await browser.close();
server.close();
rmSync(scratch, {recursive: true, force: true});
console.log(results.join('\n'));
console.log(failed ? `${failed} scenario(s) failed` : 'all scenarios passed');
process.exit(failed ? 1 : 0);
