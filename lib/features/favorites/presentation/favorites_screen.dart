import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../home/domain/product.dart';
import '../../home/presentation/widgets/product_card.dart';
import 'favorites_provider.dart';

/// نفس مقاييس شبكة الرئيسية (عمودان + التباعدات نفسها) ليبقى الإحساس
/// بصرياً واحداً بين الشاشتين.
const SliverGridDelegateWithFixedCrossAxisCount _productGridDelegate =
    SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 14,
  crossAxisSpacing: 12,
  childAspectRatio: 0.60,
);

/// شاشة المفضلة: منتجات المستخدم المفضّلة على شبكة ثنائية كشاشة الرئيسية.
///
/// الحالة الثلاث (تحميل/خطأ/فارغ) لها فرع صريح، والمنتجات تُجلب دفعة
/// واحدة عبر [favoriteProductsProvider] بدل طلب لكل منتج.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Set<String>> favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoritesTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: favorites.when(
        loading: () => _shimmerGrid(),
        error: (Object error, StackTrace stack) => ErrorStateView(
          title: l10n.dataLoadFailed,
          message: l10n.noInternetBody,
          retryLabel: l10n.retry,
          isOffline: true,
          onRetry: () => ref.read(favoritesProvider.notifier).fetch(),
        ),
        data: (Set<String> ids) => ids.isEmpty
            ? EmptyStateView(
                icon: Icons.favorite_border_rounded,
                title: l10n.favoritesEmpty,
                message: l10n.favoritesEmptyHint,
                compact: true,
              )
            : const _FavoriteProducts(),
      ),
    );
  }

  Widget _shimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: _productGridDelegate,
      itemCount: 4,
      itemBuilder: (BuildContext context, int index) => ShimmerLoading.productCard(),
    );
  }
}

/// شبكة المنتجات: تحميل/خطأ/فارغ لها فروع، مع سحب للتحديث.
class _FavoriteProducts extends ConsumerWidget {
  const _FavoriteProducts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Product>> async = ref.watch(favoriteProductsProvider);

    return async.when(
      loading: () => GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: _productGridDelegate,
        itemCount: 4,
        itemBuilder: (BuildContext context, int index) => ShimmerLoading.productCard(),
      ),
      error: (Object error, StackTrace stack) => ErrorStateView(
        title: l10n.dataLoadFailed,
        message: l10n.noInternetBody,
        retryLabel: l10n.retry,
        isOffline: true,
        onRetry: () => ref.invalidate(favoriteProductsProvider),
      ),
      data: (List<Product> products) {
        if (products.isEmpty) {
          return EmptyStateView(
            icon: Icons.search_off_rounded,
            title: l10n.favoritesEmpty,
            message: l10n.favoritesEmptyHint,
            compact: true,
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(favoriteProductsProvider);
            await ref.read(favoriteProductsProvider.future);
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: _productGridDelegate,
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) =>
                ProductCard(product: products[index]),
          ),
        );
      },
    );
  }
}
