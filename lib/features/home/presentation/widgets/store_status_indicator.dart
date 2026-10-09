import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/auto_marquee_text.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../store_status_provider.dart';

/// مؤشر حالة المتجر في الشريط العلوي: LED دائري يومض (أخضر = مفتوح،
/// أحمر = مغلق) مع نص توضيحي واضح.
class StoreStatusIndicator extends ConsumerStatefulWidget {
  const StoreStatusIndicator({super.key});

  @override
  ConsumerState<StoreStatusIndicator> createState() => _StoreStatusIndicatorState();
}

class _StoreStatusIndicatorState extends ConsumerState<StoreStatusIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final StoreStatus status = ref.watch(storeStatusProvider);
    final bool open = status == StoreStatus.open;
    final Color ledColor = open ? AppColors.success : AppColors.danger;
    final String label = open ? l10n.storeOpenStatus : l10n.storeClosedStatus;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ضوء يومض بسلاسة (Fade) ليعوّل أن الحالة حيّة.
        FadeTransition(
          opacity: Tween<double>(begin: 0.25, end: 1).animate(_blink),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: ledColor, shape: BoxShape.circle, boxShadow: <BoxShadow>[BoxShadow(color: ledColor.withValues(alpha: 0.6), blurRadius: 6)]),
          ),
        ),
        const SizedBox(width: 8),
        // نص متحرك عند تجاوز المساحة بدل الاقتطاع.
        Expanded(
          child: AutoMarqueeText(
            text: label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}
