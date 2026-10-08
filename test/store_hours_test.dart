import 'package:atoga_customer/features/home/data/store_hours.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isStoreOpenNow', () {
    // 2026-10-05 = الاثنين (1) — صف لليوم الاثنين فقط لاختبار الفترات.
    final List<StoreHours> hours = <StoreHours>[
      const StoreHours(
        dayOfWeek: 1,
        morningOpen: TimeOfDay(hour: 8, minute: 0),
        morningClose: TimeOfDay(hour: 13, minute: 0),
        eveningOpen: TimeOfDay(hour: 16, minute: 0),
        eveningClose: TimeOfDay(hour: 21, minute: 0),
      ),
    ];

    test('ضمن الفترة الصباحية = مفتوح', () {
      expect(isStoreOpenNow(hours, DateTime(2026, 10, 5, 9, 30)), isTrue);
    });

    test('ضمن الفترة المسائية = مفتوح', () {
      expect(isStoreOpenNow(hours, DateTime(2026, 10, 5, 18, 0)), isTrue);
    });

    test('خارج الفترتين = مغلق', () {
      expect(isStoreOpenNow(hours, DateTime(2026, 10, 5, 14, 0)), isFalse);
      expect(isStoreOpenNow(hours, DateTime(2026, 10, 5, 22, 0)), isFalse);
    });

    test('حدود الإغلاق بالضبط = مغلق', () {
      expect(isStoreOpenNow(hours, DateTime(2026, 10, 5, 13, 0)), isFalse);
      expect(isStoreOpenNow(hours, DateTime(2026, 10, 5, 8, 0)), isTrue);
    });

    test('يوم بلا جدول (الثلاثاء 6 أكتوبر) = مغلق', () {
      expect(isStoreOpenNow(hours, DateTime(2026, 10, 6, 10, 0)), isFalse);
    });
  });
}
