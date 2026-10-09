import 'customer_user.dart';

/// عقد المصادقة — يفصل الواجهة عن Supabase ليسهل الاختبار.
///
/// pathways الدخول: **رقم الهاتف + كلمة المرور** أو **Google Sign-In**.
///
/// الهاتف يُعامَل كـ Username: يحوّله التطبيق خلف الكواليس إلى بريد وهمي
/// (`<phone>@atoga.com`) ويُمرّره إلى Supabase Auth، فنستفيد من JWT و RLS
/// كاملين بلا Phone Provider و بلا OTP.
/// لا يسمع المستخدم بهذه العملية إطلاقاً.
abstract interface class AuthRepository {
  /// المستخدم الحالي من الجلسة المحفوظة، أو null.
  CustomerUser? get currentUser;

  /// يستمع لتغيّر الجلسة (تسجيل دخول/خروج/تحديث).
  Stream<CustomerUser?> authStateChanges();

  /// يفتح متصفح OAuth؛ النتيجة تُراقَب عبر [authStateChanges] لأن العائد
  /// من `signInWithOAuth` هو نجاحُ_launch فقط لا نتيجة المصادقة.
  Future<void> signInWithGoogle();

  /// تسجيل الدخول برقم الهاتف: يُحوَّل إلى بريد وهمي ثم يُرسل لـ
  /// `supabase.auth.signInWithPassword(email: dummyEmail, password: ...)`.
  Future<CustomerUser> signInWithPassword({required String phone, required String password});

  /// إنشاء حساب جديد برقم الهاتف وكلمة المرور.
  ///
  /// يعيد `sessionReady = false` إن لم يُنشأ تريد تأكيد (عند تعطيل
  /// `phone_autoconfirm` في لوحة Supabase).
  Future<SignUpResult> signUp({
    required String phone,
    required String password,
    String? displayName,
  });

  Future<void> signOut();

  /// شرط Google Play: مسح كل بيانات المستخدم من الخادم ومن Auth.
  Future<void> deleteAccount();

  /// تحديث الاسم ورقم الهاتف في جدول `profiles`.
  ///
  /// رقم الهاتف **اختياري**: القيم الفارغة تُحفظ كـ null.
  Future<CustomerUser> updateProfile({String? displayName, String? phone});

  /// يحفظ رقم الهاتف وحده (يستعمله الـ BottomSheet عند إتمام الطلب).
  Future<CustomerUser> savePhone(String phone);

  /// يقرأ الملف الشخصي المحفوظ أو ينشئه.
  ///
  /// يُستدعى عند الإقلاع بجلسة محفوظة: `_map` لا يقرأ `profiles`، فبدونه
  /// لا تصل اللغة والتفضيلات المخزّنة في الخادم إلى التطبيق.
  Future<CustomerUser> refreshProfile();

  /// يحفظ لغة المستخدم في `profiles.language_code` لتعود بعد أي دخول
  /// أو على جهاز آخر. الاستيراد يتم عبر قراءة الملف الشخصي.
  Future<void> saveLanguage(String languageCode);

  /// يربط رمز FCM للجهاز الحالي بحساب المستخدم في `profiles.fcm_token`
  /// (يستهدفه تطبيق الإدارة بالإشعارات).
  ///
  /// يُمرَّر `null` عند تسجيل الخروج لتصفير الرمز حتى لا تصل إشعارات
  /// شخصية لشخص آخر يستخدم نفس الهاتف.
  Future<void> saveFcmToken(String? fcmToken);
}

/// نتيجة إنشاء الحساب: هل توجد جلسة جاهزة أم يلزم تأكيد الرقم؟
class SignUpResult {
  const SignUpResult({required this.user, required this.sessionReady});

  final CustomerUser user;

  /// `true` = المستخدم داخل التطبيق مباشرة، `false` = بريد/رقم غير مؤكد بعد.
  final bool sessionReady;
}
