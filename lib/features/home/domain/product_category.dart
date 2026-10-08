import '../../../core/utils/bilingual.dart';

/// تصنيف منتجات يُدار بالكامل من لوحة التحكم عبر Supabase.
///
/// ملاحظة: الاسم `ProductCategory` وليس `Category` لأن `flutter/foundation`
/// يصدّر `Category` (للتعليقات التوضيحية) فيحدث تعارض أسماء.
class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    this.iconName,
    this.nameAr,
    this.nameFr,
    this.iconUrl,
    this.isActive = true,
    this.displayOrder = 0,
  });

  final String id;

  /// الاسم العربي المخزَّن في `name` (عمود مرآة مولّد من `name_ar`).
  final String name;
  final String? iconName;

  /// الاسم الأساسي (عربية) — حقل الإدارة `name_ar`.
  final String? nameAr;

  /// النسخة الفرنسية الاختيارية — حقل الإدارة `name_fr`.
  final String? nameFr;

  /// صورة الأيقونة المرفوعة على Supabase Storage إن وُجدت.
  final String? iconUrl;

  /// إخفاء التصنيف من تطبيق الزبون دون حذفه.
  final bool isActive;

  /// موضع التصنيف في الشريط الأفقي (تصاعدي).
  final int displayOrder;

  factory ProductCategory.fromJson(Map<String, dynamic> json) => ProductCategory(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? json['name_ar'] ?? ''}',
        iconName: json['icon_name']?.toString(),
        nameAr: json['name_ar']?.toString(),
        nameFr: json['name_fr']?.toString(),
        iconUrl: json['icon_url']?.toString(),
        isActive: json['is_active'] as bool? ?? true,
        displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      );

  /// الاسم المناسب لغة الجهاز الحالية.
  ///
  /// العربية هي الافتراضية؛ الفرنسية تُفضَّل إن وُجدت، وإن غابت نعود
  /// للعربية بدل عرض فراغ (نفس سلوك [Bilingual.pick] في بقية التطبيق).
  String getLocalizedName(String languageCode) {
    final String arabic = (nameAr ?? '').trim().isEmpty ? name : nameAr!;
    return Bilingual.pick(arabic, nameFr, languageCode);
  }
}
