self.addEventListener("install", e => {
  e.waitUntil(
    caches.open("ultra-v1").then(cache =>
      cache.addAll([
        "/mobile.html",
        "/css/ultra.css",
        "/js/api.js"
      ])
    )
  );
});

self.addEventListener("fetch", e => {
  e.respondWith(
    caches.match(e.request).then(resp => resp || fetch(e.request))
  );
});
