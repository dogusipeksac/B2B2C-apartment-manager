/** Concatenate PostgREST / Postgres error fields for matching. */
export function pgErrorText(err: {
  message?: string;
  details?: string;
  hint?: string;
  code?: string;
} | null): string {
  if (!err) return "";
  return [err.message, err.details, err.hint, err.code]
    .filter((x) => x != null && String(x).length > 0)
    .map((x) => String(x))
    .join(" ")
    .toLowerCase();
}

/** True when error indicates `column` is absent (migration not applied). */
export function isMissingColumn(
  err: {
    message?: string;
    details?: string;
    hint?: string;
    code?: string;
  } | null,
  column: string,
): boolean {
  const t = pgErrorText(err);
  const col = column.toLowerCase();
  if (!t.includes(col)) return false;
  return (
    t.includes("does not exist") ||
    t.includes("schema cache") ||
    t.includes("could not find") ||
    t.includes("undefined_column") ||
    t.includes("42703")
  );
}
