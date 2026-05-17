/**
 * Building manager elections — secret ballot (one vote per unit).
 *
 * POST JSON:
 * { "action": "list" | "active" | "get" | "create" | "start" | "start_voting" |
 *   "close" | "nominate" | "vote",
 *   "device_id", "session_token",
 *   "election_id"?, "title"?, "description"?, "closes_at"?,
 *   "candidate_id"? }
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
      const { error: healErr } = await supabase
        .from("devices")
        .update({
          session_token: clientTok,
          last_seen_at: new Date().toISOString(),
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

async function membershipHasProfile(
  supabase: ReturnType<typeof createClient>,
  buildingId: string,
  profileId: string,
): Promise<boolean> {
  const { count, error } = await supabase
    .from("memberships")
    .select("id", { count: "exact", head: true })
    .eq("building_id", buildingId)
    .eq("user_id", profileId);

  if (error) {
    console.error("memberships verify profile", error);
    return false;
  }
  return (count ?? 0) > 0;
}

async function membershipHasResidentProfile(
  supabase: ReturnType<typeof createClient>,
  buildingId: string,
  profileId: string,
): Promise<boolean> {
  let query = supabase
    .from("memberships")
    .select("id", { count: "exact", head: true })
    .eq("building_id", buildingId)
    .eq("user_id", profileId)
    .in("role", ["resident", "owner"]);

  let res = await query.eq("status", "active");
  if (res.error && isMissingColumn(res.error, "status")) {
    res = await query;
  }
  if (res.error) {
    console.error("memberships verify resident profile", res.error);
    return false;
  }
  return (res.count ?? 0) > 0;
}

async function persistDeviceSession(
  supabase: ReturnType<typeof createClient>,
  deviceId: string,
  profileId: string,
  unitId?: string | null,
): Promise<void> {
  const patch: Record<string, unknown> = {
    profile_id: profileId,
    last_seen_at: new Date().toISOString(),
  };
  if (unitId != null && String(unitId).trim().length > 0) {
    patch.unit_id = String(unitId).trim();
  }
  const { error } = await supabase
    .from("devices")
    .update(patch)
    .eq("device_id", deviceId);

  if (error) {
    console.error("devices session persist", error);
  }
}

async function effectiveUnitId(
  supabase: ReturnType<typeof createClient>,
  deviceId: string,
  device: DeviceRow & { building_id: string },
  unitHint?: string | null,
): Promise<string | null> {
  const direct = device.unit_id;
  if (direct != null && String(direct).trim().length > 0) {
    return String(direct).trim();
  }

  const hint = unitHint ? String(unitHint).trim() : "";
  if (hint.length > 0) {
    const { data: unitRow } = await supabase
      .from("units")
      .select("id")
      .eq("id", hint)
      .eq("building_id", device.building_id)
      .maybeSingle();
    if (unitRow?.id) {
      const uid = String(unitRow.id);
      await supabase
        .from("devices")
        .update({ unit_id: uid, last_seen_at: new Date().toISOString() })
        .eq("device_id", deviceId);
      return uid;
    }
  }

  const profileId = device.profile_id;
  if (profileId != null && String(profileId).trim().length > 0) {
    const { data: mem } = await supabase
      .from("memberships")
      .select("unit_id")
      .eq("building_id", device.building_id)
      .eq("user_id", String(profileId).trim())
      .eq("status", "active")
      .maybeSingle();
    if (mem?.unit_id) {
      const uid = String(mem.unit_id);
      await supabase
        .from("devices")
        .update({ unit_id: uid, last_seen_at: new Date().toISOString() })
        .eq("device_id", deviceId);
      return uid;
    }
  }

  return null;
}

async function profileIdFromUnitMembership(
  supabase: ReturnType<typeof createClient>,
  buildingId: string,
  unitId: string,
): Promise<string | null> {
  const { data, error } = await supabase
    .from("memberships")
    .select("user_id")
    .eq("building_id", buildingId)
    .eq("unit_id", unitId)
    .eq("status", "active")
    .limit(1)
    .maybeSingle();

  if (error) {
    console.error("memberships by unit", error);
    return null;
  }
  const uid = data?.user_id;
  return uid != null && String(uid).trim().length > 0
    ? String(uid).trim()
    : null;
}

async function effectiveProfileId(
  supabase: ReturnType<typeof createClient>,
  deviceId: string,
  device: DeviceRow & { building_id: string },
  profileHint?: string | null,
  unitHint?: string | null,
): Promise<string | null> {
  const tryPersist = async (
    pid: string,
    unitId?: string | null,
  ): Promise<string> => {
    await persistDeviceSession(supabase, deviceId, pid, unitId);
    return pid;
  };

  const isResidentRole = device.role === "resident" || device.role === "owner";

  const acceptProfile = async (pid: string): Promise<string | null> => {
    const trimmed = pid.trim();
    if (!trimmed) {
      return null;
    }
    if (
      isResidentRole &&
      !await membershipHasResidentProfile(
        supabase,
        device.building_id,
        trimmed,
      )
    ) {
      return null;
    }
    return trimmed;
  };

  const direct = device.profile_id;
  if (direct != null && String(direct).trim().length > 0) {
    const ok = await acceptProfile(String(direct));
    if (ok) {
      return ok;
    }
  }

  const { data, error } = await supabase
    .from("devices")
    .select("profile_id")
    .eq("device_id", deviceId)
    .maybeSingle();

  if (error) {
    console.error("devices profile_id heal", error);
  } else {
    const healed = data?.profile_id;
    if (healed != null && String(healed).trim().length > 0) {
      const ok = await acceptProfile(String(healed));
      if (ok) {
        return ok;
      }
    }
  }

  const resolvedUnit = await effectiveUnitId(
    supabase,
    deviceId,
    device,
    unitHint,
  );
  if (resolvedUnit) {
    const fromUnit = await profileIdFromUnitMembership(
      supabase,
      device.building_id,
      resolvedUnit,
    );
    if (fromUnit) {
      const ok = await acceptProfile(fromUnit);
      if (ok) {
        return await tryPersist(ok, resolvedUnit);
      }
    }
  }

  const hint = profileHint ? String(profileHint).trim() : "";
  if (hint.length > 0) {
    const ok = isResidentRole
      ? await membershipHasResidentProfile(supabase, device.building_id, hint)
      : await membershipHasProfile(supabase, device.building_id, hint);
    if (ok) {
      return await tryPersist(hint, resolvedUnit);
    }
  }

  if (ADMIN_ROLES.has(device.role)) {
    const { data: building } = await supabase
      .from("buildings")
      .select("created_by")
      .eq("id", device.building_id)
      .maybeSingle();

    const createdBy = building?.created_by;
    if (createdBy != null && String(createdBy).trim().length > 0) {
      const pid = String(createdBy).trim();
      const ok = await membershipHasProfile(supabase, device.building_id, pid);
      if (ok) {
        return await tryPersist(pid);
      }
    }

    const { data: adminRows, error: adminErr } = await supabase
      .from("memberships")
      .select("user_id")
      .eq("building_id", device.building_id)
      .in("role", ["building_admin", "building_co_admin"]);

    if (!adminErr && adminRows) {
      const unique = [
        ...new Set(
          adminRows.map((r) => String((r as { user_id: string }).user_id)),
        ),
      ];
      if (unique.length === 1) {
        return await tryPersist(unique[0]);
      }
    }
  }

  return null;
}

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

function initialsFromName(name: string): string {
  const parts = name.split(/\s+/).filter(Boolean);
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  if (parts.length === 1 && parts[0].length > 0) {
    return parts[0].substring(0, 2).toUpperCase();
  }
  return "??";
}

function firstNameFromFull(name: string): string {
  const parts = name.split(/\s+/).filter(Boolean);
  return parts[0] ?? name;
}

function isManagerMembershipRole(role: string): boolean {
  return role === "building_admin" || role === "building_co_admin";
}

type MemberMeta = { role: string; unitId: string | null };

async function candidateMemberMeta(
  supabase: ReturnType<typeof createClient>,
  buildingId: string,
  profileIds: string[],
): Promise<Map<string, MemberMeta>> {
  const map = new Map<string, MemberMeta>();
  const unique = [...new Set(profileIds.filter((id) => id.length > 0))];
  if (unique.length === 0) {
    return map;
  }

  const { data, error } = await supabase
    .from("memberships")
    .select("user_id, role, unit_id")
    .eq("building_id", buildingId)
    .in("user_id", unique);

  if (error) {
    console.error("memberships candidate meta", error);
    return map;
  }

  for (const row of data ?? []) {
    const uid = String((row as { user_id: string }).user_id);
    const role = String((row as { role: string }).role ?? "");
    const unitId = (row as { unit_id: string | null }).unit_id;
    const existing = map.get(uid);
    if (!existing) {
      map.set(uid, { role, unitId: unitId ? String(unitId) : null });
      continue;
    }
    if (isManagerMembershipRole(role) && !isManagerMembershipRole(existing.role)) {
      map.set(uid, { role, unitId: unitId ? String(unitId) : null });
    } else if (!existing.unitId && unitId) {
      map.set(uid, {
        role: existing.role,
        unitId: String(unitId),
      });
    }
  }

  return map;
}

async function unitLabelsById(
  supabase: ReturnType<typeof createClient>,
  unitIds: string[],
): Promise<Map<string, string>> {
  const map = new Map<string, string>();
  const unique = [...new Set(unitIds.filter((id) => id.length > 0))];
  if (unique.length === 0) {
    return map;
  }

  const { data, error } = await supabase
    .from("units")
    .select("id, block, door_number")
    .in("id", unique);

  if (error) {
    console.error("units labels", error);
    return map;
  }

  for (const row of data ?? []) {
    const id = String((row as { id: string }).id);
    const door = String((row as { door_number?: string }).door_number ?? "")
      .trim();
    const block = String((row as { block?: string }).block ?? "").trim();
    if (door.length > 0) {
      map.set(id, block.length > 0 ? `${block} · ${door}` : door);
    } else if (block.length > 0) {
      map.set(id, block);
    }
  }

  return map;
}

type ElectionRow = Record<string, unknown>;

function serializeElectionSummary(
  row: ElectionRow,
  extras: Record<string, unknown> = {},
): Record<string, unknown> {
  return {
    id: String(row.id),
    title: String(row.title ?? ""),
    description: String(row.description ?? ""),
    status: String(row.status ?? "draft"),
    closes_at: row.closes_at ?? null,
    nominations_close_at: row.nominations_close_at ?? null,
    started_at: row.started_at ?? null,
    closed_at: row.closed_at ?? null,
    created_at: row.created_at,
    ...extras,
  };
}

async function fetchElection(
  supabase: ReturnType<typeof createClient>,
  buildingId: string,
  electionId: string,
): Promise<ElectionRow | null> {
  const { data, error } = await supabase
    .from("manager_elections")
    .select(
      "id, title, description, status, closes_at, nominations_close_at, started_at, closed_at, created_at",
    )
    .eq("id", electionId)
    .eq("building_id", buildingId)
    .maybeSingle();

  if (error) {
    console.error("manager_elections get", error);
    return null;
  }
  return data as ElectionRow | null;
}

async function voteCountsByCandidate(
  supabase: ReturnType<typeof createClient>,
  electionId: string,
): Promise<Map<string, number>> {
  const { data, error } = await supabase
    .from("manager_election_votes")
    .select("candidate_id")
    .eq("election_id", electionId);

  if (error) {
    console.error("manager_election_votes count", error);
    return new Map();
  }

  const map = new Map<string, number>();
  for (const row of data ?? []) {
    const cid = String((row as { candidate_id: string }).candidate_id);
    map.set(cid, (map.get(cid) ?? 0) + 1);
  }
  return map;
}

async function totalVoteCount(
  supabase: ReturnType<typeof createClient>,
  electionId: string,
): Promise<number> {
  const { count, error } = await supabase
    .from("manager_election_votes")
    .select("id", { count: "exact", head: true })
    .eq("election_id", electionId);

  if (error) {
    console.error("manager_election_votes total", error);
    return 0;
  }
  return count ?? 0;
}

async function userHasVoted(
  supabase: ReturnType<typeof createClient>,
  electionId: string,
  unitId: string | null,
): Promise<boolean> {
  if (!unitId) {
    return false;
  }
  const { data, error } = await supabase
    .from("manager_election_votes")
    .select("id")
    .eq("election_id", electionId)
    .eq("unit_id", unitId)
    .maybeSingle();

  if (error) {
    console.error("manager_election_votes has_voted", error);
    return false;
  }
  return data != null;
}

async function hasElectionInProgress(
  supabase: ReturnType<typeof createClient>,
  buildingId: string,
  excludeId?: string | null,
): Promise<boolean> {
  let query = supabase
    .from("manager_elections")
    .select("id", { count: "exact", head: true })
    .eq("building_id", buildingId)
    .in("status", ["nominating", "active"]);

  if (excludeId) {
    query = query.neq("id", excludeId);
  }

  const { count, error } = await query;
  if (error) {
    console.error("manager_elections in progress", error);
    return false;
  }
  return (count ?? 0) > 0;
}

async function buildElectionDetail(
  supabase: ReturnType<typeof createClient>,
  row: ElectionRow,
  device: DeviceRow & { building_id: string },
  deviceId: string,
  profileHint?: string | null,
  unitHint?: string | null,
): Promise<Record<string, unknown>> {
  const electionId = String(row.id);
  const status = String(row.status ?? "draft");
  const isAdmin = ADMIN_ROLES.has(device.role);
  const resultsVisible = status === "closed";
  const resolvedUnitId = await effectiveUnitId(
    supabase,
    deviceId,
    device,
    unitHint,
  );

  const { data: candRows, error: candErr } = await supabase
    .from("manager_election_candidates")
    .select("id, profile_id, position")
    .eq("election_id", electionId)
    .order("position", { ascending: true });

  if (candErr) {
    console.error("manager_election_candidates", candErr);
    throw candErr;
  }

  const profileIds = (candRows ?? []).map((c) =>
    String((c as { profile_id: string }).profile_id)
  );
  const names = await profileNames(supabase, profileIds);
  const memberMeta = await candidateMemberMeta(
    supabase,
    device.building_id,
    profileIds,
  );
  const unitIds = [...memberMeta.values()]
    .map((m) => m.unitId)
    .filter((id): id is string => id != null && id.length > 0);
  const unitLabels = await unitLabelsById(supabase, unitIds);

  const counts = resultsVisible
    ? await voteCountsByCandidate(supabase, electionId)
    : new Map<string, number>();

  const totalVotes = resultsVisible
    ? await totalVoteCount(supabase, electionId)
    : status === "active"
    ? await totalVoteCount(supabase, electionId)
    : 0;

  const hasVoted = await userHasVoted(
    supabase,
    electionId,
    resolvedUnitId,
  );

  const viewerProfileId = await effectiveProfileId(
    supabase,
    deviceId,
    device,
    profileHint,
    unitHint,
  );

  const candidates = (candRows ?? []).map((c) => {
    const cid = String((c as { id: string }).id);
    const pid = String((c as { profile_id: string }).profile_id);
    const displayName = names.get(pid) ?? "—";
    const meta = memberMeta.get(pid);
    const role = meta?.role ?? "resident";
    const roleKind = isManagerMembershipRole(role) ? "manager" : "resident";
    const unitId = meta?.unitId ?? null;
    const unitLabel = unitId ? (unitLabels.get(unitId) ?? null) : null;
    return {
      id: cid,
      profile_id: pid,
      display_name: displayName,
      first_name: firstNameFromFull(displayName),
      initials: initialsFromName(displayName),
      role_kind: roleKind,
      unit_label: unitLabel,
      is_self: viewerProfileId != null && pid === viewerProfileId,
      vote_count: resultsVisible ? (counts.get(cid) ?? 0) : null,
    };
  });

  const isActive = status === "active";
  const isNominating = status === "nominating";
  const isDraft = status === "draft";
  const pastVoteClose = row.closes_at &&
    new Date(String(row.closes_at)).getTime() < Date.now();
  const pastNomClose = row.nominations_close_at &&
    new Date(String(row.nominations_close_at)).getTime() < Date.now();

  const alreadyCandidate = viewerProfileId != null &&
    (candRows ?? []).some(
      (c) =>
        String((c as { profile_id: string }).profile_id) === viewerProfileId,
    );

  const canNominate = viewerProfileId != null && !alreadyCandidate &&
    ((isNominating && !pastNomClose) ||
      (isDraft && isAdmin && !pastVoteClose));

  const canStartNominations = isAdmin && isDraft;
  const canStartVoting = isAdmin && isNominating;

  return {
    election: serializeElectionSummary(row),
    candidates,
    has_voted: hasVoted,
    can_vote: isActive && !hasVoted && resolvedUnitId != null &&
      !pastVoteClose,
    can_nominate: canNominate,
    can_start_nominations: canStartNominations,
    can_start_voting: canStartVoting,
    can_manage: isAdmin,
    results_visible: resultsVisible,
    total_votes: isActive || resultsVisible ? totalVotes : null,
    voted_candidate_id: null,
    viewer_profile_id: viewerProfileId,
  };
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
  const isAdmin = ADMIN_ROLES.has(device.role);

  if (action === "list") {
    let query = supabase
      .from("manager_elections")
      .select(
        "id, title, description, status, closes_at, nominations_close_at, started_at, closed_at, created_at",
      )
      .eq("building_id", buildingId)
      .order("created_at", { ascending: false });

    if (!isAdmin) {
      query = query.in("status", ["nominating", "active", "closed"]);
    }

    const { data, error } = await query;
    if (error) {
      console.error("manager_elections list", error);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const elections = await Promise.all(
      (data ?? []).map(async (row) => {
        const eid = String((row as { id: string }).id);
        const status = String((row as { status: string }).status);
        const hasVoted = await userHasVoted(
          supabase,
          eid,
          device.unit_id,
        );
        const { count: candCount } = await supabase
          .from("manager_election_candidates")
          .select("id", { count: "exact", head: true })
          .eq("election_id", eid);

        return serializeElectionSummary(row as ElectionRow, {
          candidate_count: candCount ?? 0,
          has_voted: hasVoted,
        });
      }),
    );

    return jsonResponse(200, { success: true, elections });
  }

  if (action === "active") {
    const unitHint = String(payload.unit_id ?? "").trim() || null;
    const resolvedUnit = await effectiveUnitId(
      supabase,
      deviceId,
      device,
      unitHint,
    );

    const { data: activeRow, error: activeErr } = await supabase
      .from("manager_elections")
      .select(
        "id, title, description, status, closes_at, nominations_close_at, started_at, closed_at, created_at",
      )
      .eq("building_id", buildingId)
      .eq("status", "active")
      .order("started_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (activeErr) {
      console.error("manager_elections active", activeErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    let row = activeRow as ElectionRow | null;

    if (!row) {
      const { data: nomRow, error: nomErr } = await supabase
        .from("manager_elections")
        .select(
          "id, title, description, status, closes_at, nominations_close_at, started_at, closed_at, created_at",
        )
        .eq("building_id", buildingId)
        .eq("status", "nominating")
        .order("started_at", { ascending: false })
        .limit(1)
        .maybeSingle();

      if (nomErr) {
        console.error("manager_elections nominating", nomErr);
        return jsonResponse(500, { success: false, error: "database_error" });
      }
      row = nomRow as ElectionRow | null;
    }

    if (!row) {
      return jsonResponse(200, { success: true, election: null });
    }

    const hasVoted = await userHasVoted(
      supabase,
      String(row.id),
      resolvedUnit,
    );

    return jsonResponse(200, {
      success: true,
      election: serializeElectionSummary(row, {
        has_voted: hasVoted,
      }),
    });
  }

  if (action === "get") {
    const electionId = String(payload.election_id ?? "").trim();
    if (!electionId) {
      return jsonResponse(400, {
        success: false,
        error: "election_id_required",
      });
    }

    const row = await fetchElection(supabase, buildingId, electionId);
    if (!row) {
      return jsonResponse(404, { success: false, error: "election_not_found" });
    }

    if (String(row.status) === "draft" && !isAdmin) {
      return jsonResponse(403, { success: false, error: "election_not_visible" });
    }

    try {
      const profileHint = String(payload.profile_id ?? "").trim() || null;
      const unitHint = String(payload.unit_id ?? "").trim() || null;
      const detail = await buildElectionDetail(
        supabase,
        row,
        device,
        deviceId,
        profileHint,
        unitHint,
      );
      return jsonResponse(200, { success: true, ...detail });
    } catch {
      return jsonResponse(500, { success: false, error: "database_error" });
    }
  }

  if (action === "create") {
    if (!isAdmin) {
      return jsonResponse(403, {
        success: false,
        error: "not_building_admin",
      });
    }

    const title = String(payload.title ?? "").trim();
    if (title.length < 3) {
      return jsonResponse(422, {
        success: false,
        error: "election_title_required",
      });
    }

    const description = String(payload.description ?? "").trim();
    const closesAt = payload.closes_at
      ? String(payload.closes_at).trim()
      : null;
    const nominationsCloseAt = payload.nominations_close_at
      ? String(payload.nominations_close_at).trim()
      : null;

    const { data, error } = await supabase
      .from("manager_elections")
      .insert({
        building_id: buildingId,
        title,
        description: description.length > 0 ? description : null,
        status: "draft",
        closes_at: closesAt,
        nominations_close_at: nominationsCloseAt,
        created_by: device.profile_id,
      })
      .select("id")
      .single();

    if (error) {
      console.error("manager_elections insert", error);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    return jsonResponse(200, {
      success: true,
      election_id: String(data?.id ?? ""),
    });
  }

  if (action === "start") {
    if (!isAdmin) {
      return jsonResponse(403, {
        success: false,
        error: "not_building_admin",
      });
    }

    const electionId = String(payload.election_id ?? "").trim();
    if (!electionId) {
      return jsonResponse(400, {
        success: false,
        error: "election_id_required",
      });
    }

    const row = await fetchElection(supabase, buildingId, electionId);
    if (!row) {
      return jsonResponse(404, { success: false, error: "election_not_found" });
    }
    if (String(row.status) !== "draft") {
      return jsonResponse(422, {
        success: false,
        error: "election_not_draft",
      });
    }

    if (await hasElectionInProgress(supabase, buildingId, electionId)) {
      return jsonResponse(409, {
        success: false,
        error: "election_active_exists",
      });
    }

    const { error } = await supabase
      .from("manager_elections")
      .update({
        status: "nominating",
        started_at: new Date().toISOString(),
      })
      .eq("id", electionId)
      .eq("building_id", buildingId);

    if (error) {
      console.error("manager_elections start nominations", error);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    return jsonResponse(200, { success: true });
  }

  if (action === "start_voting") {
    if (!isAdmin) {
      return jsonResponse(403, {
        success: false,
        error: "not_building_admin",
      });
    }

    const electionId = String(payload.election_id ?? "").trim();
    if (!electionId) {
      return jsonResponse(400, {
        success: false,
        error: "election_id_required",
      });
    }

    const row = await fetchElection(supabase, buildingId, electionId);
    if (!row) {
      return jsonResponse(404, { success: false, error: "election_not_found" });
    }
    if (String(row.status) !== "nominating") {
      return jsonResponse(422, {
        success: false,
        error: "election_not_nominating",
      });
    }

    const { count: activeCount } = await supabase
      .from("manager_elections")
      .select("id", { count: "exact", head: true })
      .eq("building_id", buildingId)
      .eq("status", "active");

    if ((activeCount ?? 0) > 0) {
      return jsonResponse(409, {
        success: false,
        error: "election_active_exists",
      });
    }

    const { error } = await supabase
      .from("manager_elections")
      .update({
        status: "active",
      })
      .eq("id", electionId)
      .eq("building_id", buildingId);

    if (error) {
      console.error("manager_elections start voting", error);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    return jsonResponse(200, { success: true });
  }

  if (action === "close") {
    if (!isAdmin) {
      return jsonResponse(403, {
        success: false,
        error: "not_building_admin",
      });
    }

    const electionId = String(payload.election_id ?? "").trim();
    if (!electionId) {
      return jsonResponse(400, {
        success: false,
        error: "election_id_required",
      });
    }

    const row = await fetchElection(supabase, buildingId, electionId);
    if (!row) {
      return jsonResponse(404, { success: false, error: "election_not_found" });
    }
    if (String(row.status) !== "active") {
      return jsonResponse(422, {
        success: false,
        error: "election_not_active",
      });
    }

    const { error } = await supabase
      .from("manager_elections")
      .update({
        status: "closed",
        closed_at: new Date().toISOString(),
      })
      .eq("id", electionId)
      .eq("building_id", buildingId);

    if (error) {
      console.error("manager_elections close", error);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    return jsonResponse(200, { success: true });
  }

  if (action === "nominate") {
    const electionId = String(payload.election_id ?? "").trim();
    if (!electionId) {
      return jsonResponse(400, {
        success: false,
        error: "election_id_required",
      });
    }

    const profileHint = String(payload.profile_id ?? "").trim() || null;
    const unitHint = String(payload.unit_id ?? "").trim() || null;
    const profileId = await effectiveProfileId(
      supabase,
      deviceId,
      device,
      profileHint,
      unitHint,
    );
    if (!profileId) {
      return jsonResponse(422, {
        success: false,
        error: "profile_required",
      });
    }

    const row = await fetchElection(supabase, buildingId, electionId);
    if (!row) {
      return jsonResponse(404, { success: false, error: "election_not_found" });
    }

    const electionStatus = String(row.status ?? "");
    if (electionStatus === "draft") {
      if (!ADMIN_ROLES.has(device.role)) {
        return jsonResponse(422, {
          success: false,
          error: "election_not_active",
        });
      }
    } else if (electionStatus === "nominating") {
      const pastNom = row.nominations_close_at &&
        new Date(String(row.nominations_close_at)).getTime() < Date.now();
      if (pastNom && !ADMIN_ROLES.has(device.role)) {
        return jsonResponse(422, {
          success: false,
          error: "election_nomination_closed",
        });
      }
    } else if (electionStatus !== "active" && electionStatus !== "draft") {
      return jsonResponse(422, {
        success: false,
        error: "election_not_active",
      });
    } else if (electionStatus === "active") {
      return jsonResponse(422, {
        success: false,
        error: "election_nomination_closed",
      });
    }

    const { count: existing } = await supabase
      .from("manager_election_candidates")
      .select("id", { count: "exact", head: true })
      .eq("election_id", electionId)
      .eq("profile_id", profileId);

    if ((existing ?? 0) > 0) {
      return jsonResponse(409, {
        success: false,
        error: "already_candidate",
      });
    }

    const { count: posCount } = await supabase
      .from("manager_election_candidates")
      .select("id", { count: "exact", head: true })
      .eq("election_id", electionId);

    const { data, error } = await supabase
      .from("manager_election_candidates")
      .insert({
        election_id: electionId,
        profile_id: profileId,
        position: posCount ?? 0,
      })
      .select("id")
      .single();

    if (error) {
      console.error("manager_election_candidates insert", error);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    return jsonResponse(200, {
      success: true,
      candidate_id: String(data?.id ?? ""),
    });
  }

  if (action === "vote") {
    const electionId = String(payload.election_id ?? "").trim();
    const candidateId = String(payload.candidate_id ?? "").trim();

    if (!electionId || !candidateId) {
      return jsonResponse(422, {
        success: false,
        error: "vote_payload_invalid",
      });
    }

    const unitHint = String(payload.unit_id ?? "").trim() || null;
    const unitId = await effectiveUnitId(
      supabase,
      deviceId,
      device,
      unitHint,
    );
    if (!unitId) {
      return jsonResponse(422, {
        success: false,
        error: "unit_required",
      });
    }

    const row = await fetchElection(supabase, buildingId, electionId);
    if (!row) {
      return jsonResponse(404, { success: false, error: "election_not_found" });
    }
    if (String(row.status) !== "active") {
      return jsonResponse(422, {
        success: false,
        error: "election_not_active",
      });
    }

    if (row.closes_at &&
      new Date(String(row.closes_at)).getTime() < Date.now()) {
      return jsonResponse(422, {
        success: false,
        error: "election_closed",
      });
    }

    const { data: cand } = await supabase
      .from("manager_election_candidates")
      .select("id")
      .eq("id", candidateId)
      .eq("election_id", electionId)
      .maybeSingle();

    if (!cand) {
      return jsonResponse(404, {
        success: false,
        error: "candidate_not_found",
      });
    }

    const already = await userHasVoted(supabase, electionId, unitId);
    if (already) {
      return jsonResponse(409, {
        success: false,
        error: "already_voted",
      });
    }

    const { error } = await supabase.from("manager_election_votes").insert({
      election_id: electionId,
      candidate_id: candidateId,
      unit_id: unitId,
      device_id: deviceId,
    });

    if (error) {
      console.error("manager_election_votes insert", error);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    return jsonResponse(200, { success: true });
  }

  return jsonResponse(400, { success: false, error: "unknown_action" });
});
