import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_providers.dart';
import '../../../core/services/cart_storage.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../home/domain/product.dart';
import '../../home/presentation/store_status_provider.dart';
import '../domain/cart_item.dart';
import '../domain/coupon.dart';

/// ملخّص مالي لحظي (يعرضه ملخص السلة وشاشة الدفع).
class CartTotals {
  const CartTotals({
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
  });

  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;

  static const CartTotals empty = CartTotals(
    subtotal: 0,
    discount: 0,
    deliveryFee: 0,
    total: 0,
  );
}

/// حالة السلة: تُحفظ في Hive بعد كل تغيير (Sprint 3).
class CartState {
  const CartState({
    this.items = const <CartItem>[],
    this.coupon,
    this.couponError = false,
    this.couponCodeInput,
  });

  final List<CartItem> items;
  final Coupon? coupon;

  /// خطأ إدخال الكوبون لعرض رسالة فورية.
  final bool couponError;

  final String? couponCodeInput;

  bool get isEmpty => items.isEmpty;

  /// عدد القطع الإجمالي (يظهر في الشارة على أيقونة السلة).
  int get totalQuantity => items.fold<int>(0, (int sum, CartItem i) => sum + i.quantity);

  double get subtotal => items.fold<double>(0, (double sum, CartItem i) => sum + i.lineTotal);

  double get discount => coupon?.discountFor(subtotal) ?? 0;

  /// التوصيل مجاني فوق الحد بعد تطبيق الخصم.
  double get deliveryFee {
    final double net = subtotal - discount;
    return net >= _freeDeliveryThreshold ? 0 : _deliveryFee;
  }

  double get total => (subtotal - discount) + deliveryFee;

  static const double _freeDeliveryThreshold = 3000;
  static const double _deliveryFee = 200;

  int quantityOf(String productId) {
    for (final CartItem item in items) {
      if (item.productId == productId) {
        return item.quantity;
      }
    }
    return 0;
  }

  CartState copyWith({
    List<CartItem>? items,
    Coupon? coupon,
    bool clearCoupon = false,
    bool? couponError,
    String? couponCodeInput,
  }) {
    return CartState(
      items: items ?? this.items,
      coupon: clearCoupon ? null : (coupon ?? this.coupon),
      couponError: couponError ?? false,
      couponCodeInput: couponCodeInput,
    );
  }
}

final cartStorageProvider = Provider<CartStore>(
  (Ref ref) => throw UnimplementedError('cartStorageProvider must be overridden'),
);

/// مزوّد السلة — مصدر الحقيقة الوحيد لعدد المنتجات والمجاميع.
class CartController extends Notifier<CartState> {
  CartStore get _storage => ref.read(cartStorageProvider);

  /// رفع مؤجّل للخادم: يمنع طوفان الطلبات عند الضغط المتكرر (+/-) ويتفادى
  /// سباق «حذف + إدراج» بين رفعين متزامنين.
  Timer? _cloudDebounce;

  @override
  CartState build() {
    ref.onDispose(() => _cloudDebounce?.cancel());
    // استرجاع فوري من الذاكرة المحلية عند الإقلاع.
    return CartState(items: _safeRead());
  }

  List<CartItem> _safeRead() {
    try {
      return _storage.readAll();
    } on Object {
      return const <CartItem>[];
    }
  }

  Future<void> _persist(CartState next) async {
    state = next;
    try {
      await _storage.writeAll(next.items);
    } on Object {
      // فشل التخزين لا يصحّر السلة من الذاكرة.
    }
    _scheduleCloudPush();
  }

  /// يجدول رفعاً واحداً بعد آخر تعديل (600ms صمت). الزائر بلا جدولة إطلاقاً.
  void _scheduleCloudPush() {
    _cloudDebounce?.cancel();
    final String? userId = _currentUserId();
    if (userId == null) {
      return;
    }
    _cloudDebounce = Timer(const Duration(milliseconds: 600), () {
      _cloudDebounce = null;
      unawaited(_pushCloud(userId, state.items));
    });
  }

  /// معرّف صاحب السلة: `null` عند الزائر **وعند غياب تهيئة Supabase**
  /// (اختبارات الوحدة تُزدّي المخزن المحلي فقط) — فالحفظ المحلي وحده يكفي
  /// هناك، وقراءة المزوّد في هذه الحالة ترمي `UnimplementedError`.
  String? _currentUserId() {
    try {
      return ref.read(currentUserProvider)?.id;
    } on Object {
      return null;
    }
  }

  /// رفع الحالة الحالية إلى `cart_items`. الفشل لا يُبطل الإضافة: السلة
  /// المحلية تبقى مصدر الحقيقة وتُرفع لاحقاً في المزامنة القادمة.
  Future<void> _pushCloud(String userId, List<CartItem> items) async {
    try {
      await ref.read(cartCloudStoreProvider).replace(userId, items);
    } on Object catch (error) {
      debugPrint('Cart cloud push failed: $error');
    }
  }

  /// **مزامنة الدخول**: يمزج سلة الزائر المحلية مع سلة الحساب في الخادم
  /// ثم يرفع النتيجة — لا تُمسح عناصر الزائر أبداً.
  ///
  /// قاعدة الدمج `max(الكمية)` لا `المجموع`: الدمج idempotent، وإلا
  /// لتضاعفت كميات السلة مع كل تسجيل دخول.
  Future<void> syncWithServer(String userId) async {
    _cloudDebounce?.cancel();
    try {
      final List<CartItem> remote = await ref.read(cartCloudStoreProvider).fetch(userId);
      final CartState merged = state.copyWith(items: _mergeCart(local: state.items, remote: remote));
      state = merged;
      await _storage.writeAll(merged.items);
      await ref.read(cartCloudStoreProvider).replace(userId, merged.items);
    } on Object catch (error) {
      debugPrint('CartController.syncWithServer: $error');
    }
  }

  /// يدمج القائمتين: منتج فيهما معاً ← أقصى كمية، وفي إحداهما فقط ← يبقى.
  List<CartItem> _mergeCart({required List<CartItem> local, required List<CartItem> remote}) {
    final Map<String, CartItem> byId = <String, CartItem>{};
    for (final CartItem item in remote) {
      byId[item.productId] = item;
    }
    for (final CartItem item in local) {
      final CartItem? existing = byId[item.productId];
      if (existing == null || item.quantity > existing.quantity) {
        byId[item.productId] = item;
      }
    }
    return byId.values.toList(growable: false);
  }

  /// إضافة منتج (أو زيادة الكمية إذا كان موجوداً).
  Future<void> addProduct(Product product, {int quantity = 1}) async {
    // طبقة دفاعية: المتجر مغلق فلا تُضاف (الواجهة تعطّل الزر أيضاً).
    if (ref.read(storeStatusProvider) == StoreStatus.closed) {
      return;
    }
    final List<CartItem> items = List<CartItem>.of(state.items);
    final int index = items.indexWhere((CartItem i) => i.productId == product.id);
    if (index >= 0) {
      final CartItem existing = items[index];
      items[index] = existing.copyWith(
        quantity: (existing.quantity + quantity).clamp(1, 99),
      );
    } else {
      items.add(CartItem.fromProduct(product, quantity: quantity.clamp(1, 99)));
    }
    await _persist(state.copyWith(items: items));
  }

  /// زيادة كمية عنصر قائم. يعيد `false` إذا لم يوجد.
  Future<bool> increment(String productId) async {
    if (ref.read(storeStatusProvider) == StoreStatus.closed) {
      return false;
    }
    final int index = _indexOf(productId);
    if (index < 0) {
      return false;
    }
    final List<CartItem> items = List<CartItem>.of(state.items);
    final CartItem item = items[index];
    if (item.quantity >= 99) {
      return true;
    }
    items[index] = item.copyWith(quantity: item.quantity + 1);
    await _persist(state.copyWith(items: items));
    return true;
  }

  /// إنقاص الكمية؛ عند الوصول إلى صفر يُحذف العنصر تلقائياً.
  Future<void> decrement(String productId) async {
    final int index = _indexOf(productId);
    if (index < 0) {
      return;
    }
    final List<CartItem> items = List<CartItem>.of(state.items);
    final CartItem item = items[index];
    if (item.quantity <= 1) {
      items.removeAt(index);
    } else {
      items[index] = item.copyWith(quantity: item.quantity - 1);
    }
    await _persist(state.copyWith(items: items));
  }

  Future<void> setQuantity(String productId, int quantity) async {
    if (quantity < 1) {
      await remove(productId);
      return;
    }
    final int index = _indexOf(productId);
    if (index < 0) {
      return;
    }
    final List<CartItem> items = List<CartItem>.of(state.items);
    items[index] = items[index].copyWith(quantity: quantity.clamp(1, 99));
    await _persist(state.copyWith(items: items));
  }

  Future<void> remove(String productId) async {
    final List<CartItem> items = state.items
        .where((CartItem i) => i.productId != productId)
        .toList();
    await _persist(state.copyWith(items: items));
  }

  /// استعادة عنصر بعد "تراجع" عن الحذف.
  Future<void> restore(CartItem item) async {
    await addProduct(
      Product(
        id: item.productId,
        name: item.name,
        nameFr: item.nameFr,
        price: item.price,
        imageUrl: item.imageUrl,
        unit: item.unit,
      ),
      quantity: item.quantity,
    );
  }

  Future<void> clear() async {
    await _persist(const CartState());
    try {
      await _storage.clear();
    } on Object {
      // تجاهل
    }
  }

  /// تطبيق كوبون محلي. يُعاد `false` عند غير صلاحيته.
  Future<bool> applyLocalCoupon(String rawCode) async {
    final String code = rawCode.trim().toUpperCase();
    final Coupon? coupon = LocalCoupons.byCode[code];
    if (coupon == null || !coupon.isValidFor(state.subtotal)) {
      await _persist(
        state.copyWith(couponError: true, couponCodeInput: rawCode),
      );
      return false;
    }
    await _persist(
      state.copyWith(coupon: coupon, couponError: false, couponCodeInput: code),
    );
    return true;
  }

  Future<void> clearCoupon() async {
    await _persist(state.copyWith(clearCoupon: true, couponCodeInput: ''));
  }

  int _indexOf(String productId) {
    return state.items.indexWhere((CartItem i) => i.productId == productId);
  }
}

final cartControllerProvider =
    NotifierProvider<CartController, CartState>(CartController.new);
