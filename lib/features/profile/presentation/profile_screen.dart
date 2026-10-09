import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/onesignal_service.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/button_label.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/login_screen.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../checkout/presentation/address_form_screen.dart';
import '../../checkout/presentation/checkout_controller.dart';
import '../../checkout/presentation/delivery_zones_provider.dart';
import '../../checkout/domain/delivery_zone.dart';
import '../../auth/domain/auth_status.dart';
import '../../auth/domain/customer_user.dart';
import '../../checkout/domain/address.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/empty_state_view.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'widgets/app_developer_section.dart';
import 'widgets/support_section.dart';
import 'widgets/social_links_section.dart';

/// الحساب والإعدادات: البيانات الشخصية، العناوين، اللغة، الدعم، الحذف.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _versionTaps = 0;
  Timer? _versionTapTimer;

  @override
  void dispose() {
    _versionTapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final Locale locale = ref.watch(localeControllerProvider);
    // قراءة صريحة لحالة AuthStatus: كل الحالات لها فرع رسم (لا SizedBox.shrink).
    final AuthStatus status = ref.watch(authControllerProvider.select((AuthStateView s) => s.status));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: switch (status) {
        AuthGuest() => _SignedOutView(onLogin: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => const LoginScreen()))),
        AuthAuthenticated(:final CustomerUser user) => _profileBody(l10n, theme, locale, user),
        AuthLoading() => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _profileBody(AppLocalizations l10n, ThemeData theme, Locale locale, CustomerUser user) {
    return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                CircleAvatar(radius: 26, backgroundColor: AppColors.primary.withValues(alpha: 0.12), child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fallbackLabel.isEmpty ? l10n.profileTitle : user.fallbackLabel, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(user.phone ?? user.email ?? '', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(tooltip: l10n.editProfile, icon: const Icon(Icons.edit_outlined), onPressed: () => _editProfile(context, l10n)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _GroupLabel(text: l10n.personalInfo),
          _Tile(icon: Icons.badge_outlined, title: l10n.personalInfo, onTap: () => _editProfile(context, l10n)),
          _Tile(icon: Icons.phone_in_talk_outlined, title: l10n.phoneNumberOptional, trailing: user.hasPhone ? user.phone : l10n.notSet, onTap: () => _editPhone(context, l10n)),
          _Tile(icon: Icons.location_on_outlined, title: l10n.addresses, onTap: () => _manageAddresses(context, l10n)),
          _Tile(icon: Icons.translate_rounded, title: l10n.language, trailing: locale.languageCode == 'ar' ? l10n.languageArabic : l10n.languageFrench, onTap: () => ref.read(localeControllerProvider.notifier).toggle()),
          const SizedBox(height: 18),
          _GroupLabel(text: l10n.support),
          const SupportSection(),
          _Tile(icon: Icons.help_outline_rounded, title: l10n.faq, onTap: () => _open(AppConstants.faqUrl, l10n)),
          const SizedBox(height: 18),
          const SocialLinksSection(),
          const SizedBox(height: 18),
          _GroupLabel(text: l10n.appDeveloperTitle),
          const AppDeveloperSection(),
          const SizedBox(height: 18),
          _GroupLabel(text: l10n.settings),
          _Tile(icon: Icons.privacy_tip_outlined, title: l10n.privacyPolicy, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => const PrivacyPolicyScreen()))),
          _Tile(icon: Icons.gavel_rounded, title: l10n.termsOfService, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => const TermsOfServiceScreen()))),
          _Tile(icon: Icons.info_outline_rounded, title: l10n.aboutApp, trailing: l10n.appVersion(AppConstants.appVersion), onTap: () => _onVersionTap(l10n)),
          const SizedBox(height: 22),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)), icon: const Icon(Icons.logout_rounded, size: 18), label: ButtonLabel(l10n.logout), onPressed: () => ref.read(authControllerProvider.notifier).signOut())),
          const SizedBox(height: 10),
          // شرط Google Play: زر واضح باللون الأحمر لحذف الحساب نهائياً.
          SizedBox(width: double.infinity, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: AppColors.danger), icon: const Icon(Icons.delete_forever_rounded, size: 20), label: ButtonLabel(l10n.deleteAccount), onPressed: () => _deleteAccount(context, l10n))),
        ],
    );
  }

  /// أداة تشخيص مخفية: 5 نقرات على «حول التطبيق» تعرض حالة OneSignal
  /// (الإذن/الاشتراك/رمز FCM) لتشخيص وصلو الإشعارات دون adb.
  void _onVersionTap(AppLocalizations l10n) {
    _versionTapTimer?.cancel();
    _versionTaps += 1;
    _versionTapTimer = Timer(const Duration(seconds: 2), () => _versionTaps = 0);
    if (_versionTaps < 5) {
      return;
    }
    _versionTaps = 0;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) => AlertDialog(
          title: const Text('OneSignal diagnostics'),
          content: SingleChildScrollView(
            child: FutureBuilder<String>(
              future: OneSignalService.instance.nativeProbe(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) => SelectableText(
                '${OneSignalService.instance.diagnosticsSummary}\nprobe: ${snapshot.data ?? "..."}',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                OneSignalService.instance.requestPermission().whenComplete(() {
                  if (context.mounted) {
                    setDialogState(() {});
                  }
                });
              },
              child: const Text('طلب الإذن'),
            ),
            TextButton(
              // غير منتظر: التعليق كان يمنع تحديث النافذة. نحدّث فوراً ثم عند العودة.
              onPressed: () {
                setDialogState(() {});
                OneSignalService.instance.retryInitialize(AppConstants.onesignalAppId).whenComplete(() {
                  if (context.mounted) {
                    setDialogState(() {});
                  }
                });
              },
              child: const Text('إعادة تهيئة'),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ],
        ),
      ),
    );
  }

  Future<void> _editProfile(BuildContext context, AppLocalizations l10n) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final CustomerUser? user = ref.read(currentUserProvider);
    // المتحكّمات ملكية الحوار (تُحرَّر في dispose() بعد زوال شجرته)، والقيم
    // تعود عبر نتيجة pop — فلا نمسّها من هنا بعد فجوة الـ await إطلاقاً.
    final _ProfileForm? updated = await showDialog<_ProfileForm>(
      context: context,
      builder: (BuildContext context) => _ProfileEditDialog(
        initialName: user?.displayName ?? '',
        initialPhone: user?.phone ?? '',
      ),
    );
    if (updated == null || !mounted) {
      return;
    }
    final bool ok = await ref.read(authControllerProvider.notifier).updateProfile(displayName: updated.name, phone: updated.phone);
    if (!mounted) {
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(ok ? l10n.profileUpdated : l10n.somethingWentWrong)));
  }

  /// **رقم الهاتف اختياري**: يمكن إضافته أو تعديله في أي وقت.
  Future<void> _editPhone(BuildContext context, AppLocalizations l10n) async {
    final CustomerUser? user = ref.read(currentUserProvider);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String? updated = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => _PhoneEditDialog(initialValue: user?.phone ?? ''),
    );
    if (updated == null || !mounted) {
      return;
    }
    final bool ok = await ref.read(authControllerProvider.notifier).updateProfile(phone: updated);
    if (!mounted) {
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(ok ? l10n.phoneSaved : l10n.somethingWentWrong)));
  }

  Future<void> _manageAddresses(BuildContext context, AppLocalizations l10n) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => const AddressListScreen()));
  }

  /// شرط Google Play: مسح كامل لبيانات المستخدم بعد تأكيد صريح.
  Future<void> _deleteAccount(BuildContext context, AppLocalizations l10n) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 34),
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.danger), onPressed: () => Navigator.pop(context, true), child: ButtonLabel(l10n.deleteAccountConfirmAction)),
        ],
      ),
    );
    // فجوة async: نتأكد أن الشاشة ما زالت قائمة قبل أي استخدام لـ ref/context.
    if (!mounted) {
      return;
    }
    if (confirmed != true) {
      return;
    }
    final bool ok = await ref.read(authControllerProvider.notifier).deleteAccount();
    if (!mounted) {
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(ok ? l10n.accountDeleted : l10n.deleteAccountFailed)));
    if (ok) {
      await ref.read(cartControllerProvider.notifier).clear();
    }
  }

  Future<void> _open(String url, AppLocalizations l10n) async {
    final bool ok = await launchUrl(Uri.parse(url)).onError((Object error, StackTrace stack) => false);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.supportUnavailable)));
    }
  }
}

/// شاشة الزائر: رسالة صريحة + زر يوجّه إلى تسجيل الدخول.
class _SignedOutView extends StatelessWidget {
  const _SignedOutView({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return EmptyStateView(icon: Icons.lock_person_rounded, title: l10n.loginRequiredTitle, message: l10n.loginToViewProfile, actionLabel: l10n.login, onAction: onLogin);
  }
}

/// إدارة العناوين المحفوظة (إضافة / حذف).
class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AddressesState state = ref.watch(addressesControllerProvider);
    final List<DeliveryZone> zones = ref.watch(deliveryZonesProvider).valueOrNull ?? const <DeliveryZone>[];

    if (state.loading && state.items.isEmpty) {
      return Scaffold(appBar: AppBar(title: Text(l10n.addresses, maxLines: 1, overflow: TextOverflow.ellipsis)), body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addresses, maxLines: 1, overflow: TextOverflow.ellipsis)),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        // فجوة async: لا نستخدم ref قبل التأكد أن الشاشة ما زالت قائمة.
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => const AddressFormScreen())).then((_) {
          if (context.mounted) {
            ref.read(addressesControllerProvider.notifier).load();
          }
        }),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: Text(l10n.add),
      ),
      body: state.items.isEmpty
          ? Center(child: Text(l10n.noSavedAddresses, style: Theme.of(context).textTheme.bodyMedium))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              itemCount: state.items.length,
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                final Address address = state.items[index];
                final String title = address.titleFor(zones);
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title.isEmpty ? l10n.notSet : title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(address.phone, style: Theme.of(context).textTheme.bodySmall)])),
                      IconButton(tooltip: l10n.edit, icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => AddressFormScreen(existing: address))).then((_) {
                        if (context.mounted) {
                          ref.read(addressesControllerProvider.notifier).load();
                        }
                      })),
                      IconButton(tooltip: l10n.delete, icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger), onPressed: () => ref.read(addressesControllerProvider.notifier).remove(address.id ?? '')),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(4, 0, 0, 8), child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary)));
}

/// نتيجة نموذج تعديل الملف الشخصي (الاسم + الهاتف الاختياري).
class _ProfileForm {
  const _ProfileForm(this.name, this.phone);

  final String name;
  final String phone;
}

/// حوار تعديل الاسم ورقم الهاتف.
class _ProfileEditDialog extends StatefulWidget {
  const _ProfileEditDialog({required this.initialName, required this.initialPhone});

  final String initialName;
  final String initialPhone;

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  // ملكية الحوار: المتحكّم يُنشأ هنا ويُحرَّر هنا — بعد زوال الشجرة بالكامل.
  late final TextEditingController _name = TextEditingController(text: widget.initialName);
  late final TextEditingController _phone = TextEditingController(text: widget.initialPhone);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.editProfile),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _name, textCapitalization: TextCapitalization.words, decoration: InputDecoration(labelText: l10n.name, hintText: l10n.nameHint), validator: (String? v) => Validators.requiredField(v) == null ? null : l10n.fieldRequired),
            const SizedBox(height: 12),
            TextFormField(controller: _phone, keyboardType: Validators.phoneKeyboard, decoration: InputDecoration(labelText: '${l10n.phoneNumber} (${l10n.optional})', hintText: l10n.phoneHint), validator: (String? v) => _phoneError(v, l10n)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        // القيم تُقرأ قبل pop وبقبل التحرير — وهذا الآمن الوحيد للقراءة.
        FilledButton(onPressed: () { if (!(_form.currentState?.validate() ?? false)) { return; } Navigator.pop(context, _ProfileForm(_name.text.trim(), _phone.text.trim())); }, child: Text(l10n.save)),
      ],
    );
  }
}

/// حوار تعديل رقم الهاتف وحده (اختياري، يمكن تركه فارغاً للحذف).
class _PhoneEditDialog extends StatefulWidget {
  const _PhoneEditDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_PhoneEditDialog> createState() => _PhoneEditDialogState();
}

class _PhoneEditDialogState extends State<_PhoneEditDialog> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.phoneNumberOptional),
      content: Form(
        key: _form,
        child: TextFormField(controller: _controller, keyboardType: Validators.phoneKeyboard, autofocus: true, decoration: InputDecoration(labelText: l10n.phoneNumber, hintText: l10n.phoneHint, helperText: l10n.phoneOptionalHint), validator: (String? v) => _phoneError(v, l10n)),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(onPressed: () { if (!(_form.currentState?.validate() ?? false)) { return; } Navigator.pop(context, _controller.text.trim()); }, child: Text(l10n.save)),
      ],
    );
  }
}

/// الهاتف اختياري هنا: الفارغ يُحفظ كـ null (حذف)، وإن وُجد يجب أن يكون صالحاً.
String? _phoneError(String? value, AppLocalizations l10n) {
  if (Validators.isNotBlank(value)) {
    return Validators.phone(value) == null ? null : l10n.phoneInvalidShort;
  }
  return null;
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, this.onTap, this.trailing});

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 21, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
        trailing: trailing != null ? Text(trailing!, style: Theme.of(context).textTheme.bodySmall) : (onTap != null ? const Icon(Icons.chevron_right_rounded) : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
