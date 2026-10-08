import 'package:atoga_customer/core/utils/validators.dart';
import 'package:atoga_customer/features/auth/domain/customer_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomerUser.hasPhone (بوابة إتمام الطلب)', () {
    test('يرفض الطلب عندما الهاتف null', () {
      expect(const CustomerUser(id: 'u1').hasPhone, isFalse);
    });

    test('يرفض الطلب عندما الهاتف فارغ أو مسافات فقط', () {
      expect(const CustomerUser(id: 'u1', phone: '').hasPhone, isFalse);
      expect(const CustomerUser(id: 'u1', phone: '   ').hasPhone, isFalse);
    });

    test('يقبل الطلب عند وجود رقم صالح', () {
      expect(const CustomerUser(id: 'u1', phone: '0555123456').hasPhone, isTrue);
    });
  });

  group('copyWith — تعديل الهاتف اختيارياً', () {
    test('.phone يتجاوز القيمة الحالية', () {
      const CustomerUser user = CustomerUser(id: 'u1', phone: '0555123456');
      expect(user.copyWith(phone: '0666111222').phone, '0666111222');
    });

    test('clearPhone يفرغ الرقم', () {
      const CustomerUser user = CustomerUser(id: 'u1', phone: '0555123456');
      final CustomerUser cleared = user.copyWith(clearPhone: true);
      expect(cleared.phone, isNull);
      expect(cleared.hasPhone, isFalse);
    });

    test('بدون clearPhone يبقي الرقم القديم', () {
      const CustomerUser user = CustomerUser(id: 'u1', phone: '0555123456');
      expect(user.copyWith(displayName: 'سالم').phone, '0555123456');
    });
  });

  group('Validators.email', () {
    test('يقبل بريداً صحيحاً ويعيد null', () {
      expect(Validators.email('salem@example.com'), isNull);
    });

    test('يرفض بريداً غير صحيح', () {
      expect(Validators.email('salem@'), isNotNull);
      expect(Validators.email('salem example.com'), isNotNull);
    });

    test('الحقل الفارغ يعيد null (التفويض للـ Form)', () {
      expect(Validators.email(''), isNull);
    });
  });

  group('Validators.password', () {
    test('يرفض الأقصر من 6 محارف', () {
      expect(Validators.password('12345'), isNotNull);
    });

    test('يقبل 6 محارف فأكثر', () {
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.phone (تنسيق الملف الشخصي)', () {
    test('يقبل الصيغ الجزائرية', () {
      expect(Validators.phone('0555123456'), isNull);
      expect(Validators.phone('+213555123456'), isNull);
    });

    test('يرفض صيغة غير صحيحة أو فارغ', () {
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone('abc'), isNotNull);
      expect(Validators.phone(''), isNull);
    });
  });
}
