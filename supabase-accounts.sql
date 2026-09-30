-- ============================================================
-- Cuentas de usuario (sin email): apodo + PIN de 4 dígitos.
-- Los datos de progreso se guardan por usuario y se pueden
-- recuperar en otro dispositivo entrando con apodo + PIN.
--
-- Seguro: la tabla NO es accesible directamente por la clave
-- pública (RLS sin políticas). Solo se toca a través de estas
-- funciones SECURITY DEFINER, que exigen el PIN correcto. El PIN
-- se guarda cifrado (bcrypt), nunca en claro.
--
-- Pegar en Supabase -> SQL Editor -> New query -> Run.
-- ============================================================
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  uid        text primary key,                 -- apodo normalizado (minúsculas)
  nick       text not null,
  section    text not null,
  pin_hash   text not null,
  state      jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
-- sin políticas => la clave anónima no puede leer/escribir la tabla directamente

-- Crear cuenta
create or replace function public.mm_register(p_nick text, p_section text, p_pin text, p_state jsonb default '{}')
returns json language plpgsql security definer set search_path=public, extensions as $$
declare v_uid text; begin
  v_uid := lower(btrim(p_nick));
  if length(v_uid) < 2 then return json_build_object('ok',false,'error','nick_short'); end if;
  if p_pin !~ '^[0-9]{4}$' then return json_build_object('ok',false,'error','pin_format'); end if;
  if exists(select 1 from profiles where uid=v_uid) then return json_build_object('ok',false,'error','taken'); end if;
  insert into profiles(uid,nick,section,pin_hash,state)
    values (v_uid, btrim(p_nick), p_section, crypt(p_pin, gen_salt('bf')), coalesce(p_state,'{}'::jsonb));
  return json_build_object('ok',true);
end $$;

-- Entrar (devuelve el estado si el PIN coincide)
create or replace function public.mm_login(p_nick text, p_pin text)
returns json language plpgsql security definer set search_path=public, extensions as $$
declare r profiles; begin
  select * into r from profiles where uid=lower(btrim(p_nick));
  if not found then return json_build_object('ok',false,'error','not_found'); end if;
  if r.pin_hash <> crypt(p_pin, r.pin_hash) then return json_build_object('ok',false,'error','bad_pin'); end if;
  return json_build_object('ok',true,'nick',r.nick,'section',r.section,'state',r.state);
end $$;

-- Guardar estado (exige PIN correcto)
create or replace function public.mm_save(p_nick text, p_pin text, p_state jsonb, p_section text default null)
returns json language plpgsql security definer set search_path=public, extensions as $$
declare r profiles; begin
  select * into r from profiles where uid=lower(btrim(p_nick));
  if not found then return json_build_object('ok',false,'error','not_found'); end if;
  if r.pin_hash <> crypt(p_pin, r.pin_hash) then return json_build_object('ok',false,'error','bad_pin'); end if;
  update profiles set state=p_state, section=coalesce(p_section,section), updated_at=now() where uid=r.uid;
  return json_build_object('ok',true);
end $$;

grant execute on function public.mm_register(text,text,text,jsonb) to anon;
grant execute on function public.mm_login(text,text) to anon;
grant execute on function public.mm_save(text,text,jsonb,text) to anon;
