import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/button_label.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../home/domain/product.dart';
import '../domain/order.dart';
import '../domain/status.dart';
import 'order_tracking_screen.dart';
import 'orders_controller.dart';
import 'widgets/status_labels.dart';

/// سجل الطلبات: طلبات جارية + طلبات سابقة، مع إعادة الطلب.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(ordersControllerProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final OrdersState state = ref.watch(ordersControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersTitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: _body(context, l10n, state),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n, OrdersState state) {
    if (state.loading && state.orders.isEmpty) {
      return ListView.builder(itemCount: 4, itemBuilder: (BuildContext context, int index) => ShimmerLoading.listTile());
    }
    if (state.error != null && state.orders.isEmpty) {
      return ErrorStateView(title: l10n.ordersLoadFailed, message: l10n.noInternetBody, retryLabel: l10n.retry, onRetry: () => ref.read(ordersControllerProvider.notifier).load(), isOffline: true);
    }
    if (state.isEmpty) {
      return EmptyStateView(icon: Icons.receipt_long_outlined, title: l10n.noOrders, message: l10n.noOrdersHint, compact: true);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(ordersControllerProvider.notifier).load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (state.active.isNotEmpty) ...[
            _Title(text: l10n.activeOrders),
            ...state.active.map((Order o) => _OrderCard(order: o, live: true)),
            const SizedBox(height: 18),
          ],
          if (state.past.isNotEmpty) ...[
            _Title(text: l10n.pastOrders),
            ...state.past.map((Order o) => _OrderCard(order: o, live: false)),
          ],
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(text, style: Theme.of(context).textTheme.titleMedium));
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order, required this.live});

  final Order order;
  final bool live;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String lang = Localizations.localeOf(context).languageCode;
    final ThemeData theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('${l10n.orderNumber}: ${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}', style: theme.textTheme.titleSmall)),
              _StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(Formatters.dateTime(order.createdAt, lang), style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Text('${l10n.cartItemsLabel(order.totalQuantity)} • ${Formatters.price(order.total, lang)}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          if (live && order.hasCourier) ...[
            const SizedBox(height: 10),
            _CourierRow(name: order.courierName ?? l10n.courierInfo, phone: order.courierPhone!),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (live)
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => OrderTrackingScreen(orderId: order.id))),
                    child: ButtonLabel(l10n.trackOrder),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    onPressed: () => _reorder(context, ref, l10n),
                    label: ButtonLabel(l10n.reorder),
                  ),
                ),
              if (!live) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => OrderTrackingScreen(orderId: order.id))),
                    child: ButtonLabel(l10n.invoice),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// "إعادة الطلب": يعبّئ السلة بنفس العناصر فوراً.
  Future<void> _reorder(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final CartController cart = ref.read(cartControllerProvider.notifier);
    for (final OrderItem item in order.items) {
      await cart.addProduct(Product(id: item.productId, name: item.name, nameFr: item.nameFr, price: item.price, imageUrl: item.imageUrl, unit: item.unit), quantity: item.quantity);
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.reordered)));
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color color = status.isActive ? AppColors.primary : Colors.grey.shade600;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text(status.label(l10n), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)));
  }
}

class _CourierRow extends StatelessWidget {
  const _CourierRow({required this.name, required this.phone});

  final String name;
  final String phone;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.delivery_dining_rounded, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text('${l10n.courierInfo}: $name', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34), padding: const EdgeInsets.symmetric(horizontal: 10)),
            icon: const Icon(Icons.call_rounded, size: 15),
            label: Text(l10n.callCourier, style: const TextStyle(fontSize: 12.5)),
            onPressed: () => launchUrl(Uri.parse('tel:$phone')),
          ),
        ],
      ),
    );
  }
}
