-- ============================================================
-- Esquema del ranking para "IESE Calculation Prep".
-- Pégalo en: Supabase -> tu proyecto -> SQL Editor -> New query -> Run.
-- Crea la tabla de puntuaciones y deja que cualquiera (clave anon)
-- pueda INSERTAR su marca y LEER el ranking, pero NO borrar ni editar.
-- ============================================================

create table if not exists public.scores (
  id           bigint generated always as identity primary key,
  created_at   timestamptz not null default now(),
  nick         text not null check (char_length(nick) between 1 and 24),
  section      text not null check (char_length(section) between 1 and 12),
  client_id    text,                                  -- id anónimo del dispositivo (anti-duplicado suave)
  challenge_id text not null,                          -- p.ej. "2026-09-30" (reto del día)
  score        int  not null check (score >= 0 and score <= 1000000),
  correct      int  not null default 0,
  total        int  not null default 0,
  seconds      numeric not null default 0
);

alter table public.scores enable row level security;

-- Insertar: permitido a la clave anónima (los estudiantes)
drop policy if exists "anon insert scores" on public.scores;
create policy "anon insert scores" on public.scores
  for insert to anon with check (true);

-- Leer: permitido a la clave anónima (para mostrar el ranking)
drop policy if exists "anon read scores" on public.scores;
create policy "anon read scores" on public.scores
  for select to anon using (true);

-- Índice para ordenar rápido el ranking de cada reto
create index if not exists scores_challenge_score
  on public.scores (challenge_id, score desc);
