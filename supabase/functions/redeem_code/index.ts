/**
 * Redeem invite code (admin or unit). Uses service role — bypasses RLS.
 *
 * POST body JSON:
 * { "code": string, "device_id": string, "full_name"?: string, "probe"?: boolean }
 *
 * probe=true (admin codes only): read-only — returns would_resume + building_name for UI,
 * no invite consume and no device upsert.
 * Reinstall: new device_id but same invite row — singleton completed admin row is rebound.
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

/** Exactly one completed admin device row for this invite — reinstall / device_id change. */
async function findSingletonCompletedAdminForInvite(
  supabase: ReturnType<typeof createClient>,
  inviteRowId: string,
): Promise<{ row: Record<string, unknown>; pk: string } | null> {
  const sel = await supabase
    .from("devices")
    .select(
      "id, device_id, building_id, profile_id, unit_id, role, admin_invite_code_id",
    )
    .eq("admin_invite_code_id", inviteRowId)
    .eq("role", "building_admin")
    .not("building_id", "is", null);

  if (sel.error && isMissingColumn(sel.error, "admin_invite_code_id")) {
    return null;
  }
  if (sel.error) {
    console.error("devices singleton admin lookup", sel.error);
    return null;
  }
  const rows = sel.data as Record<string, unknown>[] | null;
  if (!rows || rows.length !== 1) {
    return null;
  }
  const r = rows[0]!;
  const pk = String(r.id ?? "");
  if (!pk) {
    return null;
  }
  return { row: r, pk };
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

  if (probeOnly && codeType !== "admin") {
    return jsonResponse(400, {
      success: false,
      error: "probe_admin_only",
    });
  }

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
    const inviteRowId = String(row.id);

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
      const probeSingleton = await findSingletonCompletedAdminForInvite(
        supabase,
        inviteRowId,
      );
      if (probeSingleton) {
        const bid = probeSingleton.row.building_id;
        if (typeof bid === "string" && bid.length > 0) {
          let buildingName = "";
          const { data: bMetaSg } = await supabase
            .from("buildings")
            .select("name")
            .eq("id", bid)
            .maybeSingle();
          if (typeof bMetaSg?.name === "string") {
            buildingName = (bMetaSg.name as string).trim();
          }
          return jsonResponse(200, {
            success: true,
            probe: true,
            would_resume: true,
            building_id: bid,
            building_name: buildingName.length > 0 ? buildingName : null,
          });
        }
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

      let buildingName = "";
      const { data: bMeta } = await supabase
        .from("buildings")
        .select("name")
        .eq("id", exBid)
        .maybeSingle();
      if (typeof bMeta?.name === "string") {
        buildingName = (bMeta.name as string).trim();
      }

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

    const reinstallSingleton = await findSingletonCompletedAdminForInvite(
      supabase,
      inviteRowId,
    );
    const reinstallBid =
      reinstallSingleton &&
      typeof reinstallSingleton.row.building_id === "string" &&
      String(reinstallSingleton.row.building_id).length > 0
        ? String(reinstallSingleton.row.building_id)
        : null;

    if (reinstallSingleton && reinstallBid) {
      const prevDid = String(reinstallSingleton.row.device_id ?? "").trim();
      if (prevDid !== deviceId) {
        const clash = await supabase
          .from("devices")
          .select("id")
          .eq("device_id", deviceId)
          .maybeSingle();

        const clashId = clash.data
          ? String((clash.data as Record<string, unknown>).id ?? "")
          : "";
        if (clashId.length > 0 && clashId !== reinstallSingleton.pk) {
          return jsonResponse(409, {
            success: false,
            error: "device_id_conflict",
          });
        }

        let rebErr = (
          await supabase
            .from("devices")
            .update({
              device_id: deviceId,
              session_token: sessionToken,
              last_seen_at: nowIso,
            })
            .eq("id", reinstallSingleton.pk)
        ).error;

        if (rebErr && isMissingColumn(rebErr, "session_token")) {
          rebErr = (
            await supabase
              .from("devices")
              .update({
                device_id: deviceId,
                last_seen_at: nowIso,
              })
              .eq("id", reinstallSingleton.pk)
          ).error;
        }

        if (rebErr) {
          console.error("devices rebind reinstall admin", rebErr);
          return jsonResponse(500, { success: false, error: "database_error" });
        }

        let rbName = "";
        const { data: bMetaRb } = await supabase
          .from("buildings")
          .select("name")
          .eq("id", reinstallBid)
          .maybeSingle();
        if (typeof bMetaRb?.name === "string") {
          rbName = (bMetaRb.name as string).trim();
        }

        return jsonResponse(200, {
          success: true,
          role: "building_admin",
          building_id: reinstallBid,
          unit_id: reinstallSingleton.row.unit_id ?? null,
          profile_id: reinstallSingleton.row.profile_id ?? null,
          session_token: sessionToken,
          building_name: rbName.length > 0 ? rbName : null,
          resumed: true,
          rebound: true,
        });
      }
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

    const { error: dErr } = await upsertDeviceWithLegacyColumns(supabase, {
      device_id: deviceId,
      profile_id: profileId,
      building_id: buildingId,
      unit_id: unitId,
      role: "resident",
      session_token: sessionToken,
      last_seen_at: nowIso,
    });

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
