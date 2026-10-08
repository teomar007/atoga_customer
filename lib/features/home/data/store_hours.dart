import 'package:flutter/material.dart' show TimeOfDay;
import 'package:supabase_flutter/supabase_flutter.dart';

/// ساعات عمل يوم واحد من جدول `store_hours` (يديره تطبيق الأدمن).
class StoreHours {
  const StoreHours({
    required this.dayOfWeek,
    this.morningOpen,
    this.morningClose,
    this.eveningOpen,
    this.eveningClose,
    this.isActive = true,
  });

  /// 1 = الاثنين ... 7 = الأحد (نفس `DateTime.weekday` في Dart).
  final int dayOfWeek;

  /// الفترة الصباحية (اختيارية — قد يعمل المتجر مساءً فقط).
  final TimeOfDay? morningOpen;
  final TimeOfDay? morningClose;

  /// الفترة المسائية (اختيارية).
  final TimeOfDay? eveningOpen;
  final TimeOfDay? eveningClose;

  final bool isActive;

  factory StoreHours.fromJson(Map<String, dynamic> json) {
    return StoreHours(
      dayOfWeek: (json['day_of_week'] as num?)?.toInt() ?? 0,
      morningOpen: _time(json['morning_open']),
      morningClose: _time(json['morning_close']),
      eveningOpen: _time(json['evening_open']),
      eveningClose: _time(json['evening_close']),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static TimeOfDay? _time(Object? value) {
    if (value == null) {
      return null;
    }
    final List<String> parts = '$value'.split(':');
    if (parts.length < 2) {
      return null;
    }
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
  }
}

/// يجلب أيام العمل الفعّالة من Supabase (الكتابة للأدمن عبر service_role).
Future<List<StoreHours>> fetchStoreHours(SupabaseClient client) async {
  final PostgrestList rows = await client
      .from('store_hours')
      .select()
      .eq('is_active', true)
      .order('day_of_week', ascending: true);
  return rows.map((dynamic row) => StoreHours.fromJson(Map<String, dynamic>.from(row as Map))).toList();
}

/// هل المتجر مفتوح الآن؟ منطق خالص قابل للاختبار.
///
/// غياب صف اليوم أو فترة ناقصة يعني «مغلق». المتصل بالمزود يتعامل مع
/// فشل الجلب كـ«مفتوح افتراضياً» كي لا تُعطّل الشبكة التسوق.
bool isStoreOpenNow(List<StoreHours> hours, DateTime now) {
  StoreHours? day;
  for (final StoreHours h in hours) {
    if (h.isActive && h.dayOfWeek == now.weekday) {
      day = h;
      break;
    }
  }
  if (day == null) {
    return false;
  }
  bool within(TimeOfDay? open, TimeOfDay? close) {
    if (open == null || close == null) {
      return false;
    }
    final int current = now.hour * 60 + now.minute;
    return current >= open.hour * 60 + open.minute && current < close.hour * 60 + close.minute;
  }

  return within(day.morningOpen, day.morningClose) || within(day.eveningOpen, day.eveningClose);
}
