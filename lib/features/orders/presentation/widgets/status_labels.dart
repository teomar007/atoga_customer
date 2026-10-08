import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/status.dart';

/// ترجمة حالة الطلب ورسالتها إلى `l10n` (تستخدمها كل الشاشات).
extension OrderStatusL10n on OrderStatus {
  String label(AppLocalizations l10n) {
    return switch (this) {
      OrderStatus.received => l10n.statusReceived,
      OrderStatus.preparing => l10n.statusPreparing,
      OrderStatus.onTheWay => l10n.statusOnTheWay,
      OrderStatus.delivered => l10n.statusDelivered,
      OrderStatus.cancelled => l10n.statusCancelled,
    };
  }

  String description(AppLocalizations l10n) {
    return switch (this) {
      OrderStatus.received => l10n.statusReceivedDesc,
      OrderStatus.preparing => l10n.statusPreparingDesc,
      OrderStatus.onTheWay => l10n.statusOnTheWayDesc,
      OrderStatus.delivered => l10n.statusDeliveredDesc,
      OrderStatus.cancelled => l10n.statusCancelledDesc,
    };
  }
}

/// الخط الزمني التفاعلي لحالة الطلب (Sprint 5).
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int current = status.step;
    final List<OrderStatus> steps = <OrderStatus>[OrderStatus.received, OrderStatus.preparing, OrderStatus.onTheWay, OrderStatus.delivered];

    if (status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
        child: Row(children: [const Icon(Icons.cancel_outlined, color: Colors.red), const SizedBox(width: 10), Expanded(child: Text(status.description(l10n), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)))]),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          _TimelineStep(status: steps[i], index: i, current: current, isLast: i == steps.length - 1),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.status, required this.index, required this.current, required this.isLast});

  final OrderStatus status;
  final int index;
  final int current;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool done = index <= current;
    final bool active = index == current;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 26,
                height: 26,
                decoration: BoxDecoration(color: done ? Colors.green : Colors.white, shape: BoxShape.circle, border: Border.all(color: done ? Colors.green : Colors.grey.shade400, width: 2)),
                child: done ? Icon(Icons.check_rounded, size: 15, color: active ? Colors.white : Colors.green) : null,
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: index < current ? Colors.green : Colors.grey.shade300)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(status.label(l10n), style: TextStyle(fontWeight: active ? FontWeight.w800 : FontWeight.w600, color: done ? Colors.black87 : Colors.grey)),
                  const SizedBox(height: 2),
                  Text(status.description(l10n), style: TextStyle(fontSize: 12, color: done ? Colors.grey.shade700 : Colors.grey.shade400)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
