// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ATOGA MARKET';

  @override
  String get homeTab => 'الرئيسية';

  @override
  String get tagline => 'تسوّق بسرعة وراحة';

  @override
  String get retry => 'حاول مجدداً';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get confirm => 'تأكيد';

  @override
  String get proceed => 'متابعة';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get done => 'تم';

  @override
  String get apply => 'تطبيق';

  @override
  String get add => 'إضافة';

  @override
  String get clear => 'مسح';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get optional => 'اختياري';

  @override
  String get required => 'مطلوب';

  @override
  String get search => 'بحث';

  @override
  String get quantity => 'الكمية';

  @override
  String get price => 'السعر';

  @override
  String get total => 'الإجمالي';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منتج',
      two: 'منتجان',
      one: 'منتج واحد',
      zero: 'لا توجد منتجات',
    );
    return '$_temp0';
  }

  @override
  String cartBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منتج',
      two: 'منتجان',
      one: 'منتج واحد',
      zero: 'لا شيء',
    );
    return '$_temp0';
  }

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitleEmail => 'أدخل بريدك الإلكتروني وكلمة المرور';

  @override
  String get loginSubtitlePhone => 'أدخل رقم هاتفك وكلمة المرور';

  @override
  String get phoneAuthHint => 'مثال: 0555123456 — يُنشأ حسابك وتدخل مباشرة';

  @override
  String get phoneExists =>
      'رقم الهاتف مسجّل مسبقاً. سجّل الدخول أو استخدم Google.';

  @override
  String get phoneConfirmNeeded =>
      'تم إنشاء الحساب. يجب تأكيد الرقم قبل الدخول (فعّل «تأكيد الهاتف تلقائياً» في Supabase).';

  @override
  String get phoneAuthDisabled =>
      'التسجيل برقم الهاتف غير مفعّل. فعّل Phone provider في Supabase أو سجّل عبر Google.';

  @override
  String get smsNotConfigured =>
      'خدمة رسائل SMS غير مهيأة. اربط مزوّد SMS في Supabase أو سجّل عبر Google.';

  @override
  String get autoconfirmRequired =>
      'تم إنشاء الحساب لكن لم تُفتح جلسة. فعّل التأكيد التلقائي للبريد في Supabase: Authentication > Email > Confirm email = OFF.';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get registerSubtitle => 'أنشئ حساباً للتسوق السريع';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get passwordTooShort => 'كلمة المرور يجب أن تكون 6 محارف على الأقل';

  @override
  String get emailInvalid => 'البريد الإلكتروني غير صحيح';

  @override
  String get emailExists => 'هذا البريد مسجّل مسبقاً';

  @override
  String get invalidCredentials => 'البريد أو كلمة المرور غير صحيحة';

  @override
  String get signUpFailed => 'تعذّر إنشاء الحساب';

  @override
  String get signUpDisabled =>
      'التسجيل معطّل حالياً. فعّل مزوّد الحساب في Supabase أو استخدم Google.';

  @override
  String get userBanned => 'هذا الحساب موقوف. تواصل مع الدعم.';

  @override
  String get sessionExpired => 'انتهت الجلسة، يرجى تسجيل الدخول من جديد';

  @override
  String get invalidInput => 'البيانات المُدخلة غير صحيحة';

  @override
  String get rlsDenied =>
      'صلاحيات غير كافية: لم يُمنح التطبيق صلاحية الكتابة على ملفك الشخصي';

  @override
  String get schemaMissing =>
      'قاعدة البيانات غير مهيأة. نفّذ supabase/schema.sql في Supabase.';

  @override
  String errorCodeLabel(String code) {
    return 'رمز الخطأ: $code';
  }

  @override
  String get tooManyAttemptsDetailed =>
      'تجاوزت حد إرسال رسائل البريد. انتظر قليلاً أو سجّل عبر Google.';

  @override
  String get verifyEmail => 'تحقق من بريدك الإلكتروني لتفعيل الحساب';

  @override
  String get accountCreated => 'تم إنشاء حسابك بنجاح';

  @override
  String get resetSent => 'أرسلنا رابط إعادة التعيين إلى بريدك';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get noAccount => 'ليس لديك حساب؟ أنشئ حساباً';

  @override
  String get emailFirst => 'أدخل بريدك الإلكتروني أولاً';

  @override
  String get phoneNumberOptional => 'رقم الهاتف (اختياري)';

  @override
  String get phoneOptionalHint => 'يُطلب إلزامياً عند إتمام أول طلب توصيل';

  @override
  String get phoneSaved => 'تم حفظ رقم الهاتف';

  @override
  String get notSet => 'غير محدد';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب لإتمام الطلب';

  @override
  String get phoneRequiredTitle => 'أضف رقم هاتفك';

  @override
  String get phoneRequiredBody =>
      'رقم الهاتف مطلوب للتواصل معك وتسليم الطلب. لن يُطلب مرة أخرى إلا إذا غيّرته.';

  @override
  String get phonePrivacyNote =>
      'يُستخدم رقمك للاتصال بالطلب فقط، ولا يُشارك مع جهات خارجية.';

  @override
  String get phoneSaveFailed => 'تعذّر حفظ الرقم، حاول مجدداً';

  @override
  String get saving => 'جارٍ الحفظ...';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneHint => '5X XX XX XX';

  @override
  String get tooManyAttempts => 'محاولات كثيرة. انتظر قليلاً ثم أعد المحاولة';

  @override
  String get orContinueWith => 'أو تابع باستخدام';

  @override
  String get continueWithGoogle => 'المتابعة بحساب Google';

  @override
  String get browseAsGuest => 'تصفح كزائر';

  @override
  String get browseAsGuestHint =>
      'يمكنك تصفح المنتجات بدون تسجيل، وسيُطلب منك الدخول عند إتمام الطلب';

  @override
  String get byContinuing => 'بمتابعتك أنت توافق على';

  @override
  String get termsOfService => 'شروط الاستخدام';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get loginRequiredTitle => 'تسجيل الدخول مطلوب';

  @override
  String get loginToViewProfile => 'يرجى تسجيل الدخول لعرض حسابك';

  @override
  String get loginRequiredBody =>
      'سجّل الدخول لتتمكن من إتمام طلبك. سلة التسوق محفوظة ولن تضيع.';

  @override
  String get searchHint => 'ابحث عن منتج...';

  @override
  String get promosTitle => 'عروض اليوم';

  @override
  String get categoriesTitle => 'التصنيفات';

  @override
  String get productsTitle => 'المنتجات';

  @override
  String get allCategories => 'الكل';

  @override
  String get categoryCanned => 'معلبات';

  @override
  String get categoryDrinks => 'مشروبات';

  @override
  String get categoryDairy => 'أجبان وألبان';

  @override
  String get categoryGrains => 'حبوب وعجائن';

  @override
  String get categorySnacks => 'حلويات';

  @override
  String get categoryCleaning => 'مواد التنظيف';

  @override
  String get noProducts => 'لا توجد منتجات';

  @override
  String get noProductsHint => 'جرّب تصنيفاً آخر أو كلمة بحث مختلفة';

  @override
  String get addToCart => 'أضف للسلة';

  @override
  String get addedToCart => 'تمت الإضافة إلى السلة';

  @override
  String get removeFromCart => 'إزالة من السلة';

  @override
  String get favoriteAdd => 'أضف إلى المفضلة';

  @override
  String get favoriteRemove => 'إزالة من المفضلة';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get favoritesEmpty => 'لا توجد منتجات مفضلة';

  @override
  String get favoritesEmptyHint => 'اضغط على القلب في أي منتج ليظهر هنا';

  @override
  String get decreaseQuantity => 'إنقاص الكمية';

  @override
  String get increaseQuantity => 'زيادة الكمية';

  @override
  String get unitCan => 'علبة';

  @override
  String get unitBottle => 'قنينة';

  @override
  String get unitPack => 'حزمة';

  @override
  String get unitJar => 'عبوة';

  @override
  String get unitFlask => 'زجاجة';

  @override
  String get unitBag => 'كيس';

  @override
  String get unitPiece => 'قطعة';

  @override
  String get searchNoResult => 'لا توجد نتائج لبحثك';

  @override
  String get searchNoResultHint => 'تحقق من كتابة الكلمة أو ابحث عن فئة أخرى';

  @override
  String get cartTitle => 'سلة التسوق';

  @override
  String get cartEmpty => 'سلتك فارغة حالياً';

  @override
  String get cartEmptyHint => 'ابدأ التسوق وأضف منتجاتك المفضلة';

  @override
  String get startShopping => 'ابدأ التسوق';

  @override
  String cartItemsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منتج',
      two: 'منتجان',
      one: 'منتج واحد',
      zero: 'لا توجد منتجات',
    );
    return '$_temp0';
  }

  @override
  String get subtotal => 'قيمة الطلبية';

  @override
  String get deliveryFee => 'تكلفة التوصيل';

  @override
  String get discount => 'الخصم';

  @override
  String get coupon => 'كوبون الخصم';

  @override
  String get couponHint => 'أدخل رمز الكوبون';

  @override
  String get couponApply => 'تطبيق';

  @override
  String get couponApplied => 'تم تطبيق الكوبون';

  @override
  String get couponInvalid => 'رمز الكوبون غير صالح';

  @override
  String get couponRemove => 'إزالة الكوبون';

  @override
  String couponDiscountValue(String value) {
    return 'خصم $value';
  }

  @override
  String get couponsTitle => 'الكوبونات';

  @override
  String get couponsEmpty => 'لا توجد كوبونات متاحة';

  @override
  String get couponsEmptyHint => 'عد لاحقاً — قد نضيف عروضاً جديدة';

  @override
  String get couponCopied => 'تم نسخ الكوبون بنجاح';

  @override
  String get copy => 'نسخ';

  @override
  String get proceedToCheckout => 'متابعة الشراء';

  @override
  String itemRemoved(String name) {
    return 'تم حذف $name';
  }

  @override
  String get undo => 'تراجع';

  @override
  String get swipeToDeleteHint => 'اسحب للحذف';

  @override
  String minimumOrder(String value) {
    return 'أقل قيمة للطلب $value';
  }

  @override
  String get freeDelivery => 'توصيل مجاني';

  @override
  String get checkoutTitle => 'إتمام الطلب';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get addNewAddress => 'إضافة عنوان جديد';

  @override
  String get editAddress => 'تعديل العنوان';

  @override
  String get street => 'الشارع';

  @override
  String get streetHint => 'اسم الشارع';

  @override
  String get building => 'العمارة / المنزل';

  @override
  String get buildingHint => 'رقم العمارة أو المنزل';

  @override
  String get apartment => 'الطابق / الشقة';

  @override
  String get apartmentHint => 'مثال: الطابق 3، شقة 12';

  @override
  String get notesForCourier => 'ملاحظات للمندوب';

  @override
  String get notesForCourierHint => 'مثال: اتصل قبل الوصول';

  @override
  String get contactPhone => 'رقم الهاتف للتواصل';

  @override
  String get pinLocation => 'حدد موقعك على الخريطة';

  @override
  String get pinLocationHint => 'اضغط على الخريطة لتحديد موقع التسليم';

  @override
  String get useCurrentLocation => 'استخدم موقعي الحالي';

  @override
  String get locating => 'جارٍ تحديد موقعك...';

  @override
  String get locationPermissionTitle => 'الوصول إلى الموقع';

  @override
  String get locationPermissionBody =>
      'نحتاج للوصول إلى موقعك لتوصيل طلبك بدقة إلى باب منزلك';

  @override
  String get locationPermissionDenied =>
      'تم رفض إذن الموقع. يمكنك تفعيله من إعدادات الهاتف.';

  @override
  String get locationPermissionDeniedForever =>
      'إذن الموقع مرفوض بشكل دائم. فعّله من إعدادات التطبيق.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get locationUnavailable =>
      'تعذّر تحديد موقعك، حدّده يدوياً على الخريطة';

  @override
  String get savedAddresses => 'العناوين المحفوظة';

  @override
  String get noSavedAddresses => 'لا توجد عناوين محفوظة';

  @override
  String get deleteAddress => 'حذف العنوان';

  @override
  String get deleteAddressConfirm => 'هل تريد حذف هذا العنوان؟';

  @override
  String get addressLabelHome => 'المنزل';

  @override
  String get addressLabelWork => 'العمل';

  @override
  String get addressLabelOther => 'أخرى';

  @override
  String get addressLabel => 'تسمية العنوان';

  @override
  String get selectAddress => 'اختر عنوان التوصيل';

  @override
  String get addressSaved => 'تم حفظ العنوان';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get phoneInvalidShort => 'أدخل رقم هاتف صحيح';

  @override
  String get locationRequired => 'حدد موقع التسليم على الخريطة';

  @override
  String get chooseAddressFirst => 'اختر عنوان التوصيل أولاً';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cashOnDelivery => 'الدفع عند الاستلام';

  @override
  String get cashOnDeliveryDesc => 'ادفع نقداً للمندوب عند وصول طلبك';

  @override
  String get paymentMethodFixed =>
      'طريقة الدفع الوحيدة المتاحة حالياً هي الدفع عند الاستلام';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get confirmOrder => 'تأكيد الطلب';

  @override
  String get sendingOrder => 'جارٍ إرسال الطلب...';

  @override
  String get orderPlaced => 'تم استلام طلبك!';

  @override
  String get orderPlacedBody =>
      'سيتواصل معك فريقنا لتأكيد الطلب. يمكنك متابعة حالته في أي وقت.';

  @override
  String get orderNumber => 'رقم الطلب';

  @override
  String get trackOrder => 'تتبع الطلب';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String get orderFailed => 'تعذّر إرسال الطلب';

  @override
  String get orderFailedBody => 'تحقق من اتصالك بالإنترنت وحاول مجدداً';

  @override
  String insufficientStock(String name) {
    return 'الكمية المتوفرة من $name غير كافية';
  }

  @override
  String get ordersTitle => 'طلباتي';

  @override
  String get activeOrders => 'طلبات جارية';

  @override
  String get pastOrders => 'طلبات سابقة';

  @override
  String get noOrders => 'لا توجد طلبات';

  @override
  String get noOrdersHint => 'طلباتك المستقبلية ستظهر هنا';

  @override
  String get trackingTitle => 'تتبع الطلب';

  @override
  String get statusReceived => 'تم الاستلام';

  @override
  String get statusPreparing => 'قيد التجهيز';

  @override
  String get statusOnTheWay => 'في طريق التوصيل';

  @override
  String get statusDelivered => 'تم التسليم';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get statusReceivedDesc => 'تم استلام طلبك بنجاح';

  @override
  String get statusPreparingDesc => 'فريقنا يجهّز طلبك الآن';

  @override
  String get statusOnTheWayDesc => 'المندوب في طريقه إليك';

  @override
  String get statusDeliveredDesc => 'تم تسليم الطلب. بالهناء والشفاء!';

  @override
  String get statusCancelledDesc => 'تم إلغاء هذا الطلب';

  @override
  String get courierInfo => 'المندوب';

  @override
  String get callCourier => 'اتصال';

  @override
  String get orderDate => 'تاريخ الطلب';

  @override
  String get orderTotal => 'إجمالي الطلب';

  @override
  String get reorder => 'إعادة الطلب';

  @override
  String get reordered => 'تمت إضافة منتجات الطلب إلى السلة';

  @override
  String get invoice => 'الفاتورة';

  @override
  String get cancelOrder => 'إلغاء الطلب';

  @override
  String get cancelOrderConfirm => 'هل تريد إلغاء هذا الطلب؟';

  @override
  String get orderCancelledToast => 'تم إلغاء الطلب';

  @override
  String get cancelOrderTooLate =>
      'عذراً، لا يمكن إلغاء الطلب بعد البدء في تجهيزه';

  @override
  String deliveredAt(String date) {
    return 'تم التسليم في $date';
  }

  @override
  String estimatedDelivery(String time) {
    return 'الوصول المتوقع: $time';
  }

  @override
  String get profileTitle => 'حسابي';

  @override
  String get personalInfo => 'البيانات الشخصية';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get name => 'الاسم الكامل';

  @override
  String get nameHint => 'أدخل اسمك';

  @override
  String get profileUpdated => 'تم تحديث البيانات';

  @override
  String get guestUser => 'زائر';

  @override
  String get loginToEditProfile => 'سجّل الدخول لتعديل بياناتك';

  @override
  String get addresses => 'عناوين التوصيل';

  @override
  String get language => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get support => 'الدعم الفني';

  @override
  String get settings => 'الإعدادات';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get socialLinks => 'التواصل الاجتماعي';

  @override
  String get facebook => 'فيسبوك';

  @override
  String get instagram => 'إنستغرام';

  @override
  String get tiktok => 'تيك توك';

  @override
  String get linkNotSet => 'الرابط غير متوفر حالياً';

  @override
  String get contactNotSet => 'رقم التواصل غير متوفر حالياً';

  @override
  String get deliveryZone => 'منطقة التوصيل';

  @override
  String get deliveryZonesEmpty => 'لا توجد مناطق توصيل متاحة حالياً';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String appVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل تريد تسجيل الخروج؟';

  @override
  String get deleteAccount => 'حذف الحساب نهائياً';

  @override
  String get deleteAccountWarning =>
      'سيتم حذف جميع بياناتك نهائياً ولا يمكن التراجع عن هذا الإجراء';

  @override
  String get deleteAccountConfirmTitle => 'تأكيد حذف الحساب';

  @override
  String get deleteAccountConfirmBody =>
      'سيتم حذف حسابك وطلباتك وعناوينك وكل بياناتك نهائياً. لا يمكن التراجع عن هذه العملية.';

  @override
  String get deleteAccountConfirmAction => 'نعم، احذف حسابي';

  @override
  String get accountDeleted => 'تم حذف حسابك بنجاح';

  @override
  String get deleteAccountFailed => 'تعذّر حذف الحساب، حاول مجدداً';

  @override
  String get supportUnavailable => 'تعذّر فتح الرابط، حاول لاحقاً';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get noInternetBody => 'تحقق من اتصالك ثم أعد المحاولة';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get dataLoadFailed => 'تعذّر تحميل البيانات';

  @override
  String get productsLoadFailed => 'تعذّر تحميل المنتجات';

  @override
  String get ordersLoadFailed => 'تعذّر تحميل الطلبات';

  @override
  String get guestCartNotice => 'أنت تتصفح كزائر. سجّل الدخول عند إتمام الطلب.';

  @override
  String get legalLastUpdated => 'آخر تحديث: أكتوبر 2026';

  @override
  String get privacyIntro =>
      'تسري هذه السياسة على تطبيق ATOGA MARKET، المتخصص في طلب وشراء مستلزمات السوبرماركت مع التوصيل داخل الجزائر. توضح هذه الوثيقة البيانات التي نجمعها، وكيفية استخدامها، وتدابير حمايتها، وما هي حقوقك. بإنشائك حساباً أو بإتمامك طلباً داخل التطبيق فإنك تُقرّ بقراءتك لهذه السياسة والموافقة عليها، ويسري أي تعديل منشور داخل التطبيق.';

  @override
  String get privacySecDataTitle => 'البيانات التي نجمعها';

  @override
  String get privacySecDataBody =>
      'نجمع الحد الأدنى الضروري لإتمام طلبك:\n• رقم هاتفك: وسيلة التواصل الأساسية لتأكيد الطلب والاتصال بك عند الحاجة.\n• اسمك وبيانات حسابك.\n• عنوان التوصيل الذي تُدخله: الشارع، العمارة، الطابق وملاحظات الوصول.\n• إحداثيات الموقع (خط الطول وخط العرض): فقط عندما تختار استخدام موقعك الحالي لتحديد العنوان على الخريطة، ويمكنك تحديد الموقع يدوياً دون منح هذا الإذن.\n• سجل طلباتك ومشترياتك: المنتجات، الكميات، الأسعار، رسوم التوصيل، تاريخ الطلب وحالته.\nلا نجمع ولا نُخزّن أي معلومة بطاقة بنكية، لأن الدفع عند الاستلام فقط.';

  @override
  String get privacySecUsageTitle => 'كيفية استخدام بياناتك';

  @override
  String get privacySecUsageBody =>
      'نستخدم بياناتك حصرياً من أجل: معالجة طلباتك وتحضيرها وتسليمها للمندوب المكلف بالتوصيل؛ التواصل معك هاتفياً لتأكيد الطلب أو عند وجود استفسار أو نقص في المنتجات؛ حساب تكلفة التوصيل ديناميكياً حسب منطقة أو حي التوصيل الذي تختاره؛ عرض سجل طلباتك داخل التطبيق؛ وتحسين أداء الخدمة والمتجر.\nلا نستخدم بياناتك لأغراض إعلانية، ولا نرسل رسائل تسويقية دون موافقتك.';

  @override
  String get privacySecSecurityTitle => 'أمان البيانات وتخزينها';

  @override
  String get privacySecSecurityBody =>
      'تُخزَّن بياناتك في قاعدة بيانات Supabase المحمية، وتُطبَّق عليها سياسات أمان على مستوى الصفوف (RLS) تضمن ألّا يطّلع مستخدم على بيانات مستخدم آخر، كما تُنقل البيانات عبر اتصال مشفّر (HTTPS).\nلا نبيع بياناتك الشخصية ولا نشاركها مع أي طرف ثالث خارج نطاق عملية التوصيل: يتلقى المندوب والمسؤول عن التوصيل ما يحتاجه فقط من بيانات (العنوان، رقم الهاتف، تفاصيل الطلب) لتنفيذ التسليم. وقد نفصح عن بياناتك إذا اقتضى ذلك قانون ساري المفعول في الجزائر.';

  @override
  String get privacySecRightsTitle => 'حقوقك';

  @override
  String get privacySecRightsBody =>
      'يمكنك في أي وقت: تعديل اسمك ورقم هاتفك من صفحة الحساب؛ إضافة عناوين توصيل أو تعديلها أو حذفها من شاشة العناوين؛ طلب حذف حسابك وبياناتك الشخصية نهائياً من زر «حذف الحساب» في صفحة الحساب، حيث يُمحى حسابك وطلباتك وعناوينك من قاعدة البيانات ومن نظام المصادقة دون إمكانية التراجع؛ وسحب موافقتك على الوصول إلى موقعك بإزالة إذن الموقع من إعدادات هاتفك.';

  @override
  String get privacySecContactTitle => 'التواصل معنا';

  @override
  String get privacySecContactBody =>
      'لأي استفسار بخصوص خصوصية بياناتك أو لممارسة أي من الحقوق الواردة أعلاه، تواصل معنا عبر قسم «الدعم الفني» داخل التطبيق (الهاتف أو واتساب)، وسنعالج طلبك في أقرب وقت ممكن.';

  @override
  String get termsIntro =>
      'تنظّم هذه الشروط العلاقة بينك وبين ATOGA MARKET عند استخدامك لتطبيق الطلب والتوصيل. بإنشائك حساباً أو بإتمامك طلباً داخل التطبيق فإنك تُقرّ بقبولك لهذه الشروط كاملة، وإذا كنت لا توافق على أي بند منها يُرجى عدم استخدام التطبيق.';

  @override
  String get termsSecAccountTitle => 'إنشاء الحساب والمسؤولية';

  @override
  String get termsSecAccountBody =>
      'يلزمك لإنشاء حساب تقديم بيانات صحيحة ورقم هاتف فعّال قادر على استقبال المكالمات، لأن الاتصال بك شرط لتأكيد الطلب وتسليمه. أنت مسؤول عن الحفاظ على سرية بيانات دخولك وعن كل طلب يُجرى عبر حسابك، ويحتفظ المتجر بحق تعليق الحساب مؤقتاً أو إيقافه عند إساءة الاستخدام أو تقديم بيانات غير صحيحة أو مكرّرة.';

  @override
  String get termsSecPricingTitle => 'الأسعار وتكلفة التوصيل';

  @override
  String get termsSecPricingBody =>
      'تُعرض الأسعار بالدينار الجزائري، وقد تتغير دون إشعار مسبق، ويُعتمد السعر الساري وقت تأكيد الطلب. تُحسب تكلفة التوصيل ديناميكياً حسب منطقة أو حي التوصيل المختار وتُضاف إلى إجمالي الطلب قبل الدفع، وقد تُلغى بالكامل عند بلوغ إجمالي الطلب للحد المعلن للتوصيل المجاني داخل التطبيق. كما يمكن تطبيق كوبونات خصم سارية المفعول على الإجمالي.';

  @override
  String get termsSecPaymentTitle => 'طريقة الدفع';

  @override
  String get termsSecPaymentBody =>
      'الطريقة المعتمدة حالياً هي الدفع عند الاستلام (Cash on Delivery) نقداً بالدينار الجزائري، ويلتزم الزبون بتسليم كامل المبلغ المبيّن في الفاتورة للمندوب عند استلام الطلب. لا يطلب التطبيق أي معلومة بطاقة بنكية ولا أي دفع إلكتروني مسبق، ولا يُطلب أي مبلغ قبل تسليم الطلب فعلياً.';

  @override
  String get termsSecCancellationTitle => 'إلغاء الطلب وتعديله';

  @override
  String get termsSecCancellationBody =>
      'يمكنك تعديل طلبك أو إلغاؤه مجاناً قبل خروجه للتوصيل عبر التواصل مع قسم الدعم. ويحتفظ المتجر بحق إلغاء الطلب في الحالات التالية: تعذّر التواصل معك عبر الهاتف قبل التأكيد أو أثناء التحضير؛ إدخال عنوان أو رقم هاتف غير صحيح أو غير مكتمل؛ عدم توفر بعض المنتجات ورفضك البدائل؛ أو وقوع خطأ جوهري في الأسعار أو في بيانات الطلب. ونُعلمك بسبب الإلغاء في كل الأحوال.';

  @override
  String get termsSecChangesTitle => 'تعديل الشروط';

  @override
  String get termsSecChangesBody =>
      'يحق لـ ATOGA MARKET تحديث هذه الشروط عند تغيّر الخدمات أو الأنظمة المعمول بها، ويسري التعديل فور نشره داخل التطبيق، واستمرارك في استخدام التطبيق بعد النشر يعني قبولك للشروط المحدّثة.';

  @override
  String get termsSecLawTitle => 'القانون المطبق';

  @override
  String get termsSecLawBody =>
      'تخضع هذه الشروط لأنظمة الجمهورية الجزائرية الديمقراطية الشعبية، ولا سيما ما يتعلق بالتجارة الإلكترونية وحماية المستهلك والحقوق المعنية، ويُحاول حل أي نزاع أولاً ودياً عبر قسم الدعم داخل التطبيق مع الإبقاء على حقك في التظلم لدى الجهات المختصة.';

  @override
  String get walletTitle => 'المحفظة';

  @override
  String get walletBalance => 'الرصيد الحالي';

  @override
  String get walletTopUpHint =>
      'لشحن رصيدك، يرجى زيارة متجرنا وإيداع المبلغ نقداً ليتم إضافته إلى حسابك.';

  @override
  String get walletHistoryTitle => 'سجل العمليات';

  @override
  String get walletNoTransactions => 'لا توجد حركات بعد';

  @override
  String get walletDepositTitle => 'شحن رصيد من الإدارة';

  @override
  String walletPaymentTitle(String orderId) {
    return 'دفع للطلب رقم: #$orderId';
  }

  @override
  String get walletInsufficient =>
      'عذراً، رصيد محفظتك غير كافٍ. تم التحويل إلى الدفع عند الاستلام.';

  @override
  String get payWithWallet => 'الدفع من المحفظة';

  @override
  String get rememberPassword => 'حفظ كلمة المرور';

  @override
  String get rememberPasswordHint =>
      'تُخزَّن مشفّرة على جهازك فقط؛ لن يُطلب منك إدخالها في كل مرة.';

  @override
  String get appDeveloperTitle => 'مبرمج التطبيق';

  @override
  String get appDeveloperMarketing =>
      'تم برمجة هذا التطبيق بواسطة DIRAYA LAB. لطلب تطبيقك الخاص، يمكنك التواصل معنا عبر الإيميل التالي:';

  @override
  String get appDeveloperEmailCopied => 'تم نسخ البريد الإلكتروني بنجاح';

  @override
  String get storeOpenStatus => 'المتجر مفتوح حالياً — يمكنك الطلب';

  @override
  String get storeClosedStatus => 'المتجر مغلق حالياً';

  @override
  String get walletUserId => 'معرّف المستخدم (لشحن الرصيد من المتجر)';

  @override
  String get walletUserIdCopied => 'تم نسخ معرّف المستخدم بنجاح';

  @override
  String get storeClosedAddToCart =>
      'المتجر مغلق حالياً — لا يمكن إضافة المنتجات إلى السلة';
}
