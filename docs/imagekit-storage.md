# تخزين الصور عبر ImageKit (بديل Supabase Storage)

## المعمارية

- **الرفع يتم من العميل مباشرةً إلى ImageKit** (لا يمرّ الملف عبر Supabase)، ما يخفّض
  استهلاك التخزين والنطاق في Supabase إلى الصفر.
- **Edge Function `imagekit-auth`** تولّد بيانات التوقيع المؤقتة
  (`token` / `expire` / `signature` / `publicKey`) بعد التحقق من أن المستخدم موظف
  نشط بدور `super_admin` أو `manager` أو `marketer`. المفتاح الخاص يبقى سرّاً على
  الخادم ولا يُرسل للعميل أبداً.
- **تطبيق الإدارة `ATOGA_MANAGER`** يرفع الصورة عبر `ImageKitUploader`
  ثم يخزّن رابط CDN الناتج في عمود `image_url` (في `products` وغيرها).
- **التحويلات**: يُخزَّن الرابط مع `?tr=w-800,f-webp,q-80` لتصغير الحجم وتقديمه
  بصيغة webp (توفير ≈ 70% من الحجم).

## المسار

```
تطبيق الإدارة ──invoke──▶ imagekit-auth (يتحقق من الدور)
      │                        └─ يعيد token/expire/signature/publicKey
      └──multipart upload──▶ upload.imagekit.io ──▶ رابط CDN
      └──insert/update──▶ Supabase (products.image_url)
```

## الإعداد (مرة واحدة)

1. **السرّ**: Supabase ← Edge Functions ← Secrets ← أضف
   `IMAGEKIT_PRIVATE_KEY` (المفتاح الخاص من ImageKit). بدونه تُعيد الدالة
   `imagekit_not_configured`.
   اختياري: `IMAGEKIT_PUBLIC_KEY` و`IMAGEKIT_URL_ENDPOINT` (لهما قيم افتراضية عامة).
2. **النشر**: الدالة `imagekit-auth` منشورة بمصادقة JWT مفعّلة (`verify_jwt=true`).
   لإعادة النشر يدوياً:
   ```bash
   supabase functions deploy imagekit-auth
   ```

## التحقق

```powershell
.\tool\verify_imagekit_upload.ps1 -Email <staff-email> -Password <pass> -ImagePath .\sample.jpg
```

السكربت يسجّل الدخول، يطلب توكن ImageKit، يرفع صورة، يحفظ رابطها في `products`،
يتحقق من قيمته، ثم يحذف صف الاختبار. يطبع `PASS` عند النجاح.

## الملفات

- `supabase/functions/imagekit-auth/index.ts` — مولّد التوكن.
- `ATOGA_MANAGER/lib/core/services/imagekit_uploader.dart` — رافع العميل.
- `ATOGA_MANAGER/lib/features/catalog/data/catalog_repository.dart` —
  `uploadImage` للمنتجات.
- `ATOGA_MANAGER/lib/features/marketing/data/marketing_repository.dart` —
  `uploadImage` للبانرات/الإشعارات.
