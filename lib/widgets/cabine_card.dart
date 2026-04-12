import 'package:flutter/material.dart';

import '../models/cabine.dart';
import '../theme/theme.dart';

/// Card simples de cabine — estrutura minimalista, zero widgets que escondem
/// conteúdo (sem Opacity/Visibility/ClipRect/Stack/FittedBox/Spacer).
class CabineCard extends StatelessWidget {
  final Cabine cabine;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isSelectable;

  const CabineCard({
    super.key,
    required this.cabine,
    this.onTap,
    this.isSelected = false,
    this.isSelectable = false,
  });

  Color _statusColor(BuildContext context) {
    return switch (cabine.status) {
      'ao_vivo' => context.colors.success,
      'reservada' => context.colors.warning,
      'ativa' => context.colors.info,
      'manutencao' => context.colors.error,
      _ => context.colors.textTertiary,
    };
  }

  String _statusLabel() {
    return switch (cabine.status) {
      'ao_vivo' => 'AO VIVO',
      'reservada' => 'RESERVADA',
      'ativa' => 'ATIVA',
      'manutencao' => 'MANUTENÇÃO',
      'disponivel' => 'DISPONÍVEL',
      _ => cabine.status.toUpperCase(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = _statusColor(context);
    final isLive = cabine.status == 'ao_vivo';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: accent, width: 4),
            top: BorderSide(
                color: isSelected ? colors.primary : colors.divider,
                width: isSelected ? 2 : 1),
            right: BorderSide(
                color: isSelected ? colors.primary : colors.divider,
                width: isSelected ? 2 : 1),
            bottom: BorderSide(
                color: isSelected ? colors.primary : colors.divider,
                width: isSelected ? 2 : 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Text(
              'Cabine ${cabine.numero.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Status badge inline (sem StatusBadge widget externo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _statusLabel(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Cliente
            Text(
              cabine.clienteNome ?? 'Sem cliente vinculado',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Apresentador (opcional)
            if (cabine.apresentadorNome != null) ...[
              const SizedBox(height: 2),
              Text(
                cabine.apresentadorNome!,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // GMV se ao vivo
            if (isLive) ...[
              const SizedBox(height: 6),
              Text(
                'GMV R\$ ${cabine.gmvAtual.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.success,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${cabine.viewerCount} espectadores',
                style: TextStyle(
                  fontSize: 10,
                  color: colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
