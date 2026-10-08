import 'package:flutter/widgets.dart';

import 'phone_utils.dart';

/// تحقق بسيط من المدخلات (يعيد مفتاح الخطأ أو null).
abstract final class Validators {
  const Validators._();

  /// أرقام هاتف الجزائر: 0X XX XX XX، أو بصيغة دولية 213...
  static final RegExp _phone = RegExp(r'^(?:\+?213|0)?[5-7]\d{8}$');

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// يعيد `null` إذا كان البريد صالحاً، أو `'invalid'` خلاف ذلك.
  static String? email(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) {
      return null;
    }
    return _email.hasMatch(v) ? null : 'invalid';
  }

  /// الحد الأدنى لكلمة المرور (6 محارف حسب افتراضي Supabase).
  static const int minPasswordLength = 6;

  static String? password(String? value) {
    final String v = value ?? '';
    if (v.isEmpty) {
      return null;
    }
    return v.length >= minPasswordLength ? null : 'too_short';
  }

  static String? phone(String? value) {
    final String digits = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (digits.isEmpty) {
      return null;
    }
    return _phone.hasMatch(digits) ? null : 'invalid';
  }

  /// حقل تسجيل الدخول: الهاتف هو الاسم المستخدم (لا بريد إلكتروني).
  /// الفارغ خطأ هنا بخلاف [phone] الذي يخص الملف الشخصي (اختياري).
  static String? phoneRequired(String? value) {
    return PhoneNumbers.isValidAlgerian(value) ? null : 'invalid';
  }

  /// يقبل البريد أو الهاتف (حساب Google قد يُرجع البريد).
  static bool isValidIdentifier(String value) {
    final String v = value.replaceAll(RegExp(r'[\s-]'), '');
    return _phone.hasMatch(v) || _email.hasMatch(value);
  }

  static bool isNotBlank(String? value) => (value ?? '').trim().isNotEmpty;

  /// رسائل التحقق تُترجم عبر `l10n` في الواجهة، لذا يعيد مفتاح الخطأ فقط.
  static String? requiredField(String? value) {
    return isNotBlank(value) ? null : 'required';
  }

  static bool isValidCoordinate(double lat, double lng) {
    final bool inRange =
        lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    return inRange && !(lat == 0 && lng == 0);
  }

  static TextInputType get phoneKeyboard => TextInputType.phone;
}
