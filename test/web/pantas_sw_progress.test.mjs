// Run with: node --test test/web/pantas_sw_progress.test.mjs
// The service worker counts the decoded bytes of the app files it passes to the
// page and posts progress (loading board A, UX lead, Nov 25). It must never
// change what is cached or which response the page gets.
import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import { readFileSync } from 'node:fs';

const source = readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8');
const ORIGIN = 'https://app.test/';
const bytes = (n, fill = 'a') => fill.repeat(n);

const LIST = {
  v: 1,
  files: {
    'main.dart.js': 1000,
    'canvaskit/chromium/canvaskit.js': 100,
    'canvaskit/chromium/canvaskit.wasm': 900,
    'canvaskit/canvaskit.js': 100,
    'canvaskit/canvaskit.wasm': 1500,
  },
  alternatives: [[
    ['canvaskit/chromium/canvaskit.js', 'canvaskit/chromium/canvaskit.wasm'],
    ['canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm'],
  ]],
};

// A response whose body arrives in several chunks, the way the network does.
function chunked(total, { chunks = 4, status = 200 } = {}) {
  const size = Math.ceil(total / chunks);
  let left = total;
  const stream = new ReadableStream({
    pull(controller) {
      if (left <= 0) return controller.close();
      const n = Math.min(size, left);
      left -= n;
      controller.enqueue(new Uint8Array(n).fill(97));
    },
  });
  const response = new Response(stream, { status });
  // A same-origin network answer, as the browser gives it to a worker.
  Object.defineProperty(response, 'type', { value: 'basic' });
  return response;
}

// Loads pantas_sw.js into a fake worker. `files` maps a path to the size of
// the response the network gives; `stored` lists paths already in the cache.
function load({ list = LIST, files = {}, stored = [], clientMissing = false } = {}) {
  const handlers = {};
  const posted = [];
  const puts = [];
  const cacheStore = new Map(stored.map((p) => [ORIGIN + p, bytes(files[p] ?? 1)]));
  const cache = {
    match: async (request) => {
      const url = typeof request === 'string' ? request : request.url;
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
    setTimeout, clearTimeout,
    self: {
      location: { href: ORIGIN + 'pantas_sw.js?v=t1', origin: 'https://app.test' },
      registration: { scope: ORIGIN },
      addEventListener: (type, fn) => (handlers[type] = fn),
      skipWaiting: async () => {},
      clients: {
        claim: async () => {},
        get: async () => (clientMissing ? undefined : client),
      },
    },
    caches: { open: async () => cache, keys: async () => [], delete: async () => true },
    fetch: async (request) => {
      const url = typeof request === 'string' ? request : request.url;
      const path = url.replace(ORIGIN, '').split('?')[0];
      if (path === 'pantas_load_sizes.json') {
        if (list === null) return new Response('<html>', { status: 404 });
        return new Response(JSON.stringify(list), { headers: { 'Content-Type': 'application/json' } });
      }
      if (path in files) return chunked(files[path]);
      return new Response('', { status: 404 });
    },
  };
  context.self.fetch = context.fetch;
  vm.runInNewContext(source, context);
  // Runs one page request through the worker and waits for all its work.
  async function request(path, { clientId = 'c1' } = {}) {
    const waits = [];
    let answer;
    handlers.fetch({
      request: new Request(ORIGIN + path),
      clientId,
      respondWith: (p) => (answer = p),
      waitUntil: (p) => waits.push(p),
    });
    const response = await answer;
    // The page reads its copy at its own pace, then the worker finishes.
    const text = await response.text();
    await Promise.all(waits);
    return { response, text };
  }
  return { request, posted, puts, cacheStore };
}

const last = (t) => t.posted[t.posted.length - 1];
const pcts = (t) => t.posted.map((m) => Math.floor((m.loaded * 100) / m.total));

test('the bytes of each file are counted as they arrive and posted with the total', async () => {
  const t = load({ files: { 'main.dart.js': 1000, 'canvaskit/chromium/canvaskit.js': 100, 'canvaskit/chromium/canvaskit.wasm': 900 } });
  await t.request('main.dart.js');
  await t.request('canvaskit/chromium/canvaskit.js');
  await t.request('canvaskit/chromium/canvaskit.wasm');
  assert.ok(t.posted.length > 3, 'progress arrives in steps, not once');
  assert.ok(t.posted.every((m) => m.type === 'pantas-load-progress' && m.total === 2000));
  assert.deepEqual(last(t), { type: 'pantas-load-progress', loaded: 2000, total: 2000 });
  const loaded = t.posted.map((m) => m.loaded);
  assert.deepEqual(loaded, [...loaded].sort((a, b) => a - b), 'the count never goes back');
});

test('the page gets the same bytes, and the worker adds no cache writes of its own', async () => {
  const baseline = load({ list: null, files: { 'main.dart.js': 1000 } });
  const counted = load({ files: { 'main.dart.js': 1000 } });
  const a = await baseline.request('main.dart.js');
  const b = await counted.request('main.dart.js');
  assert.equal(b.text, bytes(1000));
  assert.equal(b.text, a.text);
  assert.equal(b.response.status, a.response.status);
  assert.equal(JSON.stringify(counted.puts), JSON.stringify(baseline.puts));
});

test('files already in the cache count as received at once', async () => {
  const t = load({
    files: { 'main.dart.js': 1000, 'canvaskit/chromium/canvaskit.js': 100, 'canvaskit/chromium/canvaskit.wasm': 900 },
    stored: ['main.dart.js', 'canvaskit/chromium/canvaskit.js', 'canvaskit/chromium/canvaskit.wasm'],
  });
  await t.request('main.dart.js');
  await t.request('canvaskit/chromium/canvaskit.js');
  await t.request('canvaskit/chromium/canvaskit.wasm');
  assert.deepEqual(last(t), { type: 'pantas-load-progress', loaded: 2000, total: 2000 });
  assert.equal(t.puts.length, 0, 'a stored file is not stored again');
});

test('until the page asks for a canvaskit build there is no total, so nothing is posted', async () => {
  const t = load({ files: { 'main.dart.js': 1000 } });
  await t.request('main.dart.js');
  assert.equal(t.posted.length, 0);
});

test('a browser that takes the full canvaskit counts that build, not both', async () => {
  const t = load({ files: { 'main.dart.js': 1000, 'canvaskit/canvaskit.js': 100, 'canvaskit/canvaskit.wasm': 1500 } });
  await t.request('main.dart.js');
  await t.request('canvaskit/canvaskit.js');
  await t.request('canvaskit/canvaskit.wasm');
  assert.deepEqual(last(t), { type: 'pantas-load-progress', loaded: 2600, total: 2600 });
});

test('the percent only ever rises and ends at 100', async () => {
  const t = load({ files: { 'main.dart.js': 1000, 'canvaskit/chromium/canvaskit.js': 100, 'canvaskit/chromium/canvaskit.wasm': 900 } });
  await t.request('canvaskit/chromium/canvaskit.js');
  await t.request('main.dart.js');
  await t.request('canvaskit/chromium/canvaskit.wasm');
  const p = pcts(t);
  assert.deepEqual(p, [...p].sort((a, b) => a - b));
  assert.equal(p[p.length - 1], 100);
});

test('a file asked for twice by one page is counted once', async () => {
  const t = load({ files: { 'main.dart.js': 1000, 'canvaskit/chromium/canvaskit.js': 100, 'canvaskit/chromium/canvaskit.wasm': 900 } });
  await t.request('main.dart.js');
  await t.request('main.dart.js');
  await t.request('canvaskit/chromium/canvaskit.js');
  await t.request('canvaskit/chromium/canvaskit.wasm');
  assert.deepEqual(last(t), { type: 'pantas-load-progress', loaded: 2000, total: 2000 });
});

test('each page is counted on its own', async () => {
  const t = load({ files: { 'main.dart.js': 1000, 'canvaskit/chromium/canvaskit.js': 100, 'canvaskit/chromium/canvaskit.wasm': 900 } });
  for (const clientId of ['c1', 'c2']) {
    await t.request('main.dart.js', { clientId });
    await t.request('canvaskit/chromium/canvaskit.js', { clientId });
    await t.request('canvaskit/chromium/canvaskit.wasm', { clientId });
  }
  const done = t.posted.filter((m) => m.loaded === m.total);
  assert.equal(done.length, 2);
});

test('a file whose size is not the listed size stops the numbers', async () => {
  const t = load({ files: { 'main.dart.js': 1200, 'canvaskit/chromium/canvaskit.js': 100, 'canvaskit/chromium/canvaskit.wasm': 900 } });
  await t.request('main.dart.js');
  await t.request('canvaskit/chromium/canvaskit.js');
  await t.request('canvaskit/chromium/canvaskit.wasm');
  assert.ok(t.posted.every((m) => m.loaded <= m.total));
  assert.ok(!t.posted.some((m) => m.loaded === m.total), 'it never claims 100%');
});

test('with no size list the worker posts nothing', async () => {
  const t = load({ list: null, files: { 'main.dart.js': 1000 } });
  const { text } = await t.request('main.dart.js');
  assert.equal(text, bytes(1000));
  assert.equal(t.posted.length, 0);
});

test('a size list that is not valid is ignored', async () => {
  for (const bad of [
    { v: 2, files: { 'main.dart.js': 1 } },
    { v: 1, files: { 'main.dart.js': -5 } },
    { v: 1, files: { 'main.dart.js': 'x' } },
    { v: 1, files: {} },
    { v: 1 },
    [],
  ]) {
    const t = load({ list: bad, files: { 'main.dart.js': 1000 } });
    await t.request('main.dart.js');
    assert.equal(t.posted.length, 0, JSON.stringify(bad));
  }
});

test('files outside the list are not counted', async () => {
  const t = load({ files: { 'assets/AssetManifest.bin': 50, 'main.dart.js': 1000, 'canvaskit/chromium/canvaskit.js': 100, 'canvaskit/chromium/canvaskit.wasm': 900 } });
  await t.request('assets/AssetManifest.bin');
  assert.equal(t.posted.length, 0);
  await t.request('main.dart.js');
  await t.request('canvaskit/chromium/canvaskit.js');
  await t.request('canvaskit/chromium/canvaskit.wasm');
  assert.deepEqual(last(t), { type: 'pantas-load-progress', loaded: 2000, total: 2000 });
});

test('a failed or missing page client never breaks the response', async () => {
  const t = load({ clientMissing: true, files: { 'main.dart.js': 1000 } });
  const { text } = await t.request('main.dart.js');
  assert.equal(text, bytes(1000));
  assert.equal(t.posted.length, 0);
});

test('the worker still stores and serves exactly as before', () => {
  assert.match(source, /const PRECACHE = \[/);
  assert.match(source, /async function cacheFirst/);
  assert.match(source, /const NETWORK_FIRST = new Set/);
  assert.ok(!/PRECACHE = \[[^\]]*pantas_load_sizes/.test(source), 'the list is not added to the stored files');
});
