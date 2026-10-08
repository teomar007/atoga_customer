import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// عنوان فرعي داخل مستند قانوني: عنوان بارز + فقرة.
class LegalSection {
  const LegalSection({required this.title, required this.body});

  final String title;
  final String body;
}

/// هيكل مشترك لشاشتي سياسة الخصوصية وشروط الاستخدام:
/// عنوان المستند + تاريخ آخر تحديث + مقدمة + أقسام مرقّمة، كلها داخل
/// [ListView] قابل للتمرير لضمان قراءة مريحة على أي طول شاشة.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.lead,
    required this.sections,
  });

  final String title;

  /// الفقرة الافتتاحية أسفل العنوان مباشرة.
  final String lead;

  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(l10n.legalLastUpdated, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          Text(lead, style: theme.textTheme.bodyMedium?.copyWith(height: 1.7, color: AppColors.textSecondary)),
          const SizedBox(height: 18),
          for (final LegalSection section in sections) _LegalSectionView(section: section),
          const SizedBox(height: 4),
          Text(l10n.appVersion(AppConstants.appVersion), textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _LegalSectionView extends StatelessWidget {
  const _LegalSectionView({required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Expanded(child: Text(section.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 8),
          Text(section.body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.7)),
        ],
      ),
    );
  }
}
