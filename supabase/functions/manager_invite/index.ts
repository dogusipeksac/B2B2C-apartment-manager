/**
 * Manager-only: list units for building or create a resident (unit) invite code.
 *
 * POST JSON:
 * { "action": "list_units" | "create_invite", "device_id", "session_token",
 *   "unit_id"?: uuid }  // optional for create_invite — picks first unit if omitted
 */
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

function jsonResponse(
  status: number,
  body: Record<string, unknown>,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function randomUnitCode(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(5));
  let s = "";
  for (let i = 0; i < 5; i++) {
    s += CODE_ALPHABET[bytes[i]! % CODE_ALPHABET.length];
  }
  return s;
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

  const { data: deviceRow, error: devFetchErr } = await supabase
    .from("devices")
    .select("profile_id, building_id, role, session_token")
    .eq("device_id", deviceId)
    .maybeSingle();

  if (devFetchErr) {
    console.error("devices select", devFetchErr);
    return { ok: false, status: 500, error: "database_error" };
  }

  if (!deviceRow) {
    return { ok: false, status: 404, error: "device_not_found" };
  }

  let dbTok = String(deviceRow.session_token ?? "").trim();

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
      }
    }
  }

  if (dbTok !== clientTok) {
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
      ...deviceRow,
      building_id: String(bid),
    },
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

  let payload: {
    action?: string;
    device_id?: string;
    session_token?: string;
    unit_id?: string;
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

  if (action !== "list_units" && action !== "create_invite") {
    return jsonResponse(400, { success: false, error: "unknown_action" });
  }

  const gate = await assertManagerSession(supabase, deviceId, sessionToken);
  if (!gate.ok) {
    return jsonResponse(gate.status, { success: false, error: gate.error });
  }

  const buildingId = gate.device.building_id;

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

    const rows = (units ?? []).map((u: Record<string, unknown>) => ({
      id: u.id as string,
      floor: u.floor as number | null,
      door_number: String(u.door_number ?? ""),
      block: typeof u.block === "string" ? u.block.trim() : "",
    }));

    return jsonResponse(200, {
      success: true,
      building_name: buildingName,
      units: rows,
    });
  }

  // create_invite
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

  for (let attempt = 0; attempt < 16; attempt++) {
    const code = randomUnitCode();
    const { data: row, error: insErr } = await supabase
      .from("invite_codes")
      .insert({
        code,
        code_type: "unit",
        status: "active",
        building_id: buildingId,
        unit_id: unitId,
        created_by: createdBy,
      })
      .select("expires_at")
      .single();

    if (!insErr && row) {
      return jsonResponse(200, {
        success: true,
        code,
        unit_id: unitId,
        expires_at: row.expires_at ?? null,
      });
    }

    const msg = insErr?.message ?? "";
    if (msg.includes("duplicate") || msg.includes("unique")) {
      continue;
    }

    console.error("invite_codes insert", insErr);
    return jsonResponse(500, { success: false, error: "database_error" });
  }

  return jsonResponse(500, { success: false, error: "code_generation_failed" });
});
