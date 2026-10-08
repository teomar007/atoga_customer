import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'widgets/legal_document.dart';

/// شروط الاستخدام كاملة داخل التطبيق (بدلاً من رابط خارجي غير مضمون).
///
/// النص مصدره ملفات الترجمة `app_ar.arb` / `app_fr.arb` فيتحدّث مع لغة
/// الجهاز تلقائياً.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return LegalDocumentScreen(
      title: l10n.termsOfService,
      lead: l10n.termsIntro,
      sections: <LegalSection>[
        LegalSection(title: l10n.termsSecAccountTitle, body: l10n.termsSecAccountBody),
        LegalSection(title: l10n.termsSecPricingTitle, body: l10n.termsSecPricingBody),
        LegalSection(title: l10n.termsSecPaymentTitle, body: l10n.termsSecPaymentBody),
        LegalSection(title: l10n.termsSecCancellationTitle, body: l10n.termsSecCancellationBody),
        LegalSection(title: l10n.termsSecChangesTitle, body: l10n.termsSecChangesBody),
        LegalSection(title: l10n.termsSecLawTitle, body: l10n.termsSecLawBody),
      ],
    );
  }
}
