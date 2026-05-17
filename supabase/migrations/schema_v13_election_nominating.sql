-- Election phases: draft → nominating (candidates) → active (voting) → closed

ALTER TYPE public.manager_election_status ADD VALUE IF NOT EXISTS 'nominating';

ALTER TABLE public.manager_elections
  ADD COLUMN IF NOT EXISTS nominations_close_at timestamptz;

COMMENT ON COLUMN public.manager_elections.nominations_close_at IS
  'Optional end of nomination period; voting may start manually or after this time.';
