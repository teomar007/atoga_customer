import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/presentation/store_status_provider.dart';
import '../providers/locale_provider.dart';
import '../services/app_icon_service.dart';

/// يزامن أيقونة المشغّل مع حالة المتجر أثناء التشغيل (وعند الإقلاع)،
/// ويحفظ آخر حالة لتقليل النداءات. التحديث الخلفي تتولاه مهمة WorkManager.
class StoreIconSync extends ConsumerStatefulWidget {
  const StoreIconSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<StoreIconSync> createState() => _StoreIconSyncState();
}

class _StoreIconSyncState extends ConsumerState<StoreIconSync> {
  static const String _prefKey = 'store_icon_open_state';
  bool _applied = false;

  @override
  void initState() {
    super.initState();
    // أول تطبيق دائماً (لضمان تطابق الجانب الأصلي مع آخر حالة محفوظة).
    WidgetsBinding.instance.addPostFrameCallback((_) => _apply(ref.read(storeStatusProvider)));
  }

  Future<void> _apply(StoreStatus status) async {
    final bool open = status == StoreStatus.open;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    if (_applied && prefs.getBool(_prefKey) == open) {
      return;
    }
    _applied = true;
    await prefs.setBool(_prefKey, open);
    try {
      await AppIconService.setStoreOpen(open);
    } on Object catch (error) {
      debugPrint('AppIconService.setStoreOpen failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<StoreStatus>(storeStatusProvider, (StoreStatus? previous, StoreStatus next) => _apply(next));
    return widget.child;
  }
}
