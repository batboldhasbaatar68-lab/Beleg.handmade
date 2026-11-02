/** Netlify's Node runtime adapter. Service key stays in server runtime variables. */
const base='https://iqwklalhyayetrlujghi.supabase.co/storage/v1/object';
function headers(){const key=process.env.SUPABASE_SERVICE_ROLE_KEY;if(!key)throw Error('NOT_CONFIGURED');return {apikey:key,Authorization:'Bearer '+key};}
function url(key:string){return base+'/beleg-private/'+key.split('/').map(encodeURIComponent).join('/');}
const storage={
 async put(key:string,bytes:Uint8Array,options:any){const r=await fetch(url(key),{method:'POST',headers:{...headers(),'Content-Type':options.httpMetadata.contentType,'x-upsert':'false'},body:bytes as BodyInit});if(!r.ok)throw Error('STORAGE_UNAVAILABLE');},
 async delete(key:string){const r=await fetch(url(key),{method:'DELETE',headers:headers()});if(!r.ok&&r.status!==404)throw Error('STORAGE_UNAVAILABLE');},
 async get(key:string,options?:{range?:Headers}){const range=options?.range?.get('range');const r=await fetch(url(key),{headers:{...headers(),...(range?{Range:range}:{})}});if(r.status===404||r.status===400)return null;if(!r.ok)throw Error('STORAGE_UNAVAILABLE');const cr=r.headers.get('content-range')?.match(/^bytes (\d+)-(\d+)\/(\d+)$/);return {body:r.body,size:cr?Number(cr[3]):Number(r.headers.get('content-length')),range:cr?{offset:Number(cr[1]),length:Number(cr[2])-Number(cr[1])+1}:undefined,writeHttpMetadata(h:Headers){h.set('Content-Type',r.headers.get('content-type')||'application/octet-stream');}};}
};
export const env={BELEG_GATEWAY_KEY:process.env.BELEG_GATEWAY_KEY,BUCKET:storage,DB:null};
