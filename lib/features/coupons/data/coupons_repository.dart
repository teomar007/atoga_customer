import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/coupon_offer.dart';

/// قراءة الكوبونات المتاحة من جدول `coupons`.
class CouponsRepository {
  const CouponsRepository(this._client);

  final SupabaseClient _client;

  /// الكوبونات المتاحة للزبون: يُحسب كل شيء على الخادم في `customer_coupons()`
  /// (الفعالية + بداية/نهاية الصلاحية + حدّ الاستخدام لكل مستخدم).
  Future<List<CouponOffer>> fetchAvailable({String? userId}) async {
    final dynamic result = await _client.rpc('customer_coupons');
    if (result is! List) {
      return const <CouponOffer>[];
    }
    // فلترة أمان إضافية على العميل لانتهاء الصلاحية.
    return result
        .map((dynamic row) => CouponOffer.fromJson(Map<String, dynamic>.from(row as Map)))
        .where((CouponOffer coupon) => !coupon.isExpired)
        .toList();
  }
}
