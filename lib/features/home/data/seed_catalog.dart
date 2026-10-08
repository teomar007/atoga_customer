import '../domain/product.dart';
import '../domain/product_category.dart';
import '../domain/promo_banner.dart';
import 'catalog_repository.dart';

/// بيانات تجريبية محلية تُستخدم عند غياب الجداول أو انقطاع الخادم،
/// حتى يعمل التطبيق فوراً قبل ربط قاعدة البيانات الفعلية.
abstract final class SeedCatalog {
  const SeedCatalog._();

  static final List<ProductCategory> categories = <ProductCategory>[
    // زر «الكل» ليس تصنيفاً: يُرسم ثابتاً في أول الشريط (CategoryRail).
    const ProductCategory(id: 'canned', name: 'معلبات', iconName: 'lunch_dining'),
    const ProductCategory(id: 'drinks', name: 'مشروبات', iconName: 'local_drink'),
    const ProductCategory(id: 'dairy', name: 'أجبان وألبان', iconName: 'egg_alt'),
    const ProductCategory(id: 'grains', name: 'حبوب وعجائن', iconName: 'grain'),
    const ProductCategory(id: 'snacks', name: 'حلويات', iconName: 'cookie'),
    const ProductCategory(id: 'cleaning', name: 'مواد التنظيف', iconName: 'cleaning'),
  ];

  static final List<PromoBanner> banners = <PromoBanner>[
    const PromoBanner(id: 'b1', title: 'خصم 20%', titleFr: 'Remise 20%', subtitle: 'على كل المشروبات', subtitleFr: 'Sur toutes les boissons', discountLabel: '-20%', targetCategoryId: 'drinks'),
    const PromoBanner(id: 'b2', title: 'أجبان طازجة', titleFr: 'Fromages frais', subtitle: 'طازجة كل صباح', subtitleFr: 'Frais chaque matin', discountLabel: '-10%', targetCategoryId: 'dairy'),
    const PromoBanner(id: 'b3', title: 'توصيل مجاني', titleFr: 'Livraison gratuite', subtitle: 'للطلبات فوق 3000 د.ج', subtitleFr: 'Pour les commandes +3000 DA', targetCategoryId: 'all'),
  ];

  static final List<Product> products = <Product>[
    // صور الخصم والروابط تجريبية (placehold.co): تُستبدل بصور حقيقية من
    // لوحة الأدمن عبر image_url — الروابط مطابقة للبيانات في schema.sql.
    const Product(id: 'p1', name: 'طماطم مصبرة 400غ', nameFr: 'Tomates concervées 400 g', price: 120, categoryId: 'canned', unit: 'علبة', oldPrice: 150, imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Tomates'),
    const Product(id: 'p2', name: 'تون معلب في زيت', nameFr: 'Thon en boîte à l\'huile', price: 280, categoryId: 'canned', unit: 'علبة', imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Thon'),
    const Product(id: 'p3', name: 'معجون طماطم 800غ', nameFr: 'Pâte de tomate 800 g', price: 240, categoryId: 'canned', unit: 'علبة', oldPrice: 300, isPromo: true, imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Pate%20Tomate'),
    const Product(id: 'p4', name: 'عصير برتقال 1 لتر', nameFr: 'Jus d\'orange 1 L', price: 150, categoryId: 'drinks', unit: 'قنينة', oldPrice: 190, imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Jus%20Orange'),
    const Product(id: 'p5', name: 'مياه معدنية 6 قارورات', nameFr: 'Eau minérale 6 bouteilles', price: 180, categoryId: 'drinks', unit: 'حزمة', imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Eau'),
    const Product(id: 'p6', name: 'مشروب طاقة 250 مل', nameFr: 'Boisson énergisante 250 ml', price: 200, categoryId: 'drinks', unit: 'علبة', imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Energie'),
    const Product(id: 'p7', name: 'جبن أبيض 500غ', nameFr: 'Fromage blanc 500 g', price: 320, categoryId: 'dairy', unit: 'عبوة', imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Fromage'),
    const Product(id: 'p8', name: 'حليب طويل الأمد 1 لتر', nameFr: 'Lait longue conservation 1 L', price: 210, categoryId: 'dairy', unit: 'قنينة', imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Lait'),
    const Product(id: 'p9', name: 'زبدة طبيعية 250غ', nameFr: 'Beurre nature 250 g', price: 450, categoryId: 'dairy', unit: 'عبوة', oldPrice: 550, imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Beurre'),
    const Product(id: 'p10', name: 'زيت زيتون 1 لتر', nameFr: 'Huile d\'olive 1 L', price: 950, categoryId: 'dairy', unit: 'زجاجة', imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Huile'),
    const Product(id: 'p11', name: 'معكرونة إسباجتي 500غ', nameFr: 'Spaghetti 500 g', price: 130, categoryId: 'grains', unit: 'كيس', imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Spaghetti'),
    const Product(id: 'p12', name: 'أرز بسمتي 1 كغ', nameFr: 'Riz basmati 1 kg', price: 380, categoryId: 'grains', unit: 'كيس', oldPrice: 450, imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Riz'),
    const Product(id: 'p13', name: 'سكر 1 كغ', nameFr: 'Sucre 1 kg', price: 190, categoryId: 'grains', unit: 'كيس', imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Sucre'),
    const Product(id: 'p14', name: 'شوكولاتة 100غ', nameFr: 'Chocolat 100 g', price: 90, categoryId: 'snacks', unit: 'قطعة', imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Chocolat'),
    const Product(id: 'p15', name: 'بسكويت محشو 300غ', nameFr: 'Biscuits fourrés 300 g', price: 220, categoryId: 'snacks', unit: 'علبة', imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Biscuits'),
    const Product(id: 'p16', name: 'ماء ج الصابون 1 لتر', nameFr: 'Eau de Javel 1 L', price: 260, categoryId: 'cleaning', unit: 'قنينة', imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Javel'),
    const Product(id: 'p17', name: 'مسحوق غسيل 3 كغ', nameFr: 'Lessive en poudre 3 kg', price: 780, categoryId: 'cleaning', unit: 'كيس', oldPrice: 950, imageUrl: 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Lessive'),
  ];

  static List<Product> byCategory(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty || categoryId == 'all') {
      return products;
    }
    return products.where((Product p) => p.categoryId == categoryId).toList();
  }

  static ProductPage page({String? categoryId, String? search, int offset = 0, int pageSize = 20}) {
    final String term = (search ?? '').trim().toLowerCase();
    List<Product> filtered = byCategory(categoryId);
    if (term.isNotEmpty) {
      filtered = filtered.where((Product p) => p.name.toLowerCase().contains(term)).toList();
    }
    final List<Product> slice = filtered.skip(offset).take(pageSize).toList();
    return ProductPage(items: slice, hasMore: offset + slice.length < filtered.length);
  }
}
