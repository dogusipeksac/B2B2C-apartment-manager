/**
 * Redeem invite code (admin or unit). Uses service role — bypasses RLS.
 *
 * POST body JSON:
 * { "code": string, "device_id": string, "full_name"?: string }
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

type DeviceUpsertRow = {
  device_id: string;
  profile_id: string | null;
  building_id: string | null;
  unit_id: string | null;
  role: string;
  session_token: string;
  last_seen_at: string;
};

async function upsertDeviceForgivingMissingSessionColumn(
  supabase: ReturnType<typeof createClient>,
  row: DeviceUpsertRow,
): Promise<{ error: { message?: string } | null }> {
  let res = await supabase.from("devices").upsert(row, {
    onConflict: "device_id",
  });
  if (!res.error) return res;
  if (!isMissingColumn(res.error, "session_token")) return res;
  const { session_token: _st, ...legacy } = row;
  void _st;
  return await supabase.from("devices").upsert(legacy, {
    onConflict: "device_id",
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

  const superAccess = Deno.env.get("SUPERADMIN_ACCESS_CODE")?.trim();
  if (superAccess && superAccess.length >= 4) {
    const secretNorm = normalizeCode(superAccess);
    if (secretNorm.length >= 4 && code === secretNorm) {
      const nowIso = new Date().toISOString();
      const { error: devErr } = await upsertDeviceForgivingMissingSessionColumn(
        supabase,
        {
          device_id: deviceId,
          profile_id: null,
          building_id: null,
          unit_id: null,
          role: "super_admin",
          session_token: sessionToken,
          last_seen_at: nowIso,
        },
      );

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
      "id, code_type, status, building_id, unit_id, expires_at, admin_redeem_policy",
    )
    .eq("code", code)
    .maybeSingle();

  if (primary.error && isMissingColumn(primary.error, "admin_redeem_policy")) {
    const legacy = await supabase
      .from("invite_codes")
      .select("id, code_type, status, building_id, unit_id, expires_at")
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
  const rawAdminPolicy = (row as Record<string, unknown>).admin_redeem_policy;
  const adminRedeemPolicy =
    typeof rawAdminPolicy === "string" && rawAdminPolicy.trim() === "reusable"
      ? "reusable"
      : "single_use";

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

  if (codeType === "admin") {
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

    const { error: devErr } = await upsertDeviceForgivingMissingSessionColumn(
      supabase,
      {
        device_id: deviceId,
        profile_id: null,
        building_id: null,
        unit_id: null,
        role: "building_admin",
        session_token: sessionToken,
        last_seen_at: nowIso,
      },
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
      console.error("invite_codes update unit", updErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    if (!locked) {
      return jsonResponse(409, {
        success: false,
        error: "code_already_used",
        message: "Bu kod daha önce kullanılmış.",
      });
    }

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

    const { error: dErr } = await upsertDeviceForgivingMissingSessionColumn(
      supabase,
      {
        device_id: deviceId,
        profile_id: profileId,
        building_id: buildingId,
        unit_id: unitId,
        role: "resident",
        session_token: sessionToken,
        last_seen_at: nowIso,
      },
    );

    if (dErr) {
      console.error("devices upsert unit", dErr);
      await supabase.from("memberships").delete().eq("user_id", profileId);
      await supabase.from("profiles").delete().eq("id", profileId);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    let buildingName = "";
    const { data: bMeta, error: bNameErr } = await supabase
      .from("buildings")
      .select("name")
      .eq("id", buildingId)
      .maybeSingle();

    if (bNameErr) {
      console.error("buildings name for redeem", bNameErr);
    } else if (typeof bMeta?.name === "string") {
      buildingName = (bMeta.name as string).trim();
    }

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
