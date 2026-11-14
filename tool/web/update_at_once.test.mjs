import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {createHash, webcrypto} from 'node:crypto';
import {readFileSync} from 'node:fs';

const swSource = readFileSync('web/pantas_sw.js', 'utf8');
const pwaSource = readFileSync('web/pantas_pwa.js', 'utf8');
const scope = 'https://app.example/';
function worker(versions = ['old'], network = async () => { throw Error('offline'); }, source = swSource) {
  const handlers = {};
  const stores = new Map(['old', 'new', 'unused'].map(v => ['pantas-shell-' + v, new Map([[scope + 'main.dart.js', new Response(v)]]) ]));
  let skips = 0;
  const clients = versions.map((version, i) => ({id: String(i), postMessage(data, ports) { ports[0].postMessage({version}); }}));
  class Channel { constructor() { this.port1 = {close() {}}; this.port2 = {postMessage: data => this.port1.onmessage?.({data}), close() {}}; } }
  const caches = {
    keys: async () => [...stores.keys()], delete: async n => stores.delete(n),
    open: async n => { if (!stores.has(n)) stores.set(n, new Map()); const m = stores.get(n); return {
      match: async r => m.get(typeof r === 'string' ? r : r.url)?.clone(),
      put: async (r, v) => m.set(typeof r === 'string' ? r : r.url, v),
    }; },
  };
  const self = {location: new URL(scope + 'pantas_sw.js?v=new'), registration: {scope},
    clients: {matchAll: async () => clients, get: async id => clients.find(c => c.id === id), claim: async () => {}},
    skipWaiting: async () => { skips++; }, addEventListener: (n, f) => handlers[n] = f};
  vm.runInNewContext(source, {self, caches, URL, Request, Response, crypto: webcrypto, MessageChannel: Channel, setTimeout, clearTimeout,
    fetch: network});
  async function dispatch(name, extra = {}) { const jobs = []; let answer; handlers[name]({...extra, waitUntil: p => jobs.push(p), respondWith: p => {answer = p;}}); const result = await answer; await Promise.all(jobs); return result; }
  return {stores, dispatch, clients, registration: self.registration, skips: () => skips};
}

test('activation keeps a live build, then removes it after its client closes', async () => {
  const w = worker(['old']);
  await w.dispatch('activate');
  assert.ok(w.stores.has('pantas-shell-old'));
  assert.ok(!w.stores.has('pantas-shell-unused'));
  w.clients.splice(0); await w.dispatch('activate');
  assert.ok(!w.stores.has('pantas-shell-old'));
});
test('an old page gets its own cached script after takeover', async () => {
  const w = worker(['old']);
  const r = await w.dispatch('fetch', {clientId: '0', request: new Request(scope + 'main.dart.js')});
  assert.equal(await r.text(), 'old');
});
test('unknown clients prevent deletion', async () => {
  const w = worker([null]); await w.dispatch('activate');
  assert.ok(w.stores.has('pantas-shell-old'));
});
test('only an explicit skipWaiting message activates a waiting worker', async () => {
  const w = worker();
  await w.dispatch('message', {data: {type: 'SKIP_WAITING'}});
  assert.equal(w.skips(), 1);
});

function page({version = 'new', offline = false, supported = true} = {}) {
  const events = {}, swEvents = {}, timers = [], calls = [];
  let now = 0, reloads = 0;
  const waiting = {scriptURL: scope + 'pantas_sw.js?v=new', postMessage: data => {
    calls.push(data.type); sw.controller = waiting; swEvents.controllerchange?.();
  }};
  const registration = {active: null, waiting, update: async () => calls.push('update'), addEventListener() {}};
  const sw = {controller: {scriptURL: scope + 'pantas_sw.js?v=old', postMessage() {}},
    register: async script => { calls.push(script); return registration; },
    addEventListener: (n, f) => swEvents[n] = f, removeEventListener() {}};
  const document = {visibilityState: 'visible', addEventListener: (n, f) => events[n] = f};
  const window = {document, addEventListener() {}, location: {reload: () => reloads++}, performance: {mark() {}}};
  const context = {window, document, navigator: supported ? {serviceWorker: sw} : {}, URL, Promise, encodeURIComponent,
    Date: {now: () => now}, setTimeout: (f, ms) => {timers.push({f, ms}); return timers.length;}, clearTimeout() {},
    fetch: async (url, options) => {calls.push({url, options}); if (offline) throw Error('offline'); return {ok: true, json: async () => ({pantasBuildVersion: version})};}};
  vm.runInNewContext(pwaSource, context);
  return {window, calls, timers, events, document, swEvents, sw, waiting, setNow: v => now = v, reloads: () => reloads};
}
async function start(p) {
  const job = p.window.pantasPwa.registerWorker('old');
  await new Promise(resolve => setImmediate(resolve));
  // Startup fallback timeout, if a mock worker never takes control.
  p.timers.filter(t => t.ms === 4000).forEach(t => t.f());
  await job;
}
test('check compares opaque build versions and caches unchanged results', async () => {
  const p = page({version: 'old'}); await start(p);
  assert.ok(p.window.pantasUpdate, 'update API exists');
  assert.equal(p.window.pantasUpdate.currentVersion, 'old');
  assert.equal((await p.window.pantasUpdate.check()).available, false);
  const count = p.calls.length; await p.window.pantasUpdate.check(); assert.equal(p.calls.length, count);
});
test('check discovers another build without activating or reloading', async () => {
  const p = page(); await start(p);
  const result = await p.window.pantasUpdate.check();
  assert.equal(result.available, true); assert.equal(result.version, 'new');
  assert.ok(p.calls.includes('update')); assert.ok(!p.calls.includes('SKIP_WAITING'));
  assert.equal(p.reloads(), 0);
  const request = p.calls.find(c => c.url); assert.equal(request.options.cache, 'no-store');
});
test('offline and unsupported checks resolve without an update', async () => {
  for (const options of [{offline: true}, {supported: false}]) {
    const p = page(options); await start(p);
    assert.equal((await p.window.pantasUpdate.check()).available, false);
    assert.equal(p.reloads(), 0);
  }
});
test('apply activates and reloads without deleting any storage', async () => {
  const p = page(); await start(p); await p.window.pantasUpdate.check();
  await p.window.pantasUpdate.apply();
  assert.ok(p.calls.includes('SKIP_WAITING')); assert.equal(p.reloads(), 1);
  // No storage APIs exist in this page: any attempted clearing would throw.
});
test('visible checks run after five minutes and on visibility return', async () => {
  const p = page({version: 'old'}); await start(p); await p.window.pantasUpdate.check();
  p.setNow(300001); p.document.visibilityState = 'visible';
  await p.events.visibilitychange();
  assert.equal(p.calls.filter(c => c.url).length, 2);
  assert.ok(p.timers.some(t => t.ms === 300000));
});

test('installing the shell leaves the worker waiting', async () => {
  const w = worker();
  // Offline install fails, but must not request takeover even on failure.
  await assert.rejects(w.dispatch('install'), /offline/);
  assert.equal(w.skips(), 0);
});
test('the fresh version request bypasses shell caching', async () => {
  const w = worker();
  assert.equal(await w.dispatch('fetch', {clientId: '0', request: new Request(scope + 'version.json', {cache: 'no-store'})}), undefined);
});

test('opening a page can fetch bootstrap even with several retained builds', async () => {
  const w = worker([null]);
  w.stores.get('pantas-shell-new').set(scope + 'flutter_bootstrap.js', new Response('bootstrap-new'));
  const response = await w.dispatch('fetch', {clientId: '0', request: new Request(scope + 'flutter_bootstrap.js')});
  assert.equal(await response.text(), 'bootstrap-new');
});

test('a timed-out apply cannot reload when another tab activates later', async () => {
  const p = page(); await start(p); await p.window.pantasUpdate.check();
  const waiting = p.window.pantasUpdate;
  const regCalls = p.calls;
  p.swEvents.controllerchange = undefined;
  p.waiting.postMessage = data => regCalls.push(data.type);
  const apply = waiting.apply(); await new Promise(resolve => setImmediate(resolve));
  const rejection = assert.rejects(apply, /timed out/);
  p.timers.filter(t => t.ms === 15000).forEach(t => t.f());
  await rejection;
  p.sw.controller = p.waiting; p.swEvents.controllerchange?.();
  assert.equal(p.reloads(), 0);
});

test('a successful installation does not activate itself', async () => {
  const w = worker([], async () => {
    const response = new Response('file');
    Object.defineProperty(response, 'type', {value: 'basic'});
    return response;
  });
  await w.dispatch('install');
  assert.equal(w.skips(), 0);
});
test('a tagged database worker uses its page build for WASM', async () => {
  const w = worker(['new']);
  w.clients[0].url = scope + 'drift_worker.js?pantas_build=new';
  w.clients[0].postMessage = () => {throw Error('Worker has no page handler');};
  w.stores.get('pantas-shell-new').set(scope + 'sqlite3.wasm', new Response('new-wasm'));
  const response = await w.dispatch('fetch', {clientId: '0', request: new Request(scope + 'sqlite3.wasm')});
  assert.equal(await response.text(), 'new-wasm');
});
test('a retired cache miss never downloads a new file into the old cache', async () => {
  let assetFetched = false;
  const w = worker(['old'], async request => {
    if (request.url.endsWith('version.json')) return new Response(JSON.stringify({pantasBuildVersion: 'new'}));
    assetFetched = true; return new Response('new');
  });
  w.stores.get('pantas-shell-old').set(scope + 'version.json', new Response(JSON.stringify({pantasBuildVersion: 'old'})));
  await assert.rejects(w.dispatch('fetch', {clientId: '0', request: new Request(scope + 'assets/missing.png')}), /Retired build/);
  assert.equal(assetFetched, false);
});

test('cleanup retains a pending build even when its URL has an old version', async () => {
  const w = worker(['old']);
  w.registration.waiting = {scriptURL: scope + 'pantas_sw.js?v=old'};
  await w.dispatch('activate');
  assert.ok(w.stores.has('pantas-shell-unused'));
});
test('stamped install verifies all shell bytes and rejects a deploy changing mid-install', async () => {
  const bytes = JSON.stringify({pantasBuildVersion: 'new'});
  const hash = createHash('sha256').update(bytes).digest('hex');
  const names = ['', 'flutter_bootstrap.js', 'pantas_history.js', 'pantas_pwa.js', 'pantas_welcome.js',
    'pantas_splash.js', 'manifest.json', 'version.json', 'favicon.png', 'icons/Icon-192.png', 'icons/Icon-512.png',
    'main.dart.js_1.part.js'];
  const hashes = Object.fromEntries(names.map(n => [n || 'index.html', hash]));
  const source = swSource.replace("const STAMPED_VERSION = '';", "const STAMPED_VERSION = 'new';")
    .replace('const SHELL_FILES = [];', "const SHELL_FILES = ['main.dart.js_1.part.js'];")
    .replace('const SHELL_HASHES = {};', `const SHELL_HASHES = ${JSON.stringify(hashes)};`);
  for (const changed of [false, true]) {
    const w = worker([], async request => {
      const response = new Response(changed && request.url.endsWith('.part.js') ? 'other-build' : bytes);
      Object.defineProperty(response, 'type', {value: 'basic'}); return response;
    }, source);
    if (changed) await assert.rejects(w.dispatch('install'), /Build file changed/);
    else {
      await w.dispatch('install');
      assert.ok(w.stores.get('pantas-shell-new').has(scope + 'main.dart.js_1.part.js'));
    }
    assert.equal(w.skips(), 0);
  }
});
