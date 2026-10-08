import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/delivery_zone.dart';

/// مناطق التوصيل من جدول `delivery_zones`.
class DeliveryZoneRepository {
  const DeliveryZoneRepository(this._client);

  final SupabaseClient _client;

  /// الأحياء النشطة فقط، بترتيب إدراجها في لوحة الإدارة.
  ///
  /// RLS يسمح بالقراءة للجميع (`Public read delivery_zones`).
  Future<List<DeliveryZone>> fetchActive() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('delivery_zones')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: true);
    return rows.map(DeliveryZone.fromJson).toList();
  }
}
