import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../widgets/offline_banner.dart';
import '../../features/cart/presentation/cart_controller.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/coupons/presentation/coupons_controller.dart';
import '../../features/coupons/presentation/coupons_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/wallet/presentation/wallet_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import 'main_tab_provider.dart';

/// الهيكل الرئيسي: 6 تبويبات + شريط انقطاع الاتصال.
/// الترتيب: الرئيسية ← السلة ← المحفظة ← طلباتي ← الكوبونات ← حسابي.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int cartCount = ref.watch(cartControllerProvider.select((CartState s) => s.totalQuantity));
    // عدد الكوبونات يتحدّث تلقائياً مع couponsProvider (0 ← بلا شارة).
    final int couponsCount = ref.watch(availableCouponsCountProvider);
    // فهرس التبويب من المزوّد: يمكن لأي شاشة (السلة الفارغة مثلاً)
    // توجيه المستخدم إلى الرئيسية عبر MainTabIndexController.
    final int index = ref.watch(mainTabIndexProvider);
    final List<Widget> pages = <Widget>[const HomeScreen(), const CartScreen(), const WalletScreen(), const OrdersScreen(), const CouponsScreen(), const ProfileScreen()];

    return Scaffold(
      body: Column(
        children: [
          OfflineBanner(message: l10n.noInternet),
          Expanded(child: IndexedStack(index: index, children: pages)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (int value) => ref.read(mainTabIndexProvider.notifier).select(value),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.storefront_outlined), selectedIcon: const Icon(Icons.storefront_rounded, color: AppColors.primary), label: l10n.homeTab),
          NavigationDestination(icon: _NavIcon(icon: Icons.shopping_cart_outlined, count: cartCount), selectedIcon: _NavIcon(icon: Icons.shopping_cart_outlined, count: cartCount, selected: true), label: l10n.cartTitle),
          NavigationDestination(icon: const Icon(Icons.account_balance_wallet_outlined), selectedIcon: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary), label: l10n.walletTitle),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long_rounded, color: AppColors.primary), label: l10n.ordersTitle),
          NavigationDestination(icon: _NavIcon(icon: Icons.local_offer_outlined, count: couponsCount), selectedIcon: _NavIcon(icon: Icons.local_offer_rounded, count: couponsCount, selected: true), label: l10n.couponsTitle),
          NavigationDestination(icon: const Icon(Icons.person_outline_rounded), selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primary), label: l10n.profileTitle),
        ],
      ),
    );
  }
}

/// أيقونة تبويب مع عدّاد حي (السلة والكوبونات).
class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.count, this.selected = false});

  final IconData icon;
  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? AppColors.primary : const Color(0xFF6B7280);
    // الشارة مخفية تماماً عندما يكون العدد 0.
    return Badge(
      isLabelVisible: count > 0,
      backgroundColor: AppColors.accent,
      textColor: AppColors.textPrimary,
      label: Text('$count'),
      child: Icon(icon, color: color),
    );
  }
}
