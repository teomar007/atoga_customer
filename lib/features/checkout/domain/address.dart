import 'delivery_zone.dart';

/// عنوان توصيل محفوظ.
class Address {
  const Address({
    this.id,
    required this.label,
    required this.street,
    required this.building,
    this.apartment = '',
    this.deliveryZoneId,
    this.notes = '',
    required this.phone,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  final String? id;
  final String label;
  final String street;
  final String building;
  final String apartment;
  final String? deliveryZoneId;
  final String notes;
  final String phone;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  bool get hasPin => latitude != null && longitude != null;

  /// سطر مختصر للعرض في قائمة العناوين.
  String get shortLabel {
    final List<String> parts = <String>[street, building];
    if (apartment.isNotEmpty) {
      parts.add(apartment);
    }
    return parts.where((String p) => p.trim().isNotEmpty).join(' - ');
  }

  /// عنوان العرض في القوائم: الحيّ أولاً، وإلا الحقول القديمة.
  ///
  /// العناوين الجديدة لا تحمل شارعاً ولا عمارة (أُلغيت من النموذج)،
  /// والعناوين القديمة التي سُجّلت قبل `delivery_zone_id` تعود لـ [shortLabel].
  String titleFor(List<DeliveryZone> zones) {
    final String? zone = zoneNameFor(zones, deliveryZoneId);
    if (zone != null && zone.isNotEmpty) {
      return zone;
    }
    return shortLabel;
  }

  Address copyWith({String? label, String? street, String? building, String? apartment, String? deliveryZoneId, String? notes, String? phone, double? latitude, double? longitude, bool? isDefault}) {
    return Address(
      id: id,
      label: label ?? this.label,
      street: street ?? this.street,
      building: building ?? this.building,
      apartment: apartment ?? this.apartment,
      deliveryZoneId: deliveryZoneId ?? this.deliveryZoneId,
      notes: notes ?? this.notes,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: '${json['id']}',
      label: '${json['label'] ?? ''}',
      street: '${json['street'] ?? ''}',
      building: '${json['building'] ?? ''}',
      apartment: '${json['apartment'] ?? ''}',
      deliveryZoneId: json['delivery_zone_id']?.toString(),
      notes: '${json['notes'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      isDefault: json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      'label': label,
      'street': street,
      'building': building,
      'apartment': apartment,
      'delivery_zone_id': deliveryZoneId,
      'notes': notes,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }

  static double? _toDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value');
  }
}
