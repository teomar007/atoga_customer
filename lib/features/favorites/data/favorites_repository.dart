import 'package:supabase_flutter/supabase_flutter.dart';

/// قائمة المفضلة (`favorites`) — معرّفات المنتجات المحفوظة للمستخدم.
class FavoritesRepository {
  const FavoritesRepository(this._client);

  final SupabaseClient _client;

  /// معرّفات المنتجات المفضّلة — مجموعة لا قائمة لأن الاستعلام الشائع
  /// هو "هل هذا المنتج مفضّل؟" (بحث O(1)).
  Future<Set<String>> fetch(String userId) async {
    final List<Map<String, dynamic>> rows = await _client.from('favorites').select().eq('user_id', userId).order('created_at', ascending: false);
    return rows.map((Map<String, dynamic> row) => '${row['product_id'] ?? ''}').where((String id) => id.isNotEmpty).toSet();
  }

  /// إضافة منتج إلى المفضلة أو إزالته (معرّف فريد `user_id, product_id`).
  Future<void> set(String userId, String productId, {required bool favorite}) async {
    if (favorite) {
      await _client.from('favorites').upsert(<String, dynamic>{'user_id': userId, 'product_id': productId}, onConflict: 'user_id,product_id');
    } else {
      await _client.from('favorites').delete().eq('user_id', userId).eq('product_id', productId);
    }
  }
}
