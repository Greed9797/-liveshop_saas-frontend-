import 'package:flutter/material.dart';

/// Stripe-inspired shadow system — dual layer, very low alpha
class AppShadows {
  // Small shadow
  static const List<BoxShadow> sm = [
    const BoxShadow(
      color: Color(0x08000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  // Medium shadow
  static const List<BoxShadow> md = [
    const BoxShadow(
      color: Color(0x08000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
    const BoxShadow(
      color: Color(0x05000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  // Large shadow
  static const List<BoxShadow> lg = [
    const BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    const BoxShadow(
      color: Color(0x05000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // Extra large shadow
  static const List<BoxShadow> xl = [
    const BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    const BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  // No shadow
  static const List<BoxShadow> none = [];
}
