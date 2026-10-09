import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/supabase_providers.dart';
import 'core/services/cart_storage.dart';
import 'core/services/fcm_service.dart';
import 'core/services/secure_local_storage.dart';
import 'features/cart/presentation/cart_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
  await _initPushNotifications();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final Box<dynamic> cartBox = await CartStorage.openBox();
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(url: SupabaseConfig.url, publishableKey: SupabaseConfig.anonKey, authOptions: FlutterAuthClientOptions(localStorage: SecureLocalStorage(persistSessionKey: 'supabase.auth.session')));
  }
  runApp(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs), cartStorageProvider.overrideWithValue(CartStorage(cartBox)), supabaseClientProvider.overrideWithValue(Supabase.instance.client)], child: const AtogaApp()));
}

/// تهيئة إشعارات Firebase (FCM) — بلا طلب إذن عند الإقلاع؛ الطلب يقع من
/// النافذة السياقية بعد تسجيل الدخول.
Future<void> _initPushNotifications() async {
  try {
    await Firebase.initializeApp();
    await FcmService.instance.initialize();
  } on Object catch (error) {
    debugPrint('FCM initialization failed: $error');
  }
}
