-- -----------------------------------------------------------------------------
-- Session token persisted server-side (paired with device_id for Edge Functions).
-- Apply after schema_v2.sql
-- -----------------------------------------------------------------------------
ALTER TABLE public.devices
  ADD COLUMN IF NOT EXISTS session_token text;

COMMENT ON COLUMN public.devices.session_token IS
  'Issued by redeem_code; required by finalize_building_setup alongside device_id.';
