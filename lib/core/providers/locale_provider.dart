import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// اللغات المدعومة: العربية (RTL) والفرنسية (LTR).
abstract final class AppLocales {
  const AppLocales._();

  static const Locale arabic = Locale('ar');
  static const Locale french = Locale('fr');
  static const List<Locale> supported = <Locale>[arabic, french];

  static Locale resolve(Locale? deviceLocale) {
    final String code = deviceLocale?.languageCode ?? '';
    return code == 'fr' ? french : arabic;
  }
}

/// لغة التطبيق، محفوظة محلياً. الافتراضي: العربية.
class LocaleController extends Notifier<Locale> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  Locale build() {
    final String? stored = _prefs.getString(AppConstants.localePrefKey);
    return stored == 'fr' ? AppLocales.french : AppLocales.arabic;
  }

  Future<void> setLocale(Locale locale) async {
    state = locale.languageCode == 'fr' ? AppLocales.french : AppLocales.arabic;
    await _prefs.setString(AppConstants.localePrefKey, state.languageCode);
  }

  Future<void> toggle() => setLocale(state.languageCode == 'ar' ? AppLocales.french : AppLocales.arabic);

  /// يتبناى لغة الحساب بعد قراءة الملف الشخصي (اتجاه القراءة).
  ///
  /// إن كانت اللغة مفقودة في الحساب أو غير مدعومة أو مطابقة للحالية فلا
  /// يفعل شيئاً — فالحفظ المحلي يبقى مصدر الحقيقة عند غياب `language_code`.
  Future<void> applyRemote(String? code) async {
    final String trimmed = (code ?? '').trim();
    if (trimmed != 'ar' && trimmed != 'fr') {
      return;
    }
    final Locale target = trimmed == 'fr' ? AppLocales.french : AppLocales.arabic;
    if (target == state) {
      return;
    }
    state = target;
    // يُحفظ محلياً أيضاً حتى تبقى اللغة بعد الإقلاع بلا اتصال.
    await _prefs.setString(AppConstants.localePrefKey, target.languageCode);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((Ref ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope'));

final localeControllerProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);
