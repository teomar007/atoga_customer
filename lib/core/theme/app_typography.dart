import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// خطوط التطبيق: Cairo للعربية، Poppins للفرنسية.
abstract final class AppTypography {
  const AppTypography._();

  static TextTheme arabic() => _base(GoogleFonts.cairoTextTheme());

  static TextTheme french() => _base(GoogleFonts.poppinsTextTheme());

  static TextTheme _base(TextTheme source) {
    return source.copyWith(
      displaySmall: source.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF212121),
      ),
      headlineSmall: source.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF212121),
      ),
      titleLarge: source.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF212121),
      ),
      titleMedium: source.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF212121),
      ),
      titleSmall: source.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF212121),
      ),
      bodyLarge: source.bodyLarge?.copyWith(color: const Color(0xFF212121)),
      bodyMedium: source.bodyMedium?.copyWith(color: const Color(0xFF212121)),
      bodySmall: source.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
      labelLarge: source.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
