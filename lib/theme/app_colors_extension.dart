import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.cardBackground,
    required this.cardBorder,
    required this.sidebarBg,
    required this.sidebarActiveBg,
    required this.sidebarActiveText,
    required this.sidebarInactiveText,
    required this.sidebarHover,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.primary,
    required this.primaryHover,
    required this.primaryLightBg,
    required this.divider,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.tooltipBg,
    required this.tooltipText,
    required this.progressBg,
    required this.inputFill,
    required this.inputBorder,
    required this.inputFocusBorder,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color cardBackground;
  final Color cardBorder;
  final Color sidebarBg;
  final Color sidebarActiveBg;
  final Color sidebarActiveText;
  final Color sidebarInactiveText;
  final Color sidebarHover;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color primary;
  final Color primaryHover;
  final Color primaryLightBg;
  final Color divider;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final Color tooltipBg;
  final Color tooltipText;
  final Color progressBg;
  final Color inputFill;
  final Color inputBorder;
  final Color inputFocusBorder;

  factory AppColorsExtension.light() => const AppColorsExtension(
        background: Color(0xFFFAF8F6),
        surface: Color(0xFFFFFFFF),
        surfaceElevated: Color(0xFFF5F3F1),
        cardBackground: Color(0xFFFFFFFF),
        cardBorder: Color(0x0F000000),
        sidebarBg: Color(0xFFFAF8F6),
        sidebarActiveBg: Color(0x1FD7582D),
        sidebarActiveText: Color(0xFFD7582D),
        sidebarInactiveText: Color(0xFF6B6B6B),
        sidebarHover: Color(0x0A000000),
        textPrimary: Color(0xFF1A1A1A),
        textSecondary: Color(0xFF6B6B6B),
        textTertiary: Color(0xFF9B9B9B),
        primary: Color(0xFFD7582D),
        primaryHover: Color(0xFFC14E27),
        primaryLightBg: Color(0x14D7582D),
        divider: Color(0x0F000000),
        success: Color(0xFF22C55E),
        error: Color(0xFFEF4444),
        warning: Color(0xFFF59E0B),
        info: Color(0xFF3B82F6),
        tooltipBg: Color(0xE61A1A1A),
        tooltipText: Color(0xFFFFFFFF),
        progressBg: Color(0x0F000000),
        inputFill: Color(0xFFFFFFFF),
        inputBorder: Color(0xFFE5E7EB),
        inputFocusBorder: Color(0xFFD7582D),
      );

  factory AppColorsExtension.dark() => const AppColorsExtension(
        background: Color(0xFF0A0A0A),
        surface: Color(0xFF1A1A1A),
        surfaceElevated: Color(0xFF242424),
        cardBackground: Color(0xFF1A1A1A),
        cardBorder: Color(0x0FFFFFFF),
        sidebarBg: Color(0xFF0F0F0F),
        sidebarActiveBg: Color(0x26D7582D),
        sidebarActiveText: Color(0xFFD7582D),
        sidebarInactiveText: Color(0xFF707070),
        sidebarHover: Color(0x0AFFFFFF),
        textPrimary: Color(0xFFF5F5F5),
        textSecondary: Color(0xFFA0A0A0),
        textTertiary: Color(0xFF666666),
        primary: Color(0xFFD7582D),
        primaryHover: Color(0xFFE5633A),
        primaryLightBg: Color(0x1FD7582D),
        divider: Color(0x0FFFFFFF),
        success: Color(0xFF4ADE80),
        error: Color(0xFFF87171),
        warning: Color(0xFFFBBF24),
        info: Color(0xFF60A5FA),
        tooltipBg: Color(0xE6F5F5F5),
        tooltipText: Color(0xFF1A1A1A),
        progressBg: Color(0x14FFFFFF),
        inputFill: Color(0xFF1A1A1A),
        inputBorder: Color(0xFF333333),
        inputFocusBorder: Color(0xFFD7582D),
      );

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? cardBackground,
    Color? cardBorder,
    Color? sidebarBg,
    Color? sidebarActiveBg,
    Color? sidebarActiveText,
    Color? sidebarInactiveText,
    Color? sidebarHover,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? primary,
    Color? primaryHover,
    Color? primaryLightBg,
    Color? divider,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    Color? tooltipBg,
    Color? tooltipText,
    Color? progressBg,
    Color? inputFill,
    Color? inputBorder,
    Color? inputFocusBorder,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      sidebarBg: sidebarBg ?? this.sidebarBg,
      sidebarActiveBg: sidebarActiveBg ?? this.sidebarActiveBg,
      sidebarActiveText: sidebarActiveText ?? this.sidebarActiveText,
      sidebarInactiveText: sidebarInactiveText ?? this.sidebarInactiveText,
      sidebarHover: sidebarHover ?? this.sidebarHover,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryLightBg: primaryLightBg ?? this.primaryLightBg,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      tooltipBg: tooltipBg ?? this.tooltipBg,
      tooltipText: tooltipText ?? this.tooltipText,
      progressBg: progressBg ?? this.progressBg,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      inputFocusBorder: inputFocusBorder ?? this.inputFocusBorder,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      sidebarBg: Color.lerp(sidebarBg, other.sidebarBg, t)!,
      sidebarActiveBg: Color.lerp(sidebarActiveBg, other.sidebarActiveBg, t)!,
      sidebarActiveText: Color.lerp(sidebarActiveText, other.sidebarActiveText, t)!,
      sidebarInactiveText: Color.lerp(sidebarInactiveText, other.sidebarInactiveText, t)!,
      sidebarHover: Color.lerp(sidebarHover, other.sidebarHover, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryLightBg: Color.lerp(primaryLightBg, other.primaryLightBg, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      tooltipBg: Color.lerp(tooltipBg, other.tooltipBg, t)!,
      tooltipText: Color.lerp(tooltipText, other.tooltipText, t)!,
      progressBg: Color.lerp(progressBg, other.progressBg, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputFocusBorder: Color.lerp(inputFocusBorder, other.inputFocusBorder, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}
