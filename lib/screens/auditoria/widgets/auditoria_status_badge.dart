import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_typography.dart';

class AuditoriaStatusBadge extends StatelessWidget {
  final String status;
  const AuditoriaStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'em_analise' => ('Em Análise', context.colors.warning),
      'pendencia_comercial' => ('Pendência', context.colors.warning),
      'reprovado' => ('Restrição', context.colors.error),
      'ativo' || 'aprovado' => ('Aprovado', context.colors.success),
      'arquivado' => ('Arquivado', context.colors.textSecondary),
      _ => (status, context.colors.textSecondary),
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
