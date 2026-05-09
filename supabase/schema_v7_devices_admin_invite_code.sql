-- -----------------------------------------------------------------------------
-- schema_v7_devices_admin_invite_code.sql
-- Hangi admin davet kodunun bu cihazda kullanıldığını saklar; aynı kodla
-- tekrar girişte apartman kurulumu atlanıp doğrudan ana sayfa için gerekli.
-- Apply after schema_v2.sql (devices + invite_codes exist).
-- -----------------------------------------------------------------------------
ALTER TABLE public.devices
  ADD COLUMN IF NOT EXISTS admin_invite_code_id uuid REFERENCES public.invite_codes(id)
    ON DELETE SET NULL;

COMMENT ON COLUMN public.devices.admin_invite_code_id IS
  'Admin invite row last redeemed on this device; resume session without duplicate setup.';

-- Best-effort backfill (used_by_device_id üzerinden son admin kodu).
UPDATE public.devices d
SET admin_invite_code_id = sub.id
FROM (
  SELECT DISTINCT ON (ic.used_by_device_id)
    ic.id,
    ic.used_by_device_id
  FROM public.invite_codes ic
  WHERE ic.code_type = 'admin'::public.invite_code_type
  ORDER BY ic.used_by_device_id, ic.used_at DESC NULLS LAST
) sub
WHERE sub.used_by_device_id = d.device_id
  AND d.admin_invite_code_id IS NULL
  AND d.role = 'building_admin'::public.user_role;
