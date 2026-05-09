/**
 * Super-admin: cross-building manager invites and unit invites.
 *
 * POST JSON:
 * { "action": string, "device_id": string, "session_token": string,
 *   "building_id"?: uuid, "unit_id"?: uuid }
 *
 * Actions: list_buildings | list_admin_codes | create_admin_invite |
 *          revoke_admin_code | list_units | create_unit_invite | delete_building
 */
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

import { isMissingColumn } from "../_shared/db_compat.ts";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

function normalizeInviteCode(raw: string): string {
  return raw.trim().toUpperCase().replace(/[^A-Z0-9]/g, "");
}

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

function randomAdminCode(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(8));
  let s = "";
  for (let i = 0; i < 8; i++) {
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

async function assertSuperAdminSession(
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

  if (deviceRow.role !== "super_admin") {
    return { ok: false, status: 403, error: "not_super_admin" };
  }

  if (legacyNoSessionColumn) {
    // schema_v3_devices_session.sql not applied — cannot verify stored token.
    if (!clientTok) {
      return { ok: false, status: 401, error: "invalid_session" };
    }
  } else {
    const dbTok = String(deviceRow.session_token ?? "").trim();
    if (dbTok !== clientTok) {
      return { ok: false, status: 401, error: "invalid_session" };
    }
  }

  return {
    ok: true,
    device: deviceRow as DeviceRow,
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
    building_id?: string;
    unit_id?: string;
    admin_redeem_policy?: string;
    code?: string;
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

  const gate = await assertSuperAdminSession(supabase, deviceId, sessionToken);
  if (!gate.ok) {
    return jsonResponse(gate.status, { success: false, error: gate.error });
  }

  const createdBy = gate.device.profile_id;

  if (action === "list_buildings") {
    const { data: rows, error } = await supabase
      .from("buildings")
      .select("id, name, address, city, district, created_at")
      .order("created_at", { ascending: false })
      .limit(500);

    if (error) {
      console.error("buildings list", error);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const buildings = (rows ?? []).map((r: Record<string, unknown>) => ({
      id: r.id as string,
      name: typeof r.name === "string" ? r.name.trim() : "",
      address: typeof r.address === "string" ? r.address.trim() : "",
      city: typeof r.city === "string" ? r.city.trim() : "",
      district: typeof r.district === "string" ? r.district.trim() : "",
      created_at: r.created_at ?? null,
    }));

    return jsonResponse(200, { success: true, buildings });
  }

  if (action === "list_admin_codes") {
    let rows: Record<string, unknown>[] | null = null;
    let listErr: { message?: string } | null = null;

    const listFull = await supabase
      .from("invite_codes")
      .select(
        "id, code, status, expires_at, created_at, admin_redeem_policy",
      )
      .eq("code_type", "admin")
      .order("created_at", { ascending: false })
      .limit(100);

    if (listFull.error && isMissingColumn(listFull.error, "admin_redeem_policy")) {
      const leg = await supabase
        .from("invite_codes")
        .select("id, code, status, expires_at, created_at")
        .eq("code_type", "admin")
        .order("created_at", { ascending: false })
        .limit(100);
      rows = (leg.data ?? []) as Record<string, unknown>[];
      listErr = leg.error;
    } else if (listFull.error) {
      listErr = listFull.error;
    } else {
      rows = (listFull.data ?? []) as Record<string, unknown>[];
    }

    if (listErr) {
      console.error("invite_codes admin list", listErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const codes = (rows ?? []).map((r: Record<string, unknown>) => ({
      id: String(r.id ?? ""),
      code: String(r.code ?? ""),
      status: String(r.status ?? ""),
      expires_at: r.expires_at ?? null,
      created_at: r.created_at ?? null,
      admin_redeem_policy: typeof r.admin_redeem_policy === "string"
        ? r.admin_redeem_policy.trim()
        : "single_use",
    }));

    return jsonResponse(200, { success: true, codes });
  }

  if (action === "revoke_admin_code") {
    const codeRaw = payload.code?.trim();
    if (!codeRaw) {
      return jsonResponse(400, { success: false, error: "code_required" });
    }
    const normalized = normalizeInviteCode(codeRaw);
    if (normalized.length < 4) {
      return jsonResponse(400, {
        success: false,
        error: "code_invalid_length",
      });
    }

    const { data: revokedRows, error: revErr } = await supabase
      .from("invite_codes")
      .update({ status: "revoked" })
      .eq("code", normalized)
      .eq("code_type", "admin")
      .neq("status", "revoked")
      .select("id");

    if (revErr) {
      console.error("invite_codes revoke admin", revErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    if (!revokedRows || revokedRows.length === 0) {
      return jsonResponse(404, {
        success: false,
        error: "code_not_found_or_revoked",
      });
    }

    return jsonResponse(200, { success: true });
  }

  if (action === "create_admin_invite") {
    const policyRaw = payload.admin_redeem_policy?.trim().toLowerCase();
    const adminRedeemPolicy = policyRaw === "reusable"
      ? "reusable"
      : "single_use";

    for (let attempt = 0; attempt < 24; attempt++) {
      const code = randomAdminCode();
      const rowInsert = {
        code,
        code_type: "admin" as const,
        status: "active" as const,
        building_id: null,
        unit_id: null,
        created_by: createdBy,
        admin_redeem_policy: adminRedeemPolicy,
      };

      let ins = await supabase
        .from("invite_codes")
        .insert(rowInsert)
        .select("expires_at")
        .single();

      if (
        ins.error &&
        isMissingColumn(ins.error, "admin_redeem_policy")
      ) {
        const { admin_redeem_policy: _arp, ...legacyInsert } = rowInsert;
        void _arp;
        ins = await supabase
          .from("invite_codes")
          .insert(legacyInsert)
          .select("expires_at")
          .single();
      }

      const insErr = ins.error;
      const row = ins.data;

      if (!insErr && row) {
        return jsonResponse(200, {
          success: true,
          code,
          expires_at: row.expires_at ?? null,
          admin_redeem_policy: adminRedeemPolicy,
        });
      }

      const msg = insErr?.message ?? "";
      if (msg.includes("duplicate") || msg.includes("unique")) {
        continue;
      }

      console.error("invite_codes insert admin", insErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    return jsonResponse(500, {
      success: false,
      error: "code_generation_failed",
    });
  }

  const buildingIdRaw = payload.building_id?.trim();
  if (
    action === "list_units" ||
    action === "create_unit_invite"
  ) {
    if (!buildingIdRaw || buildingIdRaw.length === 0) {
      return jsonResponse(400, {
        success: false,
        error: "building_id_required",
      });
    }
  }

  if (action === "list_units") {
    const buildingId = buildingIdRaw!;

    const { data: bMeta, error: bErr } = await supabase
      .from("buildings")
      .select("name")
      .eq("id", buildingId)
      .maybeSingle();

    if (bErr) {
      console.error("buildings select name", bErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    if (!bMeta) {
      return jsonResponse(404, { success: false, error: "building_not_found" });
    }

    const buildingName = typeof bMeta.name === "string"
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
      created_at: number;
    };
    const inviteByUnit = new Map<string, InvitePick>();

    const ids = unitRows.map((r) => r.id);
    if (ids.length > 0) {
      const { data: invs, error: invErr } = await supabase
        .from("invite_codes")
        .select("unit_id, code, expires_at, created_at")
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
          inviteByUnit.set(uid, {
            code: row.code as string,
            expires_at: row.expires_at ? String(row.expires_at) : null,
            created_at: ca,
          });
        }
      }
    }

    const rows = unitRows.map((u) => {
      const inv = inviteByUnit.get(u.id);
      return {
        ...u,
        invite_code: inv?.code ?? null,
        invite_expires_at: inv?.expires_at ?? null,
      };
    });

    return jsonResponse(200, {
      success: true,
      building_name: buildingName,
      units: rows,
    });
  }

  if (action === "create_unit_invite") {
    const buildingId = buildingIdRaw!;
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

    const { data: existingRows, error: exErr } = await supabase
      .from("invite_codes")
      .select("code, expires_at, created_at")
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
      return jsonResponse(200, {
        success: true,
        code: codeReuse,
        unit_id: unitId,
        expires_at: row.expires_at ?? null,
        reused: true,
      });
    }

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
          reused: false,
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
  }

  if (action === "delete_building") {
    const buildingId = payload.building_id?.trim();
    if (!buildingId) {
      return jsonResponse(400, {
        success: false,
        error: "building_id_required",
      });
    }

    const { data: bRow, error: bErr } = await supabase
      .from("buildings")
      .select("id")
      .eq("id", buildingId)
      .maybeSingle();

    if (bErr) {
      console.error("buildings select delete", bErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    if (!bRow) {
      return jsonResponse(404, { success: false, error: "building_not_found" });
    }

    const { error: devBuildingErr } = await supabase
      .from("devices")
      .update({ building_id: null, unit_id: null })
      .eq("building_id", buildingId);

    if (devBuildingErr) {
      console.error("devices clear building_id", devBuildingErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const { data: unitRows, error: unitsErr } = await supabase
      .from("units")
      .select("id")
      .eq("building_id", buildingId);

    if (unitsErr) {
      console.error("units select for delete prep", unitsErr);
      return jsonResponse(500, { success: false, error: "database_error" });
    }

    const unitIds = (unitRows ?? [])
      .map((r: Record<string, unknown>) => r.id as string)
      .filter((id: string) => id.length > 0);

    if (unitIds.length > 0) {
      const { error: devUnitErr } = await supabase
        .from("devices")
        .update({ unit_id: null })
        .in("unit_id", unitIds);

      if (devUnitErr) {
        console.error("devices clear unit_id", devUnitErr);
        return jsonResponse(500, { success: false, error: "database_error" });
      }

      // votes.unit_id references units without ON DELETE SET NULL in older DBs —
      // blocks CASCADE when deleting building → units.
      const { error: votesErr } = await supabase
        .from("votes")
        .delete()
        .in("unit_id", unitIds);

      if (votesErr) {
        console.error("votes delete by unit_id", votesErr);
        return jsonResponse(500, { success: false, error: "database_error" });
      }
    }

    const { error: auditErr } = await supabase
      .from("audit_logs")
      .update({ building_id: null })
      .eq("building_id", buildingId);

    if (auditErr) {
      console.warn("audit_logs clear building_id (optional)", auditErr);
    }

    const { error: delErr } = await supabase
      .from("buildings")
      .delete()
      .eq("id", buildingId);

    if (delErr) {
      console.error("buildings delete", delErr);
      return jsonResponse(500, {
        success: false,
        error: "delete_failed",
        message:
          typeof delErr.message === "string" ? delErr.message : undefined,
      });
    }

    return jsonResponse(200, { success: true });
  }

  return jsonResponse(400, { success: false, error: "unknown_action" });
});
