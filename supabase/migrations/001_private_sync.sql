-- Private Cheyenne snapshots and receipts. No account IDs or personal records belong here.
create schema if not exists cheyenne_private;
revoke all on schema cheyenne_private from public, anon, authenticated;
create table if not exists cheyenne_private.members (
  user_id uuid primary key references auth.users(id) on delete cascade
);
revoke all on cheyenne_private.members from public, anon, authenticated;

create or replace function public.cheyenne_can_sync()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from cheyenne_private.members where user_id = auth.uid());
$$;
revoke all on function public.cheyenne_can_sync() from public, anon;
grant execute on function public.cheyenne_can_sync() to authenticated;

create table if not exists public.cheyenne_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  revision bigint not null default 1 check (revision > 0),
  data jsonb not null check (jsonb_typeof(data) = 'object'),
  updated_at timestamptz not null default now()
);
alter table public.cheyenne_state enable row level security;
revoke all on public.cheyenne_state from public, anon, authenticated;
grant select on public.cheyenne_state to authenticated;
drop policy if exists cheyenne_owner_read on public.cheyenne_state;
create policy cheyenne_owner_read on public.cheyenne_state for select to authenticated
  using (user_id = (select auth.uid()) and (select public.cheyenne_can_sync()));

-- Writes must compare the revision atomically; direct browser UPDATE is intentionally absent.
create or replace function public.save_cheyenne_state(p_expected_revision bigint, p_data jsonb)
returns table(accepted boolean, current_revision bigint, current_data jsonb, saved_at timestamptz)
language plpgsql security definer set search_path = '' as $$
declare v_user uuid := auth.uid(); v_count integer;
begin
  if v_user is null or not public.cheyenne_can_sync() then
    raise exception 'This account is not authorized to sync' using errcode = '42501';
  end if;
  if p_expected_revision is null or p_expected_revision < 0 then
    raise exception 'Invalid revision' using errcode = '22023';
  end if;
  if jsonb_typeof(p_data) is distinct from 'object'
     or jsonb_typeof(p_data->'expenses') is distinct from 'array'
     or jsonb_typeof(p_data->'trips') is distinct from 'array'
     or pg_column_size(p_data) > 10485760 then
    raise exception 'Invalid dashboard snapshot' using errcode = '22023';
  end if;
  if p_expected_revision = 0 then
    insert into public.cheyenne_state(user_id, revision, data)
      values(v_user, 1, p_data) on conflict(user_id) do nothing;
  else
    update public.cheyenne_state set data = p_data, revision = revision + 1, updated_at = now()
      where user_id = v_user and revision = p_expected_revision;
  end if;
  get diagnostics v_count = row_count;
  return query select v_count = 1, s.revision, s.data, s.updated_at
    from public.cheyenne_state s where s.user_id = v_user;
end;
$$;
revoke all on function public.save_cheyenne_state(bigint,jsonb) from public, anon;
grant execute on function public.save_cheyenne_state(bigint,jsonb) to authenticated;

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
  values('cheyenne-receipts','cheyenne-receipts',false,10485760,
    array['image/jpeg','image/png','image/webp','image/heic','image/heif','application/pdf'])
  on conflict(id) do update set public = false, file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;
drop policy if exists cheyenne_receipt_read on storage.objects;
drop policy if exists cheyenne_receipt_insert on storage.objects;
create policy cheyenne_receipt_read on storage.objects for select to authenticated
  using (bucket_id = 'cheyenne-receipts' and (storage.foldername(name))[1] = (select auth.uid()::text)
    and (select public.cheyenne_can_sync()));
create policy cheyenne_receipt_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'cheyenne-receipts' and (storage.foldername(name))[1] = (select auth.uid()::text)
    and (select public.cheyenne_can_sync()));
-- Receipt paths are content-addressed and immutable. No anonymous access or public URLs.
-- After creating the app's one Auth user, add its ID to cheyenne_private.members via a trusted admin.
