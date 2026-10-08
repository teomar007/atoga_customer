import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../home/domain/product.dart';
import '../data/favorites_repository.dart';

/// معرّفات المنتجات في مفضلة المستخدم الحالي.
///
/// - **Optimistic Update**: الزر ينقلب فوراً قبل أي اتصال، والاتصال يتم في
///   الخلفية؛ وعند الفشل نعود للحالة السابقة **بصمت** فلا يشعر المستخدم
///   بأي تردّد في التجربة.
/// - الزائر ← مجموعة فارغة بلا أي طلب شبكة (تُملأ عند الدخول عبر SessionSync).
///
/// نمرّ عبر [favoritesRepositoryProvider] لا `Supabase.instance.client`
/// مباشرة: فالمسار يمرّ بـ `supabaseClientProvider` المُزدّد في `main.dart`
/// ويمكن اختباره دون تهيئة Supabase.
class FavoritesController extends AsyncNotifier<Set<String>> {
  FavoritesRepository get _repo => ref.read(favoritesRepositoryProvider);

  @override
  Future<Set<String>> build() async {
    final String? userId = ref.watch(currentUserProvider)?.id;
    if (userId == null) {
      return const <String>{};
    }
    return _repo.fetch(userId);
  }

  /// جلب صريح (يُستدعى من مزامنة الجلسة بعد تسجيل الدخول).
  Future<void> fetch() async {
    final String? userId = ref.read(currentUserProvider)?.id;
    if (userId == null) {
      state = const AsyncData(<String>{});
      return;
    }
    state = await AsyncValue.guard(() => _repo.fetch(userId));
  }

  /// تبديل المنتج في المفضلة: تحديث فوري في الواجهة ثم تأكيد من الخادم،
  /// مع تراجع الحالة السابقة عند الفشل.
  Future<void> toggle(String productId) async {
    final String? userId = ref.read(currentUserProvider)?.id;
    if (userId == null) {
      return;
    }
    final Set<String> previous = state.valueOrNull ?? const <String>{};
    final bool favorite = !previous.contains(productId);

    // Optimistic Update: القلب ينقلب فوراً قبل أن يصل الطلب إلى الخادم.
    state = AsyncData(favorite ? <String>{...previous, productId} : previous.difference(<String>{productId}));
    try {
      await _repo.set(userId, productId, favorite: favorite);
    } on Object catch (error) {
      // Rollback صامت: نعود للحالة السابقة بلا رسالة خطأ — الخادم هو
      // المرجع، والواجهة لا تُظهر ترددّاً عند ضعف الاتصال.
      debugPrint('favorites.toggle failed: $error');
      state = AsyncData(previous);
    }
  }

  bool contains(String productId) => state.valueOrNull?.contains(productId) ?? false;

  /// تفريغ الذاكرة عند تسجيل الخروج (البيانات تبقى في الخادم).
  void reset() => state = const AsyncData(<String>{});
}

final favoritesProvider = AsyncNotifierProvider<FavoritesController, Set<String>>(FavoritesController.new);

/// منتجات المفضلة كاملة (اسم/سعر/صورة) بدلاً من المعرّفات وحدها.
///
/// يراقب [favoritesProvider] فيعيد البناء عند أي تغيّر (إضافة أو إزالة)،
/// والشاشة لا تشاهده قبل أن تملك المفضلة بيانات — فلا طلب شبكة أثناء
/// التحميل ولا للزائر.
final favoriteProductsProvider = FutureProvider<List<Product>>((Ref ref) {
  final Set<String> ids = ref.watch(favoritesProvider).valueOrNull ?? const <String>{};
  if (ids.isEmpty) {
    return const <Product>[];
  }
  return ref.watch(catalogRepositoryProvider).fetchByIds(ids.toList(growable: false));
});
