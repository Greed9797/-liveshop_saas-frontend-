import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_typography.dart';

class AuditoriaStatusBadge extends StatelessWidget {
  final String status;
  const AuditoriaStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'em_analise' => ('Em Análise', AppColors.warningYellow),
      'pendencia_comercial' => ('Pendência', AppColors.warningYellow),
      'reprovado' => ('Restrição', AppColors.dangerRed),
      'ativo' || 'aprovado' => ('Aprovado', AppColors.successGreen),
      'arquivado' => ('Arquivado', AppColors.textSecondary),
      _ => (status, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
