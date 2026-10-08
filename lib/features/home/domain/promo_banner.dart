import '../../../core/utils/bilingual.dart';

/// بانر ترويجي في شريط التمرير العلوي.
class PromoBanner {
  const PromoBanner({
    required this.id,
    required this.title,
    this.titleFr,
    this.subtitle,
    this.subtitleFr,
    this.imageUrl,
    this.discountLabel,
    this.targetCategoryId,
  });

  final String id;
  final String title;

  /// النسخة الفرنسية من العنوان — تُملأ في لوحة التحكم/قاعدة البيانات.
  final String? titleFr;

  final String? subtitle;

  /// النسخة الفرنسية من السطر التوضيحي.
  final String? subtitleFr;

  final String? imageUrl;
  final String? discountLabel;

  /// عند النقر ينتقل التطبيق لهذا التصنيف (بدل صفحة تفاصيل).
  final String? targetCategoryId;

  /// العنوان باللغة الحالية: الفرنسية إن وُجدت، وإلا الافتراضية (عربية).
  String titleFor(String languageCode) => Bilingual.pick(title, titleFr, languageCode);

  /// هل يملك البنر صورة جاهزة للعرض؟ (فارغ = تستعمل الواجهة التصميم القديم).
  bool get hasImage => (imageUrl ?? '').trim().isNotEmpty;

  /// صورة البنر المضمّنة محلياً (assets) عند تطابق الرابط مع الصور
  /// المعتمدة — العرض يعمل بلا اعتماد على الشبكة، مع بقاء أي رابط
  /// يضيفه الأدمن يمرّ عبر الشبكة كالمعتاد.
  static String? bundledAssetFor(String? url) {
    final String? src = url;
    if (src == null || src.isEmpty) {
      return null;
    }
    const List<(String, String)> known = <(String, String)>[
      ('photo-1544145945-f90425340c7e', 'assets/images/banners/b1_drinks.jpg'),
      ('photo-1486297678162-eb2a19b0a32d', 'assets/images/banners/b2_dairy.jpg'),
      ('photo-1616401784845-180882ba9ba8', 'assets/images/banners/b3_delivery.jpg'),
    ];
    for (final (String photoId, String asset) in known) {
      if (src.contains(photoId)) {
        return asset;
      }
    }
    return null;
  }

  /// السطر التوضيحي باللغة الحالية.
  String? subtitleFor(String languageCode) {
    final String value = Bilingual.pick(subtitle, subtitleFr, languageCode);
    return value.isEmpty ? null : value;
  }

  factory PromoBanner.fromJson(Map<String, dynamic> json) {
    return PromoBanner(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      titleFr: json['title_fr']?.toString(),
      subtitle: json['subtitle']?.toString(),
      subtitleFr: json['subtitle_fr']?.toString(),
      imageUrl: json['image_url']?.toString(),
      discountLabel: json['discount_label']?.toString(),
      targetCategoryId: json['target_category_id']?.toString(),
    );
  }
}
