/**
 * Redeem invite code (admin or unit). Uses service role — bypasses RLS.
 *
 * POST body JSON:
 * { "code": string, "device_id": string, "full_name"?: string, "probe"?: boolean }
 *
 * probe=true: read-only — returns would_resume + building_name (+ unit_label for unit codes),
 * no invite consume and no device upsert.
 * Reinstall / new phone: same invite code reopens the linked building (admin) or unit
 * (resident) when setup or first redeem already completed — not tied to a single device_id.
 *
 * Admin (8-char): full_name optional — creates device row, building wizard fills building later.
 * Unit (5-char): full_name required (≥3 chars) — creates profile + membership + device.
 * Optional env SUPERADMIN_ACCESS_CODE: matching normalized code issues super_admin device session.
 * Admin invite_codes.admin_redeem_policy: single_use (consume) | reusable (repeat redeem).
 */
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

import { isMissingColumn } from "../_shared/db_compat.ts";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
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

function normalizeCode(raw: string): string {
  return raw.trim().toUpperCase().replace(/[^A-Z0-9]/g, "");
}

/** Upsert devices row; omits unknown columns for older DBs (session_token, admin_invite_code_id). */
async function upsertDeviceWithLegacyColumns(
  supabase: ReturnType<typeof createClient>,
  row: Record<string, unknown>,
): Promise<{ error: { message?: string } | null }> {
  let payload: Record<string, unknown> = { ...row };
  for (;;) {
    const res = await supabase.from("devices").upsert(payload, {
      onConflict: "device_id",
    });
    if (!res.error) return res;
    const err = res.error;
    if (isMissingColumn(err, "session_token") && "session_token" in payload) {
      const { session_token: _s, ...rest } = payload;
      void _s;
      payload = rest;
      continue;
    }
    if (
      isMissingColumn(err, "admin_invite_code_id") &&
      "admin_invite_code_id" in payload
    ) {
      const { admin_invite_code_id: _a, ...rest } = payload;
      void _a;
      payload = rest;
      continue;
    }
    return res;
  }
}

type CanonicalDevice = {
  pk: string;
  device_id: string;
  building_id: string;
  profile_id: string | null;
  unit_id: string | null;
};

function isInviteExpired(row: Record<string, unknown>): boolean {
  if (!row.expires_at) {
    return false;
  }
  const exp = new Date(row.expires_at as string);
  return exp.getTime() < Date.now();
}

function inviteAllowsRedeem(
  row: Record<string, unknown>,
  hasExistingAccess: boolean,
): boolean {
  const status = String(row.status ?? "");
  if (status === "revoked" || status === "expired") {
    return false;
  }
  if (status === "active") {
    return true;
  }
  if (status === "used" && hasExistingAccess) {
    return true;
  }
  return false;
}

async function fetchUnitLabel(
  supabase: ReturnType<typeof createClient>,
  unitId: string | null,
): Promise<string> {
  if (!unitId || unitId.length === 0) {
    return "";
  }
  const { data: uMeta } = await supabase
    .from("units")
    .select("block, door_number, floor")
    .eq("id", unitId)
    .maybeSingle();
  if (!uMeta) {
    return "";
  }
  const block = typeof uMeta.block === "string" ? uMeta.block.trim() : "";
  const door = typeof uMeta.door_number === "string"
    ? uMeta.door_number.trim()
    : "";
  const floor = uMeta.floor;
  const floorPart = floor == null ? "" : `${floor}. kat · `;
  if (block.length > 0) {
    return `${floorPart}${block} · ${door || "-"}`;
  }
  if (door.length > 0) {
    return `${floorPart}${door}`;
  }
  return "";
}

async function fetchBuildingName(
  supabase: ReturnType<typeof createClient>,
  buildingId: string,
): Promise<string> {
  const { data: bMeta } = await supabase
    .from("buildings")
    .select("name")
    .eq("id", buildingId)
    .maybeSingle();
  if (typeof bMeta?.name === "string") {
    return (bMeta.name as string).trim();
  }
  return "";
}

function inviteCodeWasUsed(row: Record<string, unknown>): boolean {
  const usedAt = row.used_at;
  return usedAt != null && String(usedAt).length > 0;
}

/** Best admin device row for this invite (completed setup). */
async function findCanonicalAdminForInvite(
  supabase: ReturnType<typeof createClient>,
  inviteRowId: string,
  inviteBuildingId: string | null,
): Promise<CanonicalDevice | null> {
  const sel = await supabase
    .from("devices")
    .select(
      "id, device_id, building_id, profile_id, unit_id, role, admin_invite_code_id, created_at",
    )
    .eq("admin_invite_code_id", inviteRowId)
    .eq("role", "building_admin")
    .not("building_id", "is", null);

  if (sel.error && isMissingColumn(sel.error, "admin_invite_code_id")) {
    if (inviteBuildingId) {
      return {
        pk: "",
        device_id: "",
        building_id: inviteBuildingId,
        profile_id: null,
        unit_id: null,
      };
    }
    return null;
  }
  if (sel.error) {
    console.error("devices canonical admin lookup", sel.error);
    return null;
  }

  const rows = (sel.data as Record<string, unknown>[] | null) ?? [];
  if (rows.length === 0) {
    if (inviteBuildingId) {
      return {
        pk: "",
        device_id: "",
        building_id: inviteBuildingId,
        profile_id: null,
        unit_id: null,
      };
    }
    return null;
  }

  rows.sort((a, b) => {
    const aProfile = a.profile_id ? 1 : 0;
    const bProfile = b.profile_id ? 1 : 0;
    if (bProfile !== aProfile) {
      return bProfile - aProfile;
    }
    const aTs = String(a.created_at ?? "");
    const bTs = String(b.created_at ?? "");
    return aTs.localeCompare(bTs);
  });

  const r = rows[0]!;
  const buildingId = String(r.building_id ?? "");
  if (!buildingId) {
    return null;
  }
  const pk = String(r.id ?? "");
  return {
    pk,
    device_id: String(r.device_id ?? ""),
    building_id: inviteBuildingId && inviteBuildingId.length > 0
      ? inviteBuildingId
      : buildingId,
    profile_id: r.profile_id ? String(r.profile_id) : null,
    unit_id: r.unit_id ? String(r.unit_id) : null,
  };
}

const RESIDENT_MEMBERSHIP_ROLES = ["resident", "owner"];

/** True when profile has an active resident/owner membership in this building. */
async function profileHasResidentMembership(
  supabase: ReturnType<typeof createClient>,
  buildingId: string,
  profileId: string,
): Promise<boolean> {
  const pid = profileId.trim();
  const bid = buildingId.trim();
  if (!pid || !bid) {
    return false;
  }

  let query = supabase
    .from("memberships")
    .select("id", { count: "exact", head: true })
    .eq("building_id", bid)
    .eq("user_id", pid)
    .in("role", RESIDENT_MEMBERSHIP_ROLES);

  let res = await query.eq("status", "active");
  if (res.error && isMissingColumn(res.error, "status")) {
    res = await query;
  }
  if (res.error) {
    console.error("memberships resident verify", res.error);
    return false;
  }
  return (res.count ?? 0) > 0;
}

/** Active resident membership for a unit (service-role lookup). */
async function findMembershipProfileForUnit(
  supabase: ReturnType<typeof createClient>,
  buildingId: string,
  unitId: string,
): Promise<string | null> {
  let query = supabase
    .from("memberships")
    .select("user_id")
    .eq("building_id", buildingId)
    .eq("unit_id", unitId)
    .eq("role", "resident");

  let res = await query
    .eq("status", "active")
    .order("joined_at", { ascending: true })
    .limit(1)
    .maybeSingle();

  if (res.error && isMissingColumn(res.error, "status")) {
    res = await query
      .order("joined_at", { ascending: true })
      .limit(1)
      .maybeSingle();
  }

  if (res.error && isMissingColumn(res.error, "joined_at")) {
    res = await query.limit(1).maybeSingle();
  }

  if (res.error) {
    console.error("memberships unit resident lookup", res.error);
    return null;
  }

  const profileId = typeof res.data?.user_id === "string"
    ? (res.data.user_id as string).trim()
    : "";
  return profileId.length > 0 ? profileId : null;
}

async function profileToCanonicalResident(
  supabase: ReturnType<typeof createClient>,
  profileId: string,
  buildingId: string,
  unitId: string,
): Promise<CanonicalDevice> {
  const devSel = await supabase
    .from("devices")
    .select(
      "id, device_id, building_id, profile_id, unit_id, role, created_at",
    )
    .eq("profile_id", profileId)
    .eq("role", "resident")
    .order("created_at", { ascending: true })
    .limit(1)
    .maybeSingle();

  if (devSel.error || !devSel.data) {
    return {
      pk: "",
      device_id: "",
      building_id: buildingId,
      profile_id: profileId,
      unit_id: unitId,
    };
  }

  const d = devSel.data as Record<string, unknown>;
  return {
    pk: String(d.id ?? ""),
    device_id: String(d.device_id ?? ""),
    building_id: String(d.building_id ?? buildingId),
    profile_id: profileId,
    unit_id: d.unit_id ? String(d.unit_id) : unitId,
  };
}

/** Resident device already bound to this unit invite (phone change / reinstall). */
async function findCanonicalResidentForInvite(
  supabase: ReturnType<typeof createClient>,
  inviteRowId: string,
  buildingId?: string | null,
  unitId?: string | null,
): Promise<CanonicalDevice | null> {
  const sel = await supabase
    .from("devices")
    .select(
      "id, device_id, building_id, profile_id, unit_id, role, admin_invite_code_id, created_at",
    )
    .eq("admin_invite_code_id", inviteRowId)
    .eq("role", "resident")
    .not("building_id", "is", null);

  let rows: Record<string, unknown>[] = [];
  if (sel.error && isMissingColumn(sel.error, "admin_invite_code_id")) {
    rows = [];
  } else if (sel.error) {
    console.error("devices canonical resident lookup", sel.error);
    return null;
  } else {
    rows = (sel.data as Record<string, unknown>[] | null) ?? [];
  }

  rows = rows.filter((r) => {
    const bid = String(r.building_id ?? "");
    const pid = r.profile_id;
    const role = String(r.role ?? "");
    return (
      role === "resident" &&
      bid.length > 0 &&
      typeof pid === "string" &&
      (pid as string).trim().length > 0
    );
  });

  if (rows.length === 0) {
    const inv = await supabase
      .from("invite_codes")
      .select("used_by_device_id, building_id, unit_id")
      .eq("id", inviteRowId)
      .maybeSingle();
    const legacyDid = typeof inv.data?.used_by_device_id === "string"
      ? (inv.data.used_by_device_id as string).trim()
      : "";
    // Only resume a prior *resident* device — never reuse manager/admin rows.
    if (legacyDid.length > 0) {
      const leg = await supabase
        .from("devices")
        .select(
          "id, device_id, building_id, profile_id, unit_id, role, created_at",
        )
        .eq("device_id", legacyDid)
        .eq("role", "resident")
        .maybeSingle();
      if (leg.data) {
        const legRow = leg.data as Record<string, unknown>;
        const legPid = String(legRow.profile_id ?? "").trim();
        const legBid = String(legRow.building_id ?? "").trim();
        if (
          legPid.length > 0 &&
          legBid.length > 0 &&
          await profileHasResidentMembership(supabase, legBid, legPid)
        ) {
          rows = [legRow];
        }
      }
    }
    if (rows.length === 0) {
      const bid =
        typeof buildingId === "string" && buildingId.length > 0
          ? buildingId
          : null;
      const uid = typeof unitId === "string" && unitId.length > 0
        ? unitId
        : null;
      if (!bid || !uid) {
        return null;
      }

      const profileId = await findMembershipProfileForUnit(supabase, bid, uid);
      if (
        profileId &&
        await profileHasResidentMembership(supabase, bid, profileId)
      ) {
        return await profileToCanonicalResident(
          supabase,
          profileId,
          bid,
          uid,
        );
      }

      const { data: unitDev, error: udErr } = await supabase
        .from("devices")
        .select(
          "id, device_id, building_id, profile_id, unit_id, role, created_at",
        )
        .eq("building_id", bid)
        .eq("unit_id", uid)
        .eq("role", "resident")
        .not("profile_id", "is", null)
        .order("created_at", { ascending: true })
        .limit(1)
        .maybeSingle();

      if (!udErr && unitDev) {
        const d = unitDev as Record<string, unknown>;
        const pid = String(d.profile_id ?? "").trim();
        if (
          pid.length > 0 &&
          await profileHasResidentMembership(supabase, bid, pid)
        ) {
          return {
            pk: String(d.id ?? ""),
            device_id: String(d.device_id ?? ""),
            building_id: String(d.building_id ?? bid),
            profile_id: pid,
            unit_id: d.unit_id ? String(d.unit_id) : uid,
          };
        }
      }
      return null;
    }
  }

  rows.sort((a, b) => {
    const aTs = String(a.created_at ?? "");
    const bTs = String(b.created_at ?? "");
    return aTs.localeCompare(bTs);
  });

  const r = rows[0]!;
  const resolvedBuildingId = String(r.building_id ?? "");
  if (!resolvedBuildingId) {
    return null;
  }
  return {
    pk: String(r.id ?? ""),
    device_id: String(r.device_id ?? ""),
    building_id: resolvedBuildingId,
    profile_id: r.profile_id ? String(r.profile_id) : null,
    unit_id: r.unit_id ? String(r.unit_id) : null,
  };
}

/** Drop stale incomplete device row blocking upsert on this device_id. */
async function clearIncompleteDeviceClash(
  supabase: ReturnType<typeof createClient>,
  deviceId: string,
  inviteRowId: string,
): Promise<void> {
  const clash = await supabase
    .from("devices")
    .select("id, building_id, admin_invite_code_id, role")
    .eq("device_id", deviceId)
    .maybeSingle();

  if (clash.error || !clash.data) {
    return;
  }

  const row = clash.data as Record<string, unknown>;
  const pk = String(row.id ?? "");
  const bid = row.building_id;
  const hasBuilding = typeof bid === "string" && bid.length > 0;
  const sameInvite = String(row.admin_invite_code_id ?? "") === inviteRowId;

  if (!pk || (hasBuilding && sameInvite)) {
    return;
  }

  await supabase.from("devices").delete().eq("id", pk);
}

async function grantManagerAccess(
  supabase: ReturnType<typeof createClient>,
  deviceId: string,
  sessionToken: string,
  nowIso: string,
  inviteRowId: string,
  canonical: CanonicalDevice,
): Promise<Response> {
  const buildingId = canonical.building_id;
  const profileId = canonical.profile_id;

  await clearIncompleteDeviceClash(supabase, deviceId, inviteRowId);

  if (canonical.pk && canonical.device_id !== deviceId) {
    const clash = await supabase
      .from("devices")
      .select("id")
      .eq("device_id", deviceId)
      .maybeSingle();
    const clashPk = clash.data
      ? String((clash.data as Record<string, unknown>).id ?? "")
      : "";
    if (clashPk.length > 0 && clashPk !== canonical.pk) {
      await supabase.from("devices").delete().eq("id", clashPk);
    }

    let rebErr = (
      await supabase
        .from("devices")
        .update({
          device_id: deviceId,
          session_token: sessionToken,
          last_seen_at: nowIso,
          profile_id: profileId,
          building_id: buildingId,
          admin_invite_code_id: inviteRowId,
        })
        .eq("id", canonical.pk)
    ).error;

    if (rebErr && isMissingColumn(rebErr, "session_token")) {
      rebErr = (
        await supabase
          .from("devices")
          .update({
            device_id: deviceId,
            last_seen_at: nowIso,
            profile_id: profileId,
            building_id: buildingId,
            admin_invite_code_id: inviteRowId,
          })
          .eq("id", canonical.pk)
      ).error;
    }

    if (rebErr) {
      console.error("devices rebind admin", rebErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }
  } else {
    const { error: devErr } = await upsertDeviceWithLegacyColumns(supabase, {
      device_id: deviceId,
      profile_id: profileId,
      building_id: buildingId,
      unit_id: null,
      role: "building_admin",
      session_token: sessionToken,
      last_seen_at: nowIso,
      admin_invite_code_id: inviteRowId,
    });
    if (devErr) {
      console.error("devices grant admin", devErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }
  }

  const buildingName = await fetchBuildingName(supabase, buildingId);
  return jsonResponse(200, {
    success: true,
    role: "building_admin",
    building_id: buildingId,
    unit_id: canonical.unit_id,
    profile_id: profileId,
    session_token: sessionToken,
    building_name: buildingName.length > 0 ? buildingName : null,
    resumed: true,
    rebound: canonical.device_id !== deviceId,
  });
}

async function grantResidentAccess(
  supabase: ReturnType<typeof createClient>,
  deviceId: string,
  sessionToken: string,
  nowIso: string,
  inviteRowId: string,
  canonical: CanonicalDevice,
  fullName: string,
): Promise<Response> {
  const buildingId = canonical.building_id;
  const unitId = canonical.unit_id;
  const profileId = canonical.profile_id;

  if (profileId && fullName.length >= 3) {
    await supabase
      .from("profiles")
      .update({ full_name: fullName })
      .eq("id", profileId);
  }

  await clearIncompleteDeviceClash(supabase, deviceId, inviteRowId);

  if (canonical.pk && canonical.device_id !== deviceId) {
    const clash = await supabase
      .from("devices")
      .select("id")
      .eq("device_id", deviceId)
      .maybeSingle();
    const clashPk = clash.data
      ? String((clash.data as Record<string, unknown>).id ?? "")
      : "";
    if (clashPk.length > 0 && clashPk !== canonical.pk) {
      await supabase.from("devices").delete().eq("id", clashPk);
    }

    let rebErr = (
      await supabase
        .from("devices")
        .update({
          device_id: deviceId,
          session_token: sessionToken,
          last_seen_at: nowIso,
          profile_id: profileId,
          building_id: buildingId,
          unit_id: unitId,
          admin_invite_code_id: inviteRowId,
        })
        .eq("id", canonical.pk)
    ).error;

    if (rebErr && isMissingColumn(rebErr, "session_token")) {
      rebErr = (
        await supabase
          .from("devices")
          .update({
            device_id: deviceId,
            last_seen_at: nowIso,
            profile_id: profileId,
            building_id: buildingId,
            unit_id: unitId,
            admin_invite_code_id: inviteRowId,
          })
          .eq("id", canonical.pk)
      ).error;
    }

    if (rebErr) {
      console.error("devices rebind resident", rebErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }
  } else {
    const { error: dErr } = await upsertDeviceWithLegacyColumns(supabase, {
      device_id: deviceId,
      profile_id: profileId,
      building_id: buildingId,
      unit_id: unitId,
      role: "resident",
      session_token: sessionToken,
      last_seen_at: nowIso,
      admin_invite_code_id: inviteRowId,
    });
    if (dErr) {
      console.error("devices grant resident", dErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }
  }

  const buildingName = await fetchBuildingName(supabase, buildingId);
  let resolvedFullName: string | null = null;
  if (profileId) {
    const { data: prof } = await supabase
      .from("profiles")
      .select("full_name")
      .eq("id", profileId)
      .maybeSingle();
    if (typeof prof?.full_name === "string" && prof.full_name.trim().length > 0) {
      resolvedFullName = prof.full_name.trim();
    }
  }
  if (!resolvedFullName && fullName.length >= 3) {
    resolvedFullName = fullName;
  }

  return jsonResponse(200, {
    success: true,
    role: "resident",
    building_id: buildingId,
    unit_id: unitId,
    profile_id: profileId,
    session_token: sessionToken,
    building_name: buildingName.length > 0 ? buildingName : null,
    full_name: resolvedFullName,
    resumed: true,
    rebound: canonical.device_id !== deviceId,
  });
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

  let payload: {
    code?: string;
    device_id?: string;
    full_name?: string;
    probe?: boolean;
  };
  try {
    payload = await req.json();
  } catch {
    return jsonResponse(400, { success: false, error: "invalid_json" });
  }

  const probeOnly = payload.probe === true;

  const codeRaw = payload.code;
  const deviceId = payload.device_id?.trim();
  const fullName = payload.full_name?.trim();

  if (!codeRaw || typeof codeRaw !== "string") {
    return jsonResponse(400, { success: false, error: "code_required" });
  }
  if (!deviceId) {
    return jsonResponse(400, { success: false, error: "device_id_required" });
  }

  const code = normalizeCode(codeRaw);
  if (code.length < 4) {
    return jsonResponse(400, { success: false, error: "code_invalid_length" });
  }

  const sessionToken = crypto.randomUUID();

  const superAccess = Deno.env.get("SUPERADMIN_ACCESS_CODE")?.trim();
  if (superAccess && superAccess.length >= 4) {
    const secretNorm = normalizeCode(superAccess);
    if (secretNorm.length >= 4 && code === secretNorm) {
      if (probeOnly) {
        return jsonResponse(200, {
          success: true,
          probe: true,
          would_resume: false,
          role: "super_admin",
        });
      }
      const nowIso = new Date().toISOString();
      const { error: devErr } = await upsertDeviceWithLegacyColumns(supabase, {
        device_id: deviceId,
        profile_id: null,
        building_id: null,
        unit_id: null,
        role: "super_admin",
        session_token: sessionToken,
        last_seen_at: nowIso,
      });

      if (devErr) {
        console.error("devices upsert super_admin", devErr);
        return jsonResponse(500, { success: false, error: "database_error" });
      }

      return jsonResponse(200, {
        success: true,
        role: "super_admin",
        building_id: null,
        unit_id: null,
        profile_id: null,
        session_token: sessionToken,
      });
    }
  }

  let row: Record<string, unknown> | null = null;
  const primary = await supabase
    .from("invite_codes")
    .select(
      "id, code_type, status, building_id, unit_id, expires_at, "
        + "admin_redeem_policy, used_at, used_by_device_id",
    )
    .eq("code", code)
    .maybeSingle();

  if (primary.error && isMissingColumn(primary.error, "admin_redeem_policy")) {
    const legacy = await supabase
      .from("invite_codes")
      .select(
        "id, code_type, status, building_id, unit_id, expires_at, "
          + "used_at, used_by_device_id",
      )
      .eq("code", code)
      .maybeSingle();
    if (legacy.error) {
      console.error("invite_codes select legacy", legacy.error);
      return jsonResponse(500, { success: false, error: "database_error" });
    }
    row = legacy.data as Record<string, unknown> | null;
  } else if (primary.error) {
    console.error("invite_codes select", primary.error);
    return jsonResponse(500, { success: false, error: "database_error" });
  } else {
    row = primary.data as Record<string, unknown> | null;
  }

  if (!row) {
    return jsonResponse(404, {
      success: false,
      error: "code_not_found_or_expired",
      message:
        "Kod bulunamadı veya süresi dolmuş.",
    });
  }

  if (isInviteExpired(row)) {
    return jsonResponse(404, {
      success: false,
      error: "code_not_found_or_expired",
      message:
        "Kod bulunamadı veya süresi dolmuş.",
    });
  }

  const codeType = row.code_type as string;
  const inviteRowId = String(row.id);
  const inviteBuildingId =
    typeof row.building_id === "string" && row.building_id.length > 0
      ? row.building_id
      : null;

  const adminCanonical = codeType === "admin"
    ? await findCanonicalAdminForInvite(
      supabase,
      inviteRowId,
      inviteBuildingId,
    )
    : null;
  const inviteUnitId =
    typeof row.unit_id === "string" && row.unit_id.length > 0
      ? row.unit_id
      : null;
  let residentCanonical = codeType === "unit"
    ? await findCanonicalResidentForInvite(
      supabase,
      inviteRowId,
      inviteBuildingId,
      inviteUnitId,
    )
    : null;

  const hasExistingAccess = codeType === "admin"
    ? adminCanonical != null
    : residentCanonical != null;

  if (!inviteAllowsRedeem(row, hasExistingAccess)) {
    return jsonResponse(404, {
      success: false,
      error: "code_not_found_or_expired",
      message:
        "Kod bulunamadı veya süresi dolmuş.",
    });
  }
  const rawAdminPolicy = (row as Record<string, unknown>).admin_redeem_policy;
  const adminRedeemPolicy =
    typeof rawAdminPolicy === "string" && rawAdminPolicy.trim() === "reusable"
      ? "reusable"
      : "single_use";

  const nowIso = new Date().toISOString();

  if (probeOnly && codeType === "unit") {
    let devProbe = await supabase
      .from("devices")
      .select("building_id, profile_id, unit_id, role, admin_invite_code_id")
      .eq("device_id", deviceId)
      .maybeSingle();

    if (
      devProbe.error &&
      isMissingColumn(devProbe.error, "admin_invite_code_id")
    ) {
      devProbe = await supabase
        .from("devices")
        .select("building_id, profile_id, unit_id, role")
        .eq("device_id", deviceId)
        .maybeSingle();
    }

    if (devProbe.error) {
      console.error("devices select resident probe", devProbe.error);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const ex = devProbe.data as Record<string, unknown> | null;
    const exBid = ex?.building_id;
    const storedInvite = ex?.admin_invite_code_id;
    const exUnitRaw = ex?.unit_id;
    const exUnitId = typeof exUnitRaw === "string" && exUnitRaw.length > 0
      ? exUnitRaw
      : null;
    const unitMatches = !inviteUnitId || exUnitId === inviteUnitId;
    const canResume =
      ex?.role === "resident" &&
      typeof exBid === "string" &&
      exBid.length > 0 &&
      inviteBuildingId &&
      String(exBid) === inviteBuildingId &&
      unitMatches &&
      (storedInvite == null ||
        String(storedInvite) === inviteRowId);

    if (canResume && typeof exBid === "string") {
      const unitId = exUnitId ?? inviteUnitId;
      const buildingName = await fetchBuildingName(supabase, exBid);
      const unitLabel = await fetchUnitLabel(supabase, unitId);
      return jsonResponse(200, {
        success: true,
        probe: true,
        would_resume: true,
        building_id: exBid,
        building_name: buildingName.length > 0 ? buildingName : null,
        unit_label: unitLabel.length > 0 ? unitLabel : null,
      });
    }

    if (residentCanonical) {
      const buildingName = await fetchBuildingName(
        supabase,
        residentCanonical.building_id,
      );
      const unitLabel = await fetchUnitLabel(
        supabase,
        residentCanonical.unit_id,
      );
      return jsonResponse(200, {
        success: true,
        probe: true,
        would_resume: true,
        building_id: residentCanonical.building_id,
        building_name: buildingName.length > 0 ? buildingName : null,
        unit_label: unitLabel.length > 0 ? unitLabel : null,
      });
    }

    if (
      inviteCodeWasUsed(row) &&
      inviteBuildingId &&
      inviteUnitId
    ) {
      const buildingName = await fetchBuildingName(supabase, inviteBuildingId);
      const unitLabel = await fetchUnitLabel(supabase, inviteUnitId);
      return jsonResponse(200, {
        success: true,
        probe: true,
        would_resume: true,
        building_id: inviteBuildingId,
        building_name: buildingName.length > 0 ? buildingName : null,
        unit_label: unitLabel.length > 0 ? unitLabel : null,
      });
    }

    return jsonResponse(200, {
      success: true,
      probe: true,
      would_resume: false,
    });
  }

  if (codeType === "unit" && !probeOnly) {
    const codeAlreadyUsed = inviteCodeWasUsed(row);
    if (!residentCanonical && codeAlreadyUsed) {
      residentCanonical = await findCanonicalResidentForInvite(
        supabase,
        inviteRowId,
        inviteBuildingId,
        inviteUnitId,
      );
    }
    const isReturning = residentCanonical != null;
    if (!isReturning && (!fullName || fullName.length < 3)) {
      return jsonResponse(422, {
        success: false,
        error: "full_name_required",
        message: "Ad soyad en az 3 karakter olmalı.",
      });
    }
  }

  if (codeType === "admin") {
    let devProbe = await supabase
      .from("devices")
      .select("building_id, profile_id, unit_id, role, admin_invite_code_id")
      .eq("device_id", deviceId)
      .maybeSingle();

    if (
      devProbe.error &&
      isMissingColumn(devProbe.error, "admin_invite_code_id")
    ) {
      devProbe = await supabase
        .from("devices")
        .select("building_id, profile_id, unit_id, role")
        .eq("device_id", deviceId)
        .maybeSingle();
    }

    if (devProbe.error) {
      console.error("devices select admin resume", devProbe.error);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const ex = devProbe.data as Record<string, unknown> | null;
    const exBid = ex?.building_id;
    const storedInvite = ex?.admin_invite_code_id;
    const canResume =
      ex?.role === "building_admin" &&
      typeof exBid === "string" &&
      exBid.length > 0 &&
      storedInvite != null &&
      String(storedInvite) === inviteRowId;

    if (probeOnly) {
      if (canResume && typeof exBid === "string") {
        let buildingName = "";
        const { data: bMetaProbe } = await supabase
          .from("buildings")
          .select("name")
          .eq("id", exBid)
          .maybeSingle();
        if (typeof bMetaProbe?.name === "string") {
          buildingName = (bMetaProbe.name as string).trim();
        }
        return jsonResponse(200, {
          success: true,
          probe: true,
          would_resume: true,
          building_id: exBid,
          building_name: buildingName.length > 0 ? buildingName : null,
        });
      }
      if (adminCanonical) {
        const buildingName = await fetchBuildingName(
          supabase,
          adminCanonical.building_id,
        );
        return jsonResponse(200, {
          success: true,
          probe: true,
          would_resume: true,
          building_id: adminCanonical.building_id,
          building_name: buildingName.length > 0 ? buildingName : null,
        });
      }
      return jsonResponse(200, {
        success: true,
        probe: true,
        would_resume: false,
      });
    }

    if (canResume) {
      let touchErr = (
        await supabase
          .from("devices")
          .update({
            session_token: sessionToken,
            last_seen_at: nowIso,
          })
          .eq("device_id", deviceId)
      ).error;

      if (touchErr && isMissingColumn(touchErr, "session_token")) {
        touchErr = (
          await supabase
            .from("devices")
            .update({ last_seen_at: nowIso })
            .eq("device_id", deviceId)
        ).error;
      }

      if (touchErr) {
        console.error("devices resume admin session", touchErr);
        return jsonResponse(500, { success: false, error: "database_error" });
      }

      const buildingName = await fetchBuildingName(
        supabase,
        String(exBid),
      );

      return jsonResponse(200, {
        success: true,
        role: "building_admin",
        building_id: exBid,
        unit_id: ex?.unit_id ?? null,
        profile_id: ex?.profile_id ?? null,
        session_token: sessionToken,
        building_name: buildingName.length > 0 ? buildingName : null,
        resumed: true,
      });
    }

    if (adminCanonical) {
      return await grantManagerAccess(
        supabase,
        deviceId,
        sessionToken,
        nowIso,
        inviteRowId,
        adminCanonical,
      );
    }

    if (adminRedeemPolicy !== "reusable") {
      const { data: locked, error: updErr } = await supabase
        .from("invite_codes")
        .update({
          status: "used",
          used_at: nowIso,
          used_by_device_id: deviceId,
        })
        .eq("id", row.id)
        .eq("status", "active")
        .select("id")
        .maybeSingle();

      if (updErr) {
        console.error("invite_codes update admin", updErr);
        return jsonResponse(500, { success: false, error: "database_error" });
      }

      if (!locked) {
        return jsonResponse(409, {
          success: false,
          error: "code_already_used",
          message: "Bu kod daha önce kullanılmış.",
        });
      }
    }

    const { error: devErr } = await upsertDeviceWithLegacyColumns(supabase, {
      device_id: deviceId,
      profile_id: null,
      building_id: null,
      unit_id: null,
      role: "building_admin",
      session_token: sessionToken,
      last_seen_at: nowIso,
      admin_invite_code_id: inviteRowId,
    });

    if (devErr) {
      console.error("devices upsert admin", devErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    return jsonResponse(200, {
      success: true,
      role: "building_admin",
      building_id: null,
      unit_id: null,
      profile_id: null,
      session_token: sessionToken,
    });
  }

  if (codeType === "unit") {
    if (!residentCanonical && inviteCodeWasUsed(row)) {
      residentCanonical = await findCanonicalResidentForInvite(
        supabase,
        inviteRowId,
        inviteBuildingId,
        inviteUnitId,
      );
    }

    if (residentCanonical) {
      const pid = residentCanonical.profile_id;
      const bid = residentCanonical.building_id;
      if (
        pid &&
        await profileHasResidentMembership(supabase, bid, pid)
      ) {
        return await grantResidentAccess(
          supabase,
          deviceId,
          sessionToken,
          nowIso,
          inviteRowId,
          residentCanonical,
          fullName ?? "",
        );
      }
      residentCanonical = null;
    }

    if (
      inviteCodeWasUsed(row) &&
      !residentCanonical &&
      inviteBuildingId &&
      inviteUnitId &&
      (!fullName || fullName.length < 3)
    ) {
      const profileId = await findMembershipProfileForUnit(
        supabase,
        inviteBuildingId,
        inviteUnitId,
      );
      if (
        profileId &&
        await profileHasResidentMembership(
          supabase,
          inviteBuildingId,
          profileId,
        )
      ) {
        residentCanonical = await profileToCanonicalResident(
          supabase,
          profileId,
          inviteBuildingId,
          inviteUnitId,
        );
        if (residentCanonical) {
          return await grantResidentAccess(
            supabase,
            deviceId,
            sessionToken,
            nowIso,
            inviteRowId,
            residentCanonical,
            fullName ?? "",
          );
        }
      }
      return jsonResponse(409, {
        success: false,
        error: "resident_registration_not_found",
        message:
          "Bu kodla kayıt bulunamadı. Yöneticinize başvurun.",
      });
    }

    if (!fullName || fullName.length < 3) {
      return jsonResponse(422, {
        success: false,
        error: "full_name_required",
        message: "Ad soyad en az 3 karakter olmalı.",
      });
    }

    // Audit first use only; code stays active for repeat login on other devices.
    await supabase
      .from("invite_codes")
      .update({
        used_at: nowIso,
        used_by_device_id: deviceId,
      })
      .eq("id", row.id)
      .is("used_at", null);

    const buildingId = row.building_id as string | null;
    const unitId = row.unit_id as string | null;

    const residentAfterAudit = await findCanonicalResidentForInvite(
      supabase,
      inviteRowId,
      buildingId,
      unitId,
    );
    if (residentAfterAudit) {
      return await grantResidentAccess(
        supabase,
        deviceId,
        sessionToken,
        nowIso,
        inviteRowId,
        residentAfterAudit,
        fullName ?? "",
      );
    }

    if (!buildingId) {
      return jsonResponse(500, {
        success: false,
        error: "invite_data_invalid",
      });
    }

    const { data: profile, error: pErr } = await supabase
      .from("profiles")
      .insert({
        full_name: fullName,
        language: "tr",
      })
      .select("id")
      .single();

    if (pErr || !profile) {
      console.error("profiles insert", pErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const profileId = profile.id as string;

    const { error: mErr } = await supabase.from("memberships").insert({
      user_id: profileId,
      building_id: buildingId,
      unit_id: unitId,
      role: "resident",
      status: "active",
    });

    if (mErr) {
      console.error("memberships insert", mErr);
      await supabase.from("profiles").delete().eq("id", profileId);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const { error: dErr } = await upsertDeviceWithLegacyColumns(supabase, {
      device_id: deviceId,
      profile_id: profileId,
      building_id: buildingId,
      unit_id: unitId,
      role: "resident",
      session_token: sessionToken,
      last_seen_at: nowIso,
      admin_invite_code_id: inviteRowId,
    });

    if (dErr) {
      console.error("devices upsert unit", dErr);
      await supabase.from("memberships").delete().eq("user_id", profileId);
      await supabase.from("profiles").delete().eq("id", profileId);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const buildingName = await fetchBuildingName(supabase, buildingId);

    return jsonResponse(200, {
      success: true,
      role: "resident",
      building_id: buildingId,
      unit_id: unitId,
      profile_id: profileId,
      session_token: sessionToken,
      building_name: buildingName.length > 0 ? buildingName : null,
    });
  }

  return jsonResponse(400, { success: false, error: "unknown_code_type" });
});
