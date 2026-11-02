-- Supabase Auth owner binding; guest ordering remains behind the server-only gateway.
-- Existing designated Supabase administrator is preserved.
alter table beleg_internal.orders add column if not exists photo_key text;
alter table beleg_internal.orders add column if not exists payment_confirmed_at timestamptz;
create or replace function beleg_internal.gateway(p_key text,p_action text,p_actor text,p_data jsonb)
returns jsonb language plpgsql security definer set search_path='' as $$
declare cfg beleg_internal.config; o beleg_internal.orders; p beleg_internal.products;
 item jsonb; lines jsonb:='[]'; subtotal bigint:=0; fee integer; qty integer;
 admin boolean; result jsonb; delta integer; target text; ident uuid;
begin
 select * into cfg from beleg_internal.config where id;
 if p_key is null or length(p_key)<40 or encode(sha256(convert_to(p_key,'UTF8')),'hex')<>cfg.gateway_hash then
  raise exception 'FORBIDDEN' using errcode='42501';
 end if;
 admin:=coalesce(auth.uid()='4a03f88c-8d48-4f0f-b878-2c47d3ad94b8'::uuid,false);
 if p_actor=cfg.owner_id and not admin then raise exception 'FORBIDDEN' using errcode='42501';end if;
 if admin then p_actor:=cfg.owner_id;end if;
 if p_action='catalog' then
  select coalesce(jsonb_agg(to_jsonb(t) order by t.id),'[]') into result from beleg_internal.products t ;
  return jsonb_build_object('products',result,'settings',cfg.settings);
 end if;
 if p_action='gift' then
  select * into o from beleg_internal.orders where share_token=p_data->>'token';
  if not found or o.revoked or o.expires_at<now() or o.status='cancelled' or not o.audio_approved or o.audio_key is null then raise exception 'GIFT_UNAVAILABLE';end if;
  return jsonb_build_object('id',o.id,'customization',o.customization,'audio_key',o.audio_key,'photo_key',o.photo_key,'expires_at',o.expires_at);
 end if;
 if not admin and (p_actor is null or p_actor !~ '^guest:[a-f0-9-]{36}$') then raise exception 'UNAUTHENTICATED';end if;
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
   update beleg_internal.orders set status=target,payment_status=coalesce(p_data->>'paymentStatus',payment_status),payment_confirmed_at=case when p_data->>'paymentStatus'='paid' then now() when p_data ? 'paymentStatus' then null else payment_confirmed_at end where id=o.id;
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

grant usage on schema beleg_internal to authenticated;
grant execute on function beleg_internal.gateway(text,text,text,jsonb) to authenticated;
grant execute on function public.beleg_shop_gateway(text,text,text,jsonb) to authenticated;
-- No browser has the gateway key; JWT is also required for all administrator actions.
alter table beleg_internal.orders enable row level security;
grant select,insert,update,delete on beleg_internal.orders to authenticated;
create policy owner_only on beleg_internal.orders for all to authenticated using ((select auth.uid())='4a03f88c-8d48-4f0f-b878-2c47d3ad94b8'::uuid) with check ((select auth.uid())='4a03f88c-8d48-4f0f-b878-2c47d3ad94b8'::uuid);
alter table beleg_internal.products enable row level security;
grant select,insert,update,delete on beleg_internal.products to authenticated;
create policy owner_only on beleg_internal.products for all to authenticated using ((select auth.uid())='4a03f88c-8d48-4f0f-b878-2c47d3ad94b8'::uuid) with check ((select auth.uid())='4a03f88c-8d48-4f0f-b878-2c47d3ad94b8'::uuid);
alter table beleg_internal.config enable row level security;
grant select,insert,update,delete on beleg_internal.config to authenticated;
create policy owner_only on beleg_internal.config for all to authenticated using ((select auth.uid())='4a03f88c-8d48-4f0f-b878-2c47d3ad94b8'::uuid) with check ((select auth.uid())='4a03f88c-8d48-4f0f-b878-2c47d3ad94b8'::uuid);
alter table beleg_internal.audit enable row level security;
grant select,insert,update,delete on beleg_internal.audit to authenticated;
create policy owner_only on beleg_internal.audit for all to authenticated using ((select auth.uid())='4a03f88c-8d48-4f0f-b878-2c47d3ad94b8'::uuid) with check ((select auth.uid())='4a03f88c-8d48-4f0f-b878-2c47d3ad94b8'::uuid);
revoke all on beleg_internal.config from authenticated;
revoke all on beleg_internal.audit from authenticated;
