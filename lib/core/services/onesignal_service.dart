import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  String? _lastInitError;
  final List<String> _log = <String>[];

  static const MethodChannel _probeChannel = MethodChannel('app_native_probe');

  bool get initialized => _initialized;

  /// نصّ آخر خطأ تهيئة (يُعرض في أداة التشخيص).
  String? get lastInitError => _lastInitError;

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
    try {
      _log.add('init:start');
      // سجلّ مفصّل في وضع التطوير لتشخيص التسجيل (FCM token / id / permission).
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      }
      // مهلة صريحة: تعليق القناة (كما نراه على الجهاز) يجب أن يظهر كخطأ.
      await OneSignal.initialize(appId).timeout(const Duration(seconds: 15));
      _initialized = true;
      _lastInitError = null;
      _log.add('init:ok id=$currentSubscriptionId');
      debugPrint('OneSignal initialized → id=$currentSubscriptionId token=$pushToken permission=$hasPermission');
      _emit(currentSubscriptionId);
      if (_observer == null) {
        _observer = (OSPushSubscriptionChangedState state) => _emit(state.current.id);
        OneSignal.User.pushSubscription.addObserver(_observer!);
      }
    } on Object catch (error) {
      // نُبقي القناة قابلة لإعادة المحاولة (لا نعتبره مهيّأً).
      _lastInitError = '$error';
      _log.add('init:err $error');
      debugPrint('OneSignal initialize failed: $error');
    }
  }

  /// تشخيص أصلي: هل فئات OneSignal/Firebase موجودة في الحزمة (كشف قطع R8).
  Future<String> nativeProbe() async {
    if (isTestEnvironment) {
      return 'test environment';
    }
    try {
      return await _probeChannel.invokeMethod<String>('probe') ?? '(empty)';
    } on Object catch (error) {
      return 'probe failed: $error';
    }
  }

  /// إعادة محاولة التهيئة (زر داخل أداة التشخيص).
  Future<void> retryInitialize(String appId) async {
    _initialized = false;
    await initialize(appId);
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
        'fcmToken: ${pushToken ?? "(null)"}\n'
        'initialized: $initialized\n'
        'lastInitError: ${lastInitError ?? "(none)"}\n'
        'log:\n${_log.isEmpty ? "(empty)" : _log.join("\n")}';
  }

  /// طلب إذن الإشعارات — يُستدعى من زر النافذة السياقية فقط (وفق الدليل).
  Future<bool> requestPermission() async {
    if (isTestEnvironment) {
      return false;
    }
    final bool granted = await OneSignal.Notifications.requestPermission(true);
    if (granted) {
      // الإذن مطلوب لتسجيل الاشتراك لدى OneSignal — نؤكّد الـ opt-in فوراً.
      try {
        await OneSignal.User.pushSubscription.optIn();
      } on Object catch (error) {
        debugPrint('OneSignal optIn failed: $error');
      }
      _log.add('permission:granted');
      _emit(currentSubscriptionId);
    } else {
      _log.add('permission:denied');
    }
    return granted;
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
