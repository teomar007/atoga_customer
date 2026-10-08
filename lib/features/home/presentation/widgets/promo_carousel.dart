import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

import '../../../../core/theme/app_colors.dart';
import '../../domain/promo_banner.dart';
import '../home_controller.dart';

/// شريط العروض الترويجية (Carousel أفقي).
///
/// يتحرك أوتوماتيكياً في لوب (1 ← 2 ← 3 … ثم يعود للأولى) بسرعة طبيعية
/// (كل 4 ثوانٍ مع انسياب 550ms) ويتوقف مؤقتاً أثناء سحب المستخدم.
class PromoCarousel extends ConsumerStatefulWidget {
  const PromoCarousel({super.key, required this.banners});

  final List<PromoBanner> banners;

  @override
  ConsumerState<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends ConsumerState<PromoCarousel> {
  late final PageController _controller = PageController(viewportFraction: 0.88);
  Timer? _autoTimer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// الحلقة التلقائية: تقدم كل 4 ثوانٍ ثم تعود للأولى بعد الأخيرة.
  void _startAutoPlay() {
    _autoTimer?.cancel();
    if (widget.banners.length < 2) {
      return;
    }
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) => _advance());
  }

  void _advance() {
    if (!_controller.hasClients) {
      return;
    }
    final int next = (_current + 1) % widget.banners.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    _current = index;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // إيقاف الحلقة أثناء سحب المستخدم، واستئنافها بعد الانتهاء.
        if (notification is ScrollStartNotification) {
          _autoTimer?.cancel();
        } else if (notification is ScrollEndNotification) {
          _startAutoPlay();
        }
        return false;
      },
      child: SizedBox(
        height: 148,
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.banners.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (BuildContext context, int index) {
            final PromoBanner banner = widget.banners[index];
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 12, start: 2),
              child: _BannerCard(banner: banner, onTap: () => ref.read(homeControllerProvider.notifier).selectCategory(banner.targetCategoryId)),
            );
          },
        ),
      ),
    );
}
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.onTap});

  final PromoBanner banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String lang = Localizations.localeOf(context).languageCode;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // الصورة الكاملة للبنر، أو التصميم القديم عند غيابها/فشلها.
            _Background(banner: banner),
            _BannerOverlay(title: banner.titleFor(lang), subtitle: banner.subtitleFor(lang), discountLabel: banner.discountLabel, showScrim: banner.hasImage),
          ],
        ),
      ),
    );
  }
}

/// خلفية البنر: صورة الشبكة تعبئ كامل البطاقة (BoxFit.cover) مع تراجع
/// تلقائي إلى التصميم القديم (تدرّج ملون) عندما يكون الرابط فارغاً أو
/// فشل تحميل الصورة — حتى لا نعرض بطاقة فارغة أبداً.
class _Background extends StatelessWidget {
  const _Background({required this.banner});

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    if (!banner.hasImage) {
      return const _GradientBackground();
    }
    // الصورة المضمّنة (استضافة ذاتية) عند تطابق الرابط — بلا اعتماد شبكة.
    final String? bundled = PromoBanner.bundledAssetFor(banner.imageUrl);
    if (bundled != null) {
      return Image.asset(
        bundled,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) => const _GradientBackground(),
      );
    }
    return CachedNetworkImage(
      imageUrl: banner.imageUrl!,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (BuildContext context, String url) => const _GradientBackground(),
      errorWidget: (BuildContext context, String url, Object error) => const _GradientBackground(),
    );
  }
}

/// التصميم القديم: خلفية متدرجة بالألوان الأساسية.
class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: <Color>[AppColors.primary, AppColors.primaryDark], begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd),
      ),
    );
  }
}

/// النصوص فوق الخلفية: شارة الخصم + العنوان + السطر التوضيحي، مع تظليل
/// سفلي خفيف فوق الصور لضمان الوضوح.
class _BannerOverlay extends StatelessWidget {
  const _BannerOverlay({required this.title, required this.subtitle, required this.discountLabel, required this.showScrim});

  final String title;
  final String? subtitle;
  final String? discountLabel;
  final bool showScrim;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Stack(
      children: [
        if (showScrim)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topCenter,
                    end: AlignmentDirectional.bottomCenter,
                    colors: <Color>[Colors.transparent, const Color(0xB3000000)],
                  ),
                ),
              ),
            ),
          ),
        if (discountLabel != null && discountLabel!.isNotEmpty)
          PositionedDirectional(
            top: 12,
            start: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(20)),
              child: Text(discountLabel!, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ),
        PositionedDirectional(
          start: 16,
          end: 16,
          bottom: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
              if (subtitle != null && subtitle!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.92))),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
