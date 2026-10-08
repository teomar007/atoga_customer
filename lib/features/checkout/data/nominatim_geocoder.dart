import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../domain/reverse_geocode_result.dart';

/// Reverse Geocoding عبر OpenStreetMap Nominatim (بدون مفتاح API).
///
/// سياسة الاستخدام تشترط:
/// - ترويسة `User-Agent` تعرّف التطبيق (مطلوبة).
/// - حدّ الطلبات: نمنع أي طلبين متتاليين بفاصل 1.1 ثانية.
abstract final class NominatimGeocoder {
  const NominatimGeocoder._();

  static const String endpoint = 'https://nominatim.openstreetmap.org/reverse';
  static const String userAgent = 'ATOGAMARKET/1.1.0 (Flutter app; contact: support@atogamarket.app)';

  static DateTime? _lastCall;

  /// يحول الإحداثيات إلى أقرب عنوان.
  ///
  /// [languageCode] لغة التطبيق الحالية (`ar` / `fr`) — تمرّر إلى Nominatim
  /// كي يعيد أسماء الشوارع والأحياء باللغة نفسها بدل تثبيت العربية.
  static Future<ReverseGeocodeResult?> reverse({required double lat, required double lng, String languageCode = 'ar'}) async {
    await _throttle();
    try {
      final Uri uri = Uri.parse(endpoint).replace(queryParameters: <String, String>{'format': 'jsonv2', 'lat': '$lat', 'lon': '$lng', 'zoom': '18', 'addressdetails': '1', 'accept-language': languageCode});
      final http.Response response = await http.get(uri, headers: <String, String>{'User-Agent': userAgent, 'Accept-Language': languageCode}).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        debugPrint('Nominatim status ${response.statusCode}');
        return null;
      }
      return _parse(response.body);
    } on Object catch (error) {
      debugPrint('Nominatim reverse failed: $error');
      return null;
    }
  }

  static Future<void> _throttle() async {
    final DateTime? last = _lastCall;
    if (last != null) {
      final Duration since = DateTime.now().difference(last);
      if (since < const Duration(milliseconds: 1100)) {
        await Future<void>.delayed(const Duration(milliseconds: 1100) - since);
      }
    }
    _lastCall = DateTime.now();
  }

  static ReverseGeocodeResult? _parse(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is! Map) {
        return null;
      }
      final dynamic raw = decoded['address'];
      if (raw is! Map) {
        return null;
      }
      String? pick(List<String> keys) {
        for (final String key in keys) {
          final String? value = raw[key]?.toString();
          if (value != null && value.trim().isNotEmpty) {
            return value.trim();
          }
        }
        return null;
      }

      return ReverseGeocodeResult(road: pick(<String>['road', 'pedestrian', 'footway', 'residential']), neighbourhood: pick(<String>['neighbourhood', 'quarter', 'suburb', 'city_block']), suburb: pick(<String>['suburb', 'city_district', 'district']), city: pick(<String>['city', 'town', 'village', 'municipality', 'county']), postcode: pick(<String>['postcode']));
    } on Object catch (error) {
      debugPrint('Nominatim parse failed: $error');
      return null;
    }
  }
}
