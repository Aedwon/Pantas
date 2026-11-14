// Build identity belongs to the URL, never to a page or its controller.
'use strict';
const STAMPED_VERSION = '';
const RETAINED_VERSIONS = [];
const BUILD_FILES = [];
const BUILD_HASHES = {};
const LEGACY_FILES = {};
const SCOPE = self.registration.scope;
const ROOT_CACHE = 'pantas-root';
const BUILD_PREFIX = 'pantas-build-';
const NETWORK_TIMEOUT_MS = 3000;

function storable(response, html = false) {
  return response && response.status === 200 && response.type === 'basic' &&
    !/no-store|private/i.test(response.headers.get('Cache-Control') || '') &&
    (html || !/text\/html/i.test(response.headers.get('Content-Type') || ''));
}
async function cacheFirst(request, version, cacheName = BUILD_PREFIX + version) {
  const cache = await caches.open(cacheName);
  const existing = await cache.match(request);
  if (existing) return existing;
  const response = await fetch(request);
  if (storable(response)) await cache.put(request, response.clone());
  return response;
}
function completeKey(version) {return SCOPE + 'b/' + version + '/.pantas-complete';}
async function pinnedVersion(response) {
  const match = (await response.clone().text()).match(/<html[^>]*data-pantas-build="([A-Za-z0-9_-]+)"/);
  return match && match[1];
}
async function completeIndex(response) {
  const version = await pinnedVersion(response);
  return version && await (await caches.open(BUILD_PREFIX + version)).match(completeKey(version));
}
async function verify(response, hash, path) {
  if (!storable(response)) throw Error('Invalid build file: ' + path);
  const bytes = await crypto.subtle.digest('SHA-256', await response.clone().arrayBuffer());
  const actual = Array.from(new Uint8Array(bytes), b => b.toString(16).padStart(2,'0')).join('');
  if (actual !== hash) throw Error('Build hash mismatch: ' + path);
}
async function networkFirst(request, key, event) {
  const cache = await caches.open(ROOT_CACHE);
  // Let a slow successful request refresh the fallback even after the timeout.
  const network = fetch(request).then(async response => {
    if (storable(response, key === SCOPE + 'index.html') &&
        (key !== SCOPE + 'index.html' || await completeIndex(response))) await cache.put(key, response.clone());
    return response;
  });
  event.waitUntil(network.catch(() => {}));
  let timer;
  try {
    const response = await Promise.race([network, new Promise(resolve => {
      timer = setTimeout(() => resolve(null), NETWORK_TIMEOUT_MS);
    })]);
    if (response && response.ok) return response;
    const fallback = await cache.match(key);
    return fallback || response || await network;
  } catch (error) {
    const fallback = await cache.match(key);
    if (fallback) return fallback;
    throw error;
  } finally {clearTimeout(timer);}
}
self.addEventListener('install', event => {
  event.waitUntil((async () => {
    // Complete the current build before replacing the offline index. Old
    // clients keep their own folder URLs throughout installation and takeover.
    await Promise.all(BUILD_FILES.map(async path => {
      const request = new Request(SCOPE + 'b/' + STAMPED_VERSION + '/' + path, {cache:'reload'});
      const response = await fetch(request);
      await verify(response, BUILD_HASHES[path], path);
      await (await caches.open(BUILD_PREFIX + STAMPED_VERSION)).put(request, response);
    }));
    // Only the first folder rollout publishes flat files. Cache verified old
    // bytes before claiming legacy pages, including their missing deferred parts.
    await Promise.all(Object.entries(LEGACY_FILES).map(async ([path, hash]) => {
      const request = new Request(SCOPE + path, {cache:'reload'});
      const response = await fetch(request);
      await verify(response, hash, path);
      await (await caches.open('pantas-legacy-flat')).put(request, response);
    }));
    await (await caches.open(BUILD_PREFIX + STAMPED_VERSION)).put(completeKey(STAMPED_VERSION), new Response('complete'));

    const root = await caches.open(ROOT_CACHE);
    for (const path of ['flutter_bootstrap.js', 'version.json', 'index.html']) {
      const response = await fetch(new Request(SCOPE + path, {cache:'reload'}));
      if (!storable(response, path === 'index.html')) throw Error('Invalid root file: ' + path);
      if (path === 'index.html' && await pinnedVersion(response) !== STAMPED_VERSION) throw Error('Deployment changed during installation');
      await root.put(SCOPE + path, response);
    }
    await self.skipWaiting();
  })());
});
self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const keep = new Set([STAMPED_VERSION, ...RETAINED_VERSIONS]);
    for (const name of await caches.keys()) {
      if (name.startsWith(BUILD_PREFIX) && !keep.has(name.slice(BUILD_PREFIX.length))) await caches.delete(name);
      // Legacy caches are intentionally untouched during flat migration.
    }
    await self.clients.claim();
  })());
});
self.addEventListener('fetch', event => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== 'GET' || url.origin !== new URL(SCOPE).origin ||
      !url.href.startsWith(SCOPE) || request.cache === 'no-store' ||
      request.credentials === 'include' || request.headers.has('Authorization') || request.headers.has('Range')) return;
  const path = url.pathname.slice(new URL(SCOPE).pathname.length);
  if (path.startsWith('__/') || path.startsWith('wrapped/')) return;
  if (Object.hasOwn(LEGACY_FILES, path)) {
    event.respondWith(cacheFirst(request, null, 'pantas-legacy-flat')); return;
  }
  const folder = /^b\/([A-Za-z0-9_-]+)\/.+/.exec(path);
  if (folder) {event.respondWith(cacheFirst(request, folder[1])); return;}
  if (request.mode === 'navigate' || path === '' || path === 'index.html') {
    event.respondWith(networkFirst(request, SCOPE + 'index.html', event));
  } else if (path === 'flutter_bootstrap.js' || path === 'version.json') {
    event.respondWith(networkFirst(request, SCOPE + path, event));
  }
});
