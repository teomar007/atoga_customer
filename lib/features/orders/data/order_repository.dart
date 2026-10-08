import 'package:supabase_flutter/supabase_flutter.dart';

import '../../cart/domain/cart_item.dart';
import '../domain/order.dart';

/// إنشاء طلب جديد مع عناصره (نفس العملية المعاملاتية).
class NewOrderPayload {
  const NewOrderPayload({required this.address, required this.items, required this.subtotal, required this.discount, required this.deliveryFee, required this.total, this.couponCode, this.paymentMethod = 'cod'});

  final Map<String, dynamic> address;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final String? couponCode;

  /// `cod` (الدفع عند الاستلام) أو `wallet` (خصم من المحفظة عبر RPC آمن).
  final String paymentMethod;
}

abstract interface class OrderRepository {
  Future<String> createOrder(NewOrderPayload payload);

  Future<List<Order>> fetchOrders({int limit = 50});

  Future<Order> fetchOrder(String id);

  /// بثّ حي لتغيّر حالة طلب (Sprint 5).
  Stream<Order> watchOrder(String id);

  Future<bool> cancelOrder(String id);
}

class SupabaseOrderRepository implements OrderRepository {
  const SupabaseOrderRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<String> createOrder(NewOrderPayload payload) async {
    // المحفظة: إنشاء الطلب + الخصم + تسجيل الحركة في معاملة واحدة عبر RPC
    // (security definer) — لا يمكن خصم الرصيد دون إنشاء الطلب والعكس.
    if (payload.paymentMethod == 'wallet') {
      return _createWalletOrder(payload);
    }
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      // بلا جلسة ترفض RLS الإدراج (42501) — نمنع قبل الوصول للخادم.
      throw const OrderException('not_authenticated');
    }

    // الحقول النصية تُرسل كسلسلة دائماً (لا null): أعمدة orders صريحة
    // النصوص، والإدراج بـ null يفشل بـ 23502 ولو كان لها قيمة افتراضية.
    String text(Object? value) => value?.toString() ?? '';

    final PostgrestList inserted = await _client.from('orders').insert(<String, dynamic>{
      // user_id إلزامي: `with check (auth.uid() = user_id)` يقرأه من
      // الصف الجديد، وغيابه يعني null ← رفض بـ 42501.
      'user_id': userId,
      'street': text(payload.address['street']),
      'building': text(payload.address['building']),
      'apartment': text(payload.address['apartment']),
      'notes': text(payload.address['notes']),
      'phone': text(payload.address['phone']),
      'latitude': payload.address['latitude'],
      'longitude': payload.address['longitude'],
      'subtotal': payload.subtotal,
      'discount': payload.discount,
      'delivery_fee': payload.deliveryFee,
      'total': payload.total,
      'coupon_code': payload.couponCode,
      'payment_method': payload.paymentMethod,
      'status': 'received',
    }).select().limit(1);

    if (inserted.isEmpty) {
      throw const OrderException('insert_failed');
    }
    final String id = '${inserted.first['id']}';

    final List<Map<String, dynamic>> rows = payload.items.map((CartItem item) {
      return <String, dynamic>{'order_id': id, 'product_id': item.productId, 'name': item.name, 'name_fr': item.nameFr, 'price': item.price, 'quantity': item.quantity, 'image_url': item.imageUrl, 'unit': item.unit};
    }).toList();
    await _client.from('order_items').insert(rows);
    return id;
  }

  /// يحوّل الحمولة إلى استدعاء `create_order_with_wallet` الأصلي في الخادم.
  Future<String> _createWalletOrder(NewOrderPayload payload) async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const OrderException('not_authenticated');
    }
    final Map<String, dynamic> address = payload.address;
    final Object? result = await _client.rpc('create_order_with_wallet', params: <String, dynamic>{
      'p_street': '${address['street'] ?? ''}',
      'p_building': '${address['building'] ?? ''}',
      'p_apartment': '${address['apartment'] ?? ''}',
      'p_notes': '${address['notes'] ?? ''}',
      'p_phone': '${address['phone'] ?? ''}',
      'p_latitude': address['latitude'],
      'p_longitude': address['longitude'],
      'p_subtotal': payload.subtotal,
      'p_discount': payload.discount,
      'p_delivery_fee': payload.deliveryFee,
      'p_total': payload.total,
      'p_coupon_code': payload.couponCode,
      'p_items': payload.items.map((CartItem item) => <String, dynamic>{
        'product_id': item.productId,
        'name': item.name,
        'name_fr': item.nameFr,
        'price': item.price,
        'quantity': item.quantity,
        'image_url': item.imageUrl,
        'unit': item.unit,
      }).toList(),
    });
    if (result == null || '$result'.isEmpty) {
      throw const OrderException('create_failed');
    }
    return '$result';
  }

  @override
  Future<List<Order>> fetchOrders({int limit = 50}) async {
    final PostgrestList orders = await _client.from('orders').select().order('created_at', ascending: false).limit(limit);
    if (orders.isEmpty) {
      return const <Order>[];
    }
    final List<String> ids = orders.map((dynamic row) => '${row['id']}').toList();
    final Map<String, List<OrderItem>> itemsByOrder = await _itemsFor(ids);
    return orders.map((dynamic row) => Order.fromJson(Map<String, dynamic>.from(row as Map), items: itemsByOrder['${row['id']}'] ?? const <OrderItem>[])).toList();
  }

  @override
  Future<Order> fetchOrder(String id) async {
    final PostgrestList rows = await _client.from('orders').select().eq('id', id).limit(1);
    if (rows.isEmpty) {
      throw const OrderException('not_found');
    }
    final Map<String, List<OrderItem>> itemsByOrder = await _itemsFor(<String>[id]);
    return Order.fromJson(Map<String, dynamic>.from(rows.first as Map), items: itemsByOrder[id] ?? const <OrderItem>[]);
  }

  @override
  Stream<Order> watchOrder(String id) async* {
    await for (final SupabaseStreamEvent rows in _client.from('orders').stream(primaryKey: <String>['id'])) {
      for (final Map<String, dynamic> row in rows) {
        if ('${row['id']}' == id) {
          yield Order.fromJson(row);
        }
      }
    }
  }

  @override
  Future<bool> cancelOrder(String id) async {
    // Safety guard من طرف الخادم: نعيد قراءة الحالة لحظة الإلغاء لأن
    // الأدمن/المندوب قد يبدأ التجهيز بين فتح الشاشة والضغط على الزر.
    final PostgrestList current = await _client.from('orders').select('status').eq('id', id).limit(1);
    if (current.isEmpty) {
      return false;
    }
    if ('${current.first['status']}' != 'received') {
      return false;
    }
    // تحديث مشروط أيضاً (مطابق لسياسة RLS "Users cancel own pending order"):
    // لو تغيّرت الحالة في اللحظة نفسها لن يُحدَّث أي صف.
    final PostgrestList rows = await _client.from('orders').update(<String, dynamic>{'status': 'cancelled'}).eq('id', id).eq('status', 'received').select();
    return rows.isNotEmpty;
  }

  Future<Map<String, List<OrderItem>>> _itemsFor(List<String> orderIds) async {
    final PostgrestList rows = await _client.from('order_items').select().inFilter('order_id', orderIds);
    final Map<String, List<OrderItem>> result = <String, List<OrderItem>>{};
    for (final dynamic row in rows) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(row as Map);
      final String orderId = '${map['order_id']}';
      result.putIfAbsent(orderId, () => <OrderItem>[]).add(OrderItem.fromJson(map));
    }
    return result;
  }
}


class OrderException implements Exception {
  const OrderException(this.code);

  final String code;

  @override
  String toString() => 'OrderException($code)';
}
