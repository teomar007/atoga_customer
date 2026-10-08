import 'package:supabase_flutter/supabase_flutter.dart';

/// روابط التواصل الاجتماعي — جدول `social_links` بنمط Key-Value.
///
/// القراءة عامة (سياسة RLS `using (true)`) فلا حاجة لتمرير المستخدم،
/// والتحديث يتم من لوحة تحكم الإدارة فينعكس على التطبيق دون إعادة نشر.
class SocialLinksRepository {
  const SocialLinksRepository(this._client);

  final SupabaseClient _client;

  /// كل الروابط كخريطة `key → url` مرتّبة بحسب المفتاح.
  ///
  /// **لا نصفّي القيم الفارغة هنا**: الشاشة تعرض المنصات الثلاث دائماً،
  /// وعند غياب الرابط تعرض تنبيهاً للمستخدم — لا إخفاءً للمنصة.
  Future<Map<String, String>> fetchAll() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('social_links')
        .select()
        .order('key', ascending: true);

    final Map<String, String> links = <String, String>{};
    for (final Map<String, dynamic> row in rows) {
      final String key = '${row['key'] ?? ''}'.trim().toLowerCase();
      if (key.isEmpty) {
        continue;
      }
      links[key] = '${row['url'] ?? ''}'.trim();
    }
    return links;
  }
}
