/// تطبيع أرقام الهاتف بين الصيغة المحلية الجزائرية وصيغة E.164 التي
/// يطلبها Supabase Auth (مثال: `+213555123456`).
abstract final class PhoneNumbers {
  const PhoneNumbers._();

  static const String defaultCountryCode = '213';
  static const String defaultDialCode = '+213';

  /// **حيلة البريد الوهمي**: نتعامل مع الهاتف كـ Username، ونحوّله خلف
  /// الكواليس إلى بريد حتى يعمل Supabase Auth (JWT + RLS) بلا Phone Provider.
  /// المثال: `0555123456` → `0555123456@atoga.com`.
  static const String dummyEmailDomain = 'atoga.com';

  /// يبني البريد الوهمي من الهاتف بأي صيغة. يعيد `null` إن كان الهاتف غير صالح.
  static String? toDummyEmail(String? phone, {String domain = dummyEmailDomain}) {
    final String? national = _nationalDigits(phone, countryCode: defaultCountryCode);
    if (national == null || national.length != 9) {
      return null;
    }
    // محور واحد: صيغة محلية موحّدة، فالهاتف نفسه ← نفس الحساب.
    return '0$national@$domain';
  }

  /// يستخرج الهاتف المحلي من البريد الوهمي (للقراءة عند الحاجة).
  static String? fromDummyEmail(String? email) {
    final String local = (email ?? '').split('@').first.trim();
    if (local.isEmpty) {
      return null;
    }
    return toDummyEmail(local)?.split('@').first;
  }

  /// يحوّل أي صيغة مقبولة إلى E.164، أو `null` إن كانت غير صالحة.
  static String? toE164(String? input, {String countryCode = defaultCountryCode}) {
    final String? national = _nationalDigits(input, countryCode: countryCode);
    if (national == null || national.length != 9) {
      return null;
    }
    return '+$countryCode$national';
  }

  /// يحوّل E.164 إلى الصيغة المحلية للعرض والتخزين (`05XXXXXXXX`).
  static String toLocal(String? e164, {String countryCode = defaultCountryCode}) {
    if (e164 == null || e164.trim().isEmpty) {
      return '';
    }
    final String cleaned = e164.replaceAll(RegExp(r'[\s\-()]'), '');
    final String prefix = '+$countryCode';
    final String national = cleaned.startsWith(prefix) ? cleaned.substring(prefix.length) : cleaned.replaceFirst(RegExp(r'^\+'), '');
    if (national.length != 9) {
      return cleaned;
    }
    return '0$national';
  }

  /// يستخرج الأرقام المحلية (9 خانات) من أي صيغة.
  static String? _nationalDigits(String? input, {required String countryCode}) {
    final String raw = (input ?? '').replaceAll(RegExp(r'[\s\-().]'), '');
    if (raw.isEmpty) {
      return null;
    }
    // بصيغة E.164 مباشرة.
    if (raw.startsWith('+$countryCode')) {
      return raw.substring(('+$countryCode').length);
    }
    // بصيغة 00213...
    if (raw.startsWith('00$countryCode')) {
      return raw.substring(('00$countryCode').length);
    }
    if (raw.startsWith('0')) {
      return raw.substring(1);
    }
    if (raw.length == 9) {
      return raw;
    }
    return null;
  }

  /// للأرقام الجزائرية: 5 أو 6 أو 7 بعد رمز الدولة.
  static bool isValidAlgerian(String? input) {
    final String? national = _nationalDigits(input, countryCode: defaultCountryCode);
    if (national == null || national.length != 9) {
      return false;
    }
    return RegExp(r'^[5-7]').hasMatch(national);
  }
}
