import '../../../core/constants/app_constants.dart';

/// منطقة توصيل (حي) يحددها الإدارة في جدول `delivery_zones`.
class DeliveryZone {
  const DeliveryZone({
    required this.id,
    required this.name,
    required this.deliveryFee,
    this.isActive = true,
  });

  final String id;

  /// اسم الحي/المنطقة (مثال: حي السلام).
  final String name;

  /// سعر التوصيل الخاص بهذه المنطقة.
  final double deliveryFee;

  final bool isActive;

  factory DeliveryZone.fromJson(Map<String, dynamic> json) {
    return DeliveryZone(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      deliveryFee: _toDouble(json['delivery_fee']),
      isActive: json['is_active'] != false,
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('${value ?? ''}') ?? 0;
  }
}

/// اسم الحي من معرّفه — `null` إن لم يعد موجوداً (حُذف، أو عنوان قديم
/// أُنشئ قبل وجود حقل `delivery_zone_id`).
String? zoneNameFor(List<DeliveryZone> zones, String? zoneId) {
  if (zoneId == null || zoneId.isEmpty) {
    return null;
  }
  for (final DeliveryZone zone in zones) {
    if (zone.id == zoneId) {
      return zone.name;
    }
  }
  return null;
}

/// رسوم التوصيل عند إتمام الطلب لعنوان مربوط بمنطقة.
///
/// والمحفوظ في الخادم على رقم واحد:
double checkoutDeliveryFee({
  required String? zoneId,
  required List<DeliveryZone> zones,
  required double subtotalAfterDiscount,
}) {
  if (subtotalAfterDiscount >= AppConstants.freeDeliveryThreshold) {
    return 0;
  }
  if (zoneId == null || zoneId.isEmpty) {
    return AppConstants.deliveryFee;
  }
  for (final DeliveryZone zone in zones) {
    if (zone.id == zoneId && zone.isActive) {
      return zone.deliveryFee;
    }
  }
  return AppConstants.deliveryFee;
}
