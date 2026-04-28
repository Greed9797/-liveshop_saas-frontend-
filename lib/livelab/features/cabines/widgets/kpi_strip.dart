import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';
import '../../../theme/livelab_theme.dart';
import '../cabines_models.dart';

class KpiStrip extends StatelessWidget {
  const KpiStrip({super.key, required this.cabins});

  final List<Cabin> cabins;

  @override
  Widget build(BuildContext context) {
    final live = cabins.where((c) => c.status == CabinStatus.live).toList();
    final reserved = cabins.where((c) => c.status == CabinStatus.busy).length;
    final free = cabins.where((c) => c.status == CabinStatus.free).length;
    final gmvTotal = live.fold(0.0, (s, c) => s + c.gmv);
    final audienceTotal = live.fold(0, (s, c) => s + c.views);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiTile(
                label: 'Cabines mapeadas',
                value: '${cabins.length}',
                sub: 'Total alocado na unidade',
                accent: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _KpiLive(live: live.length)),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiTile(
                label: 'Reservadas',
                value: '$reserved',
                sub: 'aguardando ativação',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiTile(
                label: 'Livres',
                value: '$free',
                sub: 'prontas para receber',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _KpiGmv(gmv: gmvTotal, liveCount: live.length)),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiTile(
                label: 'Audiência simultânea',
                value: '$audienceTotal',
                sub: '${live.length} live${live.length != 1 ? 's' : ''} conectada${live.length != 1 ? 's' : ''}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.sub,
    this.accent = false,
  });

  final String label;
  final String value;
  final String sub;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: t.bgElev1,
        borderRadius: BorderRadius.circular(LlRadius.xl),
        border: accent
            ? Border(
                top: BorderSide(color: t.primary, width: 2),
                left: BorderSide(color: t.border),
                right: BorderSide(color: t.border),
                bottom: BorderSide(color: t.border),
              )
            : Border.all(color: t.border),
        boxShadow: t.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.12,
              color: t.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.025,
              height: 1.1,
              color: t.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: t.textMuted),
          ),
        ],
      ),
    );
  }
}

class _KpiLive extends StatelessWidget {
  const _KpiLive({required this.live});

  final int live;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: t.bgElev1,
        borderRadius: BorderRadius.circular(LlRadius.xl),
        border: Border.all(color: t.border),
        boxShadow: t.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'AO VIVO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.12,
                  color: t.textMuted,
                ),
              ),
              const Spacer(),
              _LiveBadge(t: t),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$live',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.025,
              height: 1.1,
              color: t.success,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'sessões em andamento',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: t.textMuted),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.t});
  final LlTokens t;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: t.successSoft,
        borderRadius: BorderRadius.circular(LlRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(color: t.success),
          const SizedBox(width: 5),
          Text(
            'LIVE',
            style: TextStyle(
              color: t.success,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.06,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiGmv extends StatelessWidget {
  const _KpiGmv({required this.gmv, required this.liveCount});

  final double gmv;
  final int liveCount;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.primary.withValues(alpha: 0.08), t.bgElev1],
        ),
        borderRadius: BorderRadius.circular(LlRadius.xl),
        border: Border.all(color: t.border),
        boxShadow: t.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'GMV TOTAL HOJE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.12,
              color: t.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            gmv >= 1000
                ? 'R\$ ${(gmv / 1000).toStringAsFixed(1)}k'
                : 'R\$ ${gmv.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.025,
              height: 1.1,
              color: t.primary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'soma do que está no ar · $liveCount live${liveCount != 1 ? 's' : ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: t.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing dot ───────────────────────────────────────────────────────────────

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
