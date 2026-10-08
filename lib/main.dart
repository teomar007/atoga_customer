import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/config/supabase_config.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/supabase_providers.dart';
import 'core/services/cart_storage.dart';
import 'core/services/secure_local_storage.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/cart/presentation/cart_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
  await _initOneSignal();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final Box<dynamic> cartBox = await CartStorage.openBox();
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(url: SupabaseConfig.url, publishableKey: SupabaseConfig.anonKey, authOptions: FlutterAuthClientOptions(localStorage: SecureLocalStorage(persistSessionKey: 'supabase.auth.session')));
  }
  runApp(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs), cartStorageProvider.overrideWithValue(CartStorage(cartBox)), supabaseClientProvider.overrideWithValue(Supabase.instance.client)], child: const AtogaApp()));
}

/// تهيئة OneSignal وطلب إذن الإشعارات، ثم ربط أي معرّف اشتراك يصل بالحساب
/// الحالي عبر [pushSubscriptionIdEvents] (يستمع إليه AuthController).
///
/// الفشل هنا ليس قاتلاً: يتوجّه التطبيق بلا إشعارات والميزة تعود عند
/// توفر الشبكة/الإعدادات الصحيحة.
Future<void> _initOneSignal() async {
  try {
    await OneSignal.initialize(AppConstants.onesignalAppId);
    await OneSignal.Notifications.requestPermission(true);
    OneSignal.User.pushSubscription.addObserver((OSPushSubscriptionChangedState state) {
      pushSubscriptionIdEvents.add(state.current.id);
    });
  } on Object catch (error) {
    debugPrint('OneSignal initialization failed: $error');
  }
}
