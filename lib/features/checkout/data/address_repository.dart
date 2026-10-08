import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/address.dart';

/// عناوين التوصيل في جدول `addresses` (مرتبطة بمستخدم مُصادَق).
abstract interface class AddressRepository {
  Future<List<Address>> fetchAll();

  Future<Address> save(Address address);

  Future<void> delete(String id);
}

class SupabaseAddressRepository implements AddressRepository {
  const SupabaseAddressRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Address>> fetchAll() async {
    final PostgrestList rows = await _client.from('addresses').select().order('is_default', ascending: false).order('created_at', ascending: false);
    return rows.map(Address.fromJson).toList();
  }

  @override
  Future<Address> save(Address address) async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      // بلا جلسة ترفض RLS الإدراج — نمنع الطلب قبل الوصول للخادم.
      throw const AddressException('not_authenticated');
    }

    // إرفاق user_id إلزامي: سياسة `with check (auth.uid() = user_id)` تقرأ
    // الحقل من الصف الجديد، وغيابه يعني null ← رفض الإدراج بـ 42501.
    // نضعه بعد الـ spread ليضمن أن ملكية الصف دائماً للمستخدم الحالي.
    final Map<String, dynamic> payload = <String, dynamic>{
      ...address.toJson(),
      'user_id': userId,
    };

    if (address.id == null) {
      final PostgrestList inserted = await _client.from('addresses').insert(payload).select().limit(1);
      if (inserted.isEmpty) {
        throw const AddressException('insert_failed');
      }
      return Address.fromJson(inserted.first);
    }
    // نفس `with check` يسري على التحديث — وإرسال user_id يثبّت الملكية.
    await _client.from('addresses').update(payload).eq('id', address.id!);
    return address;
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('addresses').delete().eq('id', id);
  }
}

/// خطأ عنوان موحّد تُترجمه الواجهة.
class AddressException implements Exception {
  const AddressException(this.code);

  final String code;

  @override
  String toString() => 'AddressException($code)';
}
