import {headers} from 'next/headers';
import AdminPanel from '../admin-panel';
import AdminLogin from '../admin-login';
import {supabaseAdmin} from '../../lib/supabase-admin';
export const dynamic='force-dynamic';
export default async function AdminPage(){const h=await headers(),req=new Request('https://beleg-handmade-boutique.avidblade1.chatgpt.site/admin',{headers:h});return await supabaseAdmin(req)?<AdminPanel/>:<AdminLogin/>;}
