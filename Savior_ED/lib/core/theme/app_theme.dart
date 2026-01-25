import 'package:flutter/material.dart';
import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';

/// Application theme configuration
class AppTheme {
  // Modern font family - using system default with fallback
  static const String _fontFamily = 'Roboto';

  // Helper to resolve color scheme
  static Color _getSchemeColor(String scheme) {
    switch (scheme) {
      case 'blue':
        return const Color(0xFF2196F3);
      case 'green':
        return AppColors.primary; // 0xFF4CAF50
      case 'purple':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  static ThemeData lightTheme(String scheme) {
    final primaryColor = _getSchemeColor(scheme);

    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        // ... (Keep text styles as is, or updated if needed, but for now just structure)
        displayLarge: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: AppSizes.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.textDisabled),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.textDisabled),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingMedium,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),

          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: AppSizes.paddingMedium,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: AppSizes.paddingMedium,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
    );
  }

  static ThemeData darkTheme(String scheme) {
    final primaryColor = _getSchemeColor(scheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor, // Ensure primary is set
        surface: const Color(0xFF1E1E1E), // Explicit dark surface
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: AppSizes.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      // Add more dark theme customizations if needed
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
    );
  }
}
