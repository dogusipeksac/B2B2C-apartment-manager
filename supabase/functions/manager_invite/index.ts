/**
 * Manager-only: list units for building or create a resident (unit) invite code.
 *
 * POST JSON:
 * { "action": "list_units" | "create_invite" | "revoke_invite" | "assign_my_unit",
 *   "device_id", "session_token", "unit_id"?: uuid, "notes"?: string,
 *   "profile_id"?: uuid }
 */
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

import { isMissingColumn } from "../_shared/db_compat.ts";
import {
  UNIT_CODE_LENGTH,
  allocateUniqueInviteCode,
  isInviteCodeDuplicateError,
} from "../_shared/invite_code_gen.ts";
import { parseInviteNotes } from "../_shared/invite_notes.ts";

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

type DeviceRow = {
  profile_id: string | null;
  building_id: string | null;
  role: string;
  session_token: string | null;
};

async function assertManagerSession(
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
    .select("profile_id, building_id, role, session_token")
    .eq("device_id", deviceId)
    .maybeSingle();

  let deviceRow: Record<string, unknown> | null = null;
  let legacyNoSessionColumn = false;

  if (full.error && isMissingColumn(full.error, "session_token")) {
    const leg = await supabase
      .from("devices")
      .select("profile_id, building_id, role")
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

  if (!legacyNoSessionColumn && dbTok !== clientTok) {
    const roleOk = deviceRow.role === "building_admin";
    const noBuilding =
      deviceRow.building_id === null ||
      String(deviceRow.building_id).length === 0;
    const dbEmpty = dbTok.length === 0;

    if (roleOk && noBuilding && dbEmpty && clientTok.length > 0) {
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

  if (deviceRow.role !== "building_admin") {
    return { ok: false, status: 403, error: "not_building_admin" };
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
      role: String(deviceRow.role ?? ""),
      session_token: deviceRow.session_token as string | null,
    },
  };
}

function formatUnitLabel(
  floor: number | null,
  door: string,
  block: string,
): string {
  const floorPart = floor == null ? "" : `${floor}. kat · `;
  const b = block.trim();
  if (b.length > 0) {
    return `${floorPart}${b} · ${door.trim()}`;
  }
  return `${floorPart}${door.trim()}`;
}

async function resolveManagerProfileId(
  supabase: ReturnType<typeof createClient>,
  deviceId: string,
  buildingId: string,
  device: DeviceRow,
  profileHint?: string | null,
): Promise<string | null> {
  const direct = device.profile_id;
  if (direct != null && String(direct).trim().length > 0) {
    return String(direct).trim();
  }

  const { data: devRow } = await supabase
    .from("devices")
    .select("profile_id")
    .eq("device_id", deviceId)
    .maybeSingle();

  const fromDev = devRow?.profile_id;
  if (fromDev != null && String(fromDev).trim().length > 0) {
    return String(fromDev).trim();
  }

  const hint = profileHint ? String(profileHint).trim() : "";
  if (hint.length > 0) {
    const { count } = await supabase
      .from("memberships")
      .select("id", { count: "exact", head: true })
      .eq("building_id", buildingId)
      .eq("user_id", hint);
    if ((count ?? 0) > 0) {
      return hint;
    }
  }

  const { data: building } = await supabase
    .from("buildings")
    .select("created_by")
    .eq("id", buildingId)
    .maybeSingle();

  const createdBy = building?.created_by;
  if (createdBy != null && String(createdBy).trim().length > 0) {
    return String(createdBy).trim();
  }

  return null;
}

async function persistManagerProfileAndUnit(
  supabase: ReturnType<typeof createClient>,
  deviceId: string,
  buildingId: string,
  profileId: string,
  unitId: string,
): Promise<void> {
  const nowIso = new Date().toISOString();
  await supabase
    .from("devices")
    .update({
      profile_id: profileId,
      building_id: buildingId,
      unit_id: unitId,
      last_seen_at: nowIso,
    })
    .eq("device_id", deviceId);

  const { data: existingMem } = await supabase
    .from("memberships")
    .select("id")
    .eq("building_id", buildingId)
    .eq("user_id", profileId)
    .eq("role", "building_admin")
    .maybeSingle();

  if (existingMem?.id) {
    await supabase
      .from("memberships")
      .update({ unit_id: unitId })
      .eq("id", existingMem.id);
  } else {
    await supabase.from("memberships").insert({
      user_id: profileId,
      building_id: buildingId,
      unit_id: unitId,
      role: "building_admin",
      status: "active",
    });
  }
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
    action?: string;
    device_id?: string;
    session_token?: string;
    unit_id?: string;
    notes?: string;
    profile_id?: string;
  };

  try {
    payload = await req.json();
  } catch {
    return jsonResponse(400, { success: false, error: "invalid_json" });
  }

  const deviceId = payload.device_id?.trim();
  const sessionToken = payload.session_token?.trim();
  const action = payload.action?.trim();

  if (!deviceId || !sessionToken) {
    return jsonResponse(400, {
      success: false,
      error: "device_or_token_required",
    });
  }

  if (
    action !== "list_units" &&
    action !== "create_invite" &&
    action !== "revoke_invite" &&
    action !== "assign_my_unit"
  ) {
    return jsonResponse(400, { success: false, error: "unknown_action" });
  }

  const gate = await assertManagerSession(supabase, deviceId, sessionToken);
  if (!gate.ok) {
    return jsonResponse(gate.status, { success: false, error: gate.error });
  }

  const buildingId = gate.device.building_id;
  const profileHint = payload.profile_id?.trim() || null;

  if (action === "assign_my_unit") {
    const unitIdAssign = payload.unit_id?.trim();
    if (!unitIdAssign) {
      return jsonResponse(400, {
        success: false,
        error: "unit_id_required",
      });
    }

    const profileId = await resolveManagerProfileId(
      supabase,
      deviceId,
      buildingId,
      gate.device,
      profileHint,
    );
    if (!profileId) {
      return jsonResponse(422, {
        success: false,
        error: "profile_required",
      });
    }

    const { data: unitRow, error: uErr } = await supabase
      .from("units")
      .select("id, floor, door_number, block")
      .eq("id", unitIdAssign)
      .eq("building_id", buildingId)
      .eq("is_active", true)
      .maybeSingle();

    if (uErr) {
      console.error("units assign_my_unit", uErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    if (!unitRow) {
      return jsonResponse(422, { success: false, error: "invalid_unit" });
    }

    await persistManagerProfileAndUnit(
      supabase,
      deviceId,
      buildingId,
      profileId,
      String(unitRow.id),
    );

    const label = formatUnitLabel(
      unitRow.floor as number | null,
      String(unitRow.door_number ?? ""),
      typeof unitRow.block === "string" ? unitRow.block : "",
    );

    return jsonResponse(200, {
      success: true,
      unit_id: String(unitRow.id),
      unit_label: label,
      profile_id: profileId,
    });
  }

  if (action === "list_units") {
    const { data: bMeta, error: bErr } = await supabase
      .from("buildings")
      .select("name")
      .eq("id", buildingId)
      .maybeSingle();

    if (bErr) {
      console.error("buildings select name", bErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const buildingName = typeof bMeta?.name === "string"
      ? (bMeta.name as string).trim()
      : "";

    const { data: units, error: uErr } = await supabase
      .from("units")
      .select("id, floor, door_number, block")
      .eq("building_id", buildingId)
      .eq("is_active", true)
      .order("floor", { ascending: true })
      .order("door_number", { ascending: true });

    if (uErr) {
      console.error("units select", uErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const unitRows = (units ?? []).map((u: Record<string, unknown>) => ({
      id: u.id as string,
      floor: u.floor as number | null,
      door_number: String(u.door_number ?? ""),
      block: typeof u.block === "string" ? u.block.trim() : "",
    }));

    type InvitePick = {
      code: string;
      expires_at: string | null;
      notes: string | null;
      created_at: number;
    };
    const inviteByUnit = new Map<string, InvitePick>();

    const ids = unitRows.map((r) => r.id);
    const joinedUnitIds = new Set<string>();
    if (ids.length > 0) {
      const { data: memRows, error: memErr } = await supabase
        .from("memberships")
        .select("unit_id")
        .eq("building_id", buildingId)
        .eq("role", "resident")
        .eq("status", "active")
        .in("unit_id", ids);

      if (memErr) {
        console.error("memberships joined list", memErr);
        return jsonResponse(500, { success: false, error: "database_error" });
      }

      for (const m of memRows ?? []) {
        const uid = m.unit_id as string | null;
        if (uid) {
          joinedUnitIds.add(uid);
        }
      }
    }

    if (ids.length > 0) {
      const { data: invs, error: invErr } = await supabase
        .from("invite_codes")
        .select("unit_id, code, expires_at, notes, created_at")
        .eq("building_id", buildingId)
        .eq("code_type", "unit")
        .eq("status", "active")
        .in("unit_id", ids);

      if (invErr) {
        console.error("invite_codes list", invErr);
        return jsonResponse(500, { success: false, error: "database_error" });
      }

      const now = Date.now();
      for (const row of invs ?? []) {
        const uid = row.unit_id as string | null;
        if (!uid) continue;
        const expMs = row.expires_at
          ? new Date(row.expires_at as string).getTime()
          : null;
        if (expMs !== null && expMs < now) continue;

        const ca = new Date(row.created_at as string).getTime();
        const prev = inviteByUnit.get(uid);
        if (!prev || ca > prev.created_at) {
          const notesRaw = row.notes;
          const notesVal = typeof notesRaw === "string" && notesRaw.trim().length > 0
            ? notesRaw.trim()
            : null;
          inviteByUnit.set(uid, {
            code: row.code as string,
            expires_at: row.expires_at ? String(row.expires_at) : null,
            notes: notesVal,
            created_at: ca,
          });
        }
      }
    }

    let myUnitId: string | null = null;
    const { data: devUnit } = await supabase
      .from("devices")
      .select("unit_id, profile_id")
      .eq("device_id", deviceId)
      .maybeSingle();

    if (devUnit?.unit_id) {
      myUnitId = String(devUnit.unit_id);
    }

    if (!myUnitId) {
      const profileId = await resolveManagerProfileId(
        supabase,
        deviceId,
        buildingId,
        gate.device,
        profileHint,
      );
      if (profileId) {
        const { data: mem } = await supabase
          .from("memberships")
          .select("unit_id")
          .eq("building_id", buildingId)
          .eq("user_id", profileId)
          .eq("role", "building_admin")
          .maybeSingle();
        if (mem?.unit_id) {
          myUnitId = String(mem.unit_id);
        }
      }
    }

    let myUnitLabel: string | null = null;
    if (myUnitId) {
      const mine = unitRows.find((u) => u.id === myUnitId);
      if (mine) {
        myUnitLabel = formatUnitLabel(mine.floor, mine.door_number, mine.block);
      }
    }

    const rows = unitRows.map((u) => {
      const inv = inviteByUnit.get(u.id);
      const isManagerUnit = myUnitId != null && u.id === myUnitId;
      return {
        ...u,
        invite_code: inv?.code ?? null,
        invite_expires_at: inv?.expires_at ?? null,
        invite_notes: inv?.notes ?? null,
        resident_joined: joinedUnitIds.has(u.id),
        is_manager_unit: isManagerUnit,
      };
    });

    return jsonResponse(200, {
      success: true,
      building_name: buildingName,
      my_unit_id: myUnitId,
      my_unit_label: myUnitLabel,
      units: rows,
    });
  }

  if (action === "revoke_invite") {
    const unitIdRevoke = payload.unit_id?.trim();
    if (!unitIdRevoke || unitIdRevoke.length === 0) {
      return jsonResponse(400, {
        success: false,
        error: "unit_id_required",
      });
    }

    const { data: uOk, error: verifyErr } = await supabase
      .from("units")
      .select("id")
      .eq("id", unitIdRevoke)
      .eq("building_id", buildingId)
      .maybeSingle();

    if (verifyErr) {
      console.error("units verify revoke", verifyErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    if (!uOk) {
      return jsonResponse(422, { success: false, error: "invalid_unit" });
    }

    const { data: revokedRows, error: revErr } = await supabase
      .from("invite_codes")
      .update({ status: "revoked" })
      .eq("building_id", buildingId)
      .eq("unit_id", unitIdRevoke)
      .eq("code_type", "unit")
      .eq("status", "active")
      .select("id");

    if (revErr) {
      console.error("invite_codes revoke unit", revErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    if (!revokedRows || revokedRows.length === 0) {
      return jsonResponse(404, {
        success: false,
        error: "unit_invite_not_found",
      });
    }

    return jsonResponse(200, { success: true });
  }

  // create_invite
  const notes = parseInviteNotes(payload.notes);
  let unitId = payload.unit_id?.trim();
  if (!unitId || unitId.length === 0) {
    const { data: first, error: fErr } = await supabase
      .from("units")
      .select("id")
      .eq("building_id", buildingId)
      .eq("is_active", true)
      .order("floor", { ascending: true })
      .order("door_number", { ascending: true })
      .limit(1)
      .maybeSingle();

    if (fErr) {
      console.error("units first", fErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    if (!first?.id) {
      return jsonResponse(422, {
        success: false,
        error: "no_units_for_building",
      });
    }

    unitId = first.id as string;
  } else {
    const { data: uOk, error: verifyErr } = await supabase
      .from("units")
      .select("id")
      .eq("id", unitId)
      .eq("building_id", buildingId)
      .maybeSingle();

    if (verifyErr) {
      console.error("units verify", verifyErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    if (!uOk) {
      return jsonResponse(422, { success: false, error: "invalid_unit" });
    }
  }

  const createdBy = gate.device.profile_id;

  // Reuse newest non-expired active unit invite instead of inserting duplicates.
  const { data: existingRows, error: exErr } = await supabase
    .from("invite_codes")
    .select("id, code, expires_at, created_at")
    .eq("building_id", buildingId)
    .eq("unit_id", unitId)
    .eq("code_type", "unit")
    .eq("status", "active")
    .order("created_at", { ascending: false });

  if (exErr) {
    console.error("invite_codes existing select", exErr);
    return jsonResponse(500, { success: false, error: "database_error" });
  }

  const nowMs = Date.now();
  for (const row of existingRows ?? []) {
    const expMs = row.expires_at
      ? new Date(row.expires_at as string).getTime()
      : null;
    if (expMs !== null && expMs < nowMs) {
      continue;
    }
    const codeReuse = String(row.code ?? "").trim();
    if (codeReuse.length === 0) {
      continue;
    }
    const existingId = row.id as string | undefined;
    if (notes && existingId) {
      await supabase
        .from("invite_codes")
        .update({ notes })
        .eq("id", existingId);
    }
    return jsonResponse(200, {
      success: true,
      code: codeReuse,
      unit_id: unitId,
      expires_at: row.expires_at ?? null,
      reused: true,
    });
  }

  for (let attempt = 0; attempt < 8; attempt++) {
    const code = await allocateUniqueInviteCode(supabase, UNIT_CODE_LENGTH);
    if (!code) {
      break;
    }
    const { data: row, error: insErr } = await supabase
      .from("invite_codes")
      .insert({
        code,
        code_type: "unit",
        status: "active",
        building_id: buildingId,
        unit_id: unitId,
        created_by: createdBy,
        ...(notes ? { notes } : {}),
      })
      .select("expires_at")
      .single();

    if (!insErr && row) {
      return jsonResponse(200, {
        success: true,
        code,
        unit_id: unitId,
        expires_at: row.expires_at ?? null,
        reused: false,
      });
    }

    if (isInviteCodeDuplicateError(insErr)) {
      continue;
    }

    console.error("invite_codes insert", insErr);
    return jsonResponse(500, { success: false, error: "database_error" });
  }

  return jsonResponse(500, { success: false, error: "code_generation_failed" });
});
