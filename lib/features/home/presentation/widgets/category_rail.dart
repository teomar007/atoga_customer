import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/product_category.dart';
import '../home_controller.dart';

/// شريط التصنيفات: أيقونات دائرية قابلة للتمرير أفقياً.
///
/// أول عنصر زر ثابت «الكل» يعيد `selectedCategoryId` إلى `null`
/// فيُعرض كل المنتجات؛ ويكون محدداً تلقائياً عند فتح التطبيق.
class CategoryRail extends ConsumerWidget {
  const CategoryRail({super.key, required this.categories, required this.selectedId});

  final List<ProductCategory> categories;
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final bool isAll = index == 0;
          final ProductCategory? category = isAll ? null : categories[index - 1];
          // زر «الكل» يعيد التحديد إلى null فيصفّر الفلتر.
          final String? id = category?.id;
          final bool selected = isAll ? selectedId == null : selectedId == id;
          final String label = isAll ? AppLocalizations.of(context).allCategories : labelFor(context, category!);
          return InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () => ref.read(homeControllerProvider.notifier).selectCategory(id),
            child: SizedBox(
              width: 72,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: selected ? AppColors.primary : AppColors.surface, shape: BoxShape.circle, border: Border.all(color: selected ? AppColors.primary : AppColors.divider)),
                    child: isAll ? Icon(Icons.grid_view_rounded, color: selected ? Colors.white : AppColors.textSecondary, size: 24) : _imageOrIcon(context, category!, selected),
                  ),
                  const SizedBox(height: 6),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, color: selected ? AppColors.primary : AppColors.textSecondary, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// صورة التصنيف المرفوعة على Supabase Storage، أو أيقونة Material افتراضية.
  ///
  /// تسقط إلى أيقونة [iconFor] عند فشل تحميل الصورة حتى لا يختفي
  /// التصنيف بسبب رابط منتهي أو صورة محذوفة من التخزين.
  static Widget _imageOrIcon(BuildContext context, ProductCategory category, bool selected) {
    final Color color = selected ? Colors.white : AppColors.textSecondary;
    final String url = (category.iconUrl ?? '').trim();
    if (url.isEmpty) {
      return Icon(iconFor(category.iconName), color: color, size: 24);
    }
    return ClipOval(
      child: Image.network(
        url,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) => Icon(iconFor(category.iconName), color: color, size: 24),
      ),
    );
  }

  /// تسمية التصنيف حسب اللغة الحالية.
  ///
  /// المعرّفات ثابتة ودلالية (`drinks`، `dairy`…) فتُترجم من ملفات `l10n`
  /// كباقي نصوص الواجهة. تصنيف غير معروف (أضافه المشرف لاحقاً) يعود إلى
  /// اسمه ثنائي اللغة عبر [ProductCategory.getLocalizedName].
  static String labelFor(BuildContext context, ProductCategory category) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? known = switch (category.id) {
      'all' => l10n.allCategories,
      'canned' => l10n.categoryCanned,
      'drinks' => l10n.categoryDrinks,
      'dairy' => l10n.categoryDairy,
      'grains' => l10n.categoryGrains,
      'snacks' => l10n.categorySnacks,
      'cleaning' => l10n.categoryCleaning,
      _ => null,
    };
    if (known != null) {
      return known;
    }
    return category.getLocalizedName(Localizations.localeOf(context).languageCode);
  }

  /// خريطة الأيقونة: يُخزَّن الاسم في قاعدة البيانات ويرسم هنا.
  static IconData iconFor(String? name) {
    switch (name) {
      case 'lunch_dining':
        return Icons.lunch_dining_rounded;
      case 'local_drink':
        return Icons.local_drink_rounded;
      case 'egg_alt':
        return Icons.egg_alt_rounded;
      case 'grain':
        return Icons.grain_rounded;
      case 'cookie':
        return Icons.cookie_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'bakery_dining':
        return Icons.bakery_dining_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }
}
