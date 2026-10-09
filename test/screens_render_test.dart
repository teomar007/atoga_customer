import 'dart:async';

import 'package:atoga_customer/core/services/cart_storage.dart';
import 'package:atoga_customer/core/constants/app_constants.dart';
import 'package:atoga_customer/core/theme/app_colors.dart';
import 'package:atoga_customer/core/utils/formatters.dart';
import 'package:atoga_customer/core/widgets/empty_state_view.dart';
import 'package:atoga_customer/core/providers/locale_provider.dart';
import 'package:atoga_customer/core/theme/app_theme.dart';
import 'package:atoga_customer/features/auth/domain/auth_repository.dart';
import 'package:atoga_customer/features/auth/domain/customer_user.dart';
import 'package:atoga_customer/core/providers/supabase_providers.dart';
import 'package:atoga_customer/features/auth/domain/auth_status.dart';
import 'package:atoga_customer/features/auth/presentation/auth_controller.dart';
import 'package:atoga_customer/features/auth/presentation/login_screen.dart';
import 'package:atoga_customer/features/cart/data/cart_cloud_store.dart';
import 'package:atoga_customer/features/cart/domain/cart_item.dart';
import 'package:atoga_customer/features/cart/presentation/cart_controller.dart';
import 'package:atoga_customer/features/cart/presentation/cart_screen.dart';
import 'package:atoga_customer/features/coupons/data/coupons_repository.dart';
import 'package:atoga_customer/features/coupons/domain/coupon_offer.dart';
import 'package:atoga_customer/features/coupons/presentation/coupons_controller.dart';
import 'package:atoga_customer/features/coupons/presentation/coupons_screen.dart';
import 'package:atoga_customer/features/coupons/presentation/widgets/coupon_card.dart';
import 'package:atoga_customer/features/favorites/data/favorites_repository.dart';
import 'package:atoga_customer/features/favorites/presentation/favorites_provider.dart';
import 'package:atoga_customer/features/favorites/presentation/favorites_screen.dart';
import 'package:atoga_customer/core/navigation/main_shell.dart';
import 'package:atoga_customer/core/navigation/main_tab_provider.dart';
import 'package:atoga_customer/core/navigation/session_sync.dart';
import 'package:atoga_customer/features/checkout/presentation/checkout_controller.dart';
import 'package:atoga_customer/features/checkout/presentation/address_form_screen.dart';
import 'package:atoga_customer/features/checkout/presentation/delivery_zones_provider.dart';
import 'package:atoga_customer/features/checkout/domain/address.dart';
import 'package:atoga_customer/features/checkout/domain/delivery_zone.dart';
import 'package:atoga_customer/features/home/domain/product.dart';
import 'package:atoga_customer/features/home/data/catalog_repository.dart';
import 'package:atoga_customer/features/home/domain/product_category.dart';
import 'package:atoga_customer/features/home/domain/promo_banner.dart';
import 'package:atoga_customer/features/home/presentation/home_controller.dart';
import 'package:atoga_customer/features/home/presentation/home_screen.dart';
import 'package:atoga_customer/features/home/presentation/store_status_provider.dart';
import 'package:atoga_customer/features/home/presentation/widgets/category_rail.dart';
import 'package:atoga_customer/features/home/presentation/widgets/product_card.dart';
import 'package:atoga_customer/features/home/presentation/widgets/promo_carousel.dart';
import 'package:atoga_customer/features/orders/data/order_repository.dart';
import 'package:atoga_customer/features/orders/domain/order.dart';
import 'package:atoga_customer/features/orders/domain/status.dart';
import 'package:atoga_customer/features/orders/presentation/order_tracking_screen.dart';
import 'package:atoga_customer/features/orders/presentation/orders_controller.dart';
import 'package:atoga_customer/features/profile/presentation/profile_screen.dart';
import 'package:atoga_customer/features/profile/presentation/privacy_policy_screen.dart';
import 'package:atoga_customer/features/profile/presentation/widgets/social_links_section.dart';
import 'package:atoga_customer/features/profile/presentation/widgets/support_section.dart';
import 'package:atoga_customer/features/profile/presentation/terms_of_service_screen.dart';
import 'package:atoga_customer/features/social/data/social_links_repository.dart';
import 'package:atoga_customer/features/wallet/presentation/wallet_screen.dart';
import 'package:atoga_customer/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryStore implements CartStore {
  List<CartItem> seed;
  _MemoryStore(this.seed);

  @override
  List<CartItem> readAll() => List<CartItem>.of(seed);

  @override
  Future<void> writeAll(List<CartItem> items) async => seed = List<CartItem>.of(items);

  @override
  Future<void> clear() async => seed = <CartItem>[];
}

class _FakeAuthRepo implements AuthRepository {
  _FakeAuthRepo(this._user);
  final CustomerUser? _user;

  /// آخر لغة أرسلها التطبيق إلى profiles — تُستعمل في اختبار المزامنة.
  String? savedLanguage;

  @override
  CustomerUser? get currentUser => _user;

  @override
  Stream<CustomerUser?> authStateChanges() => Stream<CustomerUser?>.value(_user);

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<CustomerUser> savePhone(String phone) async => _user ?? CustomerUser(id: 'x');

  @override
  Future<void> saveLanguage(String languageCode) async => savedLanguage = languageCode;

  @override
  Future<void> saveFcmToken(String? fcmToken) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<CustomerUser> signInWithPassword({required String phone, required String password}) async => _user ?? CustomerUser(id: 'x');

  @override
  Future<SignUpResult> signUp({required String phone, required String password, String? displayName}) async => SignUpResult(user: _user ?? CustomerUser(id: 'x'), sessionReady: true);

  @override
  Future<void> signOut() async {}

  @override
  Future<CustomerUser> refreshProfile() async => _user ?? CustomerUser(id: 'x');

  @override
  Future<CustomerUser> updateProfile({String? displayName, String? phone}) async => _user ?? CustomerUser(id: 'x');
}

/// سلة سحابية وهمية تسجّل ما رُفع وتُرجع ما هو مخزّن في الخادم.
class _FakeCartCloud implements CartCloudStore {
  _FakeCartCloud(this.remote);

  List<CartItem> remote;
  String? replacedUserId;

  @override
  Future<List<CartItem>> fetch(String userId) async => remote;

  @override
  Future<void> replace(String userId, List<CartItem> items) async {
    replacedUserId = userId;
    remote = items;
  }
}

/// مستودع مفضلة وهمي: يسجّل آخر كتابة ويجبر الفشل لاختبار التراجع.
class _FakeFavoritesRepository implements FavoritesRepository {
  _FakeFavoritesRepository(this._seed);

  final Set<String> _seed;
  bool fail = false;
  int fetchCalls = 0;
  String? lastProductId;
  bool? lastFavorite;

  @override
  Future<Set<String>> fetch(String userId) async {
    fetchCalls += 1;
    return Set<String>.of(_seed);
  }

  @override
  Future<void> set(String userId, String productId, {required bool favorite}) async {
    lastProductId = productId;
    lastFavorite = favorite;
    if (fail) {
      throw Exception('network down');
    }
  }
}

/// مستودع روابط اجتماعية وهمي — يعيد الخريطة كما هي دون شبكة.
class _FakeSocialLinksRepository implements SocialLinksRepository {
  _FakeSocialLinksRepository(this.links);

  final Map<String, String> links;

  @override
  Future<Map<String, String>> fetchAll() async => links;
}

/// كتالوج وهمي: يثبت أن الشاشة تعرض ما يعيده المستودع بعد التحميل الأولي.
///
/// يُستخدم `implements` لا `extends` عمداً: بناء `SupabaseClient` يشغّل
/// مؤقتاً داخلياً يبقى معلّقاً فينتهي الاختبار بخطأ، والوهمي لا يحتاج عميلاً.
class _FakeCatalogRepository implements CatalogRepository {
  /// مصدر واحد للبيانات يستعمله كل طرق الجلب — لا تباين بينها في الاختبار.
  static const List<Product> _items = <Product>[
    Product(id: 'p1', name: 'طماطم مصبرة 400غ', nameFr: 'Tomates concervées 400 g', price: 120, categoryId: 'canned', unit: 'علبة'),
    Product(id: 'p2', name: 'عصير برتقال 1 لتر', nameFr: 'Jus d\'orange 1 L', price: 150, categoryId: 'drinks', unit: 'قنينة'),
  ];

  @override
  Future<List<PromoBanner>> fetchBanners() async => <PromoBanner>[
        const PromoBanner(
          id: 'b1',
          title: 'خصم 20%',
          titleFr: 'Remise 20%',
          subtitle: 'على كل المشروبات',
          subtitleFr: 'Sur toutes les boissons',
          targetCategoryId: 'drinks',
        ),
      ];

  @override
  Future<List<ProductCategory>> fetchCategories() async => <ProductCategory>[
        const ProductCategory(id: 'all', name: 'الكل', iconName: 'grid'),
        const ProductCategory(id: 'canned', name: 'معلبات', iconName: 'lunch_dining'),
        const ProductCategory(id: 'drinks', name: 'مشروبات', iconName: 'local_drink'),
      ];

  @override
  Future<ProductPage> fetchProducts({String? categoryId, String? search, int offset = 0}) async => ProductPage(
        items: _items,
        hasMore: false,
      );

  @override
  Future<List<Product>> fetchByIds(List<String> ids) async => _items.where((Product p) => ids.contains(p.id)).toList();
}

/// مستودع كوبونات وهمي — يتجاوز بناء `SupabaseClient` (مؤقت داخلي معلّق).
class _FakeCouponsRepository implements CouponsRepository {
  _FakeCouponsRepository(this._coupons);

  final List<CouponOffer> _coupons;

  @override
  Future<List<CouponOffer>> fetchAvailable({String? userId}) async => _coupons;
}

/// مستودع طلبات وهمي: حالة ثابتة قابلة للتغيير عبر بثّ حي، مع خيار رفض
/// الإلغاء (يحاكي انتقال الطلب إلى `preparing` قبل الضغط على الإلغاء).
class _FakeOrderRepository implements OrderRepository {
  _FakeOrderRepository(this._order, {Stream<Order>? watch}) : _watch = watch ?? Stream<Order>.value(_order);

  final Order _order;
  final Stream<Order> _watch;

  /// `true` ⇒ الإلغاء مرفوض من «الخادم» (الحالة لم تعد received).
  bool rejectCancel = false;

  @override
  Future<String> createOrder(NewOrderPayload payload) async => 'o1';

  @override
  Future<List<Order>> fetchOrders({int limit = 50}) async => <Order>[_order];

  @override
  Future<Order> fetchOrder(String id) async => _order;

  @override
  Stream<Order> watchOrder(String id) => _watch;

  @override
  Future<bool> cancelOrder(String id) async {
    if (rejectCancel) {
      return false;
    }
    return true;
  }
}

/// حالة متجر ثابتة للاختبار — يلغي الجلب والتوقيت الدوري.
class _FixedStoreStatus extends StoreStatusController {
  _FixedStoreStatus(this.value);

  final StoreStatus value;

  @override
  StoreStatus build() => value;
}

Future<ProviderContainer> _container({
  CustomerUser? user,
  List<CartItem>? cart,
  CatalogRepository? catalog,
  List<CouponOffer>? coupons,
  AuthRepository? auth,
  Map<String, Object>? stored,
  CartCloudStore? cloud,
  FavoritesRepository? favorites,
  SocialLinksRepository? socialLinks,
  List<DeliveryZone>? zones,
  OrderRepository? ordersRepo,
  StoreStatus? storeStatus,
}) async {
  SharedPreferences.setMockInitialValues(stored ?? <String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final ProviderContainer container = ProviderContainer(overrides: <Override>[
    sharedPreferencesProvider.overrideWithValue(prefs),
    cartStorageProvider.overrideWithValue(_MemoryStore(cart ?? <CartItem>[])),
    authRepositoryProvider.overrideWithValue(auth ?? _FakeAuthRepo(user)),
    if (catalog != null) catalogRepositoryProvider.overrideWithValue(catalog),
    if (coupons != null) couponsRepositoryProvider.overrideWithValue(_FakeCouponsRepository(coupons)),
    if (cloud != null) cartCloudStoreProvider.overrideWithValue(cloud),
    if (favorites != null) favoritesRepositoryProvider.overrideWithValue(favorites),
    if (socialLinks != null) socialLinksRepositoryProvider.overrideWithValue(socialLinks),
    if (zones != null) deliveryZonesProvider.overrideWith((Ref ref) async => zones),
    if (ordersRepo != null) orderRepositoryProvider.overrideWithValue(ordersRepo),
    if (storeStatus != null) storeStatusProvider.overrideWith(() => _FixedStoreStatus(storeStatus)),
  ]);
  return container;
}

Widget _host(Widget child, {Locale locale = const Locale('ar'), double textScale = 1.0}) {
  return MaterialApp(
    locale: locale,
    theme: AppTheme.build(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    builder: (BuildContext context, Widget? child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child ?? const SizedBox.shrink(),
    ),
    home: child,
  );
}

/// نصوص كل حقول الإدخال في الشاشة الحالية.
Iterable<String> _fieldTexts(WidgetTester tester) => tester
    .widgetList<EditableText>(find.byType(EditableText))
    .map((EditableText field) => field.controller.text);

void main() {
  testWidgets('CartScreen renders its items', (WidgetTester tester) async {
    final ProviderContainer c = await _container(cart: <CartItem>[CartItem.fromProduct(const Product(id: 'p1', name: 'طماطم مصبرة 400غ', price: 120), quantity: 2)]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const CartScreen())));
    await tester.pump();
    expect(find.textContaining('طماطم'), findsWidgets, reason: 'item name should render');
    expect(tester.takeException(), isNull, reason: 'cart body must not throw layout errors');
    expect(find.byType(ListView), findsWidgets);
  });

  testWidgets('السلة الفارغة: «ابدأ التسوق» ينقل إلى تبويب الرئيسية بدل نافذة فارغة', (WidgetTester tester) async {
    final ProviderContainer c = await _container();
    addTearDown(c.dispose);
    // نفتح الهيكل على تبويب السلة (1) كما لو ضغط المستخدم على أيقونة السلة.
    c.read(mainTabIndexProvider.notifier).select(1);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const MainShell())));
    await tester.pump();
    await tester.pump();

    expect(find.text('سلتك فارغة حالياً'), findsOneWidget, reason: 'حالة السلة الفارغة ظاهرة');
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1, reason: 'نحن في تبويب السلة');

    await tester.tap(find.text('ابدأ التسوق'));
    await tester.pump();

    expect(c.read(mainTabIndexProvider), 0, reason: 'الزر يعيد الفهرس إلى تبويب الرئيسية');
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0, reason: 'تظهر الرئيسية بدل النافذة الفارغة');
    expect(tester.takeException(), isNull);
  });

  testWidgets('شاشة المحفظة تعرض طلب تسجيل الدخول للزائر', (WidgetTester tester) async {
    final ProviderContainer c = await _container();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const WalletScreen())));
    await tester.pump();

    expect(find.text('المحفظة'), findsOneWidget, reason: 'عنوان الشاشة ظاهر');
    expect(find.text('تسجيل الدخول مطلوب'), findsOneWidget, reason: 'الزائر يرى دعوة الدخول بدل الرصيد');
    expect(tester.takeException(), isNull);
  });

  testWidgets('بطاقة المحفظة تعرض معرّف المستخدم وينسخه بنقرة', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final ProviderContainer c = await _container(user: const CustomerUser(id: 'u1-abc-123'));
    addTearDown(c.dispose);

    final List<MethodCall> clipboardCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
      if (call.method == 'Clipboard.setData') {
        clipboardCalls.add(call);
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const WalletScreen())));
    await tester.pump();
    await tester.pump();

    expect(find.text('u1-abc-123'), findsOneWidget, reason: 'معرّف المستخدم ظاهر في البطاقة');
    expect(find.text('معرّف المستخدم (لشحن الرصيد من المتجر)'), findsOneWidget);

    await tester.tap(find.text('u1-abc-123'));
    await tester.pump();
    await tester.pump();

    expect(clipboardCalls, isNotEmpty, reason: 'النقر ينسخ المعرّف للحافظة');
    expect((clipboardCalls.first.arguments as Map<dynamic, dynamic>)['text'], 'u1-abc-123');
    expect(find.text('تم نسخ معرّف المستخدم بنجاح'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('selectPaymentMethod يحوّل تلقائياً إلى الدفع عند الاستلام عند نقص الرصيد', () async {
    final ProviderContainer c = await _container();
    addTearDown(c.dispose);

    // الرصيد غير متاح في بيئة الاختبار ← يعامل كـ 0 ← المحفظة مرفوضة.
    final bool ok = await c.read(checkoutControllerProvider.notifier).selectPaymentMethod(PaymentMethod.wallet);
    expect(ok, isFalse, reason: 'الرصيد غير كافٍ فلا تُقبل المحفظة');
    expect(c.read(checkoutControllerProvider).paymentMethod, PaymentMethod.cod, reason: 'يُحوَّل تلقائياً إلى الدفع عند الاستلام');

    final bool cod = await c.read(checkoutControllerProvider.notifier).selectPaymentMethod(PaymentMethod.cod);
    expect(cod, isTrue, reason: 'الدفع عند الاستلام مقبول دائماً');
    expect(c.read(checkoutControllerProvider).paymentMethod, PaymentMethod.cod);
  });

  testWidgets('ProfileScreen renders when signed out', (WidgetTester tester) async {
    final ProviderContainer c = await _container();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const ProfileScreen())));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('loginToViewProfile'), findsNothing);
    expect(find.textContaining('حسابك'), findsWidgets, reason: 'guest must see the sign-in prompt');
  });

  testWidgets('قسم «مبرمج التطبيق» يعرض البريد وينسخه بنقرة', (WidgetTester tester) async {
    // ارتفاع كافٍ حتى يُبنى القسم في أسفل قائمة الملف الشخصي.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final ProviderContainer c = await _container(user: const CustomerUser(id: 'u1'));
    addTearDown(c.dispose);

    final List<MethodCall> clipboardCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
      if (call.method == 'Clipboard.setData') {
        clipboardCalls.add(call);
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const ProfileScreen())));
    await tester.pump();
    await tester.pump();

    expect(find.text('مبرمج التطبيق'), findsOneWidget, reason: 'عنوان القسم ظاهر');
    expect(find.text('DIRAYA LAB'), findsOneWidget, reason: 'اسم الفريق المطوّر ظاهر');
    expect(find.text('DIRAYALAB@GMAIL.COM'), findsOneWidget, reason: 'البريد معروض بوضوح');

    await tester.tap(find.text('DIRAYALAB@GMAIL.COM'));
    await tester.pump();
    await tester.pump();

    expect(clipboardCalls, isNotEmpty, reason: 'النقر ينسخ إلى الحافظة');
    expect((clipboardCalls.first.arguments as Map<dynamic, dynamic>)['text'], 'DIRAYALAB@GMAIL.COM');
    expect(find.text('تم نسخ البريد الإلكتروني بنجاح'), findsOneWidget, reason: 'رسالة نجاح فورية');
    expect(tester.takeException(), isNull);
  });

  testWidgets('شاشة الدخول تعرض مربع «حفظ كلمة المرور»', (WidgetTester tester) async {
    final ProviderContainer c = await _container();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const LoginScreen())));
    await tester.pump();
    await tester.pump();

    expect(find.text('حفظ كلمة المرور'), findsOneWidget, reason: 'خيار حفظ كلمة المرور ظاهر في وضع الدخول');
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MainShell has 6 destinations in the required order', (WidgetTester tester) async {
    final ProviderContainer c = await _container();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const MainShell())));
    await tester.pump();
    final NavigationBar bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.destinations.length, 6);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeScreen: الشيمر يختفي وتظهر المنتجات بعد التحميل الأولي', (WidgetTester tester) async {
    final ProviderContainer c = await _container(catalog: _FakeCatalogRepository());
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const HomeScreen())));

    // الحالة الأولى (قبل وصول البيانات): هيكل التحميل ظاهر.
    expect(find.byType(Shimmer), findsWidgets, reason: 'shimmer must show while loading');

    // يشغّل microtask التحميل الأولي ثم يستقر على الحالة النهائية.
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('طماطم مصبرة 400غ'), findsWidgets, reason: 'products must render after loadInitial');
    expect(find.byType(CategoryRail), findsOneWidget, reason: 'categories must render after loadInitial');
    expect(find.byType(Shimmer), findsNothing, reason: 'shimmer must disappear once data arrives');
    expect(tester.takeException(), isNull, reason: 'home body must not throw layout errors');
  });

  testWidgets('HomeScreen بالفرنسية: التصنيفات والبانرات يتبعان لغة التطبيق', (WidgetTester tester) async {
    final ProviderContainer c = await _container(catalog: _FakeCatalogRepository());
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const HomeScreen(), locale: const Locale('fr'))));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('Conserves'), findsWidgets, reason: 'category labels must come from l10n, not from the database');
    expect(find.text('Tout'), findsWidgets, reason: 'the "all" chip must use allCategories');
    expect(find.text('Remise 20%'), findsWidgets, reason: 'banner title must use the French column');
    expect(find.text('Tomates concervées 400 g'), findsWidgets, reason: 'product names must use the French column');
    expect(find.text('Boîte'), findsWidgets, reason: 'units are a closed vocabulary translated from l10n');
    expect(find.text('طماطم مصبرة 400غ'), findsNothing, reason: 'the Arabic product name must not render in French');
    expect(find.text('خصم 20%'), findsNothing, reason: 'the Arabic banner title must not render in French');
    expect(tester.takeException(), isNull);
  });

  testWidgets('شريط العروض يتحرك أوتوماتيكياً في لوب', (WidgetTester tester) async {
    final ProviderContainer c = await _container();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: _host(Scaffold(body: PromoCarousel(banners: const <PromoBanner>[
        PromoBanner(id: 'b1', title: 'عرض 1'),
        PromoBanner(id: 'b2', title: 'عرض 2'),
      ]))),
    ));
    await tester.pump();

    final PageView pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller!.page, 0);

    // الدفعة الأولى: بعد 4 ثوانٍ ينتقل للأولى ← الثانية.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 600));
    expect(pageView.controller!.page, closeTo(1, 0.01), reason: 'من الأولى إلى الثانية تلقائياً');

    // اللفة الكاملة: يعود للأولى بعد الأخيرة.
    await tester.pump(const Duration(seconds: 4, milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(pageView.controller!.page, closeTo(0, 0.01), reason: 'يعود للأولى في لوب');
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeScreen: زر «الكل» أول عنصر في الشريط ويعيد الفلتر إلى null', (WidgetTester tester) async {
    final ProviderContainer c = await _container(catalog: _FakeCatalogRepository());
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const HomeScreen())));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    // افتراضياً لا تصنيف محدد: زر «الكل» مفعّل ويعرض كل المنتجات.
    expect(c.read(homeControllerProvider).selectedCategoryId, isNull, reason: 'الفلتر يبدأ مصفّراً عند فتح التطبيق');
    expect(find.text('الكل'), findsWidgets, reason: 'زر «الكل» عنصر ثابت في أول الشريط');

    // اختيار تصنيف يضبط المعرّف، ثم «الكل» يلغي الفلترة.
    await tester.tap(find.text('معلبات'));
    await tester.pump();
    expect(c.read(homeControllerProvider).selectedCategoryId, isNotNull, reason: 'اختيار تصنيف يضبط selectedCategoryId');

    await tester.tap(find.text('الكل').first);
    await tester.pump();
    expect(c.read(homeControllerProvider).selectedCategoryId, isNull, reason: '«الكل» يعيد null فيعرض كل المنتجات');
    expect(tester.takeException(), isNull);
  });

  testWidgets('المستندات القانونية: سياسة الخصوصية بالعربية وشروط الاستخدام بالفرنسية', (WidgetTester tester) async {
    // شاشة طويلة تُظهر كل الأقسام دفعة واحدة حتى يتحقّق الاختبار من المحتوى
    // لا من عنوان واحد فقط.
    tester.view.physicalSize = const Size(400, 4200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final ProviderContainer c = await _container();
    addTearDown(c.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const PrivacyPolicyScreen())));
    await tester.pump();
    expect(find.text('البيانات التي نجمعها'), findsOneWidget, reason: 'عنوان قسم بارز');
    expect(find.textContaining('Supabase'), findsOneWidget, reason: 'أمن البيانات وRLS منشور في السياسة');
    expect(find.textContaining('الدفع عند الاستلام فقط'), findsOneWidget, reason: 'غياب مدفوعات البطاقة مذكور صراحة');
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const TermsOfServiceScreen(), locale: const Locale('fr'))));
    await tester.pump();
    expect(find.text('Prix et frais de livraison'), findsOneWidget, reason: 'les sections sont traduites en français');
    expect(find.textContaining('paiement à la livraison'), findsOneWidget, reason: 'le mode de paiement est précisé');
    expect(find.textContaining('République Algérienne'), findsOneWidget, reason: 'le droit applicable est précisé');
    expect(tester.takeException(), isNull);
  });

  testWidgets('تتبع الطلب: زر الإلغاء يظهر في received وتُعرض رسالة الرفض عند بدء التجهيز', (WidgetTester tester) async {
    // شاشة مرتفعة حتى يُبنى زر الإلغاء أسفل الفاتورة داخل ListView.
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final _FakeOrderRepository repo = _FakeOrderRepository(Order(id: 'o1', createdAt: DateTime(2026, 10, 7), subtotal: 100, discount: 0, deliveryFee: 200, total: 300, status: OrderStatus.received))..rejectCancel = true;
    final ProviderContainer c = await _container(ordersRepo: repo);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const OrderTrackingScreen(orderId: 'o1'))));
    await tester.pump();
    await tester.pump();

    expect(find.text('إلغاء الطلب'), findsOneWidget, reason: 'زر الإلغاء ظاهر في مرحلة received فقط');

    // «الخادم» رفض الإلغاء (الحالة انتقلت إلى preparing): تظهر رسالة مخصصة.
    await tester.ensureVisible(find.text('إلغاء الطلب'));
    await tester.tap(find.text('إلغاء الطلب'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('تأكيد'));
    await tester.pump();
    await tester.pump();

    expect(find.text('عذراً، لا يمكن إلغاء الطلب بعد البدء في تجهيزه'), findsOneWidget, reason: 'رسالة رفض الإلغاء بعد بدء التجهيز');
    expect(tester.takeException(), isNull);

    // تفريغ مؤقتات تصفية المزوّدات (autoDispose) قبل نهاية الاختبار.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 5));
  });

  testWidgets('تتبع الطلب: لا زر إلغاء في أي مرحلة بعد received', (WidgetTester tester) async {
    for (final OrderStatus status in <OrderStatus>[OrderStatus.preparing, OrderStatus.onTheWay, OrderStatus.delivered, OrderStatus.cancelled]) {
      final ProviderContainer c = await _container(
        ordersRepo: _FakeOrderRepository(Order(id: 'o1', createdAt: DateTime(2026, 10, 7), subtotal: 100, discount: 0, deliveryFee: 200, total: 300, status: status)),
      );
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const OrderTrackingScreen(orderId: 'o1'))));
      await tester.pump();
      await tester.pump();
      expect(find.text('إلغاء الطلب'), findsNothing, reason: 'لا زر إلغاء في حالة $status');
      expect(tester.takeException(), isNull);
    }

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 5));
  });

  testWidgets('تتبع الطلب: زر الإلغاء يختفي فور وصول preparing عبر البث الحي', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final StreamController<Order> stream = StreamController<Order>.broadcast();
    addTearDown(() async => stream.close());
    final ProviderContainer c = await _container(
      ordersRepo: _FakeOrderRepository(Order(id: 'o1', createdAt: DateTime(2026, 10, 7), subtotal: 100, discount: 0, deliveryFee: 200, total: 300, status: OrderStatus.received), watch: stream.stream),
    );
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const OrderTrackingScreen(orderId: 'o1'))));
    await tester.pump();
    await tester.pump();
    expect(find.text('إلغاء الطلب'), findsOneWidget, reason: 'الزر ظاهر قبل بدء التجهيز');

    stream.add(Order(id: 'o1', createdAt: DateTime(2026, 10, 7), subtotal: 100, discount: 0, deliveryFee: 200, total: 300, status: OrderStatus.preparing));
    await tester.pump();
    await tester.pump();
    expect(find.text('إلغاء الطلب'), findsNothing, reason: 'الزر يختفي تلقائياً بمجرد انتقال الحالة في Supabase');
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 5));
  });

  testWidgets('CouponsScreen تعرض الكوبونات مع بطاقة ونسخ الكود', (WidgetTester tester) async {
    final ProviderContainer c = await _container(coupons: <CouponOffer>[
      const CouponOffer(id: 'c1', code: 'WELCOME10', title: 'خصم 10% على أول طلب'),
      const CouponOffer(id: 'c2', code: 'SAVE200', title: 'خصم 200 د.ج'),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const CouponsScreen())));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.byType(CouponCard), findsNWidgets(2));
    expect(find.text('WELCOME10'), findsOneWidget, reason: 'the code must be rendered prominently');
    expect(find.text('خصم 10% على أول طلب'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing, reason: 'loading must end once data arrives');
    expect(tester.takeException(), isNull);
  });

  testWidgets('CouponsScreen تعرض حالة الفراغ عند عدم وجود كوبونات', (WidgetTester tester) async {
    final ProviderContainer c = await _container(coupons: const <CouponOffer>[]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const CouponsScreen())));
    await tester.pump();
    await tester.pump();

    expect(find.byType(CouponCard), findsNothing);
    expect(find.byType(EmptyStateView), findsOneWidget, reason: 'the empty state must be shown explicitly');
    expect(tester.takeException(), isNull);
  });

  test('availableCouponsCountProvider يعيد 0 عند فشل الجلب بدل رمي خطأ', () async {
    final ProviderContainer c = await _container();
    addTearDown(c.dispose);
    // لا يوجد override لـ couponsRepositoryProvider: يرمي supabaseClientProvider
    // خطأً، ولا يجوز أن ينهار بسببه شريط التنقل كاملاً (شاشة بيضاء).
    expect(c.read(availableCouponsCountProvider), 0);
  });

  testWidgets('MainShell تعرض شارة الكوبونات بعددّ الجلب', (WidgetTester tester) async {
    final ProviderContainer c = await _container(coupons: const <CouponOffer>[
      CouponOffer(id: 'c1', code: 'WELCOME10'),
      CouponOffer(id: 'c2', code: 'SAVE200'),
      CouponOffer(id: 'c3', code: 'BIG500'),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const MainShell())));
    await tester.pump();
    await tester.pump();

    final Iterable<String> visibleBadges = tester
        .widgetList<Badge>(find.byType(Badge))
        .where((Badge badge) => badge.isLabelVisible)
        .map((Badge badge) => (badge.label! as Text).data ?? '');
    expect(visibleBadges, contains('3'), reason: 'the coupons badge must show the available count');
    expect(tester.takeException(), isNull);
  });

  testWidgets('تسميات شريط التنقل في الفرنسية تبقى في سطر واحد عند تكبير النص', (WidgetTester tester) async {
    final ProviderContainer c = await _container(coupons: const <CouponOffer>[CouponOffer(id: 'c1', code: 'WELCOME10')]);
    addTearDown(c.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: _host(const MainShell(), locale: const Locale('fr'), textScale: 1.3),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    // 1.3 هو أقصى مقياس يسمح به NavigationBar داخلياً — نتحقق عند الحد الأقصى.
    for (final String label in <String>['Accueil', 'Panier', 'Wallet', 'Commandes', 'Coupons', 'Compte']) {
      final Finder finder = find.descendant(of: find.byType(NavigationBar), matching: find.text(label));
      expect(finder, findsOneWidget, reason: 'tab "$label" must be rendered in French');
      final Size size = tester.getSize(finder);
      expect(size.height, lessThan(26), reason: 'tab "$label" must stay on a single line');
    }
    expect(tester.takeException(), isNull);
  });

  test('اللغة تبقى بعد تسجيل الخروج — لا تُمسح مع الجلسة', () async {
    final ProviderContainer c = await _container(stored: <String, Object>{'app_locale': 'fr'});
    addTearDown(c.dispose);

    expect(c.read(localeControllerProvider).languageCode, 'fr', reason: 'اللغة المحفوظة تُقرأ عند الإقلاع');
    await c.read(authControllerProvider.notifier).signOut();

    expect(c.read(localeControllerProvider).languageCode, 'fr', reason: 'signOut يجب ألا يمسح مفتاح اللغة');
    expect(c.read(sharedPreferencesProvider).getString('app_locale'), 'fr');
  });

  test('applyRemote يتبنى language_code من الحساب ويحفظه محلياً', () async {
    final ProviderContainer c = await _container();
    addTearDown(c.dispose);
    expect(c.read(localeControllerProvider).languageCode, 'ar');

    await c.read(localeControllerProvider.notifier).applyRemote('fr');
    expect(c.read(localeControllerProvider).languageCode, 'fr');
    expect(c.read(sharedPreferencesProvider).getString('app_locale'), 'fr', reason: 'يُحفظ محلياً حتى بعد الإقلاع بلا شبكة');

    // لغة مفقودة أو غير مدعومة ← الحالية تبقى كما هي.
    await c.read(localeControllerProvider.notifier).applyRemote(null);
    await c.read(localeControllerProvider.notifier).applyRemote('de');
    expect(c.read(localeControllerProvider).languageCode, 'fr');
  });

  test('تغيير اللغة وهو مسجّل يحفظها في profiles', () async {
    final _FakeAuthRepo repo = _FakeAuthRepo(const CustomerUser(id: 'u1', languageCode: 'ar'));
    final ProviderContainer c = await _container(auth: repo);
    addTearDown(c.dispose);
    c.read(authControllerProvider); // يثبّت مستمع المزامنة
    expect(c.read(authControllerProvider).status, isA<AuthAuthenticated>(), reason: 'الدفع يتم فقط أثناء تسجيل الدخول');
    expect(c.read(localeControllerProvider).languageCode, 'ar');

    await c.read(localeControllerProvider.notifier).toggle();
    await Future<void>.delayed(Duration.zero);

    expect(repo.savedLanguage, 'fr', reason: 'التغيير أثناء تسجيل الدخول يُرفع إلى profiles');
  });

  test('تغيير اللغة كزائر لا يستدعي حفظاً في profiles', () async {
    final _FakeAuthRepo repo = _FakeAuthRepo(null);
    final ProviderContainer c = await _container(auth: repo);
    addTearDown(c.dispose);
    c.read(authControllerProvider); // يثبّت مستمع المزامنة

    await c.read(localeControllerProvider.notifier).toggle();
    await Future<void>.delayed(Duration.zero);

    expect(repo.savedLanguage, isNull, reason: 'الزائر يحفظ محلياً فقط');
  });

  test('مزامنة السلة تدمج سلة الزائر مع سلة الحساب دون فقد أي عنصر', () async {
    final _FakeCartCloud cloud = _FakeCartCloud(<CartItem>[
      CartItem(productId: 'p1', name: 'طماطم مصبرة', price: 120, quantity: 3),
      CartItem(productId: 'p2', name: 'مياه معدنية', price: 180, quantity: 1),
    ]);
    final ProviderContainer c = await _container(
      cloud: cloud,
      cart: <CartItem>[
        CartItem(productId: 'p1', name: 'طماطم مصبرة', price: 120, quantity: 5),
        CartItem(productId: 'p3', name: 'سكر', price: 190, quantity: 2),
      ],
    );
    addTearDown(c.dispose);

    await c.read(cartControllerProvider.notifier).syncWithServer('u1');

    final List<CartItem> merged = c.read(cartControllerProvider).items;
    expect(merged.map((CartItem i) => i.productId).toSet(), <String>{'p1', 'p2', 'p3'}, reason: 'لا يُفقد عنصر من الطرفين');
    expect(merged.firstWhere((CartItem i) => i.productId == 'p1').quantity, 5, reason: 'الكمية القصوى تفوز — الدمج idempotent');
    expect(cloud.replacedUserId, 'u1', reason: 'النتيجة تُرفع إلى حساب المستخدم');
    expect(cloud.remote.map((CartItem i) => i.productId).toSet(), <String>{'p1', 'p2', 'p3'});
  });

  testWidgets('SessionSync يفرّغ بيانات المستخدم عند الخروج ويبقي اللغة', (WidgetTester tester) async {
    final ProviderContainer c = await _container(
      auth: _FakeAuthRepo(const CustomerUser(id: 'u1')),
      stored: <String, Object>{'app_locale': 'fr'},
      cart: <CartItem>[CartItem(productId: 'p1', name: 'طماطم مصبرة', price: 120, quantity: 2)],
    );
    addTearDown(c.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const SessionSync(child: SizedBox()))));
    await tester.pump();
    await tester.pump();

    expect(c.read(localeControllerProvider).languageCode, 'fr', reason: 'مزامنة الدخول لا تمسح اللغة المحلية');
    expect(c.read(cartControllerProvider).items, isNotEmpty, reason: 'سلة الزائر محفوظة قبل الخروج');

    await c.read(authControllerProvider.notifier).signOut();
    await tester.pump();
    await tester.pump();

    expect(c.read(localeControllerProvider).languageCode, 'fr', reason: 'signOut يبقي الإعدادات العامة وحدها');
    expect(c.read(cartControllerProvider).items, isEmpty, reason: 'السلة تُفرَغ عند الخروج');
    expect(c.read(couponsProvider).valueOrNull, isEmpty, reason: 'كوبونات الحساب تُفرَغ');
    expect(c.read(addressesControllerProvider).items, isEmpty, reason: 'عناوين الحساب تُفرَغ');
    expect(c.read(ordersControllerProvider).orders, isEmpty, reason: 'سجل الطلبات يُفرَغ');
  });

  test('المفضلة: تبديل فوري ينعكس على الحالة ويُرسل إلى الخادم', () async {
    final _FakeFavoritesRepository repo = _FakeFavoritesRepository(<String>{'p1'});
    final ProviderContainer c = await _container(user: const CustomerUser(id: 'u1'), favorites: repo);
    addTearDown(c.dispose);
    await c.read(favoritesProvider.future);
    expect(c.read(favoritesProvider).valueOrNull, contains('p1'));

    await c.read(favoritesProvider.notifier).toggle('p2');

    expect(c.read(favoritesProvider).valueOrNull, containsAll(<String>{'p1', 'p2'}), reason: 'الحالة تتضمن المنتج فوراً');
    expect(repo.lastProductId, 'p2');
    expect(repo.lastFavorite, isTrue, reason: 'الأفضلية أُرسلت للخادم');
  });

  test('المفضلة: تراجع صامت عن التبديل عند فشل قاعدة البيانات', () async {
    final _FakeFavoritesRepository repo = _FakeFavoritesRepository(<String>{'p1'})..fail = true;
    final ProviderContainer c = await _container(user: const CustomerUser(id: 'u1'), favorites: repo);
    addTearDown(c.dispose);
    await c.read(favoritesProvider.future);

    await c.read(favoritesProvider.notifier).toggle('p2');

    expect(repo.lastProductId, 'p2', reason: 'الطلب أُرسل فعلاً قبل أن يفشل');
    expect(c.read(favoritesProvider).valueOrNull, <String>{'p1'}, reason: 'تعود للحالة السابقة بلا رسالة خطأ');
  });

  test('المفضلة: الزائر لا يصدر أي طلب شبكة', () async {
    final _FakeFavoritesRepository repo = _FakeFavoritesRepository(<String>{'p1'});
    final ProviderContainer c = await _container(favorites: repo);
    addTearDown(c.dispose);

    await c.read(favoritesProvider.future);

    expect(c.read(favoritesProvider).valueOrNull, isEmpty, reason: 'مجموعة فارغة للزائر');
    expect(repo.fetchCalls, 0, reason: 'لا جلب قبل تسجيل الدخول');
  });

  testWidgets('قلب المفضلة يعكس حالة المستخدم على بطاقة المنتج', (WidgetTester tester) async {
    final _FakeFavoritesRepository repo = _FakeFavoritesRepository(<String>{'p1'});
    final ProviderContainer c = await _container(user: const CustomerUser(id: 'u1'), favorites: repo);
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: _host(
          Scaffold(
            body: Center(child: ProductCard(product: const Product(id: 'p1', name: 'طماطم', price: 120))),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget, reason: 'منتج مفضّل ← قلب ممتلئ');
    expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('Product.discountPercentage و toMap يعملان على الخصومات الصحيحة فقط', () {
    const Product discounted = Product(id: 'p1', name: 'زبدة', price: 200, oldPrice: 400);
    expect(discounted.discountPercentage, 50, reason: '400 → 200 = خصم 50%');

    expect(const Product(id: 'p2', name: 'سكر', price: 200).discountPercentage, 0, reason: 'بلا سعر قديم = بلا خصم');
    expect(const Product(id: 'p3', name: 'شاي', price: 300, oldPrice: 200).discountPercentage, 0, reason: 'سعر قديم أقل من الحالي لا يُعتبر خصماً');
    expect(const Product(id: 'p4', name: 'قهوة', price: 200, oldPrice: 0).discountPercentage, 0, reason: 'قسمة على صفر محمية');

    // toMap → fromJson دورة كاملة تحافظ على حقل الخصم والصورة.
    final Map<String, dynamic> map = discounted.toMap();
    expect(map['old_price'], 400);
    expect(map['image_url'], isNull);
    expect(Product.fromJson(map).discountPercentage, 50);
  });

  test('Formatters تعرض أرقاماً لاتينية دائماً — لا أرقام هندية في أي لغة', () async {
    // بيانات تواريخ العربية (أسماء الأشهر) تُحمَّل عند الطلب.
    await initializeDateFormatting('ar');
    final String ar = Formatters.price(10000, 'ar');
    expect(ar, endsWith(' د.ج'));
    expect(ar, isNot(contains(RegExp('[٠-٩]'))), reason: 'لا أرقام هندية في السعر العربي');
    expect(ar, isNot(contains('٬')), reason: 'لا فاصل آلاف عربي هجين');
    expect(ar, contains('10'), reason: 'الأرقام لاتينية 0-9');

    final String fr = Formatters.price(1500, 'fr');
    expect(fr.endsWith(' DA'), isTrue);
    expect(fr, isNot(contains(RegExp('[٠-٩]'))));

    expect(Formatters.plainNumber(12345, 'ar'), isNot(contains(RegExp('[٠-٩]'))));
    final String whenStr = Formatters.dateTime(DateTime(2026, 10, 7, 9, 5), 'ar');
    expect(whenStr, isNot(contains(RegExp('[٠-٩]'))), reason: 'تاريخ ووقت المحفظة بأرقام لاتينية');
    expect(whenStr.codeUnitAt(0), inInclusiveRange(0x30, 0x39), reason: 'التاريخ يبدأ برقم لاتيني');
  });

  testWidgets('بطاقة المنتج: شارة الخصم التلقائية والسعر القديم المشطوب بجانب الحالي', (WidgetTester tester) async {
    final ProviderContainer c = await _container();
    addTearDown(c.dispose);
    // اللغة الفرنسية لتأكيد النصوص بأرقام لاتينية حتمية.
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: _host(
        Scaffold(body: Center(child: ProductCard(product: const Product(id: 'p9', name: 'زبدة', price: 200, oldPrice: 400)))),
        locale: const Locale('fr'),
      ),
    ));
    await tester.pump();

    expect(find.text('-50%'), findsOneWidget, reason: 'الشارة تعرض نسبة الخصم المحسوبة تلقائياً');
    final Text struck = tester.widget<Text>(find.text('400 DA'));
    expect(struck.style?.decoration, TextDecoration.lineThrough, reason: 'السعر القديم مشطوب بجانب السعر الحالي');
    expect(find.text('200 DA'), findsOneWidget, reason: 'السعر الحالي يبقى بارزاً');
    expect(tester.takeException(), isNull);
  });

  testWidgets('عند إغلاق المتجر: زر «إضافة للسلة» معطّل', (WidgetTester tester) async {
    final ProviderContainer closed = await _container(storeStatus: StoreStatus.closed);
    addTearDown(closed.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: closed, child: _host(Scaffold(body: Center(child: ProductCard(product: const Product(id: 'p1', name: 'زبدة', price: 300)))))));
    await tester.pump();
    await tester.pump();

    final FilledButton button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull, reason: 'الزر معطّل عندما يكون المتجر مغلقاً');

    // النقر على بطاقة المنتج (حتى لو كان الزر معطّلاً) يعرض رسالة الإغلاق
    // بدل رسالة النجاح القديمة.
    await tester.tap(find.text('زبدة'));
    await tester.pump();
    await tester.pump();
    expect(find.text('المتجر مغلق حالياً — لا يمكن إضافة المنتجات إلى السلة'), findsOneWidget, reason: 'رسالة إغلاق واضحة بدل تمت الإضافة');
    expect(find.textContaining('تمت الإضافة'), findsNothing);
    expect(tester.takeException(), isNull);

    // متجر مفتوح (الافتراضي): الزر يعمل.
    final ProviderContainer open = await _container(storeStatus: StoreStatus.open);
    addTearDown(open.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: open, child: _host(Scaffold(body: Center(child: ProductCard(product: const Product(id: 'p1', name: 'زبدة', price: 300)))))));
    await tester.pump();
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull, reason: 'الزر مفعّل عندما يكون المتجر مفتوحاً');
    expect(tester.takeException(), isNull);
  });

  testWidgets('شاشة المفضلة تعرض المنتجات المفضّلة على الشبكة', (WidgetTester tester) async {
    final ProviderContainer c = await _container(
      user: const CustomerUser(id: 'u1'),
      favorites: _FakeFavoritesRepository(<String>{'p1'}),
      catalog: _FakeCatalogRepository(),
    );
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: _host(const FavoritesScreen())),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.byType(ProductCard), findsOneWidget, reason: 'في المفضلة منتج واحد فقط');
    expect(find.text('طماطم مصبرة 400غ'), findsWidgets, reason: 'الاسم يُجلب من الكتالوج لا من المعرّفات');
    expect(tester.takeException(), isNull);
  });

  testWidgets('شاشة المفضلة تعرض حالة الفراغ عند عدم وجود مفضلة', (WidgetTester tester) async {
    final ProviderContainer c = await _container(
      user: const CustomerUser(id: 'u1'),
      favorites: _FakeFavoritesRepository(<String>{}),
    );
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: _host(const FavoritesScreen())),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(EmptyStateView), findsOneWidget, reason: 'فراغ صريح بدل شاشة بيضاء');
    expect(find.byType(ProductCard), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('قسم التواصل الاجتماعي: 3 منصات بأيقونات موحّدة وبلا رابط نصي', (WidgetTester tester) async {
    final ProviderContainer c = await _container(
      socialLinks: _FakeSocialLinksRepository(const <String, String>{
        'facebook': 'https://www.facebook.com/atogamarket',
        'instagram': 'https://www.instagram.com/atogamarket',
        'tiktok': 'https://www.tiktok.com/@atogamarket',
      }),
    );
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: _host(Scaffold(body: ListView(children: [const SocialLinksSection()]))),
      ),
    );
    await tester.pump();
    await tester.pump();

    // اسم المنصة فقط — بالعربية هنا لأن اللغة الافتراضية ar.
    expect(find.text('فيسبوك'), findsOneWidget);
    expect(find.text('إنستغرام'), findsOneWidget);
    expect(find.text('تيك توك'), findsOneWidget);

    // القاعدة 1: منع عرض الرابط النصي إطلاقاً.
    expect(find.textContaining('http'), findsNothing, reason: 'لا يظهر أي رابط');
    expect(find.textContaining('facebook.com'), findsNothing, reason: 'لا يظهر أي رابط');

    // القاعدة 2: أيقونات Font Awesome ملوّنة بلون التطبيق لا بلون العلامة.
    final Iterable<FaIcon> icons = tester.widgetList<FaIcon>(find.byType(FaIcon));
    expect(icons.length, 3, reason: 'أيقونة واحدة لكل منصة');
    expect(
      icons.every((FaIcon icon) => icon.color == AppColors.primary),
      isTrue,
      reason: 'اللون موحّد بـ AppColors.primary',
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('قسم التواصل الاجتماعي: تنبيه عند غياب الرابط بدل الصمت', (WidgetTester tester) async {
    final ProviderContainer c = await _container(
      socialLinks: _FakeSocialLinksRepository(const <String, String>{'facebook': ''}),
    );
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: _host(Scaffold(body: ListView(children: [const SocialLinksSection()]))),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('فيسبوك'));
    await tester.pump();

    expect(find.text('الرابط غير متوفر حالياً'), findsOneWidget, reason: 'يُنبّه المستخدم بدل التجاهل');
    expect(tester.takeException(), isNull);
  });

  testWidgets('تعديل الملف الشخصي: الحفظ بعد فجوة await بلا استثناءات', (WidgetTester tester) async {
    final ProviderContainer c = await _container(user: const CustomerUser(id: 'u1'));
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: _host(const ProfileScreen())),
    );
    await tester.pump();

    // فتح حوار تعديل الملف الشخصي.
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2), reason: 'حقلان: الاسم والهاتف');

    await tester.enterText(find.byType(TextFormField).first, 'محمد أمين');
    await tester.pump();

    // الحفظ ← فجوة await داخل updateProfile ثم إشعار.
    await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget, reason: 'إشعار نجاح الحفظ يظهر');
    expect(
      tester.takeException(),
      isNull,
      reason: 'لا استثناءات — بما فيها InheritedElement._dependents.isEmpty',
    );
  });

  testWidgets('قسم الدعم الفني: عنوانان فقط بلا عرض أي رقم', (WidgetTester tester) async {
    final ProviderContainer c = await _container(
      socialLinks: _FakeSocialLinksRepository(const <String, String>{
        'contact_phone': '+213000000000',
        'whatsapp_number': '+213000000000',
      }),
    );
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: _host(Scaffold(body: ListView(children: [const SupportSection()]))),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('اتصل بنا'), findsOneWidget);
    expect(find.text('واتساب'), findsOneWidget);

    // شرط التصميم: لا يُعرض الرقم إطلاقاً.
    expect(find.textContaining('213'), findsNothing, reason: 'منع عرض رقم الهاتف');
    expect(find.textContaining('+213'), findsNothing, reason: 'منع عرض رقم الهاتف');

    // شرط التناسق: الأيقونات ملوّنة بلون التطبيق.
    final Icon phone = tester.widget<Icon>(find.byIcon(Icons.phone_outlined));
    expect(phone.color, AppColors.primary, reason: 'أيقونة الهاتف باللون الأساسي');
    final FaIcon whatsapp = tester.widget<FaIcon>(find.byWidgetPredicate((Widget w) => w is FaIcon));
    expect(whatsapp.color, AppColors.primary, reason: 'أيقونة واتساب باللون الأساسي');

    expect(tester.takeException(), isNull);
  });

  testWidgets('قسم الدعم الفني: تنبيه عند غياب الرقم بدل الانهيار', (WidgetTester tester) async {
    final ProviderContainer c = await _container(
      socialLinks: _FakeSocialLinksRepository(const <String, String>{}),
    );
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: _host(Scaffold(body: ListView(children: [const SupportSection()]))),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('اتصل بنا'));
    await tester.pump();

    expect(
      find.text('رقم التواصل غير متوفر حالياً'),
      findsOneWidget,
      reason: 'تنبيه بدل الانهيار',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('شاشة العنوان: الحقول التفصيلية مُلغيتة والحفظ محجوب بلا حيّ', (WidgetTester tester) async {
    // النموذج أطول من النافذة الافتراضية (800×600) — نوسعها حتى يُبنى
    // كامل النموذج وإلا لن يبني ListView الزر السفلي.
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final ProviderContainer c = await _container(zones: const <DeliveryZone>[
      DeliveryZone(id: 'z1', name: 'حي السلام', deliveryFee: 200),
    ]);
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: _host(const AddressFormScreen())),
    );
    await tester.pump();
    await tester.pump();

    // 1) الحقول التفصيلية أُلغيت تماماً — الهاتف والملاحظات فقط.
    expect(find.byType(TextFormField), findsNWidgets(2), reason: 'الهاتف والملاحظات فقط');
    expect(find.text('الشارع'), findsNothing, reason: 'حقل الشارع محذوف');
    expect(find.text('العمارة / المنزل'), findsNothing, reason: 'حقل العمارة محذوف');
    expect(find.text('الطابق / الشقة'), findsNothing, reason: 'حقل الطابق محذوف');

    // 2) قائمة مناطق التوصيل حاضرة.
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget, reason: 'قائمة الأحياء');

    // 3) الحفظ محجوب: لا منطقة توصيل محددة.
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'حفظ'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
    await tester.pump();

    expect(find.text('هذا الحقل مطلوب'), findsWidgets, reason: 'خطأ تحقق على الحي');
    expect(find.text('حدد موقع التسليم على الخريطة'), findsNothing, reason: 'محجوب قبل فحص الموقع');
    expect(tester.takeException(), isNull);
  });

  testWidgets('شاشة العنوان: الموقع اختياري — يُحفظ بلا تحديد دبوس', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final ProviderContainer c = await _container(zones: const <DeliveryZone>[
      DeliveryZone(id: 'z1', name: 'حي السلام', deliveryFee: 200),
    ]);
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: _host(AddressFormScreen(
          existing: Address(id: 'a1', label: 'home', street: '', building: '', phone: '0555123456', deliveryZoneId: 'z1'),
        )),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'حفظ'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
    await tester.pump();

    // الحفظ تعدّي بوابتي الحي والهاتف ثم يذهب للخادم — لا بوابة موقع.
    expect(find.byType(SnackBar), findsOneWidget, reason: '_save شُغّل فعلاً رغم غياب الإحداثيات');
    expect(find.text('حدد موقع التسليم على الخريطة'), findsNothing, reason: 'الموقع اختياري تماماً');
    expect(tester.takeException(), isNull);
  });

  test('checkoutDeliveryFee: رسوم المنطقة + حد التوصيل المجاني + العنوان القديم', () {
    const List<DeliveryZone> zones = <DeliveryZone>[
      DeliveryZone(id: 'z1', name: 'حي السلام', deliveryFee: 200),
      DeliveryZone(id: 'z2', name: 'وسط المدينة', deliveryFee: 350),
    ];

    // المنطقة المختارة ← رسومها لا القيمة الثابتة 200.
    expect(checkoutDeliveryFee(zoneId: 'z2', zones: zones, subtotalAfterDiscount: 500), 350);
    // عنوان قديم بلا منطقة ← القيمة الافتراضية.
    expect(checkoutDeliveryFee(zoneId: null, zones: zones, subtotalAfterDiscount: 500), AppConstants.deliveryFee);
    // منطقة حُذفت من لوحة الإدارة ← الافتراضية بدل انهيار الحساب.
    expect(checkoutDeliveryFee(zoneId: 'zz', zones: zones, subtotalAfterDiscount: 500), AppConstants.deliveryFee);
    // فوق حد «التوصيل المجاني» ← صفر مهما كانت المنطقة.
    expect(
      checkoutDeliveryFee(zoneId: 'z2', zones: zones, subtotalAfterDiscount: AppConstants.freeDeliveryThreshold),
      0,
      reason: 'عرض التوصيل المجاني يعلّم رسوم أي منطقة',
    );
  });

  testWidgets('شاشة العنوان: الهاتف مسحوباً من البروفايل والعنوان يفضّل رقمه', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final ProviderContainer c = await _container(
      user: const CustomerUser(id: 'u1', phone: '0555123456'),
      zones: const <DeliveryZone>[DeliveryZone(id: 'z1', name: 'حي السلام', deliveryFee: 200)],
    );
    addTearDown(c.dispose);

    // (1) عنوان جديد ← يرث هاتف الملف الشخصي.
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _host(const AddressFormScreen())));
    await tester.pump();
    await tester.pump();
    expect(_fieldTexts(tester), contains('0555123456'), reason: 'عنوان جديد يرث هاتف البروفايل');

    // (2) عنوان يحمل رقمه الخاص ← يُفضّل ولا يُستبدل.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: _host(AddressFormScreen(
          // مفتاح مختلف: وإلا يُعاد استخدام الـ State فلا يُستدعى initState
          // ويبقى نص الهاتف من الخطوة الأولى.
          key: const ValueKey<String>('edit-address'),
          existing: const Address(id: 'a1', label: 'home', street: '', building: '', phone: '0987654321'),
        )),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(_fieldTexts(tester), contains('0987654321'), reason: 'رقم العنوان يُفضّل');
    expect(_fieldTexts(tester), isNot(contains('0555123456')), reason: 'لا يُستبدل رقم العنوان برقمه الخاص');
    expect(tester.takeException(), isNull);
  });
}
