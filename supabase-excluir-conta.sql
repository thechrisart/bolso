-- Bolso: permite que cada pessoa exclua a própria conta pelo app (exigência da App Store).
-- Cole no SQL Editor do Supabase e clique em "Run". Pode rodar mais de uma vez.

create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Faça login para excluir a conta';
  end if;
  delete from public.months where user_id = auth.uid();
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
