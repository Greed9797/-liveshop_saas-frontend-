import 'package:flutter/material.dart';
import '../theme/app_colors_extension.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.lg;
    final resolvedBorderRadius = BorderRadius.circular(radius);
    final colors = context.colors;

    final container = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.cardBackground,
        borderRadius: resolvedBorderRadius,
        border: Border.all(
          color: borderColor ?? colors.cardBorder,
          width: 1,
        ),
        boxShadow: boxShadow ?? AppShadows.md,
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: resolvedBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: resolvedBorderRadius,
          child: container,
        ),
      );
    }
    return container;
  }
}
