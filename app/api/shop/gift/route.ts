import {gateway,failure} from '../../../../lib/beleg-server';
import {stream} from '../../../../lib/file-stream';
export async function GET(req:Request){try{const token=new URL(req.url).searchParams.get('token');if(!token||!/^[a-f0-9]{64}$/.test(token))throw Error('GIFT_UNAVAILABLE');const d=await gateway('gift',null,{token});return stream(req,new URL(req.url).searchParams.get('type')==='photo'?d.photo_key:d.audio_key);}catch(e){return failure(e);}}
