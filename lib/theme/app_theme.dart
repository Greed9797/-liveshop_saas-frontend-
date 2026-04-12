import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_colors_extension.dart';
import 'app_typography.dart';

final ThemeData lightTheme = _buildTheme(Brightness.light);
final ThemeData darkTheme = _buildTheme(Brightness.dark);

/// Keep backward compatibility — points to lightTheme
final ThemeData appTheme = lightTheme;

ThemeData _buildTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final ext = isLight ? AppColorsExtension.light() : AppColorsExtension.dark();

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    extensions: [ext],

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryOrange,
      brightness: brightness,
      primary: AppColors.primaryOrange,
      surface: isLight ? const Color(0xFFFAF8F6) : const Color(0xFF0A0A0A),
      onSurface: isLight ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      error: AppColors.dangerRed,
    ),

    scaffoldBackgroundColor:
        isLight ? const Color(0xFFFAF8F6) : const Color(0xFF0A0A0A),

    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      displayLarge:  AppTypography.h1,
      displayMedium: AppTypography.h2,
      displaySmall:  AppTypography.h3,
      bodyLarge:     AppTypography.bodyLarge,
      bodyMedium:    AppTypography.bodyMedium,
      bodySmall:     AppTypography.bodySmall,
      labelLarge:    AppTypography.labelLarge,
      labelMedium:   AppTypography.caption,
      labelSmall:    AppTypography.labelSmall,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: isLight ? const Color(0xFFFAF8F6) : const Color(0xFF0F0F0F),
      foregroundColor: isLight ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLight
              ? const Color(0x0F000000)
              : const Color(0x0FFFFFFF),
          width: 1,
        ),
      ),
      color: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
    ),

    drawerTheme: DrawerThemeData(
      backgroundColor: isLight ? const Color(0xFFFAF8F6) : const Color(0xFF0F0F0F),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTypography.buttonText,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryOrange,
        side: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTypography.buttonText,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isLight ? const Color(0xFFE5E7EB) : const Color(0xFF333333),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isLight ? const Color(0xFFE5E7EB) : const Color(0xFF333333),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryOrange,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dangerRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.5),
      ),
      filled: true,
      fillColor: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
      elevation: 0,
    ),

    dividerTheme: DividerThemeData(
      color: isLight ? const Color(0x0F000000) : const Color(0x0FFFFFFF),
      thickness: 1,
      space: 1,
    ),

    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: BorderSide(
        color: isLight ? const Color(0xFFE5E7EB) : const Color(0xFF333333),
      ),
    ),
  );
}
