-- rls_auto_enable() backs the `ensure_rls` event trigger (enables RLS on new
-- tables in public). Keep the protection; just remove API-role EXECUTE so it
-- isn't exposed via /rest/v1/rpc. It only exists on the hosted project.
do $$
begin
  if to_regprocedure('public.rls_auto_enable()') is not null then
    revoke execute on function public.rls_auto_enable() from public, anon, authenticated;
  end if;
end $$;
