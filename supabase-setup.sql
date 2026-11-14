-- Run this once in Supabase -> SQL Editor -> New query
drop table if exists tracker_data;   -- the empty table from the earlier step

create table tracker_sections (
  user_id uuid not null references auth.users(id) on delete cascade,
  section text not null,
  j text not null,
  t bigint not null default 0,
  primary key (user_id, section)
);

alter table tracker_sections enable row level security;

create policy "own rows only" on tracker_sections
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

grant select, insert, update, delete on tracker_sections to authenticated;

alter publication supabase_realtime add table tracker_sections;

-- lets a signed-in user delete their own account (required by Google Play)
create or replace function delete_my_account() returns void
language sql security definer set search_path = '' as $$
  delete from auth.users where id = auth.uid();
$$;
revoke all on function delete_my_account() from public, anon;
grant execute on function delete_my_account() to authenticated;
