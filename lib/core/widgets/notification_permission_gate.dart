import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/generated/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../services/onesignal_service.dart';

/// نافذة سياقية واحدة لطلب إذن الإشعارات: تظهر مرة واحدة (لكل تثبيت)
/// عند وصول معرّف اشتراك حقيقي، وتشرح الفائدة قبل فتح نافذة النظام —
/// وفق دليل OneSignal (الطلب يتم من زر النافذة فقط، لا عند الإقلاع).
class NotificationPermissionGate extends ConsumerStatefulWidget {
  const NotificationPermissionGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationPermissionGate> createState() => _NotificationPermissionGateState();
}

class _NotificationPermissionGateState extends ConsumerState<NotificationPermissionGate> {
  static const String _promptShownKey = 'onesignal_prompt_shown';

  StreamSubscription<String?>? _subscription;
  bool _prompted = false;

  @override
  void initState() {
    super.initState();
    _subscription = pushSubscriptionIdEvents.stream.listen(_maybePrompt);
    // قد يكون المعرّف جاهزاً قبل تسجيل المستمع — تقييم فوري.
    _maybePrompt(OneSignalService.instance.currentSubscriptionId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _maybePrompt(String? id) async {
    if (_prompted || !OneSignalService.isRealSubscriptionId(id)) {
      return;
    }
    _prompted = true;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getBool(_promptShownKey) ?? false) {
      return;
    }
    await prefs.setBool(_promptShownKey, true);
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
              onPressed: () {
                Navigator.pop(context);
                OneSignalService.instance.requestPermission();
              },
              child: Text(l10n.onesignalPromptAllow),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
