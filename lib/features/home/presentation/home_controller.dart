import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_providers.dart';
import '../data/catalog_repository.dart';
import '../domain/product.dart';
import '../domain/product_category.dart';
import '../domain/promo_banner.dart';

/// حالة الشاشة الرئيسية: البانرات + التصنيفات + المنتجات (مع ترقيم).
@immutable
class HomeState {
  const HomeState({
    this.banners = const <PromoBanner>[],
    this.categories = const <ProductCategory>[],
    this.products = const <Product>[],
    this.selectedCategoryId,
    this.search = '',
    this.loading = true,
    this.loadingMore = false,
    this.hasMore = false,
    this.error,
  });

  final List<PromoBanner> banners;
  final List<ProductCategory> categories;
  final List<Product> products;
  final String? selectedCategoryId;
  final String search;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;

  /// رسالة خطأ جاهزة للعرض، أو null.
  final String? error;

  bool get isSearching => search.trim().isNotEmpty;

  bool get isEmpty => !loading && products.isEmpty;

  HomeState copyWith({
    List<PromoBanner>? banners,
    List<ProductCategory>? categories,
    List<Product>? products,
    String? selectedCategoryId,
    bool clearCategory = false,
    String? search,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return HomeState(
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      search: search ?? this.search,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// مزوّد الشاشة الرئيسية — يدير البحث والتصنيفات والتمرير اللانهائي.
class HomeController extends Notifier<HomeState> {
  Timer? _searchDebounce;

  CatalogRepository get _repo => ref.read(catalogRepositoryProvider);

  @override
  HomeState build() {
    ref.onDispose(() => _searchDebounce?.cancel());
    // التحميل الأولي يبدأ تلقائياً عند أول إنشاء للمزوّد. بدون هذا السطر
    // تبقى `loading: true` إلى ما لا نهاية وتعرض الشاشة مربعات الشيمر
    // دائماً — لا يوجد أي استدعاء لـ loadInitial عند الإقلاع.
    Future<void>.microtask(loadInitial);
    return const HomeState();
  }

  /// التحميل الأولي (شاشات الشيمر).
  Future<void> loadInitial() async {
    if (state.loading && state.products.isNotEmpty) {
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      // قراءة المزوّد داخل try: فشل التهيئة (عميل Supabase غير المُهيّأ مثلاً)
      // يجب أن يظهر كخطأ في الواجهة مع زر إعادة المحاولة، لا كاستثناء غير
      // معالَج يخرج من microtask.
      final CatalogRepository repo = _repo;
      final List<Object> results = await Future.wait(<Future<Object>>[repo.fetchBanners(), repo.fetchCategories()]);
      final List<PromoBanner> banners = results[0] as List<PromoBanner>;
      final List<ProductCategory> categories = results[1] as List<ProductCategory>;
      final ProductPage page = await repo.fetchProducts(categoryId: state.selectedCategoryId, search: state.search);
      state = state.copyWith(banners: banners, categories: categories, products: page.items, hasMore: page.hasMore, loading: false, clearError: true);
    } on Object catch (error) {
      debugPrint('HomeController.loadInitial: $error');
      state = state.copyWith(loading: false, error: 'productsLoadFailed');
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(products: const <Product>[], loading: true, clearError: true);
    await loadInitial();
  }

  void selectCategory(String? id) {
    // 'all' رمز تاريخي (بانرات وبذور): يعاد إلى null أي زر «الكل».
    final String? selected = id == 'all' ? null : id;
    if (state.selectedCategoryId == selected) {
      return;
    }
    state = state.copyWith(selectedCategoryId: selected, clearCategory: selected == null);
    _reloadProducts();
  }

  /// بحث مؤجّل 350ms لتقليل الطلبات أثناء الكتابة.
  void onSearchChanged(String value) {
    state = state.copyWith(search: value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _reloadProducts);
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    state = state.copyWith(search: '');
    _reloadProducts();
  }

  Future<void> _reloadProducts() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final ProductPage page = await _repo.fetchProducts(categoryId: state.selectedCategoryId, search: state.search);
      state = state.copyWith(products: page.items, hasMore: page.hasMore, loading: false);
    } on Object catch (error) {
      debugPrint('HomeController._reloadProducts: $error');
      state = state.copyWith(loading: false, error: 'productsLoadFailed');
    }
  }

  /// يُستدعى عند الوصول قرب القاع (تمرير لا نهائي).
  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore || state.loading) {
      return;
    }
    state = state.copyWith(loadingMore: true);
    try {
      final ProductPage page = await _repo.fetchProducts(categoryId: state.selectedCategoryId, search: state.search, offset: state.products.length);
      state = state.copyWith(products: <Product>[...state.products, ...page.items], hasMore: page.hasMore, loadingMore: false);
    } on Object catch (error) {
      debugPrint('HomeController.loadMore: $error');
      state = state.copyWith(loadingMore: false);
    }
  }
}

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(HomeController.new);
