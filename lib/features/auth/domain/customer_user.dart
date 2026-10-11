/// مستخدم مُصادَق عليه.
///
/// ملاحظة: تجنّبنا تسمية النموذج `AuthUser` لأن `package:supabase` يصدّر
/// صنفاً مهجوراً بنفس الاسم فيتعارضان.
class CustomerUser {
  const CustomerUser({required this.id, this.phone, this.email, this.displayName, this.languageCode, this.walletBalance = 0, this.onesignalId, this.isFrozen = false, this.frozenReason});

  final String id;
  final String? phone;
  final String? email;
  final String? displayName;

  /// لغة المستخدم المحفوظة في `profiles.language_code` (`ar` / `fr`).
  /// `null` = لم يختر بعد ← نعتمد اللغة المحلية على الجهاز.
  final String? languageCode;

  /// رصيد المحفظة الإلكترونية (`profiles.wallet_balance`) — يُقرأ فقط ولا
  /// يُعدَّل من العميل (الخصم/الشحن عبر دوال آمنة في الخادم).
  final double walletBalance;

  /// معرّف اشتراك OneSignal لهذا الجهاز (`profiles.onesignal_id`) —
  /// يستخدمه تطبيق الإدارة لاستهداف الزبون بالإشعارات.
  final String? onesignalId;

  /// حساب مجمّد: يسمح بالدخول لكن يمنع الشراء (يُدار من تطبيق المانجر).
  final bool isFrozen;

  /// سبب التجميد المعروض للزبون.
  final String? frozenReason;

  /// اسم العرض: الاسم المحفوظ، وإلا الهاتف أو البريد.
  String get fallbackLabel {
    final String named = (displayName ?? '').trim();
    if (named.isNotEmpty) {
      return named;
    }
    return phone ?? email ?? '';
  }

  /// رقم الهاتف اختياري وقد يكون `null`؛ استخدام `clearPhone` لتفريغه صراحةً.
  CustomerUser copyWith({String? displayName, String? phone, bool clearPhone = false, String? languageCode, double? walletBalance, String? onesignalId, bool? isFrozen, String? frozenReason, bool clearFrozenReason = false}) {
    return CustomerUser(id: id, phone: clearPhone ? null : (phone ?? this.phone), email: email, displayName: displayName ?? this.displayName, languageCode: languageCode ?? this.languageCode, walletBalance: walletBalance ?? this.walletBalance, onesignalId: onesignalId ?? this.onesignalId, isFrozen: isFrozen ?? this.isFrozen, frozenReason: clearFrozenReason ? null : (frozenReason ?? this.frozenReason));
  }

  /// هل يوجد رقم هاتف صالح يمكن استخدامه للتوصيل.
  bool get hasPhone => (phone ?? '').trim().isNotEmpty;

  factory CustomerUser.fromJson(Map<String, dynamic> json) {
    return CustomerUser(
      id: '${json['id'] ?? ''}',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      displayName: json['display_name']?.toString(),
      languageCode: json['language_code']?.toString(),
      walletBalance: double.tryParse('${json['wallet_balance'] ?? ''}') ?? 0,
      onesignalId: json['onesignal_id']?.toString(),
      isFrozen: json['is_frozen'] == true,
      frozenReason: json['frozen_reason']?.toString(),
    );
  }
}
