import 'customer_user.dart';

/// حالة المصادقة: أثناء الفحص، زائر، أو مُصادَق.
sealed class AuthStatus {
  const AuthStatus();
}

/// لم تُنتهَ قراءة الجلسة المحفوظة بعد.
class AuthLoading extends AuthStatus {
  const AuthLoading();
}

/// المستخدم يتصفح بلا حساب (يُطلب الدخول عند إتمام الطلب فقط).
class AuthGuest extends AuthStatus {
  const AuthGuest();
}

class AuthAuthenticated extends AuthStatus {
  const AuthAuthenticated(this.user);

  final CustomerUser user;
}
