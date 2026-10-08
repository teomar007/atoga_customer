import '../../../core/utils/bilingual.dart';

/// منتج في الكتالوج.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.nameFr,
    this.categoryId,
    this.imageUrl,
    this.unit,
    this.stock,
    this.isPromo = false,
    this.oldPrice,
  });

  final String id;
  final String name;

  /// الاسم بالفرنسية — يُملأ في قاعدة البيانات (`products.name_fr`).
  final String? nameFr;

  final double price;
  final String? categoryId;
  final String? imageUrl;

  /// وحدة البيع ("علبة"، "قنينة"...) للعرض فقط.
  final String? unit;

  /// `null` يعني غير محدود (لا نفرض قيد مخزون من قاعدة البيانات).
  final int? stock;

  final bool isPromo;
  final double? oldPrice;

  bool get inStock => stock == null || stock! > 0;

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  /// اسم المنتج باللغة الحالية (فرنسية إن وُجدت، وإلا الافتراضية).
  String nameFor(String languageCode) => Bilingual.pick(name, nameFr, languageCode);

  /// نسبة الخصم التلقائية المستخلصة من [oldPrice] مقابل [price]:
  /// تعيد 0 عند غياب خصم صحيح (حماية من القسمة على صفر ومن أسعار أخطأ
  /// فيها الإدخال مثل سعر قديم أقل من السعر الحالي).
  int get discountPercentage {
    if (oldPrice != null && oldPrice! > price && oldPrice! > 0) {
      return (((oldPrice! - price) / oldPrice!) * 100).round();
    }
    return 0;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      nameFr: json['name_fr']?.toString(),
      price: _toDouble(json['price']),
      categoryId: json['category_id']?.toString(),
      imageUrl: json['image_url']?.toString(),
      unit: json['unit']?.toString(),
      stock: json['stock'] == null ? null : _toInt(json['stock']),
      isPromo: json['is_promo'] == true,
      oldPrice: json['old_price'] == null ? null : _toDouble(json['old_price']),
    );
  }

  /// تمثيل JSON كامل (مرآة لـ [fromJson]) — يُستخدم عند تمرير المنتج
  /// إلى واجهات أخرى أو تسجيل البيانات دون فقدان حقل الخصم والصورة.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'name': name,
    'name_fr': nameFr,
    'price': price,
    'category_id': categoryId,
    'image_url': imageUrl,
    'unit': unit,
    'stock': stock,
    'is_promo': isPromo,
    'old_price': oldPrice,
  };

  static double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('${value ?? ''}') ?? 0;
  }

  static int _toInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('${value ?? ''}') ?? 0;
  }
}
