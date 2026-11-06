// Service worker do Bolso: abre o app sem internet. Os dados financeiros nunca passam por este cache.
// Ao mudar a lista abaixo ou a forma de cachear, aumente a versão para descartar o cache antigo.
const CACHE = 'bolso-v1';
const SHELL = ['./', 'index.html', 'config.js', 'i18n.js', 'manifest.json', 'icon.svg', 'icon-192.png', 'icon-512.png', 'apple-touch-icon.png?v=3'];
const SUPABASE_LIB = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.50.0/dist/umd/supabase.js';
// Bibliotecas com versão fixa e fontes. O Supabase (dados e login) fica de fora de propósito.
const CDN = /^https:\/\/(cdn\.jsdelivr\.net|cdnjs\.cloudflare\.com|fonts\.googleapis\.com|fonts\.gstatic\.com)\//;
const NETWORK_TIMEOUT = 3000;

self.addEventListener('install', e => {
  e.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    await cache.addAll(SHELL);
    await cache.add(new Request(SUPABASE_LIB, { mode: 'no-cors' })).catch(() => {});
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', e => {
  e.waitUntil((async () => {
    for (const key of await caches.keys()) if (key !== CACHE) await caches.delete(key);
    await self.clients.claim();
  })());
});

// Site: rede primeiro, para as atualizações chegarem; se demorar ou falhar, usa a cópia salva.
async function networkFirst(request) {
  const cache = await caches.open(CACHE);
  const network = fetch(request).then(response => {
    if (response.ok) cache.put(request, response.clone());
    return response;
  });
  const fallback = async () => {
    const saved = await cache.match(request, { ignoreSearch: true })
      || (request.mode === 'navigate' ? await cache.match('index.html') : undefined);
    if (saved) return saved;
    return network;
  };
  const timeout = new Promise(resolve => setTimeout(resolve, NETWORK_TIMEOUT));
  try {
    return (await Promise.race([network, timeout])) || await fallback();
  } catch {
    return fallback();
  }
}

async function cacheFirst(request) {
  const cache = await caches.open(CACHE);
  const saved = await cache.match(request);
  if (saved) return saved;
  const response = await fetch(request);
  if (response.ok || response.type === 'opaque') cache.put(request, response.clone());
  return response;
}

self.addEventListener('fetch', e => {
  const { request } = e;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin === self.location.origin) e.respondWith(networkFirst(request));
  else if (CDN.test(request.url)) e.respondWith(cacheFirst(request));
});
