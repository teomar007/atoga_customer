# الميزات — Features
> عربي / English — صفحة يدوية تُحدَّث عند إضافة ميزة. Hand-maintained.

## المصادقة — Authentication
- الدخول برقم الهاتف وكلمة مرور (بريد وهمي `<phone>@atoga.com`) — Phone + password login (dummy email).
- Google Sign-In بمخطط `atogamarket://login-callback` — Google OAuth deeplink.
- إنشاء حساب، تسجيل خروج، حذف حساب (Google Play) — Signup, logout, account deletion.
- حفظ الجلسة في SecureStorage، وسلة في Hive — Secure session + Hive cart.

## الرئيسية — Home
- بنرات (carousel)، شريط تصنيفات بأيقونات، بحث، شبكة منتجات عمودَين وتمرير لا نهائي — banners, icons rail, search, infinite grid.
- مؤشّر مفتوح/مغلق حسب أوقات العمل — open/closed status by store hours.
- بطاقة المنتج: سعر/عرض/خصم، إضافة للسلة، مفضلة — product card (price, promo, favorites).

## السلة والدفع — Cart & Checkout
- تعديل كميات/حذف، سلة سحابية متزامنة — quantities, cloud-synced cart.
- كوبونات (نسبة/مبلغ/توصيل مجاني، حد أدنى) — coupons.
- عناوين + منطقة توصيل + خريطة (flutter_map/OSM + Nominatim reverse geocode) — addresses, zones, map.
- دفع عند الاستلام أو محفظة (خصم RPC) — COD or wallet payment.
- رسوم منطقة + توصيل مجاني فوق حدّ — zone fees + free-delivery threshold.

## الطلبات — Orders
- قائمة حية جارية/سابقة، إعادة الطلب — live list + reorder.
- تتبّع: خط زمني، مندوب مع اتصال، فاتورة حيّة، شارة «نفد المخزون»، إلغاء في «قيد الاستلام» — tracking, courier, live invoice, out-of-stock badge, cancellation window.

## المحفظة — Wallet
- رصيد يُقرأ فقط، سجل حركات (شحن إداري/دفع) — read-only balance + transactions.

## الحساب والإشعارات — Profile & Notifications
- لغة عربي/فرنسي، عناوين، دعم، أسئلة، خصوصية/شروط — language, addresses, support, FAQ, legal.
- FCM: إشعارات الحالة + صورة Big Picture + فتح التتبّع من النقر — FCM status push with image + deep open.
- حالة التجميد الحي (Realtime على profiles) — live frozen state.

---
*رابط لقطة الشاشات: `SCREENS.md` ووثيقة المنظومة المركزية `docs/ATOGA_SYSTEM_DOCUMENTATION.html`.*
