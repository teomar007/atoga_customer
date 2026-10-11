// Edge Function: إدارة الحسابات (تغيير كلمة المرور) بواسطة super_admin فقط.
// يستدعي GoTrue Admin مباشرة بمفتاح الخدمة.
// النشر: supabase functions deploy admin-manage-user --project-ref <ref>

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  try {
    const authHeader = req.headers.get('Authorization') ?? '';
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

    const jwtClient = createClient(
      supabaseUrl,
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } },
    );
    const { data: { user }, error: userError } = await jwtClient.auth.getUser();
    if (userError || !user) {
      return json({ error: 'not_authenticated' }, 401);
    }

    const admin = createClient(supabaseUrl, serviceKey);
    const { data: roleRow } = await admin
      .from('staff_roles')
      .select('role, is_active')
      .eq('user_id', user.id)
      .maybeSingle();
    if (!roleRow?.is_active || roleRow.role !== 'super_admin') {
      return json({ error: 'forbidden' }, 403);
    }

    const payload = (await req.json()) as {
      action?: string;
      user_id?: string;
      new_password?: string;
    };
    if (payload.action !== 'password' || !payload.user_id || !payload.new_password) {
      return json({ error: 'invalid_payload' }, 400);
    }
    if (payload.new_password.length < 6) {
      return json({ error: 'كلمة المرور 6 أحرف على الأقل.' }, 400);
    }

    const resp = await fetch(
      new URL(`/auth/v1/admin/users/${payload.user_id}`, supabaseUrl),
      {
        method: 'PUT',
        headers: {
          apikey: serviceKey,
          Authorization: `Bearer ${serviceKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ password: payload.new_password }),
      },
    );

    const rawText = await resp.text();
    let body: Record<string, unknown> = {};
    try {
      body = JSON.parse(rawText);
    } catch (_) {
      // نص غير JSON
    }
    if (!resp.ok) {
      const message = (body?.msg ?? body?.error ?? body?.message ?? rawText ?? 'update_failed') as string;
      return json({ error: message }, resp.status || 400);
    }

    return json({ ok: true, action: 'password' });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
