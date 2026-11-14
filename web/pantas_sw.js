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
// never served from another build's cache. Live pages identify their build;
// cleanup keeps every live build, and keeps all caches if a page is unknown.

'use strict';

// Stamped into the deployed worker: an automatic update of an old ?v= URL
// must never populate that old build's cache with the new deployment.
const STAMPED_VERSION = '';
const SHELL_FILES = [];
const SHELL_HASHES = {};
const VERSION = STAMPED_VERSION || new URL(self.location.href).searchParams.get('v') || 'dev';
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

// Build files must come from the running page's cache. Bootstrap is fetched
// fresh only at page startup; explicit version checks bypass the shell.
const BUILD_FILES = new Set([
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

async function matchesBuild(path, response) {
  const expected = SHELL_HASHES[path === '' ? 'index.html' : path];
  if (!expected) return !STAMPED_VERSION;
  const digest = await crypto.subtle.digest('SHA-256', await response.clone().arrayBuffer());
  const actual = Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, '0')).join('');
  return actual === expected;
}

self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      if (STAMPED_VERSION) {
        const metadata = await fetch(new Request(SCOPE + 'version.json', { cache: 'no-store' }));
        if (!metadata.ok || (await metadata.json()).pantasBuildVersion !== VERSION) {
          throw new Error('Deployment changed during installation');
        }
      }
      const cache = await caches.open(CACHE);
      const results = await Promise.allSettled(
        [...new Set([...PRECACHE, ...SHELL_FILES])].map(async (path) => {
          const request = new Request(SCOPE + path, { cache: 'reload' });
          const existing = await cache.match(request);
          if (existing && await matchesBuild(path, existing)) return;
          const response = await fetch(request);
          if (!await matchesBuild(path, response)) throw new Error('Build file changed: ' + path);
          if (!isStorable(response, { allowHtml: path === '' || path === 'index.html' })) {
            throw new Error('not storable: ' + path);
          }
          await cache.put(request, response);
        })
      );
      // A complete build is required before apply can activate it. Missing
      // deferred parts must not be fetched from a later deployment.
      const failed = results.find((result) => result.status === 'rejected');
      if (failed) throw failed.reason;
      // Updates wait until the app explicitly reaches a safe point.
    })()
  );
});

// Ask the page rather than the controller: another tab may have applied an
// update while this page is still finishing a session on its original build.
function clientVersion(client) {
  if (!client) return Promise.resolve(null);
  return new Promise((resolve) => {
    const channel = new MessageChannel();
    const finish = (version) => {
      clearTimeout(timer);
      channel.port1.close();
      resolve(typeof version === 'string' && version ? version : null);
    };
    const timer = setTimeout(() => finish(null), 1000);
    channel.port1.onmessage = (event) => finish(event.data && event.data.version);
    client.postMessage({ type: 'PANTAS_VERSION' }, [channel.port2]);
  });
}

async function cleanupCaches() {
  // A worker can have a stamped identity different from its registration URL.
  // Do not guess which cache belongs to an in-progress update.
  if (self.registration.installing || self.registration.waiting) return;
  const clients = await self.clients.matchAll({ includeUncontrolled: true });
  const versions = await Promise.all(clients.map((client) => {
    const tagged = client.url && new URL(client.url).searchParams.get('pantas_build');
    return tagged || clientVersion(client);
  }));
  // Legacy pages and suspended pages may not answer. Storage is cheaper than
  // losing a running session. Try again on the next fetch or activation.
  if (versions.includes(null)) return;
  const keep = new Set([CACHE, ...versions.map((v) => CACHE_PREFIX + v)]);
  // A different tab may currently be installing or applying another build.
  for (const worker of [self.registration.active, self.registration.waiting, self.registration.installing]) {
    if (worker) keep.add(CACHE_PREFIX + new URL(worker.scriptURL).searchParams.get('v'));
  }
  const names = await caches.keys();
  if (self.registration.installing || self.registration.waiting) return;
  await Promise.all(names.filter((name) => name.startsWith(CACHE_PREFIX) && !keep.has(name))
    .map((name) => caches.delete(name)));
}

self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    event.waitUntil(self.skipWaiting());
  }
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    await cleanupCaches();
    await self.clients.claim();
  })());
});

async function cacheForEvent(event) {
  const client = event.clientId ? await self.clients.get(event.clientId) : null;
  const tagged = client && client.url ? new URL(client.url).searchParams.get('pantas_build') : null;
  const version = tagged || await clientVersion(client);
  if (version) return caches.open(CACHE_PREFIX + version);
  // A pre-upgrade page cannot report its version. With one retained build it
  // is unambiguous; otherwise fail closed rather than mix script versions.
  if (client) {
    const older = (await caches.keys()).filter((name) => name.startsWith(CACHE_PREFIX) && name !== CACHE);
    if (older.length === 1) return caches.open(older[0]);
    if (older.length > 1) throw new Error('Unknown running build');
  }
  return caches.open(CACHE);
}

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
  if (path === 'version.json' && request.cache === 'no-store') return;
  // These helpers run only while opening a page. A running session requests
  // assets and manifests through its own cache below.
  if (BUILD_FILES.has(path) && !path.startsWith('assets/') && path !== 'version.json') {
    event.respondWith(bootstrap(request));
    return;
  }
  if (BUILD_FILES.has(path)) {
    event.respondWith(cacheFirst(event, request, path));
    return;
  }
  if (isStaticPath(path)) {
    event.respondWith(cacheFirst(event, request, path));
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
  const network = fetch(request);
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

// Bootstrap runs only when opening a page, which is an approved safe point.
// Never write a new bootstrap into an older build's cache.
async function bootstrap(request) {
  try {
    return await withTimeout(fetch(new Request(request, { cache: 'no-store' })), NETWORK_TIMEOUT_MS);
  } catch (_) {
    const cache = await caches.open(CACHE);
    const stored = await cache.match(request, { ignoreSearch: true });
    if (stored) return stored;
    throw new Error('Bootstrap unavailable');
  }
}

async function cacheFirst(event, request, path) {
  const cache = await cacheForEvent(event);
  event.waitUntil(cleanupCaches());
  // Tag worker entry URLs so their later WASM requests keep the originating
  // build even after the service worker restarts. Worker clients have no DOM.
  if (['worker', 'sharedworker'].includes(request.destination) && !new URL(request.url).searchParams.has('pantas_build')) {
    const entries = await cache.match(SCOPE + 'version.json');
    const version = entries ? (await entries.json()).pantasBuildVersion : VERSION;
    const target = new URL(request.url);
    target.searchParams.set('pantas_build', version);
    return Response.redirect(target.href);
  }
  const stored = await cache.match(request, { ignoreSearch: true });
  if (stored) {
    // A cached Response.url is canonical and would erase the worker's tag.
    // An empty response URL preserves the requested, tagged worker URL.
    if (['worker', 'sharedworker'].includes(request.destination)) {
      return new Response(stored.body, {status: stored.status, statusText: stored.statusText, headers: stored.headers});
    }
    return stored;
  }
  // Never pollute a retained build with a same-path file from a new deploy.
  const metadata = await cache.match(SCOPE + 'version.json');
  const cachedVersion = metadata && (await metadata.json()).pantasBuildVersion;
  if (cachedVersion) {
    const current = await fetch(new Request(SCOPE + 'version.json', { cache: 'no-store' }));
    if (!current.ok || (await current.json()).pantasBuildVersion !== cachedVersion) {
      throw new Error('Retired build file unavailable');
    }
  }
  const response = await fetch(request);
  if (cachedVersion === VERSION && !await matchesBuild(path, response)) {
    throw new Error('Build file changed: ' + path);
  }
  if (isStorable(response)) {
    event.waitUntil(cache.put(request, response.clone()));
    // Stamped production builds already contain every deferred part, verified
    // during install. The fallback warmer is only for unstamped local builds.
    if (!STAMPED_VERSION && path === 'main.dart.js') event.waitUntil(warmDeferredParts(cache, response.clone()));
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
