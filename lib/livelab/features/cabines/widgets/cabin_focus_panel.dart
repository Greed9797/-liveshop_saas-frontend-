import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';
import '../../../theme/livelab_theme.dart';
import '../cabines_models.dart';

class CabinFocusPanel extends StatelessWidget {
  const CabinFocusPanel({super.key, required this.cabin});

  final Cabin? cabin;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    final c = cabin;

    return Container(
      decoration: BoxDecoration(
        color: t.bgElev1,
        borderRadius: BorderRadius.circular(LlRadius.xl),
        border: Border.all(color: t.border),
        boxShadow: t.shadowCard,
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionLabel(t, 'Trilho operacional'),
          const SizedBox(height: 4),
          Text(
            'Cabine em foco',
            style: TextStyle(
              color: t.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.01,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Da fila de ativação ao raio-X da cabine, tudo aqui.',
            style: TextStyle(color: t.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (c == null) _empty(t) else _detail(t, c),
          const SizedBox(height: 12),
          _actions(t, c),
        ],
      ),
    );
  }

  Widget _empty(LlTokens t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bgElev2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Text(
        'Selecione uma cabine para ver os detalhes.',
        style: TextStyle(color: t.textMuted, fontSize: 13),
      ),
    );
  }

  Widget _detail(LlTokens t, Cabin c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.primarySofter,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Cabine ${c.number.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: t.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.02,
                ),
              ),
              const Spacer(),
              _statusBadge(t, c.status),
            ],
          ),
          const SizedBox(height: 12),
          if (c.status == CabinStatus.live) ...[
            _kv(t, 'Cliente', c.client ?? '—'),
            _kv(t, 'Contrato', c.contract ?? '—', mono: true),
            _kv(t, 'Apresentador', c.presenter ?? '—'),
            const SizedBox(height: 8),
            Divider(color: t.border, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GMV atual',
                        style: TextStyle(
                          color: t.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'R\$ ${c.gmv >= 1000 ? '${(c.gmv / 1000).toStringAsFixed(1)}k' : c.gmv.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: t.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.02,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audiência',
                        style: TextStyle(
                          color: t.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${c.views}',
                        style: TextStyle(
                          color: t.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.02,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else if (c.status == CabinStatus.busy) ...[
            _kv(t, 'Cliente', c.client ?? '—'),
            if (c.contract != null) _kv(t, 'Contrato', c.contract!, mono: true),
            if (c.presenter != null) _kv(t, 'Apresentador', c.presenter!),
            if (c.startsIn != null) ...[
              const SizedBox(height: 8),
              Divider(color: t.border, height: 1),
              const SizedBox(height: 8),
              _kv(t, 'Inicia em', c.startsIn!),
            ],
          ] else ...[
            Text(
              'Sem sessão ativa. Vincule um cliente para começar a operar esta cabine.',
              style: TextStyle(color: t.textMuted, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actions(LlTokens t, Cabin? c) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.bar_chart_rounded, size: 14, color: t.textSecondary),
            label: Text(
              'Ver analítico',
              style: TextStyle(color: t.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: t.borderStrong),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LlRadius.pill),
              ),
            ),
          ),
        ),
        if (c?.status == CabinStatus.live) ...[
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.stop_circle_outlined, size: 14, color: t.danger),
            label: Text(
              'Encerrar',
              style: TextStyle(color: t.danger, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              backgroundColor: t.dangerSoft,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LlRadius.pill),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _kv(LlTokens t, String label, String value, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: t.textMuted, fontSize: 13)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: t.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(LlTokens t, CabinStatus status) {
    final (label, bg, fg) = switch (status) {
      CabinStatus.live => ('AO VIVO', t.successSoft, t.success),
      CabinStatus.busy => ('RESERVADA', t.warningSoft, t.warning),
      CabinStatus.free => ('DISPONÍVEL', t.bgElev2, t.textMuted),
      CabinStatus.maint => ('MANUTENÇÃO', t.warningSoft, t.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(LlRadius.pill)),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.04),
      ),
    );
  }

  Widget _sectionLabel(LlTokens t, String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.12,
        color: t.textMuted,
      ),
    );
  }
}
