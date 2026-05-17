-- =============================================================================
-- schema_v9_invite_code_global_unique.sql
-- Documents global uniqueness: admin (8-char) and unit (5-char) share invite_codes.code.
-- =============================================================================

COMMENT ON COLUMN public.invite_codes.code IS
  'Globally unique (all types/statuses). Random generation checks DB before insert.';
