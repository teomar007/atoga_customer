// Edge Function: توليد بيانات مصادقة رفع الصور إلى ImageKit (Client-side upload).
//
// الأسرار المطلوبة في Supabase ← Edge Functions ← Secrets:
//   IMAGEKIT_PRIVATE_KEY   : المفتاح الخاص (سرّي — لا يُرسل للعميل)
// (IMAGEKIT_PUBLIC_KEY / IMAGEKIT_URL_ENDPOINT لهما قيم افتراضية عامة أدناه)
//
// التصريح: موظف إداري نشط فقط (super_admin / manager / marketer).

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const DEFAULT_PUBLIC_KEY = 'public_fuLuGqWN++rXzhU7+ZLaaBskdjs=';
const DEFAULT_URL_ENDPOINT = 'https://ik.imagekit.io/atougamarket/';
const TRANSFORMATION = 'w-800,f-webp,q-80';
const UPLOAD_TTL_SECONDS = 1800;
const STAFF_ROLES = ['super_admin', 'manager', 'marketer'];

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  try {
    const authHeader = req.headers.get('Authorization') ?? '';
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';

    const jwtClient = createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authHeader } } });
    const { data: { user }, error } = await jwtClient.auth.getUser();
    if (error || !user) {
      return json({ error: 'not_authenticated' }, 401);
    }

    // التصريح: طاقم إداري نشط فقط.
    const admin = createClient(supabaseUrl, serviceKey);
    const { data: roleRow } = await admin.from('staff_roles').select('role, is_active').eq('user_id', user.id).maybeSingle();
    const staffRole = String(roleRow?.role ?? '');
    if (!(roleRow?.is_active === true && STAFF_ROLES.includes(staffRole))) {
      return json({ error: 'forbidden' }, 403);
    }

    const privateKey = Deno.env.get('IMAGEKIT_PRIVATE_KEY') ?? '';
    if (!privateKey) {
      return json({ error: 'imagekit_not_configured' }, 500);
    }
    const publicKey = Deno.env.get('IMAGEKIT_PUBLIC_KEY') ?? DEFAULT_PUBLIC_KEY;
    const urlEndpoint = Deno.env.get('IMAGEKIT_URL_ENDPOINT') ?? DEFAULT_URL_ENDPOINT;

    const token = crypto.randomUUID();
    const expire = Math.floor(Date.now() / 1000) + UPLOAD_TTL_SECONDS;
    const signature = await hmacSha1Hex(privateKey, token + expire);

    return json({
      token,
      expire,
      signature,
      publicKey,
      urlEndpoint,
      transformation: TRANSFORMATION,
    });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});

async function hmacSha1Hex(key: string, message: string): Promise<string> {
  const enc = new TextEncoder();
  const cryptoKey = await crypto.subtle.importKey('raw', enc.encode(key), { name: 'HMAC', hash: 'SHA-1' }, false, ['sign']);
  const sig = await crypto.subtle.sign('HMAC', cryptoKey, enc.encode(message));
  return [...new Uint8Array(sig)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
}
