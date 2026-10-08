import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/auth_status.dart';
import '../../features/auth/domain/customer_user.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/cart/presentation/cart_controller.dart';
import '../../features/checkout/presentation/checkout_controller.dart';
import '../../features/coupons/presentation/coupons_controller.dart';
import '../../features/favorites/presentation/favorites_provider.dart';
import '../../features/orders/presentation/orders_controller.dart';

/// مزامنة الجلسة: تربط بيانات المستخدم بملفه الشخصي في Supabase.
///
/// - **الدخول**: الملف الشخصي أولاً (يطبّق اللغة والتفضيلات) ثم الكوبونات
///   والسلة (مع دمج سلة الزائر) والعناوين والطلبات والمفضلة — بالتوازي.
/// - **الخروج**: تفريغ بيانات المستخدم من الذاكرة، مع الإبقاء على الإعدادات
///   العامة المحلية (اللغة) وحدها كي لا يختلّ الواجهة.
///
/// يوضع في **طبقة الواجهة** عمداً: المزوّدات التابعة للمستخدم تعتمد على
/// `authControllerProvider`، فجعل المزامنة داخله كان سيخلق دورة
/// (auth ← coupons ← auth) يمنعها Riverpod.
class SessionSync extends ConsumerStatefulWidget {
  const SessionSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionSync> createState() => _SessionSyncState();
}

class _SessionSyncState extends ConsumerState<SessionSync> {
  /// مفتاح آخر حالة زامَنّاها: يمنع إعادة المزامنة عند إعادة البناء
  /// بالحالة نفسها (الكائنات تتجدد مع كل حدث ومعرّف المستخدم لا يتغيّر).
  String? _syncedKey;

  @override
  void initState() {
    super.initState();
    // جلسة محفوظة عند الإقلاع: نزامن بعد أول إطار حتى تكون المزوّدات جاهزة.
    WidgetsBinding.instance.addPostFrameCallback((_) => _reconcile());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthStatus>(
      authControllerProvider.select((AuthStateView s) => s.status),
      (AuthStatus? previous, AuthStatus next) => _reconcile(),
    );
    return widget.child;
  }

  void _reconcile() {
    final AuthStatus status = ref.read(authControllerProvider).status;
    final String key = _keyOf(status);
    if (key == _syncedKey) {
      return;
    }
    final String? previous = _syncedKey;
    _syncedKey = key;
    // خارج دورة البناء: تعديل مزوّدات أخرى أثناء الرسم ممنوع في Riverpod.
    Future<void>.microtask(() async {
      if (!mounted) {
        return;
      }
      if (status is AuthAuthenticated) {
        await _onSignIn(status.user);
      } else if (status is AuthGuest && previous != null && previous.startsWith('in:')) {
        await _onSignOut();
      }
    });
  }

  static String _keyOf(AuthStatus status) {
    return switch (status) {
      AuthAuthenticated(:final CustomerUser user) => 'in:${user.id}',
      AuthGuest() => 'out',
      AuthLoading() => 'loading',
    };
  }

  Future<void> _onSignIn(CustomerUser user) async {
    if (!mounted) {
      return;
    }
    // 1) الملف الشخصي الكامل ← يطبّق اللغة والتفضيلات المحفوظة في الخادم.
    await ref.read(authControllerProvider.notifier).reloadProfile();
    if (!mounted) {
      return;
    }
    // 2) باقي بيانات المستخدم بالتوازي — كل مزوّد يعالج أخطاءه بنفسه.
    unawaited(ref.read(couponsProvider.notifier).refresh());
    unawaited(ref.read(cartControllerProvider.notifier).syncWithServer(user.id));
    unawaited(ref.read(addressesControllerProvider.notifier).load());
    unawaited(ref.read(ordersControllerProvider.notifier).load());
    unawaited(ref.read(favoritesProvider.notifier).fetch());
  }

  Future<void> _onSignOut() async {
    if (!mounted) {
      return;
    }
    // السلة تُمسح من الذاكرة ومن Hive معاً حتى لا تنتقل سلة حساب
    // إلى الحساب التالي على الجهاز نفسه.
    await ref.read(cartControllerProvider.notifier).clear();
    if (!mounted) {
      return;
    }
    ref.read(couponsProvider.notifier).reset();
    ref.read(favoritesProvider.notifier).reset();
    ref.read(addressesControllerProvider.notifier).reset();
    ref.read(ordersControllerProvider.notifier).reset();
    // localeControllerProvider عمداً غير مُمسوح: إعداد عام على الجهاز.
  }
}
