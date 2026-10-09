import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/orders/presentation/order_tracking_screen.dart';
import '../navigation/app_navigator.dart';

/// موضوع الإشعارات العامة (حملات وعروض) — مرة واحدة لكل مشترك.
const String fcmAllTopic = 'all';

/// إشعارات Firebase المباشرة (بديل OneSignal): إذن النظام الأصلي، رمز
/// الجهاز، الموضوع العام، وعرض الإشعارات والتطبيق مفتوح.
class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();

  static const String _channelId = 'atoga_default';
  static const String _channelName = 'ATOGA MARKET';

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final StreamController<String?> _tokenController = StreamController<String?>.broadcast();

  String? _token;
  bool _permission = false;
  bool _initialized = false;

  /// بثّ رمز الجهاز (يُحفظ في `profiles.fcm_token`).
  Stream<String?> get tokenEvents => _tokenController.stream;
  String? get token => _token;
  bool get hasPermission => _permission;

  static bool get isTestEnvironment => Platform.environment['FLUTTER_TEST'] == 'true';

  /// تهيئة الإشعارات: قناة العرض، مستمع الواجهة، الرمز وتحديثه، والموضوع.
  /// لا يطلب الإذن هنا (الطلب لاحقاً من نافذة سياقية بعد الدخول).
  Future<void> initialize() async {
    if (_initialized || isTestEnvironment) {
      return;
    }
    _initialized = true;
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    _permission = _isAuthorized((await messaging.getNotificationSettings()).authorizationStatus);

    await _local.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: (NotificationResponse response) => _openFromPayload(response.payload),
    );
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(_channelId, _channelName, description: 'إشعارات الطلبات والعروض', importance: Importance.high));

    // عرض الإشعارات والتطبيق مفتوح.
    FirebaseMessaging.onMessage.listen(_showForeground);
    // فتح تتبّع الطلب عند النقر على إشعار (خلفية/مغلق).
    FirebaseMessaging.onMessageOpenedApp.listen(_openFromMessage);
    final RemoteMessage? initial = await messaging.getInitialMessage();
    if (initial != null) {
      _openFromMessage(initial);
    }

    _token = await messaging.getToken();
    _emitToken(_token);
    messaging.onTokenRefresh.listen(_emitToken);

    // موضوع العروض العامة (لا يتطلب إذن الإشعارات).
    try {
      await messaging.subscribeToTopic(fcmAllTopic);
    } on Object catch (error) {
      debugPrint('FCM subscribeToTopic failed: $error');
    }
  }

  /// طلب إذن الإشعارات — نافذة نظام واحدة سريعة (بعد تسجيل الدخول).
  Future<bool> requestPermission() async {
    if (isTestEnvironment) {
      return false;
    }
    final NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
    _permission = _isAuthorized(settings.authorizationStatus);
    return _permission;
  }

  /// ملخص تشخيصي يُعرض في أداة الدعم المخفية.
  String get diagnosticsSummary {
    if (isTestEnvironment) {
      return 'test environment';
    }
    return 'permission: $hasPermission\n'
        'fcmToken: ${_token ?? "(null)"}\n'
        'topic: $fcmAllTopic';
  }

  static bool _isAuthorized(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized || status == AuthorizationStatus.provisional;
  }

  void _emitToken(String? value) {
    _token = value;
    debugPrint('FCM token: ${value == null ? "(null)" : "received"}');
    _tokenController.add(value);
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final String? orderId = message.data['orderId']?.toString();
    if (notification == null) {
      return;
    }
    await _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(android: AndroidNotificationDetails(_channelId, _channelName, importance: Importance.high, priority: Priority.high)),
      payload: orderId,
    );
  }

  void _openFromMessage(RemoteMessage message) => _openFromPayload(message.data['orderId']?.toString());

  void _openFromPayload(String? orderId) {
    if (orderId == null || orderId.isEmpty || orderId == 'null') {
      return;
    }
    appNavigatorKey.currentState?.push(MaterialPageRoute<void>(builder: (BuildContext context) => OrderTrackingScreen(orderId: orderId)));
  }
}
