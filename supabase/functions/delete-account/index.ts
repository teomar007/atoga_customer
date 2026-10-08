// Edge Function: حذف الحساب نهائياً (شرط Google Play)
//
// تحذف صف المستخدم من auth.users بالكامل. لا يمكن ذلك من العميل لأن مفتاح
// anon لا يملك صلاحية الحذف — لذلك نستخدم مفتاح service role هنا.
//   supabase functions deploy delete-account --no-verify-jwt
// التطبيق يستدعيه باسم: supabase.functions.invoke('delete-account')

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
    // هوية المستخدم من ترويسة Authorization (العميل يرسل توكن الجلسة).
    const authHeader = req.headers.get('Authorization') ?? '';
    const userClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData.user) {
      return json({ error: 'not_authenticated' }, 401);
    }
    const userId = userData.user.id;

    const admin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    );

    // 1) مسح بيانات التطبيق (جداول_policy تحميها، لذلك service role يتجاوزها).
    await admin.from('order_items').delete().in('order_id', idsOf(await admin.from('orders').select('id').eq('user_id', userId)));
    await admin.from('orders').delete().eq('user_id', userId);
    await admin.from('addresses').delete().eq('user_id', userId);
    await admin.from('profiles').delete().eq('id', userId);

    // 2) حذف صف المصادقة نفسه.
    const { error: deleteError } = await admin.auth.admin.deleteUser(userId);
    if (deleteError) {
      return json({ error: deleteError.message }, 500);
    }

    return json({ ok: true });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});

function idsOf(result: { data: Array<{ id: string }> | null }): string[] {
  return (result.data ?? []).map((row) => row.id);
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
