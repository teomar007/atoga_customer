// Edge Function: إرسال إشعارات FCM (مجاناً) — للمستخدم، للموضوع العام،
// أو تلقائياً عند تغيّر حالة الطلب (الزبون)، أو عند وصول طلب جديد (الدرايفر).
//
// الأسرار المطلوبة: FIREBASE_SERVICE_ACCOUNT (Service Account من Firebase).
// التصريح: x-internal-secret (Vault)، أو service_role، أو موظف إداري نشط.
//
// ملاحظة: هذا الملف مطابق للإصدار المنشور (v10). أوضاع الزبون
// (`order_status`/`user`/`topic`) محفوظة كما هي، والجديد هو `new_order`.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { importPKCS8, SignJWT } from 'npm:jose@5';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-internal-secret',
};

const ADMIN_ROLES = ['super_admin', 'marketer', 'manager'];
const FULFILLMENT_ROLES = ['driver', 'packager', 'driver_packager'];

// قناة إشعارات الدرايفر (تُنشأ في التطبيق بصوت المنبّه).
const DRIVER_CHANNEL_ID = 'driver_orders';

type PushMode = 'user' | 'topic' | 'order_status' | 'new_order';

interface PushBody {
  mode: PushMode;
  user_id?: string;
  topic?: string;
  order_id?: string;
  title?: string;
  body?: string;
  image?: string;
  data?: Record<string, string>;
  channel_id?: string;
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
        const { data: roleRow } = await admin.from('staff_roles').select('role, is_active').eq('user_id', sub).maybeSingle();
        const staffRole = String(roleRow?.role ?? '');
        if (!(roleRow?.is_active === true && ADMIN_ROLES.includes(staffRole))) {
          return json({ error: 'forbidden' }, 403);
        }
      }
    }

    const payload = (await req.json()) as PushBody;
    const project = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');

    if (payload.mode === 'order_status') {
      return await sendOrderStatus(project, payload.order_id);
    }
    if (payload.mode === 'new_order') {
      return await sendNewOrderToStaff(project, payload.order_id, payload.channel_id);
    }
    const title = payload.title ?? '';
    const body = payload.body ?? '';
    if (payload.mode === 'user') {
      if (!payload.user_id || !title || !body) {
        return json({ error: 'missing_fields' }, 400);
      }
      const { data: profile } = await project.from('profiles').select('fcm_token').eq('id', payload.user_id).maybeSingle();
      const token = profile?.fcm_token as string | undefined;
      if (!token) {
        return json({ error: 'no_token' }, 404);
      }
      await sendFcm({ token, title, body, image: payload.image, data: payload.data });
      return json({ ok: true, mode: 'user' });
    }
    const topic = payload.topic ?? 'all';
    if (!title || !body) {
      return json({ error: 'missing_title_or_body' }, 400);
    }
    await sendFcm({ topic, title, body, image: payload.image, data: payload.data });
    return json({ ok: true, mode: 'topic', topic });
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
  const token = profile?.fcm_token as string | undefined;
  if (!token) {
    return json({ error: 'no_token' }, 404);
  }
  const status = String(order.status);
  const lang = profile?.language_code === 'fr' ? 'fr' : 'ar';
  const text = STATUS_TEXT[status]?.[lang];
  if (!text) {
    return json({ error: 'unknown_status' }, 400);
  }
  await sendFcm({ token, title: text[0], body: text[1], data: { orderId, status } });
  return json({ ok: true, mode: 'order_status', status });
}

// عند وصول طلب جديد: يُرسل إلى جميع رموز الموظفين النشطين (سائق/معبئ/مزدوج).
async function sendNewOrderToStaff(
  project: ReturnType<typeof createClient>,
  orderId?: string,
  channelId?: string,
) {
  if (!orderId) {
    return json({ error: 'missing_order_id' }, 400);
  }
  const { data: order } = await project
    .from('orders')
    .select('id, delivery_zone_name, street')
    .eq('id', orderId)
    .maybeSingle();
  if (!order) {
    return json({ error: 'order_not_found' }, 404);
  }
  const area = String(order.delivery_zone_name ?? '').trim() || String(order.street ?? '').trim();
  const title = 'طلب جديد وصل!';
  const body = area ? `طلب جديد بانتظار التجهيز — ${area}` : 'طلب جديد بانتظار التجهيز';

  const { data: staff } = await project
    .from('staff_roles')
    .select('user_id')
    .eq('is_active', true)
    .in('role', FULFILLMENT_ROLES);
  const ids = (staff ?? []).map((row: { user_id: string }) => row.user_id).filter((id: string) => !!id);
  if (ids.length === 0) {
    return json({ ok: true, mode: 'new_order', sent: 0 });
  }

  const { data: profiles } = await project.from('profiles').select('fcm_token').in('id', ids);
  const tokens = Array.from(
    new Set(
      (profiles ?? [])
        .map((row: { fcm_token: string | null }) => row.fcm_token)
        .filter((token: string | null): token is string => typeof token === 'string' && token.length > 0),
    ),
  );

  const channel = channelId || DRIVER_CHANNEL_ID;
  let sent = 0;
  const errors: string[] = [];
  for (const token of tokens) {
    try {
      await sendFcm({ token, title, body, channelId: channel, data: { type: 'new_order', orderId } });
      sent += 1;
    } catch (error) {
      errors.push(String(error));
    }
  }
  return json({ ok: true, mode: 'new_order', candidates: tokens.length, sent, errors: errors.slice(0, 3) });
}

async function sendFcm(message: {
  token?: string;
  topic?: string;
  title: string;
  body: string;
  image?: string;
  data?: Record<string, string>;
  channelId?: string;
}) {
  const raw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
  if (!raw) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT secret is not set');
  }
  const account = JSON.parse(raw) as { project_id: string; client_email: string; private_key: string };
  const accessToken = await googleAccessToken(account);
  const target = message.token ? { token: message.token } : { topic: message.topic };
  const androidNotification: Record<string, unknown> = {
    ...(message.image ? { image: message.image } : {}),
    ...(message.channelId
      ? {
          channel_id: message.channelId,
          notification_priority: 'PRIORITY_MAX',
          default_sound: true,
          default_vibrate_timings: true,
        }
      : {}),
  };
  const response = await fetch(`https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      message: {
        ...target,
        notification: { title: message.title, body: message.body, ...(message.image ? { image: message.image } : {}) },
        android: {
          priority: 'high',
          ...(Object.keys(androidNotification).length > 0 ? { notification: androidNotification } : {}),
        },
        data: message.data ?? {},
      },
    }),
  });
  if (!response.ok) {
    throw new Error(`FCM ${response.status}: ${await response.text()}`);
  }
}

async function googleAccessToken(account: { client_email: string; private_key: string }): Promise<string> {
  const iat = Math.floor(Date.now() / 1000);
  const jwt = await new SignJWT({ scope: 'https://www.googleapis.com/auth/firebase.messaging' })
    .setProtectedHeader({ alg: 'RS256' })
    .setIssuer(account.client_email)
    .setAudience('https://oauth2.googleapis.com/token')
    .setIssuedAt(iat)
    .setExpirationTime(iat + 3600)
    .sign(await importPKCS8(account.private_key, 'RS256'));
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion: jwt }),
  });
  if (!response.ok) {
    throw new Error(`OAUTH ${response.status}: ${await response.text()}`);
  }
  const data = (await response.json()) as { access_token: string };
  return data.access_token;
}

function jwtRole(authHeader: string): string {
  return String(decodeJwt(authHeader)?.role ?? '');
}

function jwtSub(authHeader: string): string | null {
  const sub = decodeJwt(authHeader)?.sub;
  return typeof sub === 'string' && sub.length > 0 ? sub : null;
}

function decodeJwt(authHeader: string): Record<string, unknown> | null {
  const token = authHeader.replace(/^Bearer\s+/i, '').trim();
  const parts = token.split('.');
  if (parts.length !== 3) {
    return null;
  }
  try {
    const base64 = parts[1].replace(/-/g, '+').replace(/_/g, '/');
    return JSON.parse(decodeURIComponent(escape(atob(base64))));
  } catch {
    try {
      return JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));
    } catch {
      return null;
    }
  }
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
}
