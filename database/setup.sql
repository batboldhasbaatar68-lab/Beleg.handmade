-- Additive v2 schema. Existing public.orders/products and legacy D1 orders are untouched.
-- Run once with an administrator. Replace __GATEWAY_SHA256__ out of band.
begin;
create schema if not exists beleg_internal;
revoke all on schema beleg_internal from public;
create table beleg_internal.config (
 id boolean primary key default true check(id), gateway_hash text not null,
 owner_id text not null, settings jsonb not null
);
create table beleg_internal.products (
 id text primary key, name text not null check(length(name) between 1 and 150),
 price integer not null check(price between 1 and 10000000),
 description text not null default '', category text not null,
 image text not null default '', image_note text not null default '',
 stock integer check(stock>=0), active boolean not null default false,
 kind text not null default 'physical' check(kind in ('physical','voice','ai','premium')),
 updated_at timestamptz not null default now()
);
create table beleg_internal.orders (
 id uuid primary key default gen_random_uuid(), user_id text not null,
 request_key uuid not null, customer_name text not null, phone text not null,
 address text not null default '', delivery_zone text not null,
 subtotal integer not null, delivery_fee integer not null, total integer not null,
 items jsonb not null, customization jsonb not null default '{}',
 status text not null default 'new', payment_status text not null default 'unverified', payment_confirmed_at timestamptz,
 receipt_key text, source_key text, audio_key text, photo_key text, share_token text unique,
 audio_approved boolean not null default false, revoked boolean not null default false,
 expires_at timestamptz not null default (now()+interval '365 days'),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(user_id, request_key), check(total=subtotal+delivery_fee),
 check(status in ('new','confirmed','making','ready','shipping','completed','cancelled')),
 check(payment_status in ('unverified','review','paid'))
);
create index beleg_orders_user_created on beleg_internal.orders(user_id,created_at desc);
create index beleg_orders_expiry on beleg_internal.orders(expires_at) where not revoked;
create table beleg_internal.audit (
 id bigint generated always as identity primary key,
 actor text not null, action text not null, order_id uuid, created_at timestamptz default now()
);
alter table beleg_internal.config enable row level security;
alter table beleg_internal.products enable row level security;
alter table beleg_internal.orders enable row level security;
alter table beleg_internal.audit enable row level security;
revoke all on all tables in schema beleg_internal from public,anon,authenticated;
insert into beleg_internal.config values(true,'__GATEWAY_SHA256__','9f730dd1-ff2b-4239-96ff-866691d21bdd',
 '{"facebook":"https://www.facebook.com/share/19kJDbmsjH/?mibextid=wwXIfr","messenger":"","retentionDays":365,"bank":"ХААН БАНК","iban":"MN320005005075371267","accountName":"Tsoggerel Altantsatsral"}');
insert into beleg_internal.products(id,name,price,description,category,image,image_note,stock,active,kind) values
 ('beleg-classic','БЭЛЭГ Classic',45000,'Пластик торон суурь, утсан хээ, мөрөвч, гоёлын төмөр түгжээтэй жижиг мөрний цүнх. Бэлэн эсэх, хэмжээг захиалга баталгаажуулахдаа тохирно.','bags','/images/beleg-rose-collection.png','AI танилцуулгын дүрслэл. Бодит цүнхний өнгө, хийц, хэмжээг захиалга баталгаажуулахдаа лавлана уу.',null,true,'physical'),
 ('qr-own','Өөрийн дуу хоолой',29900,'Таны өөрийн бичлэг, сонгосон загвар, давтагдашгүй QR карт. PNG болон хэвлэх PDF.','qr','','',null,true,'voice'),
 ('qr-ai','AI шүлэгтэй дуут бэлэг',39900,'Таны түүхээс сэдэвлэсэн монгол шүлэг, эмэгтэй эсвэл эрэгтэй хоолой. Админ аудиог бэлдэж, танаар батлуулна.','qr','','',null,true,'ai'),
 ('qr-premium','Premium QR бэлгийн багц',59900,'QR дуут карт, бэлгийн багцын захиалга. Доторх бүтээгдэхүүн, савлагааг утсаар баталгаажуулна.','qr','','',null,true,'premium'),
 ('candle-bath','Үнэртэй лаа + ванны бөмбөлөг',1,'Үнэ, найрлага, хэмжээ болон бодит зураг батлагдсаны дараа захиалга нээгдэнэ.','gifts','','',0,false,'physical'),
 ('open-when','Сэтгэлээр унасан үедээ нээ',1,'Сэтгэл шингэсэн захидлын багц. Үнэ, захидлын тоо бэлтгэгдэж байна.','gifts','','',0,false,'physical'),
 ('secret-box','Нууц хайрцаг',1,'Таны зургаар бүтээх дурсамжийн бэлэг. Хэмжээ, үнэ, зураг бэлтгэгдэж байна.','gifts','','',0,false,'physical');

create policy admin_products on beleg_internal.products for all to authenticated using ((select auth.uid())='4a03f88c-8d48-4f0f-b878-2c47d3ad94b8'::uuid) with check ((select auth.uid())='4a03f88c-8d48-4f0f-b878-2c47d3ad94b8'::uuid);
create policy admin_orders on beleg_internal.orders for all to authenticated using ((select auth.uid())='4a03f88c-8d48-4f0f-b878-2c47d3ad94b8'::uuid) with check ((select auth.uid())='4a03f88c-8d48-4f0f-b878-2c47d3ad94b8'::uuid);
-- This privileged gateway authenticates a high-entropy server-only capability.
-- It is deliberately outside the exposed schema; browsers never receive its key.
create function beleg_internal.gateway(p_key text,p_action text,p_actor text,p_data jsonb)
returns jsonb language plpgsql security definer set search_path='' as $$
declare cfg beleg_internal.config; o beleg_internal.orders; p beleg_internal.products;
 item jsonb; lines jsonb:='[]'; subtotal bigint:=0; fee integer; qty integer;
 admin boolean; result jsonb; delta integer; target text; ident uuid;
begin
 select * into cfg from beleg_internal.config where id;
 if p_key is null or length(p_key)<40 or encode(sha256(convert_to(p_key,'UTF8')),'hex')<>cfg.gateway_hash then
  raise exception 'FORBIDDEN' using errcode='42501';
 end if;
 -- p_actor is supplied only by the trusted server after Supabase getUser verification.
 admin:=coalesce(p_actor=cfg.owner_id,false);
 if p_action='catalog' then
  select coalesce(jsonb_agg(to_jsonb(t) order by t.id),'[]') into result from beleg_internal.products t ;
  return jsonb_build_object('products',result,'settings',cfg.settings);
 end if;
 if p_action='gift' then
  select * into o from beleg_internal.orders where share_token=p_data->>'token';
  if not found or o.revoked or o.expires_at<now() or o.status='cancelled' or not o.audio_approved or o.audio_key is null then raise exception 'GIFT_UNAVAILABLE';end if;
  return jsonb_build_object('id',o.id,'customization',o.customization,'audio_key',o.audio_key,'photo_key',o.photo_key,'expires_at',o.expires_at);
 end if;
 if p_actor is null or length(p_actor)<2 then raise exception 'UNAUTHENTICATED';end if;
 if p_action='create' then
  perform pg_advisory_xact_lock(hashtextextended(p_actor||coalesce(p_data->>'requestKey',''),0));
  select * into o from beleg_internal.orders where user_id=p_actor and request_key=(p_data->>'requestKey')::uuid;
  if found then return to_jsonb(o);end if;
  if length(p_data->>'name') not between 2 and 80 or p_data->>'phone' !~ '^[0-9]{8}$' then raise exception 'INVALID_CUSTOMER';end if;
  if p_data->>'zone' not in ('central','outer','pickup') then raise exception 'INVALID_DELIVERY';end if;
  if p_data->>'zone'<>'pickup' and length(p_data->>'address')<8 then raise exception 'INVALID_ADDRESS';end if;
  if jsonb_typeof(p_data->'items')<>'array' or jsonb_array_length(p_data->'items') not between 1 and 20 then raise exception 'INVALID_CART';end if;
  if (select count(distinct value->>'id') from jsonb_array_elements(p_data->'items'))<>jsonb_array_length(p_data->'items') then raise exception 'INVALID_CART';end if;
  for item in select value from jsonb_array_elements(p_data->'items') order by value->>'id' loop
   qty:=(item->>'quantity')::integer;
   if qty is null or qty not between 1 and 20 then raise exception 'INVALID_QUANTITY';end if;
   select * into p from beleg_internal.products where id=item->>'id' and active for update;
   if not found then raise exception 'PRODUCT_UNAVAILABLE';end if;
   if p.stock is not null and p.stock<qty then raise exception 'OUT_OF_STOCK';end if;
   if p.stock is not null then update beleg_internal.products set stock=stock-qty where id=p.id;end if;
   subtotal:=subtotal+p.price::bigint*qty;
   lines:=lines||jsonb_build_array(jsonb_build_object('id',p.id,'name',p.name,'price',p.price,'quantity',qty,'kind',p.kind,'stock_tracked',p.stock is not null));
  end loop;
  fee:=case when subtotal>=150000 or p_data->>'zone'='pickup' then 0 when p_data->>'zone'='central' then 8000 else 10000 end;
  insert into beleg_internal.orders(user_id,request_key,customer_name,phone,address,delivery_zone,subtotal,delivery_fee,total,items,customization,expires_at)
  values(p_actor,(p_data->>'requestKey')::uuid,p_data->>'name',p_data->>'phone',coalesce(p_data->>'address',''),p_data->>'zone',subtotal,fee,subtotal+fee,lines,coalesce(p_data->'customization','{}'),now()+make_interval(days=>(cfg.settings->>'retentionDays')::integer)) returning * into o;
  return to_jsonb(o);
 end if;
 if p_action='orders' then
  select coalesce(jsonb_agg(to_jsonb(t) order by t.created_at desc),'[]') into result from (select * from beleg_internal.orders where admin or user_id=p_actor order by created_at desc limit 200) t;
  return result;
 end if;
 if p_action='order' or p_action='file' or p_action='approve' or p_action='revoke' or p_action='status' then
  select * into o from beleg_internal.orders where id=(p_data->>'id')::uuid and (user_id=p_actor or admin) for update;
  if not found then raise exception 'ORDER_NOT_FOUND';end if;
  if p_action='order' then return to_jsonb(o);end if;
  if p_action='file' then
   if o.revoked or o.expires_at<now() or o.status='cancelled' then raise exception 'GIFT_UNAVAILABLE';end if;
   target:=p_data->>'type';
   if target='receipt' then update beleg_internal.orders set receipt_key=p_data->>'key',payment_status=case when payment_status='paid' then 'paid' else 'review' end where id=o.id;
   elsif target='photo' then update beleg_internal.orders set photo_key=p_data->>'key' where id=o.id;
   elsif target='source' then update beleg_internal.orders set source_key=p_data->>'key' where id=o.id;
   elsif target='final' and (admin or exists(select 1 from jsonb_array_elements(o.items) i where i->>'kind'='voice')) then update beleg_internal.orders set audio_key=p_data->>'key',audio_approved=false,share_token=replace(gen_random_uuid()::text||gen_random_uuid()::text,'-','') where id=o.id;
   else raise exception 'FORBIDDEN';end if;
  elsif p_action='approve' then
   if o.audio_key is null then raise exception 'AUDIO_NOT_READY';end if;
   update beleg_internal.orders set audio_approved=true where id=o.id;
  elsif p_action='revoke' then
   update beleg_internal.orders set revoked=true,audio_approved=false,audio_key=null,source_key=null,share_token=null,receipt_key=null,photo_key=null,customization='{}' where id=o.id;
  elsif p_action='status' then
   if not admin then raise exception 'FORBIDDEN';end if;
   target:=coalesce(p_data->>'status',o.status);
   if target not in ('new','confirmed','making','ready','shipping','completed','cancelled') then raise exception 'INVALID_STATUS';end if;
   if o.status='cancelled' and target<>'cancelled' then raise exception 'CANNOT_REOPEN_CANCELLED';end if;
   if target='cancelled' and o.status<>'cancelled' then
    for item in select value from jsonb_array_elements(o.items) order by value->>'id' loop
     if (item->>'stock_tracked')::boolean then update beleg_internal.products set stock=stock+(item->>'quantity')::integer where id=item->>'id';end if;
    end loop;
   end if;
   if p_data ? 'paymentStatus' and p_data->>'paymentStatus' not in ('unverified','review','paid') then raise exception 'INVALID_PAYMENT';end if;
   update beleg_internal.orders set status=target,payment_status=coalesce(p_data->>'paymentStatus',payment_status),payment_confirmed_at=case when p_data->>'paymentStatus'='paid' then coalesce(payment_confirmed_at,now()) when p_data ? 'paymentStatus' then null else payment_confirmed_at end where id=o.id;
  end if;
  update beleg_internal.orders set updated_at=now() where id=o.id returning * into o;
  insert into beleg_internal.audit(actor,action,order_id) values(p_actor,p_action,o.id);
  return to_jsonb(o);
 end if;
 if not admin then raise exception 'FORBIDDEN';end if;
 if p_action='legacy_orders' then select coalesce(jsonb_agg(to_jsonb(t) order by t.created_at desc),'[]') into result from (select id,customer_name,phone,address,product_name,quantity,total_price,status,payment_status,created_at from public.orders order by created_at desc limit 200) t;return result;end if;
 if p_action='product' then
  insert into beleg_internal.products(id,name,price,description,category,image,image_note,stock,active,kind)
  values(p_data->>'id',p_data->>'name',(p_data->>'price')::integer,coalesce(p_data->>'description',''),p_data->>'category',coalesce(p_data->>'image',''),coalesce(p_data->>'image_note',''),(p_data->>'stock')::integer,(p_data->>'active')::boolean,p_data->>'kind')
  on conflict(id) do update set name=excluded.name,price=excluded.price,description=excluded.description,category=excluded.category,image=excluded.image,image_note=excluded.image_note,stock=excluded.stock,active=excluded.active,kind=excluded.kind,updated_at=now();
  insert into beleg_internal.audit(actor,action) values(p_actor,'product');return '{"ok":true}';
 end if;
 if p_action='settings' then
  if (p_data->>'retentionDays')::integer not between 30 and 365 then raise exception 'INVALID_RETENTION';end if;
  update beleg_internal.config set settings=settings||p_data where id;return '{"ok":true}';
 end if;
 if p_action='expired' then
  select coalesce(jsonb_agg(to_jsonb(t)),'[]') into result from (select * from beleg_internal.orders where not revoked and expires_at<now() limit 100) t;return result;
 end if;
 raise exception 'UNKNOWN_ACTION';
end $$;
revoke all on function beleg_internal.gateway(text,text,text,jsonb) from public;
grant usage on schema beleg_internal to anon;
grant execute on function beleg_internal.gateway(text,text,text,jsonb) to anon;
create function public.beleg_shop_gateway(p_key text,p_action text,p_actor text,p_data jsonb default '{}')
returns jsonb language sql security invoker set search_path='' as $$
 select beleg_internal.gateway(p_key,p_action,p_actor,p_data);
$$;
revoke all on function public.beleg_shop_gateway(text,text,text,jsonb) from public,authenticated;
grant execute on function public.beleg_shop_gateway(text,text,text,jsonb) to anon;
commit;
