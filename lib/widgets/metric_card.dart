import 'package:flutter/material.dart';
import '../design_system/design_system.dart' hide AppCard;
import 'app_card.dart';

/// Premium KPI metric card — redesigned per Figma instructions
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;
  final bool? deltaPositive;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.deltaPositive,
    this.subtitle,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.x5),
      boxShadow: AppShadows.sm,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.colors.bgMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: iconColor ?? AppColors.primary,
                  ),
                ),
              if (icon != null) const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: AppTypography.h2.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ),
              if (delta != null || subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    delta ?? subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: delta != null
                          ? ((deltaPositive ?? true) ? AppColors.success : AppColors.danger)
                          : context.colors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
