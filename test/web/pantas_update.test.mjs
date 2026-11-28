// Run with: node --test test/web/pantas_update.test.mjs
// The page and a waiting worker (revision 2, "wait, then sweep"). A reload, a start, a return to
// the tab or a timer never asks a waiting worker to take over: it becomes active when the browser
// has no Pantas tab open, or when the Update Required button asks (updateNow). Nothing here
// deletes a cache or unregisters.
import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';
import {loadPage} from './fixtures/fake_page.mjs';

const tick = () => new Promise((done) => setImmediate(done));

// A page that started on build 'running'. The update, if any, finishes installing after the start.
async function started(options) {
  const page = loadPage({controller: 'https://app.test/pantas_sw.js?v=running', ...options});
  await page.pwa.registerWorker('running');
  page.arrive();
  return page;
}

test('there is no page-side update check or apply any more', () => {
  const p = loadPage({controller: null});
  assert.equal(p.update, undefined);
  assert.equal(p.window.pantasUpdate, undefined);
});

// Item 4g: a reload with a waiting worker does not update.
test('a start with a worker already waiting asks it nothing: the page keeps its build', async () => {
  const p = loadPage({controller: 'https://app.test/pantas_sw.js?v=running', waitingAtLoad: true, waiting: {id: 'next'}});
  assert.equal(await p.pwa.registerWorker('running'), false, 'the caller starts Flutter on the build it has');
  await tick();
  assert.deepEqual(p.posted, [], 'no message to the waiting worker');
  assert.equal(p.reloads(), 0);
  assert.equal(p.listening(), 0);
  assert.equal(p.updates(), 1, 'the browser was asked once to look for a newer worker');
});

test('the bootstrap starts Flutter on its own build even with a worker waiting', async () => {
  const p = loadPage({controller: 'https://app.test/pantas_sw.js?v=running', waitingAtLoad: true, waiting: {id: 'next'}});
  const loads = [];
  p.context._flutter = {loader: {load: (options) => loads.push(options)}};
  p.context.performance = {mark() {}};
  const bootstrap = readFileSync(new URL('../../web/flutter_bootstrap.js', import.meta.url), 'utf8')
    .replace('{{flutter_js}}', '').replace('{{flutter_build_config}}', '').replace('{{flutter_service_worker_version}}', '"running"');
  vm.runInContext(bootstrap, p.context);
  await tick();
  await tick();
  assert.equal(loads.length, 1);
  assert.deepEqual(p.posted, []);
  assert.equal(p.reloads(), 0);
});

test('returning to the tab and the passing of time never apply an update', async () => {
  const p = await started({waiting: {id: 'next'}});
  assert.equal(p.listeners.visibilitychange, undefined, 'the page no longer listens for a return to the tab');
  assert.equal(p.timers.some((t) => t.ms === 300000), false, 'and sets no five-minute check');
  assert.deepEqual(p.posted, []);
  assert.equal(p.reloads(), 0);
});

test('the page never unregisters the worker or deletes a cache', async () => {
  const p = await started({waiting: {id: 'next'}});
  p.sw.getRegistrations = () => assert.fail('getRegistrations');
  p.registration.unregister = () => assert.fail('unregister');
  await p.pwa.updateNow();
});

// ---- The Update Required button ----

test('updateNow takes over into a waiting build and reloads once the worker controls the page', async () => {
  const p = await started({waiting: {id: 'next'}});
  await p.pwa.updateNow();
  assert.deepEqual(p.posted.map((m) => m.type).slice(0, 2), ['pantas-build-id', 'pantas-take-over']);
  await tick();
  assert.equal(p.reloads(), 1, 'one reload, from the takeover');
});

test('updateNow does not reload twice when the worker reports control twice', async () => {
  const p = await started({waiting: {id: 'next'}});
  await p.pwa.updateNow();
  p.controllerChange();
  p.controllerChange();
  await tick();
  assert.equal(p.reloads(), 1);
});

test('updateNow reloads only when the worker that controls the page is the one it asked', async () => {
  const p = await started({waiting: {id: 'next', controls: false}});
  await p.pwa.updateNow();
  await tick();
  assert.equal(p.reloads(), 0, 'a controllerchange to some other worker is not the update');
  p.fire(5000);
  await tick();
  assert.equal(p.reloads(), 0, 'nor is the five second check, while another worker controls the page');
});

test('a takeover that never reports control still reloads after five seconds, once the target controls the page', async () => {
  const p = await started({waiting: {id: 'next'}});
  p.sw.addEventListener = () => {};
  await p.pwa.updateNow();
  await tick();
  assert.equal(p.reloads(), 0);
  p.fire(5000);
  await tick();
  assert.equal(p.reloads(), 1);
});

test('updateNow with nothing waiting asks the browser to look and reloads', async () => {
  const p = await started();
  const before = p.updates();
  await p.pwa.updateNow();
  assert.equal(p.updates(), before + 1);
  assert.equal(p.reloads(), 1);
});

test('updateNow still reloads when the worker does not answer or the browser has no registration', async () => {
  const silent = await started({waiting: {id: 'next'}, silentWaiting: true});
  const updating = silent.pwa.updateNow();
  await tick();
  silent.fireAll(3000);
  await updating;
  assert.equal(silent.reloads(), 1);
  const none = await started({hasRegistration: false});
  await none.pwa.updateNow();
  assert.equal(none.reloads(), 1);
});
