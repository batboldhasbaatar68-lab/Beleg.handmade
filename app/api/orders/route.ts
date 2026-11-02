import {guard,failure,OWNER} from '../../../lib/beleg-server';
import { getDb } from '../../../db';
import { orders } from '../../../db/schema';
import { and, eq, desc } from 'drizzle-orm';
import { z } from 'zod';
export const dynamic = 'force-dynamic';
const input = z.object({
  requestKey:z.string().uuid(), productId:z.literal('beleg-classic'), quantity:z.number().int().min(1).max(5),
  name:z.string().trim().min(2).max(80), phone:z.string().regex(/^\d{8}$/),
  delivery:z.enum(['delivery','pickup']), address:z.string().trim().max(300), note:z.string().trim().max(500),
}).refine(v=>v.delivery==='pickup'||v.address.length>=8);
function userId(req:Request) {return req.headers.get('oai-authenticated-user-id') || (process.env.NODE_ENV==='development'?'preview-user':null);}
function json(data:unknown,status=200) {return Response.json(data,{status,headers:{'Cache-Control':'no-store'}});}
function receipt(row:typeof orders.$inferSelect) {const {userId:_,requestKey:__,...safe}=row;return safe;}
export async function POST(){return json({error:'Шинэ захиалгыг дэлгүүрийн сагсаар илгээнэ үү.'},410);}
export async function GET(req:Request) {
  try{await guard(req,true);}catch(e){return failure(e);}
  const user=OWNER;
  try{const rows=await getDb().select().from(orders).where(eq(orders.userId,user)).orderBy(desc(orders.createdAt)).limit(50);return json({orders:rows.map(receipt)});}
  catch{return json({error:'Захиалгуудыг ачаалж чадсангүй.'},503);}
}
