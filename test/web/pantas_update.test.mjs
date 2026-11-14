import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {readFileSync} from 'node:fs';

const source = readFileSync('web/pantas_pwa.js', 'utf8');
function page({version = 'next', failure = false, hang = false, updateFails = false} = {}) {
  const calls = [], timers = [], events = {};
  let reloads = 0, updates = 0;
  const document = {visibilityState: 'visible', addEventListener: (n, f) => events[n] = f};
  const registration = {update: async () => {updates++; if (updateFails) throw Error('worker offline');}};
  const window = {document, addEventListener() {}, performance: {mark() {}}, location: {reload: () => reloads++}};
  const config = {version, failure, hang};
  vm.runInNewContext(source, {
    window, document, navigator: {serviceWorker: {
      controller: null, register: async () => registration, getRegistration: async () => registration,
    }}, Promise, AbortController,
    setTimeout: (f, ms) => {timers.push({f, ms}); return timers.length;}, clearTimeout() {},
    fetch: async (url, options) => {
      calls.push({url, options});
      if (config.failure) throw Error('offline');
      if (config.hang) return new Promise(() => {});
      return {ok: true, json: async () => ({pantasBuildVersion: config.version})};
    },
  });
  return {window, document, config, calls, timers, events, reloads: () => reloads, updates: () => updates};
}
async function started(options) {
  const p = page(options);
  await p.window.pantasPwa.registerWorker('running');
  return p;
}
test('check detects a new version with no-store and refreshes the existing registration', async () => {
  const p = await started();
  assert.equal(p.window.pantasUpdate.currentVersion, 'running');
  const result = await p.window.pantasUpdate.check();
  assert.equal(result.available, true);
  assert.equal(result.version, 'next');
  assert.equal(p.calls[0].url, 'version.json');
  assert.equal(p.calls[0].options.cache, 'no-store');
  assert.equal(p.updates(), 1);
  assert.equal(p.reloads(), 0);
});
test('check reports no update for the page startup version', async () => {
  const p = await started({version: 'running'});
  assert.equal((await p.window.pantasUpdate.check()).available, false);
});
test('network failure remains retryable and still requests worker refresh', async () => {
  const p = await started({failure: true});
  await assert.rejects(p.window.pantasUpdate.check(), /offline/);
  p.config.failure = false;
  assert.equal((await p.window.pantasUpdate.check()).available, true);
  assert.equal(p.updates(), 2);
  assert.equal(p.reloads(), 0);
});
test('a slow check times out and the next safe point retries', async () => {
  const p = await started({hang: true});
  const checking = p.window.pantasUpdate.check();
  const rejected = assert.rejects(checking, /timed out/);
  p.timers.find(t => t.ms === 4000).f();
  await rejected;
  p.config.hang = false;
  assert.equal((await p.window.pantasUpdate.check()).available, true);
});
test('worker refresh failure does not hide version availability', async () => {
  const p = await started({updateFails: true});
  assert.equal((await p.window.pantasUpdate.check()).available, true);
});
test('missing version is rejected rather than treated as an update', async () => {
  const p = await started({version: undefined});
  p.config.version = undefined;
  await assert.rejects(p.window.pantasUpdate.check(), /Missing build version/);
});
test('checks before bootstrap do not claim a running version', async () => {
  const p = page();
  assert.equal((await p.window.pantasUpdate.check()).available, false);
  assert.equal(p.window.pantasUpdate.currentVersion, null);
});
test('apply only reloads, without fetching or worker operations', async () => {
  const p = await started();
  p.window.pantasUpdate.apply();
  assert.equal(p.reloads(), 1);
  assert.equal(p.calls.length, 0);
  assert.equal(p.updates(), 0);
});
test('visibility return and five-minute polling check without reloading', async () => {
  const p = await started();
  await p.events.visibilitychange();
  assert.equal(p.calls.length, 1);
  await p.timers.find(t => t.ms === 300000).f();
  assert.equal(p.calls.length, 2);
  p.document.visibilityState = 'hidden';
  await p.events.visibilitychange();
  await p.timers.filter(t => t.ms === 300000).at(-1).f();
  assert.equal(p.calls.length, 2);
  assert.equal(p.reloads(), 0);
});
