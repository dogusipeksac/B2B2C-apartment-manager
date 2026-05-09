-- =============================================================================
-- schema_after_v2_bundle.sql — Tek dosyada şema ekleri (sıfır/temiz DB sonrası)
-- Önce schema.sql + schema_v2.sql (+ istenirse rls.sql) çalıştırıldıktan sonra bu dosyayı çalıştırın.
-- İçerik: schema_v3_devices_session + schema_v6_invite_admin_redeem_policy
-- =============================================================================

-- schema_v3 — Edge oturum doğrulaması için devices.session_token
ALTER TABLE public.devices
  ADD COLUMN IF NOT EXISTS session_token text;

COMMENT ON COLUMN public.devices.session_token IS
  'Issued by redeem_code; required by finalize_building_setup alongside device_id.';

-- schema_v6 — Yönetici davet kodu: tek kullanımlı (single_use) veya çoklu kurulum (reusable)
ALTER TABLE public.invite_codes
  ADD COLUMN IF NOT EXISTS admin_redeem_policy text NOT NULL DEFAULT 'single_use';

COMMENT ON COLUMN public.invite_codes.admin_redeem_policy IS
  'admin codes only: single_use = consume on redeem; reusable = keep active for reinstall.';

ALTER TABLE public.invite_codes DROP CONSTRAINT IF EXISTS invite_codes_admin_redeem_policy_check;

ALTER TABLE public.invite_codes
  ADD CONSTRAINT invite_codes_admin_redeem_policy_check CHECK (
    admin_redeem_policy IN ('single_use', 'reusable')
  );
