-- Execute este SQL no Supabase > SQL Editor.
-- A tabela permite que cada usuário veja e altere seus próprios oradores
-- em qualquer dispositivo ao entrar com a mesma conta.

create extension if not exists pgcrypto;

create table if not exists public.oradores (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  nome text not null,
  tema text not null,
  congregacao text not null,
  created_at timestamptz not null default now()
);

alter table public.oradores enable row level security;

drop policy if exists "oradores_select_own" on public.oradores;
create policy "oradores_select_own"
on public.oradores for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "oradores_insert_own" on public.oradores;
create policy "oradores_insert_own"
on public.oradores for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "oradores_update_own" on public.oradores;
create policy "oradores_update_own"
on public.oradores for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "oradores_delete_own" on public.oradores;
create policy "oradores_delete_own"
on public.oradores for delete
to authenticated
using (auth.uid() = user_id);

create index if not exists oradores_user_id_idx on public.oradores(user_id);


-- Campos adicionais usados no convite conforme o modelo enviado.
alter table public.oradores add column if not exists data_discurso date;
alter table public.oradores add column if not exists horario text default '09:00';
alter table public.oradores add column if not exists periodo text default 'Manhã';
