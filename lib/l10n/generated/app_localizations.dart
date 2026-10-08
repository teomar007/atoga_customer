import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'ATOGA MARKET'**
  String get appName;

  /// No description provided for @homeTab.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get homeTab;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'تسوّق بسرعة وراحة'**
  String get tagline;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'حاول مجدداً'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @proceed.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get proceed;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @apply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get apply;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @clear.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clear;

  /// No description provided for @seeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get seeAll;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get loading;

  /// No description provided for @optional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get required;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @quantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantity;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @itemsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد منتجات} =1{منتج واحد} =2{منتجان} other{منتج}}'**
  String itemsCount(int count);

  /// No description provided for @cartBadge.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا شيء} =1{منتج واحد} =2{منتجان} other{منتج}}'**
  String cartBadge(int count);

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginTitle;

  /// No description provided for @loginSubtitleEmail.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني وكلمة المرور'**
  String get loginSubtitleEmail;

  /// No description provided for @loginSubtitlePhone.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك وكلمة المرور'**
  String get loginSubtitlePhone;

  /// No description provided for @phoneAuthHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 0555123456 — يُنشأ حسابك وتدخل مباشرة'**
  String get phoneAuthHint;

  /// No description provided for @phoneExists.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف مسجّل مسبقاً. سجّل الدخول أو استخدم Google.'**
  String get phoneExists;

  /// No description provided for @phoneConfirmNeeded.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحساب. يجب تأكيد الرقم قبل الدخول (فعّل «تأكيد الهاتف تلقائياً» في Supabase).'**
  String get phoneConfirmNeeded;

  /// No description provided for @phoneAuthDisabled.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل برقم الهاتف غير مفعّل. فعّل Phone provider في Supabase أو سجّل عبر Google.'**
  String get phoneAuthDisabled;

  /// No description provided for @smsNotConfigured.
  ///
  /// In ar, this message translates to:
  /// **'خدمة رسائل SMS غير مهيأة. اربط مزوّد SMS في Supabase أو سجّل عبر Google.'**
  String get smsNotConfigured;

  /// No description provided for @autoconfirmRequired.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحساب لكن لم تُفتح جلسة. فعّل التأكيد التلقائي للبريد في Supabase: Authentication > Email > Confirm email = OFF.'**
  String get autoconfirmRequired;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get createAccount;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @registerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حساباً للتسوق السريع'**
  String get registerSubtitle;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get passwordMismatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 6 محارف على الأقل'**
  String get passwordTooShort;

  /// No description provided for @emailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صحيح'**
  String get emailInvalid;

  /// No description provided for @emailExists.
  ///
  /// In ar, this message translates to:
  /// **'هذا البريد مسجّل مسبقاً'**
  String get emailExists;

  /// No description provided for @invalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'البريد أو كلمة المرور غير صحيحة'**
  String get invalidCredentials;

  /// No description provided for @signUpFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إنشاء الحساب'**
  String get signUpFailed;

  /// No description provided for @signUpDisabled.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل معطّل حالياً. فعّل مزوّد الحساب في Supabase أو استخدم Google.'**
  String get signUpDisabled;

  /// No description provided for @userBanned.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحساب موقوف. تواصل مع الدعم.'**
  String get userBanned;

  /// No description provided for @sessionExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة، يرجى تسجيل الدخول من جديد'**
  String get sessionExpired;

  /// No description provided for @invalidInput.
  ///
  /// In ar, this message translates to:
  /// **'البيانات المُدخلة غير صحيحة'**
  String get invalidInput;

  /// No description provided for @rlsDenied.
  ///
  /// In ar, this message translates to:
  /// **'صلاحيات غير كافية: لم يُمنح التطبيق صلاحية الكتابة على ملفك الشخصي'**
  String get rlsDenied;

  /// No description provided for @schemaMissing.
  ///
  /// In ar, this message translates to:
  /// **'قاعدة البيانات غير مهيأة. نفّذ supabase/schema.sql في Supabase.'**
  String get schemaMissing;

  /// No description provided for @errorCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'رمز الخطأ: {code}'**
  String errorCodeLabel(String code);

  /// No description provided for @tooManyAttemptsDetailed.
  ///
  /// In ar, this message translates to:
  /// **'تجاوزت حد إرسال رسائل البريد. انتظر قليلاً أو سجّل عبر Google.'**
  String get tooManyAttemptsDetailed;

  /// No description provided for @verifyEmail.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من بريدك الإلكتروني لتفعيل الحساب'**
  String get verifyEmail;

  /// No description provided for @accountCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء حسابك بنجاح'**
  String get accountCreated;

  /// No description provided for @resetSent.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رابط إعادة التعيين إلى بريدك'**
  String get resetSent;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @haveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟ سجّل الدخول'**
  String get haveAccount;

  /// No description provided for @noAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟ أنشئ حساباً'**
  String get noAccount;

  /// No description provided for @emailFirst.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني أولاً'**
  String get emailFirst;

  /// No description provided for @phoneNumberOptional.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف (اختياري)'**
  String get phoneNumberOptional;

  /// No description provided for @phoneOptionalHint.
  ///
  /// In ar, this message translates to:
  /// **'يُطلب إلزامياً عند إتمام أول طلب توصيل'**
  String get phoneOptionalHint;

  /// No description provided for @phoneSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ رقم الهاتف'**
  String get phoneSaved;

  /// No description provided for @notSet.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get notSet;

  /// No description provided for @phoneRequired.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف مطلوب لإتمام الطلب'**
  String get phoneRequired;

  /// No description provided for @phoneRequiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف رقم هاتفك'**
  String get phoneRequiredTitle;

  /// No description provided for @phoneRequiredBody.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف مطلوب للتواصل معك وتسليم الطلب. لن يُطلب مرة أخرى إلا إذا غيّرته.'**
  String get phoneRequiredBody;

  /// No description provided for @phonePrivacyNote.
  ///
  /// In ar, this message translates to:
  /// **'يُستخدم رقمك للاتصال بالطلب فقط، ولا يُشارك مع جهات خارجية.'**
  String get phonePrivacyNote;

  /// No description provided for @phoneSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ الرقم، حاول مجدداً'**
  String get phoneSaveFailed;

  /// No description provided for @saving.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الحفظ...'**
  String get saving;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In ar, this message translates to:
  /// **'5X XX XX XX'**
  String get phoneHint;

  /// No description provided for @tooManyAttempts.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كثيرة. انتظر قليلاً ثم أعد المحاولة'**
  String get tooManyAttempts;

  /// No description provided for @orContinueWith.
  ///
  /// In ar, this message translates to:
  /// **'أو تابع باستخدام'**
  String get orContinueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In ar, this message translates to:
  /// **'المتابعة بحساب Google'**
  String get continueWithGoogle;

  /// No description provided for @browseAsGuest.
  ///
  /// In ar, this message translates to:
  /// **'تصفح كزائر'**
  String get browseAsGuest;

  /// No description provided for @browseAsGuestHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تصفح المنتجات بدون تسجيل، وسيُطلب منك الدخول عند إتمام الطلب'**
  String get browseAsGuestHint;

  /// No description provided for @byContinuing.
  ///
  /// In ar, this message translates to:
  /// **'بمتابعتك أنت توافق على'**
  String get byContinuing;

  /// No description provided for @termsOfService.
  ///
  /// In ar, this message translates to:
  /// **'شروط الاستخدام'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @loginRequiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول مطلوب'**
  String get loginRequiredTitle;

  /// No description provided for @loginToViewProfile.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تسجيل الدخول لعرض حسابك'**
  String get loginToViewProfile;

  /// No description provided for @loginRequiredBody.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لتتمكن من إتمام طلبك. سلة التسوق محفوظة ولن تضيع.'**
  String get loginRequiredBody;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن منتج...'**
  String get searchHint;

  /// No description provided for @promosTitle.
  ///
  /// In ar, this message translates to:
  /// **'عروض اليوم'**
  String get promosTitle;

  /// No description provided for @categoriesTitle.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات'**
  String get categoriesTitle;

  /// No description provided for @productsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get productsTitle;

  /// No description provided for @allCategories.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allCategories;

  /// No description provided for @categoryCanned.
  ///
  /// In ar, this message translates to:
  /// **'معلبات'**
  String get categoryCanned;

  /// No description provided for @categoryDrinks.
  ///
  /// In ar, this message translates to:
  /// **'مشروبات'**
  String get categoryDrinks;

  /// No description provided for @categoryDairy.
  ///
  /// In ar, this message translates to:
  /// **'أجبان وألبان'**
  String get categoryDairy;

  /// No description provided for @categoryGrains.
  ///
  /// In ar, this message translates to:
  /// **'حبوب وعجائن'**
  String get categoryGrains;

  /// No description provided for @categorySnacks.
  ///
  /// In ar, this message translates to:
  /// **'حلويات'**
  String get categorySnacks;

  /// No description provided for @categoryCleaning.
  ///
  /// In ar, this message translates to:
  /// **'مواد التنظيف'**
  String get categoryCleaning;

  /// No description provided for @noProducts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات'**
  String get noProducts;

  /// No description provided for @noProductsHint.
  ///
  /// In ar, this message translates to:
  /// **'جرّب تصنيفاً آخر أو كلمة بحث مختلفة'**
  String get noProductsHint;

  /// No description provided for @addToCart.
  ///
  /// In ar, this message translates to:
  /// **'أضف للسلة'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In ar, this message translates to:
  /// **'تمت الإضافة إلى السلة'**
  String get addedToCart;

  /// No description provided for @removeFromCart.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من السلة'**
  String get removeFromCart;

  /// No description provided for @favoriteAdd.
  ///
  /// In ar, this message translates to:
  /// **'أضف إلى المفضلة'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المفضلة'**
  String get favoriteRemove;

  /// No description provided for @favoritesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات مفضلة'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على القلب في أي منتج ليظهر هنا'**
  String get favoritesEmptyHint;

  /// No description provided for @decreaseQuantity.
  ///
  /// In ar, this message translates to:
  /// **'إنقاص الكمية'**
  String get decreaseQuantity;

  /// No description provided for @increaseQuantity.
  ///
  /// In ar, this message translates to:
  /// **'زيادة الكمية'**
  String get increaseQuantity;

  /// No description provided for @unitCan.
  ///
  /// In ar, this message translates to:
  /// **'علبة'**
  String get unitCan;

  /// No description provided for @unitBottle.
  ///
  /// In ar, this message translates to:
  /// **'قنينة'**
  String get unitBottle;

  /// No description provided for @unitPack.
  ///
  /// In ar, this message translates to:
  /// **'حزمة'**
  String get unitPack;

  /// No description provided for @unitJar.
  ///
  /// In ar, this message translates to:
  /// **'عبوة'**
  String get unitJar;

  /// No description provided for @unitFlask.
  ///
  /// In ar, this message translates to:
  /// **'زجاجة'**
  String get unitFlask;

  /// No description provided for @unitBag.
  ///
  /// In ar, this message translates to:
  /// **'كيس'**
  String get unitBag;

  /// No description provided for @unitPiece.
  ///
  /// In ar, this message translates to:
  /// **'قطعة'**
  String get unitPiece;

  /// No description provided for @searchNoResult.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج لبحثك'**
  String get searchNoResult;

  /// No description provided for @searchNoResultHint.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من كتابة الكلمة أو ابحث عن فئة أخرى'**
  String get searchNoResultHint;

  /// No description provided for @cartTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلة التسوق'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In ar, this message translates to:
  /// **'سلتك فارغة حالياً'**
  String get cartEmpty;

  /// No description provided for @cartEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التسوق وأضف منتجاتك المفضلة'**
  String get cartEmptyHint;

  /// No description provided for @startShopping.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التسوق'**
  String get startShopping;

  /// No description provided for @cartItemsLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد منتجات} =1{منتج واحد} =2{منتجان} other{منتج}}'**
  String cartItemsLabel(int count);

  /// No description provided for @subtotal.
  ///
  /// In ar, this message translates to:
  /// **'قيمة الطلبية'**
  String get subtotal;

  /// No description provided for @deliveryFee.
  ///
  /// In ar, this message translates to:
  /// **'تكلفة التوصيل'**
  String get deliveryFee;

  /// No description provided for @discount.
  ///
  /// In ar, this message translates to:
  /// **'الخصم'**
  String get discount;

  /// No description provided for @coupon.
  ///
  /// In ar, this message translates to:
  /// **'كوبون الخصم'**
  String get coupon;

  /// No description provided for @couponHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز الكوبون'**
  String get couponHint;

  /// No description provided for @couponApply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get couponApply;

  /// No description provided for @couponApplied.
  ///
  /// In ar, this message translates to:
  /// **'تم تطبيق الكوبون'**
  String get couponApplied;

  /// No description provided for @couponInvalid.
  ///
  /// In ar, this message translates to:
  /// **'رمز الكوبون غير صالح'**
  String get couponInvalid;

  /// No description provided for @couponRemove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الكوبون'**
  String get couponRemove;

  /// No description provided for @couponDiscountValue.
  ///
  /// In ar, this message translates to:
  /// **'خصم {value}'**
  String couponDiscountValue(String value);

  /// No description provided for @couponsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الكوبونات'**
  String get couponsTitle;

  /// No description provided for @couponsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد كوبونات متاحة'**
  String get couponsEmpty;

  /// No description provided for @couponsEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'عد لاحقاً — قد نضيف عروضاً جديدة'**
  String get couponsEmptyHint;

  /// No description provided for @couponCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ الكوبون بنجاح'**
  String get couponCopied;

  /// No description provided for @copy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copy;

  /// No description provided for @proceedToCheckout.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الشراء'**
  String get proceedToCheckout;

  /// No description provided for @itemRemoved.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف {name}'**
  String itemRemoved(String name);

  /// No description provided for @undo.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get undo;

  /// No description provided for @swipeToDeleteHint.
  ///
  /// In ar, this message translates to:
  /// **'اسحب للحذف'**
  String get swipeToDeleteHint;

  /// No description provided for @minimumOrder.
  ///
  /// In ar, this message translates to:
  /// **'أقل قيمة للطلب {value}'**
  String minimumOrder(String value);

  /// No description provided for @freeDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل مجاني'**
  String get freeDelivery;

  /// No description provided for @checkoutTitle.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الطلب'**
  String get checkoutTitle;

  /// No description provided for @deliveryAddress.
  ///
  /// In ar, this message translates to:
  /// **'عنوان التوصيل'**
  String get deliveryAddress;

  /// No description provided for @addNewAddress.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عنوان جديد'**
  String get addNewAddress;

  /// No description provided for @editAddress.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العنوان'**
  String get editAddress;

  /// No description provided for @street.
  ///
  /// In ar, this message translates to:
  /// **'الشارع'**
  String get street;

  /// No description provided for @streetHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم الشارع'**
  String get streetHint;

  /// No description provided for @building.
  ///
  /// In ar, this message translates to:
  /// **'العمارة / المنزل'**
  String get building;

  /// No description provided for @buildingHint.
  ///
  /// In ar, this message translates to:
  /// **'رقم العمارة أو المنزل'**
  String get buildingHint;

  /// No description provided for @apartment.
  ///
  /// In ar, this message translates to:
  /// **'الطابق / الشقة'**
  String get apartment;

  /// No description provided for @apartmentHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: الطابق 3، شقة 12'**
  String get apartmentHint;

  /// No description provided for @notesForCourier.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات للمندوب'**
  String get notesForCourier;

  /// No description provided for @notesForCourierHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: اتصل قبل الوصول'**
  String get notesForCourierHint;

  /// No description provided for @contactPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف للتواصل'**
  String get contactPhone;

  /// No description provided for @pinLocation.
  ///
  /// In ar, this message translates to:
  /// **'حدد موقعك على الخريطة'**
  String get pinLocation;

  /// No description provided for @pinLocationHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على الخريطة لتحديد موقع التسليم'**
  String get pinLocationHint;

  /// No description provided for @useCurrentLocation.
  ///
  /// In ar, this message translates to:
  /// **'استخدم موقعي الحالي'**
  String get useCurrentLocation;

  /// No description provided for @locating.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحديد موقعك...'**
  String get locating;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In ar, this message translates to:
  /// **'الوصول إلى الموقع'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionBody.
  ///
  /// In ar, this message translates to:
  /// **'نحتاج للوصول إلى موقعك لتوصيل طلبك بدقة إلى باب منزلك'**
  String get locationPermissionBody;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الموقع. يمكنك تفعيله من إعدادات الهاتف.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In ar, this message translates to:
  /// **'إذن الموقع مرفوض بشكل دائم. فعّله من إعدادات التطبيق.'**
  String get locationPermissionDeniedForever;

  /// No description provided for @openSettings.
  ///
  /// In ar, this message translates to:
  /// **'فتح الإعدادات'**
  String get openSettings;

  /// No description provided for @locationUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديد موقعك، حدّده يدوياً على الخريطة'**
  String get locationUnavailable;

  /// No description provided for @savedAddresses.
  ///
  /// In ar, this message translates to:
  /// **'العناوين المحفوظة'**
  String get savedAddresses;

  /// No description provided for @noSavedAddresses.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناوين محفوظة'**
  String get noSavedAddresses;

  /// No description provided for @deleteAddress.
  ///
  /// In ar, this message translates to:
  /// **'حذف العنوان'**
  String get deleteAddress;

  /// No description provided for @deleteAddressConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذا العنوان؟'**
  String get deleteAddressConfirm;

  /// No description provided for @addressLabelHome.
  ///
  /// In ar, this message translates to:
  /// **'المنزل'**
  String get addressLabelHome;

  /// No description provided for @addressLabelWork.
  ///
  /// In ar, this message translates to:
  /// **'العمل'**
  String get addressLabelWork;

  /// No description provided for @addressLabelOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get addressLabelOther;

  /// No description provided for @addressLabel.
  ///
  /// In ar, this message translates to:
  /// **'تسمية العنوان'**
  String get addressLabel;

  /// No description provided for @selectAddress.
  ///
  /// In ar, this message translates to:
  /// **'اختر عنوان التوصيل'**
  String get selectAddress;

  /// No description provided for @addressSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ العنوان'**
  String get addressSaved;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @phoneInvalidShort.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتف صحيح'**
  String get phoneInvalidShort;

  /// No description provided for @locationRequired.
  ///
  /// In ar, this message translates to:
  /// **'حدد موقع التسليم على الخريطة'**
  String get locationRequired;

  /// No description provided for @chooseAddressFirst.
  ///
  /// In ar, this message translates to:
  /// **'اختر عنوان التوصيل أولاً'**
  String get chooseAddressFirst;

  /// No description provided for @paymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethod;

  /// No description provided for @cashOnDelivery.
  ///
  /// In ar, this message translates to:
  /// **'الدفع عند الاستلام'**
  String get cashOnDelivery;

  /// No description provided for @cashOnDeliveryDesc.
  ///
  /// In ar, this message translates to:
  /// **'ادفع نقداً للمندوب عند وصول طلبك'**
  String get cashOnDeliveryDesc;

  /// No description provided for @paymentMethodFixed.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع الوحيدة المتاحة حالياً هي الدفع عند الاستلام'**
  String get paymentMethodFixed;

  /// No description provided for @orderSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الطلب'**
  String get orderSummary;

  /// No description provided for @confirmOrder.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الطلب'**
  String get confirmOrder;

  /// No description provided for @sendingOrder.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ إرسال الطلب...'**
  String get sendingOrder;

  /// No description provided for @orderPlaced.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام طلبك!'**
  String get orderPlaced;

  /// No description provided for @orderPlacedBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتواصل معك فريقنا لتأكيد الطلب. يمكنك متابعة حالته في أي وقت.'**
  String get orderPlacedBody;

  /// No description provided for @orderNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get orderNumber;

  /// No description provided for @trackOrder.
  ///
  /// In ar, this message translates to:
  /// **'تتبع الطلب'**
  String get trackOrder;

  /// No description provided for @backToHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة للرئيسية'**
  String get backToHome;

  /// No description provided for @orderFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إرسال الطلب'**
  String get orderFailed;

  /// No description provided for @orderFailedBody.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصالك بالإنترنت وحاول مجدداً'**
  String get orderFailedBody;

  /// No description provided for @insufficientStock.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المتوفرة من {name} غير كافية'**
  String insufficientStock(String name);

  /// No description provided for @ordersTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get ordersTitle;

  /// No description provided for @activeOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات جارية'**
  String get activeOrders;

  /// No description provided for @pastOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات سابقة'**
  String get pastOrders;

  /// No description provided for @noOrders.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات'**
  String get noOrders;

  /// No description provided for @noOrdersHint.
  ///
  /// In ar, this message translates to:
  /// **'طلباتك المستقبلية ستظهر هنا'**
  String get noOrdersHint;

  /// No description provided for @trackingTitle.
  ///
  /// In ar, this message translates to:
  /// **'تتبع الطلب'**
  String get trackingTitle;

  /// No description provided for @statusReceived.
  ///
  /// In ar, this message translates to:
  /// **'تم الاستلام'**
  String get statusReceived;

  /// No description provided for @statusPreparing.
  ///
  /// In ar, this message translates to:
  /// **'قيد التجهيز'**
  String get statusPreparing;

  /// No description provided for @statusOnTheWay.
  ///
  /// In ar, this message translates to:
  /// **'في طريق التوصيل'**
  String get statusOnTheWay;

  /// No description provided for @statusDelivered.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغى'**
  String get statusCancelled;

  /// No description provided for @statusReceivedDesc.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام طلبك بنجاح'**
  String get statusReceivedDesc;

  /// No description provided for @statusPreparingDesc.
  ///
  /// In ar, this message translates to:
  /// **'فريقنا يجهّز طلبك الآن'**
  String get statusPreparingDesc;

  /// No description provided for @statusOnTheWayDesc.
  ///
  /// In ar, this message translates to:
  /// **'المندوب في طريقه إليك'**
  String get statusOnTheWayDesc;

  /// No description provided for @statusDeliveredDesc.
  ///
  /// In ar, this message translates to:
  /// **'تم تسليم الطلب. بالهناء والشفاء!'**
  String get statusDeliveredDesc;

  /// No description provided for @statusCancelledDesc.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء هذا الطلب'**
  String get statusCancelledDesc;

  /// No description provided for @courierInfo.
  ///
  /// In ar, this message translates to:
  /// **'المندوب'**
  String get courierInfo;

  /// No description provided for @callCourier.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get callCourier;

  /// No description provided for @orderDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الطلب'**
  String get orderDate;

  /// No description provided for @orderTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلب'**
  String get orderTotal;

  /// No description provided for @reorder.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الطلب'**
  String get reorder;

  /// No description provided for @reordered.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة منتجات الطلب إلى السلة'**
  String get reordered;

  /// No description provided for @invoice.
  ///
  /// In ar, this message translates to:
  /// **'الفاتورة'**
  String get invoice;

  /// No description provided for @cancelOrder.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get cancelOrder;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء هذا الطلب؟'**
  String get cancelOrderConfirm;

  /// No description provided for @orderCancelledToast.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الطلب'**
  String get orderCancelledToast;

  /// No description provided for @cancelOrderTooLate.
  ///
  /// In ar, this message translates to:
  /// **'عذراً، لا يمكن إلغاء الطلب بعد البدء في تجهيزه'**
  String get cancelOrderTooLate;

  /// No description provided for @deliveredAt.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم في {date}'**
  String deliveredAt(String date);

  /// No description provided for @estimatedDelivery.
  ///
  /// In ar, this message translates to:
  /// **'الوصول المتوقع: {time}'**
  String estimatedDelivery(String time);

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get profileTitle;

  /// No description provided for @personalInfo.
  ///
  /// In ar, this message translates to:
  /// **'البيانات الشخصية'**
  String get personalInfo;

  /// No description provided for @editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfile;

  /// No description provided for @name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك'**
  String get nameHint;

  /// No description provided for @profileUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث البيانات'**
  String get profileUpdated;

  /// No description provided for @guestUser.
  ///
  /// In ar, this message translates to:
  /// **'زائر'**
  String get guestUser;

  /// No description provided for @loginToEditProfile.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لتعديل بياناتك'**
  String get loginToEditProfile;

  /// No description provided for @addresses.
  ///
  /// In ar, this message translates to:
  /// **'عناوين التوصيل'**
  String get addresses;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageFrench.
  ///
  /// In ar, this message translates to:
  /// **'الفرنسية'**
  String get languageFrench;

  /// No description provided for @support.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني'**
  String get support;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بنا'**
  String get contactUs;

  /// No description provided for @whatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsapp;

  /// No description provided for @faq.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة'**
  String get faq;

  /// No description provided for @socialLinks.
  ///
  /// In ar, this message translates to:
  /// **'التواصل الاجتماعي'**
  String get socialLinks;

  /// No description provided for @facebook.
  ///
  /// In ar, this message translates to:
  /// **'فيسبوك'**
  String get facebook;

  /// No description provided for @instagram.
  ///
  /// In ar, this message translates to:
  /// **'إنستغرام'**
  String get instagram;

  /// No description provided for @tiktok.
  ///
  /// In ar, this message translates to:
  /// **'تيك توك'**
  String get tiktok;

  /// No description provided for @linkNotSet.
  ///
  /// In ar, this message translates to:
  /// **'الرابط غير متوفر حالياً'**
  String get linkNotSet;

  /// No description provided for @contactNotSet.
  ///
  /// In ar, this message translates to:
  /// **'رقم التواصل غير متوفر حالياً'**
  String get contactNotSet;

  /// No description provided for @deliveryZone.
  ///
  /// In ar, this message translates to:
  /// **'منطقة التوصيل'**
  String get deliveryZone;

  /// No description provided for @deliveryZonesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مناطق توصيل متاحة حالياً'**
  String get deliveryZonesEmpty;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @appVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String appVersion(String version);

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج؟'**
  String get logoutConfirm;

  /// No description provided for @deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب نهائياً'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف جميع بياناتك نهائياً ولا يمكن التراجع عن هذا الإجراء'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد حذف الحساب'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف حسابك وطلباتك وعناوينك وكل بياناتك نهائياً. لا يمكن التراجع عن هذه العملية.'**
  String get deleteAccountConfirmBody;

  /// No description provided for @deleteAccountConfirmAction.
  ///
  /// In ar, this message translates to:
  /// **'نعم، احذف حسابي'**
  String get deleteAccountConfirmAction;

  /// No description provided for @accountDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف حسابك بنجاح'**
  String get accountDeleted;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حذف الحساب، حاول مجدداً'**
  String get deleteAccountFailed;

  /// No description provided for @supportUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح الرابط، حاول لاحقاً'**
  String get supportUnavailable;

  /// No description provided for @noInternet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get noInternet;

  /// No description provided for @noInternetBody.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصالك ثم أعد المحاولة'**
  String get noInternetBody;

  /// No description provided for @somethingWentWrong.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما'**
  String get somethingWentWrong;

  /// No description provided for @dataLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل البيانات'**
  String get dataLoadFailed;

  /// No description provided for @productsLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل المنتجات'**
  String get productsLoadFailed;

  /// No description provided for @ordersLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الطلبات'**
  String get ordersLoadFailed;

  /// No description provided for @guestCartNotice.
  ///
  /// In ar, this message translates to:
  /// **'أنت تتصفح كزائر. سجّل الدخول عند إتمام الطلب.'**
  String get guestCartNotice;

  /// No description provided for @legalLastUpdated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: أكتوبر 2026'**
  String get legalLastUpdated;

  /// No description provided for @privacyIntro.
  ///
  /// In ar, this message translates to:
  /// **'تسري هذه السياسة على تطبيق ATOGA MARKET، المتخصص في طلب وشراء مستلزمات السوبرماركت مع التوصيل داخل الجزائر. توضح هذه الوثيقة البيانات التي نجمعها، وكيفية استخدامها، وتدابير حمايتها، وما هي حقوقك. بإنشائك حساباً أو بإتمامك طلباً داخل التطبيق فإنك تُقرّ بقراءتك لهذه السياسة والموافقة عليها، ويسري أي تعديل منشور داخل التطبيق.'**
  String get privacyIntro;

  /// No description provided for @privacySecDataTitle.
  ///
  /// In ar, this message translates to:
  /// **'البيانات التي نجمعها'**
  String get privacySecDataTitle;

  /// No description provided for @privacySecDataBody.
  ///
  /// In ar, this message translates to:
  /// **'نجمع الحد الأدنى الضروري لإتمام طلبك:\n• رقم هاتفك: وسيلة التواصل الأساسية لتأكيد الطلب والاتصال بك عند الحاجة.\n• اسمك وبيانات حسابك.\n• عنوان التوصيل الذي تُدخله: الشارع، العمارة، الطابق وملاحظات الوصول.\n• إحداثيات الموقع (خط الطول وخط العرض): فقط عندما تختار استخدام موقعك الحالي لتحديد العنوان على الخريطة، ويمكنك تحديد الموقع يدوياً دون منح هذا الإذن.\n• سجل طلباتك ومشترياتك: المنتجات، الكميات، الأسعار، رسوم التوصيل، تاريخ الطلب وحالته.\nلا نجمع ولا نُخزّن أي معلومة بطاقة بنكية، لأن الدفع عند الاستلام فقط.'**
  String get privacySecDataBody;

  /// No description provided for @privacySecUsageTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيفية استخدام بياناتك'**
  String get privacySecUsageTitle;

  /// No description provided for @privacySecUsageBody.
  ///
  /// In ar, this message translates to:
  /// **'نستخدم بياناتك حصرياً من أجل: معالجة طلباتك وتحضيرها وتسليمها للمندوب المكلف بالتوصيل؛ التواصل معك هاتفياً لتأكيد الطلب أو عند وجود استفسار أو نقص في المنتجات؛ حساب تكلفة التوصيل ديناميكياً حسب منطقة أو حي التوصيل الذي تختاره؛ عرض سجل طلباتك داخل التطبيق؛ وتحسين أداء الخدمة والمتجر.\nلا نستخدم بياناتك لأغراض إعلانية، ولا نرسل رسائل تسويقية دون موافقتك.'**
  String get privacySecUsageBody;

  /// No description provided for @privacySecSecurityTitle.
  ///
  /// In ar, this message translates to:
  /// **'أمان البيانات وتخزينها'**
  String get privacySecSecurityTitle;

  /// No description provided for @privacySecSecurityBody.
  ///
  /// In ar, this message translates to:
  /// **'تُخزَّن بياناتك في قاعدة بيانات Supabase المحمية، وتُطبَّق عليها سياسات أمان على مستوى الصفوف (RLS) تضمن ألّا يطّلع مستخدم على بيانات مستخدم آخر، كما تُنقل البيانات عبر اتصال مشفّر (HTTPS).\nلا نبيع بياناتك الشخصية ولا نشاركها مع أي طرف ثالث خارج نطاق عملية التوصيل: يتلقى المندوب والمسؤول عن التوصيل ما يحتاجه فقط من بيانات (العنوان، رقم الهاتف، تفاصيل الطلب) لتنفيذ التسليم. وقد نفصح عن بياناتك إذا اقتضى ذلك قانون ساري المفعول في الجزائر.'**
  String get privacySecSecurityBody;

  /// No description provided for @privacySecRightsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حقوقك'**
  String get privacySecRightsTitle;

  /// No description provided for @privacySecRightsBody.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك في أي وقت: تعديل اسمك ورقم هاتفك من صفحة الحساب؛ إضافة عناوين توصيل أو تعديلها أو حذفها من شاشة العناوين؛ طلب حذف حسابك وبياناتك الشخصية نهائياً من زر «حذف الحساب» في صفحة الحساب، حيث يُمحى حسابك وطلباتك وعناوينك من قاعدة البيانات ومن نظام المصادقة دون إمكانية التراجع؛ وسحب موافقتك على الوصول إلى موقعك بإزالة إذن الموقع من إعدادات هاتفك.'**
  String get privacySecRightsBody;

  /// No description provided for @privacySecContactTitle.
  ///
  /// In ar, this message translates to:
  /// **'التواصل معنا'**
  String get privacySecContactTitle;

  /// No description provided for @privacySecContactBody.
  ///
  /// In ar, this message translates to:
  /// **'لأي استفسار بخصوص خصوصية بياناتك أو لممارسة أي من الحقوق الواردة أعلاه، تواصل معنا عبر قسم «الدعم الفني» داخل التطبيق (الهاتف أو واتساب)، وسنعالج طلبك في أقرب وقت ممكن.'**
  String get privacySecContactBody;

  /// No description provided for @termsIntro.
  ///
  /// In ar, this message translates to:
  /// **'تنظّم هذه الشروط العلاقة بينك وبين ATOGA MARKET عند استخدامك لتطبيق الطلب والتوصيل. بإنشائك حساباً أو بإتمامك طلباً داخل التطبيق فإنك تُقرّ بقبولك لهذه الشروط كاملة، وإذا كنت لا توافق على أي بند منها يُرجى عدم استخدام التطبيق.'**
  String get termsIntro;

  /// No description provided for @termsSecAccountTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب والمسؤولية'**
  String get termsSecAccountTitle;

  /// No description provided for @termsSecAccountBody.
  ///
  /// In ar, this message translates to:
  /// **'يلزمك لإنشاء حساب تقديم بيانات صحيحة ورقم هاتف فعّال قادر على استقبال المكالمات، لأن الاتصال بك شرط لتأكيد الطلب وتسليمه. أنت مسؤول عن الحفاظ على سرية بيانات دخولك وعن كل طلب يُجرى عبر حسابك، ويحتفظ المتجر بحق تعليق الحساب مؤقتاً أو إيقافه عند إساءة الاستخدام أو تقديم بيانات غير صحيحة أو مكرّرة.'**
  String get termsSecAccountBody;

  /// No description provided for @termsSecPricingTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأسعار وتكلفة التوصيل'**
  String get termsSecPricingTitle;

  /// No description provided for @termsSecPricingBody.
  ///
  /// In ar, this message translates to:
  /// **'تُعرض الأسعار بالدينار الجزائري، وقد تتغير دون إشعار مسبق، ويُعتمد السعر الساري وقت تأكيد الطلب. تُحسب تكلفة التوصيل ديناميكياً حسب منطقة أو حي التوصيل المختار وتُضاف إلى إجمالي الطلب قبل الدفع، وقد تُلغى بالكامل عند بلوغ إجمالي الطلب للحد المعلن للتوصيل المجاني داخل التطبيق. كما يمكن تطبيق كوبونات خصم سارية المفعول على الإجمالي.'**
  String get termsSecPricingBody;

  /// No description provided for @termsSecPaymentTitle.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get termsSecPaymentTitle;

  /// No description provided for @termsSecPaymentBody.
  ///
  /// In ar, this message translates to:
  /// **'الطريقة المعتمدة حالياً هي الدفع عند الاستلام (Cash on Delivery) نقداً بالدينار الجزائري، ويلتزم الزبون بتسليم كامل المبلغ المبيّن في الفاتورة للمندوب عند استلام الطلب. لا يطلب التطبيق أي معلومة بطاقة بنكية ولا أي دفع إلكتروني مسبق، ولا يُطلب أي مبلغ قبل تسليم الطلب فعلياً.'**
  String get termsSecPaymentBody;

  /// No description provided for @termsSecCancellationTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب وتعديله'**
  String get termsSecCancellationTitle;

  /// No description provided for @termsSecCancellationBody.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تعديل طلبك أو إلغاؤه مجاناً قبل خروجه للتوصيل عبر التواصل مع قسم الدعم. ويحتفظ المتجر بحق إلغاء الطلب في الحالات التالية: تعذّر التواصل معك عبر الهاتف قبل التأكيد أو أثناء التحضير؛ إدخال عنوان أو رقم هاتف غير صحيح أو غير مكتمل؛ عدم توفر بعض المنتجات ورفضك البدائل؛ أو وقوع خطأ جوهري في الأسعار أو في بيانات الطلب. ونُعلمك بسبب الإلغاء في كل الأحوال.'**
  String get termsSecCancellationBody;

  /// No description provided for @termsSecChangesTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الشروط'**
  String get termsSecChangesTitle;

  /// No description provided for @termsSecChangesBody.
  ///
  /// In ar, this message translates to:
  /// **'يحق لـ ATOGA MARKET تحديث هذه الشروط عند تغيّر الخدمات أو الأنظمة المعمول بها، ويسري التعديل فور نشره داخل التطبيق، واستمرارك في استخدام التطبيق بعد النشر يعني قبولك للشروط المحدّثة.'**
  String get termsSecChangesBody;

  /// No description provided for @termsSecLawTitle.
  ///
  /// In ar, this message translates to:
  /// **'القانون المطبق'**
  String get termsSecLawTitle;

  /// No description provided for @termsSecLawBody.
  ///
  /// In ar, this message translates to:
  /// **'تخضع هذه الشروط لأنظمة الجمهورية الجزائرية الديمقراطية الشعبية، ولا سيما ما يتعلق بالتجارة الإلكترونية وحماية المستهلك والحقوق المعنية، ويُحاول حل أي نزاع أولاً ودياً عبر قسم الدعم داخل التطبيق مع الإبقاء على حقك في التظلم لدى الجهات المختصة.'**
  String get termsSecLawBody;

  /// No description provided for @walletTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get walletTitle;

  /// No description provided for @walletBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الحالي'**
  String get walletBalance;

  /// No description provided for @walletTopUpHint.
  ///
  /// In ar, this message translates to:
  /// **'لشحن رصيدك، يرجى زيارة متجرنا وإيداع المبلغ نقداً ليتم إضافته إلى حسابك.'**
  String get walletTopUpHint;

  /// No description provided for @walletHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل العمليات'**
  String get walletHistoryTitle;

  /// No description provided for @walletNoTransactions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات بعد'**
  String get walletNoTransactions;

  /// No description provided for @walletDepositTitle.
  ///
  /// In ar, this message translates to:
  /// **'شحن رصيد من الإدارة'**
  String get walletDepositTitle;

  /// No description provided for @walletPaymentTitle.
  ///
  /// In ar, this message translates to:
  /// **'دفع للطلب رقم: #{orderId}'**
  String walletPaymentTitle(String orderId);

  /// No description provided for @walletInsufficient.
  ///
  /// In ar, this message translates to:
  /// **'عذراً، رصيد محفظتك غير كافٍ. تم التحويل إلى الدفع عند الاستلام.'**
  String get walletInsufficient;

  /// No description provided for @payWithWallet.
  ///
  /// In ar, this message translates to:
  /// **'الدفع من المحفظة'**
  String get payWithWallet;

  /// No description provided for @rememberPassword.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كلمة المرور'**
  String get rememberPassword;

  /// No description provided for @rememberPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'تُخزَّن مشفّرة على جهازك فقط؛ لن يُطلب منك إدخالها في كل مرة.'**
  String get rememberPasswordHint;

  /// No description provided for @appDeveloperTitle.
  ///
  /// In ar, this message translates to:
  /// **'مبرمج التطبيق'**
  String get appDeveloperTitle;

  /// No description provided for @appDeveloperMarketing.
  ///
  /// In ar, this message translates to:
  /// **'تم برمجة هذا التطبيق بواسطة DIRAYA LAB. لطلب تطبيقك الخاص، يمكنك التواصل معنا عبر الإيميل التالي:'**
  String get appDeveloperMarketing;

  /// No description provided for @appDeveloperEmailCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ البريد الإلكتروني بنجاح'**
  String get appDeveloperEmailCopied;

  /// No description provided for @storeOpenStatus.
  ///
  /// In ar, this message translates to:
  /// **'المتجر مفتوح حالياً — يمكنك الطلب'**
  String get storeOpenStatus;

  /// No description provided for @storeClosedStatus.
  ///
  /// In ar, this message translates to:
  /// **'المتجر مغلق حالياً'**
  String get storeClosedStatus;

  /// No description provided for @walletUserId.
  ///
  /// In ar, this message translates to:
  /// **'معرّف المستخدم (لشحن الرصيد من المتجر)'**
  String get walletUserId;

  /// No description provided for @walletUserIdCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ معرّف المستخدم بنجاح'**
  String get walletUserIdCopied;

  /// No description provided for @storeClosedAddToCart.
  ///
  /// In ar, this message translates to:
  /// **'المتجر مغلق حالياً — لا يمكن إضافة المنتجات إلى السلة'**
  String get storeClosedAddToCart;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
