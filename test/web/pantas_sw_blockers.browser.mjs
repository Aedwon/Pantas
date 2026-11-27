// The two Blocker proofs of audit 1 (E-184, plan
// docs/superpowers/plans/2026-11-25-sw-build-mix-option1.md, Revision 1, item 8), in
// headless Chromium against a local static server and fixture builds. Every file of
// a build carries a marker, and every page load logs the build of each boot file it
// ran, so a load is one build, or it did not boot.
//
//   PW_MODULE=/path/to/node_modules/playwright node test/web/pantas_sw_blockers.browser.mjs
//
// Blocker 1: a window that runs B stays on B while C installs, even offline, and a
// second window keeps C from taking over.
// Blocker 2: today's production worker, with its own helper and bootstrap, warmed;
// B's install held back past ten seconds; the network cut before, during and after
// the takeover and on a navigation slower than four seconds. Every load is all A,
// all B, or no boot.
import assert from 'node:assert/strict';
import {
  bootOf, coldHttpCache, controlled, controlledById, controllerId, oneBuild, open, pause, settle, start, waitFor, workerState,
} from './fixtures/browser_harness.mjs';

const t = await start({'A-prod': ['A', {prod: true}], B: ['B'], C: ['C']});
const {base, state, scenario} = t;
const cacheFor = name => `pantas-build-${t.constant(name).id}-${t.constant(name).list}`;

async function visit(page, name, expected) {
  state.build = name;
  oneBuild(await open(page, base, `first load of ${name}`), `first load of ${name}`, expected);
  await settle(page);
  await controlled(page);
  await pause(500);
  oneBuild(await open(page, base, `second load of ${name}`, {reload: true}), `second load of ${name}`, expected);
  // The exact worker in charge, not merely some worker (audit 2, Medium 9).
  if (name === 'A-prod') assert.equal(await controllerId(page), null, 'today\'s worker controls the page');
  else await controlledById(page, t.constant(name).id);
}

// ---- Blocker 1 -----------------------------------------------------------------

await scenario('Blocker 1: a held-open B tab stays on B while C installs, offline included; a second tab stops apply', async context => {
  const page = await context.newPage();
  await visit(page, 'B', 'B');
  await page.evaluate(() => { window.__stay = true; });
  const folder = t.constant('B').base;
  state.build = 'C';
  // Ask the browser to look for C, and wait until C has installed and is waiting.
  await page.evaluate(() => window.pantasUpdate.check().catch(() => null));
  await waitFor(async () => {
    await page.evaluate(() => window.pantasUpdate.check().catch(() => null));
    return (await workerState(page)).waiting;
  }, 'C installed and waiting', {timeout: 40000, every: 500});
  const during = await workerState(page);
  assert.ok(during.caches.includes(cacheFor('B')) && during.caches.includes(cacheFor('C')), `both caches exist: ${during.caches}`);

  // Offline, a deferred part B's page asks for is B's bytes, and the page is B's.
  await coldHttpCache(page); state.down = true;
  const offlinePart = await page.evaluate(async path => (await fetch(path)).text(), `${folder}main.dart.js_2.part.js`);
  assert.match(offlinePart, /@build:B@/, 'the deferred part is B\'s');
  const offlinePage = await page.evaluate(async () => (await fetch('/', {headers: {Accept: 'text/html'}})).text()).catch(() => '');
  assert.ok(!offlinePage.includes('@build:C@'), 'the page is not C\'s');
  state.down = false;
  assert.equal(await page.evaluate(() => window.__stay), true, 'the page was not reloaded');
  assert.equal((await workerState(page)).waiting, true, 'C is still waiting: it did not take over by itself');

  // A second window: apply must not let C take over while B runs in the other one.
  const second = await context.newPage();
  oneBuild(await open(second, base, 'second tab'), 'second tab', 'B');
  await page.evaluate(() => window.pantasUpdate.apply());
  await pause(2500);
  const afterApply = await workerState(page);
  assert.equal(afterApply.waiting, true, 'C is still waiting after apply with two windows');
  assert.ok(afterApply.caches.includes(cacheFor('B')), 'B\'s cache was not deleted');
  assert.equal(await page.evaluate(() => window.__stay), true, 'the first window was not reloaded');
  await coldHttpCache(page); state.down = true;
  assert.match(await page.evaluate(async path => (await fetch(path)).text(), `${folder}main.dart.js_2.part.js`), /@build:B@/);
  state.down = false;

  // With one window left, apply takes over and the page boots C.
  await second.close();
  await pause(500);
  await page.evaluate(() => window.pantasUpdate.apply());
  const swapped = await waitFor(async () => {
    const log = await bootOf(page, {timeout: 500});
    return log.booted && log.builds[0] === 'C' ? log : null;
  }, 'the page to boot C', {timeout: 20000});
  oneBuild(swapped, 'after apply', 'C');
  // Nothing is deleted when C takes over (fix list item 3; the Node tests show it). The page
  // registered C under its own address, which installs again and prunes B: C is the build in
  // charge and no window runs B. Never fewer than C's whole cache.
  const after = (await workerState(page)).caches;
  assert.ok(after.includes(cacheFor('C')), `C's cache is kept: ${after}`);
});

// The window that was on B when C took over (fix list items 2 and 3, audit 2 Blocker 1): nothing is
// deleted at activation, and C serves B's addresses from B's cache. The takeover is asked for
// directly, so no reload follows and the B window really runs on under C.
await scenario('Blocker 1: a B window held open across C\'s activation still loads a part it never requested, offline, cold HTTP cache', async context => {
  const page = await context.newPage();
  await visit(page, 'B', 'B');
  await page.evaluate(() => { window.__stay = true; });
  const folder = t.constant('B').base;
  state.build = 'C';
  await waitFor(async () => {
    await page.evaluate(() => window.pantasUpdate.check().catch(() => null));
    return (await workerState(page)).waiting;
  }, 'C installed and waiting', {timeout: 40000, every: 500});
  // C takes over while the B window stays: the reply is the worker's own "ok".
  const reply = await page.evaluate(async () => {
    const registration = await navigator.serviceWorker.getRegistration();
    return new Promise(resolve => {
      const channel = new MessageChannel();
      channel.port1.onmessage = event => resolve(event.data);
      registration.waiting.postMessage({type: 'pantas-take-over'}, [channel.port2]);
    });
  });
  assert.equal(reply.ok, true, 'one window: the worker agreed');
  await controlledById(page, t.constant('C').id);
  assert.equal(await page.evaluate(() => window.__stay), true, 'the B window was not reloaded');
  const during = (await workerState(page)).caches;
  assert.ok(during.includes(cacheFor('B')) && during.includes(cacheFor('C')), `activation deleted nothing: ${during}`);
  await coldHttpCache(page);
  state.down = true;
  const part = path => page.evaluate(async address => (await fetch(address)).text(), path);
  assert.match(await part(`${folder}main.dart.js_2.part.js`), /@build:B@/, 'a part B never requested is still B\'s');
  assert.match(await part(`${t.constant('C').base}main.dart.js_2.part.js`), /@build:C@/, 'and C\'s own is C\'s');
  state.down = false;
});

// ---- Blocker 2 -----------------------------------------------------------------

// Everything the worker fetches by itself, not the page's script and image loads.
const workerFetch = folder => (path, headers) => path.startsWith(`/${folder}`) && headers['sec-fetch-dest'] === 'empty';

async function warmedA(context) {
  const page = await context.newPage();
  await visit(page, 'A-prod', 'A');
  return page;
}

await scenario('Blocker 2: B deployed over warmed today\'s worker, network cut before B was ever loaded: all A', async context => {
  const page = await warmedA(context);
  state.build = 'B';
  await coldHttpCache(page); state.down = true;
  oneBuild(await open(page, base, 'offline before B', {reload: true}), 'offline before B', 'A');
});

await scenario('Blocker 2: B\'s install held past ten seconds, network cut during the install: all A, all B or no boot', async context => {
  const page = await warmedA(context);
  state.build = 'B';
  state.delays = [{when: workerFetch(t.constant('B').base), ms: 11000}];
  // Online, today's worker gives the page; it names B's folder, whose files load as the page asks.
  const online = oneBuild(await open(page, base, 'B online while its install is held back', {reload: true}), 'B online, install held');
  assert.ok(['B'].includes(online.builds[0]) || !online.booted, `online load: ${online.log}`);
  // Cut the network while B's install is still waiting on its files.
  await coldHttpCache(page); state.down = true;
  const cut = oneBuild(await open(page, base, 'offline during B\'s install', {reload: true}), 'offline during install');
  assert.ok(cut.builds.length <= 1);
  state.down = false;
  const stored = await workerState(page);
  assert.ok(!stored.caches.some(name => name.startsWith('pantas-build-')) || stored.caches.includes(cacheFor('B')),
    'no half-built cache of B is left');
});

await scenario('Blocker 2: the network is cut right after B\'s last file arrives, during the takeover: all A, all B or no boot', async context => {
  const page = await warmedA(context);
  state.build = 'B';
  const folder = t.constant('B').base;
  // The worker's fetch of the build's last file cuts the network as soon as it is answered.
  state.afterServe = [{when: (path, headers) => path === `/${folder}sqlite3.wasm` && headers['sec-fetch-dest'] === 'empty', run: () => { state.down = true; }}];
  state.delays = [{when: workerFetch(folder), ms: 300}];
  oneBuild(await open(page, base, 'B loaded', {reload: true}), 'B loaded');
  await pause(4000);
  await coldHttpCache(page); state.down = true;
  state.afterServe = [];
  oneBuild(await open(page, base, 'offline after the cut', {reload: true}), 'offline after the cut');
  state.down = false;
});

await scenario('Blocker 2: network cut after the takeover: all B, offline boot works', async context => {
  const page = await warmedA(context);
  state.build = 'B';
  oneBuild(await open(page, base, 'B loaded', {reload: true}), 'B loaded', 'B');
  await waitFor(async () => {
    const worker = await workerState(page);
    // B is in charge once it wrote its note. Today's cache stays, for tabs still on A.
    return worker.caches.includes(cacheFor('B')) && worker.caches.includes('pantas-meta');
  }, 'B in charge', {timeout: 30000});
  await pause(500);
  await coldHttpCache(page); state.down = true;
  oneBuild(await open(page, base, 'offline after takeover', {reload: true}), 'offline after takeover', 'B');
  state.down = false;
});

await scenario('Blocker 2: a navigation slower than four seconds: all A, all B or no boot, and nothing mixed later', async context => {
  const page = await warmedA(context);
  state.build = 'B';
  // Today's worker waits four seconds for the network and then serves its stored page.
  state.delays = [{when: path => path === '/', ms: 6000}];
  const slow = oneBuild(await open(page, base, 'slow navigation', {reload: true, timeout: 30000}), 'slow navigation');
  assert.ok(slow.builds.length <= 1);
  state.delays = [];
  await pause(7000); // the late answer is stored by today's worker as its page
  await coldHttpCache(page); state.down = true;
  oneBuild(await open(page, base, 'offline after the slow navigation', {reload: true}), 'offline after the slow navigation');
  state.down = false;
});

await t.finish();
