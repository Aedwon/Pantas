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

// What the stamp step writes into the worker for a build whose CanvasKit
// loads from the CDN (main.dart.js only) and for one that loads it locally.
const CDN = { 'main.dart.js': 1000 };
const LOCAL = { 'main.dart.js': 1000, 'canvaskit/chromium/canvaskit.js': 100, 'canvaskit/chromium/canvaskit.wasm': 900 };

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

// Loads pantas_sw.js, stamped with `sizes` (null: an unstamped worker), into a
// fake worker. `files` maps a path to the size the network gives; `stored`
// lists paths already in the cache.
function load({ sizes = CDN, files = {}, stored = [], bodyOptions = {}, clientMissing = false } = {}) {
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
  const stamped = source.replace(/^const LOAD_SIZES = .*$/m, `const LOAD_SIZES = ${JSON.stringify(sizes)};`);
  assert.notEqual(stamped, undefined);
  vm.runInNewContext(stamped, context);
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
const DONE = (total) => ({ type: 'pantas-load-progress', loaded: total, total, done: true });
const STOP = { type: 'pantas-load-progress', stop: true };
const progress = (t) => t.posted.filter((m) => !m.stop);

test('bytes are counted as the page reads them, and 100% comes only when the stream closes', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  const response = await t.ask('main.dart.js');
  const reader = response.body.getReader();
  await reader.read();
  await t.tick();
  assert.ok(t.posted.length > 0);
  assert.ok(t.posted.every((m) => m.total === 1000 && m.loaded <= 250 && !m.done), 'the true count, never done part way');
  for (;;) {
    const { done } = await reader.read();
    if (done) break;
  }
  await t.tick();
  assert.deepEqual(last(t), DONE(1000));
});

test('the true byte count is posted, not a capped one', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  const response = await t.ask('main.dart.js');
  const reader = response.body.getReader();
  let got = 0;
  while (got < 1000) got += (await reader.read()).value.byteLength;
  await t.tick();
  assert.ok(!t.posted.some((m) => m.stop));
  assert.equal(Math.max(...t.posted.map((m) => m.loaded)), 1000);
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
  const baseline = load({ sizes: null, files: { 'main.dart.js': 1000 }, bodyOptions: stalled });
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
  const baseline = load({ sizes: null, files: { 'main.dart.js': 1000 } });
  const counted = load({ files: { 'main.dart.js': 1000 } });
  const a = await baseline.request('main.dart.js');
  const b = await counted.request('main.dart.js');
  assert.equal(b.text, bytes(1000));
  assert.equal(b.text, a.text);
  assert.equal(b.response.status, a.response.status);
  assert.equal(JSON.stringify(counted.puts), JSON.stringify(baseline.puts));
});

test('a cache hit returns the very same stored response, untouched, and counts as received at once', async () => {
  const t = load({ files: { 'main.dart.js': 1000 }, stored: ['main.dart.js'] });
  await t.tick();
  const stored = t.cacheStore.get(ORIGIN + 'main.dart.js');
  const response = await t.ask('main.dart.js');
  assert.equal(response, stored, 'the identical object, so its compiled-code metadata survives');
  await t.tick();
  assert.deepEqual(t.posted, [DONE(1000)]);
  assert.equal(await response.text(), bytes(1000));
  assert.equal(t.puts.length, 0);
  assert.equal(t.fetched.length, 0);
});

test('with one file from the cache and one from the network, 100% waits for the network one', async () => {
  const t = load({ sizes: LOCAL, files: LOCAL_FILES, stored: ['main.dart.js'] });
  await t.tick();
  await t.request('main.dart.js');
  assert.equal(t.posted.length, 1);
  assert.deepEqual(t.posted[0], { type: 'pantas-load-progress', loaded: 1000, total: 2000, done: false });
  await t.request('canvaskit/chromium/canvaskit.js');
  assert.ok(!t.posted.some((m) => m.done));
  await t.request('canvaskit/chromium/canvaskit.wasm');
  assert.deepEqual(last(t), DONE(2000));
});

const LOCAL_FILES = { 'main.dart.js': 1000, 'canvaskit/chromium/canvaskit.js': 100, 'canvaskit/chromium/canvaskit.wasm': 900 };

test('the total is fixed from the first post, so a request still pending keeps it below 100%', async () => {
  const t = load({ sizes: LOCAL, files: LOCAL_FILES });
  await t.tick();
  await t.request('main.dart.js');
  await t.request('canvaskit/chromium/canvaskit.js');
  assert.ok(t.posted.every((m) => m.total === 2000));
  assert.ok(!t.posted.some((m) => m.done), 'the wasm has not been asked for');
  await t.request('canvaskit/chromium/canvaskit.wasm');
  assert.deepEqual(last(t), DONE(2000));
});

test('a request that fails keeps the load below 100%', async () => {
  const t = load({ sizes: LOCAL, files: { 'main.dart.js': 1000 } });
  await t.tick();
  await t.request('main.dart.js');
  const response = await t.ask('canvaskit/chromium/canvaskit.wasm');
  assert.equal(response.status, 404);
  assert.ok(!t.posted.some((m) => m.done));
  assert.deepEqual(last(t), STOP, 'a failed listed file ends the numbers');
});

test('a CDN build: main.dart.js alone is the whole total', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  await t.request('main.dart.js');
  assert.ok(progress(t).length > 1);
  assert.ok(t.posted.every((m) => m.total === 1000));
  assert.deepEqual(last(t), DONE(1000));
});

test('files outside the stamped sizes are passed through, never counted, with no wrapper', async () => {
  const t = load({ files: { 'assets/AssetManifest.bin': 50, 'canvaskit/canvaskit.wasm': 1500 } });
  await t.tick();
  const a = await t.request('assets/AssetManifest.bin');
  const b = await t.request('canvaskit/canvaskit.wasm');
  assert.equal(a.text, bytes(50));
  assert.equal(b.text, bytes(1500));
  assert.equal(t.posted.length, 0);
});

test('the percent only ever rises', async () => {
  const t = load({ sizes: LOCAL, files: LOCAL_FILES });
  await t.tick();
  for (const name of Object.keys(LOCAL)) await t.request(name);
  const p = progress(t).map((m) => Math.floor((m.loaded * 100) / m.total));
  assert.deepEqual(p, [...p].sort((a, b) => a - b));
});

test('more bytes than the listed size posts a stop and the page still gets every byte', async () => {
  const t = load({ files: { 'main.dart.js': 1200 } });
  await t.tick();
  const { text } = await t.request('main.dart.js');
  assert.equal(text, bytes(1200));
  assert.ok(!t.posted.some((m) => m.done));
  assert.equal(t.posted.filter((m) => m.stop).length, 1);
  assert.deepEqual(last(t), STOP);
});

test('after a stop that load posts nothing more', async () => {
  const t = load({ sizes: LOCAL, files: { ...LOCAL_FILES, 'main.dart.js': 1200 } });
  await t.tick();
  await t.request('main.dart.js');
  const count = t.posted.length;
  await t.request('canvaskit/chromium/canvaskit.js');
  await t.request('canvaskit/chromium/canvaskit.wasm');
  assert.equal(t.posted.length, count);
});

test('a body shorter than the listed size posts a stop and never 100%', async () => {
  const t = load({ files: { 'main.dart.js': 800 } });
  await t.tick();
  await t.request('main.dart.js');
  assert.ok(!t.posted.some((m) => m.done));
  assert.deepEqual(last(t), STOP);
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

test('an unstamped worker passes everything through and posts nothing', async () => {
  for (const sizes of [null, {}, { 'main.dart.js': 0 }, { 'main.dart.js': 'x' }, { 'main.dart.js': -4 }, []]) {
    const t = load({ sizes, files: { 'main.dart.js': 1000 } });
    await t.tick();
    const { text } = await t.request('main.dart.js');
    assert.equal(text, bytes(1000), JSON.stringify(sizes));
    assert.equal(t.posted.length, 0, JSON.stringify(sizes));
  }
});

test('the worker reads no list: no fetch, no cache read, nothing at install or activate', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.tick();
  assert.equal(t.cacheReads.length, 0);
  await t.request('main.dart.js');
  assert.ok(!t.fetched.some((url) => url.includes('load_sizes')));
  assert.ok(!t.cacheReads.some((url) => url.includes('load_sizes')));
  assert.ok(!/pantas_load_sizes/.test(source.replace(/\/\/.*$/gm, '')), 'no list file is named in the code');
});

test('a missing page client never breaks the response', async () => {
  const t = load({ clientMissing: true, files: { 'main.dart.js': 1000 } });
  await t.tick();
  const { text } = await t.request('main.dart.js');
  assert.equal(text, bytes(1000));
  assert.equal(t.posted.length, 0);
});

test('the source worker is unstamped, and install, activate and precache are as on main', () => {
  assert.match(source, /^const LOAD_SIZES = null;/m);
  assert.ok(!/PRECACHE = \[[^\]]*load_sizes/.test(source));
  assert.ok(!/addEventListener\('activate'[\s\S]*refreshSizes/.test(source));
  assert.ok(!/\.tee\(\)|getReader/.test(source), 'no tee and no extra reader for counting');
});
