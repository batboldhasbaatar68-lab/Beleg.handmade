/** Netlify may pass an internal URL to Next.js; only accept the known public shop origin. */
export function assertRequestOrigin(req:Request){
 const supplied=req.headers.get('origin');
 if(!supplied)return;
 const allowed=new Set([new URL(req.url).origin,'https://beleg-handmade-shop.netlify.app']);
 if(!allowed.has(supplied))throw Error('FORBIDDEN');
}
