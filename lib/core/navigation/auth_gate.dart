import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/auth_status.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import 'main_shell.dart';

/// بوابة المصادقة (App Wrapper).
///
/// - `AuthLoading` → شاشة البداية (بانتظار استعادة الجلسة).
/// - `AuthAuthenticated` → الهيكل الرئيسي مباشرة.
/// - `AuthGuest` → شاشة الدخول **إجبارياً**.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthStatus status = ref.watch(authControllerProvider.select((AuthStateView s) => s.status));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: switch (status) {
        AuthLoading() => const SplashScreen(key: ValueKey<String>('splash')),
        AuthAuthenticated() => const MainShell(key: ValueKey<String>('shell')),
        AuthGuest() => const _ForcedLoginScreen(key: ValueKey<String>('login')),
      },
    );
  }
}

/// شاشة الدخول الإلزامية: تمنع الرجوع لأن المستخدم لم يدخل بعد.
class _ForcedLoginScreen extends StatelessWidget {
  const _ForcedLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PopScope(canPop: false, child: LoginScreen(canGoBack: false));
  }
}
