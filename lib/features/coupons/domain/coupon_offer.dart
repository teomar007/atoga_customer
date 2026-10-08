/// كوبون يُعرض للمستخدم (صف من جدول `coupons`).
///
/// مختلف عن [Coupon] في `features/cart` الذي يحسب الخصم؛ هذا النموذج
/// يمثّل العرض الترويجي (عنوان + كود ينسخه المستخدم).
class CouponOffer {
  const CouponOffer({
    required this.id,
    required this.code,
    this.title = '',
    this.userId,
    this.createdAt,
    this.expiresAt,
    this.isActive = true,
  });

  final String id;
  final String code;
  final String title;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final bool isActive;

  /// انتهت الصلاحية: لا تُعرض ولا تُحسب في الشارة.
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  /// العنوان المعروض: العنوان إن وُجد، وإلا الكود نفسه (لا نترك فراغاً).
  String get displayTitle => title.trim().isEmpty ? code : title;

  factory CouponOffer.fromJson(Map<String, dynamic> json) {
    return CouponOffer(
      id: '${json['id'] ?? ''}',
      code: '${json['code'] ?? ''}',
      title: '${json['title'] ?? ''}',
      userId: json['user_id']?.toString(),
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
      expiresAt: DateTime.tryParse('${json['expires_at'] ?? ''}'),
      isActive: json['is_active'] != false,
    );
  }
}
