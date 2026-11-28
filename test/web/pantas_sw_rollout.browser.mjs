// Real-browser rollout test for the service worker (E-184, plan
// docs/superpowers/plans/2026-11-25-sw-build-mix-option1.md, Revision 1). Headless
// Chromium, a local static server, fixture builds (no Flutter build, no hosted calls).
// For every page load it asserts that every boot file the page ran came from one
// build: the page, the helper, the bootstrap, main.dart.js and its deferred part.
// The two Blocker proofs are in pantas_sw_blockers.browser.mjs.
//
//   PW_MODULE=/path/to/node_modules/playwright node test/web/pantas_sw_rollout.browser.mjs
//
// PW_MODULE is the same variable tool/design_system/capture_boards.mjs reads; the
// default is build/pw/node_modules/playwright. Not a *.test.mjs file, so
// `node --test` does not need a browser.
import assert from 'node:assert/strict';
import {
  bootOf, coldHttpCache, controlled, controlledById, controllerId, oneBuild, open, pause, settle, start, waitFor, workerState,
} from './fixtures/browser_harness.mjs';

// Today's production worker, helper and bootstrap (A, and the rollback target), and new builds.
const t = await start({
  'A-prod': ['A', {prod: true}],
  B: ['B'],
  C: ['C'],
  'A-new': ['A'],
});
const {base, state, scenario} = t;

// First visit and a second visit, so the worker controls the page.
async function visit(page, name, expected) {
  state.build = name;
  oneBuild(await open(page, base, `first load of ${name}`), `first load of ${name}`, expected);
  await settle(page);
  await controlled(page);
  await pause(500);
  oneBuild(await open(page, base, `second load of ${name}`, {reload: true}), `second load of ${name}`, expected);
  // The exact worker in charge: today's worker has no build id to report, a new one reports its own.
  if (name === 'A-prod') assert.equal(await controllerId(page), null, 'today\'s worker controls the page');
  else await controlledById(page, t.constant(name).id);
}
const reload = async (page, label, expected) => oneBuild(await open(page, base, label, {reload: true}), label, expected);
async function offline(page, label, expected) {
  // Cold HTTP cache: only the service worker's own storage can answer from here on.
  await coldHttpCache(page);
  state.down = true;
  try {
    return await reload(page, `${label} (offline)`, expected);
  } finally {
    state.down = false;
  }
}
// Waits until the browser holds a verified worker that is waiting, or is already in charge.
const hasWaiting = page => waitFor(async () => (await workerState(page)).waiting, 'a waiting worker');
const worksOffline = (page, label, expected) => offline(page, label, expected);

await scenario('prod A, deploy B, reload online, reload offline', async context => {
  const page = await context.newPage();
  await visit(page, 'A-prod', 'A');
  state.build = 'B';
  await reload(page, 'B online (today\'s worker gave the page, the page names B\'s folder)', 'B');
  // B's worker has no other stamped build to wait for, so it takes over at once.
  await waitFor(async () => (await workerState(page)).caches.some(name => name.startsWith('pantas-build-')), 'B stored');
  await pause(800);
  await worksOffline(page, 'B', 'B');
  await reload(page, 'B online again', 'B');
});

await scenario('prod A, deploy B, go offline before B was ever loaded: still one build (A)', async context => {
  const page = await context.newPage();
  await visit(page, 'A-prod', 'A');
  state.build = 'B';
  await offline(page, 'A offline after B deployed', 'A');
});

await scenario('B to A rollback to today\'s worker never mixes, online and offline', async context => {
  const page = await context.newPage();
  await visit(page, 'A-prod', 'A');
  state.build = 'B';
  await reload(page, 'B online', 'B');
  await waitFor(async () => (await workerState(page)).caches.some(name => name.startsWith('pantas-build-')), 'B stored');
  await pause(800);
  state.build = 'A-prod';
  oneBuild(await open(page, base, 'rollback deployed', {reload: true}), 'rollback deployed');
  await pause(1500);
  oneBuild(await open(page, base, 'rollback, later', {reload: true}), 'rollback, later');
  await pause(800);
  oneBuild(await offline(page, 'rollback', undefined), 'rollback offline');
});

// Asks the browser to look for a newer worker, and waits until one is installed and waiting.
const lookUntilWaiting = page => waitFor(async () => {
  await page.evaluate(async () => {
    const registration = await navigator.serviceWorker.getRegistration();
    if (registration) await registration.update().catch(() => null);
  });
  return (await workerState(page)).waiting;
}, 'a waiting worker', {timeout: 40000, every: 500});

// Every tab closes, so the browser activates the waiting worker by itself. Returns the new tab,
// on the new build.
async function allTabsClosed(context, page, label, expected) {
  await page.close();
  const fresh = await context.newPage();
  const booted = await waitFor(async () => {
    const log = await open(fresh, base, label, {reload: fresh.url() !== 'about:blank'});
    return log.booted && log.builds[0] === expected ? log : null;
  }, `${label}: a new tab to boot ${expected}`, {timeout: 30000, every: 1500});
  oneBuild(booted, label, expected);
  return fresh;
}

await scenario('B to C to B with the new worker never mixes, online and offline; a reload never updates', async context => {
  let page = await context.newPage();
  await visit(page, 'B', 'B');
  state.build = 'C';
  // C installs and waits: the page keeps booting B, however often it reloads.
  await lookUntilWaiting(page);
  await reload(page, 'C waiting, reload', 'B');
  await reload(page, 'C waiting, reload again', 'B');
  assert.equal((await workerState(page)).waiting, true, 'C still waits after reloads');
  await offline(page, 'B with C waiting', 'B');
  // No tab open: the browser activates C, which sweeps B.
  page = await allTabsClosed(context, page, 'C after every tab closed', 'C');
  await offline(page, 'C', 'C');
  assert.deepEqual((await workerState(page)).caches, [`pantas-build-${t.constant('C').id}-${t.constant('C').list}`], 'only C\'s cache remains');
  state.build = 'B';
  await lookUntilWaiting(page);
  await reload(page, 'rollback to B waiting, reload', 'C');
  page = await allTabsClosed(context, page, 'B after every tab closed', 'B');
  await offline(page, 'B again', 'B');
});

await scenario('B to A-new rollback with the new worker', async context => {
  let page = await context.newPage();
  await visit(page, 'B', 'B');
  state.build = 'A-new';
  await lookUntilWaiting(page);
  await reload(page, 'A deployed, waiting, reload', 'B');
  page = await allTabsClosed(context, page, 'A after every tab closed', 'A');
  await offline(page, 'A', 'A');
});

await scenario('Update Required: updateNow takes over into the waiting build and the page boots it', async context => {
  const page = await context.newPage();
  await visit(page, 'B', 'B');
  state.build = 'C';
  await lookUntilWaiting(page);
  assert.equal(await page.evaluate(() => window.__boot.some(entry => entry.startsWith('C:'))), false, 'the open page still runs B');
  await page.evaluate(() => { window.pantasPwa.updateNow(); });
  const swapped = await waitFor(async () => {
    const log = await bootOf(page, {timeout: 500});
    return log.booted && log.builds[0] === 'C' ? log : null;
  }, 'the page to boot C', {timeout: 20000});
  oneBuild(swapped, 'after updateNow', 'C');
  // The takeover deleted nothing: B's cache stays until the next natural activation.
  assert.ok((await workerState(page)).caches.length >= 2);
});

await t.finish();
