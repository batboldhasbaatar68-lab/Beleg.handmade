-- Applied to the existing database on 2026-11-03.
-- The Netlify gateway key hash is provisioned separately; never commit the key.
create table if not exists beleg_internal.gateway_credentials (name text primary key,key_hash text not null check (key_hash ~ '^[0-9a-f]{64}$'));
alter table beleg_internal.gateway_credentials enable row level security;
revoke all on beleg_internal.gateway_credentials from public,anon,authenticated;
do $migration$ declare src text; old_guard text := 'encode(sha256(convert_to(p_key,''UTF8'')),''hex'')<>cfg.gateway_hash then'; new_guard text := '(encode(sha256(convert_to(p_key,''UTF8'')),''hex'')<>cfg.gateway_hash and not exists (select 1 from beleg_internal.gateway_credentials c where c.key_hash=encode(sha256(convert_to(p_key,''UTF8'')),''hex''))) then'; begin select pg_get_functiondef('beleg_internal.gateway(text,text,text,jsonb)'::regprocedure) into src; if position(old_guard in src)>0 then execute replace(src,old_guard,new_guard); end if; end $migration$;
insert into storage.buckets(id,name,public,file_size_limit) values ('beleg-private','beleg-private',false,20971520) on conflict(id) do nothing;
