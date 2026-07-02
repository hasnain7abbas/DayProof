import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextTheme theme() {
    final base = ThemeData.dark().textTheme.apply(
      fontFamily: 'PlusJakartaSans',
    );
    return base.copyWith(
      displaySmall: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: AppColors.textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        height: 1.05,
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: AppColors.textPrimary,
        fontSize: 26,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: AppColors.textPrimary,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: AppColors.textSecondary,
        fontSize: 14,
        height: 1.45,
      ),
      labelLarge: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
