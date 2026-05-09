-- =============================================================================
-- schema_v2.sql — Invite-code auth model (apply after schema.sql on existing DB)
-- =============================================================================
-- Adds invite_codes + devices, relaxes profiles.id FK from auth.users, optional
-- full_name. Safe to run once; uses IF NOT EXISTS / DROP IF EXISTS where needed.
-- =============================================================================

-- ENUMS (invite flow)
DO $$
BEGIN
  CREATE TYPE public.invite_code_type AS ENUM ('admin', 'unit');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE public.invite_code_status AS ENUM ('active', 'used', 'expired', 'revoked');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- -----------------------------------------------------------------------------
-- PROFILES: decouple from auth.users (device-based accounts; Phase 11 may relink)
-- -----------------------------------------------------------------------------
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;

ALTER TABLE public.profiles
  ALTER COLUMN id SET DEFAULT gen_random_uuid();

ALTER TABLE public.profiles
  ALTER COLUMN full_name DROP NOT NULL;

COMMENT ON COLUMN public.profiles.id IS
  'PK; may match auth.users(id) if linked, else standalone UUID from gen_random_uuid().';

-- -----------------------------------------------------------------------------
-- INVITE_CODES (ADMIN_INVITE_CODE 8 chars, UNIT_INVITE_CODE 5 chars — enforced in app / edge)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.invite_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  code_type public.invite_code_type NOT NULL,
  status public.invite_code_status NOT NULL DEFAULT 'active',
  building_id uuid REFERENCES public.buildings (id) ON DELETE CASCADE,
  unit_id uuid REFERENCES public.units (id) ON DELETE CASCADE,
  created_by uuid REFERENCES public.profiles (id),
  used_by_device_id text,
  used_at timestamptz,
  expires_at timestamptz DEFAULT (now() + interval '90 days'),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT invite_codes_admin_no_unit CHECK (
    code_type <> 'admin' OR (building_id IS NULL AND unit_id IS NULL)
  ),
  CONSTRAINT invite_codes_unit_has_building CHECK (
    code_type <> 'unit' OR building_id IS NOT NULL
  )
);

CREATE INDEX IF NOT EXISTS idx_invite_codes_code ON public.invite_codes (code);
CREATE INDEX IF NOT EXISTS idx_invite_codes_active
  ON public.invite_codes (status)
  WHERE status = 'active';

COMMENT ON TABLE public.invite_codes IS
  'Pre-shared codes: admin = one-shot building creation right; unit = resident join.';

-- -----------------------------------------------------------------------------
-- DEVICES (local session anchor; Edge Function uses service role)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id text NOT NULL UNIQUE,
  profile_id uuid REFERENCES public.profiles (id) ON DELETE SET NULL,
  building_id uuid REFERENCES public.buildings (id),
  unit_id uuid REFERENCES public.units (id),
  role public.user_role NOT NULL,
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_devices_device ON public.devices (device_id);
CREATE INDEX IF NOT EXISTS idx_devices_profile ON public.devices (profile_id);

COMMENT ON TABLE public.devices IS
  'One row per physical device_id; session_token issued by redeem_code Edge Function (client-side).';

-- -----------------------------------------------------------------------------
-- RLS: invite_codes — anon can read active codes (validation preview); creators via auth (optional)
-- -----------------------------------------------------------------------------
ALTER TABLE public.invite_codes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS anyone_validate_active_code ON public.invite_codes;
CREATE POLICY anyone_validate_active_code
  ON public.invite_codes
  FOR SELECT
  USING (
    status = 'active'
    AND (expires_at IS NULL OR expires_at > now())
  );

DROP POLICY IF EXISTS creator_manage_own_codes ON public.invite_codes;
CREATE POLICY creator_manage_own_codes
  ON public.invite_codes
  FOR ALL
  USING (created_by = auth.uid())
  WITH CHECK (created_by = auth.uid());

-- -----------------------------------------------------------------------------
-- RLS: devices — optional device-scoped access when app sets app.device_id (Postgres custom var)
-- Edge Function uses service role and bypasses RLS.
-- -----------------------------------------------------------------------------
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS self_device ON public.devices;
CREATE POLICY self_device
  ON public.devices
  FOR ALL
  USING (
    device_id IS NOT NULL
    AND device_id = current_setting('app.device_id', true)
  )
  WITH CHECK (
    device_id IS NOT NULL
    AND device_id = current_setting('app.device_id', true)
  );
