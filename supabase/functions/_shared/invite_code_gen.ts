import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

/** Unambiguous charset (no 0/O, 1/I/L). */
export const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

export const ADMIN_CODE_LENGTH = 8;
export const UNIT_CODE_LENGTH = 5;

/** ~1.1e12 admin codes, ~33M unit codes — collision probability negligible with DB check. */
export function normalizeInviteCode(raw: string): string {
  return raw.trim().toUpperCase().replace(/[^A-Z0-9]/g, "");
}

/** Cryptographically random code of exact [length] using CODE_ALPHABET. */
export function randomInviteCode(length: number): string {
  const alphabet = CODE_ALPHABET;
  const n = alphabet.length;
  const bytes = crypto.getRandomValues(new Uint8Array(length));
  let s = "";
  for (let i = 0; i < length; i++) {
    s += alphabet[bytes[i]! % n];
  }
  return s;
}

function reservedCodes(): Set<string> {
  const reserved = new Set<string>();
  const superRaw = Deno.env.get("SUPERADMIN_ACCESS_CODE")?.trim();
  if (superRaw && superRaw.length >= 4) {
    reserved.add(normalizeInviteCode(superRaw));
  }
  return reserved;
}

/**
 * Returns a code not present in invite_codes (any type/status) and not reserved.
 * Admin (8) and unit (5) codes share one global namespace.
 */
export async function allocateUniqueInviteCode(
  supabase: ReturnType<typeof createClient>,
  length: number,
): Promise<string | null> {
  const reserved = reservedCodes();
  const maxAttempts = 64;

  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    const code = randomInviteCode(length);
    if (code.length !== length || reserved.has(code)) {
      continue;
    }

    const { data, error } = await supabase
      .from("invite_codes")
      .select("id")
      .eq("code", code)
      .maybeSingle();

    if (error) {
      console.error("invite_codes uniqueness check", error);
      return null;
    }

    if (!data) {
      return code;
    }
  }

  return null;
}

/** True when Postgres reports a unique violation on invite_codes.code. */
export function isInviteCodeDuplicateError(
  err: { code?: string; message?: string } | null,
): boolean {
  if (!err) {
    return false;
  }
  if (err.code === "23505") {
    return true;
  }
  const msg = (err.message ?? "").toLowerCase();
  return msg.includes("duplicate") || msg.includes("unique");
}
