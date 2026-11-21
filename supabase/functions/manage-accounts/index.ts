import { createClient } from "https://esm.sh/@supabase/supabase-js@2.112.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, x-client-info, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const roles = ["beneficiary", "personnel", "admin", "super_admin"];
const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function respond(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return respond(405, { error: "Use POST to manage accounts." });
  }

  try {
    const authorization = request.headers.get("Authorization");
    const token = authorization?.match(/^Bearer\s+(.+)$/i)?.[1];
    if (!authorization || !token) {
      return respond(401, { error: "Sign in before managing accounts." });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !anonKey || !serviceRoleKey) {
      console.error("Account management requires the Supabase URL, anon key, and service-role key.");
      return respond(500, { error: "Account management is not configured on the server." });
    }

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authorization } },
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: { user }, error: authError } = await userClient.auth.getUser(token);
    if (authError || !user) {
      return respond(401, { error: "Your session is invalid or has expired." });
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: caller, error: callerError } = await adminClient
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();
    if (callerError) {
      console.error("Unable to verify the account-management role:", callerError.message);
      return respond(500, { error: "Unable to verify account-management permissions." });
    }

    const callerRole = String(caller.role || "").toLowerCase();
    if (!["admin", "super_admin"].includes(callerRole)) {
      return respond(403, { error: "Only administrators can manage accounts." });
    }

    const body = await request.json();
    if (body?.action === "create") {
      const email = String(body.email || "").trim().toLowerCase();
      const password = String(body.password || "");
      const role = String(body.role || "").toLowerCase();
      const firstName = String(body.firstName || "").trim();
      const middleName = String(body.middleName || "").trim();
      const lastName = String(body.lastName || "").trim();
      const contactNumber = String(body.contactNumber || "").trim();
      const barangay = String(body.barangay || "").trim();

      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
          || password.length < 8 || password.length > 72
          || !firstName || !lastName || !roles.includes(role)) {
        return respond(400, { error: "Enter valid account details and a password between 8 and 72 characters." });
      }
      if (callerRole === "admin" && !["personnel", "beneficiary"].includes(role)) {
        return respond(403, { error: "Admins can create personnel or beneficiary accounts only." });
      }

      const { data, error: createError } = await adminClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: role === "beneficiary" ? {
          fname: firstName,
          mname: middleName,
          lname: lastName,
          contactnumber: contactNumber,
          barangay,
        } : {},
      });
      if (createError || !data.user) {
        return respond(400, { error: createError?.message || "The account could not be created." });
      }

      const { data: profile, error: roleError } = await adminClient
        .from("profiles")
        .update({
          fname: firstName,
          mname: middleName,
          lname: lastName,
          contactnumber: contactNumber,
          barangay,
          role,
        })
        .eq("id", data.user.id)
        .select("id")
        .maybeSingle();
      if (roleError || !profile) {
        const { error: cleanupError } = await adminClient.auth.admin.deleteUser(data.user.id);
        const cleanupMessage = cleanupError ? ` Account cleanup failed: ${cleanupError.message}` : "";
        console.error("Unable to assign the new account role:", roleError?.message || "Profile was not created.", cleanupMessage);
        return respond(500, { error: `The account role could not be assigned.${cleanupMessage}` });
      }

      return respond(201, { userId: data.user.id });
    }

    if (body?.action === "update_role") {
      const userId = String(body.userId || "");
      const role = String(body.role || "").toLowerCase();
      if (!uuidPattern.test(userId) || !roles.includes(role)) {
        return respond(400, { error: "Choose a valid account and role." });
      }
      if (userId === user.id) {
        return respond(400, { error: "You cannot change your own account role." });
      }
      if (callerRole === "admin" && !["personnel", "beneficiary"].includes(role)) {
        return respond(403, { error: "Admins can assign personnel or beneficiary roles only." });
      }

      const { data: target, error: targetError } = await adminClient
        .from("profiles")
        .select("id, role")
        .eq("id", userId)
        .maybeSingle();
      if (targetError) {
        console.error("Unable to verify the target account:", targetError.message);
        return respond(500, { error: "Unable to verify the selected account." });
      }
      if (!target || (callerRole === "admin" && target.role !== "personnel")) {
        return respond(404, { error: "This account is not available for your role to manage." });
      }

      if (callerRole === "super_admin" && target.role === "super_admin" && role !== "super_admin") {
        const { count, error: countError } = await adminClient
          .from("profiles")
          .select("id", { count: "exact", head: true })
          .eq("role", "super_admin");
        if (countError) {
          console.error("Unable to verify the remaining super-admin accounts:", countError.message);
          return respond(500, { error: "Unable to verify super-admin account availability." });
        }
        if ((count || 0) <= 1) {
          return respond(400, { error: "At least one super-admin account must remain active." });
        }
      }

      const { error: updateError } = await adminClient
        .from("profiles")
        .update({ role })
        .eq("id", userId);
      if (updateError) {
        console.error("Unable to update the account role:", updateError.message);
        return respond(500, { error: "The account role could not be updated." });
      }

      return respond(200, { userId, role });
    }

    return respond(400, { error: "Choose a supported account-management action." });
  } catch (error) {
    console.error("Account-management request failed:", error);
    return respond(400, { error: error instanceof Error ? error.message : "The account-management request is invalid." });
  }
});
