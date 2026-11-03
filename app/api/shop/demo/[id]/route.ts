import {gateway,resolveActor,response,failure} from '../../../../../lib/beleg-server';
import {stream} from '../../../../../lib/file-stream';
export const dynamic='force-dynamic';
// Only catalog-demo uploads explicitly published by the owner can be streamed.
// Order audio and private customer files have different keys and are never used here.
export async function GET(req:Request,{params}:{params:Promise<{id:string}>}){try{const {id}=await params;if(!/^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/.test(id))return response({error:'Аудио олдсонгүй.'},404);const data=await gateway('catalog',await resolveActor(req));const path='/api/shop/demo/'+id;if(!data.settings?.experience?.greetings?.some((g:any)=>g.enabled&&g.audio===path))return response({error:'Энэ жишээ аудио нийтлэгдээгүй.'},404);return stream(req,'catalog/demo/'+id);}catch(e){return failure(e);}}
