// Run with: node --test test/web/pantas_sw_build_mix.test.mjs
// Service worker build mix (CSE release lead, Nov 25, plan
// docs/superpowers/plans/2026-11-25-sw-build-mix-option1.md). The page, its
// scripts and the Dart files (main.dart.js and its parts) a worker serves must
// all come from ONE build, online or offline, across a deploy, a rollback, and
// the move from the worker already on phones. The fake world below has one
// server that serves the deployed build, one shared CacheStorage, and workers
// loaded from source. Builds are real stamped builds of a tiny fixture tree
// (fixtures/sw_fixture_build.mjs), so the stamp tool and the worker are the real
// files. Every body carries @build:<id>@.
// fixtures/pantas_sw_prod_a.js is origin/main's worker on Nov 25, the one
// already installed on phones when the fix ships.
import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {mkdtempSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {readFileSync} from 'node:fs';
import {buildOf, STARTUP, writeBuild} from './fixtures/sw_fixture_build.mjs';

const prodSource = readFileSync(new URL('./fixtures/pantas_sw_prod_a.js', import.meta.url), 'utf8');
const ORIGIN = 'https://app.test/';
const SHELL = ['', 'flutter_bootstrap.js', 'pantas_pwa.js', 'version.json'];
const DART = ['main.dart.js', 'main.dart.js_1.part.js'];
// Every file a boot needs, as the page asks for it.
const BOOT = [...SHELL.filter((path) => path !== 'version.json'), ...DART, 'drift_worker.js', 'sqlite3.wasm', 'manifest.json'];
const keyOf = (request) => (typeof request === 'string' ? request : request.url);

// Builds are made once per test run: each is a stamped copy of the fixture tree.
const scratch = mkdtempSync(join(tmpdir(), 'sw-mix-'));
const builds = {};
function build(id, options = {}) {
  const name = options.prod ? `${id}-prod` : id;
  if (!builds[name]) {
    const dir = join(scratch, name);
    builds[name] = {id, served: writeBuild(dir, id, options), dir};
  }
  return builds[name];
}
test.after(() => rmSync(scratch, {recursive: true, force: true}));
const workerOf = (b) => b.served['pantas_sw.js'];

function basic(body, path = 'x') {
  const html = path === '' || path === 'index.html';
  const response = new Response(body, {
    status: 200,
    headers: {'Content-Type': html ? 'text/html' : 'application/javascript'},
  });
  Object.defineProperty(response, 'type', {value: 'basic'});
  return response;
}

function world() {
  const w = {
    build: null, offline: false, stores: new Map(), controller: null, requests: [], tamper: {}, events: [],
    dropAfter: null,
  };
  const strip2 = (url) => url.split('?')[0];
  w.caches = {
    has: async (name) => w.stores.has(name),
    open: async (name) => {
      if (!w.stores.has(name)) w.stores.set(name, new Map());
      const store = w.stores.get(name);
      return {
        match: async (request, options = {}) => {
          const url = options.ignoreSearch ? strip2(keyOf(request)) : keyOf(request);
          for (const [stored, text] of store) {
            if ((options.ignoreSearch ? strip2(stored) : stored) === url) return basic(text, strip2(stored).replace(ORIGIN, ''));
          }
          return undefined;
        },
        put: async (request, response) => {
          store.set(keyOf(request), await response.text());
        },
        keys: async () => [...store.keys()].map((url) => ({url})),
        delete: async (request) => store.delete(keyOf(request)),
      };
    },
    keys: async () => [...w.stores.keys()],
    delete: async (name) => w.stores.delete(name),
  };
  w.network = async (request) => {
    const url = keyOf(request);
    w.requests.push(url);
    if (w.offline) throw new TypeError('offline');
    if (w.dropAfter !== null && w.requests.length > w.dropAfter) throw new TypeError('connection lost');
    const path = strip2(url).replace(ORIGIN, '');
    if (!w.build) return new Response('', {status: 404});
    const served = builds[w.build].served;
    const file = path === '' ? '' : path;
    if (!(file in served) || file === 'pantas_sw.js') return new Response('', {status: 404});
    const body = w.tamper[file] ?? served[file];
    return basic(body, path);
  };
  return w;
}

// Loads one worker. `version` is the ?v= value of its URL.
function worker(w, source, version) {
  const handlers = {};
  const waits = [];
  const context = {
    URL, Request, Response, Headers, Promise, Set, Map, Math, Object, Array, JSON, Error, TypeError, console,
    TransformStream, ReadableStream, setTimeout, clearTimeout, Date, crypto, Uint8Array, ArrayBuffer, String,
    self: {
      location: {href: ORIGIN + `pantas_sw.js?v=${version}`, origin: 'https://app.test'},
      registration: {scope: ORIGIN},
      addEventListener: (type, fn) => (handlers[type] = fn),
      skipWaiting: async () => {
        w.events.push({event: 'skipWaiting', version, stores: new Map([...w.stores].map(([k, v]) => [k, v.size]))});
      },
      clients: {claim: async () => w.events.push({event: 'claim', version}), get: async () => undefined},
    },
    caches: w.caches,
    fetch: (request) => w.network(request),
  };
  vm.runInNewContext(source, context);
  const lifecycle = async (type) => {
    const pending = [];
    handlers[type]({waitUntil: (p) => pending.push(p)});
    await Promise.all(pending);
  };
  return {
    version,
    install: () => lifecycle('install'),
    activate: () => lifecycle('activate'),
    // Returns the worker's answer, or null when it lets the network answer.
    async fetch(path, {navigate = false, headers = {}} = {}) {
      let answer = null;
      const request = {
        method: 'GET', url: ORIGIN + path, mode: navigate ? 'navigate' : 'cors', headers: new Headers(headers),
      };
      handlers.fetch({
        request, clientId: '',
        respondWith: (p) => (answer = Promise.resolve(p)),
        waitUntil: (p) => waits.push(Promise.resolve(p).catch(() => {})),
      });
      const response = answer ? await answer : null;
      await Promise.all(waits.splice(0));
      return response;
    },
  };
}

// What the page gets for one file through the controlling worker. 'miss' is a
// file that cannot be served at all, which is not a mix.
async function get(w, path, options) {
  try {
    const response = (await w.controller.fetch(path, options)) ?? (await w.network({url: ORIGIN + path}));
    if (response.status !== 200) return {id: 'miss', status: response.status};
    return {id: buildOf(await response.text()) ?? 'none'};
  } catch (_) {
    return {id: 'miss'};
  }
}

// The page loads online: the shell, then the Dart files.
async function pageLoad(w) {
  for (const path of SHELL) await get(w, path, {navigate: path === ''});
  for (const path of DART) await get(w, path);
}

// Goes offline and reads every boot file. Returns the build ids served.
async function offlineSet(w) {
  const before = w.offline;
  w.offline = true;
  const ids = {};
  for (const path of BOOT) ids[path || 'index'] = (await get(w, path, {navigate: path === ''})).id;
  w.offline = before;
  const found = new Set(Object.values(ids).filter((id) => id !== 'miss'));
  return {ids, builds: [...found], mixed: found.size > 1, misses: Object.entries(ids).filter(([, id]) => id === 'miss').map(([p]) => p)};
}

async function install(w, id, {prod = false} = {}) {
  const b = build(id, prod ? {prod: true} : {});
  const next = worker(w, prod ? prodSource : workerOf(b), id);
  await next.install();
  return next;
}
async function takeOver(w, next) {
  await next.activate();
  w.controller = next;
}
function deploy(w, id, options) {
  build(id, options);
  w.build = options?.prod ? `${id}-prod` : id;
}

// Build A is installed and used, then B is deployed and the page loads under A.
async function deployedBUnderA(options = {}) {
  const w = world();
  deploy(w, 'A', options);
  const a = await install(w, 'A', options);
  await takeOver(w, a);
  await pageLoad(w);
  deploy(w, 'B');
  await pageLoad(w);
  return w;
}

test('one build: online under A, B deployed, page reloaded, then offline', async () => {
  const w = await deployedBUnderA();
  const r = await offlineSet(w);
  assert.equal(r.mixed, false, `offline set mixes builds: ${JSON.stringify(r.ids)}`);
  assert.deepEqual(r.builds, ['A']);
  assert.deepEqual(r.misses, [], 'every boot file is available offline');
});

test('one build: deploy C after B is installed and in use, page reloaded, then offline', async () => {
  const w = world();
  deploy(w, 'B');
  const b = await install(w, 'B');
  await takeOver(w, b);
  await pageLoad(w);
  deploy(w, 'C');
  await pageLoad(w);
  const r = await offlineSet(w);
  assert.equal(r.mixed, false, JSON.stringify(r.ids));
  assert.deepEqual(r.builds, ['B']);
});

test('online, the installed worker serves its own build for every boot file; version.json comes from the network', async () => {
  const w = world();
  deploy(w, 'B');
  const b = await install(w, 'B');
  await takeOver(w, b);
  await pageLoad(w);
  deploy(w, 'C');
  // A new build reaches the page only through a new worker that verified its whole set.
  for (const path of BOOT) {
    assert.equal((await get(w, path, {navigate: path === ''})).id, 'B', path);
  }
  assert.equal((await get(w, 'version.json')).id, 'C', 'version.json is network only');
  for (const [name, store] of w.stores) {
    assert.ok(![...store.keys()].some((url) => url.includes('version.json')), `${name} stores version.json`);
  }
});

test('install refuses a build that changed while it ran, and keeps no cache for it', async () => {
  const w = world();
  deploy(w, 'B');
  deploy(w, 'C');
  w.build = 'B';
  const late = worker(w, workerOf(build('B')), 'B');
  const network = w.network;
  let seen = 0;
  w.network = async (request) => {
    const response = await network(request);
    if (++seen === 3) w.build = 'C';
    return response;
  };
  await assert.rejects(late.install());
  assert.equal(w.events.some((e) => e.event === 'skipWaiting'), false);
  assert.equal(w.stores.has('pantas-shell-B') && w.stores.get('pantas-shell-B').size > 0, false);
});

test('Dart files fetched after a newer deploy are not stored in the older build cache', async () => {
  const w = world();
  deploy(w, 'B');
  const b = await install(w, 'B');
  await takeOver(w, b);
  const before = JSON.stringify([...w.stores.get(cacheOf('B')).entries()]);
  deploy(w, 'C');
  await get(w, 'main.dart.js');
  await get(w, 'main.dart.js_1.part.js');
  assert.equal(JSON.stringify([...w.stores.get(cacheOf('B')).entries()]), before, 'the cache did not change');
  const r = await offlineSet(w);
  assert.equal(r.mixed, false, JSON.stringify(r.ids));
});

const cacheOf = (id) => `pantas-shell-${build(id).served['pantas_sw.js'].match(/"id":"([^"]+)"/)[1]}`;

// ---- Rollout from the worker already on phones (prod) to the fixed worker ----

test('rollout: prod A, B deployed, page loads under A, B installs, B takes over', async () => {
  const w = await deployedBUnderA({prod: true});
  // Known window, and not fixable from B: prod A stores the new shell in its
  // own cache while it still controls the page. It lasts from that page load
  // until B activates, which needs the network. Offline in that window, A
  // serves B's shell with A's Dart.
  assert.equal((await offlineSet(w)).mixed, true, 'prod A window (recorded, cannot be fixed from B)');
  // B installs online. A still controls the page: the window stays open.
  const b = await install(w, 'B');
  assert.equal((await offlineSet(w)).mixed, true, 'B installed, not yet active');
  // B activates: A's cache is deleted and B's cache holds only B.
  await takeOver(w, b);
  assert.deepEqual([...w.stores.keys()], [cacheOf('B')]);
  let r = await offlineSet(w);
  assert.equal(r.mixed, false, JSON.stringify(r.ids));
  assert.deepEqual(r.builds, ['B']);
  assert.deepEqual(r.misses, [], 'offline boot works at once after activation');
  // The page loads under B.
  await pageLoad(w);
  r = await offlineSet(w);
  assert.deepEqual(r.builds, ['B']);
  // Then C is deployed and the page loads again under B.
  deploy(w, 'C');
  await pageLoad(w);
  r = await offlineSet(w);
  assert.deepEqual(r.builds, ['B']);
});

test('rollout: prod A and a deploy that lands while B installs never leaves a mixed B cache', async () => {
  const w = await deployedBUnderA({prod: true});
  const network = w.network;
  const b = worker(w, workerOf(build('B')), 'B');
  let seen = 0;
  deploy(w, 'C');
  w.build = 'B';
  w.network = async (request) => {
    const response = await network(request);
    if (++seen === 2) w.build = 'C';
    return response;
  };
  await assert.rejects(b.install());
  w.network = network;
  assert.equal(w.events.some((e) => e.event === 'skipWaiting'), false);
  const cached = w.stores.get(cacheOf('B'));
  assert.ok(!cached || cached.size === 0, 'a failed install stores nothing');
});

// ---- The new worker's own rules ----

for (const path of ['main.dart.js', 'index.html', 'assets/FontManifest.json', 'sqlite3.wasm']) {
  test(`install fails and the old worker stays when ${path} does not match its hash`, async () => {
    const w = world();
    deploy(w, 'A');
    const a = await install(w, 'A');
    await takeOver(w, a);
    deploy(w, 'B');
    w.tamper[path] = build('B').served[path] + ' tampered';
    const events = w.events.length;
    const b = worker(w, workerOf(build('B')), 'B');
    await assert.rejects(b.install(), new RegExp(path.replace('.', '\\.')));
    assert.equal(w.events.length, events, 'no skipWaiting');
    assert.ok(w.stores.has(cacheOf('A')), 'the old cache stays');
    assert.equal(w.stores.has(cacheOf('B')) && w.stores.get(cacheOf('B')).size > 0, false);
    delete w.tamper[path];
    assert.deepEqual((await offlineSet(w)).builds, ['A']);
  });
}

test('a partial cache never activates: the connection drops before the last file', async () => {
  const w = world();
  deploy(w, 'A');
  const a = await install(w, 'A');
  await takeOver(w, a);
  deploy(w, 'B');
  const events = w.events.length;
  w.dropAfter = w.requests.length + 6;
  const b = worker(w, workerOf(build('B')), 'B');
  await assert.rejects(b.install());
  assert.equal(w.events.length, events, 'no skipWaiting');
  const partial = w.stores.get(cacheOf('B'));
  assert.ok(!partial || partial.size === 0, 'nothing of B is stored before all of B is verified');
  w.dropAfter = null;
  assert.deepEqual((await offlineSet(w)).builds, ['A'], 'the old worker still boots');
});

test('skipWaiting comes only after the whole set is stored, and old caches go only after activation', async () => {
  const w = world();
  deploy(w, 'A');
  const a = await install(w, 'A');
  await takeOver(w, a);
  deploy(w, 'B');
  const b = await install(w, 'B');
  const skip = w.events.filter((e) => e.event === 'skipWaiting').at(-1);
  assert.equal(skip.version, 'B');
  assert.ok(skip.stores.get(cacheOf('B')) >= STARTUP.length + 1, 'the full set and its marker were stored first');
  assert.ok(w.stores.has(cacheOf('A')), 'installed, not activated: the old cache stays');
  await b.activate();
  assert.deepEqual([...w.stores.keys()], [cacheOf('B')]);
  const order = w.events.filter((e) => e.version === 'B').map((e) => e.event);
  assert.deepEqual(order, ['skipWaiting', 'claim']);
});

test('B to C to B: a rollback never mixes builds', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  await pageLoad(w);
  deploy(w, 'C');
  await pageLoad(w);
  assert.deepEqual((await offlineSet(w)).builds, ['B']);
  const c = await install(w, 'C');
  assert.deepEqual((await offlineSet(w)).builds, ['B'], 'C installed, B still controls');
  await takeOver(w, c);
  await pageLoad(w);
  assert.deepEqual((await offlineSet(w)).builds, ['C']);
  // Rollback: the server serves B again while C controls. Edge skew, both ways.
  deploy(w, 'B');
  await pageLoad(w);
  const midRollback = await offlineSet(w);
  assert.deepEqual(midRollback.builds, ['C'], JSON.stringify(midRollback.ids));
  // B's worker installs again from the rolled-back server and takes over.
  const b2 = await install(w, 'B');
  assert.deepEqual((await offlineSet(w)).builds, ['C']);
  await takeOver(w, b2);
  const after = await offlineSet(w);
  assert.deepEqual(after.builds, ['B'], JSON.stringify(after.ids));
  assert.deepEqual(after.misses, []);
  assert.deepEqual([...w.stores.keys()], [cacheOf('B')]);
});

test('a response outside the set is never stored', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  const before = JSON.stringify([...w.stores].map(([k, v]) => [k, [...v.keys()]]));
  for (const path of ['og-image.png', 'README.md', 'assets/NOTICES', 'version.json', 'flutter_service_worker.js', 'nothing/here.js']) {
    const answer = await w.controller.fetch(path);
    assert.equal(answer, null, `${path} goes to the network untouched`);
    await w.network({url: ORIGIN + path});
  }
  assert.equal(JSON.stringify([...w.stores].map(([k, v]) => [k, [...v.keys()]])), before);
});

test('an app route is the cached page of this build, online and offline', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  deploy(w, 'C');
  assert.equal((await get(w, 'quiz/start', {navigate: true})).id, 'B');
  w.offline = true;
  assert.equal((await get(w, 'quiz/start', {navigate: true})).id, 'B');
  assert.equal((await get(w, 'index.html', {navigate: true})).id, 'B');
});

test('a set file missing from the cache is checked against its hash and not stored', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  w.stores.get(cacheOf('B')).delete(ORIGIN + 'drift_worker.js');
  const sizeBefore = w.stores.get(cacheOf('B')).size;
  assert.equal((await get(w, 'drift_worker.js')).id, 'B');
  assert.equal(w.stores.get(cacheOf('B')).size, sizeBefore, 'not stored');
  // The server moved to another build: the answer is refused, not served as B.
  deploy(w, 'C');
  assert.equal((await get(w, 'drift_worker.js')).id, 'miss');
});

test('credentials and ranges pass through untouched', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  assert.notEqual(await w.controller.fetch('main.dart.js'), null, 'a plain GET is served');
  assert.equal(await w.controller.fetch('main.dart.js', {headers: {Authorization: 'Bearer x'}}), null);
  assert.equal(await w.controller.fetch('main.dart.js', {headers: {Range: 'bytes=0-9'}}), null);
  assert.equal(await w.controller.fetch('__/auth/handler', {navigate: true}), null);
  assert.equal(await w.controller.fetch('wrapped/abc', {navigate: true}), null);
});

test('the shipped worker file carries the unstamped marker, so dev keeps today\'s behavior', () => {
  const source = readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8');
  assert.match(source, /\/\*pantas-build\*\/ null \/\*end-pantas-build\*\//);
});
