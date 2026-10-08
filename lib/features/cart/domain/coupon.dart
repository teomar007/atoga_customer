/// كوبون خصم مُعرَّف في الخادم أو محلياً.
class Coupon {
  const Coupon({
    required this.code,
    required this.type,
    required this.value,
    this.minSubtotal = 0,
    this.expiresAt,
  });

  final String code;

  /// `percent` نسبة مئوية، أو `fixed` مبلغ ثابت.
  final String type;

  /// النسبة (10 = 10%) أو المبلغ الثابت.
  final double value;

  final double minSubtotal;
  final DateTime? expiresAt;

  bool get isPercent => type == 'percent';

  bool isValidFor(double subtotal) {
    if (minSubtotal > 0 && subtotal < minSubtotal) {
      return false;
    }
    if (expiresAt != null && expiresAt!.isBefore(DateTime.now())) {
      return false;
    }
    return true;
  }

  /// مبلغ الخصم المحسوب على قيمة الطلبية.
  double discountFor(double subtotal) {
    if (!isValidFor(subtotal) || subtotal <= 0) {
      return 0;
    }
    final double raw = isPercent ? subtotal * value / 100 : value;
    // لا يتجاوز الخصم قيمة الطلبية.
    return raw > subtotal ? subtotal : raw;
  }

}

/// كوبونات مدمجة تعمل بلا خادم (وضع التطوير).
abstract final class LocalCoupons {
  const LocalCoupons._();

  static const Map<String, Coupon> byCode = <String, Coupon>{
    'WELCOME10': Coupon(code: 'WELCOME10', type: 'percent', value: 10),
    'SAVE200': Coupon(code: 'SAVE200', type: 'fixed', value: 200),
    'BIG500': Coupon(
      code: 'BIG500',
      type: 'fixed',
      value: 500,
      minSubtotal: 3000,
    ),
  };
}
