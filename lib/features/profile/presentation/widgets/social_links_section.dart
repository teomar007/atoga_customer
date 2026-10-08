import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../social/presentation/social_links_provider.dart';

/// قسم "التواصل الاجتماعي" داخل الملف الشخصي.
///
/// قاعدتان صارمتتان في التصميم:
/// 1. **لا يُعرض الرابط النصي أبداً** — اسم المنصة + سهم فقط.
/// 2. **ألوان موحّدة**: أيقونات Font Awesome ملوّنة بـ [AppColors.primary]
///    بلا ألوان العلامات التجارية (لا أزرق لفيسبوك ولا متعدد لإنستغرام)
///    وبلا أي صور خارجية — لتبدو جزءاً أصيلاً من ستايل التطبيق.
class SocialLinksSection extends ConsumerWidget {
  const SocialLinksSection({super.key});

  /// المنصات الثلاث بالترتيب المعروض.
  /// نوع الأيقونة [FaIconData] لا [IconData] — الحزمة تمنع استخدام FA
  /// داخل `Icon` لأن أيقوناتها غير المربعة تُقصّ؛ الصحيح هو [FaIcon].
  static const List<({String key, FaIconData icon})> platforms = <({String key, FaIconData icon})>[
    (key: 'facebook', icon: FontAwesomeIcons.facebook),
    (key: 'instagram', icon: FontAwesomeIcons.instagram),
    (key: 'tiktok', icon: FontAwesomeIcons.tiktok),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Map<String, String>> state = ref.watch(socialLinksProvider);
    // أثناء الجلب فقط: نمنع اللمس لئلا يقول "الرابط غير متوفر" قبل معرفته.
    final bool loading = state.isLoading && state.valueOrNull == null;
    final Map<String, String> links = state.valueOrNull ?? const <String, String>{};

    return Column(
      // `stretch` ضروري: أبناء العمود داخل ListView يحصلون على قيود مرتخية،
      // فمع `start` ستضيق البطاقات عن عرض الشاشة بخلاف بقية صفوف الملف.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(text: l10n.socialLinks),
        for (final ({String key, FaIconData icon}) platform in platforms)
          _SocialLinkTile(
            icon: platform.icon,
            title: _titleOf(l10n, platform.key),
            url: links[platform.key],
            loading: loading,
          ),
      ],
    );
  }

  static String _titleOf(AppLocalizations l10n, String key) {
    return switch (key) {
      'facebook' => l10n.facebook,
      'instagram' => l10n.instagram,
      'tiktok' => l10n.tiktok,
      _ => key,
    };
  }
}

/// صف منصة واحدة — بنفس معالجة بقية صفوف الملف الشخصي (حاوية سطح + نصف قطر).
class _SocialLinkTile extends StatelessWidget {
  const _SocialLinkTile({
    required this.icon,
    required this.title,
    required this.url,
    required this.loading,
  });

  final FaIconData icon;
  final String title;
  final String? url;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        enabled: !loading,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // لون صريح يمنع تلوين ListTile للأيقونة عند تعطيل الصف أثناء التحميل.
        leading: FaIcon(icon, size: 21, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
        trailing: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right_rounded),
        onTap: loading ? null : () => _open(context, url),
      ),
    );
  }

  /// يفتح الرابط في تطبيق خارجي، وينبّه المستخدم إن كان فارغاً أو تعذّر فتحه.
  ///
  /// نلتقط [ScaffoldMessengerState] قبل أي `await` حتى لا نستخدم سياقاً بعد
  /// تلفه إن أُغلقت الشاشة أثناء فتح المتصفح.
  Future<void> _open(BuildContext context, String? url) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String raw = (url ?? '').trim();

    if (raw.isEmpty) {
      _notify(messenger, l10n.linkNotSet);
      return;
    }
    final Uri? uri = Uri.tryParse(raw);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      _notify(messenger, l10n.supportUnavailable);
      return;
    }

    bool opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      // الخطأ يُبلَّغ للمستخدم عبر SnackBar أدناه، لا عبر الانهيار.
      opened = false;
    }
    if (!opened) {
      _notify(messenger, l10n.supportUnavailable);
    }
  }

  void _notify(ScaffoldMessengerState messenger, String message) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

/// عنوان القسم — بنفس نمط `_GroupLabel` داخل ProfileScreen.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
