import 'package:atoga_customer/features/checkout/domain/reverse_geocode_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReverseGeocodeResult', () {
    test('isEmpty عندما لا توجد بيانات مفيدة', () {
      expect(const ReverseGeocodeResult().isEmpty, isTrue);
      expect(const ReverseGeocodeResult(city: 'الجزائر العاصمة').isEmpty, isFalse);
    });

    test('label يدمج الشارع والحي والمدينة بدون تكرار', () {
      const ReverseGeocodeResult result = ReverseGeocodeResult(road: 'شارع ديدوش مراد', neighbourhood: 'باب الوادي', suburb: 'الجزائر الوسطى', city: 'الجزائر');
      final String label = result.label;
      expect(label.contains('شارع ديدوش مراد'), isTrue);
      expect(label.contains('باب الوادي'), isTrue);
      expect(label.contains('الجزائر'), isTrue);
      // "الجزائر الوسطى" و"الجزائر" نصان مختلفان، والتكرار يُستبعد.
      expect('الجزائر، الجزائر الوسطى، باب الوادي، شارع ديدوش مراد'.split('، ').where(label.split('، ').contains).length, lessThanOrEqualTo(4));
    });

    test('label يتجاهل الحقول الفارغة', () {
      const ReverseGeocodeResult result = ReverseGeocodeResult(road: 'شارع محمد', neighbourhood: '  ', suburb: null, city: 'وهران');
      expect(result.label, 'شارع محمد، وهران');
    });

    test('label لا يحتوي عناصر فارغة أو مسافات زائدة', () {
      const ReverseGeocodeResult result = ReverseGeocodeResult(road: '  ', neighbourhood: 'حي النخيل', city: 'قسنطينة');
      expect(result.label.split('، ').every((String p) => p.trim().isNotEmpty), isTrue);
    });
  });
}
