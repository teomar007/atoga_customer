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
  /// يجب أن تطابق أسماء `kCategoryIcons` في تطبيق المدير.
  static IconData iconFor(String? name) => _icons[name] ?? Icons.grid_view_rounded;

  static const Map<String, IconData> _icons = <String, IconData>{
    // تسوّق ومتاجر
    'shopping_basket': Icons.shopping_basket,
    'shopping_cart': Icons.shopping_cart,
    'shopping_bag': Icons.shopping_bag,
    'storefront': Icons.storefront,
    'store': Icons.store,
    'local_grocery_store': Icons.local_grocery_store,
    'local_convenience_store': Icons.local_convenience_store,
    'local_mall': Icons.local_mall,
    // مطاعم ووجبات
    'restaurant': Icons.restaurant,
    'restaurant_menu': Icons.restaurant_menu,
    'local_dining': Icons.local_dining,
    'lunch_dining': Icons.lunch_dining,
    'dinner_dining': Icons.dinner_dining,
    'breakfast_dining': Icons.breakfast_dining,
    'brunch_dining': Icons.brunch_dining,
    'fastfood': Icons.fastfood,
    'local_pizza': Icons.local_pizza,
    'takeout_dining': Icons.takeout_dining,
    'room_service': Icons.room_service,
    // لحوم وأسماك
    'kebab_dining': Icons.kebab_dining,
    'outdoor_grill': Icons.outdoor_grill,
    'set_meal': Icons.set_meal,
    // نشويات
    'ramen_dining': Icons.ramen_dining,
    'rice_bowl': Icons.rice_bowl,
    'soup_kitchen': Icons.soup_kitchen,
    'grain': Icons.grain,
    // مخبوزات وحلويات
    'bakery_dining': Icons.bakery_dining,
    'cake': Icons.cake,
    'icecream': Icons.icecream,
    'cookie': Icons.cookie,
    // خضار وفواكه وفلاحة
    'grass': Icons.grass,
    'agriculture': Icons.agriculture,
    'local_florist': Icons.local_florist,
    'eco': Icons.eco,
    'park': Icons.park,
    'nature': Icons.nature,
    'filter_vintage': Icons.filter_vintage,
    // ألبان وبيض
    'egg': Icons.egg,
    'egg_alt': Icons.egg_alt,
    // مشروبات
    'local_drink': Icons.local_drink,
    'local_cafe': Icons.local_cafe,
    'coffee': Icons.coffee,
    'coffee_maker': Icons.coffee_maker,
    'emoji_food_beverage': Icons.emoji_food_beverage,
    'local_bar': Icons.local_bar,
    'sports_bar': Icons.sports_bar,
    'liquor': Icons.liquor,
    'wine_bar': Icons.wine_bar,
    'water_drop': Icons.water_drop,
    'water': Icons.water,
    'ac_unit': Icons.ac_unit,
    // مطبخ وأدوات
    'kitchen': Icons.kitchen,
    'blender': Icons.blender,
    'microwave': Icons.microwave,
    'countertops': Icons.countertops,
    // منظفات
    'cleaning_services': Icons.cleaning_services,
    'cleaning': Icons.cleaning_services,
    'soap': Icons.soap,
    'local_laundry_service': Icons.local_laundry_service,
    'dishwasher': Icons.wash,
    'dry_cleaning': Icons.dry_cleaning,
    'wash': Icons.wash,
    'sanitizer': Icons.sanitizer,
    'recycle': Icons.loop,
    // أطفال وصحة وعناية
    'child_friendly': Icons.child_friendly,
    'child_care': Icons.child_care,
    'face': Icons.face,
    'spa': Icons.spa,
    'health_and_safety': Icons.health_and_safety,
    'medical_services': Icons.medical_services,
    'medication': Icons.medication,
    'vaccines': Icons.vaccines,
    'local_pharmacy': Icons.local_pharmacy,
    // حيوانات ومنزل
    'pets': Icons.pets,
    'home': Icons.home,
    'house': Icons.house,
    'dining': Icons.dining,
    'chair': Icons.chair,
    'bed': Icons.bed,
    'light': Icons.light,
    'bolt': Icons.bolt,
    // متفرقات
    'local_shipping': Icons.local_shipping,
    'delivery_dining': Icons.delivery_dining,
    'card_giftcard': Icons.card_giftcard,
    'redeem': Icons.redeem,
    'celebration': Icons.celebration,
    'toys': Icons.toys,
    'sports_esports': Icons.sports_esports,
    'menu_book': Icons.menu_book,
    'palette': Icons.palette,
    'brush': Icons.brush,
  };
}
