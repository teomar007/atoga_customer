import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/cart_item.dart';

/// سلة التسوق السحابية (`cart_items`) — نظير [CartStore] المحلي.
///
/// RLS يقيّد كل عملية بمملِك الصف (`auth.uid() = user_id`)، فلا نمرّر
/// `userId` في الاستعلامات عدا التأكيد الصريح.
class CartCloudStore {
  const CartCloudStore(this._client);

  final SupabaseClient _client;

  /// عناصر سلة المستخدم من الخادم.
  Future<List<CartItem>> fetch(String userId) async {
    final List<Map<String, dynamic>> rows = await _client.from('cart_items').select().eq('user_id', userId).order('created_at', ascending: true);
    return rows.map(_fromJson).whereType<CartItem>().toList();
  }

  /// يستبدل سلة المستخدم بالكامل.
  ///
  /// الحذف ثم الإدراج بدل الـ upsert: السلة المحلية هي مصدر الحقيقة على
  /// الجهاز، وأي فشل جزئي يُصلَح في المزامنة القادمة بدل ترك سلة ناقصة.
  Future<void> replace(String userId, List<CartItem> items) async {
    await _client.from('cart_items').delete().eq('user_id', userId);
    if (items.isEmpty) {
      return;
    }
    await _client.from('cart_items').insert(items.map((CartItem item) => _toRow(userId, item)).toList(growable: false));
  }

  Map<String, dynamic> _toRow(String userId, CartItem item) {
    return <String, dynamic>{
      'user_id': userId,
      'product_id': item.productId,
      'quantity': item.quantity,
      'name': item.name,
      'name_fr': item.nameFr,
      'price': item.price,
      'image_url': item.imageUrl,
      'unit': item.unit,
    };
  }

  /// يقرأ الصف إلى [CartItem] عبر نفس مدقّق السلة المحلية (السجلات
  /// التالفة تُتجاهل بدل تعطيل المزامنة كلها).
  CartItem? _fromJson(Map<String, dynamic> row) {
    return CartItem.tryDecode(<String, dynamic>{
      'productId': '${row['product_id'] ?? ''}',
      'name': '${row['name'] ?? ''}',
      'nameFr': row['name_fr']?.toString(),
      'price': row['price'],
      'quantity': row['quantity'],
      'imageUrl': row['image_url']?.toString(),
      'unit': row['unit']?.toString(),
    });
  }
}
