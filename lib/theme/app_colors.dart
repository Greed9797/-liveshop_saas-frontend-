import 'package:flutter/material.dart';

class AppColors {
  // ── Brand primary (mode-independent, used in const contexts) ──
  static const Color primaryOrange = Color(0xFFD7582D);
  static const Color primaryOrangeLight = Color(0xFFFFF0E8);

  // ── Orange palette (for gradients, const contexts) ──
  static const Color orange50  = Color(0xFFFFF0E8);
  static const Color orange100 = Color(0xFFFDDDD0);
  static const Color orange200 = Color(0xFFF09070);
  static const Color orange500 = Color(0xFFD7582D);
  static const Color orange600 = Color(0xFFC14E27);

  // ── Semantic base hues (mode-independent — light/dark variants are in AppColorsExtension) ──
  static const Color successGreen  = Color(0xFF22C55E);
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color dangerRed     = Color(0xFFEF4444);
  static const Color infoPurple    = Color(0xFF8B5CF6);  // fixed: was incorrectly #E8673C
  static const Color infoBlue      = Color(0xFF3B82F6);

  // ── Medal colors (ranking, mode-independent) ──
  static const Color medalGold   = Color(0xFFFFD700);
  static const Color medalSilver = Color(0xFFC0C0C0);
  static const Color medalBronze = Color(0xFFCD7F32);

  // ── Legacy aliases (kept for gradual migration, point to new values) ──
  static const Color primary       = primaryOrange;
  static const Color black         = Color(0xFF1A1A1A);
  static const Color white         = Color(0xFFFFFFFF);
  static const Color surfaceGray   = Color(0xFFFAF8F6);
  static const Color surfaceDivider = Color(0x0F000000);
  static const Color surfaceWhite  = white;
  static const Color textPrimary   = black;
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color surface       = white;
  static const Color background    = surfaceGray;
  static const Color darkNavy      = black;
  static const Color darkNavySurface = black;
  static const Color darkNavyLight = Color(0xFF333333);
  static const Color textOnDark    = white;
  static const Color textOnOrange  = white;
  static const Color danger        = dangerRed;
  static const Color success       = successGreen;
  static const Color warning       = warningYellow;
  static const Color info          = infoBlue;
  static const Color lilac         = infoPurple;

  // ── Gray scale (Tailwind-style — kept for const contexts during migration) ──
  static const Color gray50  = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // ── Sidebar (light mode defaults — widgets should prefer context.colors) ──
  static const Color sidebarBg          = surfaceGray;
  static const Color sidebarBorder      = gray200;
  static const Color sidebarItemHover   = gray50;
  static const Color sidebarItemActive  = Color(0x1FD7582D);
}
