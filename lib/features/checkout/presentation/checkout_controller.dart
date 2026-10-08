import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../cart/domain/cart_item.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/presentation/orders_controller.dart';
import '../data/address_repository.dart';
import '../domain/address.dart';
import '../domain/delivery_zone.dart';
import '../../wallet/presentation/wallet_provider.dart';
import 'delivery_zones_provider.dart';

final addressRepositoryProvider = Provider<AddressRepository>((Ref ref) => SupabaseAddressRepository(ref.watch(supabaseClientProvider)));

// ============ العناوين ============

class AddressesState {
  const AddressesState({this.items = const <Address>[], this.loading = true, this.error});

  final List<Address> items;
  final bool loading;
  final String? error;

  bool get isEmpty => !loading && items.isEmpty;

  AddressesState copyWith({List<Address>? items, bool? loading, String? error, bool clearError = false}) {
    return AddressesState(items: items ?? this.items, loading: loading ?? this.loading, error: clearError ? null : (error ?? this.error));
  }
}

class AddressesController extends Notifier<AddressesState> {
  @override
  AddressesState build() => const AddressesState();

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final List<Address> items = await ref.read(addressRepositoryProvider).fetchAll();
      state = state.copyWith(items: items, loading: false);
    } on Object catch (error) {
      debugPrint('AddressesController.load: $error');
      state = state.copyWith(loading: false, error: 'noSavedAddresses');
    }
  }

  Future<Address> save(Address address) async {
    final Address saved = await ref.read(addressRepositoryProvider).save(address);
    await load();
    return saved;
  }

  Future<void> remove(String id) async {
    await ref.read(addressRepositoryProvider).delete(id);
    await load();
  }

  /// تفريغ العناوين عند تسجيل الخروج — لا تُعرض عناوين حساب سابق.
  void reset() => state = const AddressesState(loading: false);
}

final addressesControllerProvider = NotifierProvider<AddressesController, AddressesState>(AddressesController.new);

// ============ إرسال الطلب ============

/// طرق الدفع المعتمدة: الدفع عند الاستلام، أو الخصم من المحفظة الإلكترونية.
enum PaymentMethod {
  cod('cod'),
  wallet('wallet');

  const PaymentMethod(this.wire);

  final String wire;
}

class CheckoutState {
  const CheckoutState({
    this.submitting = false,
    this.error,
    this.errorDetail,
    this.address,
    this.deliveryFee = AppConstants.deliveryFee,
    this.paymentMethod = PaymentMethod.cod,
  });

  final bool submitting;
  final String? error;

  /// السبب الحقيقي القادم من الخادم — يُعرض في SnackBar أثناء التطوير
  /// بدل رسالة عامة تُخفي علّة الفشل.
  final String? errorDetail;

  /// عنوان التوصيل المختار — مصدر الحقيقة لحساب رسوم التوصيل ديناميكياً.
  final Address? address;

  /// رسوم التوصيل لمنطقة العنوان المختار؛ تتغيّر فور اختيار عنوان جديد
  /// أو وصول قائمة المناطق أو تغيّر صافي السلة (كوبون/كمية).
  final double deliveryFee;

  /// طريقة الدفع المختارة — التحقق من كفاية الرصيد عند اختيار المحفظة.
  final PaymentMethod paymentMethod;

  CheckoutState copyWith({
    bool? submitting,
    String? error,
    String? errorDetail,
    bool clearError = false,
    Address? address,
    bool clearAddress = false,
    double? deliveryFee,
    PaymentMethod? paymentMethod,
  }) {
    return CheckoutState(
      submitting: submitting ?? this.submitting,
      error: clearError ? null : (error ?? this.error),
      errorDetail: clearError ? null : (errorDetail ?? this.errorDetail),
      address: clearAddress ? null : (address ?? this.address),
      deliveryFee: deliveryFee ?? this.deliveryFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

/// ملخص الطلبية كما يُرسل إلى الخادم.
@immutable
class OrderTotals {
  const OrderTotals({required this.subtotal, required this.discount, required this.delivery, required this.total});

  final double subtotal;
  final double discount;
  final double delivery;
  final double total;
}

class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    // إعادة حساب فورية عند أي تغيّر يمسّ الرسوم: وصول مناطق التوصيل
    // (تحميل متأخر) أو تغيّر السلة (كوبون/كمية) لأن الإجمالي يعتمد على الصافي.
    ref.listen(deliveryZonesProvider, (_, _) => _recompute());
    ref.listen<CartState>(cartControllerProvider, (_, CartState cart) => _recompute(cart));
    return const CheckoutState();
  }

  /// يحدّد عنوان التوصيل ويحسب رسوم منطقته فوراً.
  void selectAddress(Address? address) {
    state = state.copyWith(address: address, clearAddress: address == null);
    _recompute();
  }

  /// اختيار طريقة الدفع مع تحقق فوري من كفاية رصيد المحفظة:
  /// إن لم يكفِ الرصيد تُعاد الطريقة تلقائياً إلى الدفع عند الاستلام
  /// وتُعرض رسالة في الواجهة (إرجاع `false`).
  Future<bool> selectPaymentMethod(PaymentMethod method) async {
    if (method == PaymentMethod.wallet) {
      final double balance = await _availableBalance();
      if (balance < _currentTotal()) {
        state = state.copyWith(paymentMethod: PaymentMethod.cod);
        return false;
      }
    }
    state = state.copyWith(paymentMethod: method);
    return true;
  }

  double _currentTotal() {
    final CartState cart = ref.read(cartControllerProvider);
    return cart.subtotal - cart.discount + state.deliveryFee;
  }

  Future<double> _availableBalance() async {
    try {
      return await ref.read(walletBalanceProvider.future);
    } on Object catch (error) {
      debugPrint('wallet balance unavailable: $error');
      return 0;
    }
  }

  /// يعيد حساب الرسوم من: العنوان + مناطق التوصيل + صافي السلة.
  void _recompute([CartState? cartOverride]) {
    final CartState cart = cartOverride ?? ref.read(cartControllerProvider);
    final List<DeliveryZone> zones = ref.read(deliveryZonesProvider).valueOrNull ?? const <DeliveryZone>[];
    state = state.copyWith(
      deliveryFee: checkoutDeliveryFee(
        zoneId: state.address?.deliveryZoneId,
        zones: zones,
        subtotalAfterDiscount: cart.subtotal - cart.discount,
      ),
    );
  }

  /// يرسل الطلب وعناصره ثم يمسح السلة. يعيد معرّف الطلب أو null عند الفشل.
  Future<String?> submit({required Address address, required List<CartItem> items, required OrderTotals totals, String? couponCode, PaymentMethod paymentMethod = PaymentMethod.cod}) async {
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final String id = await ref.read(orderRepositoryProvider).createOrder(NewOrderPayload(address: address.toJson(), items: items, subtotal: totals.subtotal, discount: totals.discount, deliveryFee: totals.delivery, total: totals.total, couponCode: couponCode, paymentMethod: paymentMethod.wire));
      await ref.read(cartControllerProvider.notifier).clear();
      // رصيد المحفظة وسجلها تغيّرا بعد دفع ناجح — أعد قراءتهما فوراً.
      if (paymentMethod == PaymentMethod.wallet) {
        ref.invalidate(walletBalanceProvider);
        ref.invalidate(walletTransactionsProvider);
      }
      state = state.copyWith(submitting: false);
      return id;
    } on Object catch (error, stack) {
      // السبب الحقيقي بسطرين — لا نموّهه خلف رسالة عامة أثناء التطوير.
      debugPrint('ORDER_ERROR: $error\n$stack');
      state = state.copyWith(submitting: false, error: 'orderFailed', errorDetail: '$error');
      return null;
    }
  }
}

final checkoutControllerProvider = NotifierProvider<CheckoutController, CheckoutState>(CheckoutController.new);
