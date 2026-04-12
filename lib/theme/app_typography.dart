import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // ── Headings ──
  static final TextStyle h1 = GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.56,
  );

  static final TextStyle h2 = GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.22,
  );

  static final TextStyle h3 = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  // ── KPI / Large numbers ──
  static final TextStyle heroNumber = GoogleFonts.outfit(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.08,
  );

  static final TextStyle kpiNumber = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.96,
  );

  // ── Body ──
  static final TextStyle bodyLarge = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static final TextStyle bodyMedium = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static final TextStyle bodySmall = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Labels / Captions ──
  static final TextStyle caption = GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.24,
  );

  static final TextStyle labelLarge = GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  static final TextStyle labelSmall = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );

  // ── Button ──
  static final TextStyle buttonText = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}
