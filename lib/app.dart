import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/locale_provider.dart';
import 'core/navigation/auth_gate.dart';
import 'core/navigation/session_sync.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/notification_permission_gate.dart';
import 'core/widgets/store_icon_sync.dart';
import 'l10n/generated/app_localizations.dart';

class AtogaApp extends ConsumerWidget {
  const AtogaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale locale = ref.watch(localeControllerProvider);
    return MaterialApp(
      title: 'ATOGA MARKET',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(locale),
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      // بوابة الإشعارات + مزامنة أيقونة المتجر، ثم مزامنة الجلسة والبوابة.
      home: const NotificationPermissionGate(child: StoreIconSync(child: SessionSync(child: AuthGate()))),
      builder: (BuildContext context, Widget? child) {
        // ثبات قياس الخط بغض النظر عن حجم خط النظام (سلامة التخطيط).
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(data: media.copyWith(textScaler: media.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3)), child: child ?? const SizedBox.shrink());
      },
    );
  }
}
