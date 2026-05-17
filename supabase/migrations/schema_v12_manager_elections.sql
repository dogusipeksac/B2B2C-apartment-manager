-- Manager elections: secret ballot (one vote per unit).

create type public.manager_election_status as enum ('draft', 'active', 'closed');

create table public.manager_elections (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null references public.buildings(id) on delete cascade,
  title text not null,
  description text,
  status public.manager_election_status not null default 'draft',
  closes_at timestamptz,
  created_by uuid references public.profiles(id) on delete set null,
  started_at timestamptz,
  closed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.manager_election_candidates (
  id uuid primary key default gen_random_uuid(),
  election_id uuid not null references public.manager_elections(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  position int not null default 0,
  created_at timestamptz not null default now(),
  unique (election_id, profile_id)
);

create table public.manager_election_votes (
  id uuid primary key default gen_random_uuid(),
  election_id uuid not null references public.manager_elections(id) on delete cascade,
  candidate_id uuid not null references public.manager_election_candidates(id) on delete cascade,
  unit_id uuid not null references public.units(id) on delete cascade,
  device_id text not null,
  created_at timestamptz not null default now(),
  unique (election_id, unit_id)
);

create index manager_elections_building_status_idx
  on public.manager_elections (building_id, status);

create index manager_election_candidates_election_idx
  on public.manager_election_candidates (election_id);

create index manager_election_votes_election_idx
  on public.manager_election_votes (election_id);

create trigger trg_manager_elections_upd
  before update on public.manager_elections
  for each row execute function set_updated_at();

alter table public.manager_elections enable row level security;
alter table public.manager_election_candidates enable row level security;
alter table public.manager_election_votes enable row level security;
