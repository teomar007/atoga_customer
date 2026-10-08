import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/cart_item.dart';
import '../cart_controller.dart';

/// عنصر السلة مع (+/-) وحذف سريع بالسحب.
class CartItemTile extends ConsumerWidget {
  const CartItemTile({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String lang = Localizations.localeOf(context).languageCode;
    final ThemeData theme = Theme.of(context);

    return Dismissible(
      key: ValueKey<String>(item.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white),
            const SizedBox(width: 6),
            Text(l10n.delete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      onDismissed: (DismissDirection _) => _remove(context, ref, l10n),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            SizedBox(width: 62, height: 62, child: ProductImage(url: item.imageUrl, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.nameFor(lang), maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(Formatters.price(item.price, lang), style: theme.textTheme.titleSmall?.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Formatters.price(item.lineTotal, lang), style: theme.textTheme.titleSmall),
                const SizedBox(height: 6),
                QuantityStepper(
                  compact: true,
                  quantity: item.quantity,
                  onIncrement: () => ref.read(cartControllerProvider.notifier).increment(item.productId),
                  onDecrement: () => ref.read(cartControllerProvider.notifier).decrement(item.productId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _remove(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    ref.read(cartControllerProvider.notifier).remove(item.productId);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final String lang = Localizations.localeOf(context).languageCode;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.itemRemoved(item.nameFor(lang))), action: SnackBarAction(label: l10n.undo, textColor: AppColors.accent, onPressed: () => ref.read(cartControllerProvider.notifier).restore(item))));
  }
}
