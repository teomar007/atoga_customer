# ATOGA MARKET 1.1.0 — تطبيق الزبون

تطبيق تسوّق مواد غذائية سريع — Flutter + Supabase + Riverpod.
الإصدار `1.1.0+2`، الحزمة `com.atogamarket.atoga_customer`.

## الحالة الحالية

| الفحص | النتيجة |
|---|---|
| `flutter analyze` | ✅ لا مشاكل (0 أخطاء / 0 تحذيرات) |
| `flutter test` | ✅ 96/96 ناجحة |
| قاعدة البيانات | ⏳ يحتاج تنفيذ `supabase/schema.sql` |
| الخرائط | ✅ OpenStreetMap — **بدون مفتاح API** |
| حذف الحساب | ⏳ يحتاج نشر `delete-account` Edge Function |

## التشغيل

```bash
flutter pub get
flutter gen-l10n
flutter run
```

### 1) قاعدة البيانات (إلزامي قبل الاختبار الحقيقي)

1. افتح لوحة Supabase > **SQL Editor** > New query.
2. انسخ محتوى [`supabase/schema.sql`](supabase/schema.sql) وشغّله كاملاً.
3. من **Authentication > Providers** فعّل:
   - **Email** (مزوّد المصادقة الفعلي — الهاتف يُحوَّل خلف الكواليس إلى بريد
     وهمي، راجع «حيلة البريد الوهمي» أدناه).
   - **Google** (انسخ Client ID / Client Secret من Google Cloud).
   - **Phone غير مطلوب** — لا يوجد OTP أو SMS في هذا الإصدار، ويمكن إيقافه.
4. من **Authentication > URL Configuration** أضف رابط التحويل:
   `atogamarket://login-callback`

> ### ✅ إلزامي: حيلة البريد الوهمي (بلا OTP)
> المستخدم يرى حقل **رقم الهاتف** في شاشة الدخول، لكن المصادقة تتم عبر
> **Email Provider** — لا شاشة OTP ولا رسالة SMS في هذا الإصدار
> (حُذفت `otp_screen.dart` كلياً).
>
> | ما يكتبه المستخدم | ما يصل إلى Supabase Auth |
> |---|---|
> | `0555123456` | `0555123456@atoga.com` |
>
> - التحويل في `lib/core/utils/phone_utils.dart`: `PhoneNumbers.toDummyEmail()`
>   تُستدعى من `signInWithPassword` و`signUp` في `SupabaseAuthRepository`،
>   و`PhoneNumbers.fromDummyEmail()` لاستعادة الرقم عند القراءة.
> - أي صيغة مقبولة (`05…`، `+213…`، `00213…`) تُوحَّد إلى محور واحد:
>   نفس الرقم ⇒ نفس الحساب، وأرقام مختلفة ⇒ حسابات مختلفة (لا تصادم).
> - البريد الوهمي معرّف داخلي فقط ولا يُعرض للمستخدم أبداً؛ الرقم الحقيقي
>   يُحفظ في `raw_user_meta_data.phone_local` ثم في `profiles.phone`.
>
> ### ✅ إلزامي: تسجيل بلا تأكيد (`Confirm email = OFF`)
> من **Authentication → Sign In / Providers → Email** أوقف **Confirm email**
> (= `mailer_autoconfirm`). هذه حلّ الدخول الفوري: `signUp` تُرجع **جلسة
> تلقائياً** فيدخل المستخدم التطبيق مباشرة بعد التسجيل.
>
> إن بقي التأكيد مفعّلاً، تعود `signUp` بلا جلسة فيظهر تنبيه
> `autoconfirmRequired` بدل الدخول، ونصّه يوجّه إلى:
> `Authentication > Email > Confirm email = OFF`.
>
> **التحقق:** `GET /auth/v1/settings` مع `apikey` في الـ header →
> `mailer_autoconfirm: true`.
>
> ### ⚠️ لماذا دالة `get_or_create_my_profile`؟
> لو ظلّ التأكيد مفعّلاً فلا توجد جلسة بعد التسجيل، فيمنع RLS العميل
> الكتابة على `profiles`. الضمان على ثلاثة مستويات:
> 1. `trigger on_auth_user_created` ينشئ الصف على الخادم (`SECURITY DEFINER`).
> 2. `get_or_create_my_profile()` يضمنه بعد تسجيل الدخول كشبكة أمان.
> 3. عند توفر الجلسة يكتب التطبيق `display_name` و`phone` عبر `upsert`
>    مباشرة (`SupabaseAuthRepository.signUp`).

### 2) مفاتيح الاتصال

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_xxx
```

### 3) التخزين المشفّر

جلسة Supabase تُخزَّن في `flutter_secure_storage` (Keystore / Keychain) عبر
`lib/core/services/secure_local_storage.dart` — لا تُكتب التوكنات في تخزين غير محمي.

### 4) الخرائط — OpenStreetMap (لا تحتاج مفتاحاً) {#الخرائط}

| الطبقة | الحزمة / الخدمة |
|---|---|
| عرض الخريطة | `flutter_map` + `latlong2` |
| بلاطات الخريطة | `tile.openstreetmap.org` |
| تحديد موقع الجهاز | `geolocator` |
| Reverse Geocoding | Nominatim (`nominatim.openstreetmap.org`) |

سلوك شاشة العنوان (`AddressFormScreen`):

1. **عند الفتح:** الخريطة متمركزة على الجزائر العاصمة (افتراضياً) مع دبوس
   ثابت في منتصف الشاشة (Center Marker) — العنوان المُختار هو ما تحت الدبوس.
2. **عند ضغط "استخدم موقعي الحالي":** نافذة شرح ← إذن النظام ← `geolocator`
   ← `MapController.move()` لتحريك سلس ← Reverse Geocoding يملأ الشارع والحي.
3. **أثناء الجلب:** يتحوّل الزر إلى Spinner مع نص "جارٍ تحديد موقعك...".
4. **النقر على الخريطة:** يحدّد الإحداثيات مباشرة (بلا سحب للدبوس).

> **سياسة Nominatim:** يطلب التطبيق `User-Agent` معرّفاً،
> ويفرض فاصل 1.1 ثانية بين الطلبات (`NominatimGeocoder._throttle`).
> الخريطة تعرض نسبة OpenStreetMap للمطابع بصيغة `RichAttributionWidget`.

### 5) حذف الحساب (شرط Google Play)

حذف صف `auth.users` يتطلب صلاحية `service role`، لذا يتم عبر Edge Function:

```bash
cp -r supabase/functions/delete-account <supabase-project>/supabase/functions/
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<service-role-key>
supabase functions deploy delete-account --no-verify-jwt
```

التطبيق يستدعيها من `SupabaseAuthRepository.deleteAccount()`، وهي تحذف:
عناصر الطلب ← الطلبات ← العناوين ← الملف الشخصي ← حساب Auth.

> أضف مفتاحاً جديداً في **كل** ملفات `app_ar.arb` و`app_fr.arb` معاً.

```
lib/
├── main.dart                    # تهيئة Hive + Supabase + Riverpod
├── app.dart                     # MaterialApp + الثيم + الترجمة + RTL/LTR
├── core/
│   ├── config/                  # مفاتيح Supabase و Google Maps
│   ├── constants/               # ثوابت عامة
│   ├── navigation/              # بوابة المصادقة AuthGate + الهيكل الرئيسي
│   ├── providers/               # مزوّدات عامة (اللغة، عميل Supabase)
│   ├── services/                # تخزين السلة (Hive) + تخزين مشفّر
│   ├── theme/                   # الألوان والخطوط والثيم (Material 3)
│   ├── utils/                   # تنسيق الأسعار والتواريخ + التحقق
│   └── widgets/                 # Shimmer، حالة فارغة، حالة خطأ، شريط انقطاع
├── features/
│   ├── splash/                  # شاشة البداية (Fade-in)
│   ├── auth/                    # بريد وهمي (هاتف كاسم مستخدم) + Google + حذف الحساب
│   ├── home/                    # بحث، بانرات، تصنيفات، شبكة منتجات
│   ├── cart/                    # Hive + كوبونات + مجاميع لحظية
│   ├── coupons/                 # صفحة الكوبونات (عرض + نسخ الكود + الشارة)
│   ├── favorites/               # المفضلة (مزوّد + مستودع Supabase)
│   ├── social/                  # روابط التواصل الاجتماعي (Key-Value)
│   ├── checkout/                # عناوين + خريطة OSM + COD + إدراج الطلب
│   ├── orders/                  # السجل + التتبع الحي + إعادة الطلب
│   └── profile/                 # الحساب، العناوين، اللغة، الدعم، الخصوصية
├── l10n/arb/                    # app_ar.arb + app_fr.arb (المصدر)
└── l10n/generated/              # مولّد تلقائياً — لا تعدّله
```

## قرارات معمارية مهمة

| القرار | السبب |
|---|---|
| Riverpod `Notifier` | مرونة في الت.inject + اختبار أسهل (`ProviderContainer`) |
| `AuthFailureMapper` | يقرأ `code` الرسمي من gotrue/PostgREST بدل مطابقة نصية هشة |
| حيلة البريد الوهمي (`0555123456@atoga.com`) | الهاتف هو الاسم المستخدم؛ يعمل JWT وRLS عبر Email Provider بلا Phone Provider ولا OTP |
| `get_or_create_my_profile` RPC | يضمن صف `profiles` رغم غياب الجلسة بعد التسجيل |
| `AuthGate` بدل `Navigator` في Splash | التوجيه يتبع حالة الجلسة تفاعلياً؛ لا `pushReplacement` يدوي |
| `minimumSize: Size(0, 52)` في الثيم | `Size.fromHeight` تفرض عرضاً لا نهائياً داخل `Row` فيبيّض الشاشة |
| الهاتف اختياري في `profiles` | مطلوب فقط لحظة إتمام الطلب — `PhoneRequiredSheet` |
| `profiles.upsert` بدل `insert` | يعمل لصف موجود أو غير موجود بلا فرع |
| `CartStore` واجهة + `CartStorage` تنفيذ | يسمح باختبار منطق السلة بدون Hive |
| تخزين السلة كـ JSON في Hive | يتجنّب `build_runner` وTypeAdapters |
| ترقيم صفحات بـ `range()` | تقليل استهلاك باقة بيانات الزبون |
| بحث مؤجّل 350ms | تقليل عدد الطلبات أثناء الكتابة |
| `CustomerUser` لا `AuthUser` | `package:supabase` يصدّر `AuthUser` مهجور فيتعارضان |
| `ProductCategory` لا `Category` | `flutter/foundation` يصدّر `Category` فيتعارضان |
| `.eq()`/`.ilike()` قبل `.order()`/`.range()` | `order`/`range` يُرجعان builder بلا فلاتر |

## الهوية البصرية

| العنصر | القيمة |
|---|---|
| Primary | `#E53935` |
| Accent | `#FFB300` |
| خلفية البطاقات | `#FFFFFF` |
| الخلفية العامة | `#F8F9FA` |
| النصوص | `#212121` |
| الخط (عربي) | Cairo |
| الخط (فرنسي) | Poppins |

## ضمانات Google Play

- ✅ **حذف الحساب**: زر أحمر في الإعدادات ينفّذ حذفاً كاملاً (Edge Function).
- ✅ **سياسة الخصوصية**: صفحة **داخل التطبيق** (`privacy_policy_view.dart`) +
  رابط في شاشة التسجيل + في الإعدادات.
- ✅ **أذونات الموقع**: لا يُطلب الإذن عند فتح التطبيق إطلاقاً؛ فقط عند ضغط
  المستخدم على "استخدم موقعي الحالي"، وبعد نافذة تشرح السبب.
- ✅ **الشبكة**: أذونات `INTERNET` + `ACCESS_NETWORK_STATE` فقط، دون أذونات زائدة
  (أُزيلت `com.google.android.gms` بعد التحوّل إلى OpenStreetMap).

## الأوامر

```bash
flutter analyze          # فحص الجودة
flutter test             # اختبارات الوحدة
flutter gen-l10n         # إعادة توليد الترجمات
flutter build apk --release
```

## قبل النشر

1. نفّذ `supabase/schema.sql`.
2. فعّل **Email** provider وأوقف **Confirm email** (راجع «حيلة البريد الوهمي»).
3. انشر `delete-account` Edge Function (أمر `supabase functions deploy`).
4. استبدل الروابط في `lib/core/constants/app_constants.dart` بنطاق المتجر الحقيقي
   (`privacyPolicyUrl`، `termsOfServiceUrl`، `faqUrl`، `supportPhone`، `whatsappNumber`).
5. بدّل أيقونات التطبيق (`android/app/src/main/res/mipmap-*`).

## قائمة الرفع إلى Google Play

1. **التوقيع**: `android/key.properties` + `android/app/upload-keystore.jks` (خارج git).
   البناء النهائي (مع مفتاح الخرائط):
   `flutter build appbundle --release --dart-define=MAPTILER_KEY=...` ثم ارفع
   `build/app/outputs/bundle/release/app-release.aab`.
2. **سياسة الخصوصية**: رابط عام في Play Console (مفعّل بالفعل) —
   `https://teomar007.github.io/atoga_customer/docs/privacy-policy.html`
   (Pages مفعّلة من الفرع `main`/الجذر، والملفات داخل `/docs`).
   روابط إضافية للوحة: حذف الحساب
   `https://teomar007.github.io/atoga_customer/docs/account-deletion.html`
   ودليل النشر الكامل (نصوص/بيانات/إجابات):
   `https://teomar007.github.io/atoga_customer/docs/store-listing.html`.
3. **Data Safety** في اللوحة (مطابق للسياسة): الموقع (إذن اختياري)، رقم
   الهاتف، الاسم، العنوان، سجل الطلبات، معرّف الإشعارات (OneSignal) —
   بلا إعلانات، بلا بيع بيانات.
4. **استبيان التقييم العمري** + **قائمة المتجر** بالعربية والفرنسية
   (الوصف، لقطات ≥ 2 لهاتف وأخرى للوحي، شارة 512×512).
5. **الخرائط**: MapTiler (مفعّل): مفتاح `MAPTILER_KEY` يُمرَّر في البناء
   (`--dart-define`) — غيابه يُرجع تلقائياً إلى OSM للتطوير.
6. **الإشعارات**: إعداد Firebase/`google-services.json` لـ OneSignal على
   Android، وتسجيل SHA-1 لـ Google OAuth في لوحة Supabase.
7. بعد كل تحديث: `flutter analyze` + `flutter test`، ورفع AAB جديد
   (versionCode تصاعدي في `pubspec.yaml`).
