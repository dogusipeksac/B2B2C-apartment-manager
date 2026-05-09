-- -----------------------------------------------------------------------------
-- schema_v5_votes_unit_fk.sql — votes.unit_id must not block unit/building delete
-- Apply once after schema.sql (votes table exists).
-- -----------------------------------------------------------------------------
DO $$
BEGIN
  ALTER TABLE public.votes DROP CONSTRAINT IF EXISTS votes_unit_id_fkey;
EXCEPTION
  WHEN undefined_object THEN NULL;
END $$;

ALTER TABLE public.votes
  ADD CONSTRAINT votes_unit_id_fkey
  FOREIGN KEY (unit_id)
  REFERENCES public.units(id)
  ON DELETE SET NULL;

COMMENT ON CONSTRAINT votes_unit_id_fkey ON public.votes IS
  'Unit removal (e.g. building cascade) clears vote.unit_id instead of blocking.';
