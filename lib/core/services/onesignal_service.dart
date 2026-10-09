import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// بثّ معرّف اشتراك OneSignal الحقيقي — يملؤه [OneSignalService]،
/// ويستمع إليه AuthController لربطه بالحساب (`profiles.onesignal_id`).
final StreamController<String?> pushSubscriptionIdEvents = StreamController<String?>.broadcast();

/// واجهة مركزية لكل تعاملات OneSignal (وفق دليل الدمج الرسمي):
/// لا استدعاءات مباشرة للـ SDK خارج هذا الكلاس.
///
/// المعرّف «حقيقي» فقط عندما يكون غير فارغ وغير بادئ بـ `local-` (قيمة
/// مؤقتة قبل تسجيل الجهاز في خوادم OneSignal) — لا يُبثّ غيره.
class OneSignalService {
  OneSignalService._();

  static final OneSignalService instance = OneSignalService._();

  bool _initialized = false;
  OnPushSubscriptionChangeObserver? _observer;

  /// بيئة flutter test: لا توجد قناة منصة حقيقية فيتعطل أي استدعاء.
  static bool get isTestEnvironment => Platform.environment['FLUTTER_TEST'] == 'true';

  /// المعرّف الحالي (قراءة فورية — قد يكون جاهزاً قبل اشتراك المستمع).
  String? get currentSubscriptionId {
    if (isTestEnvironment) {
      return null;
    }
    return OneSignal.User.pushSubscription.id;
  }

  /// تهيئة مرة واحدة + تقييم فوري للمعرّف + اشتراك دائم (يُحفظ المرجع).
  Future<void> initialize(String appId) async {
    if (_initialized || isTestEnvironment) {
      return;
    }
    _initialized = true;
    // سجلّ مفصّل في وضع التطوير لتشخيص التسجيل (FCM token / id / permission).
    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    }
    await OneSignal.initialize(appId);
    debugPrint('OneSignal initialized → id=$currentSubscriptionId token=$pushToken permission=$hasPermission');
    _emit(currentSubscriptionId);
    _observer = (OSPushSubscriptionChangedState state) => _emit(state.current.id);
    OneSignal.User.pushSubscription.addObserver(_observer!);
  }

  /// هل منح المستخدم إذن الإشعارات فعلاً؟ (لا نطلب ثانيةً إن كان مفعّلاً.)
  bool get hasPermission => isTestEnvironment ? false : OneSignal.Notifications.permission;

  /// رمز FCM للجهاز — وجوده شرط التسجيل لدى OneSignal وخوادم الإرسال.
  String? get pushToken => isTestEnvironment ? null : OneSignal.User.pushSubscription.token;

  /// هل الجهاز مشترك فعلاً (opt-in) في الإشعارات؟
  bool get optedIn => isTestEnvironment ? false : (OneSignal.User.pushSubscription.optedIn ?? false);

  /// ملخص تشخيصي يُعرض داخل التطبيق (أداة دعم مخفية).
  String get diagnosticsSummary {
    if (isTestEnvironment) {
      return 'test environment';
    }
    return 'permission: $hasPermission\n'
        'optedIn: $optedIn\n'
        'subscriptionId: $currentSubscriptionId\n'
        'fcmToken: ${pushToken ?? "(null)"}';
  }

  /// طلب إذن الإشعارات — يُستدعى من زر النافذة السياقية فقط (وفق الدليل).
  Future<bool> requestPermission() async {
    if (isTestEnvironment) {
      return false;
    }
    return OneSignal.Notifications.requestPermission(true);
  }

  /// فصل الجهاز عن OneSignal عند الخروج/حذف الحساب.
  Future<void> logout() async {
    if (isTestEnvironment) {
      return;
    }
    try {
      await OneSignal.logout();
    } on Object catch (error) {
      debugPrint('OneSignal.logout failed: $error');
    }
  }

  static bool isRealSubscriptionId(String? id) {
    return id != null && id.isNotEmpty && !id.startsWith('local-');
  }

  void _emit(String? id) {
    debugPrint('OneSignal subscription id: $id (token=$pushToken, permission=$hasPermission)');
    if (isRealSubscriptionId(id)) {
      pushSubscriptionIdEvents.add(id);
    }
  }
}
