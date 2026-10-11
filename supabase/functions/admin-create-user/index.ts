// Edge Function: إنشاء حساب موظف (Manager/Marketer/Driver/Packager) يدوياً
// بواسطة super_admin فقط. يستدعي Admin API (GoTrue) مباشرة بمفتاح الخدمة:
// هذا المشروع يعيد جسم المستخدم مسطّحاً (وليس داخل {user: ...}) فلا تعتمد
// على admin.auth.createUser من supabase-js.
// النشر: supabase functions deploy admin-create-user --project-ref <ref>

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const USERNAME_RE = /^[a-z0-9][a-z0-9._-]{2,29}$/;
const ALLOWED_ROLES = ['manager', 'marketer', 'driver', 'packager'];

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

    // فقط super_admin يمكنه إنشاء الحسابات
    const { data: roleRow } = await admin
      .from('staff_roles')
      .select('role, is_active')
      .eq('user_id', user.id)
      .maybeSingle();
    if (!roleRow?.is_active || roleRow.role !== 'super_admin') {
      return json({ error: 'forbidden' }, 403);
    }

    const payload = (await req.json()) as {
      username?: string;
      email?: string;
      password?: string;
      role?: string;
      full_name?: string;
      phone?: string;
    };

    const rawUsername = (payload.username ?? '').trim();
    const password = payload.password ?? '';
    const role = payload.role ?? 'manager';

    let username = rawUsername.toLowerCase();
    let email = (payload.email ?? '').trim().toLowerCase();

    // إن لم يُرسل بريد، يُشتق من اسم المستخدم (يبقى البريد داخلياً لـ GoTrue)
    if (!email && rawUsername) {
      email = EMAIL_RE.test(rawUsername) ? rawUsername.toLowerCase() : `${rawUsername.toLowerCase()}@atoga.com`;
    }
    if (username.includes('@')) {
      username = username.split('@')[0];
    }
    if (!username && email) {
      username = email.split('@')[0];
    }

    if (!USERNAME_RE.test(username)) {
      return json({ error: 'اسم المستخدم: 3-30 حرفاً (حروف/أرقام/نقطة/شرطة) فقط.' }, 400);
    }
    if (!EMAIL_RE.test(email)) {
      return json({ error: 'يرجى إدخال بريد إلكتروني صحيح.' }, 400);
    }
    if (!password || password.length < 6) {
      return json({ error: 'كلمة المرور 6 أحرف على الأقل.' }, 400);
    }
    if (!ALLOWED_ROLES.includes(role)) {
      return json({ error: 'invalid_role' }, 400);
    }

    const fullName = (payload.full_name ?? '').trim() || email;
    const localPhone = (payload.phone ?? '').trim() || undefined;

    // منع تكرار اسم المستخدم أو بريده (رسالة موحّدة ودودة)
    const { data: dupUsername } = await admin
      .from('profiles')
      .select('id')
      .ilike('username', username)
      .maybeSingle();
    if (dupUsername) {
      return json({ error: 'اسم المستخدم مستخدم بالفعل.' }, 400);
    }
    const { data: dupEmail } = await admin
      .from('auth.users')
      .select('id')
      .eq('email', email)
      .maybeSingle();
    if (dupEmail) {
      return json({ error: 'اسم المستخدم مستخدم بالفعل.' }, 400);
    }

    // استدعاء GoTrue Admin مباشرة: نتحكم بالاستجابة المسطّحة وبالرسائل
    const createResp = await fetch(new URL('/auth/v1/admin/users', supabaseUrl), {
      method: 'POST',
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email,
        password,
        email_confirm: true,
        user_metadata: {
          display_name: fullName,
          username,
          phone_local: localPhone,
          phone: localPhone,
        },
      }),
    });

    const rawText = await createResp.text();
    let body: Record<string, unknown> = {};
    try {
      body = JSON.parse(rawText);
    } catch (_) {
      // نص غير JSON: نمرره كرسالة خطأ عند الحاجة
    }

    if (!createResp.ok) {
      const message = (body?.msg ?? body?.error ?? body?.message ?? rawText ?? 'create_failed') as string;
      return json({ error: message }, createResp.status || 400);
    }

    const newId = body?.id as string | undefined;
    if (!newId) {
      return json({ error: 'create_failed' }, 400);
    }

    await admin.from('profiles').upsert({
      id: newId,
      display_name: fullName,
      username,
      phone: localPhone,
    });
    await admin.from('staff_roles').upsert({
      user_id: newId,
      role,
      is_active: true,
      created_by: user.id,
    });

    return json({ ok: true, user_id: newId, username, email, role, full_name: fullName });
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
