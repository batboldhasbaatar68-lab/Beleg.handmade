import {stream} from '../../../../lib/file-stream';
import {resolveActor,guard,gateway,response,failure,bucket} from '../../../../lib/beleg-server';
export const dynamic='force-dynamic';
export async function GET(req:Request){try{await guard(req);const u=new URL(req.url),id=u.searchParams.get('id'),type=u.searchParams.get('type');const o=await gateway('order',await resolveActor(req),{id});const key=type==='receipt'?o.receipt_key:type==='source'?o.source_key:type==='photo'?o.photo_key:o.audio_key;if(!key)return response({error:'Файл бэлэн болоогүй байна.'},404);if(type!=='receipt'&&(o.revoked||new Date(o.expires_at).getTime()<Date.now()))throw Error('GIFT_UNAVAILABLE');return await stream(req,key);}catch(e){return failure(e);}}
