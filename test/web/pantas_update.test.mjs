// Run with: node --test test/web/pantas_update.test.mjs
// Update detection and apply (Revision 1, items 2 and 5). An update is available
// only when a worker that verified its whole build is waiting; apply takes over into
// it only when this is the only window; nothing here deletes a cache or unregisters.
import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';
import {loadPage} from './fixtures/fake_page.mjs';

// A page that started on build 'running'. The update, if any, finishes installing after the start.
async function started(options) {
  const page = loadPage({controller: 'https://app.test/pantas_sw.js?v=running', ...options});
  await page.pwa.registerWorker('running');
  page.arrive();
  return page;
}

test('check finds a verified waiting worker of another build and asks the browser to look for it', async () => {
  const p = await started({waiting: {id: 'next'}});
  assert.equal(p.update.currentVersion, 'running');
  const result = await p.update.check();
  assert.deepEqual({...result}, {available: true, version: 'next'});
  assert.equal(p.updates(), 1);
  assert.equal(p.reloads(), 0);
});

test('with no waiting worker nothing is available, even if the server names a newer build', async () => {
  const p = await started();
  assert.deepEqual({...(await p.update.check())}, {available: false, version: null});
  assert.equal(p.updates(), 1, 'the browser was still asked to look');
});

test('a waiting worker of the running build is not an update', async () => {
  const p = await started({waiting: {id: 'running'}});
  assert.equal((await p.update.check()).available, false);
});

test('a worker that does not answer is not an update, and the check ends', async () => {
  const p = await started({waiting: {id: 'next'}, silentWaiting: true});
  const checking = p.update.check();
  await new Promise((done) => setImmediate(done));
  p.fire(3000); // the page gives up on the worker's answer
  assert.equal((await checking).available, false);
});

test('a failed worker look-up does not hide a worker that is already waiting', async () => {
  const p = await started({waiting: {id: 'next'}, updateFails: true});
  assert.equal((await p.update.check()).available, true);
});

test('no registration is no update', async () => {
  const p = await started({hasRegistration: false});
  assert.equal((await p.update.check()).available, false);
});

test('a slow check times out and the next safe point retries', async () => {
  const p = await started({waiting: {id: 'next'}, silentWaiting: true});
  const checking = p.update.check();
  const rejected = assert.rejects(checking, /timed out/);
  p.fire(4000);
  await rejected;
  assert.equal(p.timers.some((t) => t.ms === 4000 && t.cleared), true);
  const again = p.update.check();
  assert.notEqual(again, checking);
  await new Promise((done) => setImmediate(done));
  p.fireAll(3000); // the worker stays silent, so the page gives up on it
  assert.equal((await again).available, false);
});

test('overlapping checks share one look-up', async () => {
  const p = await started({waiting: {id: 'next'}});
  const first = p.update.check();
  const second = p.update.check();
  assert.equal(first, second);
  await first;
  assert.equal(p.updates(), 1);
});

test('checks before bootstrap do not claim a running version', async () => {
  const p = loadPage({controller: null});
  assert.deepEqual({...(await p.update.check())}, {available: false, version: null});
  assert.equal(p.update.currentVersion, null);
});

const tick = () => new Promise((done) => setImmediate(done));

test('apply asks the waiting worker to take over and reloads when it controls the page', async () => {
  const p = await started({waiting: {id: 'next'}});
  const applied = await p.update.apply();
  assert.equal(applied, true, 'apply reports the takeover');
  assert.deepEqual(p.posted.map((m) => m.type).slice(0, 2), ['pantas-build-id', 'pantas-take-over']);
  await tick();
  assert.equal(p.reloads(), 1, 'reloaded once the worker took control');
});

test('apply does nothing when another window is open: the worker refuses, and apply says so', async () => {
  const p = await started({waiting: {id: 'next', windowsOk: false}});
  assert.equal(await p.update.apply(), false, 'a refusal is not an applied update (audit 2, Medium 7)');
  assert.equal(p.reloads(), 0);
  assert.equal(p.listening(), 0, 'the page stopped waiting for a takeover that will not come');
  p.controllerChange();
  await tick();
  assert.equal(p.reloads(), 0);
});

test('apply with nothing waiting does not reload, and says nothing was applied', async () => {
  const p = await started();
  assert.equal(await p.update.apply(), false);
  assert.equal(p.reloads(), 0);
  assert.deepEqual(p.posted, []);
});

test('a takeover that never reports control still reloads after five seconds, once the target controls the page', async () => {
  const p = await started({waiting: {id: 'next'}});
  p.sw.addEventListener = () => {};
  await p.update.apply();
  await tick();
  assert.equal(p.reloads(), 0);
  p.fire(5000);
  await tick();
  assert.equal(p.reloads(), 1);
});

test('the page reloads only when the worker that controls it is the one it asked, not another worker', async () => {
  const p = await started({waiting: {id: 'next', controls: false}});
  assert.equal(await p.update.apply(), true, 'the worker accepted');
  await tick();
  assert.equal(p.reloads(), 0, 'a controllerchange to some other worker is not the update');
  p.fire(5000);
  await tick();
  assert.equal(p.reloads(), 0, 'nor is the five second check, while another worker controls the page');
});

test('a reload happens once even if the worker reports control twice', async () => {
  const p = await started({waiting: {id: 'next'}});
  await p.update.apply();
  p.controllerChange();
  p.controllerChange();
  await tick();
  assert.equal(p.reloads(), 1);
});

// ---- A takeover asked for at startup expires with the startup (audit 2, Medium 7) ----

test('a startup takeover that answers after the page stopped waiting does not reload the running app', async () => {
  const p = loadPage({controller: 'https://app.test/pantas_sw.js?v=running', waitingAtLoad: true, waiting: {id: 'next', holdTakeOver: true}});
  const startup = p.pwa.registerWorker('running');
  await tick();
  p.fire(2500); // the page gives up waiting and starts Flutter
  assert.equal(await startup, false);
  p.releaseTakeOver(); // the worker answers late: it did take over
  await tick();
  await tick();
  assert.equal(p.reloads(), 0, 'no reload under a running app');
  assert.equal(p.listening(), 0, 'and nothing is left listening');
  p.fire(5000);
  await tick();
  assert.equal(p.reloads(), 0);
});

test('a startup takeover that answers in time still reloads into the new build before Flutter starts', async () => {
  const p = loadPage({controller: 'https://app.test/pantas_sw.js?v=running', waitingAtLoad: true, waiting: {id: 'next'}});
  assert.equal(await p.pwa.registerWorker('running'), true);
  await tick();
  assert.equal(p.reloads(), 1);
});

// ---- Audit 3, Medium: never a late reload, never a stuck splash ----

test('audit 3: a controller that answers "which build?" after the page started Flutter does not reload the running app', async () => {
  const p = loadPage({
    controller: 'https://app.test/pantas_sw.js?v=running', waitingAtLoad: true,
    waiting: {id: 'next', holdTakeOver: true, holdControllerReply: true},
  });
  const startup = p.pwa.registerWorker('running');
  await tick(); // the take-over request is out, its answer held
  // The new worker controls the page: the page asks it who it is, and the answer is slow.
  p.sw.controller = p.waitingWorker;
  p.controllerChange();
  await tick();
  p.fire(2500); // the page stops waiting and starts Flutter
  assert.equal(await startup, false);
  p.releaseControllerReply(); // the slow answer arrives: it is the asked build
  await tick();
  await tick();
  assert.equal(p.reloads(), 0, 'a reload after startup would tear the running app down');
  p.releaseTakeOver();
  await tick();
  p.fire(5000);
  await tick();
  assert.equal(p.reloads(), 0);
});

test('audit 3: a takeover the worker accepted but that never gives the page the asked controller starts Flutter at the limit', async () => {
  const p = loadPage({controller: 'https://app.test/pantas_sw.js?v=running', waitingAtLoad: true, waiting: {id: 'next', controls: false}});
  const startup = p.pwa.registerWorker('running');
  await tick();
  p.fire(2500);
  assert.equal(await startup, false, 'the splash must not wait for a reload that no controller change will trigger');
  assert.equal(p.reloads(), 0);
  assert.equal(p.listening(), 0, 'and nothing is left listening');
});

test('audit 3: the bootstrap starts Flutter when the takeover it waited for does not come', async () => {
  const p = loadPage({controller: 'https://app.test/pantas_sw.js?v=running', waitingAtLoad: true, waiting: {id: 'next', controls: false}});
  const loads = [];
  p.context._flutter = {loader: {load: (options) => loads.push(options)}};
  p.context.performance = {mark() {}};
  const bootstrap = readFileSync(new URL('../../web/flutter_bootstrap.js', import.meta.url), 'utf8')
    .replace('{{flutter_js}}', '').replace('{{flutter_build_config}}', '').replace('{{flutter_service_worker_version}}', '"running"');
  vm.runInContext(bootstrap, p.context);
  await tick();
  assert.equal(loads.length, 0, 'still waiting for the takeover');
  p.fire(2500);
  await tick();
  await tick();
  assert.equal(loads.length, 1, 'the splash must end: Flutter starts on the build the page has');
});

test('visibility return and five-minute polling check without reloading', async () => {
  const p = await started({waiting: {id: 'next'}});
  await p.listeners.visibilitychange();
  assert.equal(p.updates(), 1);
  await p.fire(300000)?.valueOf();
  await new Promise((done) => setImmediate(done));
  assert.equal(p.updates(), 2);
  p.document.visibilityState = 'hidden';
  await p.listeners.visibilitychange();
  assert.equal(p.updates(), 2);
  assert.equal(p.reloads(), 0);
});

test('the page never unregisters the worker or deletes a cache', async () => {
  const p = await started({waiting: {id: 'next'}});
  p.sw.getRegistrations = () => assert.fail('getRegistrations');
  p.registration.unregister = () => assert.fail('unregister');
  await p.update.check();
  await p.update.apply();
  await p.pwa.updateNow();
});

test('updateNow takes over into a waiting build and does not reload twice', async () => {
  const p = await started({waiting: {id: 'next'}});
  await p.pwa.updateNow();
  await Promise.resolve();
  assert.equal(p.reloads(), 1, 'one reload, from the takeover');
});

test('updateNow with nothing waiting asks the browser to look and reloads', async () => {
  const p = await started();
  await p.pwa.updateNow();
  assert.equal(p.updates(), 1);
  assert.equal(p.reloads(), 1);
});

test('updateNow still reloads when the worker refuses or the browser has no registration', async () => {
  const refused = await started({waiting: {id: 'next', windowsOk: false}});
  await refused.pwa.updateNow();
  assert.equal(refused.reloads(), 1);
  const none = await started({hasRegistration: false});
  await none.pwa.updateNow();
  assert.equal(none.reloads(), 1);
});
