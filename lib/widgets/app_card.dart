import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

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

    final container = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.bgCard,
        borderRadius: resolvedBorderRadius,
        border: Border.all(
          color: borderColor ?? AppColors.borderLight,
          width: 1,
        ),
        boxShadow: boxShadow ?? AppShadows.md,
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.x6),
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
          hoverColor: AppColors.primary.withValues(alpha: 0.04),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          child: container,
        ),
      );
    }
    return container;
  }
}
