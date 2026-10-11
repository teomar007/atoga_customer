import 'package:flutter/material.dart' show Alignment, Color;

import '../../../core/theme/app_colors.dart';
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
    this.backgroundColor,
    this.imageAlignX = 0,
    this.imageAlignY = 0,
    this.imageScale = 1,
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

  /// لون خلفية البانر (hex `#RRGGBB`) عند غياب الصورة — الافتراضي لون العلامة.
  final String? backgroundColor;

  /// موضع الصورة الأفقي/العمودي داخل الإطار (من -1 إلى 1) وحجمها.
  final double imageAlignX;
  final double imageAlignY;
  final double imageScale;

  /// اللون الفعلي للخلفية: الاختياري إن صحّ، وإلا لون العلامة الأساسي.
  Color get backgroundValue {
    final String raw = (backgroundColor ?? '').trim().replaceFirst('#', '');
    if (raw.length == 6) {
      final int? v = int.tryParse(raw, radix: 16);
      if (v != null) {
        return Color(0xFF000000 | v);
      }
    }
    return AppColors.primary;
  }

  Alignment get imageAlignment => Alignment(imageAlignX.clamp(-1, 1), imageAlignY.clamp(-1, 1));

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
      backgroundColor: json['background_color']?.toString(),
      imageAlignX: double.tryParse('${json['image_align_x'] ?? 0}') ?? 0,
      imageAlignY: double.tryParse('${json['image_align_y'] ?? 0}') ?? 0,
      imageScale: double.tryParse('${json['image_scale'] ?? 1}') ?? 1,
    );
  }
}
