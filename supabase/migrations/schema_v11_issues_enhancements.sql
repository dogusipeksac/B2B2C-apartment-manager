-- Issue list metadata (optional columns; edge function tolerates missing columns).
alter table public.issues
  add column if not exists location_code text,
  add column if not exists public_code text;

create index if not exists issues_building_created_idx
  on public.issues (building_id, created_at desc);
