/**
 * Valid device session → building display name (service role).
 *
 * POST JSON: { "device_id": string, "session_token": string }
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

  let payload: { device_id?: string; session_token?: string };
  try {
    payload = await req.json();
  } catch {
    return jsonResponse(400, { success: false, error: "invalid_json" });
  }

  const deviceId = payload.device_id?.trim();
  const sessionToken = payload.session_token?.trim();

  if (!deviceId || !sessionToken) {
    return jsonResponse(400, {
      success: false,
      error: "device_or_token_required",
    });
  }

  const clientTok = sessionToken;

  const { data: deviceRow, error: devFetchErr } = await supabase
    .from("devices")
    .select("building_id, session_token, role")
    .eq("device_id", deviceId)
    .maybeSingle();

  if (devFetchErr) {
    console.error("devices select", devFetchErr);
    return jsonResponse(500, { success: false, error: "database_error" });
  }

  if (!deviceRow) {
    return jsonResponse(404, { success: false, error: "device_not_found" });
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
    return jsonResponse(401, { success: false, error: "invalid_session" });
  }

  const bid = deviceRow.building_id;
  if (!bid || String(bid).length === 0) {
    return jsonResponse(200, {
      success: true,
      building_name: null,
    });
  }

  const buildingId = String(bid);

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

  return jsonResponse(200, {
    success: true,
    building_name: buildingName.length > 0 ? buildingName : null,
  });
});
