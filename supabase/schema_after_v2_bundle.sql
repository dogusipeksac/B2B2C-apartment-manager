-- =============================================================================
-- schema_after_v2_bundle.sql — Tek dosyada şema ekleri (sıfır/temiz DB sonrası)
-- Önce schema.sql + schema_v2.sql (+ istenirse rls.sql) çalıştırıldıktan sonra bu dosyayı çalıştırın.
-- İçerik: schema_v3_devices_session + schema_v6_invite_admin_redeem_policy + schema_v7_devices_admin_invite_code
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

-- schema_v7 — Aynı yönetici koduyla tekrar girişte kurulum atlaması için cihaz ↔ kod bağlantısı
ALTER TABLE public.devices
  ADD COLUMN IF NOT EXISTS admin_invite_code_id uuid REFERENCES public.invite_codes(id)
    ON DELETE SET NULL;

COMMENT ON COLUMN public.devices.admin_invite_code_id IS
  'Admin invite row last redeemed on this device; resume session without duplicate setup.';

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

-- schema_v8 — admin invite ↔ completed building; RLS for used codes
ALTER TABLE public.invite_codes DROP CONSTRAINT IF EXISTS invite_codes_admin_no_unit;

ALTER TABLE public.invite_codes
  ADD CONSTRAINT invite_codes_admin_no_unit_id CHECK (
    code_type <> 'admin' OR unit_id IS NULL
  );

UPDATE public.invite_codes ic
SET building_id = d.building_id
FROM public.devices d
WHERE d.admin_invite_code_id = ic.id
  AND ic.code_type = 'admin'::public.invite_code_type
  AND ic.building_id IS NULL
  AND d.building_id IS NOT NULL;

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
