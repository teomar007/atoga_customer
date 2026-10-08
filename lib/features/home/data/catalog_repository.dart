import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/product.dart';
import '../domain/product_category.dart';
import '../domain/promo_banner.dart';
import 'seed_catalog.dart';

/// صفحة واحدة من المنتجات + هل يوجد المزيد.
class ProductPage {
  const ProductPage({required this.items, required this.hasMore});

  final List<Product> items;
  final bool hasMore;
}

/// قراءة الكتالوج من Supabase مع ترقيم صفحات (Range) لتقليل استهلاك
/// باقة بيانات الزبون.
class CatalogRepository {
  const CatalogRepository(this._client);

  final SupabaseClient _client;

  static const int pageSize = 20;

  Future<List<PromoBanner>> fetchBanners() async {
    try {
      // التصفية على is_active تمنع البانرات المعطّلة، والترتيب حسب
      // sort_order يثبّت التسلسل المُعرَّف في لوحة التحكم.
      // الشرط (eq) يسبق order/limit: هذه يُرجعان builder لا يدعم eq —
      // نفس القاعدة المطبّقة في fetchProducts.
      final List<Map<String, dynamic>> rows = await _client
          .from('promo_banners')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .limit(10);
      final List<PromoBanner> banners = rows
          .map(PromoBanner.fromJson)
          .where((PromoBanner b) => b.title.isNotEmpty)
          .toList();
      return banners.isEmpty ? SeedCatalog.banners : banners;
    } on Object catch (error, stack) {
      debugPrint('fetchBanners fallback: $error');
      debugPrintStack(stackTrace: stack, maxFrames: 4);
      return SeedCatalog.banners;
    }
  }

  /// التصنيفات الفعّالة فقط (`is_active = true`) مرتّبة تصاعدياً حسب
  /// `display_order` — نفس ترتيب الشريط الأفقي في لوحة التحكم.
  ///
  /// شرط (eq) يسبق order: يُرجع order بانيَ لا يدعم eq بعده (نفس القاعدة
  /// المطبّقة في fetchBanners وfetchProducts).
  ///
  /// القائمة الفارغة ليست خطأ: الأدمن قد يُخفي كل التصنيفات مؤقتاً، فيعرض
  /// التطبيق كل المنتجات بلا شريط تصنيفات. البذور تعود عند تعذّر الجلب فقط.
  Future<List<ProductCategory>> fetchCategories() async {
    try {
      final List<Map<String, dynamic>> rows = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);
      return rows.map(ProductCategory.fromJson).toList();
    } on Object catch (error, stack) {
      debugPrint('fetchCategories fallback: $error');
      debugPrintStack(stackTrace: stack, maxFrames: 4);
      return SeedCatalog.categories;
    }
  }

  /// [offset] يبدأ من صفر. [search] يُطبَّق على الاسم (ilike).
  Future<ProductPage> fetchProducts({
    String? categoryId,
    String? search,
    int offset = 0,
  }) async {
    try {
      PostgrestFilterBuilder<PostgrestList> query = _client.from('products').select();

      if (categoryId != null && categoryId != 'all') {
        query = query.eq('category_id', categoryId);
      }
      if (search != null && search.trim().isNotEmpty) {
        query = query.ilike('name', '%${search.trim()}%');
      }

      // الترتيب والنطاق بعد المرشّحات: `order`/`range` يُرجعان builder لا
      // يدعم `eq`/`ilike`، فيجب تطبيقها قبلهما.
      final PostgrestList rows = await query.order('created_at', ascending: false).range(offset, offset + pageSize - 1);
      if (rows.isEmpty && offset == 0) {
        // الجدول فارغ أو غير موجود: بيانات تجريبية محلية.
        return _seedPage(categoryId: categoryId, search: search, offset: offset);
      }

      return ProductPage(
        items: rows.map(Product.fromJson).toList(),
        hasMore: rows.length == pageSize,
      );
    } on Object catch (error, stack) {
      debugPrint('fetchProducts fallback: $error');
      debugPrintStack(stackTrace: stack, maxFrames: 4);
      return _seedPage(categoryId: categoryId, search: search, offset: offset);
    }
  }

  /// منتجات محددة بالمعرّفات — أساس شاشة المفضلة.
  ///
  /// الطلب الواحد بدل جلب الكتالوج وفلترته محلياً: المفضلة قد تشير إلى
  /// منتجات خارج الصفحة الأولى. يعود لبذور [SeedCatalog] عند تعذّر الجلب
  /// (نفس سلوك بقية القراءات) فلا تفشل الشاشة.
  Future<List<Product>> fetchByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return const <Product>[];
    }
    try {
      final PostgrestList rows = await _client
          .from('products')
          .select()
          .inFilter('id', ids)
          .order('created_at', ascending: false);
      if (rows.isEmpty) {
        return SeedCatalog.products.where((Product p) => ids.contains(p.id)).toList();
      }
      return rows.map(Product.fromJson).toList();
    } on Object catch (error, stack) {
      debugPrint('fetchByIds fallback: $error');
      debugPrintStack(stackTrace: stack, maxFrames: 4);
      return SeedCatalog.products.where((Product p) => ids.contains(p.id)).toList();
    }
  }

  ProductPage _seedPage({
    String? categoryId,
    String? search,
    required int offset,
  }) {
    return SeedCatalog.page(
      categoryId: categoryId,
      search: search,
      offset: offset,
      pageSize: pageSize,
    );
  }
}
