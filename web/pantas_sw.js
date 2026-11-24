// Pantas service worker. It stores the app itself (the page, its scripts,
// fonts, icons, the database worker) so repeat visits start fast and the app
// opens without a connection.
//
// It never touches anything else:
//   * Only GET requests to this site's own origin are handled. Sign-in, the
//     study server, Firebase, payments and every other API live on other
//     origins, so the browser sends them straight to the network. Nothing
//     with user data is ever stored here.
//   * Only the app's own files are stored (see isStaticPath). A path that
//     falls through to the single-page rewrite and returns HTML is not stored.
//   * Requests carrying credentials headers, ranges or `no-store` answers are
//     passed through untouched.
//
// Each build gets its own cache, named by the `v` value in this file's URL
// (set by flutter_bootstrap.js). The page waits for the matching worker
// before it loads the app (see pantas_pwa.js), so scripts of one build are
// never served from another build's cache. Older caches are deleted when a
// new build takes over.

'use strict';

const VERSION = new URL(self.location.href).searchParams.get('v') || 'dev';
const CACHE_PREFIX = 'pantas-shell-';
const CACHE = CACHE_PREFIX + VERSION;
const SCOPE = self.registration.scope;
const NETWORK_TIMEOUT_MS = 4000;
// Decoded size of each file the page loads from this origin before the first
// frame. The build's stamp step writes it (tool/web/stamp_worker_version.mjs);
// null means unstamped, and then the page shows no loading percent.
const LOAD_SIZES = null; // stamped by tool/web/stamp_worker_version.mjs

// Small files the app cannot start without. Fetched fresh when installing.
const PRECACHE = [
  '',
  'flutter_bootstrap.js',
  'pantas_history.js',
  'pantas_pwa.js',
  'pantas_welcome.js',
  'pantas_splash.js',
  'manifest.json',
  'version.json',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
];

// Files that name the current build or list what it contains. They go to the
// network first so a new deploy is seen at once. The stored copy is used only
// when the network fails or is slow.
const NETWORK_FIRST = new Set([
  'flutter_bootstrap.js',
  'flutter.js',
  'pantas_history.js',
  'pantas_pwa.js',
  'pantas_welcome.js',
  'pantas_splash.js',
  'manifest.json',
  'version.json',
  'assets/AssetManifest.bin',
  'assets/AssetManifest.bin.json',
  'assets/FontManifest.json',
]);

// Never handled, even on this origin (Firebase auth handler, shared pages).
const BYPASS_PREFIXES = ['__/', 'wrapped/'];

const STATIC_FILES = new Set([
  'main.dart.js',
  'drift_worker.js',
  'sqlite3.wasm',
  'favicon.png',
  'flutter.js',
]);
const STATIC_PREFIXES = ['assets/', 'canvaskit/', 'icons/'];
const PART_PATTERN = /^main\.dart\.js_\d+\.part\.js$/;

function relativePath(url) {
  const href = url.href;
  return href.startsWith(SCOPE) ? href.slice(SCOPE.length).split('?')[0] : null;
}

function isBypassPath(path) {
  return BYPASS_PREFIXES.some((prefix) => path.startsWith(prefix));
}

function isStaticPath(path) {
  return (
    STATIC_FILES.has(path) ||
    PART_PATTERN.test(path) ||
    STATIC_PREFIXES.some((prefix) => path.startsWith(prefix))
  );
}

// A response is stored only when it is a plain, successful, same-origin file
// that the server did not mark private.
function isStorable(response, { allowHtml = false } = {}) {
  if (!response || response.status !== 200 || response.type !== 'basic') {
    return false;
  }
  const control = (response.headers.get('Cache-Control') || '').toLowerCase();
  if (control.includes('no-store') || control.includes('private')) return false;
  const type = (response.headers.get('Content-Type') || '').toLowerCase();
  if (!allowHtml && type.includes('text/html')) return false;
  return true;
}

self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE);
      const results = await Promise.allSettled(
        PRECACHE.map(async (path) => {
          const request = new Request(SCOPE + path, { cache: 'reload' });
          const response = await fetch(request);
          if (!isStorable(response, { allowHtml: path === '' })) {
            throw new Error('not storable: ' + path);
          }
          await cache.put(request, response);
        })
      );
      // Without the page itself there is nothing to open offline. Try again
      // on the next visit.
      if (results[0].status === 'rejected') throw results[0].reason;
      await self.skipWaiting();
    })()
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const names = await caches.keys();
      await Promise.all(
        names
          .filter((name) => name.startsWith(CACHE_PREFIX) && name !== CACHE)
          .map((name) => caches.delete(name))
      );
      await self.clients.claim();
    })()
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  if (request.headers.has('Authorization') || request.headers.has('Range')) {
    return;
  }
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;
  const path = relativePath(url);
  if (path === null || isBypassPath(path)) return;

  if (request.mode === 'navigate') {
    event.respondWith(navigate(event, request));
    return;
  }
  if (NETWORK_FIRST.has(path)) {
    const served = { cached: false };
    event.respondWith(withProgress(event, path, served, networkFirst(event, request, served)));
    return;
  }
  if (isStaticPath(path)) {
    const served = { cached: false };
    event.respondWith(withProgress(event, path, served, cacheFirst(event, request, path, served)));
  }
});

function withTimeout(promise, ms) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('timeout')), ms);
    promise.then(
      (value) => {
        clearTimeout(timer);
        resolve(value);
      },
      (error) => {
        clearTimeout(timer);
        reject(error);
      }
    );
  });
}

// Pages: always the network when it answers, so a deploy shows at once. When
// offline or slow, the stored page. Every route is the same single page.
async function navigate(event, request) {
  const cache = await caches.open(CACHE);
  const network = fetch(request).then(async (response) => {
    if (isStorable(response, { allowHtml: true })) {
      await cache.put(SCOPE, response.clone());
    }
    return response;
  });
  try {
    return await withTimeout(network, NETWORK_TIMEOUT_MS);
  } catch (_) {
    const stored = await cache.match(SCOPE);
    if (stored) {
      event.waitUntil(network.catch(() => undefined));
      return stored;
    }
    return network;
  }
}

async function networkFirst(event, request, served = {}) {
  const cache = await caches.open(CACHE);
  const network = fetch(request).then(async (response) => {
    if (isStorable(response)) await cache.put(request, response.clone());
    return response;
  });
  try {
    return await withTimeout(network, NETWORK_TIMEOUT_MS);
  } catch (_) {
    const stored = await cache.match(request, { ignoreSearch: true });
    if (stored) {
      served.cached = true;
      event.waitUntil(network.catch(() => undefined));
      return stored;
    }
    return network;
  }
}

async function cacheFirst(event, request, path, served = {}) {
  const cache = await caches.open(CACHE);
  const stored = await cache.match(request);
  if (stored) {
    served.cached = true;
    return stored;
  }
  const response = await fetch(request);
  if (isStorable(response)) {
    event.waitUntil(cache.put(request, response.clone()));
    if (path === 'main.dart.js') event.waitUntil(warmDeferredParts(cache, response.clone()));
  }
  return response;
}

// The app loads some screens later from numbered part files that main.dart.js
// names. Fetching them now lets those screens open offline on the first
// visit as well.
async function warmDeferredParts(cache, response) {
  try {
    const text = await response.text();
    const names = new Set(text.match(/main\.dart\.js_\d+\.part\.js/g) || []);
    await Promise.allSettled(
      [...names].map(async (name) => {
        const request = new Request(SCOPE + name);
        if (await cache.match(request)) return;
        const part = await fetch(request);
        if (isStorable(part)) await cache.put(request, part);
      })
    );
  } catch (_) {}
}

// ---- Loading progress (board A, Nov 25) -------------------------------------
// The page shows a percent while the app's first files arrive. LOAD_SIZES is the
// fixed list of those files and their decoded sizes, so the total is known
// before the first byte. The worker reads no file and no cache for it.
//
// A listed file served from the cache is returned untouched (its compiled-code
// cache must survive) and counts as received at once. A listed file from the
// network has its body passed through a counter, so progress is bytes delivered
// to the page. Nothing is cloned, nothing waits and no worker task is held open.
// 100% (done) is posted only when every listed file has ended at exactly its
// listed size. A wrong size, a failed request or an error stream posts a stop:
// the page hides the number and shows the spinner only.

const SIZES = readSizes(LOAD_SIZES);
const MAX_LOADS = 20;
const loads = new Map();

function readSizes(list) {
  if (!list || typeof list !== 'object' || Array.isArray(list)) return null;
  const files = new Map();
  let total = 0;
  for (const [name, size] of Object.entries(list)) {
    if (!Number.isInteger(size) || size <= 0) return null;
    files.set(name, size);
    total += size;
  }
  return files.size > 0 ? { files, total } : null;
}

// Decided before any await: whether this request is counted at all.
function pageLoad(event, path) {
  if (!SIZES || !event.clientId || !SIZES.files.has(path)) return null;
  let load = loads.get(event.clientId);
  if (!load) {
    load = {
      seen: new Set(),
      ended: new Set(),
      delivered: 0,
      lastPct: -1,
      broken: false,
      client: self.clients.get(event.clientId).catch(() => null),
    };
    loads.set(event.clientId, load);
    if (loads.size > MAX_LOADS) loads.delete(loads.keys().next().value);
  }
  if (load.seen.has(path) || load.broken) return null;
  load.seen.add(path);
  return load;
}

function post(load, message) {
  load.client.then((client) => {
    try {
      if (client) client.postMessage({ type: 'pantas-load-progress', ...message });
    } catch (_) {}
  });
}

function fail(load) {
  if (load.broken) return;
  load.broken = true;
  post(load, { stop: true });
}

function report(load) {
  if (load.broken) return;
  const pct = Math.min(99, Math.floor((load.delivered * 100) / SIZES.total));
  if (pct <= load.lastPct) return;
  load.lastPct = pct;
  post(load, { loaded: load.delivered, total: SIZES.total, done: false });
}

// A file ended at exactly its listed size.
function ended(load, path) {
  if (load.broken) return;
  load.ended.add(path);
  if (load.ended.size === SIZES.files.size) {
    load.lastPct = 100;
    post(load, { loaded: SIZES.total, total: SIZES.total, done: true });
  } else {
    report(load);
  }
}

function countBody(load, path, body) {
  const size = SIZES.files.get(path);
  let received = 0;
  const counter = new TransformStream({
    transform(chunk, controller) {
      controller.enqueue(chunk);
      received += chunk.byteLength;
      if (received > size) return fail(load);
      if (load.broken) return;
      load.delivered += chunk.byteLength;
      report(load);
    },
    flush() {
      if (received !== size) return fail(load);
      ended(load, path);
    },
  });
  // An error or a cancel on either side ends the numbers for this page load.
  body.pipeTo(counter.writable).catch(() => fail(load));
  return counter.readable;
}

// Passes the answer to the page. Unlisted files come back as the same promise,
// with no extra wait.
function withProgress(event, path, served, pending) {
  const load = pageLoad(event, path);
  if (!load) return pending;
  return pending.then(
    (response) => {
      if (!response || response.status !== 200) {
        fail(load);
        return response;
      }
      if (served.cached) {
        load.delivered += SIZES.files.get(path);
        ended(load, path);
        return response;
      }
      if (!response.body) {
        fail(load);
        return response;
      }
      return new Response(countBody(load, path, response.body), {
        status: response.status,
        statusText: response.statusText,
        headers: response.headers,
      });
    },
    (error) => {
      fail(load);
      throw error;
    }
  );
}
