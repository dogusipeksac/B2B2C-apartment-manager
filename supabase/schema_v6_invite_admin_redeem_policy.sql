-- -----------------------------------------------------------------------------
-- schema_v6_invite_admin_redeem_policy.sql
-- Admin invite codes: single_use (default) vs reusable (repeat redeem).
-- Apply after schema_v2.sql (invite_codes exists).
-- -----------------------------------------------------------------------------
ALTER TABLE public.invite_codes
  ADD COLUMN IF NOT EXISTS admin_redeem_policy text NOT NULL DEFAULT 'single_use';

COMMENT ON COLUMN public.invite_codes.admin_redeem_policy IS
  'admin codes only: single_use = consume on redeem; reusable = keep active for reinstall.';

-- Optional: enforce allowed values at DB level
ALTER TABLE public.invite_codes DROP CONSTRAINT IF EXISTS invite_codes_admin_redeem_policy_check;

ALTER TABLE public.invite_codes
  ADD CONSTRAINT invite_codes_admin_redeem_policy_check CHECK (
    admin_redeem_policy IN ('single_use', 'reusable')
  );
