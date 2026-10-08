import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/button_label.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/navigation/main_tab_provider.dart';
import '../../checkout/presentation/checkout_screen.dart';
import '../domain/cart_item.dart';
import 'cart_controller.dart';
import 'widgets/cart_item_tile.dart';

/// شاشة السلة: عناصر + كوبون + ملخص مالي + زر متابعة ثابت أسفل الشاشة.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _coupon = TextEditingController();

  @override
  void dispose() {
    _coupon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String lang = Localizations.localeOf(context).languageCode;
    final CartState cart = ref.watch(cartControllerProvider);

    if (cart.isEmpty) {
      return Scaffold(
      appBar: AppBar(title: Text(l10n.cartTitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
        body: EmptyStateView(
          icon: Icons.shopping_cart_outlined,
          title: l10n.cartEmpty,
          message: l10n.cartEmptyHint,
          actionLabel: l10n.startShopping,
          // «ابدأ التسوق»: توجيه إلى تبويب الرئيسية. السلة تبويب داخل
          // MainShell وليست صفحة مستقلة، فـ pop() وحده كان يفتح فراغاً؛
          // نغيّر التبويب ثم نغلق أي نسخة سلة مفتوحة فوق الهيكل إن وُجدت.
          onAction: () {
            ref.read(mainTabIndexProvider.notifier).select(0);
            final NavigatorState navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            }
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.cartTitle} (${l10n.cartItemsLabel(cart.totalQuantity)})', maxLines: 1, overflow: TextOverflow.ellipsis), actions: [IconButton(tooltip: l10n.delete, icon: const Icon(Icons.delete_sweep_outlined), onPressed: () => _confirmClear(l10n))]),
      // جسم السفلي مقيد بارتفاع الشاشة (Scaffold body)، فالـ ListView.builder
      // هنا محصور تلقائياً — لا حاجة لـ shrinkWrap، ولكل حالة فرع رسم صريح.
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: cart.items.length + 2,
        itemBuilder: (BuildContext context, int index) {
          if (index < cart.items.length) {
            final CartItem item = cart.items[index];
            return CartItemTile(item: item);
          }
          if (index == cart.items.length) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                _CouponField(controller: _coupon, cart: cart),
                const SizedBox(height: 14),
              ],
            );
          }
          return _TotalsCard(cart: cart, lang: lang);
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => const CheckoutScreen())),
            child: ButtonLabel('${l10n.proceedToCheckout} • ${Formatters.price(cart.total, lang)}'),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClear(AppLocalizations l10n) async {
    final bool? ok = await showDialog<bool>(context: context, builder: (BuildContext context) => AlertDialog(title: Text(l10n.delete), content: Text(l10n.deleteAddressConfirm), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)), FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete))]));
    if (ok == true) {
      await ref.read(cartControllerProvider.notifier).clear();
    }
  }
}

class _CouponField extends ConsumerWidget {
  const _CouponField({required this.controller, required this.cart});

  final TextEditingController controller;
  final CartState cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String lang = Localizations.localeOf(context).languageCode;
    final bool applied = cart.coupon != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.coupon, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (applied)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.success.withValues(alpha: 0.35))),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('${cart.coupon!.code} - ${l10n.couponDiscountValue(Formatters.plainNumber(cart.discount, lang))}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700))),
                TextButton(onPressed: () => ref.read(cartControllerProvider.notifier).clearCoupon(), child: Text(l10n.couponRemove)),
              ],
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(hintText: l10n.couponHint, errorText: cart.couponError ? l10n.couponInvalid : null, isDense: true),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                // عرض محدّد إجباري: بدونه يفرض outlinedButtonTheme عرضاً
                // لا نهائياً داخل Row فيفشل تخطيط القائمة بالكامل.
                width: 92,
                height: 48,
                child: OutlinedButton(
                  onPressed: () async {
                    final bool ok = await ref.read(cartControllerProvider.notifier).applyLocalCoupon(controller.text);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.couponInvalid)));
                    }
                  },
                  child: ButtonLabel(l10n.apply),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.cart, required this.lang});

  final CartState cart;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool free = cart.deliveryFee == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          _row(theme, l10n.subtotal, Formatters.price(cart.subtotal, lang)),
          const SizedBox(height: 8),
          if (cart.discount > 0) ...[
            _row(theme, l10n.discount, '-${Formatters.price(cart.discount, lang)}', color: AppColors.success),
            const SizedBox(height: 8),
          ],
          _row(theme, l10n.deliveryFee, free ? l10n.freeDelivery : Formatters.price(cart.deliveryFee, lang), color: free ? AppColors.success : null),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
          Row(
            children: [
              Expanded(child: Text(l10n.total, style: theme.textTheme.titleMedium)),
              Text(Formatters.price(cart.total, lang), style: theme.textTheme.titleLarge?.copyWith(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value, {Color? color}) {
    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
