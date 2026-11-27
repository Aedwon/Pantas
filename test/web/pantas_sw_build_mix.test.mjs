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
    dropAfter: null, windows: 1, extraHeaders: {}, chromium: true,
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
    if (w.offline) throw new TypeError('offline');
    if (w.dropAfter !== null && w.requests.length > w.dropAfter) throw new TypeError('connection lost');
    const path = strip2(url).replace(ORIGIN, '');
    if (!w.build) return new Response('', {status: 404});
    const served = builds[w.build].served;
    if (!(path in served) || path === 'pantas_sw.js') return new Response('', {status: 404});
    return basic(w.tamper[path] ?? served[path], path, null, w.extraHeaders[path] ?? {});
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
    // A Chromium browser has both of these; another browser lacks the first.
    Intl: w.chromium ? {v8BreakIterator: function () {}, Segmenter: function () {}} : {Segmenter: function () {}},
    self: {
      location: {href: ORIGIN + `pantas_sw.js?v=${version}`, origin: 'https://app.test'},
      registration: {scope: ORIGIN},
      addEventListener: (type, fn) => (handlers[type] = fn),
      skipWaiting: async () => {
        w.events.push({event: 'skipWaiting', version, stores: new Map([...w.stores].map(([k, v]) => [k, v.size]))});
      },
      clients: {
        claim: async () => w.events.push({event: 'claim', version}),
        get: async () => undefined,
        matchAll: async () => Array.from({length: w.windows}, () => ({})),
      },
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
    handlers,
    install: () => lifecycle('install'),
    activate: () => lifecycle('activate'),
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
  assert.deepEqual(root.sort(), ['drift_worker.js', 'favicon.png', 'index.html', 'manifest.json', 'og-image.png', 'pantas_sw.js', 'version.json', 'README.md', 'flutter_service_worker.js'].sort());
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

test('the waiting worker takes over when its page asks and is the only window', async () => {
  const {w, c} = await waitingC();
  w.windows = 1;
  assert.deepEqual(await c.message({type: 'pantas-take-over'}), {ok: true});
  assert.equal(skips(w, 'C').length, 1);
  await takeOver(w, c);
  assert.deepEqual(buildCaches(w), [cacheOf('B'), cacheOf('C')].sort(), 'nothing is deleted when C activates: a B window may still be open');
  const r = await offlineSet(w);
  assert.deepEqual(r.builds, ['C']);
  assert.deepEqual(r.misses, []);
});

test('a second window stops the takeover: apply cannot take over while another window is open', async () => {
  const {w, c} = await waitingC();
  w.windows = 2;
  const reply = await c.message({type: 'pantas-take-over'});
  assert.equal(reply.ok, false);
  assert.equal(skips(w, 'C').length, 0);
  assert.deepEqual((await offlineSet(w)).builds, ['B']);
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
// asks for, and an offline start would fail. Both variants are installed in every browser.
test('both renderer variants are installed in every browser, so Flutter\'s own choice is always there offline', async () => {
  for (const chromium of [true, false]) {
    const w = world();
    w.chromium = chromium;
    build('R', {files: rendererBuild('R'), localCanvasKit: true});
    deploy(w, 'R');
    await takeOver(w, await install(w, 'R'));
    const cached = [...w.stores.get(cacheOf('R')).keys()].map((url) => url.replace(ORIGIN, ''));
    for (const name of ['canvaskit.js', 'canvaskit.wasm', 'chromium/canvaskit.js', 'chromium/canvaskit.wasm']) {
      assert.ok(cached.includes(`${folderOf('R')}canvaskit/${name}`), `${name} (chromium browser: ${chromium})`);
    }
    w.offline = true;
    for (const name of ['canvaskit/chromium/canvaskit.wasm', 'canvaskit/canvaskit.wasm']) {
      assert.equal((await get(w, inFolder('R', name))).id, 'R', `${name} offline (chromium browser: ${chromium})`);
    }
  }
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

test('item 3: installs prune at their end and keep only the new build and the one in charge', async () => {
  const w = world();
  deploy(w, 'B');
  await takeOver(w, await install(w, 'B'));
  await pageLoad(w);
  // B stays in charge (a window is open). C, D and E install one after the other, none takes over.
  for (const id of ['C', 'D', 'E']) {
    deploy(w, id);
    await install(w, id);
    assert.deepEqual(buildCaches(w), [cacheOf('B'), cacheOf(id)].sort(), `after installing ${id}`);
  }
});

test('item 3: an activation cannot delete a successor\'s cache that is being filled', async () => {
  const {w, c} = await waitingC();
  const partial = await w.caches.open(`pantas-build-D-${'0'.repeat(12)}`);
  await partial.put(ORIGIN + 'b/D/main.dart.js', new Response('half of D'));
  await c.message({type: 'pantas-take-over'});
  await takeOver(w, c);
  assert.ok(w.stores.has(`pantas-build-D-${'0'.repeat(12)}`), 'D\'s cache survived C\'s activation');
});

test('item 3: the install that makes B the older build removes the oldest, and today\'s worker\'s cache goes with it', async () => {
  const w = await deployedBUnderA({prod: true});
  await takeOver(w, await install(w, 'B')); // B in charge: A's cache is kept for tabs still on A
  assert.ok(w.stores.has('pantas-shell-A'));
  deploy(w, 'C');
  await install(w, 'C');
  assert.equal(w.stores.has('pantas-shell-A'), false, 'A\'s cache is pruned when C installs');
  assert.deepEqual(buildCaches(w), [cacheOf('B'), cacheOf('C')].sort());
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
