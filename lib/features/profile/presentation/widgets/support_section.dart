import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../social/presentation/social_links_provider.dart';

/// قسم «الدعم الفني»: اتصال هاتفي وواتساب بأرقام ديناميكية من Supabase.
///
/// **شرط التصميم**: لا يُعرض أي رقم في الواجهة — العناوين والأيقونات فقط،
/// والأيقونات ملوّنة بـ [AppColors.primary] لتنسجم مع ستايل التطبيق.
class SupportSection extends ConsumerWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Map<String, String>> state = ref.watch(socialLinksProvider);
    final bool loading = state.isLoading && state.valueOrNull == null;
    final Map<String, String> settings = state.valueOrNull ?? const <String, String>{};

    // `stretch` ضروري: أبناء العمود داخل ListView يحصلون على قيود مرتخية،
    // فمع `start` ستضيق البطاقات عن عرض الشاشة.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SupportTile(
          icon: const Icon(Icons.phone_outlined, size: 21, color: AppColors.primary),
          title: l10n.contactUs,
          enabled: !loading,
          onTap: () => _call(context, settings[ContactKeys.phone]),
        ),
        _SupportTile(
          icon: FaIcon(FontAwesomeIcons.whatsapp, size: 20, color: AppColors.primary),
          title: l10n.whatsapp,
          enabled: !loading,
          onTap: () => _openWhatsApp(context, settings[ContactKeys.whatsapp]),
        ),
      ],
    );
  }

  /// يفتح تطبيق الهاتف على الرقم عبر مخطط `tel:`.
  ///
  /// يلتقط `ScaffoldMessenger` قبل أي `await` ويحرس بـ `context.mounted`
  /// بعده — وإلا أُعيد بناء الشاشة أثناء الاتصال فنارتد بـ
  /// `_dependents.isEmpty is not true`.
  Future<void> _call(BuildContext context, String? raw) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String cleaned = _sanitizePhone(raw);
    if (cleaned.isEmpty) {
      _notify(messenger, l10n.contactNotSet);
      return;
    }

    bool opened = false;
    try {
      opened = await launchUrl(Uri.parse('tel:$cleaned'), mode: LaunchMode.externalApplication);
    } on Object {
      opened = false;
    }
    if (!context.mounted) {
      return;
    }
    if (!opened) {
      _notify(messenger, l10n.supportUnavailable);
    }
  }

  /// يفتح محادثة واتساب عبر `https://wa.me/<أرقام دولية بلا +>`.
  Future<void> _openWhatsApp(BuildContext context, String? raw) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String digits = _whatsappDigits(raw);
    if (digits.isEmpty) {
      _notify(messenger, l10n.contactNotSet);
      return;
    }

    bool opened = false;
    try {
      opened = await launchUrl(Uri.parse('https://wa.me/$digits'), mode: LaunchMode.externalApplication);
    } on Object {
      opened = false;
    }
    if (!context.mounted) {
      return;
    }
    if (!opened) {
      _notify(messenger, l10n.supportUnavailable);
    }
  }

  /// ينظّف الرقم لأي صيغة يكتبها الإدارة: يزيل المسافات والشرطات والأقواس،
  /// ويعتبره فارغاً إن لم يحتوِ رقماً واحداً.
  static String _sanitizePhone(String? raw) {
    final String cleaned = (raw ?? '').replaceAll(RegExp(r'[\s\-()]'), '');
    return cleaned.contains(RegExp(r'\d')) ? cleaned : '';
  }

  /// يحوّل الرقم إلى صيغة دولية مناسبة لـ `wa.me` (أرقام فقط بلا `+`):
  /// `0555 12 34 56` ← `213555123456`، و`00213…` ← `213…`،
  /// و`+213…` تبقى كما هي.
  static String _whatsappDigits(String? raw) {
    String digits = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return '';
    }
    if (digits.startsWith('00')) {
      return digits.substring(2);
    }
    if (digits.startsWith('0')) {
      return '${PhoneNumbers.defaultCountryCode}${digits.substring(1)}';
    }
    return digits;
  }

  static void _notify(ScaffoldMessengerState messenger, String message) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

/// صف دعم واحد — بنفس معالجة بقية صفوف الملف الشخصي (حاوية سطح + نصف قطر).
class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.icon,
    required this.title,
    required this.enabled,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        enabled: enabled,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: icon,
        title: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
        trailing: enabled
            ? const Icon(Icons.chevron_right_rounded)
            : const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
