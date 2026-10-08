import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../profile/presentation/privacy_policy_screen.dart';
import '../../profile/presentation/terms_of_service_screen.dart';
import 'auth_controller.dart';
import '../data/saved_credentials_store.dart';
import 'widgets/brand_hero.dart';

/// يعرض رمز الخطأ الداخلي على الشاشة في وضع التصحيح فقط (يسهّل التشخيص).
const bool authErrorDebugEnabled = true;

/// وضع الشاشة: تسجيل الدخول أم إنشاء حساب جديد.
enum AuthMode { login, register }

/// شاشة المصادقة: **Google Sign-In** أو **البريد الإلكتروني + كلمة المرور**.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.canGoBack = true});

  final bool canGoBack;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final TextEditingController _name = TextEditingController();

  AuthMode _mode = AuthMode.login;
  bool _obscure = true;
  bool _remember = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  /// تعبئة الحقول تلقائياً من البيانات المحفوظة (إن وجدت) مع تفعيل
  /// مربع الحفظ — حتى يدرك المستخدم أنها مسجّلة ويمكنه إلغاؤها.
  Future<void> _loadSavedCredentials() async {
    try {
      final SavedCredentials? saved = await ref.read(savedCredentialsStoreProvider).read();
      if (!mounted || saved == null) {
        return;
      }
      setState(() {
        _phone.text = saved.phone;
        _password.text = saved.password;
        _remember = true;
      });
    } on Object catch (error) {
      debugPrint('load saved credentials failed: $error');
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    _name.dispose();
    super.dispose();
  }

  void _toggleMode() {
    ref.read(authControllerProvider.notifier).clearError();
    setState(() => _mode = _mode == AuthMode.login ? AuthMode.register : AuthMode.login);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthStateView auth = ref.watch(authControllerProvider);
    final ThemeData theme = Theme.of(context);
    final bool register = _mode == AuthMode.register;
    return Scaffold(
      appBar: widget.canGoBack ? AppBar() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
          const BrandHero(),
          // بطاقة النموذج العائمة: تتراكب قليلاً فوق الترويسة الحمراء.
          Transform.translate(
            offset: const Offset(0, -28),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 10))],
                ),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(register ? l10n.createAccount : l10n.loginTitle, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 6),
                const SizedBox(height: 6),
                Text(register ? l10n.registerSubtitle : l10n.loginSubtitlePhone, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 26),
                if (register) ...[
                  TextFormField(controller: _name, textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: l10n.name, hintText: l10n.nameHint, prefixIcon: const Icon(Icons.badge_outlined, size: 20)), validator: (String? v) => Validators.requiredField(v) == null ? null : l10n.fieldRequired),
                  const SizedBox(height: 12),
                ],
                TextFormField(controller: _phone, keyboardType: TextInputType.phone, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: l10n.phoneNumber, hintText: l10n.phoneHint, helperText: l10n.phoneAuthHint, prefixIcon: const Icon(Icons.phone_rounded, size: 20)), validator: (String? v) => Validators.phoneRequired(v) == null ? null : l10n.phoneInvalidShort),
                const SizedBox(height: 12),
                TextFormField(controller: _password, obscureText: _obscure, textInputAction: register ? TextInputAction.next : TextInputAction.done, decoration: InputDecoration(labelText: l10n.password, prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20), onPressed: () => setState(() => _obscure = !_obscure))), validator: (String? v) => Validators.password(v) == null ? null : l10n.passwordTooShort),
                // «حفظ كلمة المرور» اختياري وبمبادرة المستخدم حصراً:
                // الكتابة تتم في التخزين المشفّر بعد نجاح الدخول فقط.
                if (!register) ...[
                  const SizedBox(height: 4),
                  CheckboxListTile(
                    value: _remember,
                    onChanged: (bool? value) => setState(() => _remember = value ?? false),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(l10n.rememberPassword, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(l10n.rememberPasswordHint, style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
                if (register) ...[
                  const SizedBox(height: 12),
                  TextFormField(controller: _confirm, obscureText: _obscure, textInputAction: TextInputAction.done, decoration: InputDecoration(labelText: l10n.confirmPassword, prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20)), validator: (String? v) => v == _password.text ? null : l10n.passwordMismatch),
                ],
                if (auth.errorCode != null) ...[
                  const SizedBox(height: 12),
                  _MessageBox(text: _errorMessage(auth.errorCode!, auth.errorDetail, l10n), isError: true),
                ],
                if (auth.notice != null) ...[
                  const SizedBox(height: 12),
                  _MessageBox(text: _noticeMessage(auth.notice!, l10n), isError: false),
                ],
                if (_debugHint(l10n) != null) _debugHint(l10n)!,
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: auth.isBusy ? null : () => _submit(register),
                  child: Text(register ? l10n.createAccount : l10n.login),
                ),
                const SizedBox(height: 6),
                TextButton(onPressed: auth.isBusy ? null : _toggleMode, child: Text(register ? l10n.haveAccount : l10n.noAccount)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(l10n.orContinueWith, style: theme.textTheme.bodySmall)),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  // شعار Google الرسمي متعدد الألوان: assets/images/google_logo.png
                  // (مصدره الرسمي: https://www.gstatic.com/images/branding/googleg/1x/googleg_standard_color_128dp.png)
                  icon: SizedBox(
                    width: 22,
                    height: 22,
                    child: Image.asset(
                      'assets/images/google_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (BuildContext context, Object error, StackTrace? stack) => const Icon(Icons.g_mobiledata_rounded, size: 24, color: AppColors.textSecondary),
                    ),
                  ),
                  label: Text(l10n.continueWithGoogle),
                  onPressed: auth.isBusy ? null : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                ),
                const SizedBox(height: 12),
                // سياسة الخصوصية نشورة داخل شاشة التسجيل (شرط Google Play).
                Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodySmall,
                    children: [
                      TextSpan(text: '${l10n.byContinuing} '),
                      WidgetSpan(child: GestureDetector(onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => const TermsOfServiceScreen())), child: Text(l10n.termsOfService, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)))),
                      TextSpan(text: ' • '),
                      WidgetSpan(child: GestureDetector(onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => const PrivacyPolicyScreen())), child: Text(l10n.privacyPolicy, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)))),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(l10n.appVersion(AppConstants.appVersion), textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _submit(bool register) async {
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }
    final AuthController controller = ref.read(authControllerProvider.notifier);
    // Supabase يطلب صيغة E.164، ونحوّل أي صيغة مقبولة قبل الإرسال.
    final String? e164 = PhoneNumbers.toE164(_phone.text);
    if (e164 == null) {
      setState(() {});
      return;
    }
    if (register) {
      await controller.signUp(phone: e164, password: _password.text, displayName: _name.text);
    } else {
      final bool ok = await controller.signIn(phone: e164, password: _password.text);
      if (ok) {
        // النجاح فقط: نحفظ إن فُعِّل «حفظ كلمة المرور»، ونمسح إن أُلغي.
        final SavedCredentialsStore store = ref.read(savedCredentialsStoreProvider);
        if (_remember) {
          await store.save(_phone.text, _password.text);
        } else {
          await store.clear();
        }
      }
    }
  }

  String _errorMessage(String code, String? detail, AppLocalizations l10n) {
    return switch (code) {
      'invalid_credentials' => l10n.invalidCredentials,
      'phoneExists' => l10n.phoneExists,
      'phone_invalid' => l10n.phoneInvalidShort,
      'emailExists' => l10n.phoneExists,
      'weakPassword' => l10n.passwordTooShort,
      'phoneConfirm' => l10n.phoneConfirmNeeded,
      'autoconfirmRequired' => l10n.autoconfirmRequired,
      'phoneAuthDisabled' => l10n.phoneAuthDisabled,
      'smsNotConfigured' => l10n.smsNotConfigured,
      'rate_limited' => l10n.tooManyAttemptsDetailed,
      'signUpDisabled' => l10n.signUpDisabled,
      'userBanned' => l10n.userBanned,
      'sessionExpired' => l10n.sessionExpired,
      'invalidInput' => l10n.invalidInput,
      'rlsDenied' => l10n.rlsDenied,
      'schemaMissing' => l10n.schemaMissing,
      'no_internet' => l10n.noInternetBody,
      'sign_up_failed' => l10n.signUpFailed,
      'signup_denied' => l10n.signUpFailed,
      'delete_account_denied' => l10n.deleteAccountFailed,
      'not_authenticated' => l10n.loginRequiredTitle,
      'serverError' => (detail?.isNotEmpty ?? false) ? detail! : l10n.somethingWentWrong,
      _ => l10n.somethingWentWrong,
    };
  }

  /// يعرض رمز الخطأ الداخلي تحت debugShowCheckedModeBanner حتى يمكن
  /// تشخيص المشكلة من الكونسول/الشاشة بدل رسالة عامة.
  Widget? _debugHint(AppLocalizations l10n) {
    final bool show = kDebugMode && authErrorDebugEnabled;
    if (!show) {
      return null;
    }
    final String? code = ref.read(authControllerProvider).errorCode;
    if (code == null) {
      return null;
    }
    return Padding(padding: const EdgeInsets.only(top: 8), child: Text(l10n.errorCodeLabel(code), style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary)));
  }

  String _noticeMessage(String code, AppLocalizations l10n) {
   return switch (code) {
      'phoneConfirm' => l10n.phoneConfirmNeeded,
      'accountCreated' => l10n.accountCreated,
      'resetSent' => l10n.resetSent,
      _ => '',
    };
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final Color color = isError ? AppColors.danger : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 13))),
        ],
      ),
    );
  }
}
