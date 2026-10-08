import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../favorites/presentation/favorites_screen.dart';
import 'home_controller.dart';
import 'widgets/category_rail.dart';
import 'widgets/product_card.dart';
import 'widgets/promo_carousel.dart';
import 'widgets/store_status_indicator.dart';

/// الصفحة الرئيسية: بحث + عروض + تصنيفات + شبكة منتجات (عمودان).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 320) {
      ref.read(homeControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final HomeState state = ref.watch(homeControllerProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _TopBar(search: _search, onChanged: (String v) => ref.read(homeControllerProvider.notifier).onSearchChanged(v), onClear: () { _search.clear(); ref.read(homeControllerProvider.notifier).clearSearch(); })),
              if (state.loading && state.banners.isEmpty)
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), child: ShimmerLoading.box(height: 140, borderRadius: BorderRadius.circular(16))))
              else if (state.banners.isNotEmpty)
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 4, bottom: 18), child: PromoCarousel(banners: state.banners))),
              // شيمر التصنيفات مشروط بالتحميل: بعد انتهاء التحميل تختفي
              // المربعات ويظهر المسار، وإن لم توجد تصنيفات تُخفى القسم كاملاً
              // بدل شيمر لا نهائي تحت عنوان يتيم.
              if (state.categories.isNotEmpty || state.loading) ...[
                SliverToBoxAdapter(child: _SectionTitle(title: l10n.categoriesTitle)),
                SliverToBoxAdapter(child: state.categories.isNotEmpty ? CategoryRail(categories: state.categories, selectedId: state.selectedCategoryId) : ShimmerLoading.box(height: 90, borderRadius: BorderRadius.circular(16))),
              ],
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 10), child: _SectionTitle(title: l10n.productsTitle, trailing: state.isSearching ? l10n.searchNoResult : null))),
              if (state.loading && state.products.isEmpty)
                SliverToBoxAdapter(child: ShimmerLoading.productGrid(columns: 2, count: 6))
              else if (state.error != null && state.products.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: ErrorStateView(title: l10n.productsLoadFailed, message: l10n.noInternetBody, retryLabel: l10n.retry, onRetry: () => ref.read(homeControllerProvider.notifier).refresh(), isOffline: true))
              else if (state.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: EmptyStateView(icon: Icons.search_off_rounded, title: state.isSearching ? l10n.searchNoResult : l10n.noProducts, message: state.isSearching ? l10n.searchNoResultHint : l10n.noProductsHint, compact: true))
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 12, childAspectRatio: 0.60),
                    delegate: SliverChildBuilderDelegate((BuildContext context, int index) => ProductCard(product: state.products[index]), childCount: state.products.length),
                  ),
                ),
              if (state.loadingMore)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4)))))
              else if (state.hasMore)
                const SliverToBoxAdapter(child: SizedBox(height: 8))
              else if (!state.loading && state.products.isNotEmpty)
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(vertical: 18), child: Center(child: Text(l10n.done, style: Theme.of(context).textTheme.bodySmall))))
            ],
          ),
        ),
      ),
    );
  }
}

/// الشريط العلوي: شعار + بحث + السلة بعداد حي.
class _TopBar extends ConsumerWidget {
  const _TopBar({required this.search, required this.onChanged, required this.onClear});

  final TextEditingController search;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int count = ref.watch(cartControllerProvider.select((CartState s) => s.totalQuantity));

    // شريط علوي بلون المتجر (تدرّج أحمر) بدل الأبيض — الهوية من أول نظرة.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: <Color>[AppColors.primary, AppColors.primaryDark], begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // اللوجو الأبيض بحجم واضح فوق الأحمر.
              SizedBox(width: 48, height: 48, child: Image.asset('assets/images/atoga_logo_white.png', fit: BoxFit.contain)),
              const SizedBox(width: 10),
              // حالة المتجر (مفتوح/مغلق) بدل اسم المتجر في الشريط.
              const Expanded(child: StoreStatusIndicator()),
              _FavoritesButton(tooltip: l10n.favoritesTitle),
              _CartButton(count: count, badgeLabel: l10n.cartBadge(count)),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: search,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: search.text.isEmpty
                  ? null
                  : IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: onClear),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

/// دخول إلى شاشة المفضلة من الشريط العلوي (بجوار السلة).
class _FavoritesButton extends StatelessWidget {
  const _FavoritesButton({required this.tooltip});

  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (BuildContext context) => const FavoritesScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: const Icon(Icons.favorite_outline_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.count, required this.badgeLabel});

  final int count;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: badgeLabel,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => const CartScreen())),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Badge(
            isLabelVisible: count > 0,
            backgroundColor: AppColors.accent,
            textColor: AppColors.textPrimary,
            label: Text('$count'),
            child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          if (trailing != null) Text(trailing!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
