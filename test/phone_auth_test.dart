import 'package:atoga_customer/core/utils/phone_utils.dart';
import 'package:atoga_customer/features/auth/domain/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrue/gotrue.dart' as gotrue;

void main() {
  group('PhoneNumbers.toE164 (ما يرسله التطبيق إلى Supabase)', () {
    test('صيغة محلية 05...', () {
      expect(PhoneNumbers.toE164('0555123456'), '+213555123456');
    });

    test('صيغة دولية +213...', () {
      expect(PhoneNumbers.toE164('+213555123456'), '+213555123456');
    });

    test('صيغة 00213...', () {
      expect(PhoneNumbers.toE164('00213555123456'), '+213555123456');
    });

    test('بدون رمز الدولة (9 أرقام)', () {
      expect(PhoneNumbers.toE164('555123456'), '+213555123456');
    });

    test('يتجاهل المسافات والشرطات والأقواس', () {
      expect(PhoneNumbers.toE164(' 05 55 12 34 56 '), '+213555123456');
      expect(PhoneNumbers.toE164('+213 (555) 12-34-56'), '+213555123456');
    });

    test('يرفض الأرقام غير الصالحة', () {
      expect(PhoneNumbers.toE164(''), isNull);
      expect(PhoneNumbers.toE164(null), isNull);
      expect(PhoneNumbers.toE164('12345'), isNull);
      expect(PhoneNumbers.toE164('abcdefghij'), isNull);
    });
  });

  group('PhoneNumbers.toLocal (ما يُعرض ويُخزَّن)', () {
    test('E.164 إلى الصيغة المحلية', () {
      expect(PhoneNumbers.toLocal('+213555123456'), '0555123456');
      expect(PhoneNumbers.toLocal('+213661234567'), '0661234567');
    });

    test('يترك كما هي إن لم تكن قابلة للتحويل', () {
      expect(PhoneNumbers.toLocal('123'), '123');
      expect(PhoneNumbers.toLocal(''), '');
      expect(PhoneNumbers.toLocal(null), '');
    });
  });

  group('PhoneNumbers.isValidAlgerian', () {
    test('يقبل 5 و6 و7', () {
     expect(PhoneNumbers.isValidAlgerian('0555123456'), isTrue);
     expect(PhoneNumbers.isValidAlgerian('0661234567'), isTrue);
     expect(PhoneNumbers.isValidAlgerian('0770123456'), isTrue);
    });

    test('يرفض بادئات غير جزائرية أو أرقام ناقصة', () {
      expect(PhoneNumbers.isValidAlgerian('0155123456'), isFalse);
      expect(PhoneNumbers.isValidAlgerian('055512345'), isFalse);
      expect(PhoneNumbers.isValidAlgerian('abc'), isFalse);
    });

  });

  group('AuthFailureMapper — أخطاء رقم الهاتف', () {
    String map(String? code, String message) => AuthFailureMapper.map(gotrue.AuthException(message, code: code, statusCode: '422')).code;

    test('رقم مسجّل مسبقاً', () {
      expect(map('phone_exists', 'Phone number already registered'), 'phoneExists');
    });

    test('رقم غير صالح', () {
      expect(map('phone_number_invalid', 'Invalid phone number format'), 'phoneExists');
    });

    test('هاتف/بريد غير مؤكد', () {
      expect(map('phone_not_confirmed', 'Phone not confirmed'), 'autoconfirmRequired');
      expect(map('email_not_confirmed', 'Email not confirmed'), 'autoconfirmRequired');
    });
  });

  group('البريد الوهمي: الهاتف كـ Username', () {
    test('يحوّل أي صيغة للفعل نفسه (محور واحد)', () {
      expect(PhoneNumbers.toDummyEmail('0555123456'), '0555123456@atoga.com');
      expect(PhoneNumbers.toDummyEmail('+213555123456'), '0555123456@atoga.com');
      expect(PhoneNumbers.toDummyEmail('555123456'), '0555123456@atoga.com');
      expect(PhoneNumbers.toDummyEmail('05 55 12 34 56'), '0555123456@atoga.com');
    });

    test('رقمان مختلفان ⇒ بريدان مختلفان (لا تصادم حسابات)', () {
      expect(PhoneNumbers.toDummyEmail('0555123456'), isNot(PhoneNumbers.toDummyEmail('0555123457')));
    });

    test('يرفض أرقامًا غير صالحة', () {
      expect(PhoneNumbers.toDummyEmail('abc'), isNull);
      expect(PhoneNumbers.toDummyEmail('123'), isNull);
      expect(PhoneNumbers.toDummyEmail(''), isNull);
      expect(PhoneNumbers.toDummyEmail(null), isNull);
    });

    test('استخراج الهاتف من البريد الوهمي', () {
      expect(PhoneNumbers.fromDummyEmail('0555123456@atoga.com'), '0555123456');
      expect(PhoneNumbers.fromDummyEmail('0555123456'), '0555123456');
      expect(PhoneNumbers.fromDummyEmail('nope'), isNull);
      expect(PhoneNumbers.fromDummyEmail(null), isNull);
    });

    test('دورة كاملة: هاتف ← بريد ← هاتف', () {
      const String phone = '0555123456';
      expect(PhoneNumbers.fromDummyEmail(PhoneNumbers.toDummyEmail(phone)), phone);
    });
  });
}
