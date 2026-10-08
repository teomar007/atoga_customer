import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// بطاقة تعريفية بالفريق المطوّر (DIRAYA LAB): لوجو الشركة + نص تسويقي
/// + بريد التواصل مع نسخ فوري بنقرة واحدة.
class AppDeveloperSection extends StatelessWidget {
  const AppDeveloperSection({super.key});

  /// بريد التواصل التسويقي — يُعرض كما هو ويُنسخ بالنقر.
  static const String email = 'DIRAYALAB@GMAIL.COM';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // اللوجو بلا صندوق ولا حواف: يملأ مساحته بأقصى وضوح.
              SizedBox(
                width: 64,
                height: 64,
                child: Image.asset(
                  'assets/images/diraya_lab_logo.png',
                  fit: BoxFit.contain,
                  // لو حُذف الملف من الأصول لسبب ما نعود لأيقونة رمزية.
                  errorBuilder: (BuildContext context, Object error, StackTrace? stack) => const Icon(Icons.developer_mode_rounded, color: AppColors.primary, size: 32),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('DIRAYA LAB', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.appDeveloperMarketing, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
          const SizedBox(height: 12),
          // البريد بأكمله قابل للنقر للنسخ — RTL/LTR عبر Row مع توجيه start.
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _copyEmail(context, l10n),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(email, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.copy_rounded, size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyEmail(BuildContext context, AppLocalizations l10n) async {
    await Clipboard.setData(const ClipboardData(text: email));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.appDeveloperEmailCopied)));
  }
}
