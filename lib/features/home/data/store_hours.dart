import 'package:flutter/material.dart' show TimeOfDay;
import 'package:supabase_flutter/supabase_flutter.dart';

/// وردية عمل واحدة من جدول `store_shifts` (يديرها تطبيق المانجر).
/// يمكن أن يكون لليوم أكثر من وردية (فتح/إغلاق عدة مرات في اليوم).
class StoreShift {
  const StoreShift({
    required this.dayOfWeek,
    required this.open,
    required this.close,
    this.sortOrder = 0,
  });

  /// 1 = الاثنين … 7 = الأحد (يوافق `DateTime.weekday`).
  final int dayOfWeek;
  final TimeOfDay open;
  final TimeOfDay close;
  final int sortOrder;

  /// دقائق الفتح/الإغلاق من منتصف الليل (00:00 تُعتبر 24:00 للإغلاق).
  int get openMinutes => open.hour * 60 + open.minute;
  int get closeMinutes => (close.hour == 0 && close.minute == 0) ? 24 * 60 : close.hour * 60 + close.minute;

  factory StoreShift.fromJson(Map<String, dynamic> json) {
    return StoreShift(
      dayOfWeek: (json['day_of_week'] as num?)?.toInt() ?? 0,
      open: _parseTime('${json['open_time'] ?? ''}'),
      close: _parseTime('${json['close_time'] ?? ''}'),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

TimeOfDay _parseTime(String raw) {
  final List<String> parts = raw.split(':');
  final int h = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
  final int m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
  return TimeOfDay(hour: h, minute: m);
}

/// كل ورديات الأسبوع الفعّالة.
Future<List<StoreShift>> fetchStoreShifts(SupabaseClient client) async {
  final PostgrestList rows = await client
      .from('store_shifts')
      .select()
      .eq('is_active', true)
      .order('day_of_week', ascending: true)
      .order('sort_order', ascending: true);
  return rows.map((dynamic row) => StoreShift.fromJson(Map<String, dynamic>.from(row as Map))).toList();
}

/// هل المتجر مفتوح الآن؟ منطق خالص قابل للاختبار.
///
/// غياب أي وردية تحتوي الوقت الحالي يعني «مغلق». المتصل بالمزود يتعامل مع
/// فشل الجلب كـ«مفتوح افتراضياً» كي لا تُعطّل الشبكة التسوق.
bool isStoreOpenNow(List<StoreShift> shifts, DateTime now) {
  final int current = now.hour * 60 + now.minute;
  for (final StoreShift shift in shifts) {
    if (shift.dayOfWeek != now.weekday) {
      continue;
    }
    final int open = shift.open.hour * 60 + shift.open.minute;
    final int close = (shift.close.hour == 0 && shift.close.minute == 0) ? 24 * 60 : shift.close.hour * 60 + shift.close.minute;
    if (current >= open && current < close) {
      return true;
    }
  }
  return false;
}
