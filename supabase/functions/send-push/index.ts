// Edge Function: إرسال إشعارات FCM (مجاناً) — للمستخدم، للموضوع العام،
// أو تلقائياً عند تغيّر حالة الطلب.
//
// الأسرار المطلوبة في Supabase ← Edge Functions ← Secrets:
//   FIREBASE_SERVICE_ACCOUNT : محتوى ملف Service Account من Firebase (JSON)
// (SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY / SUPABASE_ANON_KEY تُحقن تلقائياً)
//
// التصريح:
//   - ترويسة x-internal-secret مطابقة للسرّ في Vault (الطلبات الداخلية).
//   - أو JWT بدور service_role (الخادم).
//   - أو مستخدم مسجّل بعلم profiles.is_admin = true.
//
// النشر: supabase functions deploy send-push

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { importPKCS8, SignJWT } from 'npm:jose@5';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

type PushMode = 'user' | 'topic' | 'order_status';

interface PushBody {
  mode: PushMode;
  user_id?: string;
  topic?: string;
  order_id?: string;
  title?: string;
  body?: string;
  data?: Record<string, string>;
}

const STATUS_TEXT: Record<string, { ar: [string, string]; fr: [string, string] }> = {
  received: { ar: ['تم استلام طلبك', 'جارٍ تأكيد طلبك وتجهيزه.'], fr: ['Commande reçue', 'Votre commande est en cours de confirmation.'] },
  preparing: { ar: ['طلبك قيد التجهيز', 'نحضّر طلبك الآن.'], fr: ['Commande en préparation', 'Nous préparons votre commande.'] },
  on_the_way: { ar: ['طلبك في الطريق', 'المندوب في طريقه إليك.'], fr: ['Commande en route', 'Le livreur est en chemin.'] },
  delivered: { ar: ['تم تسليم طلبك', 'نشكرك على ثقتك بنا.'], fr: ['Commande livrée', 'Merci de votre confiance.'] },
  cancelled: { ar: ['تم إلغاء طلبك', 'يمكنك التواصل مع الدعم لأي استفسار.'], fr: ['Commande annulée', 'Contactez l’assistance si besoin.'] },
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return json({ ok: true });
  }
  try {
    const authHeader = req.headers.get('Authorization') ?? '';
    const internalHeader = req.headers.get('x-internal-secret') ?? '';
    const role = jwtRole(authHeader);
    const admin = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');

    // التصريح: السرّ الداخلي، أو service_role، أو مستخدم بعلم is_admin.
    let authorized = role === 'service_role';
    if (!authorized && internalHeader) {
      const { data: secret } = await admin.rpc('push_internal_secret');
      authorized = typeof secret === 'string' && secret.length > 0 && secret === internalHeader;
    }
    if (!authorized) {
      const sub = jwtSub(authHeader);
      if (!sub) {
        return json({ error: 'not_authenticated' }, 401);
      }
      const { data } = await admin.from('profiles').select('is_admin').eq('id', sub).maybeSingle();
      if (!(data?.is_admin === true)) {
        return json({ error: 'forbidden' }, 403);
      }
    }

    const payload = (await req.json()) as PushBody;
    const project = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');

    if (payload.mode === 'order_status') {
      return await sendOrderStatus(project, payload.order_id);
    }
    const title = (payload.title ?? '').trim();
    const body = (payload.body ?? '').trim();
    if (!title || !body) {
      return json({ error: 'missing_title_or_body' }, 400);
    }
    if (payload.mode === 'topic') {
      const topic = (payload.topic ?? 'all').trim();
      await sendFcm({ topic, title, body, data: payload.data });
      return json({ ok: true, mode: 'topic', topic });
    }
    if (!payload.user_id) {
      return json({ error: 'missing_user_id' }, 400);
    }
    const { data: profile } = await project.from('profiles').select('fcm_token').eq('id', payload.user_id).maybeSingle();
    const token = (profile?.fcm_token as string | undefined) ?? '';
    if (!token) {
      return json({ error: 'no_device_token' }, 404);
    }
    await sendFcm({ token, title, body, data: payload.data });
    return json({ ok: true, mode: 'user' });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});

async function sendOrderStatus(project: ReturnType<typeof createClient>, orderId?: string) {
  if (!orderId) {
    return json({ error: 'missing_order_id' }, 400);
  }
  const { data: order } = await project.from('orders').select('status, user_id').eq('id', orderId).maybeSingle();
  if (!order) {
    return json({ error: 'order_not_found' }, 404);
  }
  const { data: profile } = await project.from('profiles').select('fcm_token, language_code').eq('id', order.user_id).maybeSingle();
  const token = (profile?.fcm_token as string | undefined) ?? '';
  if (!token) {
    return json({ error: 'no_device_token' }, 404);
  }
  const status = String(order.status);
  const lang = profile?.language_code === 'fr' ? 'fr' : 'ar';
  const text = STATUS_TEXT[status]?.[lang];
  if (!text) {
    return json({ error: 'unknown_status' }, 400);
  }
  await sendFcm({ token, title: text[0], body: text[1], data: { orderId, status } });
  return json({ ok: true, mode: 'order_status', status, orderId });
}

async function sendFcm(message: { token?: string; topic?: string; title: string; body: string; data?: Record<string, string> }) {
  const raw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
  if (!raw) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT secret is not set');
  }
  const account = JSON.parse(raw) as { project_id: string; client_email: string; private_key: string };
  const accessToken = await googleAccessToken(account);
  const target = message.token ? { token: message.token } : { topic: message.topic };
  const response = await fetch(`https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      message: {
        ...target,
        notification: { title: message.title, body: message.body },
        data: message.data ?? {},
        android: { priority: 'high' },
      },
    }),
  });
  if (!response.ok) {
    throw new Error(`FCM ${response.status}: ${await response.text()}`);
  }
}

async function googleAccessToken(account: { client_email: string; private_key: string }) {
  const key = await importPKCS8(account.private_key, 'RS256');
  const now = Math.floor(Date.now() / 1000);
  const assertion = await new SignJWT({ scope: 'https://www.googleapis.com/auth/firebase.messaging' })
    .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
    .setIssuer(account.client_email)
    .setAudience('https://oauth2.googleapis.com/token')
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(key);
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${assertion}`,
  });
  if (!response.ok) {
    throw new Error(`OAuth ${response.status}: ${await response.text()}`);
  }
  return (await response.json()).access_token as string;
}

function decodeJwt(authHeader: string): Record<string, unknown> | null {
  const token = authHeader.replace(/^Bearer\s+/i, '').trim();
  const parts = token.split('.');
  if (parts.length !== 3) {
    return null;
  }
  try {
    return JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));
  } catch {
    return null;
  }
}

function jwtRole(authHeader: string): string {
  return String(decodeJwt(authHeader)?.role ?? '');
}

function jwtSub(authHeader: string): string | null {
  const sub = decodeJwt(authHeader)?.sub;
  return typeof sub === 'string' && sub.length > 0 ? sub : null;
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
}
