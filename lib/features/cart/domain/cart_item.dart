import 'dart:convert';

import '../../../core/utils/bilingual.dart';
import '../../home/domain/product.dart';

/// عنصر في السلة: نسخة مستقلة من المنتج + الكمية (تظل صالحة لو تغيّر
/// السعر في الخادم لاحقاً، لأن السلة تحتفظ بالسعر وقت الإضافة).
class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.nameFr,
    this.imageUrl,
    this.unit,
  });

  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? nameFr;
  final String? imageUrl;
  final String? unit;

  double get lineTotal => price * quantity;

  /// اسم العنصر باللغة الحالية — السلة تُحفظ بلغتين لتتبع لغة التطبيق لاحقاً.
  String nameFor(String languageCode) => Bilingual.pick(name, nameFr, languageCode);

  factory CartItem.fromProduct(Product product, {int quantity = 1}) {
    return CartItem(
      productId: product.id,
      name: product.name,
      nameFr: product.nameFr,
      price: product.price,
      quantity: quantity,
      imageUrl: product.imageUrl,
      unit: product.unit,
    );
  }

  CartItem copyWith({int? quantity, double? price}) {
    return CartItem(
      productId: productId,
      name: name,
      nameFr: nameFr,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
      unit: unit,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'name': name,
      'nameFr': nameFr,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'unit': unit,
    };
  }

  String toJson() => jsonEncode(toMap());

  /// قراءة آمنة: أي سجل تالف يُتجاهل بدل تعطيل السلة بالكامل.
  static CartItem? tryDecode(Object? raw) {
    try {
      if (raw is String) {
        return _fromMap(jsonDecode(raw) as Map<dynamic, dynamic>);
      }
      if (raw is Map) {
        return _fromMap(raw);
      }
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
    return null;
  }

  static CartItem? _fromMap(Map<dynamic, dynamic> map) {
    final String id = '${map['productId'] ?? ''}'.trim();
    final String name = '${map['name'] ?? ''}'.trim();
    final int quantity = _toInt(map['quantity'], fallback: 1);
    if (id.isEmpty || name.isEmpty || quantity < 1) {
      return null;
    }
    return CartItem(
      productId: id,
      name: name,
      nameFr: _nullable(map['nameFr']),
      price: _toDouble(map['price']),
      quantity: quantity,
      imageUrl: _nullable(map['imageUrl']),
      unit: _nullable(map['unit']),
    );
  }

  static String? _nullable(Object? value) {
    final String text = '${value ?? ''}'.trim();
    return text.isEmpty ? null : text;
  }

  static double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('${value ?? ''}') ?? 0;
  }

  static int _toInt(Object? value, {required int fallback}) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('${value ?? ''}') ?? fallback;
  }
}
