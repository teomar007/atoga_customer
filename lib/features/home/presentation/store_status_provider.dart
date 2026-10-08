import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import '../data/store_hours.dart';

/// حالة عمل المتجر: مفتوح أم مغلق حسب ساعات الجدول.
enum StoreStatus { open, closed }

/// حالة المتجر الحالية، مع إعادة تقييم دورية كل دقيقة كي يتزامن ضوء
/// الحالة تلقائياً عند حدود الساعات دون إعادة تشغيل.
final storeStatusProvider = NotifierProvider<StoreStatusController, StoreStatus>(StoreStatusController.new);

class StoreStatusController extends Notifier<StoreStatus> {
  Timer? _refreshTimer;

  @override
  StoreStatus build() {
    ref.onDispose(() => _refreshTimer?.cancel());
    // افتراض «مفتوح» عند الإقلاع؛ يتحول وفق الجدول بعد أول جلب.
    _load();
    return StoreStatus.open;
  }

  Future<void> _load() async {
    try {
      final SupabaseClient client = ref.read(supabaseClientProvider);
      final List<StoreHours> hours = await fetchStoreHours(client);
      _refreshTimer?.cancel();
      // المؤقّت يُجدول فقط بعد نجاح الجلب (لا مؤقّت عائم في الاختبارات).
      _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) => _apply(hours));
      _apply(hours);
    } on Object catch (error) {
      // غياب الجدول أو فشل الشبكة ليس «إغلاقاً»: نبقى مفتوحين افتراضياً.
      debugPrint('store hours unavailable: $error');
    }
  }

  void _apply(List<StoreHours> hours) {
    state = isStoreOpenNow(hours, DateTime.now()) ? StoreStatus.open : StoreStatus.closed;
  }
}
