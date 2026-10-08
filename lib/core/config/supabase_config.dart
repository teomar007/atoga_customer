/// إعدادات الاتصال بـ Supabase.
///
/// تُقرأ القيم من `dart-define` عند التشغيل، وتُستخدم القيم الافتراضية
/// أدناه حتى يعمل التطبيق فوراً بعد الاستنساخ:
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=sb_publishable_xxx
/// ```
/// مفتاح `publishable` آمن للنشر في تطبيقات العميل حسب تصميم Supabase، أما
/// `service_role` فلا يُوضع أبداً في كود العميل.
library;

abstract final class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://qwiaxkrwyhdjrucnknhm.supabase.co');

  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3aWF4a3J3eWhkanJ1Y25rbmhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTExOTI0NjksImV4cCI6MjEwNjc2ODQ2OX0.SGJozJfL1RVMqCsKXjnJxrb2YDqYjGrSNpy6PtfS-h4');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
