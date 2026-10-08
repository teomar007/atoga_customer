import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// تنسيق الأرقام والعملة والتواريخ حسب اللغة الحالية.
abstract final class Formatters {
  const Formatters._();

  /// استبدال أرقام «العربية الهندية» (٠١٢٣...) التي تنتجها مكتبة intl
  /// للغة العربية بأرقام لاتينية (0-9) + الفاصل (٬ → ,) — سياسة ثابتة
  /// في كامل التطبيق: لا تُعرض الأرقام الهندية في أي شاشة.
  static const Map<String, String> _latin = <String, String>{
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
    '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    '٬': ',',
  };

  /// يحوّل أي رقم/تاريخ خارج من مكتبة intl إلى أرقام لاتينية حتمياً.
  static String _latinDigits(String input) {
    String result = input;
    _latin.forEach((String from, String to) {
      result = result.replaceAll(from, to);
    });
    return result;
  }

  /// السعر يُعرض بأرقام لا عشرية (الدينار لا يستعمل الكسور).
  static String price(double value, String languageCode) {
    final NumberFormat format = NumberFormat.decimalPattern(languageCode);
    final String amount = _latinDigits(format.format(value.round()));
    return languageCode == 'ar' ? '$amount د.ج' : '$amount DA';
  }

  static String plainNumber(double value, String languageCode) {
    return _latinDigits(NumberFormat.decimalPattern(languageCode).format(value.round()));
  }

  static String date(DateTime value, String languageCode) {
    return _latinDigits(DateFormat('d MMMM yyyy', languageCode).format(value));
  }

  static String dateTime(DateTime value, String languageCode) {
    return _latinDigits(DateFormat('d MMM yyyy - HH:mm', languageCode).format(value));
  }

  static String time(DateTime value, String languageCode) {
    return _latinDigits(DateFormat('HH:mm', languageCode).format(value));
  }

  /// تكلفة التوصيل: مجاني فوق الحد، وإلا تُحسب من الثوابت.
  static double deliveryFeeFor(double subtotal) {
    if (subtotal >= AppConstants.freeDeliveryThreshold) {
      return 0;
    }
    return AppConstants.deliveryFee;
  }
}
