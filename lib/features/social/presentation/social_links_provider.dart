import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_providers.dart';

/// إعدادات التواصل القادمة من Supabase — جدول `social_links` بنمط Key-Value.
///
/// يشمل **روابط المنصات** (`facebook`/`instagram`/`tiktok`) **ومفاتيح
/// الاتصال** ([ContactKeys.phone] و[ContactKeys.whatsapp]) — تُجلب كلها
/// في طلب واحد لأن الجدول نفسه واحد.
///
/// `FutureProvider` يُبقي الحالة داخل التطبيق: يُبنى أول مرة تُشاهَد فيه
/// الشاشة ثم يُخزَّن، فلا طلب شبكي متكرر عند التنقّل بين التبويبات.
/// لتحديث أي قيمة من لوحة الإدارة: `ref.invalidate(socialLinksProvider)`.
final socialLinksProvider = FutureProvider<Map<String, String>>(
  (Ref ref) => ref.watch(socialLinksRepositoryProvider).fetchAll(),
);

/// مفاتيح الاتصال داخل `social_links`.
///
/// القيم المخزَّنة **أرقام لا روابط**؛ التطبيق هو من يبني منها `tel:` و
/// `https://wa.me/` — فلا يُعرض الرقم في الواجهة أبداً.
abstract final class ContactKeys {
  const ContactKeys._();

  /// الهاتف الأساسي — زر «اتصل بنا».
  static const String phone = 'contact_phone';

  /// رقم واتساب — زر «واتساب».
  static const String whatsapp = 'whatsapp_number';
}
