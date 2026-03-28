import 'package:flutter/material.dart';

/// Paleta de cores e ThemeData global do LiveShop SaaS
class AppColors {
  static const primary = Color(0xFF7F77DD);       // roxo
  static const success = Color(0xFF1D9E75);        // verde
  static const danger  = Color(0xFFE24B4A);        // vermelho
  static const warning = Color(0xFFBA7517);        // âmbar
  static const info    = Color(0xFF378ADD);        // azul
  static const lilac   = Color(0xFFAFA9EC);        // lilás recomendação
  static const bgLight = Color(0xFFF5F5F7);        // fundo cinza claro
  static const cardBg  = Colors.white;
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.bgLight,
    cardTheme: const CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400),
      labelMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
    ),
    useMaterial3: true,
  );
}
