// Run with: node --test test/web/pantas_sw_progress.test.mjs
// The service worker counts the decoded bytes it delivers to the page for the
// app files named in the build's size list, and posts progress (loading board A,
// UX lead, Nov 25). Audit fixes (Codex, Nov 25): the count sits in the stream
// the page reads, nothing is cloned, nothing waits on the list at request time,
// and 100% comes only when a stream closes.
import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import { readFileSync } from 'node:fs';

const source = readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8');
const ORIGIN = 'https://app.test/';
const VERSION = 't1';
const LIST_URL = ORIGIN + 'pantas_load_sizes.json';
const bytes = (n, fill = 'a') => fill.repeat(n);
const tick = () => new Promise((resolve) => setImmediate(resolve));

const LIST = {
  v: 1,
  version: VERSION,
  files: {
    'main.dart.js': 1000,
    'canvaskit/chromium/canvaskit.js': 100,
    'canvaskit/chromium/canvaskit.wasm': 900,
    'canvaskit/canvaskit.js': 100,
    'canvaskit/canvaskit.wasm': 1500,
  },
};
const CHROMIUM = ['canvaskit/chromium/canvaskit.js', 'canvaskit/chromium/canvaskit.wasm'];

// A network body that arrives in chunks. `stallAfter` stops it part way and
// never ends; `failAfter` makes it error part way.
function chunked(total, { chunks = 4, stallAfter = null, failAfter = null } = {}) {
  const size = Math.ceil(total / chunks);
  let left = total;
  let sent = 0;
  const stream = new ReadableStream({
    pull(controller) {
      if (failAfter !== null && sent >= failAfter) return controller.error(new Error('network down'));
      if (stallAfter !== null && sent >= stallAfter) return new Promise(() => {});
      if (left <= 0) return controller.close();
      const n = Math.min(size, left);
      left -= n;
      sent += n;
      controller.enqueue(new Uint8Array(n).fill(97));
    },
  });
  const response = new Response(stream, { status: 200 });
  Object.defineProperty(response, 'type', { value: 'basic' });
  return response;
}

// Loads pantas_sw.js into a fake worker. `files` maps a path to the size the
// network gives; `stored` lists paths already in the cache; `listStore` is the
// size list in the cache (null: none, 'stall': the cache never answers).
function load({ list = LIST, files = {}, stored = [], bodyOptions = {}, listStore = list, clientMissing = false } = {}) {
  const handlers = {};
  const posted = [];
  const puts = [];
  const fetched = [];
  const cacheStore = new Map(stored.map((p) => [ORIGIN + p, bytes(files[p] ?? 1)]));
  const cache = {
    match: async (request) => {
      const url = typeof request === 'string' ? request : request.url;
      if (url === LIST_URL) {
        if (listStore === 'stall') return new Promise(() => {});
        return listStore ? new Response(JSON.stringify(listStore)) : undefined;
      }
      return cacheStore.has(url) ? new Response(cacheStore.get(url)) : undefined;
    },
    put: async (request, response) => {
      puts.push(typeof request === 'string' ? request : request.url);
      cacheStore.set(typeof request === 'string' ? request : request.url, await response.text());
    },
  };
  const client = { postMessage: (m) => posted.push(JSON.parse(JSON.stringify(m))) };
  const context = {
    URL, Request, Response, Headers, Promise, Set, Map, Math, Object, Array, JSON, Error, console,
    TransformStream, ReadableStream, setTimeout, clearTimeout,
    self: {
      location: { href: ORIGIN + `pantas_sw.js?v=${VERSION}`, origin: 'https://app.test' },
      registration: { scope: ORIGIN },
      addEventListener: (type, fn) => (handlers[type] = fn),
      skipWaiting: async () => {},
      clients: { claim: async () => {}, get: async () => (clientMissing ? undefined : client) },
    },
    caches: { open: async () => cache, keys: async () => [], delete: async () => true },
    fetch: async (request) => {
      const url = typeof request === 'string' ? request : request.url;
      fetched.push(url);
      const path = url.replace(ORIGIN, '').split('?')[0];
      if (path in files) return chunked(files[path], bodyOptions[path] ?? {});
      return new Response('', { status: 404 });
    },
  };
  vm.runInNewContext(source, context);
  const waits = [];
  // Asks the worker for a file. Returns the page's response without reading it.
  async function ask(path, { clientId = 'c1' } = {}) {
    let answer;
    handlers.fetch({
      request: new Request(ORIGIN + path),
      clientId,
      respondWith: (p) => (answer = p),
      waitUntil: (p) => waits.push(Promise.resolve(p).catch(() => {})),
    });
    return answer;
  }
  // Asks, then reads the whole body, the way a quick page does.
  async function request(path, options) {
    const response = await ask(path, options);
    const text = await response.text();
    await tick();
    return { response, text };
  }
  return { ask, request, posted, puts, fetched, waits, cacheStore, tick };
}

const last = (t) => t.posted[t.posted.length - 1];
const DONE = (total) => ({ type: 'pantas-load-progress', loaded: total, total, done: true });

async function whole(t, { skip = [] } = {}) {
  await t.tick();
  await t.request('main.dart.js');
  for (const name of CHROMIUM) if (!skip.includes(name)) await t.request(name);
}

test('bytes are counted as the page reads them, and 100% comes only when the stream closes', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  const response = await t.ask('main.dart.js');
  const reader = response.body.getReader();
  await reader.read();
  await t.tick();
  assert.ok(t.posted.length > 0);
  assert.ok(t.posted.every((m) => m.loaded < m.total && !m.done), 'part way is never 100%');
  for (;;) {
    const { done } = await reader.read();
    if (done) break;
  }
  await t.tick();
  assert.deepEqual(last(t), DONE(1000));
});

test('a slow page reader sets the pace: nothing is counted that the page has not been given', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  const response = await t.ask('main.dart.js');
  await t.tick();
  await t.tick();
  const before = t.posted.length ? last(t).loaded : 0;
  assert.ok(before <= 500, `read ahead by ${before} bytes of 1000`);
  assert.ok(!t.posted.some((m) => m.done));
  await response.arrayBuffer();
  await t.tick();
  assert.deepEqual(last(t), DONE(1000));
});

test('progress holds no worker task open: it adds no waitUntil, so a stalled body cannot block activation', async () => {
  const stalled = { 'main.dart.js': { stallAfter: 500 } };
  const baseline = load({ list: null, listStore: null, files: { 'main.dart.js': 1000 }, bodyOptions: stalled });
  const t = load({ files: { 'main.dart.js': 1000 }, bodyOptions: stalled });
  for (const w of [baseline, t]) {
    await w.tick();
    const response = await w.ask('main.dart.js');
    const reader = response.body.getReader();
    await reader.read();
    await w.tick();
  }
  assert.equal(t.waits.length, baseline.waits.length);
  assert.ok(!t.posted.some((m) => m.done));
});

test('the page gets the same bytes and the worker adds no cache writes of its own', async () => {
  const baseline = load({ list: null, listStore: null, files: { 'main.dart.js': 1000 } });
  const counted = load({ files: { 'main.dart.js': 1000 } });
  await baseline.tick();
  await counted.tick();
  const a = await baseline.request('main.dart.js');
  const b = await counted.request('main.dart.js');
  assert.equal(b.text, bytes(1000));
  assert.equal(b.text, a.text);
  assert.equal(b.response.status, a.response.status);
  assert.equal(JSON.stringify(counted.puts), JSON.stringify(baseline.puts));
});

test('a file already in the cache is counted by the same stream, as the page reads it', async () => {
  const t = load({ files: { 'main.dart.js': 1000 }, stored: ['main.dart.js'] });
  await t.tick();
  const { text } = await t.request('main.dart.js');
  assert.equal(text, bytes(1000));
  assert.deepEqual(last(t), DONE(1000));
  assert.equal(t.puts.length, 0, 'a stored file is not stored again');
  assert.equal(t.fetched.length, 0);
});

test('the total is the files the page asked for through the worker, not the whole list', async () => {
  const t = load({ files: { 'main.dart.js': 1000, [CHROMIUM[0]]: 100, [CHROMIUM[1]]: 900 } });
  await whole(t);
  assert.deepEqual(last(t), DONE(2000), 'the full canvaskit build is not in the total');
  assert.ok(t.posted.every((m) => m.total <= 2000));
});

test('CanvasKit that bypasses the worker (CDN build): the total is main.dart.js alone', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  await t.request('main.dart.js');
  assert.ok(t.posted.length > 1, 'a number is possible with the CDN build');
  assert.ok(t.posted.every((m) => m.total === 1000));
  assert.deepEqual(last(t), DONE(1000));
});

test('a browser that takes the full canvaskit counts that build only', async () => {
  const t = load({ files: { 'main.dart.js': 1000, 'canvaskit/canvaskit.js': 100, 'canvaskit/canvaskit.wasm': 1500 } });
  await t.tick();
  await t.request('main.dart.js');
  await t.request('canvaskit/canvaskit.js');
  await t.request('canvaskit/canvaskit.wasm');
  assert.deepEqual(last(t), DONE(2600));
});

test('the percent only ever rises', async () => {
  const t = load({ files: { 'main.dart.js': 1000, [CHROMIUM[0]]: 100, [CHROMIUM[1]]: 900 } });
  await whole(t);
  const loaded = t.posted.map((m) => Math.floor((m.loaded * 100) / m.total));
  assert.deepEqual(loaded, [...loaded].sort((a, b) => a - b));
});

test('more bytes than the listed size stops the numbers and never claims 100%', async () => {
  const t = load({ files: { 'main.dart.js': 1200 } });
  await t.tick();
  const { text } = await t.request('main.dart.js');
  assert.equal(text, bytes(1200), 'the page still gets every byte');
  assert.ok(!t.posted.some((m) => m.done));
  assert.ok(t.posted.every((m) => m.loaded <= m.total));
});

test('after an oversize file the rest of that load posts nothing more', async () => {
  const t = load({ files: { 'main.dart.js': 1200, [CHROMIUM[0]]: 100, [CHROMIUM[1]]: 900 } });
  await whole(t);
  const count = t.posted.length;
  await t.request('main.dart.js', { clientId: 'c1' });
  assert.equal(t.posted.length, count);
  assert.ok(!t.posted.some((m) => m.done));
});

test('a body shorter than the listed size never claims 100%', async () => {
  const t = load({ files: { 'main.dart.js': 800 } });
  await t.tick();
  await t.request('main.dart.js');
  assert.ok(!t.posted.some((m) => m.done));
});

test('a stream that errors stops the numbers for that load', async () => {
  const t = load({ files: { 'main.dart.js': 1000 }, bodyOptions: { 'main.dart.js': { failAfter: 500 } } });
  await t.tick();
  const response = await t.ask('main.dart.js');
  await assert.rejects(() => response.arrayBuffer());
  await t.tick();
  assert.ok(!t.posted.some((m) => m.done));
});

test('a file asked for twice by one page is counted once', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  await t.request('main.dart.js');
  await t.request('main.dart.js');
  assert.deepEqual(last(t), DONE(1000));
  assert.ok(t.posted.every((m) => m.total === 1000));
});

test('each page is counted on its own', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  await t.request('main.dart.js', { clientId: 'c1' });
  await t.request('main.dart.js', { clientId: 'c2' });
  assert.equal(t.posted.filter((m) => m.done).length, 2);
});

test('a path outside the list is passed through with no waiting and no wrapper', async () => {
  const t = load({ files: { 'assets/AssetManifest.bin': 50 } });
  await t.tick();
  const { text } = await t.request('assets/AssetManifest.bin');
  assert.equal(text, bytes(50));
  assert.equal(t.posted.length, 0);
});

test('a stalled size list never delays a response', async () => {
  const t = load({ listStore: 'stall', files: { 'main.dart.js': 1000, 'assets/AssetManifest.bin': 50 } });
  const started = Date.now();
  const first = await t.request('main.dart.js');
  const second = await t.request('assets/AssetManifest.bin');
  assert.ok(Date.now() - started < 200);
  assert.equal(first.text, bytes(1000));
  assert.equal(second.text, bytes(50));
  assert.equal(t.posted.length, 0, 'without the list there is no number');
});

test('the worker never fetches the size list at request time', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  await t.request('main.dart.js');
  assert.ok(!t.fetched.some((url) => url.includes('pantas_load_sizes')));
});

test('a list from another build is ignored', async () => {
  const t = load({ listStore: { ...LIST, version: 'other' }, files: { 'main.dart.js': 1000 } });
  await t.tick();
  const { text } = await t.request('main.dart.js');
  assert.equal(text, bytes(1000));
  assert.equal(t.posted.length, 0);
});

test('a list with no build version is ignored', async () => {
  const { version, ...unversioned } = LIST;
  const t = load({ listStore: unversioned, files: { 'main.dart.js': 1000 } });
  await t.tick();
  await t.request('main.dart.js');
  assert.equal(t.posted.length, 0);
});

test('with no size list the worker posts nothing', async () => {
  const t = load({ list: null, listStore: null, files: { 'main.dart.js': 1000 } });
  await t.tick();
  const { text } = await t.request('main.dart.js');
  assert.equal(text, bytes(1000));
  assert.equal(t.posted.length, 0);
});

test('a size list that is not valid is ignored', async () => {
  for (const bad of [
    { v: 2, version: VERSION, files: { 'main.dart.js': 1 } },
    { v: 1, version: VERSION, files: { 'main.dart.js': -5 } },
    { v: 1, version: VERSION, files: { 'main.dart.js': 'x' } },
    { v: 1, version: VERSION, files: {} },
    { v: 1, version: VERSION },
    [],
  ]) {
    const t = load({ listStore: bad, files: { 'main.dart.js': 1000 } });
    await t.tick();
    await t.request('main.dart.js');
    assert.equal(t.posted.length, 0, JSON.stringify(bad));
  }
});

test('a missing page client never breaks the response', async () => {
  const t = load({ clientMissing: true, files: { 'main.dart.js': 1000 } });
  await t.tick();
  const { text } = await t.request('main.dart.js');
  assert.equal(text, bytes(1000));
  assert.equal(t.posted.length, 0);
});

test('the size list is stored with the build, and the install and cache code are as before', () => {
  assert.match(source, /const PRECACHE = \[[^\]]*'pantas_load_sizes\.json'/);
  assert.match(source, /async function cacheFirst/);
  assert.match(source, /const NETWORK_FIRST = new Set/);
  assert.ok(!/clone\(\)[^;]*getReader|\.tee\(\)/.test(source), 'no tee for counting');
});
