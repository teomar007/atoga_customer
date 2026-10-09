# تكامل الإشعارات (FCM) مع تطبيق الأدمن

الإشعارات تُرسل عبر Firebase Cloud Messaging (مجاناً) من دالة Edge باسم
`send-push`. تطبيق الأدمن لا يحمل أي مفتاح سِرّي؛ يستدعي الدالة وهو مسجّل
باستخدام حساب علمه `profiles.is_admin = true`.

## 1) متطلبات لمرة واحدة

### أ) سرّ مفتاح خدمة Firebase (للإرسال)
Firebase Console ← ⚙️ Project settings ← **Service accounts** ←
**Generate new private key** ← حمّل ملف JSON كاملاً، ثم أضفه في
Supabase ← **Edge Functions ← Secrets** باسم:

```
FIREBASE_SERVICE_ACCOUNT = <محتوى ملف JSON كاملاً>
```

### ب) أسرار Vault (للـ Trigger) — تُنفَّذ مرة واحدة في SQL Editor
```sql
-- مفتاح anon العام (لتجاوز بوابة JWT في Supabase فقط)
select vault.create_secret('<ANON_KEY>', 'push_anon_key', 'public jwt for platform check');
-- السرّ الداخلي (sb_secret_…) الذي تتحقق به send-push من الطلب الداخلي
select vault.create_secret('<sb_secret_INTERNAL>', 'push_internal_secret', 'send-push internal secret');
-- اختياري: مفتاح service_role (يُرسل كـ Bearer بدل anon عند توفره)
select vault.create_secret('<SERVICE_ROLE_KEY>', 'push_service_role', 'internal auth');
```
> ملاحظة: `send-push` تقبل الطلب الداخلي عبر ترويسة `x-internal-secret`
> المطابقة للسرّ المخزّن في Vault، أو عبر JWT بدور `service_role`.

### ج) تعيين أدمن
بعد إنشاء حساب الأدمن وتسجيله في التطبيق:
```sql
update public.profiles set is_admin = true where phone = '0XXXXXXXXX';
```

## 2) الإرسال من تطبيق الأدمن (عند بنائه)

أ) **حملة عامة لكل الزبائن** (تُرسل مرة واحدة لكل مشترك في موضوع `all`):
```ts
await supabase.functions.invoke('send-push', {
  body: { mode: 'topic', topic: 'all', title: 'عروض اليوم', body: 'خصومات على منتجات مختارة' },
});
```

ب) **رسالة لمستخدم بعينه**:
```ts
await supabase.functions.invoke('send-push', {
  body: { mode: 'user', user_id: '<UUID>', title: 'مرحباً', body: 'طلبك جاهز' },
});
```

ج) **إشعار مرتبط بطلب** (نص جاهز حسب لغة الزبون) — لا حاجة لاستدعائه عند
تغيير الحالة؛ الـ Trigger يفعل ذلك تلقائياً:
```ts
await supabase.functions.invoke('send-push', {
  body: { mode: 'order_status', order_id: '<ORDER_ID>' },
});
```

## 3) كيف يعمل الإرسال التلقائي؟
عند تغيّر عمود `status` في `orders`، يستدعي Trigger `notify_order_status_change`
دالة `send-push` بمفتاح service_role (من Vault)، والدالة تقرأ رمز جهاز الزبون
(`profiles.fcm_token`) وترسل النص بلغته (`language_code`).

## 4) ملاحظات
- رموز الأجهزة تُحفظ تلقائياً في `profiles.fcm_token` من تطبيق الزبون، وتُصفّر عند تسجيل الخروج.
- حملة Firebase Console (Messaging) متاحة أيضاً للتجربة اليدوية دون أي كود.
- النطاقات المطلوبة من أجهزة الزبائن: `firebaseinstallations.googleapis.com`،
  `fcm.googleapis.com` (تعمل عادةً داخل الجزائر).
