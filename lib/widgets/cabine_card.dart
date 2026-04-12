import 'package:flutter/material.dart';

import '../models/cabine.dart';
import '../theme/theme.dart';
import 'status_badge.dart';

class CabineCard extends StatefulWidget {
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

  @override
  State<CabineCard> createState() => _CabineCardState();
}

class _CabineCardState extends State<CabineCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  bool get _isLive => widget.cabine.status == 'ao_vivo';

  Color _accentColor(BuildContext context) {
    return switch (widget.cabine.status) {
      'ao_vivo' => context.colors.success,
      'reservada' => context.colors.warning,
      'ativa' => context.colors.info,
      'manutencao' => context.colors.error,
      _ => context.colors.textTertiary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = _accentColor(context);
    final cab = widget.cabine;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: accent, width: 4),
            top: BorderSide(
              color: widget.isSelected ? colors.primary : colors.divider,
              width: widget.isSelected ? 2 : 1,
            ),
            right: BorderSide(
              color: widget.isSelected ? colors.primary : colors.divider,
              width: widget.isSelected ? 2 : 1,
            ),
            bottom: BorderSide(
              color: widget.isSelected ? colors.primary : colors.divider,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header: título + pulse dot ──
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cabine ${cab.numero.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isLive)
                  FadeTransition(
                    opacity: _pulse,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: colors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // ── Status badge ──
            StatusBadge(status: cab.status),
            const SizedBox(height: 10),

            // ── Cliente ──
            Text(
              cab.clienteNome ?? 'Sem cliente vinculado',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // ── Contrato ──
            if (cab.contratoId != null) ...[
              const SizedBox(height: 2),
              Text(
                'Contrato ${cab.contratoId!.substring(0, 8)}',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // ── Apresentador ──
            if (cab.apresentadorNome != null) ...[
              const SizedBox(height: 2),
              Text(
                cab.apresentadorNome!,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // ── Métricas ao vivo ──
            if (_isLive) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.remove_red_eye_outlined,
                      size: 13, color: accent),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${cab.viewerCount} espectadores',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'GMV R\$ ${cab.gmvAtual.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.success,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              // ── Hint ──
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.chevron_right_rounded,
                      size: 14, color: accent),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.isSelectable
                          ? 'Pronto para vincular'
                          : 'Toque para detalhes',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
