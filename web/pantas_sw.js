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
// constant after `flutter build web`): the build's files live in b/<id>/ and the
// page names them, so a page can only ever run the files of its own build. The
// constant holds the build id and the SHA-256 of every file in the startup set.
// Install fetches the set, checks every hash, and stores it in this build's cache.
// Files in the set are served from that cache only, online or offline; nothing
// outside the set is ever stored. A new build reaches a page through a new worker.
//
// Wait, then sweep (revision 2). A worker that has stored its whole set normally
// waits: the browser activates it only when no Pantas tab is open, so no page can
// then run an older build. Only two cases take over at once (skipWaiting): the first
// install and the move from the worker that shipped before build folders (no other
// build cache exists), and the Update Required button (the page asks a waiting worker
// to take over). A reload alone never updates a page.
//
// Caches. The worker serves any b/<id>/ file from whichever build cache holds it (the
// address carries the build), so a page keeps working on its own build while a newer
// one waits. Install deletes nothing. A worker deletes other caches only in an
// activation that did not follow skipWaiting (so no page runs an older build), only when
// the registration has no installing or waiting worker, and then keeps only its own
// build cache. A worker that took over marks its own cache and deletes nothing; the next
// natural activation sweeps. One Web Lock is held by install while it writes its cache and
// by the sweep while it deletes; without the Web Locks API, or when the lock is not had
// within a time limit, the sweep does not run and the install goes on without it (and
// checks afterwards that nothing it wrote was deleted). While the worker that shipped before
// build folders has tabs, its caches stay: its root deferred parts are served from them, and
// only from them, to tabs that still run that build. A root file is never answered with
// another build's bytes.
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
// The list's own hash is part of the name, so a cache can never stand in for a
// build whose list differs, even under the same id.
const CACHE = BUILD ? 'pantas-build-' + BUILD.id + '-' + BUILD.list : CACHE_PREFIX + VERSION;
// Written last, with the list's hash, so a cache that has it holds this whole list.
const COMPLETE = 'pantas-build-complete';
// Written into a build's own cache before its worker calls skipWaiting, so the activation
// that follows knows it must not sweep (a page may still run an older build). A worker's
// global scope does not survive from install to activation, so the fact lives in the cache.
const TAKEOVER = 'pantas-build-takeover';
// The one Web Lock, held by install while it writes its cache and by the sweep while it
// deletes. A request that is not granted within this time is given up, never waited on.
const LOCK = 'pantas-cache-lock';
const LOCK_WAIT_MS = 10000;
// The notes cache of the previous design of this branch: swept like any other cache of ours.
const NOTES_CACHE = 'pantas-meta';
const BUILD_PREFIX = 'pantas-build-';
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

self.addEventListener('message', (event) => {
  if (!BUILD || !event.data) return;
  const reply = (message) => {
    try {
      const port = event.ports && event.ports[0];
      if (port) port.postMessage(message);
    } catch (_) {}
  };
  if (event.data.type === 'pantas-build-id') reply({ id: BUILD.id });
  if (event.data.type === 'pantas-take-over') event.waitUntil(takeOverOnRequest(reply));
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

// Every file of the set. Of CanvasKit only the full variant is in it: the bootstrap
// pins that variant in every browser (Flutter's own choice rests on checks a service
// worker cannot make, such as ImageDecoder), so nothing else is ever asked for.

// Files in a build folder never change under their address, and the hash guards
// them, so any cached copy will do. So do the Firebase SDK files: their address carries
// the SDK version and every build shares them, so an update need not download them again.
// The few other files at the root are read past every HTTP cache.
const SDK_FOLDER = 'firebase_sdk/';

function sourceRequest(path) {
  return path.startsWith(BUILD.base) || path.startsWith(SDK_FOLDER)
    ? new Request(SCOPE + path)
    : new Request(SCOPE + path, { cache: 'reload' });
}

function isUncacheable(headers) {
  const control = (headers.get('Cache-Control') || '').toLowerCase();
  return control.includes('no-store') || control.includes('private');
}

// One file of the set, checked against the list. A response the server marked
// private or no-store, or any other bytes, fails the install.
async function fetchVerified(path) {
  const response = await fetch(sourceRequest(path));
  if (response.status !== 200 || response.type !== 'basic') {
    throw new Error('not available: ' + path);
  }
  if (isUncacheable(response.headers)) throw new Error('not cacheable: ' + path);
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

// The build id another worker of this registration reports, or null when it is not a stamped
// worker (the one that shipped before build folders does not answer) or does not answer in time.
function buildIdOf(other, waitMs = 2000) {
  return new Promise((resolve) => {
    let channel = null;
    const finish = (id) => {
      clearTimeout(timer);
      try {
        if (channel) channel.port1.close();
      } catch (_) {}
      resolve(id);
    };
    const timer = setTimeout(() => finish(null), waitMs);
    try {
      channel = new MessageChannel();
      channel.port1.onmessage = (event) => finish((event.data && event.data.id) || null);
      other.postMessage({ type: 'pantas-build-id' }, [channel.port2]);
    } catch (_) {
      finish(null);
    }
  });
}

// True when the worker is today's legacy worker (the one that shipped before build folders).
// The signal is its cache name: that worker names its cache from its own ?v= address
// (CACHE_PREFIX + version), and a stamped worker never makes such a cache. Its lack of a
// build-id reply is not the signal: a stamped worker that answers slowly looks the same.
async function isLegacyWorker(other) {
  try {
    const version = new URL(other.scriptURL).searchParams.get('v') || 'dev';
    return await caches.has(CACHE_PREFIX + version);
  } catch (_) {
    return false;
  }
}

// True when another worker of the registration is this build. A worker that gives no reply is
// asked once more with a longer wait, so a slow stamped worker is not mistaken for another
// build. One that still gives none (the legacy worker, including one whose cache was evicted)
// counts as a different build: the install goes on and waits for a natural activation. It
// never takes over: takeover is only for a worker positively identified as legacy by its cache
// name (mayTakeOverAtInstall) and for Update Required.
// Residual limit: a stamped worker that never answers is treated as a different build, and its
// replacement waits until every tab is closed.
async function sameBuildInCharge() {
  const registration = self.registration;
  for (const other of [registration.active, registration.waiting]) {
    if (!other) continue;
    if (other === registration.active && (await isLegacyWorker(other))) continue;
    const id = (await buildIdOf(other)) ?? (await buildIdOf(other, 10000));
    if (id === BUILD.id) return true;
  }
  return false;
}

// True when this build's cache holds its whole list (the marker is written last).
async function isCompleteCache() {
  if (!(await caches.has(CACHE))) return false;
  const marker = await (await caches.open(CACHE)).match(SCOPE + COMPLETE);
  return !!marker && (await marker.text()) === BUILD.list;
}

// Runs `work` holding the lock. Resolves {held: true, value}, or {held: false} when the
// browser has no Web Locks API or the lock was not granted within LOCK_WAIT_MS. It never
// waits without a limit, and never throws for a lock that could not be had.
async function withLock(work) {
  const locks = self.navigator && self.navigator.locks;
  if (!locks || typeof locks.request !== 'function' || typeof AbortController !== 'function') return { held: false };
  const abort = new AbortController();
  const timer = setTimeout(() => abort.abort(), LOCK_WAIT_MS);
  try {
    const value = await locks.request(LOCK, { signal: abort.signal }, async () => {
      clearTimeout(timer);
      return work();
    });
    return { held: true, value };
  } catch (error) {
    if (error && error.name === 'AbortError') return { held: false };
    throw error;
  } finally {
    clearTimeout(timer);
  }
}

function hasLocks() {
  const locks = self.navigator && self.navigator.locks;
  return !!locks && typeof locks.request === 'function' && typeof AbortController === 'function';
}

async function fetchPaths(paths) {
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
  return verified;
}

// Writes the files given, then the marker last. A failure removes the cache and throws.
async function storeFiles(files) {
  try {
    const cache = await caches.open(CACHE);
    for (const { path, bytes, headers } of files) {
      await cache.put(SCOPE + path, new Response(bytes, { status: 200, headers }));
    }
    await cache.put(SCOPE + COMPLETE, new Response(BUILD.list));
  } catch (error) {
    await caches.delete(CACHE);
    throw error;
  }
}

// The files of this build's list its cache lacks (all of them when the cache is gone).
async function missingPaths() {
  const paths = Object.keys(BUILD.files);
  if (!(await caches.has(CACHE))) return paths;
  const cache = await caches.open(CACHE);
  const have = new Set((await cache.keys()).map((request) => request.url));
  return paths.filter((path) => !have.has(SCOPE + path));
}

// Checks the reusable cache, fills what it lacks and verifies it is whole. With the lock held
// this cannot race a sweep; without Web Locks no sweep exists. Either way a cache that is not
// whole after a few rounds fails the install.
async function fillCache() {
  if (await isCompleteCache()) {
    // An identical build installing again: an old takeover mark is not about this install.
    await clearTakeoverMark();
  } else if (await caches.has(CACHE)) {
    await caches.delete(CACHE); // left by an install that did not finish
  }
  for (let round = 0; round < 3; round++) {
    const lacking = await missingPaths();
    if (!lacking.length && (await isCompleteCache())) return;
    await storeFiles(await fetchPaths(lacking));
  }
  if ((await missingPaths()).length || !(await isCompleteCache())) throw new Error('the cache of this build is not whole');
}

// Stores the whole set or nothing. A failure throws, so the browser keeps the
// worker it has and tries again at the next update check.
async function installBuild() {
  // The page registers the worker under an address that carries its build, so a page of the
  // build already in charge registers a duplicate of it. Refusing it keeps the active worker
  // in charge and leaves no waiting worker to replace it at the next reload. A different build
  // (an update, or a rollback) goes on. Nothing is deleted here.
  if (await sameBuildInCharge()) throw new Error('this build is already installed: ' + BUILD.id);
  // The cache is written, and the takeover mark with it, under the lock (a sweep may be deleting).
  let mark = false;
  const fillAndMark = async () => {
    await fillCache();
    mark = (await mayTakeOverAtInstall()) && (await markTakeover());
  };
  if (hasLocks()) {
    // Never write or reuse a cache without the lock. A lock that is not granted in time fails the
    // install, and the browser tries again at its next update check.
    const locked = await withLock(fillAndMark);
    if (!locked.held) throw new Error('the cache lock was not available: the install will be tried again');
  } else {
    await fillAndMark();
  }
  if (mark) await self.skipWaiting();
}

// Take over at once only when nothing can be mixed: no other build cache exists, and the worker
// in charge is either absent (first visit) or the legacy worker that shipped before build
// folders. Otherwise wait: the browser activates this worker when no Pantas tab is open. A
// missing cache of a stamped worker in charge is no reason to take over.
async function mayTakeOverAtInstall() {
  const others = (await caches.keys()).filter((name) => name.startsWith(BUILD_PREFIX) && name !== CACHE);
  if (others.length) return false;
  const active = self.registration.active;
  return !active || (await isLegacyWorker(active));
}

async function clearTakeoverMark() {
  if (await caches.has(CACHE)) await (await caches.open(CACHE)).delete(SCOPE + TAKEOVER);
}

// Marks this build's cache. The mark comes before skipWaiting so the activation that follows,
// possibly in a fresh worker scope, knows it followed a takeover and sweeps nothing. The caller
// holds the lock (or the browser has no Web Locks).
async function markTakeover() {
  if (!(await caches.has(CACHE))) return false;
  await (await caches.open(CACHE)).put(SCOPE + TAKEOVER, new Response('1'));
  return true;
}

// Update Required: marks under the lock, then skips waiting. When the lock is not had in time
// nothing is written and the worker does not take over; the page can ask again.
async function takeOver() {
  const marked = hasLocks() ? !!(await withLock(markTakeover)).value : await markTakeover();
  if (!marked) return false;
  await self.skipWaiting();
  return true;
}

// The Update Required button's request: the minimum-build gate leaves the page unusable, so
// the waiting worker takes over now, whatever other windows are open. They keep their own
// build from the retained caches, and nothing is deleted here.
async function takeOverOnRequest(reply) {
  reply({ ok: await takeOver() });
}

async function tookOver() {
  if (!(await caches.has(CACHE))) return false;
  return !!(await (await caches.open(CACHE)).match(SCOPE + TAKEOVER));
}

function registrationBusy() {
  const registration = self.registration;
  return !!(registration.installing || registration.waiting);
}

// Deletes every cache of ours but this build's. Only under the lock (never without it), only
// when no other worker is installing or waiting (checked again under the lock), and only when
// this build's own cache is whole, so a sweep never leaves a page with nothing.
async function sweep() {
  if (registrationBusy()) return;
  await withLock(async () => {
    if (registrationBusy() || !(await isCompleteCache())) return;
    for (const name of await caches.keys()) {
      const ours = name.startsWith(BUILD_PREFIX) || name.startsWith(CACHE_PREFIX) || name === NOTES_CACHE;
      if (!ours || name === CACHE) continue;
      // Read again before every delete: a worker may have started to install since the last one.
      // If one has, whatever build it is, the sweep stops and deletes nothing more.
      if (registrationBusy()) return;
      await caches.delete(name);
    }
  });
}

// A natural activation (the browser had no tab for an older worker to serve) sweeps. An
// activation that follows a takeover deletes nothing: a window may run an older build.
async function activateBuild() {
  try {
    if (!(await tookOver())) await sweep();
  } catch (_) {
    // A sweep that fails leaves caches for the next one; it never stops the activation.
  }
  await self.clients.claim();
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
    event.respondWith(fromBuild(event, request, ''));
    return;
  }
  if (hasOwn(path)) {
    const served = { cached: false };
    event.respondWith(withProgress(event, path, served, fromBuild(event, request, path, served)));
    return;
  }
  // A window still on another build, or on the build that shipped before build
  // folders, asks for files that are not in this build's set.
  const folder = /^b\/([^/]+)\//.exec(path);
  if (folder && folder[1] !== BUILD.id) {
    event.respondWith(fromKeptCaches(request, path, BUILD_PREFIX + folder[1] + '-'));
  } else if (path.startsWith(SDK_FOLDER)) {
    // A Firebase SDK file of another version than this build's: the address names the SDK
    // version and every build pins those bytes, so the cache of the build whose page asks holds
    // exactly them. Not stored in the build folder because the page's import map (an inline script
    // under the security policy's hash) cannot change with the build. Never the network.
    event.respondWith(fromKeptCaches(request, path, BUILD_PREFIX, false));
  } else if (!folder && PART_PATTERN.test(path)) {
    // Only a page of the build that shipped before build folders asks for a deferred part at
    // the root, and the edge may by now serve another build's file at that address.
    event.respondWith(fromKeptCaches(request, path, CACHE_PREFIX, false));
  }
}

// The file from a kept cache of an older build (the address names the build, so
// its bytes are that build's). Then, when `network` is true, the network, else the
// secured 503. A root address does not name its build, so it never goes to the network:
// a miss there is the 503, and the page reloads into a build it can run.
async function fromKeptCaches(request, path, prefix, network = true) {
  for (const name of await caches.keys()) {
    if (!name.startsWith(prefix)) continue;
    const stored = await (await caches.open(name)).match(SCOPE + path);
    if (stored) return stored;
  }
  if (!network) return unavailable();
  try {
    return await fetch(request);
  } catch (_) {
    return unavailable();
  }
}

// What the edge sends with every file, so the worker's own answer is as safe.
const FAILURE_HEADERS = {
  'Cache-Control': 'no-store',
  'Content-Type': 'text/plain; charset=utf-8',
  'Content-Security-Policy': "frame-ancestors 'self'",
  'X-Content-Type-Options': 'nosniff',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  'Permissions-Policy': 'camera=(), microphone=(), geolocation=(), payment=(), usb=()',
};

function unavailable() {
  return new Response('The app changed. Reload this page.', { status: 503, headers: FAILURE_HEADERS });
}

async function fromBuild(event, request, path, served = {}) {
  const cache = await caches.open(CACHE);
  const stored = await cache.match(SCOPE + path);
  if (stored) {
    served.cached = true;
    return stored;
  }
  // Not stored: a file lost from the cache. Answer from the network only when the
  // bytes are this build's, and keep them for next time. A network that fails gets
  // the same secured answer as bytes that do not match.
  let response;
  try {
    response = await fetch(sourceRequest(path));
  } catch (_) {
    return unavailable();
  }
  if (response.status !== 200 || response.type !== 'basic') return unavailable();
  const bytes = await response.arrayBuffer();
  if ((await sha256(bytes)) !== BUILD.files[path]) return unavailable();
  const headers = storedHeaders(response.headers);
  if (!isUncacheable(response.headers)) {
    event.waitUntil(cache.put(SCOPE + path, new Response(bytes, { status: 200, headers })).catch(() => undefined));
  }
  return new Response(bytes, { status: 200, headers });
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
  if (!event.clientId || !(path === PROGRESS_PATH || (BUILD && path === BUILD.base + PROGRESS_PATH))) return null;
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
