const CACHE='beleg-public-v1';
const OFFLINE='/offline.html';
self.addEventListener('install',event=>{event.waitUntil(caches.open(CACHE).then(c=>c.addAll([OFFLINE,'/flower-logo.svg','/icons/icon-192.png','/icons/icon-512.png'])));self.skipWaiting();});
self.addEventListener('activate',event=>{event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k.startsWith('beleg-public-')&&k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim()));});
self.addEventListener('fetch',event=>{
 const req=event.request,u=new URL(req.url);if(req.method!=='GET'||u.origin!==self.location.origin)return;
 // Never intercept protected endpoints, customer files, private gift links or admin pages.
 if(u.pathname.startsWith('/api/')||u.pathname.startsWith('/admin')||u.pathname.startsWith('/g/'))return;
 if(req.mode==='navigate'){event.respondWith(fetch(req).catch(()=>caches.match(OFFLINE)));return;}
 const safe=u.pathname.startsWith('/_next/static/')||u.pathname.startsWith('/assets/')||u.pathname.startsWith('/images/')||u.pathname.startsWith('/icons/')||['/flower-logo.svg','/flower-pattern.svg','/favicon.svg'].includes(u.pathname);
 if(!safe)return;
 event.respondWith(fetch(req).then(res=>{if(res.ok&&res.type==='basic'){const copy=res.clone();event.waitUntil(caches.open(CACHE).then(async c=>{await c.put(req,copy);const keys=await c.keys();if(keys.length>100){for(const k of keys){if(!['/offline.html','/flower-logo.svg','/icons/icon-192.png','/icons/icon-512.png'].includes(new URL(k.url).pathname)){await c.delete(k);break;}}}}));}return res;}).catch(()=>caches.match(req)));
});
