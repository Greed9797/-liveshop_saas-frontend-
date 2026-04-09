import 'package:flutter/material.dart';

import '../models/cabine.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
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

  ({Color background, Color border, Color accent}) get _palette {
    switch (widget.cabine.status) {
      case 'ao_vivo':
        return (
          background: AppColors.successGreen.withValues(alpha: 0.08),
          border: AppColors.successGreen.withValues(alpha: 0.45),
          accent: AppColors.successGreen,
        );
      case 'reservada':
        return (
          background: AppColors.warningYellow.withValues(alpha: 0.12),
          border: AppColors.warningYellow.withValues(alpha: 0.45),
          accent: AppColors.warningYellow,
        );
      case 'ativa':
        return (
          background: AppColors.infoBlue.withValues(alpha: 0.10),
          border: AppColors.infoBlue.withValues(alpha: 0.45),
          accent: AppColors.infoBlue,
        );
      case 'manutencao':
        return (
          background: AppColors.dangerRed.withValues(alpha: 0.08),
          border: AppColors.dangerRed.withValues(alpha: 0.35),
          accent: AppColors.dangerRed,
        );
      default:
        return (
          background: AppColors.white,
          border: AppColors.gray200,
          accent: AppColors.gray400,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final shortContrato = widget.cabine.contratoId == null
        ? 'Sem contrato'
        : 'Contrato ${widget.cabine.contratoId!.substring(0, 8)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color:
                  widget.isSelected ? AppColors.primaryOrange : palette.border,
              width: widget.isSelected ? 2 : 1.2,
            ),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header: Título + Pulse dot ──
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cabine ${widget.cabine.numero.toString().padLeft(2, '0')}',
                      style: AppTypography.h3.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_isLive)
                    FadeTransition(
                      opacity: _pulse,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.dangerRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Badge de status ──
              StatusBadge(status: widget.cabine.status),
              const SizedBox(height: 12),

              // ── Cliente ──
              Text(
                widget.cabine.clienteNome ?? 'Sem cliente vinculado',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),

              // ── Contrato ──
              Text(
                shortContrato,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption
                    .copyWith(color: AppColors.gray500, fontSize: 11),
              ),

              // ── Apresentador (condicional) ──
              if (widget.cabine.apresentadorNome != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.cabine.apresentadorNome!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.gray500, fontSize: 11),
                ),
              ],

              // ── Spacer flexível para empurrar métricas para baixo ──
              const Spacer(),

              // ── Métricas ao vivo OU hint de ação ──
              if (_isLive) ...[
                const Divider(height: 16, color: AppColors.gray200),
                Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined,
                        size: 14, color: palette.accent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${widget.cabine.viewerCount} espectadores',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'GMV R\$ ${widget.cabine.gmvAtual.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.successGreen, fontWeight: FontWeight.w700),
                ),
              ] else ...[
                const Divider(height: 16, color: AppColors.gray200),
                Row(
                  children: [
                    Icon(Icons.chevron_right_rounded,
                        size: 16, color: palette.accent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.isSelectable
                            ? 'Pronto para vincular'
                            : 'Toque para detalhes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.gray400, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
