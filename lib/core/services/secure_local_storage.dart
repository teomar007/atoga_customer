import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// تخزين جلسة Supabase داخل Keystore / Keychain عبر `flutter_secure_storage`
/// بدل SharedPreferences العادي.
///
/// يفي بمتطلب "تشفير البيانات الحساسة": التوكنات لا تُكتب في تخزين غير محمي.
class SecureLocalStorage extends LocalStorage {
  SecureLocalStorage({required this.persistSessionKey, FlutterSecureStorage? secureStorage}) : _secure = secureStorage ?? _default();

  final String persistSessionKey;
  final FlutterSecureStorage _secure;
  static FlutterSecureStorage _default() {
    return const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true), iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock));
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async {
    final String? token = await _secure.read(key: persistSessionKey);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> accessToken() => _secure.read(key: persistSessionKey);

  @override
  Future<void> removePersistedSession() => _secure.delete(key: persistSessionKey);

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _secure.write(key: persistSessionKey, value: persistSessionString);
  }
}
