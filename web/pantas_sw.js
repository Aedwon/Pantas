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
//
// A cache holds only its own build's files. Before any file is stored, the
// worker asks the network for version.json and stores the file only if that
// still names this build (the file was fetched before the check, so a match
// means no newer deploy had happened yet). Without this, a worker that still
// controls the page after a deploy stored the new build's shell next to its
// own Dart files, and offline it served the two together.

'use strict';

const VERSION = new URL(self.location.href).searchParams.get('v') || 'dev';
const CACHE_PREFIX = 'pantas-shell-';
const CACHE = CACHE_PREFIX + VERSION;
const SCOPE = self.registration.scope;
const NETWORK_TIMEOUT_MS = 4000;

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

// True when a version.json response names this worker's build. An unstamped
// local build ('dev') has no name to compare.
async function namesThisBuild(response) {
  if (VERSION === 'dev') return true;
  if (!response || response.status !== 200) return false;
  try {
    return (await response.json()).pantasBuildVersion === VERSION;
  } catch (_) {
    return false;
  }
}

// True when the network still serves this worker's build. Call it after the
// file to store was fetched.
async function buildIsCurrent() {
  if (VERSION === 'dev') return true;
  try {
    const request = new Request(SCOPE + 'version.json', { cache: 'no-store' });
    return await namesThisBuild(await withTimeout(fetch(request), NETWORK_TIMEOUT_MS));
  } catch (_) {
    return false;
  }
}

// Stores a copy only if the file is from this worker's build.
async function putIfCurrent(cache, request, response, path) {
  const same = path === 'version.json' ? await namesThisBuild(response.clone()) : await buildIsCurrent();
  if (same) await cache.put(request, response);
}

self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      const fetched = await Promise.allSettled(
        PRECACHE.map(async (path) => {
          const request = new Request(SCOPE + path, { cache: 'reload' });
          const response = await fetch(request);
          if (!isStorable(response, { allowHtml: path === '' })) {
            throw new Error('not storable: ' + path);
          }
          return [request, response];
        })
      );
      // Without the page itself there is nothing to open offline. Try again
      // on the next visit.
      if (fetched[0].status === 'rejected') throw fetched[0].reason;
      // A deploy during the install would leave files of two builds. Refuse.
      if (!(await buildIsCurrent())) throw new Error('build changed during install');
      const cache = await caches.open(CACHE);
      for (const result of fetched) {
        if (result.status === 'fulfilled') await cache.put(...result.value);
      }
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
    event.respondWith(networkFirst(event, request));
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
      event.waitUntil(putIfCurrent(cache, SCOPE, response.clone(), ''));
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

async function networkFirst(event, request) {
  const cache = await caches.open(CACHE);
  const network = fetch(request).then(async (response) => {
    if (isStorable(response)) {
      event.waitUntil(putIfCurrent(cache, request, response.clone(), relativePath(new URL(request.url))));
    }
    return response;
  });
  try {
    return await withTimeout(network, NETWORK_TIMEOUT_MS);
  } catch (_) {
    const stored = await cache.match(request, { ignoreSearch: true });
    if (stored) {
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
    event.waitUntil(putIfCurrent(cache, request, response.clone(), path));
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
    const parts = [];
    await Promise.allSettled(
      [...names].map(async (name) => {
        const request = new Request(SCOPE + name);
        if (await cache.match(request)) return;
        const part = await fetch(request);
        if (isStorable(part)) parts.push([request, part]);
      })
    );
    if (parts.length && (await buildIsCurrent())) {
      for (const [request, part] of parts) await cache.put(request, part);
    }
  } catch (_) {}
}

// ---- Loading progress (board A, Nov 25) -------------------------------------
// The page shows a percent while main.dart.js, the biggest file, arrives. This
// worker knows no sizes, and its bytes never depend on the build. For the
// network response it passes the body through a counter and posts the true
// bytes delivered to the page, then done at the end of the stream, or stop on an
// error. The page holds the total the build stamped and decides what to show.
// A cache hit is returned as the same stored response and only posts "cached".
//
// A rebuilt response skips Chromium's HTTP code cache. That only affects the
// first load after an update, which has no code cache yet, and the first load
// after an assets-only deploy, which also misses Cache Storage and so recompiles
// once. Later loads come from Cache Storage, untouched. Nothing is cloned, nothing waits and no worker task
// is held open for progress.

const PROGRESS_PATH = 'main.dart.js';
const PROGRESS_MS = 100;
const MAX_LOADS = 20;
const loads = new Map();

// Decided before any await: whether this request is counted at all.
function pageLoad(event, path) {
  if (path !== PROGRESS_PATH || !event.clientId) return null;
  let load = loads.get(event.clientId);
  if (load) return null;
  load = {
    broken: false,
    client: self.clients.get(event.clientId).catch(() => null),
  };
  loads.set(event.clientId, load);
  if (loads.size > MAX_LOADS) loads.delete(loads.keys().next().value);
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

function countBody(load, body) {
  let loaded = 0;
  let postedAt = -Infinity;
  const counter = new TransformStream({
    transform(chunk, controller) {
      controller.enqueue(chunk);
      loaded += chunk.byteLength;
      // At most one progress message per 100 ms; done and stop are never held back.
      if (load.broken || Date.now() - postedAt < PROGRESS_MS) return;
      postedAt = Date.now();
      post(load, { loaded });
    },
    flush() {
      if (!load.broken) post(load, { loaded, done: true });
    },
  });
  // An error or a cancel on either side ends the numbers for this page load.
  body.pipeTo(counter.writable).catch(() => fail(load));
  return counter.readable;
}

// Passes the answer to the page. Other files come back as the same promise,
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
        post(load, { cached: true });
        return response;
      }
      if (!response.body) {
        fail(load);
        return response;
      }
      return new Response(countBody(load, response.body), {
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
