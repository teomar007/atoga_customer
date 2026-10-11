import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_providers.dart';
import '../domain/delivery_zone.dart';

/// مناطق التوصيل المتاحة (`is_active = true`).
///
/// `autoDispose` ليُعاد الجلب عند كل فتح لشاشة العنوان/الدفع، فتنعكس
/// تعديلات الإدارة (إضافة/تعديل/حذف/إخفاء) تلقائياً دون إعادة تشغيل.
final deliveryZonesProvider = FutureProvider.autoDispose<List<DeliveryZone>>(
  (Ref ref) => ref.watch(deliveryZoneRepositoryProvider).fetchActive(),
);
