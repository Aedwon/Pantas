// Run with: node --test test/web/pantas_sw_build_mix.test.mjs
// Service worker build mix (CSE release lead r4, Nov 25). Offline, the shell
// (page, bootstrap, helper script, version.json) and the Dart files (main.dart.js
// and its parts) a worker serves must all come from ONE build. The fake world
// below has one server that serves the deployed build, one shared CacheStorage,
// and workers loaded from source. Every body starts with its build id.
// fixtures/pantas_sw_prod_a.js is origin/main's worker on Nov 25, the one
// already installed on phones when the fix ships.
import test from 'node:test';
// Parked (manager, Nov 25, option 2): these tests reproduce the build mix on
// today's worker and fail by design. The minimal fix failed a Codex audit; the
// real fix (per-file fingerprints bound to the build, take over only with a
// complete boot cache) is a worker migration that the Nov 14 correction bars
// until Aedwon lifts it. Trigger: before the beta gate drops for public launch.
const SKIP = 'parked until the worker migration is approved (see header)';

import assert from 'node:assert/strict';
import vm from 'node:vm';
import { readFileSync } from 'node:fs';

const current = readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8');
const prod = readFileSync(new URL('./fixtures/pantas_sw_prod_a.js', import.meta.url), 'utf8');
const ORIGIN = 'https://app.test/';
const SHELL = ['', 'flutter_bootstrap.js', 'pantas_pwa.js', 'version.json'];
const DART = ['main.dart.js', 'main.dart.js_1.part.js'];
const tick = () => new Promise((resolve) => setImmediate(resolve));

function basic(body, path = 'x') {
  const html = path === '';
  const response = new Response(body, {
    status: 200,
    headers: { 'Content-Type': html ? 'text/html' : 'application/javascript' },
  });
  Object.defineProperty(response, 'type', { value: 'basic' });
  return response;
}

function bodyOf(build, path) {
  if (path === 'version.json') return JSON.stringify({ pantasBuildVersion: build });
  if (path === 'main.dart.js') return `${build}|main.dart.js|main.dart.js_1.part.js`;
  return `${build}|${path || 'index'}|`;
}
const idOf = (path, text) => (path === 'version.json' ? JSON.parse(text).pantasBuildVersion : text.split('|')[0]);

function world() {
  const w = { build: null, offline: false, stores: new Map(), controller: null, requests: [] };
  const key = (request) => (typeof request === 'string' ? request : request.url);
  const strip = (url) => url.split('?')[0];
  w.caches = {
    open: async (name) => {
      if (!w.stores.has(name)) w.stores.set(name, new Map());
      const store = w.stores.get(name);
      return {
        match: async (request, options = {}) => {
          const url = options.ignoreSearch ? strip(key(request)) : key(request);
          for (const [stored, text] of store) {
            if ((options.ignoreSearch ? strip(stored) : stored) === url) return basic(text, strip(stored).replace(ORIGIN, ''));
          }
          return undefined;
        },
        put: async (request, response) => {
          store.set(key(request), await response.text());
        },
      };
    },
    keys: async () => [...w.stores.keys()],
    delete: async (name) => w.stores.delete(name),
  };
  w.network = async (request) => {
    const url = key(request);
    w.requests.push(url);
    if (w.offline) throw new TypeError('offline');
    const path = strip(url).replace(ORIGIN, '');
    if (!w.build) return new Response('', { status: 404 });
    if (!SHELL.includes(path) && !DART.includes(path)) return new Response('', { status: 404 });
    return basic(bodyOf(w.build, path), path);
  };
  return w;
}

// Loads one worker. `version` is the ?v= value of its URL.
function worker(w, source, version) {
  const handlers = {};
  const waits = [];
  const context = {
    URL, Request, Response, Headers, Promise, Set, Map, Math, Object, Array, JSON, Error, TypeError, console,
    TransformStream, ReadableStream, setTimeout, clearTimeout, Date,
    self: {
      location: { href: ORIGIN + `pantas_sw.js?v=${version}`, origin: 'https://app.test' },
      registration: { scope: ORIGIN },
      addEventListener: (type, fn) => (handlers[type] = fn),
      skipWaiting: async () => {},
      clients: { claim: async () => {}, get: async () => undefined },
    },
    caches: w.caches,
    fetch: (request) => w.network(request),
  };
  vm.runInNewContext(source, context);
  const lifecycle = async (type) => {
    const pending = [];
    handlers[type]({ waitUntil: (p) => pending.push(p) });
    await Promise.all(pending);
  };
  const self = {
    version,
    install: () => lifecycle('install'),
    activate: () => lifecycle('activate'),
    // Returns the worker's answer, or null when it lets the network answer.
    async fetch(path, { navigate = false } = {}) {
      let answer = null;
      const request = {
        method: 'GET', url: ORIGIN + path, mode: navigate ? 'navigate' : 'cors', headers: new Headers(),
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
  return self;
}

// What the page gets for one file through the controlling worker. 'miss' is a
// file that cannot be served at all, which is not a mix.
async function get(w, path, options) {
  try {
    const response = (await w.controller.fetch(path, options)) ?? (await w.network({ url: ORIGIN + path }));
    if (response.status !== 200) return { id: 'miss' };
    return { id: idOf(path, await response.text()) };
  } catch (_) {
    return { id: 'miss' };
  }
}

// The page loads online: the shell, then the Dart files.
async function pageLoad(w) {
  for (const path of SHELL) await get(w, path, { navigate: path === '' });
  for (const path of DART) await get(w, path);
}

// Goes offline and reads the whole set. Returns the build ids served.
async function offlineSet(w) {
  const before = w.offline;
  w.offline = true;
  const ids = {};
  for (const path of [...SHELL, ...DART]) ids[path || 'index'] = (await get(w, path, { navigate: path === '' })).id;
  w.offline = before;
  const builds = new Set(Object.values(ids).filter((id) => id !== 'miss'));
  return { ids, builds: [...builds], mixed: builds.size > 1 };
}

async function activate(w, source, version) {
  const next = worker(w, source, version);
  await next.install();
  return next;
}
async function takeOver(w, next) {
  await next.activate();
  w.controller = next;
}

// Build A is installed and used, then B is deployed and the page loads under A.
async function deployedBUnderA(sourceA) {
  const w = world();
  w.build = 'A';
  const a = await activate(w, sourceA, 'A');
  await takeOver(w, a);
  await pageLoad(w);
  w.build = 'B';
  await pageLoad(w);
  return w;
}

test('one build: online under A, B deployed, page reloaded, then offline (same worker code)', { skip: SKIP }, async () => {
  const w = await deployedBUnderA(current);
  const r = await offlineSet(w);
  assert.equal(r.mixed, false, `offline set mixes builds: ${JSON.stringify(r.ids)}`);
});

test('one build: deploy C after B is installed and in use, page reloaded, then offline', { skip: SKIP }, async () => {
  const w = world();
  w.build = 'B';
  const b = await activate(w, current, 'B');
  await takeOver(w, b);
  await pageLoad(w);
  w.build = 'C';
  await pageLoad(w);
  const r = await offlineSet(w);
  assert.equal(r.mixed, false, JSON.stringify(r.ids));
  assert.deepEqual(r.builds, ['B']);
});

test('online behavior is unchanged: a new deploy is seen at once under the installed worker', { skip: SKIP }, async () => {
  const w = world();
  w.build = 'B';
  const b = await activate(w, current, 'B');
  await takeOver(w, b);
  await pageLoad(w);
  w.build = 'C';
  assert.equal((await get(w, '', { navigate: true })).id, 'C');
  for (const path of ['flutter_bootstrap.js', 'pantas_pwa.js', 'version.json']) {
    assert.equal((await get(w, path)).id, 'C', path);
  }
  assert.equal((await get(w, 'main.dart.js')).id, 'B', 'Dart stays cache first');
});

test('install refuses a build that changed while it ran, and keeps no cache for it', { skip: SKIP }, async () => {
  const w = world();
  w.build = 'B';
  const late = worker(w, current, 'B');
  const network = w.network;
  w.network = async (request) => {
    const response = await network(request);
    if (String(request.url).endsWith('pantas_pwa.js')) w.build = 'C';
    return response;
  };
  await assert.rejects(late.install());
  assert.equal(w.stores.has('pantas-shell-B') && w.stores.get('pantas-shell-B').size > 0, false);
});

test('Dart files fetched after a newer deploy are not stored in the older build cache', { skip: SKIP }, async () => {
  const w = world();
  w.build = 'B';
  const b = await activate(w, current, 'B');
  await takeOver(w, b);
  w.build = 'C';
  await get(w, 'main.dart.js');
  await get(w, 'main.dart.js_1.part.js');
  const stored = [...w.stores.get('pantas-shell-B').keys()];
  assert.ok(!stored.some((url) => url.includes('main.dart.js')), stored.join());
  const r = await offlineSet(w);
  assert.equal(r.mixed, false, JSON.stringify(r.ids));
});

// ---- Rollout from the worker already on phones (prod) to the fixed worker ----

test('rollout: prod A, B deployed, page loads under A, B installs, B takes over', { skip: SKIP }, async () => {
  const w = await deployedBUnderA(prod);
  // Known window, and not fixable from B: prod A stores the new shell in its
  // own cache while it still controls the page. It lasts from that page load
  // until B activates, which needs the network. Offline in that window, A
  // serves B's shell with A's Dart.
  assert.equal((await offlineSet(w)).mixed, true, 'prod A window (recorded, cannot be fixed from B)');
  // B installs online. A still controls the page: the window stays open.
  const b = await activate(w, current, 'B');
  assert.equal((await offlineSet(w)).mixed, true, 'B installed, not yet active');
  // B activates: A's cache is deleted and B's cache holds only B.
  await takeOver(w, b);
  assert.deepEqual(w.stores.has('pantas-shell-A'), false);
  let r = await offlineSet(w);
  assert.equal(r.mixed, false, JSON.stringify(r.ids));
  assert.ok(r.builds.every((id) => id === 'B'));
  // The page loads under B: Dart files arrive and are stored.
  await pageLoad(w);
  r = await offlineSet(w);
  assert.deepEqual(r.builds, ['B']);
  assert.ok(r.ids['main.dart.js'] === 'B' && r.ids['index'] === 'B', JSON.stringify(r.ids));
  // Then C is deployed and the page loads again under B.
  w.build = 'C';
  await pageLoad(w);
  r = await offlineSet(w);
  assert.deepEqual(r.builds, ['B']);
});

test('rollout: prod A and a deploy that lands while B installs never leaves a mixed B cache', { skip: SKIP }, async () => {
  const w = await deployedBUnderA(prod);
  const network = w.network;
  const b = worker(w, current, 'B');
  w.network = async (request) => {
    const response = await network(request);
    if (String(request.url).endsWith('manifest.json')) w.build = 'C';
    return response;
  };
  await assert.rejects(b.install());
  w.network = network;
  const cached = w.stores.get('pantas-shell-B');
  assert.ok(!cached || cached.size === 0, 'a failed install stores nothing');
});
