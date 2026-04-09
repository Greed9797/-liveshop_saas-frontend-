import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryOrange,
    primary: AppColors.primaryOrange,
    surface: AppColors.surfaceWhite,
    onSurface: AppColors.black,
    error: AppColors.dangerRed,
  ),
  scaffoldBackgroundColor: AppColors.surfaceGray,

  // Base text theme mapping
  textTheme: GoogleFonts.interTextTheme().copyWith(
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

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.white,
    foregroundColor: AppColors.gray900,
    elevation: 0,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
  ),

  cardTheme: CardThemeData(
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.gray200, width: 1),
    ),
    color: AppColors.white,
  ),

  drawerTheme: const DrawerThemeData(
    backgroundColor: AppColors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
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
        borderRadius: BorderRadius.circular(10),
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
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle:
          AppTypography.buttonText.copyWith(color: AppColors.primaryOrange),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.gray200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.gray200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.dangerRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.5),
    ),
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  dialogTheme: DialogThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    backgroundColor: AppColors.white,
    elevation: 0,
  ),
);
