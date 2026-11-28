// Run with: node --test test/web/pantas_sw_build_mix.test.mjs
// Service worker build mix (CSE release lead, Nov 25 and Nov 26, plan
// docs/superpowers/plans/2026-11-25-sw-build-mix-option1.md, Revision 1). Every
// file a page loads lives in b/<id>/ and the page names those URLs, so a page can
// only ever run the files of its own build. The worker stores a build's whole set,
// verified, and takes over only when no other build is open. The fake world below
// has one server that serves the deployed build, one shared CacheStorage, and
// workers loaded from source. Builds are real stamped builds of a tiny fixture tree
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
import {parseHeaders} from '../../tool/cloudflare-app/compare.mjs';
import {buildOf, constantOf, writeBuild} from './fixtures/sw_fixture_build.mjs';

const prodSource = readFileSync(new URL('./fixtures/pantas_sw_prod_a.js', import.meta.url), 'utf8');
const ORIGIN = 'https://app.test/';
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
// The build folder of a build ('b/<id>/'), and a file in it.
const folderOf = (id) => constantOf(build(id).served).base;
const inFolder = (id, name) => folderOf(id) + name;
const cacheOf = (id) => {
  const {id: stamped, list} = constantOf(build(id).served);
  return `pantas-build-${stamped}-${list}`;
};

// The headers the edge sends, from the real prod headers file.
const edge = parseHeaders(readFileSync(new URL('../../tool/cloudflare-app/headers.prod', import.meta.url), 'utf8'));

// `stored` is the header list a cache kept; without it the edge's headers apply.
function basic(body, path = 'x', stored = null, extra = {}) {
  const html = path === '' || path === 'index.html';
  const headers = new Headers(stored ?? {'Content-Type': html ? 'text/html' : 'application/javascript', ...edge.expected('/' + path), ...extra});
  const response = new Response(body, {status: 200, headers});
  Object.defineProperty(response, 'type', {value: 'basic'});
  return response;
}

function world() {
  const w = {
    build: null, offline: false, stores: new Map(), controller: null, requests: [], tamper: {}, events: [],
    dropAfter: null, windows: 1, extraHeaders: {}, chromium: true, cacheModes: {},
    // Each open window is a client with an id; a reload gives every window a new one (a new document).
    // `clientIds` names the windows exactly when a test needs one tab to stay while another goes.
    generation: 1, clientIds: null,
    // What the edge answers at an address that is not in the deployed build (a root file of an older build).
    edge: {},
    // The registration's installing and waiting workers, and the browser's Web Locks (null: a browser without them).
    installing: null, waiting: null, active: null, locks: makeLocks(),
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
          for (const [stored, {text, headers}] of store) {
            if ((options.ignoreSearch ? strip2(stored) : stored) === url) return basic(text, strip2(stored).replace(ORIGIN, ''), headers);
          }
          return undefined;
        },
        put: async (request, response) => {
          store.set(keyOf(request), {text: await response.text(), headers: [...response.headers]});
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
    w.cacheModes[url] = request.cache;
    if (w.offline) throw new TypeError('offline');
    if (w.dropAfter !== null && w.requests.length > w.dropAfter) throw new TypeError('connection lost');
    const path = strip2(url).replace(ORIGIN, '');
    if (path in w.edge) return basic(w.edge[path], path);
    if (!w.build) return new Response('', {status: 404});
    const served = builds[w.build].served;
    if (!(path in served) || path === 'pantas_sw.js') return new Response('', {status: 404});
    return basic(w.tamper[path] ?? served[path], path, null, w.extraHeaders[path] ?? {});
  };
  return w;
}

// The browser's Web Locks for the origin: exclusive, first come first served, and a request
// that is not yet granted ends with an AbortError when its signal fires.
function makeLocks() {
  const waiting = [];
  let busy = false;
  const next = () => {
    if (busy || !waiting.length) return;
    busy = true;
    waiting.shift().grant();
  };
  return {
    names: [],
    isHeld: () => busy,
    request(name, options, callback) {
      this.names.push(name);
      return new Promise((resolve, reject) => {
        const entry = {
          grant: async () => {
            try {
              resolve(await callback());
            } catch (error) {
              reject(error);
            } finally {
              busy = false;
              next();
            }
          },
        };
        options.signal?.addEventListener('abort', () => {
          const at = waiting.indexOf(entry);
          if (at >= 0) {
            waiting.splice(at, 1);
            reject(Object.assign(new Error('The request was aborted.'), {name: 'AbortError'}));
          }
        });
        waiting.push(entry);
        next();
      });
    },
  };
}

// Loads one worker. `version` is the ?v= value of its URL. Like a browser, it shows itself as the
// registration's installing worker while its install event runs, and as the waiting worker after.
function worker(w, source, version) {
  const handlers = {};
  const waits = [];
  const self = {
    location: {href: ORIGIN + `pantas_sw.js?v=${version}`, origin: 'https://app.test'},
    get registration() {
      return {scope: ORIGIN, installing: w.installing, waiting: w.waiting, active: w.active};
    },
    navigator: w.locks ? {locks: w.locks} : {},
    addEventListener: (type, fn) => (handlers[type] = fn),
    skipWaiting: async () => {
      w.events.push({event: 'skipWaiting', version, stores: new Map([...w.stores].map(([k, v]) => [k, v.size]))});
    },
    clients: {
      claim: async () => w.events.push({event: 'claim', version}),
      get: async () => undefined,
      matchAll: async () => (w.clientIds ?? Array.from({length: w.windows}, (_, i) => `w${w.generation}.${i}`)).map((id) => ({id})),
    },
  };
  const context = {
    URL, Request, Response, Headers, Promise, Set, Map, Math, Object, Array, JSON, Error, TypeError, console,
    TransformStream, ReadableStream, clearTimeout, Date, crypto, Uint8Array, ArrayBuffer, String, AbortController, MessageChannel,
    // The lock's time limit (ten seconds) is shortened so a test of a lock nobody releases ends at once.
    setTimeout: (fn, ms) => setTimeout(fn, Math.min(ms, 30)),
    // A Chromium browser has both of these; another browser lacks the first.
    Intl: w.chromium ? {v8BreakIterator: function () {}, Segmenter: function () {}} : {Segmenter: function () {}},
    self,
    caches: w.caches,
    fetch: (request) => w.network(request),
  };
  vm.runInNewContext(source, context);
  const lifecycle = async (type) => {
    const pending = [];
    if (type === 'install') w.installing = handle;
    // An activating worker is the registration's active worker, no longer its waiting one.
    if (type === 'activate') {
      if (w.waiting === handle) w.waiting = null;
      w.active = handle;
    }
    handlers[type]({waitUntil: (p) => pending.push(p)});
    try {
      await Promise.all(pending);
      if (type === 'install') w.waiting = handle;
    } finally {
      if (type === 'install') w.installing = null;
    }
  };
  const handle = {
    version,
    // What a ServiceWorker object reports: the address it was registered under.
    scriptURL: ORIGIN + `pantas_sw.js?v=${version}`,
    handlers,
    install: () => lifecycle('install'),
    activate: () => lifecycle('activate'),
    // What a ServiceWorker object does when another worker writes to it: a message with a reply port.
    postMessage(data, ports) {
      handlers.message({data, ports: [{postMessage: (value) => ports[0].postMessage(value)}], waitUntil() {}});
    },
    // A message from a page. Returns the reply sent on the page's port, or null.
    async message(data) {
      let reply = null;
      const pending = [];
      handlers.message({data, ports: [{postMessage: (value) => (reply = value)}], waitUntil: (p) => pending.push(p)});
      await Promise.all(pending);
      return reply && JSON.parse(JSON.stringify(reply));
    },
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
  return handle;
}

// What the page gets for one file through the controlling worker. 'miss' is a
// file that cannot be served at all, which is not a mix.
async function get(w, path, options) {
  try {
    const response = (await w.controller.fetch(path, options)) ?? (await w.network({url: ORIGIN + path}));
    if (response.status !== 200) return {id: 'miss', status: response.status};
    const text = await response.text();
    return {id: buildOf(text) ?? 'none', text};
  } catch (_) {
    return {id: 'miss'};
  }
}

// The files a boot needs, as the page it is served names them: the page, the two
// scripts it loads, and next to the bootstrap the app, a deferred part, the
// database worker and wasm. Null when the page cannot be had.
async function bootPaths(w) {
  const page = await get(w, '', {navigate: true});
  if (page.id === 'miss') return null;
  const scripts = [...page.text.matchAll(/src="([^"]+)"/g)].map((match) => match[1]);
  const folder = scripts.find((path) => path.endsWith('flutter_bootstrap.js')).replace('flutter_bootstrap.js', '');
  // drift_worker.js keeps its root address in every build (fix list item 1).
  return ['', ...scripts, ...['main.dart.js', 'main.dart.js_1.part.js', 'sqlite3.wasm'].map((name) => folder + name), 'drift_worker.js', 'manifest.json'];
}

// The page loads online: the page, then everything it names.
async function pageLoad(w) {
  const paths = await bootPaths(w);
  for (const path of paths) await get(w, path, {navigate: path === ''});
  return paths;
}

// Goes offline and reads every boot file. Returns the build ids served.
async function offlineSet(w) {
  const before = w.offline;
  w.offline = true;
  const ids = {};
  const paths = await bootPaths(w);
  for (const path of paths ?? ['']) ids[path || 'index'] = (await get(w, path, {navigate: path === ''})).id;
  w.offline = before;
  // The database worker is the same file in every build and carries no build marker ('none').
  const found = new Set(Object.values(ids).filter((id) => id !== 'miss' && id !== 'none'));
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
const skips = (w, version) => w.events.filter((e) => e.event === 'skipWaiting' && (!version || e.version === version));
// The stamped build caches that exist (not today's worker's caches, not the active-build note).
const buildCaches = (w) => [...w.stores.keys()].filter((name) => name.startsWith('pantas-build-')).sort();

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
  const paths = await pageLoad(w);
  deploy(w, 'C');
  // A new build reaches the page only through a new worker that verified its whole set.
  for (const path of paths) {
    const id = (await get(w, path, {navigate: path === ''})).id;
    // The database worker is one file for every build, so it carries no build marker.
    assert.equal(id, path === 'drift_worker.js' ? 'none' : 'B', path);
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
  assert.equal(skips(w).length, 0);
  assert.equal(w.stores.has(cacheOf('B')) && w.stores.get(cacheOf('B')).size > 0, false);
});

test('Dart files fetched after a newer deploy are not stored in the older build cache', async () => {
  const w = world();
  deploy(w, 'B');
  const b = await install(w, 'B');
  await takeOver(w, b);
  const before = JSON.stringify([...w.stores.get(cacheOf('B')).entries()]);
  deploy(w, 'C');
  await get(w, inFolder('B', 'main.dart.js'));
  await get(w, inFolder('B', 'main.dart.js_1.part.js'));
  await get(w, inFolder('C', 'main.dart.js'));
  assert.equal(JSON.stringify([...w.stores.get(cacheOf('B')).entries()]), before, 'the cache did not change');
});

// ---- The build folders: nothing at the root can be mixed ----

test('a stamped build serves every file a page loads from its own folder, none from the root', () => {
  const {served} = build('B');
  const root = Object.keys(served).filter((path) => path && !path.includes('/'));
  assert.deepEqual(root.sort(), ['.last_build_id', 'drift_worker.js', 'favicon.png', 'index.html', 'manifest.json', 'og-image.png', 'pantas_sw.js', 'version.json', 'README.md', 'flutter_service_worker.js'].sort());
  const page = served[''];
  for (const [, path] of page.matchAll(/src="([^"]+)"/g)) assert.ok(path.startsWith(folderOf('B')), path);
});

test('today\'s worker claims no path inside a build folder, so it can neither store nor serve one', async () => {
  const w = world();
  deploy(w, 'A', {prod: true});
  const a = await install(w, 'A', {prod: true});
  await takeOver(w, a);
  deploy(w, 'B');
  const stored = JSON.stringify([...w.stores].map(([name, store]) => [name, [...store.keys()]]));
  const names = ['pantas_pwa.js', 'flutter_bootstrap.js', 'main.dart.js', 'main.dart.js_1.part.js', 'sqlite3.wasm',
    'assets/AssetManifest.bin', 'assets/fonts/MaterialIcons-Regular.otf', 'canvaskit/canvaskit.wasm', 'icons/Icon-192.png'];
  for (const name of names.filter((n) => !n.startsWith('icons/'))) {
    assert.equal(await w.controller.fetch(inFolder('B', name)), null, `today's worker answers b/.../${name}`);
    await w.network({url: ORIGIN + inFolder('B', name)});
  }
  assert.equal(JSON.stringify([...w.stores].map(([name, store]) => [name, [...store.keys()]])), stored, 'nothing was stored');
});

// ---- Rollout from the worker already on phones (prod) to the new worker ----

test('rollout: prod A, B deployed: the page B names loads all of B, never one file of A', async () => {
  const w = await deployedBUnderA({prod: true});
  // Today's worker (A) served the new page from the network and stored it, but every
  // file that page names is in B's folder, which A does not touch.
  const online = await pageLoad(w);
  // drift_worker.js is the one shared root file: A's copy and B's are the same bytes.
  for (const path of online.filter((p) => p)) assert.ok(path.startsWith(folderOf('B')) || ['manifest.json', 'drift_worker.js'].includes(path), path);
  // Offline, A still serves the page it stored. B's files were never stored, so the
  // load stops: no boot, and nothing of A is mixed in.
  const r = await offlineSet(w);
  assert.equal(r.mixed, false, JSON.stringify(r.ids));
  assert.ok(r.misses.length > 0, 'no boot rather than a mixed boot');
});

test('rollout: prod A, B deployed, then offline before the page reloaded: still all A', async () => {
  const w = world();
  deploy(w, 'A', {prod: true});
  await takeOver(w, await install(w, 'A', {prod: true}));
  await pageLoad(w);
  deploy(w, 'B');
  const r = await offlineSet(w);
  assert.deepEqual(r.builds, ['A']);
  assert.deepEqual(r.misses, []);
});

test('rollout: B installs next to prod A, takes over at once, and the app boots offline right away', async () => {
  const w = await deployedBUnderA({prod: true});
  const b = await install(w, 'B');
  assert.equal(skips(w, 'B').length, 1, 'no other stamped build is installed, so B takes over at once');
  await takeOver(w, b);
  // Nothing is deleted at activation: tabs still on A keep the cache they need (fix list item 3).
  assert.deepEqual(buildCaches(w), [cacheOf('B')]);
  assert.ok(w.stores.has('pantas-shell-A'), 'A\'s cache is kept for tabs still on A');
  let r = await offlineSet(w);
  assert.equal(r.mixed, false, JSON.stringify(r.ids));
  assert.deepEqual(r.builds, ['B']);
  assert.deepEqual(r.misses, [], 'offline boot works at once after activation');
  await pageLoad(w);
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
  assert.equal(skips(w, 'B').length, 0);
  const cached = w.stores.get(cacheOf('B'));
  assert.ok(!cached || cached.size === 0, 'a failed install stores nothing');
});

// ---- The new worker's own rules ----

for (const name of ['main.dart.js', 'sqlite3.wasm', 'assets/FontManifest.json']) {
  test(`install fails and the old worker stays when ${name} does not match its hash`, async () => {
    const w = world();
    deploy(w, 'A');
    const a = await install(w, 'A');
    await takeOver(w, a);
    deploy(w, 'B');
    const path = inFolder('B', name);
    w.tamper[path] = build('B').served[path] + ' tampered';
    const events = w.events.length;
    const b = worker(w, workerOf(build('B')), 'B');
    await assert.rejects(b.install(), new RegExp(name.replace('.', '\\.')));
    assert.equal(w.events.length, events, 'no skipWaiting');
    assert.ok(w.stores.has(cacheOf('A')), 'the old cache stays');
    assert.equal(w.stores.has(cacheOf('B')) && w.stores.get(cacheOf('B')).size > 0, false);
    delete w.tamper[path];
    assert.deepEqual((await offlineSet(w)).builds, ['A']);
  });
}

test('install fails when the page does not match its hash', async () => {
  const w = world();
  deploy(w, 'B');
  w.tamper[''] = build('B').served[''] + ' tampered';
  w.tamper['index.html'] = w.tamper[''];
  await assert.rejects(worker(w, workerOf(build('B')), 'B').install(), /hash mismatch/);
});

test('install refuses a response the server marked private or no-store', async () => {
  for (const control of ['private', 'no-store', 'public, no-store']) {
    const w = world();
    deploy(w, 'B');
    w.extraHeaders[inFolder('B', 'main.dart.js')] = {'Cache-Control': control};
    await assert.rejects(worker(w, workerOf(build('B')), 'B').install(), /not cacheable/, control);
    assert.equal(skips(w).length, 0);
    assert.ok(!w.stores.has(cacheOf('B')) || w.stores.get(cacheOf('B')).size === 0);
  }
});

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

test('a cache that holds another list under its name is fetched again, not trusted', async () => {
  const w = world();
  deploy(w, 'B');
  const cache = await w.caches.open(cacheOf('B'));
  await cache.put(ORIGIN + 'pantas-build-complete', new Response('0123456789ab'));
  await cache.put(ORIGIN + inFolder('B', 'main.dart.js'), new Response('stale bytes'));
  const b = worker(w, workerOf(build('B')), 'B');
  await b.install();
  await takeOver(w, b);
  assert.equal((await get(w, inFolder('B', 'main.dart.js'))).id, 'B');
});

test('a worker with no other build installed takes over at once, after the whole set is stored', async () => {
  const w = world();
  deploy(w, 'A');
  const a = await install(w, 'A');
  const skip = skips(w, 'A').at(-1);
  assert.ok(skip.stores.get(cacheOf('A')) >= Object.keys(constantOf(build('A').served).files).length + 1 - 2,
    'the whole set and its marker were stored first');
  await a.activate();
  assert.deepEqual(w.events.filter((e) => e.version === 'A').map((e) => e.event), ['skipWaiting', 'claim']);
});

// ---- Waiting worker (Revision 1, item 2) ----

async function waitingC() {
  const w = world();
  deploy(w, 'B');
  const b = await install(w, 'B');
  await takeOver(w, b);
  await pageLoad(w);
  deploy(w, 'C');
  const c = await install(w, 'C');
  return {w, b, c};
}

test('a worker installed next to another stamped build waits: no skipWaiting, no deleted cache', async () => {
  const {w, c} = await waitingC();
  assert.equal(skips(w, 'C').length, 0, 'C does not skip waiting');
  assert.ok(w.stores.has(cacheOf('B')) && w.stores.has(cacheOf('C')), 'both caches exist');
  assert.deepEqual((await offlineSet(w)).builds, ['B'], 'the open window keeps booting B');
  assert.ok(c);
});

test('a held-open B window: C installed and waiting, a deferred part loaded offline is B\'s, and C never takes over by itself', async () => {
  const {w} = await waitingC();
  w.offline = true;
  const part = await get(w, inFolder('B', 'main.dart.js_1.part.js'));
  assert.equal(part.id, 'B');
  assert.equal((await get(w, '', {navigate: true})).id, 'B');
  assert.equal(skips(w, 'C').length, 0);
});

// Takeover case 2 of 2 (case 1 is the move off today's worker): the Update Required button.
// Nothing else asks a waiting worker to take over, and it does so whatever other windows are
// open: the screen it answers cannot be dismissed, and a reload alone no longer updates.
test('Update Required: the waiting worker takes over when asked, with another window open, and deletes nothing', async () => {
  const {w, c} = await waitingC();
  w.windows = 2;
  assert.deepEqual(await c.message({type: 'pantas-take-over'}), {ok: true});
  assert.equal(skips(w, 'C').length, 1);
  await takeOver(w, c);
  assert.deepEqual(buildCaches(w), [cacheOf('B'), cacheOf('C')].sort(), 'nothing is deleted when C activates: a B window may still be open');
  const r = await offlineSet(w);
  assert.deepEqual(r.builds, ['C']);
  assert.deepEqual(r.misses, []);
  w.offline = true;
  assert.equal((await get(w, part('B', 2))).id, 'B', 'the window still on B keeps its files');
});

// Item 4c: the taking-over worker marks its own cache and sweeps nothing; the next natural
// activation (no Pantas tab open) sweeps.
test('Update Required takeover: the taking-over worker deletes nothing, and the next natural activation sweeps', async () => {
  const {w, c} = await waitingC();
  await c.message({type: 'pantas-take-over'});
  const before = JSON.stringify([...w.stores].map(([name, store]) => [name, [...store.keys()].sort()]));
  await takeOver(w, c);
  assert.equal(JSON.stringify([...w.stores].map(([name, store]) => [name, [...store.keys()].sort()])), before, 'C activated and deleted nothing');
  assert.ok(w.stores.get(cacheOf('C')).has(ORIGIN + 'pantas-build-takeover'), 'its own cache says it took over');
  // Later D arrives and waits; every Pantas tab closes; D activates by itself.
  deploy(w, 'D');
  const d = await install(w, 'D');
  assert.equal(skips(w, 'D').length, 0, 'D waits');
  assert.deepEqual(buildCaches(w), [cacheOf('B'), cacheOf('C'), cacheOf('D')].sort());
  await takeOver(w, d);
  assert.deepEqual(buildCaches(w), [cacheOf('D')], 'only the new build\'s cache remains');
  assert.ok(!w.stores.get(cacheOf('D')).has(ORIGIN + 'pantas-build-takeover'));
  assert.deepEqual((await offlineSet(w)).builds, ['D']);
});

// Item 4g: a reload does nothing to a waiting worker. Only a natural activation or the Update
// Required message moves it.
test('a waiting worker stays waiting: nothing but the browser or the Update Required message activates it', async () => {
  const {w, c} = await waitingC();
  for (const path of ['', 'index.html', 'quiz/start']) await get(w, path, {navigate: true});
  await pageLoad(w);
  assert.equal(skips(w, 'C').length, 0);
  assert.equal(w.waiting, c);
  assert.deepEqual((await offlineSet(w)).builds, ['B'], 'the page keeps its build');
  for (const type of ['pantas-build-id', 'pantas-hello', 'pantas-update']) await c.message({type});
  assert.equal(skips(w, 'C').length, 0);
});

test('the worker reports its stamped build id to the page', async () => {
  const {c} = await waitingC();
  assert.deepEqual(await c.message({type: 'pantas-build-id'}), {id: constantOf(build('C').served).id});
});

test('the worker\'s own messages are ignored when it is unstamped', async () => {
  const w = world();
  const dev = worker(w, readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8'), 'dev');
  assert.equal(await dev.message({type: 'pantas-take-over'}), null);
  assert.equal(skips(w).length, 0);
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
  assert.deepEqual((await offlineSet(w)).builds, ['B'], 'C installed and waiting, B still controls');
  assert.deepEqual(await c.message({type: 'pantas-take-over'}), {ok: true});
  await takeOver(w, c);
  await pageLoad(w);
  assert.deepEqual((await offlineSet(w)).builds, ['C']);
  // Rollback: the server serves B again while C controls. Edge skew, both ways.
  deploy(w, 'B');
  await pageLoad(w);
  const midRollback = await offlineSet(w);
  assert.deepEqual(midRollback.builds, ['C'], JSON.stringify(midRollback.ids));
  // B's worker installs again from the rolled-back server, waits, and takes over when asked.
  const b2 = await install(w, 'B');
  assert.deepEqual((await offlineSet(w)).builds, ['C']);
  assert.deepEqual(await b2.message({type: 'pantas-take-over'}), {ok: true});
  await takeOver(w, b2);
  const after = await offlineSet(w);
  assert.deepEqual(after.builds, ['B'], JSON.stringify(after.ids));
  assert.deepEqual(after.misses, []);
  // The install of the rolled-back B pruned everything but B (the new build) and C (in charge until now).
  assert.deepEqual(buildCaches(w), [cacheOf('B'), cacheOf('C')].sort());
});

test('a response outside the set is never stored', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  const before = JSON.stringify([...w.stores].map(([k, v]) => [k, [...v.keys()]]));
  for (const path of ['og-image.png', 'README.md', inFolder('B', 'assets/NOTICES'), 'version.json', 'flutter_service_worker.js', 'nothing/here.js']) {
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

test('a set file missing from the cache is checked against its hash', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  const path = inFolder('B', 'sqlite3.wasm');
  w.stores.get(cacheOf('B')).delete(ORIGIN + path);
  assert.equal((await get(w, path)).id, 'B');
  // The server moved to another build: the immutable address no longer holds B's bytes, so the answer is refused.
  w.stores.get(cacheOf('B')).delete(ORIGIN + path);
  deploy(w, 'C');
  w.tamper[path] = build('C').served[inFolder('C', 'sqlite3.wasm')];
  assert.equal((await get(w, path)).id, 'miss');
});

test('the worker\'s own 503 carries the edge security headers', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  const path = inFolder('B', 'sqlite3.wasm');
  w.stores.get(cacheOf('B')).delete(ORIGIN + path);
  w.tamper[path] = 'something else';
  const failure = await w.controller.fetch(path);
  assert.equal(failure.status, 503);
  assert.equal(failure.headers.get('cache-control'), 'no-store');
  assert.equal(failure.headers.get('x-content-type-options'), 'nosniff');
  assert.equal(failure.headers.get('referrer-policy'), edge.expected('/x')['referrer-policy']);
  assert.equal(failure.headers.get('permissions-policy'), edge.expected('/x')['permissions-policy']);
  assert.equal(failure.headers.get('content-security-policy'), edge.expected('/x')['content-security-policy']);
});

test('credentials and ranges pass through untouched', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  const path = inFolder('B', 'main.dart.js');
  assert.notEqual(await w.controller.fetch(path), null, 'a plain GET is served');
  assert.equal(await w.controller.fetch(path, {headers: {Authorization: 'Bearer x'}}), null);
  assert.equal(await w.controller.fetch(path, {headers: {Range: 'bytes=0-9'}}), null);
  assert.equal(await w.controller.fetch('__/auth/handler', {navigate: true}), null);
  assert.equal(await w.controller.fetch('wrapped/abc', {navigate: true}), null);
});

test('the shipped worker file carries the unstamped marker, so dev keeps today\'s behavior', () => {
  const source = readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8');
  assert.match(source, /\/\*pantas-build\*\/ null \/\*end-pantas-build\*\//);
});

// ---- The renderer: two variants listed, one installed (Revision 1, item 4) ----

function rendererBuild(id) {
  const files = {};
  for (const name of ['canvaskit.js', 'canvaskit.wasm', 'chromium/canvaskit.js', 'chromium/canvaskit.wasm']) {
    files[`canvaskit/${name}`] = `// @build:${id}@ ${name}`;
  }
  return files;
}

// Audit 2, High 5: a service worker cannot see every feature Flutter checks to choose a
// renderer (ImageDecoder is not exposed to it), so it could skip the variant Flutter then
// asks for, and an offline start would fail. The bootstrap now pins full CanvasKit in every
// browser (web/flutter_bootstrap.js, tested in flutter_bootstrap_pin.test.mjs), so the worker
// installs that one variant everywhere and an update downloads half the renderer bytes.
test('the full renderer is installed in every browser and the chromium variant never is', async () => {
  for (const chromium of [true, false]) {
    const w = world();
    w.chromium = chromium;
    build('R', {files: rendererBuild('R'), localCanvasKit: true});
    deploy(w, 'R');
    await takeOver(w, await install(w, 'R'));
    const cached = [...w.stores.get(cacheOf('R')).keys()].map((url) => url.replace(ORIGIN, ''));
    for (const name of ['canvaskit.js', 'canvaskit.wasm']) {
      assert.ok(cached.includes(`${folderOf('R')}canvaskit/${name}`), `${name} (chromium browser: ${chromium})`);
    }
    for (const name of ['chromium/canvaskit.js', 'chromium/canvaskit.wasm']) {
      assert.ok(!cached.includes(`${folderOf('R')}canvaskit/${name}`), `${name} is not stored (chromium browser: ${chromium})`);
    }
    w.offline = true;
    assert.equal((await get(w, inFolder('R', 'canvaskit/canvaskit.wasm'))).id, 'R', `offline (chromium browser: ${chromium})`);
  }
});

// E-210: the Firebase SDK files are the same bytes in every build and their address carries the
// SDK version, so an update may take them from the HTTP cache (the hash still guards them);
// the other root files are read past it. Without this every update downloads 1.2 MB again.
test('an install reads the SDK files through the HTTP cache and the other root files past it', async () => {
  const w = world();
  build('R', {});
  deploy(w, 'R');
  await install(w, 'R');
  const mode = (path) => w.cacheModes[ORIGIN + path];
  assert.equal(mode('firebase_sdk/12.17.0/firebase-app.js'), 'default');
  assert.equal(mode('firebase_sdk/12.17.0/firebase-firestore-pipelines.js'), 'default');
  assert.equal(mode('drift_worker.js'), 'reload');
  assert.equal(mode('manifest.json'), 'reload');
});

test('the build constant no longer carries a renderer variant list', () => {
  const b = build('R', {files: rendererBuild('R'), localCanvasKit: true});
  assert.equal(constantOf(b.served).variants, undefined);
});

// ---- Fix list items 2, 3, 4 and 6 (service worker option A, Nov 26) ----

const part = (id, n) => inFolder(id, `main.dart.js_${n}.part.js`);

test('item 3: activation deletes nothing, so a window still on B keeps every file of B after C takes over', async () => {
  const {w, c} = await waitingC();
  w.windows = 1;
  await c.message({type: 'pantas-take-over'});
  await takeOver(w, c);
  assert.deepEqual(buildCaches(w), [cacheOf('B'), cacheOf('C')].sort());
  w.offline = true;
  // B's window asks for a deferred part it never loaded: C is in charge, B's cache answers.
  assert.equal((await get(w, part('B', 2))).id, 'B');
});

test('item 2: any b/<id>/ path is served from whichever build cache holds it', async () => {
  const {w, c} = await waitingC();
  await c.message({type: 'pantas-take-over'});
  await takeOver(w, c);
  w.offline = true;
  for (const name of ['main.dart.js', 'main.dart.js_1.part.js', 'main.dart.js_2.part.js', 'sqlite3.wasm', 'assets/FontManifest.json']) {
    assert.equal((await get(w, inFolder('B', name))).id, 'B', `B ${name}`);
    assert.equal((await get(w, inFolder('C', name))).id, 'C', `C ${name}`);
  }
  // A build nobody holds is not invented: the network answers, and offline that is a miss.
  assert.equal((await get(w, 'b/other-123456789abc/main.dart.js')).id, 'miss');
});

// Item 4a: an install deletes nothing, however many arrive while tabs stay open.
test('item 4a: two tabs open on B, C installs and waits: no cache is deleted, and both tabs keep working offline', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  w.windows = 2;
  await pageLoad(w);
  deploy(w, 'C');
  const before = w.stores.get(cacheOf('B')).size;
  const deletes = [];
  const remove = w.caches.delete;
  w.caches.delete = async (name) => {
    deletes.push(name);
    return remove(name);
  };
  const c = await install(w, 'C');
  assert.deepEqual(deletes, [], 'nothing was deleted');
  assert.equal(skips(w, 'C').length, 0);
  assert.equal(w.waiting, c);
  assert.equal(w.stores.get(cacheOf('B')).size, before);
  assert.deepEqual(buildCaches(w), [cacheOf('B'), cacheOf('C')].sort());
  const offline = await offlineSet(w);
  assert.deepEqual(offline.builds, ['B']);
  assert.deepEqual(offline.misses, []);
  // C, D and E install one after the other, none takes over: every cache stays.
  for (const id of ['D', 'E']) {
    deploy(w, id);
    await install(w, id);
  }
  assert.deepEqual(buildCaches(w), ['B', 'C', 'D', 'E'].map(cacheOf).sort());
  assert.deepEqual((await offlineSet(w)).builds, ['B']);
  assert.deepEqual(deletes, []);
});

// Item 4b: with no Pantas tab open the browser activates the waiting worker by itself, and
// that activation sweeps: today's worker's caches go too.
test('item 4b: all tabs closed, C activates naturally: only C\'s cache remains', async () => {
  const {w, c} = await waitingC();
  assert.deepEqual(buildCaches(w), [cacheOf('B'), cacheOf('C')].sort());
  await takeOver(w, c);
  assert.deepEqual(buildCaches(w), [cacheOf('C')].sort());
  assert.deepEqual([...w.stores.keys()], [cacheOf('C')], 'nothing else of ours is left');
  assert.deepEqual((await offlineSet(w)).builds, ['C']);
  assert.deepEqual((await offlineSet(w)).misses, []);
});

test('item 4b: the sweep takes today\'s worker\'s cache and the notes cache of the earlier design with it', async () => {
  const w = await deployedBUnderA({prod: true});
  await takeOver(w, await install(w, 'B')); // leaving today's worker: B takes over, A's cache stays
  assert.ok(w.stores.has('pantas-shell-A'));
  (await w.caches.open('pantas-meta')).put(ORIGIN + 'pantas-active-build', new Response('x'));
  (await w.caches.open('something-else')).put(ORIGIN + 'x', new Response('x'));
  deploy(w, 'C');
  const c = await install(w, 'C');
  assert.ok(w.stores.has('pantas-shell-A'), 'an install deletes nothing');
  await takeOver(w, c);
  assert.deepEqual([...w.stores.keys()].sort(), [cacheOf('C'), 'something-else'].sort(), 'only caches of ours go');
});

// Item 4d, audit 4's Blocker: B's first activation had not run when C installed, and C's install
// pruned B. An install deletes nothing now, so B's cache is there when B activates.
test('item 4d: B\'s first activation paused, C installs: B\'s cache survives, and B\'s activation sweeps nothing', async () => {
  const w = world();
  deploy(w, 'B');
  const b = await install(w, 'B'); // takes over (first install), activation not run yet
  assert.equal(skips(w, 'B').length, 1);
  deploy(w, 'C');
  const c = await install(w, 'C');
  assert.equal(skips(w, 'C').length, 0, 'C waits');
  assert.ok(w.stores.has(cacheOf('B')), 'B\'s cache survived C\'s install');
  await b.activate();
  w.controller = b;
  assert.ok(w.stores.has(cacheOf('B')) && w.stores.has(cacheOf('C')), 'B\'s activation deleted nothing');
  assert.equal((await offlineSet(w)).misses.length, 0);
  assert.deepEqual((await offlineSet(w)).builds, ['B']);
  assert.ok(c);
});

// Lead ruling on the rollout flake: the page registers the worker under an address that carries its
// build, so a page of the build in charge registers a duplicate of it. The duplicate is refused at
// install, so no waiting worker is left to replace the active one at the next reload.
test('a duplicate of the build in charge, registered under another ?v=, is refused: no waiting worker, nothing deleted', async () => {
  const w = world();
  deploy(w, 'B');
  const b = await install(w, 'B');
  await takeOver(w, b);
  await pageLoad(w);
  const before = JSON.stringify([...w.stores].map(([name, store]) => [name, [...store.keys()].sort()]));
  const duplicate = worker(w, workerOf(build('B')), 'another-address');
  await assert.rejects(duplicate.install(), /already installed/);
  assert.equal(w.waiting, null, 'no duplicate reaches waiting');
  assert.equal(w.active, b, 'the active worker is unchanged');
  assert.equal(skips(w, 'another-address').length, 0);
  assert.equal(JSON.stringify([...w.stores].map(([name, store]) => [name, [...store.keys()].sort()])), before, 'nothing was stored or deleted');
  // The page in flight still loads its files from the active worker.
  assert.equal((await get(w, inFolder('B', 'main.dart.js'))).id, 'B');
  assert.deepEqual((await offlineSet(w)).misses, []);
});

test('a duplicate of the build that waits is refused too, and a different build still installs and waits', async () => {
  const {w, c} = await waitingC();
  const duplicate = worker(w, workerOf(build('C')), 'other-address');
  await assert.rejects(duplicate.install(), /already installed/);
  assert.equal(w.waiting, c);
  deploy(w, 'B'); // a rollback to B while B is in charge is a duplicate; D is a real update
  deploy(w, 'D');
  const d = await install(w, 'D');
  assert.equal(w.waiting, d, 'a different build installs and waits');
  assert.equal(skips(w, 'D').length, 0);
  // An active worker that does not answer (today's worker) is not the same build.
  const legacy = await deployedBUnderA({prod: true});
  const next = await install(legacy, 'B');
  assert.equal(legacy.waiting, next);
});

// Item 4e: the lock. A sweep that is deleting holds it, and an install that arrives waits for it.
test('item 4e: a sweep and an install at the same time: the install\'s cache is never deleted', async () => {
  const {w, c} = await waitingC();
  deploy(w, 'D');
  // Hold the sweep in the middle of its deletes.
  const remove = w.caches.delete;
  let reached;
  let release;
  const hit = new Promise((resolve) => (reached = resolve));
  const gate = new Promise((resolve) => (release = resolve));
  w.caches.delete = async (name) => {
    reached();
    await gate;
    return remove(name);
  };
  w.waiting = null; // C is activating by itself: nothing else installs or waits yet
  const sweeping = c.activate();
  await hit;
  assert.equal(w.locks.isHeld(), true, 'the sweep holds the lock while it deletes');
  // A new worker D starts to install now. It reads the files, then has to wait for the lock to write.
  const d = worker(w, workerOf(build('D')), 'D');
  const installing = d.install();
  await new Promise((done) => setImmediate(done));
  assert.ok(!w.stores.has(cacheOf('D')) || w.stores.get(cacheOf('D')).size === 0, 'D has not written while the sweep holds the lock');
  release();
  await sweeping;
  await installing;
  assert.ok(w.stores.has(cacheOf('D')), 'D\'s cache exists');
  assert.ok(w.stores.get(cacheOf('D')).has(ORIGIN + 'pantas-build-complete'), 'and it is whole');
  assert.equal(w.locks.isHeld(), false);
  assert.equal(w.waiting, d);
});

test('item 4e: a sweep that finds a worker waiting or installing deletes nothing', async () => {
  const {w, c} = await waitingC();
  deploy(w, 'D');
  const d = await install(w, 'D'); // D waits behind C
  assert.equal(w.waiting, d);
  w.waiting = null;
  w.installing = d; // seen as installing
  await takeOver(w, c);
  assert.deepEqual(buildCaches(w), [cacheOf('B'), cacheOf('C'), cacheOf('D')].sort(), 'installing: nothing deleted');
  w.installing = null;
  w.waiting = d; // seen as waiting
  await c.activate();
  assert.deepEqual(buildCaches(w), [cacheOf('B'), cacheOf('C'), cacheOf('D')].sort(), 'waiting: nothing deleted');
  w.waiting = null;
  await c.activate();
  assert.deepEqual(buildCaches(w), [cacheOf('C')], 'nothing installing or waiting: swept');
});

// Item 4f: without Web Locks there is no sweep, and the install completes.
test('item 4f: no navigator.locks: no sweep, and the install still completes', async () => {
  const w = world();
  w.locks = null;
  deploy(w, 'B');
  const b = await install(w, 'B');
  await takeOver(w, b);
  await pageLoad(w);
  deploy(w, 'C');
  const c = await install(w, 'C');
  assert.ok(w.stores.get(cacheOf('C')).has(ORIGIN + 'pantas-build-complete'), 'C\'s install completed and stored its whole set');
  await takeOver(w, c); // natural activation without the API
  assert.deepEqual(buildCaches(w), [cacheOf('B'), cacheOf('C')].sort(), 'no sweep');
  assert.deepEqual((await offlineSet(w)).builds, ['C']);
});

// Rev 2 audit 1, Blocker: with Web Locks, an install never writes or reuses a cache without the lock.
test('item 4f: a lock nobody releases: the sweep gives up, and the install fails (the browser tries again later)', async () => {
  const {w, c} = await waitingC();
  w.locks.request('pantas-cache-lock', {}, () => new Promise(() => {})); // another holder that never lets go
  await takeOver(w, c); // the sweep waits for the lock, times out and deletes nothing
  assert.deepEqual(buildCaches(w), [cacheOf('B'), cacheOf('C')].sort());
  deploy(w, 'D');
  await assert.rejects(worker(w, workerOf(build('D')), 'D').install(), /lock/);
  assert.equal(w.stores.has(cacheOf('D')), false, 'nothing was written without the lock');
  assert.equal(w.waiting, null);
  assert.equal(skips(w, 'D').length, 0);
});

// Codex rev 2 audit 1 (its Chromium harness, ported): C activates by itself and holds the lock
// while it deletes B; a rollback to B installs, and its lock wait times out. B used to reuse the
// B cache the sweep was deleting, then activate with no cache.
test('rev2 audit 1 Blocker: a rollback install whose lock wait times out fails, and no worker is left without its cache', async () => {
  const {w, c} = await waitingC();
  const remove = w.caches.delete;
  let reached;
  let release;
  const hit = new Promise((resolve) => (reached = resolve));
  const gate = new Promise((resolve) => (release = resolve));
  w.caches.delete = async (name) => {
    reached();
    await gate;
    return remove(name);
  };
  w.waiting = null;
  const sweeping = c.activate(); // C holds the lock, deleting B's cache
  await hit;
  deploy(w, 'B'); // the rollback
  const rollback = worker(w, workerOf(build('B')), 'B-rollback');
  await assert.rejects(rollback.install(), /lock/);
  release();
  await sweeping;
  assert.equal(w.waiting, null, 'no rollback worker waits');
  assert.equal(skips(w, 'B-rollback').length, 0);
  assert.deepEqual(buildCaches(w), [cacheOf('C')], 'C swept B, and no B worker is left to find it gone');
  // The browser tries again at its next update check: now the lock is free and B installs whole.
  const again = await install(w, 'B');
  assert.equal(w.waiting, again);
  assert.ok(w.stores.get(cacheOf('B')).has(ORIGIN + 'pantas-build-complete'));
});

test('rev2 audit 1: the sweep reads the registration again before each delete, and keeps the cache of a build installing or waiting', async () => {
  const {w, c} = await waitingC();
  w.waiting = null;
  const keys = w.caches.keys;
  let reached;
  let release;
  const hit = new Promise((resolve) => (reached = resolve));
  const gate = new Promise((resolve) => (release = resolve));
  w.caches.keys = async () => {
    const names = await keys();
    reached();
    await gate;
    return names;
  };
  const sweeping = c.activate();
  await hit;
  // While the sweep holds the names, a worker of build B starts to install (its install waits).
  deploy(w, 'B');
  const b = worker(w, workerOf(build('B')), 'B-rollback');
  w.installing = b;
  release();
  await sweeping;
  w.caches.keys = keys;
  assert.ok(w.stores.has(cacheOf('B')), 'the cache of the build that is installing was kept');
  // A worker that does not answer who it is stops the sweep altogether.
  w.installing = {postMessage() {}};
  await c.activate();
  assert.ok(w.stores.has(cacheOf('B')));
  w.installing = null;
  await c.activate();
  assert.deepEqual(buildCaches(w), [cacheOf('C')]);
});

test('item 4f: an install without the lock whose cache a sweep deleted halfway puts back what is missing', async () => {
  const w = world();
  w.locks = null;
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  deploy(w, 'C');
  // Another worker's sweep deletes C's cache after C has written a few files.
  const open = w.caches.open;
  let puts = 0;
  w.caches.open = async (name) => {
    const cache = await open(name);
    if (name !== cacheOf('C')) return cache;
    return {
      ...cache,
      put: async (request, response) => {
        await cache.put(request, response);
        if (++puts === 3) w.stores.delete(cacheOf('C'));
      },
    };
  };
  await install(w, 'C');
  const cache = w.stores.get(cacheOf('C'));
  const files = Object.keys(constantOf(build('C').served).files);
  for (const path of files) assert.ok(cache.has(ORIGIN + path), `${path} is stored`);
  assert.ok(cache.has(ORIGIN + 'pantas-build-complete'));
});

test('item 3: an activation cannot delete a successor\'s cache that is being filled', async () => {
  const {w, c} = await waitingC();
  const partial = await w.caches.open(`pantas-build-D-${'0'.repeat(12)}`);
  await partial.put(ORIGIN + 'b/D/main.dart.js', new Response('half of D'));
  await c.message({type: 'pantas-take-over'});
  await takeOver(w, c);
  assert.ok(w.stores.has(`pantas-build-D-${'0'.repeat(12)}`), 'D\'s cache survived C\'s activation');
});

test('item 4: a tab still on today\'s build gets its root deferred parts from today\'s cache after the new worker took over', async () => {
  const w = await deployedBUnderA({prod: true});
  const a = await w.controller.fetch('main.dart.js_1.part.js');
  assert.ok(a, 'today\'s worker had stored the part');
  await takeOver(w, await install(w, 'B'));
  w.offline = true;
  const answer = await get(w, 'main.dart.js_1.part.js');
  assert.equal(answer.id, 'A', 'the part is A\'s, from A\'s cache');
  // The same worker never stores a root file in B's cache.
  assert.ok(![...w.stores.get(cacheOf('B')).keys()].some((url) => url.endsWith('main.dart.js_1.part.js') && !url.includes('/b/')));
});

test('item 4: a root part today\'s cache does not hold is left to the network', async () => {
  const w = await deployedBUnderA({prod: true});
  await takeOver(w, await install(w, 'B'));
  w.offline = true;
  assert.equal((await get(w, 'main.dart.js_9.part.js')).id, 'miss');
});

test('item 6: a file that is not in the cache and cannot be fetched gets the worker\'s secured 503, not a thrown error', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  const path = inFolder('B', 'sqlite3.wasm');
  w.stores.get(cacheOf('B')).delete(ORIGIN + path);
  w.offline = true;
  const failure = await w.controller.fetch(path);
  assert.equal(failure.status, 503);
  assert.equal(failure.headers.get('cache-control'), 'no-store');
  assert.equal(failure.headers.get('x-content-type-options'), 'nosniff');
  assert.equal(failure.headers.get('content-security-policy'), edge.expected('/x')['content-security-policy']);
  // The page too: no stored page and no network.
  w.stores.get(cacheOf('B')).delete(ORIGIN);
  assert.equal((await w.controller.fetch('', {navigate: true})).status, 503);
  // And another build's file nobody holds.
  assert.equal((await w.controller.fetch('b/other-123456789abc/main.dart.js')).status, 503);
});

test('item 6: a verified miss is stored, so the next offline request is served', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  const path = inFolder('B', 'sqlite3.wasm');
  const store = w.stores.get(cacheOf('B'));
  store.delete(ORIGIN + path);
  assert.equal((await get(w, path)).id, 'B');
  assert.ok(store.has(ORIGIN + path), 'stored after its hash matched');
  w.offline = true;
  assert.equal((await get(w, path)).id, 'B');
  // Bytes that do not match the list are never stored.
  w.offline = false;
  store.delete(ORIGIN + path);
  w.tamper[path] = 'something else';
  assert.equal((await get(w, path)).id, 'miss');
  assert.equal(store.has(ORIGIN + path), false);
});

// ---- Headers ----

test('a page and files served from the cache carry the edge security headers of the network response', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  for (const [path, navigate] of [['', true], ['index.html', false], [inFolder('B', 'main.dart.js'), false], [inFolder('B', 'sqlite3.wasm'), false]]) {
    const network = await w.network({url: ORIGIN + path});
    const cached = await w.controller.fetch(path, {navigate});
    for (const name of ['content-security-policy', 'content-security-policy-report-only', 'x-content-type-options',
      'referrer-policy', 'permissions-policy', 'strict-transport-security', 'content-type']) {
      assert.equal(cached.headers.get(name), network.headers.get(name), `${path || 'page'} ${name}`);
    }
  }
  const page = await w.controller.fetch('', {navigate: true});
  assert.match(page.headers.get('content-security-policy'), /frame-ancestors 'self'/);
  assert.equal(page.headers.get('x-content-type-options'), 'nosniff');
});

// ---- Audit 3, items 2 and 3 (E-210): what a worker may delete ----

// Holds one request of an install open, so a test can run another worker's takeover in the middle.
function holdRequest(w, path) {
  const network = w.network;
  let release;
  let reached;
  const gate = new Promise((resolve) => (release = resolve));
  const hit = new Promise((resolve) => (reached = resolve));
  w.network = async (request) => {
    if (keyOf(request) === ORIGIN + path) {
      reached();
      await gate;
    }
    return network(request);
  };
  return {hit, release};
}

test('audit 3 item 2: C waiting, D installing, C takes over: C keeps its cache and navigation works online and offline', async () => {
  const {w, c} = await waitingC();
  deploy(w, 'D'); // the server now serves D
  const hold = holdRequest(w, inFolder('D', 'sqlite3.wasm'));
  const d = worker(w, workerOf(build('D')), 'D');
  const installing = d.install();
  await hold.hit;
  // C's page asks C to take over while D is still installing and holds the lock: C cannot write its
  // mark under the lock in time, so it does not take over (rev2 audit 1 Medium 3). The page asks again.
  assert.deepEqual(await c.message({type: 'pantas-take-over'}), {ok: false});
  hold.release();
  await installing; // D's install ends
  assert.deepEqual(await c.message({type: 'pantas-take-over'}), {ok: true}); // C accepts; its activate event has not run yet
  await takeOver(w, c); // C's activate event runs
  assert.ok(w.stores.has(cacheOf('C')), 'D\'s install deleted the cache of the worker taking over');
  const online = await get(w, '', {navigate: true});
  assert.equal(online.id, 'C', 'online, the page is C\'s even though the server serves D');
  assert.deepEqual((await offlineSet(w)).builds, ['C']);
  assert.deepEqual((await offlineSet(w)).misses, []);
});

test('audit 3 item 2: an install never deletes the cache of the worker that is waiting', async () => {
  const {w} = await waitingC();
  deploy(w, 'D');
  await install(w, 'D');
  assert.ok(w.stores.has(cacheOf('C')), 'C is the registration\'s waiting worker while D finishes installing');
  assert.ok(w.stores.has(cacheOf('B')) && w.stores.has(cacheOf('D')));
});

test('audit 3 item 2: an install never deletes the cache of a build another install is still filling', async () => {
  const {w} = await waitingC();
  deploy(w, 'D');
  // Hold D's write of one file: its cache is half filled while a newer install runs.
  const open = w.caches.open;
  let reached;
  let release;
  const hit = new Promise((resolve) => (reached = resolve));
  const gate = new Promise((resolve) => (release = resolve));
  w.caches.open = async (name) => {
    const cache = await open(name);
    if (name !== cacheOf('D')) return cache;
    return {
      ...cache,
      put: async (request, response) => {
        if (keyOf(request).endsWith('sqlite3.wasm')) {
          reached();
          await gate;
        }
        return cache.put(request, response);
      },
    };
  };
  const installing = worker(w, workerOf(build('D')), 'D').install();
  await hit;
  deploy(w, 'E');
  // A newer install cannot get the lock while D fills its cache: it fails and is retried later.
  await assert.rejects(worker(w, workerOf(build('E')), 'E').install(), /lock/);
  assert.ok(w.stores.has(cacheOf('D')), 'D\'s half-filled cache was deleted by another install');
  assert.equal(w.stores.has(cacheOf('E')), false);
  release();
  await installing;
  assert.ok(w.stores.get(cacheOf('D')).size > 1);
});

test('audit 3 item 3: an identical B registering again keeps A\'s cache while an A window is open, and A\'s page still gets A\'s parts', async () => {
  const w = await deployedBUnderA({prod: true});
  await takeOver(w, await install(w, 'B'));
  await assert.rejects(install(w, 'B'), /already installed/); // the same stamped build registers again
  assert.ok(w.stores.has('pantas-shell-A'), 'A\'s cache is deleted while an A window is open');
  w.offline = true;
  const answer = await get(w, 'main.dart.js_1.part.js');
  assert.equal(answer.id, 'A', 'A\'s page asks for a part: A\'s cache answers');
});

test('audit 3 item 3: the install of a build again never takes a mark of an earlier takeover along, and removes no cache', async () => {
  const w = await deployedBUnderA({prod: true});
  await takeOver(w, await install(w, 'B'));
  assert.ok(w.stores.get(cacheOf('B')).has(ORIGIN + 'pantas-build-takeover'));
  deploy(w, 'C');
  const c = await install(w, 'C'); // C waits behind B
  await c.message({type: 'pantas-take-over'});
  await takeOver(w, c); // Update Required: B's cache stays
  deploy(w, 'B');
  const again = await install(w, 'B'); // a rollback installs B again: its cache is whole, with its old mark
  assert.ok(w.stores.has(cacheOf('B')));
  assert.ok(!w.stores.get(cacheOf('B')).has(ORIGIN + 'pantas-build-takeover'), 'the old mark is cleared');
  assert.equal(skips(w, 'B').length, 1, 'B waits this time, because C\'s cache exists');
  await takeOver(w, again); // a natural activation: it sweeps
  assert.deepEqual([...w.stores.keys()], [cacheOf('B')]);
});

test('audit 3 item 3: a root part A\'s cache lacks gets the secured 503 even when the edge answers it with another build\'s bytes', async () => {
  const w = await deployedBUnderA({prod: true});
  await takeOver(w, await install(w, 'B'));
  w.edge['main.dart.js_9.part.js'] = build('B').served[inFolder('B', 'main.dart.js_1.part.js')];
  const answer = await w.controller.fetch('main.dart.js_9.part.js');
  assert.equal(answer.status, 503, 'another build\'s bytes were served to an A page');
  assert.equal(answer.headers.get('cache-control'), 'no-store');
  // Online or offline, the same.
  w.offline = true;
  assert.equal((await w.controller.fetch('main.dart.js_9.part.js')).status, 503);
});

// Audit 3 item 8: the Firebase SDK files sit at version-named root addresses, so an older page that
// names an older SDK version asks for a root address the newer worker's list does not hold.
test('audit 3 item 8: two builds with different SDK folders: the older page gets its own SDK, offline, from the retained cache', async () => {
  const older = 'firebase_sdk/12.16.0/firebase-app.js';
  build('S1', {files: {[older]: '// @build:S1@ the older SDK\n'}});
  const w = world();
  deploy(w, 'S1');
  await takeOver(w, await install(w, 'S1'));
  await pageLoad(w); // a window of S1 stays open
  deploy(w, 'S2'); // the next build ships another SDK folder only
  const s2 = await install(w, 'S2');
  assert.deepEqual(await s2.message({type: 'pantas-take-over'}), {ok: true});
  await takeOver(w, s2);
  w.offline = true;
  assert.equal((await get(w, older)).id, 'S1', 'the S1 page asks for its own SDK version');
  assert.equal((await get(w, 'firebase_sdk/12.17.0/firebase-app.js')).id, 'none', 'the shared version is served');
  // An SDK file no build holds is the secured 503, never invented.
  assert.equal((await w.controller.fetch('firebase_sdk/12.15.0/firebase-app.js')).status, 503);
});

// ---- Revision 2, audit 1 Mediums 1 to 4 ----

// Medium 1. A worker that starts to install while a sweep runs stops it: nothing more is deleted,
// whatever build the installing worker is.
async function sweepWithInstallAppearing({afterDeletes}) {
  const {w, c} = await waitingC();
  w.waiting = null;
  await (await w.caches.open('pantas-shell-A')).put(ORIGIN, new Response('legacy'));
  const deleted = [];
  const remove = w.caches.delete;
  w.caches.delete = async (name) => {
    deleted.push(name);
    const result = await remove(name);
    if (deleted.length === afterDeletes) w.installing = worker(w, workerOf(build('D')), 'D');
    return result;
  };
  deploy(w, 'D');
  if (afterDeletes === 0) {
    // The sweep has the lock and is reading the names when D starts to install.
    const keys = w.caches.keys;
    w.caches.keys = async () => {
      w.installing = worker(w, workerOf(build('D')), 'D');
      return keys();
    };
  }
  await c.activate();
  return {w, deleted};
}

test('rev2 audit 1 Medium 1: D installing before the first delete: the sweep deletes nothing', async () => {
  const {w, deleted} = await sweepWithInstallAppearing({afterDeletes: 0});
  assert.deepEqual(deleted, []);
  assert.ok(w.stores.has('pantas-shell-A') && w.stores.has(cacheOf('B')));
});

test('rev2 audit 1 Medium 1: D starts to install after the first delete: the sweep stops, whoever D is', async () => {
  const {w, deleted} = await sweepWithInstallAppearing({afterDeletes: 1});
  assert.equal(deleted.length, 1, `deleted ${JSON.stringify(deleted)}`);
  assert.ok(w.stores.has(cacheOf('C')), 'its own cache stays');
});

// Medium 2. A stamped worker whose cache is missing is not the legacy worker: the next install waits.
test('rev2 audit 1 Medium 2: stamped B active with its cache gone, C installs: no skipWaiting, C waits', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  w.stores.delete(cacheOf('B'));
  deploy(w, 'C');
  const c = await install(w, 'C');
  assert.equal(skips(w, 'C').length, 0, 'C does not skip waiting');
  assert.equal(w.waiting, c);
  assert.equal(w.stores.get(cacheOf('C')).has(ORIGIN + 'pantas-build-takeover'), false, 'no takeover mark either');
});

test('rev2 audit 1 Medium 2: today\'s legacy worker is still taken over from at once', async () => {
  const w = await deployedBUnderA({prod: true});
  const b = await install(w, 'B');
  assert.equal(skips(w, 'B').length, 1);
  assert.equal(w.waiting, b);
});

// Medium 3. The takeover mark is written under the Web Lock, or not at all.
function recordMarkWrites(w) {
  const writes = [];
  const open = w.caches.open;
  w.caches.open = async (name) => {
    const cache = await open(name);
    return {
      ...cache,
      put: async (request, response) => {
        const path = keyOf(request).replace(ORIGIN, '');
        if (path === 'pantas-build-takeover') writes.push({path, held: w.locks.isHeld()});
        return cache.put(request, response);
      },
    };
  };
  return writes;
}

test('rev2 audit 1 Medium 3: an install writes the takeover mark only while it holds the lock', async () => {
  const w = world();
  const writes = recordMarkWrites(w);
  deploy(w, 'A');
  await install(w, 'A');
  assert.deepEqual(writes, [{path: 'pantas-build-takeover', held: true}]);
  assert.equal(skips(w, 'A').length, 1);
});

test('rev2 audit 1 Medium 3: Update Required writes the mark under the lock, and not at all when the lock is not had', async () => {
  const {w, c} = await waitingC();
  const writes = recordMarkWrites(w);
  // Someone else holds the lock for longer than the install's wait.
  let release;
  const hold = new Promise((resolve) => (release = resolve));
  const holder = w.locks.request('pantas-cache-lock', {}, () => hold);
  await new Promise((done) => setImmediate(done));
  assert.deepEqual(await c.message({type: 'pantas-take-over'}), {ok: false});
  assert.deepEqual(writes, [], 'no mark was written without the lock');
  assert.equal(skips(w, 'C').length, 0, 'and C did not take over');
  release();
  await holder;
  assert.deepEqual(await c.message({type: 'pantas-take-over'}), {ok: true});
  assert.deepEqual(writes, [{path: 'pantas-build-takeover', held: true}]);
  assert.equal(skips(w, 'C').length, 1);
});

// Medium 4. A reply that does not come is unknown, not a different build.
// A worker that misses the first ask and answers only the second, longer one.
function answersOnSecondAsk(target) {
  const ask = target.postMessage.bind(target);
  let asks = 0;
  target.postMessage = (data, ports) => {
    if (++asks >= 2) ask(data, ports);
  };
}

test('rev2 audit 1 Medium 4: the build in charge answers only the second, longer ask: a duplicate of it does not install', async () => {
  const w = world();
  deploy(w, 'B');
  const b = await install(w, 'B');
  await takeOver(w, b);
  await pageLoad(w);
  answersOnSecondAsk(b);
  const duplicate = worker(w, workerOf(build('B')), 'same-B-different-url');
  await assert.rejects(duplicate.install(), /already installed/);
  assert.equal(w.waiting, null, 'no duplicate waits');
  assert.equal(skips(w, 'same-B-different-url').length, 0);
});

test('rev2 audit 1 Medium 4: the waiting worker answers only the second ask: a duplicate of it is refused too', async () => {
  const {w, c} = await waitingC();
  answersOnSecondAsk(c);
  const duplicate = worker(w, workerOf(build('C')), 'other-address');
  await assert.rejects(duplicate.install(), /already installed/);
  assert.equal(w.waiting, c);
});

test('rev2 gap (c): a stamped worker that never answers counts as a different build: the install waits, no takeover', async () => {
  const w = world();
  deploy(w, 'B');
  const b = await install(w, 'B');
  await takeOver(w, b);
  await pageLoad(w);
  b.postMessage = () => {};
  deploy(w, 'C');
  const c = await install(w, 'C');
  assert.equal(w.waiting, c);
  assert.equal(skips(w, 'C').length, 0);
  assert.equal(w.stores.get(cacheOf('C')).has(ORIGIN + 'pantas-build-takeover'), false);
});

test('rev2 gap (a): today\'s worker with its cache evicted: the new install completes and waits; every tab closed, it activates and sweeps', async () => {
  const legacy = await deployedBUnderA({prod: true});
  legacy.stores.delete('pantas-shell-A');
  const next = await install(legacy, 'B');
  assert.equal(legacy.waiting, next, 'B waits');
  assert.equal(skips(legacy, 'B').length, 0, 'no takeover');
  assert.equal(legacy.stores.get(cacheOf('B')).has(ORIGIN + 'pantas-build-takeover'), false);
  await (await legacy.caches.open('pantas-shell-old')).put(ORIGIN, new Response('x'));
  await takeOver(legacy, next); // the browser activates it with no tab open
  assert.deepEqual(buildCaches(legacy), [cacheOf('B')]);
  assert.equal(legacy.stores.has('pantas-shell-old'), false, 'the sweep took the old caches');
  assert.deepEqual((await offlineSet(legacy)).builds, ['B']);
});

test('audit 3 item 3: with A\'s cache gone, a root part is still never another build\'s bytes', async () => {
  const w = await deployedBUnderA({prod: true});
  await takeOver(w, await install(w, 'B'));
  deploy(w, 'C');
  await takeOver(w, await install(w, 'C')); // C waits, then activates by itself and sweeps A's cache
  assert.equal(w.stores.has('pantas-shell-A'), false);
  w.edge['main.dart.js_1.part.js'] = build('B').served[inFolder('B', 'main.dart.js_1.part.js')];
  assert.equal((await w.controller.fetch('main.dart.js_1.part.js')).status, 503);
});
