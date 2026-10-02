-- ============================================================
-- Admin usage stats (only returns data to the admin account).
-- Reads aggregates from the profiles table (which is otherwise
-- locked by RLS). Protected by the admin's own nick + PIN.
--
-- Paste in Supabase -> SQL Editor -> New query -> Run.
-- The admin account is the profile whose uid = 'pedro bodega'
-- (i.e. nick "Pedro Bodega"). Change the literal below if needed.
-- ============================================================
create or replace function public.mm_admin(p_nick text, p_pin text)
returns json language plpgsql security definer set search_path=public, extensions as $$
declare adm profiles; today date := current_date; res json;
begin
  select * into adm from profiles where uid='pedro bodega';
  if not found then return json_build_object('ok',false,'error','no_admin'); end if;
  if lower(btrim(p_nick)) <> 'pedro bodega' then return json_build_object('ok',false,'error','forbidden'); end if;
  if adm.pin_hash <> crypt(p_pin, adm.pin_hash) then return json_build_object('ok',false,'error','bad_pin'); end if;
  select json_build_object(
    'ok', true,
    'total_users',  (select count(*) from profiles),
    'new_today',    (select count(*) from profiles where created_at::date = today),
    'new_7d',       (select count(*) from profiles where created_at >= now()-interval '7 days'),
    'active_today', (select count(*) from profiles where updated_at::date = today),
    'active_7d',    (select count(*) from profiles where updated_at >= now()-interval '7 days'),
    'total_solved', (select coalesce(sum((state->'prog'->>'solved')::int),0) from profiles),
    'total_seconds',(select coalesce(sum(
                        (select coalesce(sum((v->>'sum')::numeric),0)
                           from jsonb_each(coalesce(state->'stats'->'byOp','{}'::jsonb)) as e(k,v))
                      ),0) from profiles),
    'by_section',   (select coalesce(json_object_agg(section, c),'{}') from (select section, count(*) c from profiles group by section) s),
    'new_by_day',   (select coalesce(json_object_agg(d, c),'{}') from (select created_at::date d, count(*) c from profiles where created_at >= now()-interval '14 days' group by 1) x),
    'active_by_day',(select coalesce(json_object_agg(d, c),'{}') from (select updated_at::date d, count(*) c from profiles where updated_at >= now()-interval '14 days' group by 1) y)
  ) into res;
  return res;
end $$;

grant execute on function public.mm_admin(text,text) to anon;
