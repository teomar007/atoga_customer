import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// هوية محفوظة لتعبئة نموذج الدخول تلقائياً (خيار «حفظ كلمة المرور»).
class SavedCredentials {
  const SavedCredentials({required this.phone, required this.password});

  final String phone;
  final String password;
}

/// يخزّن الهاتف وكلمة المرور في **التخزين المشفّر** (Keystore على Android /
/// Keychain على iOS) وليس في SharedPreferences — ولا يُكتب أي شيء ما لم
/// يطلب الزبون ذلك صراحةً عبر مربع «حفظ كلمة المرور».
class SavedCredentialsStore {
  SavedCredentialsStore({FlutterSecureStorage? storage}) : _storage = storage ?? _default();

  static const String _phoneKey = 'saved_login_phone';
  static const String _passwordKey = 'saved_login_password';

  final FlutterSecureStorage _storage;

  static FlutterSecureStorage _default() {
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }

  Future<SavedCredentials?> read() async {
    final List<String?> values = await Future.wait<String?>([
      _storage.read(key: _phoneKey),
      _storage.read(key: _passwordKey),
    ]);
    final String? phone = values[0];
    final String? password = values[1];
    final String cleanPhone = (phone ?? '').trim();
    if (cleanPhone.isEmpty || (password == null || password.isEmpty)) {
      return null;
    }
    return SavedCredentials(phone: cleanPhone, password: password);
  }

  Future<void> save(String phone, String password) async {
    await _storage.write(key: _phoneKey, value: phone.trim());
    await _storage.write(key: _passwordKey, value: password);
  }

  Future<void> clear() async {
    await _storage.delete(key: _phoneKey);
    await _storage.delete(key: _passwordKey);
  }
}

final savedCredentialsStoreProvider = Provider<SavedCredentialsStore>((Ref ref) => SavedCredentialsStore());
