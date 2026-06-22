import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextTheme theme() {
    final base = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    );
    return base.copyWith(
      displaySmall: GoogleFonts.plusJakartaSans(
        color: AppColors.textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        height: 1.05,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        color: AppColors.textPrimary,
        fontSize: 26,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.textPrimary,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        color: AppColors.textSecondary,
        fontSize: 14,
        height: 1.45,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
