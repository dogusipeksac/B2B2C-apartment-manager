/**
 * Redeem invite code (admin or unit). Uses service role — bypasses RLS.
 *
 * POST body JSON:
 * { "code": string, "device_id": string, "full_name"?: string }
 *
 * Admin (8-char): full_name optional — creates device row, building wizard fills building later.
 * Unit (5-char): full_name required (≥3 chars) — creates profile + membership + device.
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

function normalizeCode(raw: string): string {
  return raw.trim().toUpperCase().replace(/[^A-Z0-9]/g, "");
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

  let payload: { code?: string; device_id?: string; full_name?: string };
  try {
    payload = await req.json();
  } catch {
    return jsonResponse(400, { success: false, error: "invalid_json" });
  }

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

  const { data: row, error: findErr } = await supabase
    .from("invite_codes")
    .select(
      "id, code_type, status, building_id, unit_id, expires_at",
    )
    .eq("code", code)
    .maybeSingle();

  if (findErr) {
    console.error("invite_codes select", findErr);
    return jsonResponse(500, { success: false, error: "database_error" });
  }

  if (!row) {
    return jsonResponse(404, {
      success: false,
      error: "code_not_found_or_expired",
      message:
        "Kod bulunamadı veya süresi dolmuş.",
    });
  }

  if (row.status !== "active") {
    return jsonResponse(404, {
      success: false,
      error: "code_not_found_or_expired",
      message:
        "Kod bulunamadı veya süresi dolmuş.",
    });
  }

  if (row.expires_at) {
    const exp = new Date(row.expires_at as string);
    if (exp.getTime() < Date.now()) {
      return jsonResponse(404, {
        success: false,
        error: "code_not_found_or_expired",
        message:
          "Kod bulunamadı veya süresi dolmuş.",
      });
    }
  }

  const codeType = row.code_type as string;

  if (codeType === "unit") {
    if (!fullName || fullName.length < 3) {
      return jsonResponse(422, {
        success: false,
        error: "full_name_required",
        message: "Ad soyad en az 3 karakter olmalı.",
      });
    }
  }

  const nowIso = new Date().toISOString();

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
    console.error("invite_codes update", updErr);
    return jsonResponse(500, { success: false, error: "database_error" });
  }

  if (!locked) {
    return jsonResponse(409, {
      success: false,
      error: "code_already_used",
      message: "Bu kod daha önce kullanılmış.",
    });
  }

  if (codeType === "admin") {
    const { error: devErr } = await supabase.from("devices").upsert(
      {
        device_id: deviceId,
        profile_id: null,
        building_id: null,
        unit_id: null,
        role: "building_admin",
        last_seen_at: nowIso,
      },
      { onConflict: "device_id" },
    );

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
    const buildingId = row.building_id as string | null;
    const unitId = row.unit_id as string | null;

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

    const { error: dErr } = await supabase.from("devices").upsert(
      {
        device_id: deviceId,
        profile_id: profileId,
        building_id: buildingId,
        unit_id: unitId,
        role: "resident",
        last_seen_at: nowIso,
      },
      { onConflict: "device_id" },
    );

    if (dErr) {
      console.error("devices upsert unit", dErr);
      await supabase.from("memberships").delete().eq("user_id", profileId);
      await supabase.from("profiles").delete().eq("id", profileId);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    return jsonResponse(200, {
      success: true,
      role: "resident",
      building_id: buildingId,
      unit_id: unitId,
      profile_id: profileId,
      session_token: sessionToken,
    });
  }

  return jsonResponse(400, { success: false, error: "unknown_code_type" });
});
