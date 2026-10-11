import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../widgets/offline_banner.dart';
import '../../features/cart/presentation/cart_controller.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';
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
          const _FrozenBanner(),
          Expanded(child: IndexedStack(index: index, children: pages)),
        ],
      ),
      bottomNavigationBar: _CustomerNavBar(
        selectedIndex: index,
        onSelected: (int value) => ref.read(mainTabIndexProvider.notifier).select(value),
        items: <_NavItem>[
          _NavItem(label: l10n.homeTab, icon: const Icon(Icons.storefront_outlined), selectedIcon: const Icon(Icons.storefront_rounded, color: AppColors.primary)),
          _NavItem(label: l10n.cartTitle, icon: _NavIcon(icon: Icons.shopping_cart_outlined, count: cartCount), selectedIcon: _NavIcon(icon: Icons.shopping_cart_outlined, count: cartCount, selected: true)),
          _NavItem(label: l10n.walletTitle, icon: const Icon(Icons.account_balance_wallet_outlined), selectedIcon: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary)),
          _NavItem(label: l10n.ordersTitle, icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long_rounded, color: AppColors.primary)),
          _NavItem(label: l10n.couponsTitle, icon: _NavIcon(icon: Icons.local_offer_outlined, count: couponsCount), selectedIcon: _NavIcon(icon: Icons.local_offer_rounded, count: couponsCount, selected: true)),
          _NavItem(label: l10n.profileTitle, icon: const Icon(Icons.person_outline_rounded), selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.label, required this.icon, required this.selectedIcon});
  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

/// شريط تنقل سفلي أفقي قابل للتمرير: كل تسمية في سطر واحد كامل بلا التفاف.
class _CustomerNavBar extends StatefulWidget {
  const _CustomerNavBar({required this.selectedIndex, required this.onSelected, required this.items});

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<_NavItem> items;

  @override
  State<_CustomerNavBar> createState() => _CustomerNavBarState();
}

class _CustomerNavBarState extends State<_CustomerNavBar> {
  final Map<int, GlobalKey> _keys = <int, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _scrollToSelected();
  }

  @override
  void didUpdateWidget(covariant _CustomerNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? context = _keys[widget.selectedIndex]?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context, alignment: 0.5, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 6,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: widget.items.length,
            itemBuilder: (BuildContext context, int index) {
              final _NavItem item = widget.items[index];
              final bool selected = index == widget.selectedIndex;
              final Color color = selected ? AppColors.primary : const Color(0xFF6B7280);
              return InkWell(
                key: _keys.putIfAbsent(index, () => GlobalKey()),
                onTap: () => widget.onSelected(index),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: selected ? item.selectedIcon : item.icon,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: TextStyle(fontSize: 11.5, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: color),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// شريط يظهر عند تجميد حساب الزبون (دخول مسموح، شراء ممنوع).
class _FrozenBanner extends ConsumerWidget {
  const _FrozenBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool frozen = ref.watch(isFrozenProvider);
    if (!frozen) {
      return const SizedBox.shrink();
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? reason = ref.watch(frozenReasonProvider);
    return Material(
      color: AppColors.danger.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.block_rounded, color: AppColors.danger, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.accountFrozenTitle, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(reason ?? l10n.accountFrozenBlocked, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
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
