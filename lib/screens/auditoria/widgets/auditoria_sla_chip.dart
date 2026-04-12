import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_typography.dart';

class AuditoriaSlaChip extends StatelessWidget {
  final int? hours;
  const AuditoriaSlaChip({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
    if (hours == null) return const SizedBox.shrink();

    final color = hours! >= 24
        ? context.colors.error
        : hours! >= 12
            ? context.colors.primary
            : context.colors.textSecondary;

    final bg = hours! >= 24
        ? context.colors.error.withValues(alpha: 0.12)
        : hours! >= 12
            ? context.colors.primary.withValues(alpha: 0.12)
            : context.colors.textPrimary.withValues(alpha: 0.05);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '⏳ ${hours}h',
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
