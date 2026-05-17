/**
 * Building-scoped issues: list, create (resident/owner), update status (admin).
 *
 * POST JSON:
 * { "action": "list" | "get" | "create" | "update_status",
 *   "device_id", "session_token",
 *   "issue_id"?: uuid,
 *   "title"?, "description"?, "category"?, "priority"?, "location_code"?, "status"? }
 */
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

import { isMissingColumn } from "../_shared/db_compat.ts";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const MEMBER_ROLES = new Set([
  "building_admin",
  "building_co_admin",
  "accountant",
  "resident",
  "owner",
]);

const CREATE_ROLES = new Set(["resident", "owner"]);

const ADMIN_ROLES = new Set(["building_admin", "building_co_admin"]);

type DeviceRow = {
  profile_id: string | null;
  building_id: string | null;
  unit_id: string | null;
  role: string;
  session_token: string | null;
};

function jsonResponse(
  status: number,
  body: Record<string, unknown>,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function assertDeviceSession(
  supabase: ReturnType<typeof createClient>,
  deviceId: string,
  sessionToken: string,
): Promise<
  | { ok: true; device: DeviceRow & { building_id: string } }
  | { ok: false; status: number; error: string }
> {
  const clientTok = sessionToken.trim();

  const full = await supabase
    .from("devices")
    .select("profile_id, building_id, unit_id, role, session_token")
    .eq("device_id", deviceId)
    .maybeSingle();

  let deviceRow: Record<string, unknown> | null = null;
  let legacyNoSessionColumn = false;

  if (full.error && isMissingColumn(full.error, "session_token")) {
    const leg = await supabase
      .from("devices")
      .select("profile_id, building_id, unit_id, role")
      .eq("device_id", deviceId)
      .maybeSingle();
    if (leg.error) {
      console.error("devices select legacy", leg.error);
      return { ok: false, status: 500, error: "database_error" };
    }
    deviceRow = leg.data as Record<string, unknown> | null;
    legacyNoSessionColumn = true;
  } else if (full.error) {
    console.error("devices select", full.error);
    return { ok: false, status: 500, error: "database_error" };
  } else {
    deviceRow = full.data as Record<string, unknown> | null;
  }

  if (!deviceRow) {
    return { ok: false, status: 404, error: "device_not_found" };
  }

  let dbTok = legacyNoSessionColumn
    ? ""
    : String(deviceRow.session_token ?? "").trim();

  if (!legacyNoSessionColumn && dbTok !== clientTok && clientTok.length > 0) {
    const role = String(deviceRow.role ?? "");
    const hasBuilding =
      deviceRow.building_id !== null &&
      String(deviceRow.building_id).length > 0;
    const canHeal = MEMBER_ROLES.has(role) && hasBuilding;

    if (canHeal) {
      const healIso = new Date().toISOString();
      const { error: healErr } = await supabase
        .from("devices")
        .update({
          session_token: clientTok,
          last_seen_at: healIso,
        })
        .eq("device_id", deviceId);

      if (!healErr) {
        dbTok = clientTok;
      }
    }
  }

  if (legacyNoSessionColumn) {
    if (!clientTok) {
      return { ok: false, status: 401, error: "invalid_session" };
    }
  } else if (dbTok !== clientTok) {
    return { ok: false, status: 401, error: "invalid_session" };
  }

  const role = String(deviceRow.role ?? "");
  if (!MEMBER_ROLES.has(role)) {
    return { ok: false, status: 403, error: "not_building_member" };
  }

  const bid = deviceRow.building_id;
  if (!bid || String(bid).length === 0) {
    return { ok: false, status: 422, error: "building_not_ready" };
  }

  return {
    ok: true,
    device: {
      profile_id: deviceRow.profile_id as string | null,
      building_id: String(bid),
      unit_id: deviceRow.unit_id as string | null,
      role,
      session_token: deviceRow.session_token as string | null,
    },
  };
}

function mapUiCategory(raw: string | undefined): string {
  switch ((raw ?? "").trim().toLowerCase()) {
    case "plumbing":
      return "plumbing";
    case "electric":
      return "electric";
    case "mechanical":
      return "elevator";
    default:
      return "other";
  }
}

function mapUiPriority(raw: string | undefined): string {
  switch ((raw ?? "").trim().toLowerCase()) {
    case "low":
      return "low";
    case "high":
      return "high";
    default:
      return "medium";
  }
}

function mapUiStatus(raw: string | undefined): string | null {
  switch ((raw ?? "").trim().toLowerCase()) {
    case "open":
      return "open";
    case "in_progress":
    case "inprogress":
      return "in_progress";
    case "resolved":
      return "resolved";
    default:
      return null;
  }
}

function initialsFromName(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) {
    return "??";
  }
  if (parts.length === 1) {
    return parts[0].slice(0, 2).toUpperCase();
  }
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

async function nextPublicCode(
  supabase: ReturnType<typeof createClient>,
  buildingId: string,
): Promise<string> {
  const { count, error } = await supabase
    .from("issues")
    .select("id", { count: "exact", head: true })
    .eq("building_id", buildingId);

  if (error) {
    console.error("issues count", error);
    return `#A-${Math.floor(Math.random() * 900 + 100)}`;
  }
  const n = (count ?? 0) + 1;
  return `#A-${n}`;
}

type IssueRow = Record<string, unknown>;

async function profileNames(
  supabase: ReturnType<typeof createClient>,
  ids: string[],
): Promise<Map<string, string>> {
  const map = new Map<string, string>();
  const unique = [...new Set(ids.filter((id) => id.length > 0))];
  if (unique.length === 0) {
    return map;
  }
  const { data, error } = await supabase
    .from("profiles")
    .select("id, full_name")
    .in("id", unique);

  if (error) {
    console.error("profiles names", error);
    return map;
  }
  for (const row of data ?? []) {
    const id = String((row as { id: string }).id);
    const name = String((row as { full_name?: string }).full_name ?? "")
      .trim();
    map.set(id, name);
  }
  return map;
}

async function fetchIssueComments(
  supabase: ReturnType<typeof createClient>,
  issueId: string,
): Promise<Record<string, unknown>[]> {
  const { data, error } = await supabase
    .from("issue_comments")
    .select("id, body, created_at, author_id")
    .eq("issue_id", issueId)
    .order("created_at", { ascending: true });

  if (error) {
    console.error("issue_comments list", error);
    return [];
  }

  const rows = (data ?? []) as Record<string, unknown>[];
  const authorIds = rows
    .map((r) => (r.author_id ? String(r.author_id) : ""))
    .filter((id) => id.length > 0);
  const names = await profileNames(supabase, authorIds);

  return rows.map((row) => {
    const authorId = row.author_id ? String(row.author_id) : "";
    return {
      id: String(row.id),
      body: String(row.body ?? ""),
      created_at: row.created_at,
      author_name: authorId ? (names.get(authorId) ?? "") : "",
    };
  });
}

function stripStatusCommentBody(body: string): string {
  const m = body.match(/^\[status:[a-z_]+\]\s*(.*)$/is);
  return m ? String(m[1] ?? "").trim() : body.trim();
}

async function latestCommentsByIssue(
  supabase: ReturnType<typeof createClient>,
  issueIds: string[],
): Promise<Map<string, { body: string; authorName: string }>> {
  const map = new Map<string, { body: string; authorName: string }>();
  if (issueIds.length === 0) {
    return map;
  }

  const { data, error } = await supabase
    .from("issue_comments")
    .select("issue_id, body, created_at, author_id")
    .in("issue_id", issueIds)
    .order("created_at", { ascending: false });

  if (error) {
    console.error("issue_comments latest", error);
    return map;
  }

  const authorIds: string[] = [];
  for (const row of data ?? []) {
    const aid = (row as { author_id?: string }).author_id;
    if (aid) authorIds.push(String(aid));
  }
  const names = await profileNames(supabase, authorIds);

  for (const raw of data ?? []) {
    const row = raw as Record<string, unknown>;
    const issueId = String(row.issue_id);
    if (map.has(issueId)) {
      continue;
    }
    const authorId = row.author_id ? String(row.author_id) : "";
    map.set(issueId, {
      body: stripStatusCommentBody(String(row.body ?? "")),
      authorName: authorId ? (names.get(authorId) ?? "") : "",
    });
  }
  return map;
}

async function commentCounts(
  supabase: ReturnType<typeof createClient>,
  issueIds: string[],
): Promise<Map<string, number>> {
  const map = new Map<string, number>();
  if (issueIds.length === 0) {
    return map;
  }
  const { data, error } = await supabase
    .from("issue_comments")
    .select("issue_id")
    .in("issue_id", issueIds);

  if (error) {
    console.error("issue_comments count", error);
    return map;
  }
  for (const row of data ?? []) {
    const id = String((row as { issue_id: string }).issue_id);
    map.set(id, (map.get(id) ?? 0) + 1);
  }
  return map;
}

function serializeIssue(
  row: IssueRow,
  viewerProfileId: string | null,
  commentCount: number,
  nameById: Map<string, string>,
): Record<string, unknown> {
  const reporterId = row.reporter_id ? String(row.reporter_id) : "";
  const assigneeId = row.assignee_id ? String(row.assignee_id) : "";
  const reporterName = reporterId
    ? (nameById.get(reporterId) ?? "").trim()
    : "";
  const assigneeName = assigneeId
    ? (nameById.get(assigneeId) ?? "").trim()
    : "";
  const isOwn = viewerProfileId != null &&
    reporterId.length > 0 &&
    reporterId === viewerProfileId;

  const photos = row.photo_urls;
  const photoCount = Array.isArray(photos) ? photos.length : 0;

  let footerAssignee = "";
  if (assigneeName.length > 0) {
    const parts = assigneeName.split(/\s+/).filter(Boolean);
    if (parts.length >= 2) {
      footerAssignee = `${parts[0]} ${parts[1][0]}.`;
    } else {
      footerAssignee = parts[0] ?? assigneeName;
    }
  }

  const rawCode = row.public_code ? String(row.public_code).trim() : "";
  const publicCode = rawCode.length > 0
    ? rawCode
    : `#${String(row.id).slice(0, 6).toUpperCase()}`;

  return {
    id: String(row.id),
    public_code: publicCode,
    title: String(row.title ?? ""),
    description: String(row.description ?? ""),
    category: String(row.category ?? "other"),
    priority: String(row.priority ?? "medium"),
    status: String(row.status ?? "open"),
    location_code: row.location_code ? String(row.location_code) : null,
    created_at: row.created_at,
    updated_at: row.updated_at,
    reporter_name: reporterName,
    assignee_name: assigneeName,
    is_own_report: isOwn,
    avatar_initials: isOwn
      ? initialsFromName(reporterName || "Sen")
      : initialsFromName(reporterName || assigneeName || "??"),
    footer_assignee_name: footerAssignee,
    comment_count: commentCount,
    photo_count: photoCount,
  };
}

const ISSUES_CORE_SELECT =
  "id, title, description, category, priority, status, photo_urls, created_at, updated_at, reporter_id, assignee_id";

async function fetchIssuesList(
  supabase: ReturnType<typeof createClient>,
  buildingId: string,
): Promise<{ rows: IssueRow[]; error: string | null }> {
  const extended =
    `${ISSUES_CORE_SELECT}, location_code, public_code`;
  let result = await supabase
    .from("issues")
    .select(extended)
    .eq("building_id", buildingId)
    .order("created_at", { ascending: false })
    .limit(200);

  if (
    result.error &&
    (isMissingColumn(result.error, "location_code") ||
      isMissingColumn(result.error, "public_code"))
  ) {
    result = await supabase
      .from("issues")
      .select(ISSUES_CORE_SELECT)
      .eq("building_id", buildingId)
      .order("created_at", { ascending: false })
      .limit(200);
  }

  if (result.error) {
    console.error("issues list", result.error);
    return { rows: [], error: "database_error" };
  }
  return { rows: (result.data ?? []) as IssueRow[], error: null };
}

async function fetchIssueById(
  supabase: ReturnType<typeof createClient>,
  buildingId: string,
  issueId: string,
): Promise<{ row: IssueRow | null; error: string | null }> {
  const extended =
    `${ISSUES_CORE_SELECT}, location_code, public_code`;
  let result = await supabase
    .from("issues")
    .select(extended)
    .eq("id", issueId)
    .eq("building_id", buildingId)
    .maybeSingle();

  if (
    result.error &&
    (isMissingColumn(result.error, "location_code") ||
      isMissingColumn(result.error, "public_code"))
  ) {
    result = await supabase
      .from("issues")
      .select(ISSUES_CORE_SELECT)
      .eq("id", issueId)
      .eq("building_id", buildingId)
      .maybeSingle();
  }

  if (result.error) {
    console.error("issues get", result.error);
    return { row: null, error: "database_error" };
  }
  return { row: result.data as IssueRow | null, error: null };
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse(405, { success: false, error: "method_not_allowed" });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!supabaseUrl || !serviceKey) {
    return jsonResponse(500, {
      success: false,
      error: "server_misconfigured",
    });
  }

  const supabase = createClient(supabaseUrl, serviceKey);

  let payload: Record<string, unknown>;
  try {
    payload = await req.json();
  } catch {
    return jsonResponse(400, { success: false, error: "invalid_json" });
  }

  const deviceId = String(payload.device_id ?? "").trim();
  const sessionToken = String(payload.session_token ?? "").trim();
  const action = String(payload.action ?? "").trim();

  if (!deviceId || !sessionToken) {
    return jsonResponse(400, {
      success: false,
      error: "device_or_token_required",
    });
  }

  const session = await assertDeviceSession(supabase, deviceId, sessionToken);
  if (!session.ok) {
    return jsonResponse(session.status, {
      success: false,
      error: session.error,
    });
  }

  const device = session.device;
  const buildingId = device.building_id;
  const viewerProfileId = device.profile_id;

  if (action === "list") {
    const listed = await fetchIssuesList(supabase, buildingId);
    if (listed.error) {
      return jsonResponse(500, { success: false, error: listed.error });
    }

    const rows = listed.rows;
    const ids = rows.map((r) => String(r.id));
    const counts = await commentCounts(supabase, ids);
    const profileIds: string[] = [];
    for (const row of rows) {
      if (row.reporter_id) profileIds.push(String(row.reporter_id));
      if (row.assignee_id) profileIds.push(String(row.assignee_id));
    }
    const names = await profileNames(supabase, profileIds);
    const latestComments = await latestCommentsByIssue(supabase, ids);

    const issues = rows.map((row) => {
      const issueId = String(row.id);
      const base = serializeIssue(
        row,
        viewerProfileId,
        counts.get(issueId) ?? 0,
        names,
      );
      const latest = latestComments.get(issueId);
      if (!latest || latest.body.length === 0) {
        return base;
      }
      return {
        ...base,
        latest_comment_preview: latest.body,
        latest_comment_author: latest.authorName,
      };
    });

    return jsonResponse(200, { success: true, issues });
  }

  if (action === "get") {
    const issueId = String(payload.issue_id ?? "").trim();
    if (!issueId) {
      return jsonResponse(400, { success: false, error: "issue_id_required" });
    }

    const fetched = await fetchIssueById(supabase, buildingId, issueId);
    if (fetched.error) {
      return jsonResponse(500, { success: false, error: fetched.error });
    }
    if (!fetched.row) {
      return jsonResponse(404, { success: false, error: "issue_not_found" });
    }

    const row = fetched.row;
    const counts = await commentCounts(supabase, [issueId]);
    const profileIds: string[] = [];
    if (row.reporter_id) profileIds.push(String(row.reporter_id));
    if (row.assignee_id) profileIds.push(String(row.assignee_id));
    const names = await profileNames(supabase, profileIds);
    const comments = await fetchIssueComments(supabase, issueId);

    return jsonResponse(200, {
      success: true,
      issue: serializeIssue(
        row,
        viewerProfileId,
        counts.get(issueId) ?? 0,
        names,
      ),
      comments,
    });
  }

  if (action === "create") {
    if (!CREATE_ROLES.has(device.role)) {
      return jsonResponse(403, {
        success: false,
        error: "residents_only_create",
      });
    }

    const title = String(payload.title ?? "").trim();
    const description = String(payload.description ?? "").trim();
    if (title.length < 3) {
      return jsonResponse(422, {
        success: false,
        error: "issue_title_required",
      });
    }

    const category = mapUiCategory(String(payload.category ?? ""));
    const priority = mapUiPriority(String(payload.priority ?? ""));
    const locationCode = String(payload.location_code ?? "").trim() ||
      null;

    const publicCode = await nextPublicCode(supabase, buildingId);

    const insertRow: Record<string, unknown> = {
      building_id: buildingId,
      unit_id: device.unit_id,
      reporter_id: viewerProfileId,
      title,
      description: description.length > 0 ? description : null,
      category,
      priority,
      status: "open",
      location_code: locationCode,
      public_code: publicCode,
    };

    let ins = await supabase.from("issues").insert(insertRow).select("id")
      .single();

    if (ins.error && isMissingColumn(ins.error, "location_code")) {
      delete insertRow.location_code;
      ins = await supabase.from("issues").insert(insertRow).select("id")
        .single();
    }
    if (ins.error && isMissingColumn(ins.error, "public_code")) {
      delete insertRow.public_code;
      ins = await supabase.from("issues").insert(insertRow).select("id")
        .single();
    }

    if (ins.error) {
      console.error("issues insert", ins.error);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    return jsonResponse(200, {
      success: true,
      issue_id: ins.data?.id,
      public_code: publicCode,
    });
  }

  if (action === "update_status") {
    if (!ADMIN_ROLES.has(device.role)) {
      return jsonResponse(403, {
        success: false,
        error: "not_building_admin",
      });
    }

    const issueId = String(payload.issue_id ?? "").trim();
    const status = mapUiStatus(String(payload.status ?? ""));
    const note = String(payload.note ?? "").trim();
    if (!issueId || !status) {
      return jsonResponse(422, {
        success: false,
        error: "issue_status_invalid",
      });
    }

    const patch: Record<string, unknown> = {
      status,
      updated_at: new Date().toISOString(),
    };
    if (status === "resolved") {
      patch.resolved_at = new Date().toISOString();
    }

    const { error } = await supabase
      .from("issues")
      .update(patch)
      .eq("id", issueId)
      .eq("building_id", buildingId);

    if (error) {
      console.error("issues update", error);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const commentBody = note.length > 0
      ? `[status:${status}] ${note}`
      : `[status:${status}]`;

    const { data: insertedComment, error: commentErr } = await supabase
      .from("issue_comments")
      .insert({
        issue_id: issueId,
        author_id: device.profile_id ?? null,
        body: commentBody,
      })
      .select("id, body, created_at, author_id")
      .single();

    if (commentErr) {
      console.error("issue_comments insert", commentErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    let authorName = "";
    if (device.profile_id) {
      const names = await profileNames(
        supabase,
        [String(device.profile_id)],
      );
      authorName = names.get(String(device.profile_id)) ?? "";
    }

    return jsonResponse(200, {
      success: true,
      comment: insertedComment
        ? {
          id: String(insertedComment.id),
          body: stripStatusCommentBody(String(insertedComment.body ?? "")),
          raw_body: String(insertedComment.body ?? ""),
          created_at: insertedComment.created_at,
          author_name: authorName,
          status,
        }
        : null,
    });
  }

  return jsonResponse(400, { success: false, error: "unknown_action" });
});
