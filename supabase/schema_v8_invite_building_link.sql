-- =============================================================================
-- schema_v8_invite_building_link.sql
-- Admin invite codes may store completed building_id (phone-independent re-login).
-- Used codes with a building remain readable for client preview (RLS).
-- =============================================================================

ALTER TABLE public.invite_codes DROP CONSTRAINT IF EXISTS invite_codes_admin_no_unit;

ALTER TABLE public.invite_codes
  ADD CONSTRAINT invite_codes_admin_no_unit_id CHECK (
    code_type <> 'admin' OR unit_id IS NULL
  );

COMMENT ON COLUMN public.invite_codes.building_id IS
  'unit: target building; admin: populated when manager setup completes.';

-- Link completed buildings to admin invites from existing device rows.
UPDATE public.invite_codes ic
SET building_id = d.building_id
FROM public.devices d
WHERE d.admin_invite_code_id = ic.id
  AND ic.code_type = 'admin'::public.invite_code_type
  AND ic.building_id IS NULL
  AND d.building_id IS NOT NULL;

-- Link resident devices to unit invite rows (re-login on another phone).
UPDATE public.devices d
SET admin_invite_code_id = ic.id
FROM public.invite_codes ic
WHERE ic.code_type = 'unit'::public.invite_code_type
  AND ic.used_by_device_id = d.device_id
  AND d.role = 'resident'::public.user_role
  AND d.admin_invite_code_id IS NULL;

-- Allow preview of used codes that still grant access to a building/unit.
DROP POLICY IF EXISTS anyone_validate_active_code ON public.invite_codes;

CREATE POLICY anyone_validate_active_code
  ON public.invite_codes
  FOR SELECT
  USING (
    (
      status = 'active'
      AND (expires_at IS NULL OR expires_at > now())
    )
    OR (
      status = 'used'
      AND building_id IS NOT NULL
      AND (expires_at IS NULL OR expires_at > now())
    )
    OR (
      status = 'used'
      AND code_type = 'admin'::public.invite_code_type
      AND (expires_at IS NULL OR expires_at > now())
    )
  );
