/* Service worker: offline para el núcleo de la app.
   Estrategia: network-first para HTML/JS (así los estudiantes reciben
   actualizaciones al reconectar) con fallback a caché; cache-first para iconos.
   Sube CACHE_VER cuando publiques cambios para forzar refresco. */
const CACHE_VER = "iese-calc-v10";
const CORE = ["./", "./index.html", "./config.js", "./manifest.webmanifest",
  "./icon-180.png", "./icon-192.png", "./icon-512.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE_VER).then(c => c.addAll(CORE)).then(() => self.skipWaiting()));
});
self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(keys =>
    Promise.all(keys.filter(k => k !== CACHE_VER).map(k => caches.delete(k)))
  ).then(() => self.clients.claim()));
});
self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;                       // nunca cachear POST al ranking
  const url = new URL(req.url);
  if (url.origin !== location.origin) return;             // deja pasar Supabase directo a la red
  const isDoc = req.mode === "navigate" || /\.(html|js|webmanifest)$/.test(url.pathname);
  if (isDoc) {
    e.respondWith(
      fetch(req).then(res => {
        const copy = res.clone(); caches.open(CACHE_VER).then(c => c.put(req, copy)); return res;
      }).catch(() => caches.match(req).then(r => r || caches.match("./index.html")))
    );
  } else {
    e.respondWith(caches.match(req).then(r => r || fetch(req)));
  }
});
