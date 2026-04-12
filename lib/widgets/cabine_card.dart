import 'package:flutter/material.dart';

import '../models/cabine.dart';
import '../theme/theme.dart';

/// Card de cabine usando padrão canônico Material+InkWell.
/// Evita bugs do Flutter Web CanvasKit com Container(decoration)+Expanded.
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

  Color _statusColor(BuildContext context) => switch (cabine.status) {
        'ao_vivo' => context.colors.success,
        'reservada' => context.colors.warning,
        'ativa' => context.colors.info,
        'manutencao' => context.colors.error,
        _ => context.colors.textTertiary,
      };

  String _statusLabel() => switch (cabine.status) {
        'ao_vivo' => 'AO VIVO',
        'reservada' => 'RESERVADA',
        'ativa' => 'ATIVA',
        'manutencao' => 'MANUTENÇÃO',
        'disponivel' => 'DISPONÍVEL',
        _ => cabine.status.toUpperCase(),
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = _statusColor(context);
    final isLive = cabine.status == 'ao_vivo';
    final borderColor = isSelected ? colors.primary : colors.divider;
    final borderWidth = isSelected ? 2.0 : 1.0;

    return Material(
      color: colors.cardBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      child: InkWell(
        onTap: onTap,
        hoverColor: colors.primary.withValues(alpha: 0.04),
        splashColor: colors.primary.withValues(alpha: 0.08),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent line à esquerda (substitui Border(left: 4))
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
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
                    // Contrato
                    if (cabine.contratoId != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Contrato ${cabine.contratoId!.substring(0, 8)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Apresentador (se ao vivo)
                    if (isLive && cabine.apresentadorNome != null) ...[
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
                    // GMV + audiência (se ao vivo)
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
            ),
          ],
        ),
      ),
    );
  }
}
