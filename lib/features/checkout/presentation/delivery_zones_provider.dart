import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_providers.dart';
import '../domain/delivery_zone.dart';

/// مناطق التوصيل المتاحة (`is_active = true`).
///
/// `FutureProvider` يُبقي الحالة في التطبيق فلا يُعاد الجلب عند كل فتح
/// لشاشة العنوان؛ للتحديث بعد تعديل الإدارة: `ref.invalidate(deliveryZonesProvider)`.
final deliveryZonesProvider = FutureProvider<List<DeliveryZone>>(
  (Ref ref) => ref.watch(deliveryZoneRepositoryProvider).fetchActive(),
);
