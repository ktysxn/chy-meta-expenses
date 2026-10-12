begin;
insert into auth.users values ('11111111-1111-4111-8111-111111111111'),('22222222-2222-4222-8222-222222222222');
insert into cheyenne_private.members values('11111111-1111-4111-8111-111111111111');
set local role anon;
do $$ begin
  begin perform * from public.cheyenne_state; raise exception 'Anonymous read allowed'; exception when insufficient_privilege then null; end;
  begin perform public.save_cheyenne_state(0,'{"expenses":[],"trips":[]}'); raise exception 'Anonymous write allowed'; exception when insufficient_privilege then null; end;
end $$;
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','22222222-2222-4222-8222-222222222222',true);
do $$ begin
  if public.cheyenne_can_sync() then raise exception 'Unapproved account allowed'; end if;
  begin perform public.save_cheyenne_state(0,'{"expenses":[],"trips":[]}'); raise exception 'Unapproved write allowed'; exception when insufficient_privilege then null; end;
end $$;
select set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
do $$ declare r record; begin
  select * into r from public.save_cheyenne_state(0,'{"expenses":[],"trips":[]}');
  if not r.accepted or r.current_revision <> 1 then raise exception 'Initial save failed'; end if;
  select * into r from public.save_cheyenne_state(1,'{"expenses":[],"trips":[],"test":"new"}');
  if not r.accepted or r.current_revision <> 2 then raise exception 'Owner update failed'; end if;
  select * into r from public.save_cheyenne_state(1,'{"expenses":[],"trips":[],"test":"stale"}');
  if r.accepted or r.current_data->>'test' <> 'new' then raise exception 'Stale update overwrote data'; end if;
  begin update public.cheyenne_state set revision=99; raise exception 'Direct update allowed'; exception when insufficient_privilege then null; end;
  insert into storage.objects(bucket_id,name) values('cheyenne-receipts','11111111-1111-4111-8111-111111111111/hash');
  begin insert into storage.objects(bucket_id,name) values('cheyenne-receipts','22222222-2222-4222-8222-222222222222/hash'); raise exception 'Foreign receipt upload allowed'; exception when insufficient_privilege then null; end;
end $$;
select set_config('request.jwt.claim.sub','22222222-2222-4222-8222-222222222222',true);
do $$ begin
  if exists(select 1 from public.cheyenne_state) then raise exception 'Foreign records exposed'; end if;
  if exists(select 1 from storage.objects) then raise exception 'Foreign receipts exposed'; end if;
end $$;
reset role;
do $$ begin if exists(select 1 from storage.buckets where id='cheyenne-receipts' and public) then raise exception 'Receipt bucket public'; end if; end $$;
rollback;
