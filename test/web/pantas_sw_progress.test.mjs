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
const bytes = (n, fill = 'a') => fill.repeat(n);
const tick = () => new Promise((resolve) => setImmediate(resolve));

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

// Loads pantas_sw.js, exactly as it is on disk, into a fake worker. `files` maps a path to the size the network gives; `stored`
// lists paths already in the cache.
function load({ files = {}, stored = [], bodyOptions = {}, clientMissing = false } = {}) {
  const handlers = {};
  const posted = [];
  const puts = [];
  const fetched = [];
  const cacheStore = new Map(stored.map((p) => [ORIGIN + p, new Response(bytes(files[p] ?? 1))]));
  const cacheReads = [];
  const cache = {
    match: async (request) => {
      const url = typeof request === 'string' ? request : request.url;
      cacheReads.push(url);
      return cacheStore.get(url);
    },
    put: async (request, response) => {
      puts.push(typeof request === 'string' ? request : request.url);
      cacheStore.set(typeof request === 'string' ? request : request.url, new Response(await response.text()));
    },
  };
  const client = { postMessage: (m) => posted.push(JSON.parse(JSON.stringify(m))) };
  const context = {
    URL, Request, Response, Headers, Promise, Set, Map, Math, Object, Array, JSON, Error, console,
    TransformStream, ReadableStream, setTimeout, clearTimeout, Date,
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
  return { ask, request, posted, puts, fetched, waits, cacheStore, cacheReads, tick };
}

const last = (t) => t.posted[t.posted.length - 1];
const DONE = (loaded) => ({ type: 'pantas-load-progress', loaded, done: true });
const STOP = { type: 'pantas-load-progress', stop: true };
const CACHED = { type: 'pantas-load-progress', cached: true };

test('the worker script carries no sizes and no build-specific text', () => {
  assert.ok(!/LOAD_SIZES|pantasLoadTotal|load_sizes/.test(source));
});

test('true bytes are posted as the page reads them, then done with the exact count', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  const response = await t.ask('main.dart.js');
  const reader = response.body.getReader();
  await reader.read();
  await t.tick();
  assert.ok(t.posted.length > 0);
  assert.ok(t.posted.every((m) => !m.done && !m.stop && m.loaded <= 250), 'the true count, never done part way');
  assert.ok(t.posted.every((m) => m.total === undefined), 'the worker states no total');
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

test('progress adds no waitUntil, so a stalled body cannot block activation', async () => {
  const stalled = { 'main.dart.js': { stallAfter: 500 } };
  const counted = load({ files: { 'main.dart.js': 1000 }, bodyOptions: stalled });
  const plain = load({ files: { 'main.dart.js': 1000 }, bodyOptions: stalled });
  await counted.tick();
  await plain.tick();
  // No client id means the request is not counted: the same worker, untouched.
  const a = await counted.ask('main.dart.js');
  const b = await plain.ask('main.dart.js', { clientId: '' });
  await a.body.getReader().read();
  await b.body.getReader().read();
  await counted.tick();
  assert.equal(counted.waits.length, plain.waits.length);
  assert.ok(!counted.posted.some((m) => m.done));
});

test('the page gets the same bytes and the worker adds no cache writes of its own', async () => {
  const counted = load({ files: { 'main.dart.js': 1000 } });
  await counted.tick();
  const b = await counted.request('main.dart.js');
  assert.equal(b.text, bytes(1000));
  assert.equal(b.response.status, 200);
  assert.equal(JSON.stringify(counted.puts), JSON.stringify([ORIGIN + 'main.dart.js']), 'the one write cacheFirst already made');
});

test('a cache hit returns the very same stored response, untouched, and posts a cached message', async () => {
  const t = load({ files: { 'main.dart.js': 1000 }, stored: ['main.dart.js'] });
  await t.tick();
  const stored = t.cacheStore.get(ORIGIN + 'main.dart.js');
  const response = await t.ask('main.dart.js');
  assert.equal(response, stored, 'the identical object, so its compiled-code metadata survives');
  await t.tick();
  assert.deepEqual(t.posted, [CACHED]);
  assert.equal(await response.text(), bytes(1000));
  assert.equal(t.puts.length, 0);
  assert.equal(t.fetched.length, 0);
});

test('only main.dart.js is counted; every other file passes through as the same promise', async () => {
  const t = load({ files: { 'assets/AssetManifest.bin': 50, 'canvaskit/canvaskit.wasm': 1500 } });
  await t.tick();
  const a = await t.request('assets/AssetManifest.bin');
  const b = await t.request('canvaskit/canvaskit.wasm');
  assert.equal(a.text, bytes(50));
  assert.equal(b.text, bytes(1500));
  assert.equal(t.posted.length, 0);
});

test('a stream that errors posts a stop', async () => {
  const t = load({ files: { 'main.dart.js': 1000 }, bodyOptions: { 'main.dart.js': { failAfter: 500 } } });
  await t.tick();
  const response = await t.ask('main.dart.js');
  await assert.rejects(() => response.arrayBuffer());
  await t.tick();
  assert.ok(!t.posted.some((m) => m.done));
  assert.deepEqual(last(t), STOP);
});

test('a failed response for main.dart.js posts a stop', async () => {
  const t = load({ files: {} });
  await t.tick();
  const response = await t.ask('main.dart.js');
  assert.equal(response.status, 404);
  assert.deepEqual(t.posted, [STOP]);
});

test('after a stop that load posts nothing more', async () => {
  const t = load({ files: { 'main.dart.js': 1000 }, bodyOptions: { 'main.dart.js': { failAfter: 500 } } });
  await t.tick();
  const response = await t.ask('main.dart.js');
  await assert.rejects(() => response.arrayBuffer());
  await t.tick();
  const count = t.posted.length;
  await t.ask('main.dart.js');
  await t.tick();
  assert.equal(t.posted.length, count);
});

test('main.dart.js asked for twice by one page is counted once', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  await t.request('main.dart.js');
  const count = t.posted.length;
  await t.request('main.dart.js');
  assert.equal(t.posted.length, count);
  assert.equal(t.posted.filter((m) => m.done).length, 1);
});

test('each page is counted on its own', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  await t.request('main.dart.js', { clientId: 'c1' });
  await t.request('main.dart.js', { clientId: 'c2' });
  assert.equal(t.posted.filter((m) => m.done).length, 1);
  assert.deepEqual(last(t), CACHED, 'the second page finds it stored by the first');
});

test('the worker reads no list: no list fetch, no extra cache read, no install or activate change', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  assert.equal(t.cacheReads.length, 0);
  await t.request('main.dart.js');
  assert.ok(!t.fetched.some((url) => url.includes('sizes')));
});

test('a missing page client never breaks the response', async () => {
  const t = load({ clientMissing: true, files: { 'main.dart.js': 1000 } });
  await t.tick();
  const { text } = await t.request('main.dart.js');
  assert.equal(text, bytes(1000));
  assert.equal(t.posted.length, 0);
});

test('no clone, no tee and no extra reader for counting; precache is as on main', () => {
  assert.ok(!/\.tee\(\)|getReader/.test(source));
  assert.ok(!/PRECACHE = \[[^\]]*sizes/.test(source));
});
