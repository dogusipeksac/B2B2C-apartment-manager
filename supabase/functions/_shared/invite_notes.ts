/** Trim and cap optional invite code notes (Postgres `invite_codes.notes`). */
export function parseInviteNotes(
  raw: string | undefined | null,
): string | null {
  if (raw == null) {
    return null;
  }
  const trimmed = raw.trim();
  if (trimmed.length === 0) {
    return null;
  }
  return trimmed.length > 500 ? trimmed.slice(0, 500) : trimmed;
}
