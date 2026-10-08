import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/coupon_offer.dart';

/// قراءة الكوبونات المتاحة من جدول `coupons`.
class CouponsRepository {
  const CouponsRepository(this._client);

  final SupabaseClient _client;

  /// الكوبونات الفعالة وغير المنتهية: العامة (`user_id is null`) أو
  /// الخاصة بالمستخدم [userId] (null عند الزائر = العامة فقط).
  ///
  /// الفلترة على مستوى الخادم (RLS) ومستوى الاستعلام معاً: طبقة أمان
  /// وطبقة منطق. انتهاء الصلاحية يُفحص بعد الجلب لأن المطلوب (عمود
  /// فارغ أو مستقبلي) لا يُعبَّر عنه بمرشّح واحد.
  Future<List<CouponOffer>> fetchAvailable({String? userId}) async {
    PostgrestFilterBuilder<PostgrestList> query = _client.from('coupons').select().eq('is_active', true);
    query = userId == null ? query.isFilter('user_id', null) : query.or('user_id.is.null,user_id.eq.$userId');

    final PostgrestList rows = await query.order('created_at', ascending: false);
    return rows.map(CouponOffer.fromJson).where((CouponOffer coupon) => !coupon.isExpired).toList();
  }
}
