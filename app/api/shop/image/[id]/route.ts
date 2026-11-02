import {guard,failure} from '../../../../../lib/beleg-server';
import {stream} from '../../../../../lib/file-stream';
export async function GET(req:Request,{params}:{params:Promise<{id:string}>}){try{const {id}=await params;if(!/^[a-f0-9-]{36}$/.test(id))throw Error('FORBIDDEN');const image=await stream(req,'catalog/image/'+id);return image.status===404?stream(req,'catalog/video/'+id):image;}catch(e){return failure(e);}}
