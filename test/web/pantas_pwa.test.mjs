// Run with: node --test test/web/pantas_pwa.test.mjs
import test from 'node:test';
import assert from 'node:assert/strict';
import { loadPage } from './fixtures/fake_page.mjs';

// Runs pantas_pwa.js in a fake page (fixtures/fake_page.mjs). `controller` is the
// worker script URL that controlled the page at load, or null for a page no worker
// controlled.
function load(options = {}) {
  const page = loadPage(options);
  return {pwa: page.pwa, marks: page.marks, page};
}

test('a page no worker controlled is a first visit', () => {
  const { pwa } = load({ controller: null });
  assert.equal(pwa.visitKind(), 'first');
});

test('a page the same build controlled is a return visit', async () => {
  const { pwa } = load({ controller: 'https://app.example/pantas_sw.js?v=abc123' });
  assert.equal(pwa.visitKind(), 'return', 'before the build is known');
  await pwa.registerWorker('abc123');
  assert.equal(pwa.visitKind(), 'return');
});

test('a page an older build controlled is the first load after a deploy', async () => {
  const { pwa } = load({ controller: 'https://app.example/pantas_sw.js?v=old999' });
  await pwa.registerWorker('abc123');
  assert.equal(pwa.visitKind(), 'after_deploy');
});

test('the visit kind is decided at load, not after the new worker takes over', async () => {
  const { pwa } = load({ controller: null });
  await pwa.registerWorker('abc123');
  assert.equal(pwa.visitKind(), 'first');
});

test('the page can say which build it started with', async () => {
  const { pwa } = load({ controller: null });
  assert.equal(pwa.buildVersion(), null, 'before the worker step');
  await pwa.registerWorker('1293236267-5bbf79dc07b4');
  assert.equal(pwa.buildVersion(), '1293236267-5bbf79dc07b4');
});

test('a browser without workers counts as a first visit', () => {
  const { pwa } = load({ supported: false });
  assert.equal(pwa.visitKind(), 'first');
});

test('page.worker is marked when the worker step resolves, on every path', async () => {
  for (const options of [
    { controller: null },
    { controller: null, supported: false },
    { controller: 'https://app.example/pantas_sw.js?v=old', registerFails: true },
  ]) {
    const { pwa, marks } = load(options);
    assert.deepEqual(marks, []);
    await pwa.registerWorker('abc123');
    assert.deepEqual(marks, ['page.worker']);
  }
});

test('a missing performance API never breaks the worker step', async () => {
  const { pwa, marks } = load({ controller: null, noPerformance: true });
  assert.equal(await pwa.registerWorker('abc123'), false);
  assert.deepEqual(marks, []);
});

// ---- Registration without a page wait (Revision 1, item 3) ----

test('the page registers the worker for this build and does not wait for it', async () => {
  const { pwa, page } = load({ controller: 'https://app.example/pantas_sw.js?v=old' });
  // A registration that never settles must not hold the page.
  page.sw.register = (script) => {
    page.registered.push(script);
    return new Promise(() => {});
  };
  assert.equal(await pwa.registerWorker('abc123'), false);
  assert.deepEqual(page.registered, ['pantas_sw.js?v=abc123']);
  assert.equal(page.timers.some((t) => t.ms === 4000), false, 'no four-second wait for the worker');
});

test('a page with a worker already controlling it starts at once when nothing is waiting', async () => {
  const { pwa, page } = load({ controller: 'https://app.example/pantas_sw.js?v=abc123' });
  assert.equal(await pwa.registerWorker('abc123'), false);
  assert.equal(page.reloads(), 0);
  assert.deepEqual(page.posted, []);
});

test('an update already installed and waiting takes over before Flutter starts, when this is the only window', async () => {
  const { pwa, page } = load({
    controller: 'https://app.example/pantas_sw.js?v=old', waiting: { id: 'next' }, waitingAtLoad: true,
  });
  assert.equal(await pwa.registerWorker('old'), true, 'the caller must not start Flutter');
  assert.deepEqual(page.posted.map((m) => m.type).slice(0, 2), ['pantas-build-id', 'pantas-take-over']);
  // The reload waits for the answer to "who controls the page now".
  await new Promise((done) => setImmediate(done));
  assert.equal(page.reloads(), 1);
});

test('with another window open the page starts Flutter on the build it has', async () => {
  const { pwa, page } = load({
    controller: 'https://app.example/pantas_sw.js?v=old', waiting: { id: 'next', windowsOk: false }, waitingAtLoad: true,
  });
  assert.equal(await pwa.registerWorker('old'), false);
  assert.equal(page.reloads(), 0);
});

test('a worker that never answers cannot hold the start longer than the limit', async () => {
  const { pwa, page } = load({
    controller: 'https://app.example/pantas_sw.js?v=old', waiting: { id: 'next' }, silentWaiting: true, waitingAtLoad: true,
  });
  const starting = pwa.registerWorker('old');
  await new Promise((done) => setImmediate(done));
  page.fire(2500);
  assert.equal(await starting, false);
});

test('a registration that exists but is not waiting costs nothing and a missing one neither', async () => {
  for (const options of [{ hasRegistration: false }, { waiting: null }]) {
    const { pwa } = load({ controller: null, ...options });
    assert.equal(await pwa.registerWorker('abc123'), false);
  }
});
