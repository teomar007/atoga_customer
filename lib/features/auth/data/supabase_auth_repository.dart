import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/foundation.dart';
import 'package:gotrue/gotrue.dart' as gotrue;

import '../domain/auth_repository.dart';
import '../domain/customer_user.dart';
import '../../../core/utils/phone_utils.dart';

/// تنفيذ المصادقة عبر Supabase Auth:
/// **Google Sign-In + البريد الإلكتروني وكلمة المرور** (بلا OTP).
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  /// مخطط Deeplink المستخدم في إعادة توجيه Google OAuth.
  static const String oauthRedirect = 'atogamarket://login-callback';

  CustomerUser? _cached;

  @override
  CustomerUser? get currentUser {
    // الجلسة تُستعاد من التخزين المشفّر في `Supabase.initialize` قبل `runApp`،
    // لكن `_cached` يكون فارغاً عند البناء الأول، فنقرأ من عميل Auth.
    _cached ??= _map(_client.auth.currentUser);
    return _cached;
  }

  @override
  Stream<CustomerUser?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((AuthState state) => _map(state.session?.user));
  }

  @override
  Future<void> signInWithGoogle() async {
    // نتيجة المصادقة تصل لاحقاً عبر `onAuthStateChange` بعد Deeplink.
    await _client.auth.signInWithOAuth(OAuthProvider.google, redirectTo: oauthRedirect);
  }

  @override
  Future<CustomerUser> signInWithPassword({required String phone, required String password}) async {
    final String dummyEmail = PhoneNumbers.toDummyEmail(phone) ?? (throw const AuthException('phone_invalid'));
    final AuthResponse response = await _client.auth.signInWithPassword(email: dummyEmail, password: password);
    final User? user = response.user;
    if (user == null) {
      throw const AuthException('invalid_credentials');
    }
    return _cache(await _withProfile(_map(user)!));
  }

  @override
  Future<SignUpResult> signUp({required String phone, required String password, String? displayName}) async {
    final String cleanName = (displayName ?? '').trim();
    // ← الحيلة: رقم الهاتف = البريد الوهمي. لا يره المستخدم أبداً.
    final String? dummyEmail = PhoneNumbers.toDummyEmail(phone);
    if (dummyEmail == null) {
      throw const AuthException('phone_invalid');
    }
    // الصيغة المحلية للتخزين (0XXXXXXXXX) وبmetadata ثم في profiles.
    final String local = dummyEmail.split('@').first;
    try {
      final AuthResponse response = await _client.auth.signUp(email: dummyEmail, password: password, data: <String, dynamic>{
        if (cleanName.isNotEmpty) 'display_name': cleanName,
        // يحفظ الرقم الحقيقي في metadata ثم في جدول profiles عبر الـ trigger.
        'phone_local': local,
        'phone': local,
      });
      final User? user = response.user;
      if (user == null) {
        // Supabase قبل الطلب (مثلاً: التسجيل معطّل).
        throw const AuthException('signup_denied');
      }
      // نبني الملف عبر trigger/RPC عند توفر جلسة؛ وبدونها ينشئه
      // trigger `handle_new_user` على الخادم.
      final CustomerUser created = _map(user)!;
      if (response.session == null) {
        // لم تُفعَّل «التأكيد التلقائي»: لا جلسة بعد، وtrigger `handle_new_user`
        // هو من ينشئ صف profiles بالاسم والرقم من الـ metadata.
        return SignUpResult(user: _cache(created), sessionReady: false);
      }
      // الحفظ الصريح: upsert للاسم والرقم الحقيقي في profiles فور نجاح التسجيل
      // (الجلسة مفتوحة إذن RLS يسمح بالكتابة على صف المستخدم نفسه).
      try {
        await _upsertProfile(user.id, <String, dynamic>{
          if (cleanName.isNotEmpty) 'display_name': cleanName,
          'phone': local,
        });
      } on Object catch (error) {
        // لا نفشل التسجيل بسبب profiles؛ `ensureProfile` بعده شبكة أمان إضافية.
        debugPrint('profiles upsert after signUp failed: $error');
      }
      final CustomerUser withProfile = _cache(await ensureProfile(created));
      return SignUpResult(user: withProfile, sessionReady: true);
    } on gotrue.AuthException catch (error) {
      debugPrint('signUp failed: code=${error.code} status=${error.statusCode} message="${error.message}"');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    _cached = null;
  }

  @override
  Future<void> deleteAccount() async {
    final String userId = _client.auth.currentUser?.id ?? '';
    if (userId.isEmpty) {
      return;
    }
    // حذف صف `auth.users` يحتاج صلاحيات service role، لذلك يُنفَّذ عبر
    // Edge Function على الخادم (انظر README).
    try {
      final FunctionResponse response = await _client.functions.invoke('delete-account');
      if (response.status >= 400) {
        throw const AuthException('delete_account_denied');
      }
    } on FunctionException {
      throw const AuthException('delete_account_denied');
    }
    _cached = null;
  }

  @override
  Future<CustomerUser> updateProfile({String? displayName, String? phone}) async {
    final String userId = _client.auth.currentUser?.id ?? '';
    if (userId.isEmpty) {
      throw const AuthException('not_authenticated');
    }
    final Map<String, dynamic> patch = <String, dynamic>{};
    if (displayName != null) {
      patch['display_name'] = displayName.trim();
    }
    if (phone != null) {
      // الهاتف اختياري: سلسلة فارغة تُخزَّن كـ null.
      final String clean = phone.trim();
      patch['phone'] = clean.isEmpty ? null : clean;
    }
    if (patch.isNotEmpty) {
      await _upsertProfile(userId, patch);
    }
    return _refresh();
  }

  @override
  Future<CustomerUser> savePhone(String phone) async {
    final String userId = _client.auth.currentUser?.id ?? '';
    if (userId.isEmpty) {
      throw const AuthException('not_authenticated');
    }
    await _upsertProfile(userId, <String, dynamic>{'phone': phone.trim()});
    return _refresh();
  }

  @override
  Future<void> saveLanguage(String languageCode) async {
    final String userId = _client.auth.currentUser?.id ?? '';
    if (userId.isEmpty) {
      throw const AuthException('not_authenticated');
    }
    // نفس مسار حفظ الملف الشخصي (upsert) — يعمل مع صف موجود أو جديد.
    await _upsertProfile(userId, <String, dynamic>{'language_code': languageCode.trim()});
  }

  @override
  Future<void> savePushSubscriptionId(String? onesignalId) async {
    final String userId = _client.auth.currentUser?.id ?? '';
    if (userId.isEmpty) {
      return;
    }
    // upsert على عمود ممنوح وحده (onesignal_id) — لا يمسّ الرصيد وغيره.
    await _upsertProfile(userId, <String, dynamic>{'onesignal_id': onesignalId});
  }

  /// يحفظ حقول الملف الشخصي المتاحة بلا صلاحية UPDATE جدولية كاملة.
  ///
  /// نستخدم `update` أولاً (يعمل مع المنحة العمودية محمية الرصيد)،
  /// ونلجأ إلى `insert` فقط عند غياب الصف (ينشئه الزبون لنفسه) —
  /// `upsert` في PostgREST يتطلب UPDATE جدولية فيفشل بـ 403 بعد حماية
  /// `wallet_balance` من التعديل اليدوي.
  Future<void> _upsertProfile(String userId, Map<String, dynamic> patch) async {
    final PostgrestList updated = await _client
        .from('profiles')
        .update(patch)
        .eq('id', userId)
        .select('id');
    if (updated.isEmpty) {
      await _client.from('profiles').insert(<String, dynamic>{'id': userId, ...patch});
    }
  }

  Future<CustomerUser> _refresh() async {
    final CustomerUser base = _map(_client.auth.currentUser) ?? _cached ?? CustomerUser(id: '');
    final CustomerUser? profile = await _readProfile(base);
    return _cache(profile ?? base);
  }

  CustomerUser _cache(CustomerUser user) {
    _cached = user;
    return user;
  }

  /// يقرأ `profiles`؛ وإن لم يوجد صف يُنشأ عند أول تسجيل دخول.
  Future<CustomerUser> _withProfile(CustomerUser user) async {
    try {
      return await ensureProfile(user);
    } on Object catch (error) {
      // لا نفشل تسجيل الدخول بسبب الملف الشخصي، لكن نسجّل السبب بوضوح.
      debugPrint('ensureProfile failed for ${user.id}: $error');
      return user;
    }
  }

  /// يقرأ الملف الشخصي من `profiles` أو ينشئه — أساس تطبيق اللغة
  /// والتفضيلات عند الإقلاع بجلسة محفوظة.
  @override
  Future<CustomerUser> refreshProfile() async {
    final CustomerUser? base = _map(_client.auth.currentUser);
    if (base == null) {
      throw const AuthException('not_authenticated');
    }
    return _cache(await _withProfile(base));
  }

  /// يضمن وجود صف في `profiles` عبر دالة `get_or_create_my_profile`
  /// (SECURITY DEFINER) — works حتى لو لم يكن الـ trigger موجوداً.
  Future<CustomerUser> ensureProfile(CustomerUser user) async {
    try {
      final PostgrestList rows = await _client.rpc('get_or_create_my_profile', params: <String, dynamic>{});
      if (rows.isEmpty) {
        return user;
      }
      final Map<String, dynamic> row = Map<String, dynamic>.from(rows.first as Map);
      return user.copyWith(displayName: row['display_name']?.toString(), phone: row['phone']?.toString(), languageCode: row['language_code']?.toString(), walletBalance: double.tryParse('${row['wallet_balance'] ?? ''}') ?? 0);
    } on PostgrestException catch (error) {
      // 42P01 = الجدول غير موجود (لم يُنفَّذ schema.sql بعد).
      debugPrint('get_or_create_my_profile RPC failed (code=${error.code}): ${error.message}');
      return _fallbackProfile(user);
    }
  }

  /// بديل عند تعذّر الـ RPC: قراءة مباشرة ثم إدراج عند الحاجة.
  Future<CustomerUser> _fallbackProfile(CustomerUser user) async {
    final List<Map<String, dynamic>> rows = await _client.from('profiles').select().eq('id', user.id).limit(1);
    if (rows.isEmpty) {
      await _upsertProfile(user.id, <String, dynamic>{'display_name': user.fallbackLabel, 'phone': user.phone});
      return user;
    }
    return user.copyWith(displayName: rows.first['display_name']?.toString(), phone: rows.first['phone']?.toString(), languageCode: rows.first['language_code']?.toString(), walletBalance: double.tryParse('${rows.first['wallet_balance'] ?? ''}') ?? 0);
  }

  Future<CustomerUser?> _readProfile(CustomerUser user) async {
    final List<Map<String, dynamic>> rows = await _client.from('profiles').select().eq('id', user.id).limit(1);
    if (rows.isEmpty) {
      return null;
    }
    return user.copyWith(displayName: rows.first['display_name']?.toString(), phone: rows.first['phone']?.toString(), languageCode: rows.first['language_code']?.toString(), walletBalance: double.tryParse('${rows.first['wallet_balance'] ?? ''}') ?? 0);
  }

  CustomerUser? _map(User? user) {
    if (user == null) {
      _cached = null;
      return null;
    }
    final Map<String, dynamic> metadata = user.userMetadata ?? <String, dynamic>{};
    final String? name = (metadata['display_name'] ?? metadata['full_name'] ?? metadata['name'])?.toString();
    // استعادة الهاتف: أولاً من metadata، ثم من الجلسة، وأخيراً من البريد
    // الوهمي نفسه (`0555123456@atoga.com` → `0555123456`).
    final String? fromMeta = PhoneNumbers.fromDummyEmail('${metadata['phone_local'] ?? ''}');
    final String? fromEmail = PhoneNumbers.fromDummyEmail(user.email);
    final String phone = fromMeta ?? PhoneNumbers.fromDummyEmail(user.phone) ?? fromEmail ?? '';
    // البريد الوهمي معرّف داخلي فقط ولا يُعرض أبداً.
    return CustomerUser(id: user.id, phone: phone.isEmpty ? null : phone, email: null, displayName: name);
  }
}

/// خطأ مصادقة موحّد تُترجمه الواجهة إلى رسائل `l10n`.
class AuthException implements Exception {
  const AuthException(this.code);

  final String code;

  @override
  String toString() => 'AuthException($code)';
}
