import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/product_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/order.dart';
import '../domain/status.dart';
import 'orders_controller.dart';
import 'widgets/status_labels.dart';

/// شاشة تتبع الطلب: خط زمني تفاعلي + بيانات المندوب + الفاتورة.
class OrderTrackingScreen extends ConsumerStatefulWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  bool _cancelling = false;
  StreamSubscription<Order>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startWatch());
  }

  /// بدء التتبع الحي وإمساك الاشتراك لإلغائه في [dispose].
  void _startWatch() {
    if (!mounted) {
      return;
    }
    _subscription = ref.read(ordersControllerProvider.notifier).watch(widget.orderId);
  }

  @override
  void dispose() {
    // إلغاء الاشتراك مباشرةً: قراءة `ref` داخل dispose() ممنوعة في Riverpod.
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Order> async = ref.watch(orderDetailProvider(widget.orderId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackingTitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => ErrorStateView(title: l10n.ordersLoadFailed, message: l10n.noInternetBody, retryLabel: l10n.retry, onRetry: () => ref.invalidate(orderDetailProvider(widget.orderId))),
        data: (Order fetched) {
          // الأولوية للتحديث الحي إن وصل.
          final OrdersState list = ref.watch(ordersControllerProvider);
          final Order order = list.orders.firstWhere((Order o) => o.id == widget.orderId, orElse: () => fetched);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(orderDetailProvider(widget.orderId)),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Expanded(child: Text(order.status.label(l10n), style: Theme.of(context).textTheme.titleMedium)), _StatusBadge(status: order.status)]),
                      const SizedBox(height: 4),
                      Text('${l10n.orderNumber}: ${order.id}', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      const SizedBox(height: 12),
                      if (order.addressLine.isNotEmpty) Text(order.addressLine, style: Theme.of(context).textTheme.bodyMedium),
                      if (order.notes.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('${l10n.notesForCourier}: ${order.notes}', style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                ),
                if (order.hasCourier) ...[
                  const SizedBox(height: 12),
                  _CourierCard(order: order),
                ],
                const SizedBox(height: 16),
                Text(l10n.trackingTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                  child: OrderTimeline(status: order.status),
                ),
                const SizedBox(height: 18),
                Text(l10n.invoice, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...order.items.map((OrderItem item) => _InvoiceRow(item: item, lang: Localizations.localeOf(context).languageCode)),
                _Totals(order: order),
                // الإلغاء متاح في مرحلة الاستلام فقط؛ بمجرد بدء التجهيز
                // (Realtime) يختفي الزر تلقائياً من الشاشة.
                if (order.status.canBeCancelled) ...[
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: Text(l10n.cancelOrder),
                    onPressed: _cancelling ? null : () => _cancel(context, l10n),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _cancel(BuildContext context, AppLocalizations l10n) async {
    if (_cancelling) {
      return;
    }
    final bool? ok = await showDialog<bool>(context: context, builder: (BuildContext context) => AlertDialog(title: Text(l10n.cancelOrder), content: Text(l10n.cancelOrderConfirm), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)), FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.confirm))]));
    if (ok != true || !mounted) {
      return;
    }
    setState(() => _cancelling = true);
    final CancelOrderOutcome outcome = await ref.read(ordersControllerProvider.notifier).cancel(widget.orderId);
    if (!context.mounted) {
      return;
    }
    setState(() => _cancelling = false);
    if (outcome == CancelOrderOutcome.cancelled) {
      ref.invalidate(orderDetailProvider(widget.orderId));
    }
    final String message = switch (outcome) {
      CancelOrderOutcome.cancelled => l10n.orderCancelledToast,
      CancelOrderOutcome.statusChanged => l10n.cancelOrderTooLate,
      CancelOrderOutcome.failed => l10n.somethingWentWrong,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = status == OrderStatus.delivered ? AppColors.success : (status == OrderStatus.cancelled ? Colors.grey : AppColors.primary);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)), child: Text(status.wire, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)));
  }
}

class _CourierCard extends StatelessWidget {
  const _CourierCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.delivery_dining_rounded, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(order.courierName ?? l10n.courierInfo, style: const TextStyle(fontWeight: FontWeight.w700)), Text(order.courierPhone ?? '', style: Theme.of(context).textTheme.bodySmall)])),
          FilledButton.tonalIcon(icon: const Icon(Icons.call_rounded, size: 18), label: Text(l10n.callCourier), onPressed: () => launchUrl(Uri.parse('tel:${order.courierPhone}'))),
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.item, required this.lang});

  final OrderItem item;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 44, height: 44, child: ProductImage(url: item.imageUrl, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.nameFor(lang), maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium), Text('${l10nQty(item.quantity)} × ${Formatters.price(item.price, lang)}', style: Theme.of(context).textTheme.bodySmall)])),
          Text(Formatters.price(item.lineTotal, lang), style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }

  String l10nQty(int quantity) => '× $quantity';
}

class _Totals extends StatelessWidget {
  const _Totals({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String lang = Localizations.localeOf(context).languageCode;
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Row(children: [Expanded(child: Text(l10n.subtotal)), Text(Formatters.price(order.subtotal, lang))]),
          if (order.discount > 0) Padding(padding: const EdgeInsets.only(top: 6), child: Row(children: [Expanded(child: Text(l10n.discount)), Text('-${Formatters.price(order.discount, lang)}', style: const TextStyle(color: AppColors.success))])),
          Padding(padding: const EdgeInsets.only(top: 6), child: Row(children: [Expanded(child: Text(l10n.deliveryFee)), Text(order.deliveryFee == 0 ? l10n.freeDelivery : Formatters.price(order.deliveryFee, lang))])),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
          Row(children: [Expanded(child: Text(l10n.orderTotal, style: theme.textTheme.titleMedium)), Text(Formatters.price(order.total, lang), style: theme.textTheme.titleLarge?.copyWith(color: AppColors.primary))]),
        ],
      ),
    );
  }
}
