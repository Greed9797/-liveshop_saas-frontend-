import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';
import '../../../theme/livelab_theme.dart';
import '../cabines_models.dart';

class CabinCard extends StatelessWidget {
  const CabinCard({
    super.key,
    required this.cabin,
    this.selected = false,
    this.onTap,
  });

  final Cabin cabin;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return switch (cabin.status) {
      CabinStatus.live => _LiveCard(cabin: cabin, selected: selected, onTap: onTap),
      CabinStatus.busy => _ReservedCard(cabin: cabin, selected: selected, onTap: onTap),
      CabinStatus.free => _AvailableCard(cabin: cabin, selected: selected, onTap: onTap),
      CabinStatus.maint => _MaintCard(cabin: cabin),
    };
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _cabinName(LlTokens t, int number) {
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: '#',
          style: TextStyle(color: t.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        TextSpan(
          text: 'Cabine ${number.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: t.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01,
          ),
        ),
      ],
    ),
  );
}

Widget _badge(String label, Color bg, Color fg, {Widget? leading}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(LlRadius.pill)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading, const SizedBox(width: 6)],
        Text(
          label,
          style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.04),
        ),
      ],
    ),
  );
}

// ── Pulsing dot for live badge ────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.35, end: 1.0), weight: 50),
    ]).animate(_ctrl);
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(
          scale: _scale.value,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

// ── Live card ─────────────────────────────────────────────────────────────────

class _LiveCard extends StatelessWidget {
  final Cabin cabin;
  final bool selected;
  final VoidCallback? onTap;

  const _LiveCard({required this.cabin, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? t.bgElev1 : const Color(0xFFF3FBF6),
      borderRadius: BorderRadius.circular(LlRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: t.success.withValues(alpha: 0.04),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LlRadius.xl),
            border: Border(
              top: BorderSide(color: t.success, width: 2),
              left: BorderSide(
                color: selected ? t.success : t.success.withValues(alpha: 0.35),
                width: selected ? 2 : 1,
              ),
              right: BorderSide(
                color: selected ? t.success : t.success.withValues(alpha: 0.35),
                width: selected ? 2 : 1,
              ),
              bottom: BorderSide(
                color: selected ? t.success : t.success.withValues(alpha: 0.35),
                width: selected ? 2 : 1,
              ),
            ),
          ),
          padding: const EdgeInsets.all(LlSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _cabinName(t, cabin.number),
                  const Spacer(),
                  _badge(
                    'AO VIVO',
                    t.successSoft,
                    t.success,
                    leading: _PulsingDot(color: t.success),
                  ),
                ],
              ),
              const SizedBox(height: LlSpacing.md),
              Text(
                cabin.client ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: t.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.01,
                ),
              ),
              if (cabin.contract != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Contrato ${cabin.contract}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
              const SizedBox(height: 2),
              Text(
                cabin.presenter ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: t.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.only(top: LlSpacing.md),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: t.hairline)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _statCol(
                        t,
                        label: 'GMV',
                        value: 'R\$ ${(cabin.gmv / 1000).toStringAsFixed(1)}k',
                        color: t.success,
                      ),
                    ),
                    Container(width: 1, height: 30, color: t.hairline),
                    Expanded(
                      child: _statCol(
                        t,
                        label: 'Audiência',
                        value: cabin.views.toString(),
                        alignment: CrossAxisAlignment.end,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LlSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.stop_circle_outlined, size: 13, color: t.danger),
                  label: Text(
                    'Encerrar live',
                    style: TextStyle(
                      color: t.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: t.dangerSoft,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LlRadius.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCol(
    LlTokens t, {
    required String label,
    required String value,
    Color? color,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LlSpacing.sm),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            label,
            style: TextStyle(
              color: t.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color ?? t.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.01,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reserved card ─────────────────────────────────────────────────────────────

class _ReservedCard extends StatelessWidget {
  final Cabin cabin;
  final bool selected;
  final VoidCallback? onTap;

  const _ReservedCard({required this.cabin, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;

    return Material(
      color: t.bgElev1,
      borderRadius: BorderRadius.circular(LlRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: t.primary.withValues(alpha: 0.04),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LlRadius.xl),
            border: Border.all(
              color: selected ? t.primary : t.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: t.shadowCard,
          ),
          padding: const EdgeInsets.all(LlSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _cabinName(t, cabin.number),
                  const Spacer(),
                  _badge('RESERVADA', t.warningSoft, t.warning),
                ],
              ),
              const SizedBox(height: LlSpacing.md),
              if (cabin.client != null)
                Text(
                  cabin.client!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (cabin.contract != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Contrato ${cabin.contract}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
              if (cabin.presenter != null) ...[
                const SizedBox(height: 2),
                Text(
                  cabin.presenter!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: t.textSecondary, fontSize: 12),
                ),
              ],
              if (cabin.startsIn != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.only(top: LlSpacing.md),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: t.hairline)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inicia em',
                        style: TextStyle(
                          color: t.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cabin.startsIn!,
                        style: TextStyle(
                          color: t.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.01,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Available card ────────────────────────────────────────────────────────────

class _AvailableCard extends StatelessWidget {
  final Cabin cabin;
  final bool selected;
  final VoidCallback? onTap;

  const _AvailableCard({required this.cabin, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(LlRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: t.primary.withValues(alpha: 0.04),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LlRadius.xl),
            border: Border.all(
              color: selected ? t.primary : t.border,
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(LlSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _cabinName(t, cabin.number),
                  const Spacer(),
                  _badge('DISPONÍVEL', t.bgElev2, t.textMuted),
                ],
              ),
              const SizedBox(height: LlSpacing.md),
              Text(
                'Sem cliente vinculado',
                style: TextStyle(
                  color: t.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Pronta para ativação.',
                style: TextStyle(color: t.textMuted, fontSize: 12),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.link, size: 13, color: t.textSecondary),
                  label: Text(
                    'Vincular cliente',
                    style: TextStyle(
                      color: t.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: t.borderStrong),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LlRadius.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Maintenance card ──────────────────────────────────────────────────────────

class _MaintCard extends StatelessWidget {
  final Cabin cabin;
  const _MaintCard({required this.cabin});

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? t.warningSoft.withValues(alpha: 0.12) : const Color(0xFFFFFAF1);
    final borderColor = isDark ? t.warning.withValues(alpha: 0.3) : const Color(0xFFE8D3B8);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(LlRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LlRadius.xl),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.all(LlSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _cabinName(t, cabin.number),
                const Spacer(),
                _badge('MANUTENÇÃO', t.warningSoft, t.warning),
              ],
            ),
            const SizedBox(height: LlSpacing.md),
            Text(
              'Equipamento em revisão',
              style: TextStyle(
                color: t.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              cabin.maintenanceEta != null
                  ? 'Retorno previsto às ${cabin.maintenanceEta}'
                  : 'Retorno previsto em breve',
              style: TextStyle(color: t.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
