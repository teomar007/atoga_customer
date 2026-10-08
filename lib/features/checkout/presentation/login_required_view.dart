import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/generated/app_localizations.dart';

/// رسالة "تسجيل الدخول مطلوب" — تظهر للزائر عند محاولة إتمام الطلب
/// (وضع الزائر: التصفح بلا حساب، والدخول مطلوب فقط عند الشراء).
class LoginRequiredView extends StatelessWidget {
  const LoginRequiredView({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return EmptyStateView(icon: Icons.lock_person_rounded, title: l10n.loginRequiredTitle, message: l10n.loginRequiredBody, actionLabel: l10n.proceed, onAction: onLogin);
  }
}
