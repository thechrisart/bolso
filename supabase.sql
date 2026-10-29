-- Bolso: banco de dados no Supabase
-- Cole tudo no SQL Editor do Supabase e clique em "Run". Pode rodar mais de uma vez sem problema.

-- Um registro por mês de cada usuário. O mês inteiro (receitas, contas, gastos, extras, anotações) fica em "data".
create table if not exists public.months (
  user_id    uuid        not null default auth.uid() references auth.users (id) on delete cascade,
  id         text        not null check (id ~ '^[0-9]{4}-[0-9]{2}$'),  -- ex.: 2026-10
  data       jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

-- Cada pessoa só enxerga e altera os próprios meses.
alter table public.months enable row level security;

drop policy if exists "ver meus meses"     on public.months;
drop policy if exists "criar meus meses"   on public.months;
drop policy if exists "editar meus meses"  on public.months;
drop policy if exists "apagar meus meses"  on public.months;

create policy "ver meus meses"    on public.months for select to authenticated using ((select auth.uid()) = user_id);
create policy "criar meus meses"  on public.months for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "editar meus meses" on public.months for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "apagar meus meses" on public.months for delete to authenticated using ((select auth.uid()) = user_id);

grant select, insert, update, delete on public.months to authenticated;
revoke all on public.months from anon;

-- Atualização ao vivo entre celular, tablet e computador.
alter table public.months replica identity full;
do $$ begin
  alter publication supabase_realtime add table public.months;
exception when duplicate_object then null; end $$;
