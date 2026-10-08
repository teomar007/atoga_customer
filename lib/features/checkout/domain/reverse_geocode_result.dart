/// نتيجة تحويل الإحداثيات إلى عنوان (Reverse Geocoding عبر Nominatim/OSM).
class ReverseGeocodeResult {
  const ReverseGeocodeResult({this.road, this.neighbourhood, this.suburb, this.city, this.postcode});

  /// اسم الشارع — يُملأ في حقل "الشارع".
  final String? road;

  /// الحي أو المنطقة — يُدمج مع الشارع.
  final String? neighbourhood;

  final String? suburb;
  final String? city;
  final String? postcode;

  bool get isEmpty => (road ?? '').isEmpty && (neighbourhood ?? '').isEmpty && (city ?? '').isEmpty;

  /// سطر واحد يصلح للعرض أو للحقل النصي.
  String get label {
    final Set<String> unique = <String?>{road, neighbourhood, suburb, city}.whereType<String>().map((String p) => p.trim()).where((String p) => p.isNotEmpty).toSet();
    return unique.join('، ');
  }
}
