-- Owner selected admin-printed physical QR fulfillment after payment confirmation.
-- Add only a payment-status requirement to the existing public gift-read branch.
-- No roles, authentication, gateway credentials, checkout, tables, or order-write behavior change.
do $gate$
declare f text; old_guard text := 'or not o.audio_approved or o.audio_key is null then'; new_guard text := 'or o.payment_status<>''paid'' or not o.audio_approved or o.audio_key is null then';
begin
 select pg_get_functiondef('beleg_internal.gateway(text,text,text,jsonb)'::regprocedure) into f;
 if position(new_guard in f)>0 then return; end if;
 if (length(f)-length(replace(f,old_guard,'')))/length(old_guard)<>1 then raise exception 'Expected exactly one public gift guard; no change made';end if;
 execute replace(f,old_guard,new_guard);
end $gate$;