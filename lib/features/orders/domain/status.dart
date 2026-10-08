/// حالة الطلب — تطابق قيم العمود `status` في جدول `orders`.
enum OrderStatus {
  received('received'),
  preparing('preparing'),
  onTheWay('on_the_way'),
  delivered('delivered'),
  cancelled('cancelled');

  const OrderStatus(this.wire);

  final String wire;

  /// الطلبات الجارية (لم تُسلَّم ولم تُلغَ).
  bool get isActive => this == received || this == preparing || this == onTheWay;

  /// ترتيب التتبع الحي (لرسم الخط الزمني).
  int get step => switch (this) {
    received => 0,
    preparing => 1,
    onTheWay => 2,
    delivered => 3,
    cancelled => -1,
  };

  /// الإلغاء مسموح في المرحلة الأولى حصراً (`received`): بمجرد بدء التجهيز
  /// أو التوصيل لا يعود الزبون قادراً على إلغاء الطلب.
  bool get canBeCancelled => this == received;
}

/// تحويل نص قاعدة البيانات إلى `OrderStatus` مع قيمة افتراضية آمنة.
abstract final class OrderStatusX {
  const OrderStatusX._();

  static OrderStatus fromJson(String value) {
    return OrderStatus.values.firstWhere((OrderStatus s) => s.wire == value, orElse: () => OrderStatus.received);
  }
}
