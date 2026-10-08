import 'package:hive_flutter/hive_flutter.dart';

import '../../features/cart/domain/cart_item.dart';
import '../constants/app_constants.dart';

/// حفظ السلة محلياً في Hive حتى لا تضيع عند إغلاق التطبيق.
abstract interface class CartStore {
  List<CartItem> readAll();
  Future<void> writeAll(List<CartItem> items);
  Future<void> clear();
}

class CartStorage implements CartStore {
  const CartStorage(this._box);

  final Box<dynamic> _box;

  static Future<Box<dynamic>> openBox() async {
    await Hive.initFlutter();
    return Hive.openBox<dynamic>(AppConstants.cartBoxName);
  }

  @override
  List<CartItem> readAll() {
    final dynamic raw = _box.get(AppConstants.cartBoxKey);
    if (raw is! List) {
      return const <CartItem>[];
    }
    final List<CartItem> items = <CartItem>[];
    for (final dynamic entry in raw) {
      final CartItem? parsed = CartItem.tryDecode(entry);
      if (parsed != null) {
        items.add(parsed);
      }
    }
    return items;
  }

  @override
  Future<void> writeAll(List<CartItem> items) async {
    final List<String> encoded =
        items.map((CartItem i) => i.toJson()).toList(growable: false);
    await _box.put(AppConstants.cartBoxKey, encoded);
  }

  @override
  Future<void> clear() => _box.delete(AppConstants.cartBoxKey);
}
