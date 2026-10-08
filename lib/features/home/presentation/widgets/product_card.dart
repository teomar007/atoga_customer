import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/button_label.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../cart/presentation/cart_controller.dart';
import '../../../favorites/presentation/favorites_provider.dart';
import '../../domain/product.dart';
import '../store_status_provider.dart';

/// بطاقة المنتج.
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int quantity = ref.watch(cartControllerProvider.select((CartState s) => s.quantityOf(product.id)));
    // عند إغلاق المتجر تُعطَّل الإضافة وعدادات الكمية.
    final bool canOrder = ref.watch(storeStatusProvider) == StoreStatus.open;
    final ThemeData theme = Theme.of(context);
    final String lang = Localizations.localeOf(context).languageCode;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _addToCart(context, ref, l10n),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: ProductImage(url: product.imageUrl)),
                    if (product.discountPercentage > 0)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _Badge(label: '-${product.discountPercentage}%'),
                      ),
                    Positioned(top: 0, right: 0, child: _FavoriteButton(productId: product.id)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(product.nameFor(lang), maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(height: 1.25)),
              if (product.unit != null && product.unit!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(_unitLabel(l10n, product.unit!), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(Formatters.price(product.price, lang), style: theme.textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
                  // السعر القديم بجانب السعر الحالي: أصغر ومشطوب ورمادي.
                  if (product.discountPercentage > 0) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        Formatters.price(product.oldPrice!, lang),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(decoration: TextDecoration.lineThrough, color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 34,
                child: quantity == 0
                    ? FilledButton(
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(34), padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: (product.inStock && canOrder) ? () => _addToCart(context, ref, l10n) : null,
                        child: ButtonLabel(l10n.addToCart, style: const TextStyle(fontSize: 12.5)),
                      )
                    : Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: QuantityStepper(
                          compact: true,
                          quantity: quantity,
                          enabled: canOrder,
                          onIncrement: () => ref.read(cartControllerProvider.notifier).increment(product.id),
                          onDecrement: () => ref.read(cartControllerProvider.notifier).decrement(product.id),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    if (!product.inStock) {
      return;
    }
    // المتجر مغلق: لا إضافة — رسالة واضحة بدل رسالة النجاح القديمة.
    if (ref.read(storeStatusProvider) == StoreStatus.closed) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.storeClosedAddToCart)));
      return;
    }
    ref.read(cartControllerProvider.notifier).addProduct(product);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final String lang = Localizations.localeOf(context).languageCode;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.nameFor(lang)} - ${l10n.addedToCart}'), duration: const Duration(milliseconds: 900)));
  }
}

/// قلب المفضلة فوق صورة المنتج: تبديل فوري (Optimistic) + رسالة للزائر.
class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // `select` على الحالة: لا يُعيد بناء القلب إلا عند انقلاب القيمة.
    final bool favorite = ref.watch(
      favoritesProvider.select((AsyncValue<Set<String>> state) => (state.valueOrNull ?? const <String>{}).contains(productId)),
    );

    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      tooltip: favorite ? l10n.favoriteRemove : l10n.favoriteAdd,
      onPressed: () => _toggle(context, ref, l10n),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), shape: BoxShape.circle),
        child: Icon(
          favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 17,
          color: favorite ? AppColors.danger : Colors.white,
        ),
      ),
    );
  }

  void _toggle(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    if (!ref.read(isSignedInProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.loginRequiredTitle)));
      return;
    }
    ref.read(favoritesProvider.notifier).toggle(productId);
  }
}

/// وحدة البيع: مفردات مغلقة مخزَّنة بالعربية في قاعدة البيانات، فنترجمها
/// من `l10n`؛ أي وحدة غير معروفة تبقى كما هي (لا نخسر بيانата).
String _unitLabel(AppLocalizations l10n, String unit) {
  return switch (unit.trim()) {
    'علبة' => l10n.unitCan,
    'قنينة' => l10n.unitBottle,
    'حزمة' => l10n.unitPack,
    'عبوة' => l10n.unitJar,
    'زجاجة' => l10n.unitFlask,
    'كيس' => l10n.unitBag,
    'قطعة' => l10n.unitPiece,
    _ => unit,
  };
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: <Color>[Color(0xFFD32F2F), Color(0xFFFF8A65)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10),
        boxShadow: <BoxShadow>[BoxShadow(color: const Color(0xCCE53935), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
    );
  }
}
