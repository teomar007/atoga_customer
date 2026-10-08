/// ثوابت عامة التطبيق (مجمّعة في مكان واحد لتفادي تكرار القيم).
abstract final class AppConstants {
  const AppConstants._();

  static const String appName = 'ATOGA MARKET';
  static const String appVersion = '1.1.0';

  // OneSignal — معرّف تطبيق الإشعارات (Push Notifications).
  static const String onesignalAppId = '4068140a-b02a-405f-a94f-89b2b4730879';

  // روابط الدعم (تُستبدل بنطاق المتجر الفعلي قبل النشر). سياسة الخصوصية
  // وشروط الاستخدام منشورتان داخل التطبيق نفسه، مع نسخة عامة للوحة Play.
  // أرقام الاتصال صارت ديناميكية من جدول `social_links` (contact_phone /
  // whatsapp_number) فلا تُكتب هنا بعد اليوم.
  static const String faqUrl = 'https://atogamarket.app/faq';

  // الصفحات القانونية العامة (مستضافة GitHub Pages) — تُستخدم في لوحة
  // Google Play Console كروابط السياسة والشروط.
  static const String privacyPolicyUrl = 'https://teomar007.github.io/atoga_customer/docs/privacy-policy.html';
  static const String termsOfServiceUrl = 'https://teomar007.github.io/atoga_customer/docs/terms.html';

  // TODO: ADMIN APP INTEGRATION - Use this aspect ratio (e.g., 800x400 px) in the Admin App as a hint for the image picker/cropper to ensure banners fit perfectly in the customer app.
  /// نسبة العرض إلى الارتفاع المثالية لبطاقة العروض في الصفحة الرئيسية
  /// (2:1). تُستعمل كتلميح لقص الصور في لوحة الإدارة وليس كقياس حتمي —
  /// صورة أي مقاس تُعرض مقتصةً (BoxFit.cover) داخل البطاقة.
  static const double promoBannerAspectRatio = 2.0;

  // قواعد السلة والطلبات.
  static const int maxQuantityPerItem = 99;
  static const double deliveryFee = 200;
  static const double freeDeliveryThreshold = 3000;

  // التخزين المحلي.
  static const String cartBoxName = 'cart_box';
  static const String cartBoxKey = 'cart_items';
  static const String localePrefKey = 'app_locale';
}
