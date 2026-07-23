// Compatibility endpoint for service workers installed by older frontend builds.
// The current application does not use offline caching, so this worker removes
// its own registration and every cache owned by this origin.
self.addEventListener('install', () => self.skipWaiting())

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((cacheNames) => Promise.all(cacheNames.map((cacheName) => caches.delete(cacheName))))
      .then(() => self.registration.unregister())
      .then(() => self.clients.matchAll({ type: 'window' }))
      .then((clients) => Promise.all(clients.map((client) => client.navigate(client.url)))),
  )
})

self.addEventListener('fetch', (event) => {
  event.respondWith(fetch(event.request))
})
