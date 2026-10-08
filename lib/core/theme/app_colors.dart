import 'package:flutter/material.dart';

/// لوحة ألوان ATOGA MARKET — Material Design 3 / Flat / Minimalist.
abstract final class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFFC62828);
  static const Color primaryLight = Color(0xFFFF6659);
  static const Color accent = Color(0xFFFFB300);
  static const Color accentDark = Color(0xFFE09400);

  // Surfaces
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F3F5);
  static const Color divider = Color(0xFFE9ECEF);

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFB6BCC3);
  static const Color onPrimary = Colors.white;

  // Semantic
  static const Color success = Color(0xFF15A05A);
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFE53935);
  static const Color info = Color(0xFF2F80ED);

  // Shadows (خفيفة للحفاظ على الطابع المسطح)
  static const Color shadow = Color(0x14000000);
}
