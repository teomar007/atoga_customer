import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_providers.dart';
import '../data/order_repository.dart';
import '../domain/order.dart';

@immutable
class OrdersState {
  const OrdersState({this.orders = const <Order>[], this.loading = true, this.error});

  final List<Order> orders;
  final bool loading;
  final String? error;

  List<Order> get active => orders.where((Order o) => o.isActive).toList();

  List<Order> get past => orders.where((Order o) => !o.isActive).toList();

  bool get isEmpty => !loading && orders.isEmpty;

  OrdersState copyWith({List<Order>? orders, bool? loading, String? error, bool clearError = false}) {
    return OrdersState(orders: orders ?? this.orders, loading: loading ?? this.loading, error: clearError ? null : (error ?? this.error));
  }
}

class OrdersController extends Notifier<OrdersState> {
  StreamSubscription<Order>? _watch;

  OrderRepository get _repo => ref.read(orderRepositoryProvider);

  @override
  OrdersState build() {
    ref.onDispose(() => _watch?.cancel());
    return const OrdersState();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final List<Order> orders = await _repo.fetchOrders();
      state = state.copyWith(orders: orders, loading: false);
    } on Object catch (error) {
      debugPrint('OrdersController.load: $error');
      state = state.copyWith(loading: false, error: 'ordersLoadFailed');
    }
  }

  /// تحديث طلب واحد في القائمة (بعد إشعار فوري أو إعادة تحميل).
  void upsert(Order order) {
    final List<Order> next = List<Order>.of(state.orders);
    final int index = next.indexWhere((Order o) => o.id == order.id);
    if (index >= 0) {
      next[index] = order;
    } else {
      next.insert(0, order);
    }
    state = state.copyWith(orders: next);
  }

  /// تفعيل التتبع الحي لطلب محدد (Sprint 5). يعيد الاشتراك ليلغيه المتصل
  /// (الشاشة) عند إزالتها — قراءة `ref` داخل `dispose()` غير مسموح بها.
  StreamSubscription<Order> watch(String orderId) {
    _watch?.cancel();
    _watch = _repo.watchOrder(orderId).listen((Order order) => upsert(order), onError: (Object error) => debugPrint('watchOrder: $error'));
    return _watch!;
  }

  /// إلغاء الطلب مع تمييز سبب الرفض ليعرضه الزبون بدقة (بدأ التجهيز/خطأ).
  ///
  /// [CancelOrderOutcome.statusChanged] تعني أن الطلب خرج من مرحلة
  /// `received` في الخادم فلا يصح إلغاؤه.
  Future<CancelOrderOutcome> cancel(String orderId) async {
    try {
      final bool ok = await _repo.cancelOrder(orderId);
      if (ok) {
        await load();
        return CancelOrderOutcome.cancelled;
      }
      return CancelOrderOutcome.statusChanged;
    } on Object catch (error) {
      debugPrint('OrdersController.cancel: $error');
      return CancelOrderOutcome.failed;
    }
  }

  /// تفريغ سجل الطلبات عند تسجيل الخروج (البيانات تبقى في الخادم).
  void reset() => state = const OrdersState(loading: false);
}

final orderRepositoryProvider = Provider<OrderRepository>((Ref ref) => SupabaseOrderRepository(ref.watch(supabaseClientProvider)));

final ordersControllerProvider = NotifierProvider<OrdersController, OrdersState>(OrdersController.new);

/// نتيجة محاولة إلغاء الطلب: نجح الإلغاء، رُفض لأن الحالة تغيّرت في الخادم
/// (بدأ التجهيز/التوصيل)، أو فشل الاتصال.
enum CancelOrderOutcome { cancelled, statusChanged, failed }

/// طلب واحد مع تتبّعه الحي عند الحاجة.
final orderDetailProvider = FutureProvider.family.autoDispose<Order, String>((Ref ref, String id) async {
  return ref.watch(orderRepositoryProvider).fetchOrder(id);
});
