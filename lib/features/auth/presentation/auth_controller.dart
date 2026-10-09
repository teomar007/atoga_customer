import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/onesignal_service.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../../core/providers/locale_provider.dart';
import '../domain/auth_failure.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_status.dart';
import '../domain/customer_user.dart';

/// إشارات الانشغال أثناء تنفيذ عملية مصادقة أو حفظ ملف شخصي.
enum AuthPhase { idle, googleSignIn, phoneSignIn, signUp, savingProfile, deleting }

/// حالة المصادقة كاملة (مستخدم + انشغال + خطأ + رسالة ما بعد التسجيل).
class AuthStateView {
  const AuthStateView({required this.status, this.phase = AuthPhase.idle, this.errorCode, this.errorDetail, this.notice});

  final AuthStatus status;
  final AuthPhase phase;

  /// مفتاح رسالة خطأ تُترجمه الواجهة.
  final String? errorCode;

  /// نص الخطأ الخام من الخادم — يُعرض عند `serverError` بدل رسالة عامة.
  final String? errorDetail;

  /// رسالة نجاح/إرشاد (مثل "تحقق من بريدك").
  final String? notice;

  bool get isBusy => phase != AuthPhase.idle;

  AuthStateView copyWith({AuthStatus? status, AuthPhase? phase, String? errorCode, String? errorDetail, bool clearError = false, String? notice, bool clearNotice = false}) {
    return AuthStateView(status: status ?? this.status, phase: phase ?? this.phase, errorCode: clearError ? null : (errorCode ?? this.errorCode), errorDetail: clearError ? null : (errorDetail ?? this.errorDetail), notice: clearNotice ? null : (notice ?? this.notice));
  }
}

class AuthController extends Notifier<AuthStateView> {
  StreamSubscription<CustomerUser?>? _subscription;
  StreamSubscription<String?>? _pushSub;

  @override
  AuthStateView build() {
    final AuthRepository repo = ref.watch(authRepositoryProvider);
    final CustomerUser? cached = repo.currentUser;
    _subscription = repo.authStateChanges().listen(_onUserChanged);
    // بمجرد توفر معرّف اشتراك OneSignal (أو تغيّره) يُربط بالحساب الحالي.
    _pushSub = pushSubscriptionIdEvents.stream.listen((String? id) {
      if (id != null) {
        unawaited(_syncPushSubscription(id));
      }
    });
    ref.onDispose(() => _subscription?.cancel());
    ref.onDispose(() => _pushSub?.cancel());
    // اتجاه الكتابة: أي تغيير للغة أثناء تسجيل الدخول يُحفظ في profiles.
    ref.listen<Locale>(localeControllerProvider, (Locale? previous, Locale next) => _pushLanguage(next.languageCode));
    return AuthStateView(status: cached == null ? const AuthGuest() : AuthAuthenticated(cached));
  }

  /// اتجاه القراءة: نعتمد لغة الحساب بعد نجاح الدخول أو إنشائه.
  /// غياب `language_code` يعني «لم يختر بعد» ← نبقي اللغة المحلية كما هي.
  void _adoptLanguage(CustomerUser user) {
    final String? code = user.languageCode;
    if (code == null || code.trim().isEmpty) {
      return;
    }
    ref.read(localeControllerProvider.notifier).applyRemote(code);
  }

  /// اتجاه الكتابة: يحفظ اللغة المختارة في `profiles` إن كان المستخدم
  /// مسجّلاً (لا شيء للزائر)، ويتجاهل التنفيذ إن كانت متزامنة مسبقاً.
  Future<void> _pushLanguage(String code) async {
    final AuthStatus status = state.status;
    if (status is! AuthAuthenticated) {
      return;
    }
    if (status.user.languageCode == code) {
      return;
    }
    try {
      await ref.read(authRepositoryProvider).saveLanguage(code);
      // نُثبّت القيمة في الحالة حتى لا يُعاد الدفع عند أي تغيير لاحق.
      state = state.copyWith(status: AuthAuthenticated(status.user.copyWith(languageCode: code)));
    } on Object catch (error) {
      // الفشل لا يُبطل اختيار المستخدم: تبقى اللغة محفوظة محلياً.
      debugPrint('saveLanguage failed: $error');
    }
  }

  void _onUserChanged(CustomerUser? user) {
    state = state.copyWith(status: user == null ? const AuthGuest() : AuthAuthenticated(user));
  }

  void clearError() {
    state = state.copyWith(clearError: true, clearNotice: true, phase: AuthPhase.idle);
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(phase: AuthPhase.googleSignIn, clearError: true, clearNotice: true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      state = state.copyWith(phase: AuthPhase.idle);
      return true;
    } on Object catch (error, stack) {
      debugPrint('signIn failed: $error\n$stack');
      state = _failed(AuthPhase.idle, error);
      return false;
    }
  }

  Future<bool> signIn({required String phone, required String password}) async {
    state = state.copyWith(phase: AuthPhase.phoneSignIn, clearError: true, clearNotice: true);
    try {
      final CustomerUser user = await ref.read(authRepositoryProvider).signInWithPassword(phone: phone, password: password);
      _adoptLanguage(user);
      state = state.copyWith(phase: AuthPhase.idle, status: AuthAuthenticated(user));
      unawaited(_syncPushSubscriptionFromSdk());
      return true;
    } on Object catch (error) {
      state = _failed(AuthPhase.idle, error);
      return false;
    }
  }

  Future<bool> signUp({required String phone, required String password, String? displayName}) async {
    state = state.copyWith(phase: AuthPhase.signUp, clearError: true, clearNotice: true);
    try {
      final SignUpResult result = await ref.read(authRepositoryProvider).signUp(phone: phone, password: password, displayName: displayName);
      if (result.sessionReady) {
        _adoptLanguage(result.user);
      }
      // sessionReady = المستخدم داخل التطبيق مباشرة، وإلا فثمة إعداد ناقص
      // في Supabase (mailer_autoconfirm) فيتعين إصلاحه قبل الدخول.
      state = state.copyWith(
        phase: AuthPhase.idle,
        status: result.sessionReady ? AuthAuthenticated(result.user) : state.status,
        errorCode: result.sessionReady ? null : 'autoconfirmRequired',
        errorDetail: result.sessionReady ? null : 'no session returned from signUp (mailer_autoconfirm=false)',
        notice: result.sessionReady ? 'accountCreated' : null,
      );
      if (result.sessionReady) {
        unawaited(_syncPushSubscriptionFromSdk());
      }
      return true;
    } on Object catch (error, stack) {
      debugPrint('signUp failed: $error\n$stack');
      state = _failed(AuthPhase.idle, error);
      return false;
    }
  }

  /// يجلب الملف الشخصي الكامل ويعيد تطبيق لغته وتفضيلاته.
  ///
  /// يُستدعى من مزامنة الجلسة عند الإقلاع بجلسة محفوظة — `_map` لا يقرأ
  /// `profiles`، فبدون هذا الاستدعاء لا تصل لغة الحساب إلى التطبيق.
  Future<void> reloadProfile() async {
    final AuthStatus status = state.status;
    if (status is! AuthAuthenticated) {
      return;
    }
    try {
      final CustomerUser full = await ref.read(authRepositoryProvider).refreshProfile();
      _adoptLanguage(full);
      state = state.copyWith(status: AuthAuthenticated(full));
    } on Object catch (error) {
      debugPrint('reloadProfile failed: $error');
    }
  }

  Future<void> signOut() async {
    // تصفير معرّف الإشعارات قبل مسح الجلسة (يحتاج المستخدم الحالي)، ثم
    // فصل الجهاز عن OneSignal حتى لا تصله إشعارات شخصية بعد خروج صاحبه.
    await _syncPushSubscription(null);
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthStateView(status: AuthGuest());
    _disconnectOneSignal();
  }

  /// تعديل الاسم و/أو رقم الهاتف (الهاتف اختياري).
  Future<bool> updateProfile({String? displayName, String? phone}) async {
    state = state.copyWith(phase: AuthPhase.savingProfile, clearError: true, clearNotice: true);
    try {
      final CustomerUser user = await ref.read(authRepositoryProvider).updateProfile(displayName: displayName, phone: phone);
      state = state.copyWith(phase: AuthPhase.idle, status: AuthAuthenticated(user));
      return true;
    } on Object catch (error) {
      state = _failed(AuthPhase.idle, error);
      return false;
    }
  }

  /// حفظ رقم الهاتف وحده — يستدعيه الـ BottomSheet في شاشة الدفع.
  Future<bool> savePhone(String phone) async {
    state = state.copyWith(phase: AuthPhase.savingProfile, clearError: true, clearNotice: true);
    try {
      final CustomerUser user = await ref.read(authRepositoryProvider).savePhone(phone);
      state = state.copyWith(phase: AuthPhase.idle, status: AuthAuthenticated(user));
      return true;
    } on Object catch (error) {
      state = _failed(AuthPhase.idle, error);
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(phase: AuthPhase.deleting, clearError: true, clearNotice: true);
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      state = const AuthStateView(status: AuthGuest());
      _disconnectOneSignal();
      return true;
    } on Object catch (error) {
      state = _failed(AuthPhase.idle, error);
      return false;
    }
  }

  /// يقرأ معرّف الاشتراك من OneSignal ويحفظه (يُستدعى بعد نجاح الدخول).
  Future<void> _syncPushSubscriptionFromSdk() async {
    await _syncPushSubscription(OneSignalService.instance.currentSubscriptionId);
  }

  /// فصل الجهاز عن OneSignal بعد الخروج/حذف الحساب، بشكل غير منتظَر:
  /// لا يجوز أن يعلّق قناة المنصة عملية الخروج نفسها (وفي الاختبارات لا
  /// توجد قناة حقيقية أصلاً).
  void _disconnectOneSignal() {
    unawaited(OneSignalService.instance.logout());
  }

  /// يكتب المعرّف في `profiles.onesignal_id` (أو يصفّره عند الخروج).
  Future<void> _syncPushSubscription(String? id) async {
    if (state.status is! AuthAuthenticated) {
      return;
    }
    try {
      await ref.read(authRepositoryProvider).savePushSubscriptionId(id);
    } on Object catch (error) {
      debugPrint('savePushSubscriptionId failed: $error');
    }
  }

  /// تحويل الاستثناء إلى (مفتاح رسالة + نص خام) مع تسجيل التفصيل الحقيقي.
  AuthStateView _failed(AuthPhase phase, Object error) {
    // استثناءات مخصّصة تُخزّن مفتاحها جاهزاً (مثل phone_invalid).
    if (error is AuthException) {
      return state.copyWith(phase: phase, errorCode: error.code, errorDetail: error.code);
    }
    final AuthFailure failure = AuthFailureMapper.map(error);
    debugPrint('AuthController failure [$phase]: $failure');
    return state.copyWith(phase: phase, errorCode: failure.code, errorDetail: failure.userMessage);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthStateView>(AuthController.new);

/// المستخدم الحالي (null للزائر).
final currentUserProvider = Provider<CustomerUser?>((Ref ref) {
  final AuthStatus status = ref.watch(authControllerProvider.select((AuthStateView s) => s.status));
  return status is AuthAuthenticated ? status.user : null;
});

/// هل المستخدم مسجّل الدخول (شرط إتمام الطلب).
final isSignedInProvider = Provider<bool>((Ref ref) => ref.watch(currentUserProvider) != null);

/// **بوابة الطلب**: رقم الهاتف مطلوب لإتمام أي طلب توصيل.
/// مصدر الحقيقة هو جدول `profiles` (وليس Auth)، لأن الهاتف اختياري there.
final hasDeliveryPhoneProvider = Provider<bool>((Ref ref) => ref.watch(currentUserProvider)?.hasPhone ?? false);
