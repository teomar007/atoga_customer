import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/coupons_repository.dart';
import '../domain/coupon_offer.dart';

/// الكوبونات المتاحة للمستخدم الحالي (أو العامة عند الزائر).
class CouponsController extends AsyncNotifier<List<CouponOffer>> {
  CouponsRepository get _repo => ref.read(couponsRepositoryProvider);

  @override
  Future<List<CouponOffer>> build() {
    // تابع لحالة الجلسة: تسجيل الدخول أو الخروج يعيد الجلب تلقائياً،
    // فتتحدّث شارة شريط التنقل دون أي استدعاء يدوي.
    final String? userId = ref.watch(currentUserProvider)?.id;
    return _fetch(userId);
  }

  Future<List<CouponOffer>> _fetch(String? userId) async {
    try {
      return await _repo.fetchAvailable(userId: userId);
    } on Object catch (error) {
      // يُعاد رميه ليصبح AsyncError في الواجهة، ونسجّله لتشخيص الكونسول.
      debugPrint('CouponsController.fetch failed: $error');
      rethrow;
    }
  }

  /// سحب للتحديث من شاشة الكوبونات.
  Future<void> refresh() async {
    final String? userId = ref.read(currentUserProvider)?.id;
    state = await AsyncValue.guard(() => _fetch(userId));
  }

  /// تفريغ الذاكرة عند تسجيل الخروج — الكوبونات تبقى في الخادم.
  void reset() => state = const AsyncData(<CouponOffer>[]);
}

final couponsProvider = AsyncNotifierProvider<CouponsController, List<CouponOffer>>(CouponsController.new);

/// عدد الكوبونات المتاحة — مصدر الشارة في شريط التنقل.
/// يتغيّر تلقائياً مع [couponsProvider] (0 ← شارة مخفية).
///
/// **`valueOrNull` لا `value`**: الأخيرة تعيد رمي خطأ الجلب فينهار
/// `MainShell` كاملاً (شاشة بيضاء) عند تعذّر الاتصال أو غياب الجدول.
final availableCouponsCountProvider = Provider<int>((Ref ref) => ref.watch(couponsProvider).valueOrNull?.length ?? 0);
