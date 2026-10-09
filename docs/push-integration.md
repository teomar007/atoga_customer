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

### ب) سرّ الاستدعاء الداخلي (للـ Trigger)
استبدل `<SERVICE_ROLE_KEY>` بمفتاح service_role من
Supabase ← Settings ← API ← `service_role`، ونفّذ في SQL Editor:

```sql
select vault.create_secret('<SERVICE_ROLE_KEY>', 'push_service_role', 'internal auth for send-push');
```

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
