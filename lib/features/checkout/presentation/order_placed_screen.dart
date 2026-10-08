import 'package:flutter/material.dart';

import '../../../core/navigation/main_shell.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/button_label.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../orders/presentation/order_tracking_screen.dart';

/// شاشة تأكيد الطلب: رقم الطلب + زر التتبع + العودة للرئيسية.
class OrderPlacedScreen extends StatelessWidget {
  const OrderPlacedScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 96, height: 96, decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), shape: BoxShape.circle), child: const Icon(Icons.check_rounded, size: 52, color: AppColors.success)),
                const SizedBox(height: 20),
                Text(l10n.orderPlaced, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text(l10n.orderPlacedBody, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Text(l10n.orderNumber, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 4),
                      SelectableText(orderId, style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: ButtonLabel(l10n.trackOrder),
                    onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (BuildContext context) => OrderTrackingScreen(orderId: orderId))),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (BuildContext context) => const MainShell()), (Route<void> route) => false), child: ButtonLabel(l10n.backToHome)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
