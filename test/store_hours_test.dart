import 'package:atoga_customer/features/home/data/store_hours.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isStoreOpenNow (ورديات متعددة)', () {
    // 2026-10-05 = الاثنين (1) — ثلاث ورديات كما في مثال الإدارة.
    final List<StoreShift> shifts = <StoreShift>[
      const StoreShift(dayOfWeek: 1, open: TimeOfDay(hour: 8, minute: 0), close: TimeOfDay(hour: 12, minute: 0), sortOrder: 0),
      const StoreShift(dayOfWeek: 1, open: TimeOfDay(hour: 16, minute: 0), close: TimeOfDay(hour: 18, minute: 0), sortOrder: 1),
      const StoreShift(dayOfWeek: 1, open: TimeOfDay(hour: 20, minute: 0), close: TimeOfDay(hour: 0, minute: 0), sortOrder: 2),
    ];

    test('ضمن الوردية الأولى = مفتوح', () {
      expect(isStoreOpenNow(shifts, DateTime(2026, 10, 5, 9, 30)), isTrue);
    });

    test('ضمن الوردية الثانية = مفتوح', () {
      expect(isStoreOpenNow(shifts, DateTime(2026, 10, 5, 17, 0)), isTrue);
    });

    test('ضمن الوردية المسائية = مفتوح', () {
      expect(isStoreOpenNow(shifts, DateTime(2026, 10, 5, 22, 0)), isTrue);
    });

    test('بين الورديات = مغلق', () {
      expect(isStoreOpenNow(shifts, DateTime(2026, 10, 5, 13, 0)), isFalse);
      expect(isStoreOpenNow(shifts, DateTime(2026, 10, 5, 19, 0)), isFalse);
    });

    test('حدود الإغلاق/الفتح بالضبط', () {
      expect(isStoreOpenNow(shifts, DateTime(2026, 10, 5, 12, 0)), isFalse);
      expect(isStoreOpenNow(shifts, DateTime(2026, 10, 5, 8, 0)), isTrue);
    });

    test('يوم بلا ورديات (الثلاثاء 6 أكتوبر) = مغلق', () {
      expect(isStoreOpenNow(shifts, DateTime(2026, 10, 6, 10, 0)), isFalse);
    });
  });
}
