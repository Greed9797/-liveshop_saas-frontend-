import 'app_breakpoints.dart';

/// Design spacing tokens — base unit: 4px
/// xs=4, sm=8, md=12, lg=16, xl=20, x2l=24, x3l=32, x4l=40
class AppSpacing {
  // Base units
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double x2l = 24.0;
  static const double x3l = 32.0;
  static const double x4l = 40.0;

  // Semantic aliases
  static const double cardPadding = x2l; // 24 — cards principais
  static const double compactPadding = md; // 12 — cards menores, list items
  static const double screenPadding = x2l; // 24 — todas as telas
  static const double sectionGap = xl; // 20 — entre seções
  static const double cardGap = lg; // 16 — entre cards no grid
  static const double inlineGap = sm; // 8 — entre ícone e texto

  /// Returns responsive screen padding based on [availableWidth] (logical pixels,
  /// typically from [MediaQuery.sizeOf(context).width] or [BoxConstraints.maxWidth]).
  static double responsive(double width) =>
      width >= AppBreakpoints.wide
          ? 32.0
          : width >= AppBreakpoints.desktop
              ? 24.0
              : width >= AppBreakpoints.tablet
                  ? 20.0
                  : 16.0;
}
