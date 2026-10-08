import '../../../core/utils/bilingual.dart';
import 'status.dart';

/// عنصر طلب محفوظ (نسخة عند الشراء).
class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.nameFr,
    this.imageUrl,
    this.unit,
  });

  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? nameFr;
  final String? imageUrl;
  final String? unit;

  double get lineTotal => price * quantity;

  /// اسم المنتج باللغة الحالية عند عرض الطلب.
  String nameFor(String languageCode) => Bilingual.pick(name, nameFr, languageCode);

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(productId: '${json['product_id'] ?? ''}', name: '${json['name'] ?? ''}', nameFr: json['name_fr']?.toString(), price: _toDouble(json['price']), quantity: _toInt(json['quantity']), imageUrl: json['image_url']?.toString(), unit: json['unit']?.toString());
  }

  static double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('${value ?? ''}') ?? 0;
  }

  static int _toInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('${value ?? ''}') ?? 0;
  }
}

/// طلب توصيل.
class Order {
  const Order({
    required this.id,
    required this.createdAt,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.status,
    this.couponCode,
    this.paymentMethod = 'cod',
    this.street = '',
    this.building = '',
    this.apartment = '',
    this.notes = '',
    this.phone = '',
    this.latitude,
    this.longitude,
    this.courierName,
    this.courierPhone,
    this.items = const <OrderItem>[],
  });

  final String id;
  final DateTime createdAt;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final String? couponCode;
  final String paymentMethod;
  final String street;
  final String building;
  final String apartment;
  final String notes;
  final String phone;
  final double? latitude;
  final double? longitude;
  final String? courierName;
  final String? courierPhone;
  final List<OrderItem> items;

  bool get isActive => status.isActive;

  /// هل يمكن عرض بيانات المندوب (تظهر فقط في مرحلة التوصيل).
  bool get hasCourier => status == OrderStatus.onTheWay && (courierPhone?.isNotEmpty ?? false);

  String get addressLine {
    final List<String> parts = <String>[street, building];
    if (apartment.isNotEmpty) {
      parts.add(apartment);
    }
    return parts.where((String p) => p.trim().isNotEmpty).join(' - ');
  }

  int get totalQuantity => items.fold<int>(0, (int sum, OrderItem i) => sum + i.quantity);

  factory Order.fromJson(Map<String, dynamic> json, {List<OrderItem> items = const <OrderItem>[]}) {
    return Order(id: '${json['id'] ?? ''}', createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(), subtotal: _d(json['subtotal']), discount: _d(json['discount']), deliveryFee: _d(json['delivery_fee']), total: _d(json['total']), status: OrderStatusX.fromJson('${json['status'] ?? ''}'), couponCode: json['coupon_code']?.toString(), paymentMethod: '${json['payment_method'] ?? 'cod'}', street: '${json['street'] ?? ''}', building: '${json['building'] ?? ''}', apartment: '${json['apartment'] ?? ''}', notes: '${json['notes'] ?? ''}', phone: '${json['phone'] ?? ''}', latitude: _o(json['latitude']), longitude: _o(json['longitude']), courierName: json['courier_name']?.toString(), courierPhone: json['courier_phone']?.toString(), items: items);
  }

  static double _d(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('${value ?? ''}') ?? 0;
  }

  static double? _o(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value');
  }
}
