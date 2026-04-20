// Renove GLP-1 — Service Worker
// Permite notificações funcionarem mesmo com o app em segundo plano

const CACHE = 'renove-v1';

// Abre o app quando usuário clica na notificação
self.addEventListener('notificationclick', event => {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(list => {
      // Se já tem uma aba aberta, foca nela
      for (const c of list) {
        if ('focus' in c) return c.focus();
      }
      // Senão abre o app
      return clients.openWindow('/');
    })
  );
});

// Cache básico para funcionar offline
self.addEventListener('install', event => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE).then(cache =>
      cache.addAll(['/', '/index.html', '/assets/ampola.mp4'])
        .catch(() => {}) // falha silenciosa se offline
    )
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

// Responde com cache quando offline
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;
  event.respondWith(
    fetch(event.request).catch(() => caches.match(event.request))
  );
});
