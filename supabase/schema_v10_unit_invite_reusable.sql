-- Unit (resident) invite codes stay active for repeat login; revoke via manager/superadmin.
UPDATE public.invite_codes
SET status = 'active'
WHERE code_type = 'unit'
  AND status = 'used';

COMMENT ON COLUMN public.invite_codes.notes IS
  'Optional label: manager note for admin codes, resident/unit note for unit codes.';
