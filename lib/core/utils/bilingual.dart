/// اختيار النص من حقل ثنائي اللغة حسب لغة التطبيق.
///
/// المحتوى الذي يديره المشرف (المنتجات، البانرات) يُخزَّن بلغتين، والنسخة
/// الثانية اختيارية: عند غيابها أو فراغها نعود للنص الافتراضي بدل عرض
/// فراغ. العربية هي اللغة الافتراضية في هذا التطبيق.
abstract final class Bilingual {
  const Bilingual._();

  /// [primary] النص الأساسي (عربية)، [translated] النسخة الفرنسية.
  static String pick(String? primary, String? translated, String languageCode) {
    final String base = (primary ?? '').trim();
    if (languageCode == 'ar') {
      return base;
    }
    final String other = (translated ?? '').trim();
    return other.isEmpty ? base : other;
  }
}
