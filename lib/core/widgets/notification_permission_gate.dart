import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../services/onesignal_service.dart';

/// نافذة سياقية واحدة لطلب إذن الإشعارات — **بعد تسجيل الدخول فقط**،
/// فلا تقاطع شاشة الدخول ولا تجمّد الكيبورد أثناء الكتابة، وفق دليل OneSignal
/// (الطلب يقع من زر النافذة، لا عند الإقلاع). تُعرض مرة واحدة لكل تثبيت
/// ولا تُعلَّم «ظُهرت» إلا عند منح الإذن فعلاً.
class NotificationPermissionGate extends ConsumerStatefulWidget {
  const NotificationPermissionGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationPermissionGate> createState() => _NotificationPermissionGateState();
}

class _NotificationPermissionGateState extends ConsumerState<NotificationPermissionGate> {
  static const String _promptShownKey = 'onesignal_prompt_shown';

  bool _prompted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
  }

  @override
  Widget build(BuildContext context) {
    // ننتظر نجاح تسجيل الدخول ثم نعرض النافذة (بلا مقاطعة للكتابة).
    ref.listen<bool>(isSignedInProvider, (bool? previous, bool next) {
      if (next) {
        _maybePrompt();
      }
    });
    return widget.child;
  }

  Future<void> _maybePrompt() async {
    if (_prompted || !ref.read(isSignedInProvider)) {
      return;
    }
    // الإذن ممنوح مسبقاً → لا شيء.
    if (OneSignalService.instance.hasPermission) {
      _prompted = true;
      return;
    }
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getBool(_promptShownKey) ?? false) {
      _prompted = true;
      return;
    }
    _prompted = true;
    // فجوة قصيرة حتى تستقر الصفحة الرئيسية بعد الانتقال من شاشة الدخول.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        return AlertDialog(
          icon: const Icon(Icons.notifications_active_outlined),
          title: Text(l10n.onesignalPromptTitle),
          content: Text(l10n.onesignalPromptBody),
          actions: [
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                final bool granted = await OneSignalService.instance.requestPermission();
                await prefs.setBool(_promptShownKey, granted);
              },
              child: Text(l10n.onesignalPromptAllow),
            ),
          ],
        );
      },
    );
  }
}
