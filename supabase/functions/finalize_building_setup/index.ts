/**
 * Creates building, units, manager profile, and membership for a device that
 * redeemed an admin invite (service role — bypasses RLS).
 *
 * POST JSON:
 * {
 *   "device_id": string,
 *   "session_token": string,
 *   "manager_full_name"?: string,
 *   "building": {
 *     "name": string,
 *     "address"?: string,
 *     "city": string,
 *     "district": string,
 *     "monthly_dues_minor": number,
 *     "dues_due_day": number,
 *     "late_fee_enabled": boolean,
 *     "single_block": boolean,
 *     "floors": number,
 *     "per_floor": number,
 *     "naming_automatic": boolean
 *   }
 * }
 */
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

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

function minorToNumericString(minor: number): string {
  const neg = minor < 0;
  const abs = Math.abs(Math.trunc(minor));
  const lira = Math.floor(abs / 100);
  const kurus = abs % 100;
  const core = `${lira}.${String(kurus).padStart(2, "0")}`;
  return neg ? `-${core}` : core;
}

function generateUnits(
  floors: number,
  perFloor: number,
  singleBlock: boolean,
  namingAutomatic: boolean,
): Array<{ floor: number; door_number: string; block: string }> {
  if (!namingAutomatic) {
    throw new Error("custom_naming_not_supported");
  }
  const block = singleBlock ? "" : "A";
  const units: Array<{ floor: number; door_number: string; block: string }> =
    [];
  for (let fi = 1; fi <= floors; fi++) {
    for (let k = 0; k < perFloor; k++) {
      const letter = String.fromCharCode(65 + k);
      units.push({
        floor: fi,
        door_number: `${fi}${letter}`,
        block,
      });
    }
  }
  return units;
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
    device_id?: string;
    session_token?: string;
    manager_full_name?: string;
    building?: Record<string, unknown>;
  };
  try {
    payload = await req.json();
  } catch {
    return jsonResponse(400, { success: false, error: "invalid_json" });
  }

  const deviceId = payload.device_id?.trim();
  const sessionToken = payload.session_token?.trim();
  const managerName = payload.manager_full_name?.trim();

  if (!deviceId || !sessionToken) {
    return jsonResponse(400, {
      success: false,
      error: "device_or_token_required",
    });
  }

  const b = payload.building;
  if (!b || typeof b !== "object") {
    return jsonResponse(400, { success: false, error: "building_required" });
  }

  const name = typeof b.name === "string" ? b.name.trim() : "";
  const city = typeof b.city === "string" ? b.city.trim() : "";
  const district = typeof b.district === "string" ? b.district.trim() : "";
  const address = typeof b.address === "string" ? b.address.trim() : "";

  const monthlyMinor = Number(b.monthly_dues_minor);
  const duesDueDay = Number(b.dues_due_day);
  const lateFeeEnabled = Boolean(b.late_fee_enabled);
  const singleBlock = Boolean(b.single_block);
  const floors = Number(b.floors);
  const perFloor = Number(b.per_floor);
  const namingAutomatic = Boolean(b.naming_automatic);

  if (!name || !city || !district) {
    return jsonResponse(422, {
      success: false,
      error: "building_fields_invalid",
    });
  }
  if (
    !Number.isFinite(monthlyMinor) ||
    monthlyMinor < 0 ||
    !Number.isFinite(duesDueDay) ||
    duesDueDay < 1 ||
    duesDueDay > 28 ||
    !Number.isFinite(floors) ||
    floors < 1 ||
    floors > 60 ||
    !Number.isFinite(perFloor) ||
    perFloor < 1 ||
    perFloor > 40
  ) {
    return jsonResponse(422, {
      success: false,
      error: "building_numeric_invalid",
    });
  }

  let unitsSpec: Array<
    { floor: number; door_number: string; block: string }
  >;
  try {
    unitsSpec = generateUnits(
      Math.trunc(floors),
      Math.trunc(perFloor),
      singleBlock,
      namingAutomatic,
    );
  } catch (e) {
    const msg = e instanceof Error ? e.message : "invalid_units";
    if (msg === "custom_naming_not_supported") {
      return jsonResponse(422, {
        success: false,
        error: "custom_naming_not_supported",
      });
    }
    return jsonResponse(422, { success: false, error: msg });
  }

  const { data: deviceRow, error: devFetchErr } = await supabase
    .from("devices")
    .select("id, profile_id, building_id, role, session_token")
    .eq("device_id", deviceId)
    .maybeSingle();

  if (devFetchErr) {
    console.error("devices select", devFetchErr);
    return jsonResponse(500, { success: false, error: "database_error" });
  }

  if (!deviceRow) {
    return jsonResponse(404, { success: false, error: "device_not_found" });
  }

  const clientTok = sessionToken.trim();
  let dbTok = String(deviceRow.session_token ?? "").trim();

  // Heal legacy rows where redeem ran before session_token was persisted correctly.
  if (dbTok !== clientTok) {
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
      } else {
        console.error("devices heal session_token", healErr);
      }
    }
  }

  if (dbTok !== clientTok) {
    return jsonResponse(401, { success: false, error: "invalid_session" });
  }

  if (deviceRow.role !== "building_admin") {
    return jsonResponse(403, { success: false, error: "not_building_admin" });
  }

  // Idempotent: prior run may have committed DB but app crashed before saving
  // LocalSession — return existing ids so the client can sync and open home.
  if (deviceRow.building_id) {
    const buildingIdExisting = String(deviceRow.building_id);
    const profileIdRaw = deviceRow.profile_id;
    if (!profileIdRaw || String(profileIdRaw).length === 0) {
      return jsonResponse(409, {
        success: false,
        error: "building_already_created_inconsistent",
      });
    }
    const profileIdExisting = String(profileIdRaw);
    const { count: unitCount, error: cntErr } = await supabase
      .from("units")
      .select("*", { count: "exact", head: true })
      .eq("building_id", buildingIdExisting);

    if (cntErr) {
      console.error("units count", cntErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const { data: bnRow } = await supabase
      .from("buildings")
      .select("name")
      .eq("id", buildingIdExisting)
      .maybeSingle();
    const resumedName = typeof bnRow?.name === "string"
      ? (bnRow.name as string).trim()
      : "";

    return jsonResponse(200, {
      success: true,
      building_id: buildingIdExisting,
      profile_id: profileIdExisting,
      unit_count: typeof unitCount === "number" ? unitCount : 0,
      resumed: true,
      building_name: resumedName,
    });
  }

  const displayName = managerName && managerName.length >= 2
    ? managerName
    : "Site Yöneticisi";

  const { data: profile, error: pErr } = await supabase
    .from("profiles")
    .insert({
      full_name: displayName,
      language: "tr",
    })
    .select("id")
    .single();

  if (pErr || !profile) {
    console.error("profiles insert", pErr);
    return jsonResponse(500, { success: false, error: "database_error" });
  }

  const profileId = profile.id as string;

  const lateFeePercent = lateFeeEnabled ? 2 : 0;

  const { data: building, error: bErr } = await supabase
    .from("buildings")
    .insert({
      name,
      address: address || null,
      city,
      district,
      created_by: profileId,
      total_units: unitsSpec.length,
      monthly_dues_amount: minorToNumericString(Math.trunc(monthlyMinor)),
      dues_due_day: Math.trunc(duesDueDay),
      late_fee_percent: lateFeePercent,
    })
    .select("id")
    .single();

  if (bErr || !building) {
    console.error("buildings insert", bErr);
    await supabase.from("profiles").delete().eq("id", profileId);
    return jsonResponse(500, { success: false, error: "database_error" });
  }

  const buildingId = building.id as string;

  const unitRows = unitsSpec.map((u) => ({
    building_id: buildingId,
    floor: u.floor,
    door_number: u.door_number,
    // Empty string for single-block so (building_id, block, door_number) stays unique.
    block: u.block.length > 0 ? u.block : "",
    type: "apartment",
    is_active: true,
  }));

  const { error: uErr } = await supabase.from("units").insert(unitRows);

  if (uErr) {
    console.error("units insert", uErr);
    await supabase.from("buildings").delete().eq("id", buildingId);
    await supabase.from("profiles").delete().eq("id", profileId);
    return jsonResponse(500, { success: false, error: "database_error" });
  }

  const { error: mErr } = await supabase.from("memberships").insert({
    user_id: profileId,
    building_id: buildingId,
    unit_id: null,
    role: "building_admin",
    status: "active",
  });

  if (mErr) {
    console.error("memberships insert", mErr);
    await supabase.from("units").delete().eq("building_id", buildingId);
    await supabase.from("buildings").delete().eq("id", buildingId);
    await supabase.from("profiles").delete().eq("id", profileId);
    return jsonResponse(500, { success: false, error: "database_error" });
  }

  const nowIso = new Date().toISOString();
  const { error: upDevErr } = await supabase.from("devices").update({
    profile_id: profileId,
    building_id: buildingId,
    last_seen_at: nowIso,
  }).eq("device_id", deviceId);

  if (upDevErr) {
    console.error("devices update", upDevErr);
    return jsonResponse(500, { success: false, error: "database_error" });
  }

  return jsonResponse(200, {
    success: true,
    building_id: buildingId,
    profile_id: profileId,
    unit_count: unitsSpec.length,
    building_name: name,
  });
});
