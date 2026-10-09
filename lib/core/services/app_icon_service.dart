import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// تبديل أيقونة المشغّل بين حالتَي المتجر (مفتوح/مغلق) — أندرويد فقط.
///
/// الجانب الأصلي يبدّل بين نشاطين مستعارين (`MainActivityOpen/Closed`).
/// خارج أندرويد أو في الاختبارات لا يفعل شيئاً (القناة غير موجودة).
abstract final class AppIconService {
  const AppIconService._();

  static const MethodChannel _channel = MethodChannel('app_icon');

  static Future<void> setStoreOpen(bool open) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    await _channel.invokeMethod<bool>('setStoreOpen', <String, dynamic>{'open': open});
  }
}
