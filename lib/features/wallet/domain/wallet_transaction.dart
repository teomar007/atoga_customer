/// نوع حركة المحفظة — يطابق قيم عمود `type` في `wallet_transactions`.
enum WalletTransactionType {
  deposit('deposit'),
  payment('payment');

  const WalletTransactionType(this.wire);

  final String wire;
}

/// حركة واحدة في المحفظة (شحن من الإدارة أو دفع مقابل طلب).
///
/// [amount] موجبة للشحن وسالبة للدفع. يُقرأ السجل فقط من العميل؛
/// إنشاؤه يتم حصراً عبر الدوال الآمنة في الخادم (security definer).
class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.orderId,
    this.note,
  });

  final String id;
  final double amount;
  final WalletTransactionType type;

  /// رقم الطلب المرتبط بعملية الدفع (`null` للشحن).
  final String? orderId;
  final String? note;
  final DateTime createdAt;

  bool get isDeposit => type == WalletTransactionType.deposit;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final String raw = '${json['type'] ?? 'payment'}';
    return WalletTransaction(
      id: '${json['id'] ?? ''}',
      amount: double.tryParse('${json['amount'] ?? ''}') ?? 0,
      type: WalletTransactionType.values.firstWhere((WalletTransactionType t) => t.wire == raw, orElse: () => WalletTransactionType.payment),
      orderId: json['order_id']?.toString(),
      note: json['note']?.toString(),
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}') ?? DateTime.now(),
    );
  }
}
