// Old address only: remove the app's service worker and its caches, then reload open pages,
// which the tiny index.html sends on to app.pantas.study.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', event => event.waitUntil((async () => {
  for (const key of await caches.keys()) await caches.delete(key);
  await self.registration.unregister();
  for (const client of await self.clients.matchAll({type: 'window'})) client.navigate(client.url);
})()));
