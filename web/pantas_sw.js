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
// Two modes, told apart by the build constant below.
//
// Stamped (every release build; tool/web/stamp_worker_version.mjs writes the
// constant after `flutter build web`): the constant holds this build's id and the
// SHA-256 of every file in the startup set. Install fetches the whole set from the
// network, checks every hash, stores it in this build's cache, and only then takes
// over. Activate deletes every other Pantas cache. Files in the set are served
// from this build's cache only, online or offline, so a page never boots one
// build's shell with another build's Dart code. Nothing outside the set is stored.
// A new build reaches the page through a new worker, which carries its own list.
//
// Unstamped (dev, where the constant is null): the older network-first and
// cache-first behavior below, kept so a local run needs no stamp. Release scripts
// refuse an unstamped worker (tool/deploy/check_worker_stamp.mjs).

'use strict';

const BUILD = /*pantas-build*/ null /*end-pantas-build*/;
const VERSION = new URL(self.location.href).searchParams.get('v') || 'dev';
const CACHE_PREFIX = 'pantas-shell-';
// The stamped id, not the URL, names the cache: the browser may run this build's
// bytes under another build's URL when it checks for an update. Stamped caches use
// their own prefix, so today's production worker, which names its cache from the
// URL, can never fill or reuse one after a rollback to a build that still has it.
const CACHE = BUILD ? 'pantas-build-' + BUILD.id : CACHE_PREFIX + VERSION;
// Written last, so a cache that has it holds the whole verified set.
const COMPLETE = 'pantas-build-complete';
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

self.addEventListener('install', (event) => {
  if (BUILD) {
    event.waitUntil(installBuild());
    return;
  }
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
  if (BUILD) {
    event.waitUntil(activateBuild());
    return;
  }
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

  if (BUILD) {
    handleBuild(event, request, path);
    return;
  }
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

// ---- Stamped mode ------------------------------------------------------------

async function sha256(bytes) {
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, '0')).join('');
}

const INSTALL_PARALLEL = 6;

// One file of the set, fetched past every HTTP cache and checked against the
// list. Anything else fails the install.
async function fetchVerified(path) {
  const response = await fetch(new Request(SCOPE + path, { cache: 'reload' }));
  if (response.status !== 200 || response.type !== 'basic') {
    throw new Error('not available: ' + path);
  }
  const bytes = await response.arrayBuffer();
  if ((await sha256(bytes)) !== BUILD.files[path]) throw new Error('hash mismatch: ' + path);
  return { path, bytes, headers: storedHeaders(response.headers) };
}

// The stored copy keeps the edge's headers (security policy, content type,
// nosniff), minus the ones that describe the wire and not the stored bytes.
function storedHeaders(source) {
  const headers = new Headers(source);
  for (const name of ['Content-Length', 'Content-Encoding', 'Transfer-Encoding', 'Set-Cookie']) {
    headers.delete(name);
  }
  return headers;
}

// Stores the whole set or nothing, and takes over only after that. A failure
// throws, so the browser keeps the worker it has and tries again at the next
// update check.
async function installBuild() {
  if (await caches.has(CACHE)) {
    const existing = await caches.open(CACHE);
    if (await existing.match(SCOPE + COMPLETE)) {
      await self.skipWaiting();
      return;
    }
    await caches.delete(CACHE); // left by an install that did not finish
  }
  const paths = Object.keys(BUILD.files);
  const verified = [];
  let next = 0;
  let failed = false;
  const lane = async () => {
    while (!failed && next < paths.length) {
      const path = paths[next++];
      try {
        verified.push(await fetchVerified(path));
      } catch (error) {
        failed = true;
        throw error;
      }
    }
  };
  await Promise.all(Array.from({ length: Math.min(INSTALL_PARALLEL, paths.length) }, lane));
  try {
    const cache = await caches.open(CACHE);
    for (const { path, bytes, headers } of verified) {
      await cache.put(SCOPE + path, new Response(bytes, { status: 200, headers }));
    }
    await cache.put(SCOPE + COMPLETE, new Response('1'));
  } catch (error) {
    await caches.delete(CACHE);
    throw error;
  }
  await self.skipWaiting();
}

async function activateBuild() {
  await self.clients.claim();
  const names = await caches.keys();
  await Promise.all(
    names.filter((name) => name.startsWith('pantas-') && name !== CACHE).map((name) => caches.delete(name))
  );
}

function hasOwn(path) {
  return Object.prototype.hasOwnProperty.call(BUILD.files, path);
}

// Files in the set come from this build's cache. Everything else is left to the
// network, untouched and unstored (version.json among them).
function handleBuild(event, request, path) {
  const page =
    request.mode === 'navigate' &&
    (path === '' || path === 'index.html' || !/\.[A-Za-z0-9]+$/.test(path));
  if (page) {
    event.respondWith(fromBuild(request, ''));
    return;
  }
  if (!hasOwn(path)) return;
  const served = { cached: false };
  event.respondWith(withProgress(event, path, served, fromBuild(request, path, served)));
}

async function fromBuild(request, path, served = {}) {
  const cache = await caches.open(CACHE);
  const stored = await cache.match(SCOPE + path);
  if (stored) {
    served.cached = true;
    return stored;
  }
  // Not expected after a finished install. Answer from the network only when the
  // bytes are this build's, and store nothing.
  const response = await fetch(new Request(SCOPE + path, { cache: 'reload' }));
  if (
    response.status === 200 &&
    response.type === 'basic' &&
    (await sha256(await response.clone().arrayBuffer())) === BUILD.files[path]
  ) {
    return response;
  }
  return new Response('The app changed. Reload this page.', {
    status: 503,
    headers: { 'Cache-Control': 'no-store' },
  });
}

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

async function networkFirst(event, request) {
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
