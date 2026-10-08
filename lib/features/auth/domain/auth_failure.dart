import 'package:flutter/foundation.dart';
import 'package:gotrue/gotrue.dart' as gotrue;
import 'package:postgrest/postgrest.dart' as pg;

/// نتيجة تحليل الاستثناء: مفتاح رسالة مترجَم + تفصيل تقني للتسجيل.
class AuthFailure {
  const AuthFailure({required this.code, this.debugDetail, this.userMessage});

  /// مفتاح يحوّله `login_screen` إلى نص `l10n`.
  final String code;

  /// الرسالة الخام من الخادم — للتسجيل فقط، لا تُعرض للمستخدم.
  final String? debugDetail;

  /// نص الخطأ نفسه من الخادم — يُعرض عند `serverError` حتى لا نخفي السبب.
  final String? userMessage;

  @override
  String toString() => debugDetail == null ? 'AuthFailure($code)' : 'AuthFailure($code) <- $debugDetail';
}

/// يحوّل استثناءات Supabase (Auth / PostgREST / الشبكة) إلى مفاتيح واضحة.
///
/// الأهم: نقرأ `code` الرسمي من `AuthException` الخاص بـ gotrue
/// (وليس صنفاً محلياً بنفس الاسم) و`message`، بدل مطابقة نصية هشة.
abstract final class AuthFailureMapper {
  const AuthFailureMapper._();

  static AuthFailure map(Object error) {
    // 1) أخطاء المصادقة الرسمية:gotrue.AuthException
    if (error is gotrue.AuthException) {
      final String? raw = error.code;
      final String detail = 'gotrue code=${raw ?? '-'} status=${error.statusCode ?? '-'} message="${error.message}"';
      final String code = _fromAuthCode(raw, error.message);
      debugPrint('AuthFailureMapper: $detail -> $code');
      return AuthFailure(code: code, debugDetail: detail, userMessage: error.message);
    }

    // 2) أخطاء قاعدة البيانات (جدول غير موجود / RLS / اتصال).
    if (error is pg.PostgrestException) {
      final String detail = 'postgrest code=${error.code ?? '-'} message="${error.message}"';
      final String code = _fromPostgrestCode(error);
      debugPrint('AuthFailureMapper: $detail -> $code');
      return AuthFailure(code: code, debugDetail: detail, userMessage: error.message);
    }

    // 3) أخطاء الشبكة / غير مصنّفة.
    final String text = error.toString();
    final String code = _fromText(text);
    debugPrint('AuthFailureMapper: unclassified "${_clip(text)}" -> $code');
    return AuthFailure(code: code, debugDetail: text, userMessage: text);
  }

  /// رموز Supabase الرسمية: https://supabase.com/docs/guides/auth/debugging/error-codes
  static String _fromAuthCode(String? code, String message) {
    switch (code) {
      case 'email_exists':
      case 'email_address_invalid':
      case 'user_already_exists':
        return 'emailExists';
      case 'phone_exists':
      case 'phone_number_invalid':
      case 'phone_number_exists':
        return 'phoneExists';
      case 'weak_password':
      case 'password_too_short':
        return 'weakPassword';
      case 'email_not_confirmed':
      case 'phone_not_confirmed':
        return 'autoconfirmRequired';
      case 'email_conflict':
        return 'emailExists';
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
      case 'over_sms_send_rate_limit':
        return 'rate_limited';
      case 'signup_disabled':
      case 'email_provider_disabled':
        return 'signUpDisabled';
      case 'phone_provider_disabled':
      case 'phone_signups_not_allowed':
      case 'otp_provider_disabled':
        return 'phoneAuthDisabled';
      case 'sms_send_failed':
      case 'sms_provider_not_configured':
      case 'sms_not_enabled':
        return 'smsNotConfigured';
      case 'validation_failed':
        return message.contains('at least') ? 'weakPassword' : 'invalidInput';
      case 'user_banned':
        return 'userBanned';
      case 'bad_jwt':
      case 'no_authorization':
        return 'sessionExpired';
    }
    final String byText = _fromText(message);
    // لم نجد رمزاً رسمياً ولا نصاً مطابقاً: نُظهر الخطأ الخام للمستخدم بدلاً
    // من «حدث خطأ ما»، حتى لا نُخفي رمز مثل `phone_provider_disabled`.
    return byText != 'unknown' ? byText : 'serverError';
  }

  static String _fromPostgrestCode(pg.PostgrestException error) {
    final String message = error.message.toLowerCase();
    final String? code = error.code;
    if (code == '42501' || message.contains('row-level security')) {
      return 'rlsDenied';
    }
    if (code == '42P01' || message.contains('does not exist') || message.contains('schema cache')) {
      return 'schemaMissing';
    }
    if (message.contains('failed to fetch') || message.contains('network') || message.contains('connection')) {
      return 'no_internet';
    }
    return 'unknown';
  }

  /// احتياطي نصي للاستثناءات غير المصنّفة (AuthException المخصّص، Dio، إلخ).
  static String _fromText(String raw) {
    final String text = raw.toLowerCase();
    if (text.contains('failed to fetch') || text.contains('socket') || text.contains('hostlookup') || text.contains('connection refused')) {
      return 'no_internet';
    }
    if (text.contains('invalid login credentials')) {
      return 'invalid_credentials';
    }
    if (text.contains('already registered') || text.contains('already been registered') || text.contains('email_exists')) {
      return 'emailExists';
    }
    if (text.contains('password should be') || text.contains('at least') || text.contains('weak_password')) {
      return 'weakPassword';
    }
    if (text.contains('email not confirmed') || text.contains('phone not confirmed')) {
      return 'autoconfirmRequired';
    }
    if (text.contains('phone number already registered') || text.contains('phone_exists')) {
      return 'phoneExists';
    }
    if (text.contains('too many requests') || text.contains('rate limit') || text.contains('security purposes') || text.contains('429')) {
      return 'rate_limited';
    }
    return 'unknown';
  }

  static String _clip(String text) => text.length <= 220 ? text : '${text.substring(0, 220)}...';
}
