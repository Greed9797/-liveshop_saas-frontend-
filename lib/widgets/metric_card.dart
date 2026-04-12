import 'package:flutter/material.dart';
import '../theme/app_colors_extension.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';

/// Premium KPI metric card — label / number / optional trend
class MetricCard extends StatelessWidget {
  final String label;
  final String value;

  /// Optional delta text, e.g. "+12%" or "-3 pts"
  final String? delta;

  /// When true the delta is rendered in success color; false = error color.
  /// Null hides the delta row entirely (same as omitting [delta]).
  final bool? deltaPositive;

  /// Legacy subtitle field kept for backward compatibility.
  final String? subtitle;

  // Legacy params kept for call-site compatibility (not rendered in new layout)
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
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl), // 20 px
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Label ────────────────────────────────────────────────
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              fontSize: 11,
              color: colors.textSecondary,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // ── Value ────────────────────────────────────────────────
          Text(
            value,
            style: AppTypography.heroNumber.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),

          // ── Delta / trend ────────────────────────────────────────
          if (delta != null) ...[
            const SizedBox(height: 4),
            Text(
              delta!,
              style: AppTypography.caption.copyWith(
                color: (deltaPositive ?? true) ? colors.success : colors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
