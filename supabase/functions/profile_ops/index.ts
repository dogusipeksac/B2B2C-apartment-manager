/**
 * Device session profile: read linked unit/code (read-only) and update full_name.
 *
 * POST JSON:
 * { "action": "get" | "update_name", "device_id", "session_token",
 *   "full_name"?: string }
 */
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

import { isMissingColumn } from "../_shared/db_compat.ts";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const ALLOWED_ROLES = new Set([
  "building_admin",
  "building_co_admin",
  "accountant",
  "resident",
  "owner",
  "super_admin",
]);

const ADMIN_ROLES = new Set(["building_admin", "building_co_admin"]);

const RESIDENT_ROLES = new Set(["resident", "owner"]);

type DeviceRow = {
  profile_id: string | null;
  building_id: string | null;
  unit_id: string | null;
  role: string;
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

async function assertDeviceSession(
  supabase: ReturnType<typeof createClient>,
  deviceId: string,
  sessionToken: string,
): Promise<
  | { ok: true; device: DeviceRow }
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
    if (ALLOWED_ROLES.has(role) && (hasBuilding || role === "super_admin")) {
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
  if (!ALLOWED_ROLES.has(role)) {
    return { ok: false, status: 403, error: "not_building_member" };
  }

  return {
    ok: true,
    device: {
      profile_id: deviceRow.profile_id as string | null,
      building_id: deviceRow.building_id as string | null,
      unit_id: deviceRow.unit_id as string | null,
      role,
    },
  };
}

async function resolveProfileId(
  supabase: ReturnType<typeof createClient>,
  deviceId: string,
  device: DeviceRow,
): Promise<string | null> {
  const direct = device.profile_id;
  if (direct != null && String(direct).trim().length > 0) {
    return String(direct).trim();
  }

  const buildingId = device.building_id;
  if (!buildingId || buildingId.length === 0) {
    return null;
  }

  const role = String(device.role ?? "");

  if (RESIDENT_ROLES.has(role)) {
    const unitId = device.unit_id;
    if (unitId != null && String(unitId).trim().length > 0) {
      let memQuery = supabase
        .from("memberships")
        .select("user_id")
        .eq("building_id", buildingId)
        .eq("unit_id", String(unitId).trim())
        .in("role", ["resident", "owner"]);

      let memRes = await memQuery.eq("status", "active").limit(1).maybeSingle();
      if (memRes.error && isMissingColumn(memRes.error, "status")) {
        memRes = await memQuery.limit(1).maybeSingle();
      }
      if (memRes.data?.user_id) {
        const pid = String(memRes.data.user_id).trim();
        await supabase
          .from("devices")
          .update({ profile_id: pid, last_seen_at: new Date().toISOString() })
          .eq("device_id", deviceId);
        return pid;
      }
    }

    const { data: inv } = await supabase
      .from("invite_codes")
      .select("unit_id")
      .eq("used_by_device_id", deviceId)
      .eq("code_type", "unit")
      .not("unit_id", "is", null)
      .order("used_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    const invUnit = inv?.unit_id;
    if (invUnit != null && String(invUnit).trim().length > 0) {
      let memQuery = supabase
        .from("memberships")
        .select("user_id")
        .eq("building_id", buildingId)
        .eq("unit_id", String(invUnit).trim())
        .in("role", ["resident", "owner"]);

      let memRes = await memQuery.eq("status", "active").limit(1).maybeSingle();
      if (memRes.error && isMissingColumn(memRes.error, "status")) {
        memRes = await memQuery.limit(1).maybeSingle();
      }
      if (memRes.data?.user_id) {
        const pid = String(memRes.data.user_id).trim();
        await supabase
          .from("devices")
          .update({
            profile_id: pid,
            unit_id: String(invUnit).trim(),
            last_seen_at: new Date().toISOString(),
          })
          .eq("device_id", deviceId);
        return pid;
      }
    }

    return null;
  }

  if (!ADMIN_ROLES.has(role)) {
    return null;
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

  const { data: mem } = await supabase
    .from("memberships")
    .select("user_id")
    .eq("building_id", buildingId)
    .eq("role", "building_admin")
    .limit(1)
    .maybeSingle();

  if (mem?.user_id) {
    return String(mem.user_id);
  }

  return null;
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
    full_name?: string;
  };
  try {
    payload = await req.json();
  } catch {
    return jsonResponse(400, { success: false, error: "invalid_json" });
  }

  const action = payload.action?.trim();
  const deviceId = payload.device_id?.trim();
  const sessionToken = payload.session_token?.trim();

  if (!deviceId || !sessionToken) {
    return jsonResponse(400, {
      success: false,
      error: "device_or_token_required",
    });
  }

  if (action !== "get" && action !== "update_name") {
    return jsonResponse(400, { success: false, error: "unknown_action" });
  }

  const gate = await assertDeviceSession(supabase, deviceId, sessionToken);
  if (!gate.ok) {
    return jsonResponse(gate.status, { success: false, error: gate.error });
  }

  const device = gate.device;
  const profileId = await resolveProfileId(supabase, deviceId, device);

  if (action === "update_name") {
    const fullName = payload.full_name?.trim() ?? "";
    if (fullName.length < 2) {
      return jsonResponse(422, {
        success: false,
        error: "full_name_too_short",
      });
    }
    if (fullName.length > 80) {
      return jsonResponse(422, {
        success: false,
        error: "full_name_too_long",
      });
    }

    if (!profileId) {
      return jsonResponse(422, {
        success: false,
        error: "profile_required",
      });
    }

    const { error: upErr } = await supabase
      .from("profiles")
      .update({ full_name: fullName })
      .eq("id", profileId);

    if (upErr) {
      console.error("profiles update full_name", upErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    if (!device.profile_id) {
      await supabase
        .from("devices")
        .update({ profile_id: profileId })
        .eq("device_id", deviceId);
    }

    return jsonResponse(200, {
      success: true,
      full_name: fullName,
      profile_id: profileId,
    });
  }

  // get
  let fullName: string | null = null;
  if (profileId) {
    const { data: prof } = await supabase
      .from("profiles")
      .select("full_name")
      .eq("id", profileId)
      .maybeSingle();
    const fn = prof?.full_name;
    if (typeof fn === "string" && fn.trim().length > 0) {
      fullName = fn.trim();
    }
  }

  let buildingName: string | null = null;
  const buildingId = device.building_id;
  if (buildingId && String(buildingId).length > 0) {
    const { data: bMeta } = await supabase
      .from("buildings")
      .select("name")
      .eq("id", buildingId)
      .maybeSingle();
    const bn = bMeta?.name;
    if (typeof bn === "string" && bn.trim().length > 0) {
      buildingName = bn.trim();
    }
  }

  let unitLabel: string | null = null;
  let unitId = device.unit_id;
  if (!unitId && profileId && buildingId) {
    const { data: mem } = await supabase
      .from("memberships")
      .select("unit_id")
      .eq("building_id", buildingId)
      .eq("user_id", profileId)
      .maybeSingle();
    if (mem?.unit_id) {
      unitId = String(mem.unit_id);
    }
  }

  if (unitId && buildingId) {
    const { data: unitRow } = await supabase
      .from("units")
      .select("floor, door_number, block")
      .eq("id", unitId)
      .eq("building_id", buildingId)
      .maybeSingle();
    if (unitRow) {
      unitLabel = formatUnitLabel(
        unitRow.floor as number | null,
        String(unitRow.door_number ?? ""),
        typeof unitRow.block === "string" ? unitRow.block : "",
      );
    }
  }

  let inviteCode: string | null = null;
  const { data: usedCodes } = await supabase
    .from("invite_codes")
    .select("code, code_type")
    .eq("used_by_device_id", deviceId)
    .order("used_at", { ascending: false })
    .limit(3);

  if (usedCodes && usedCodes.length > 0) {
    const unitUsed = usedCodes.find((c) => c.code_type === "unit");
    const adminUsed = usedCodes.find((c) => c.code_type === "admin");
    const pick = unitUsed ?? adminUsed ?? usedCodes[0];
    if (pick?.code) {
      inviteCode = String(pick.code).trim();
    }
  }

  return jsonResponse(200, {
    success: true,
    full_name: fullName,
    profile_id: profileId,
    building_name: buildingName,
    unit_label: unitLabel,
    invite_code: inviteCode,
    role: device.role,
  });
});
