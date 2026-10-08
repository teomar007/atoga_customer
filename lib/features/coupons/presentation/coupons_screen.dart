import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/coupon_offer.dart';
import 'coupons_controller.dart';
import 'widgets/coupon_card.dart';

/// شاشة الكوبونات: تعرض الكوبونات الفعالة الخاصة بالمستخدم أو العامة،
/// مع تحميل/خطأ/فارغ وسحب للتحديث.
class CouponsScreen extends ConsumerWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<CouponOffer>> state = ref.watch(couponsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.couponsTitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: state.when(
        loading: () => _shimmerList(),
        error: (Object error, StackTrace stack) => ErrorStateView(
          title: l10n.dataLoadFailed,
          message: l10n.noInternetBody,
          retryLabel: l10n.retry,
          isOffline: true,
          onRetry: () => ref.read(couponsProvider.notifier).refresh(),
        ),
        data: (List<CouponOffer> coupons) => _content(context, ref, l10n, coupons),
      ),
    );
  }

  /// هيكل التحميل: بطاقات وهمية بنفس أبعاد البطاقة الحقيقية.
  Widget _shimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) => ShimmerLoading.listTile(),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, AppLocalizations l10n, List<CouponOffer> coupons) {
    if (coupons.isEmpty) {
      return EmptyStateView(
        icon: Icons.local_offer_outlined,
        title: l10n.couponsEmpty,
        message: l10n.couponsEmptyHint,
        compact: true,
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(couponsProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: coupons.length,
        itemBuilder: (BuildContext context, int index) => CouponCard(coupon: coupons[index]),
      ),
    );
  }
}
