import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'widgets/legal_document.dart';

/// سياسة الخصوصية كاملة **داخل التطبيق** (شرط Google Play: يجب أن تكون
/// نشورة وقابلة للوصول من شاشة التسجيل والإعدادات، وليس رابطاً خارجياً).
///
/// النص مصدره ملفات الترجمة `app_ar.arb` / `app_fr.arb` فيتحدّث مع لغة
/// الجهاز تلقائياً.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return LegalDocumentScreen(
      title: l10n.privacyPolicy,
      lead: l10n.privacyIntro,
      sections: <LegalSection>[
        LegalSection(title: l10n.privacySecDataTitle, body: l10n.privacySecDataBody),
        LegalSection(title: l10n.privacySecUsageTitle, body: l10n.privacySecUsageBody),
        LegalSection(title: l10n.privacySecSecurityTitle, body: l10n.privacySecSecurityBody),
        LegalSection(title: l10n.privacySecRightsTitle, body: l10n.privacySecRightsBody),
        LegalSection(title: l10n.privacySecContactTitle, body: l10n.privacySecContactBody),
      ],
    );
  }
}
