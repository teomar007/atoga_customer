import 'package:atoga_customer/features/auth/domain/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrue/gotrue.dart' as gotrue;
import 'package:postgrest/postgrest.dart' as pg;

void main() {
  group('AuthFailureMapper — رموز Supabase الرسمية', () {
    String mapGotrue(String? code, String message, {String? status}) {
      return AuthFailureMapper.map(gotrue.AuthException(message, code: code, statusCode: status)).code;
    }

    test('بريد مسجّل مسبقاً', () {
      expect(mapGotrue('email_exists', 'User already registered', status: '422'), 'emailExists');
    });

    test('بريد غير صالح', () {
      expect(mapGotrue('email_address_invalid', 'Email address is invalid', status: '400'), 'emailExists');
    });

    test('كلمة مرور ضعيفة', () {
      expect(mapGotrue('weak_password', 'Password should be at least 6 characters', status: '422'), 'weakPassword');
    });

    test('حد إرسال البريد (الخطأ الفعلي الذي واجهناه)', () {
      expect(mapGotrue('over_email_send_rate_limit', 'Too many requests', status: '429'), 'rate_limited');
      expect(mapGotrue('over_request_rate_limit', 'Too many requests', status: '429'), 'rate_limited');
    });

    test('رقم/بريد غير مؤكد => رسالة تفعيل التأكيد التلقائي (بلا OTP)', () {
      expect(mapGotrue('email_not_confirmed', 'Email not confirmed', status: '400'), 'autoconfirmRequired');
      expect(mapGotrue('phone_not_confirmed', 'Phone not confirmed', status: '400'), 'autoconfirmRequired');
    });

    test('التسجيل معطّل', () {
      expect(mapGotrue('signup_disabled', 'Signups not allowed for otp', status: '422'), 'signUpDisabled');
    });

    test('مزوّد الهاتف معطّل (الخطأ الفعلي الوارد من مشروعك)', () {
      expect(mapGotrue('phone_provider_disabled', 'Phone signups are disabled', status: '400'), 'phoneAuthDisabled');
    });

    test('خدمة SMS غير مهيأة', () {
      expect(mapGotrue('sms_send_failed', 'Error sending SMS', status: '500'), 'smsNotConfigured');
    });

    test('رمز غير مُصادَق عليه يعود للخطأ الخام بدل "حدث خطأ ما"', () {
      expect(mapGotrue('brand_new_code', 'Some brand new server problem', status: '418'), 'serverError');
    });

    test('رمز غير معروف يعود للاحتياطي النصي', () {
      expect(mapGotrue(null, 'Invalid login credentials', status: '400'), 'invalid_credentials');
    });

    test('لا رمز ولا نص مطابق => يعرض الخطأ الخام بدل رسالة عامة', () {
      expect(mapGotrue(null, 'something odd happened'), 'serverError');
    });
  });

  group('AuthFailureMapper — أخطاء PostgREST', () {
    test('جدول غير موجود (42P01) => schemaMissing', () {
      expect(AuthFailureMapper.map(const pg.PostgrestException(message: 'relation "profiles" does not exist', code: '42P01')).code, 'schemaMissing');
    });

    test('سياسة RLS (42501) => rlsDenied', () {
      expect(AuthFailureMapper.map(const pg.PostgrestException(message: 'new row violates row-level security policy', code: '42501')).code, 'rlsDenied');
    });
  });

  group('AuthFailureMapper — الشبكة وغير المصنّف', () {
    test('فشل الاتصال => no_internet', () {
      expect(AuthFailureMapper.map(Exception('Failed to fetch')).code, 'no_internet');
    });

    test('نص 429 => rate_limited', () {
      expect(AuthFailureMapper.map(Exception('HTTP 429 Too Many Requests')).code, 'rate_limited');
    });

    test('التفصيل يُحفظ للتسجيل', () {
      final AuthFailure failure = AuthFailureMapper.map(Exception('boom'));
      expect(failure.debugDetail, isNotNull);
      expect(failure.toString(), contains('unknown'));
    });
  });
}
