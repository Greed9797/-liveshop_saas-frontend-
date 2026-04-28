import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';
import '../../../theme/livelab_theme.dart';
import '../../../widgets/ll_card.dart';
import '../home_models.dart';

class RankingPanel extends StatelessWidget {
  const RankingPanel({super.key, required this.entries});
  final List<RankingEntry> entries;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    final maxGmv = entries.map((e) => e.gmv).reduce((a, b) => a > b ? a : b);
    return LlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_outlined, size: 16, color: t.primary),
              const SizedBox(width: 8),
              Text('Ranking do dia', style: TextStyle(color: t.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Apresentadoras com maior GMV hoje', style: TextStyle(color: t.textMuted, fontSize: 11)),
          const SizedBox(height: LlSpacing.md),
          ...entries.map((e) => _row(t, e, maxGmv)),
        ],
      ),
    );
  }

  Widget _row(LlTokens t, RankingEntry e, double maxGmv) {
    final medal = e.position <= 3;
    final medalColor = switch (e.position) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => t.bgElev2,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: medal ? medalColor : t.bgElev2,
              borderRadius: BorderRadius.circular(LlRadius.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              '${e.position}',
              style: TextStyle(
                color: medal ? Colors.black : t.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: LlSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.name, style: TextStyle(color: t.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${e.lives} lives · ${e.orders} pedidos', style: TextStyle(color: t.textMuted, fontSize: 11)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(LlRadius.sm),
                  child: LinearProgressIndicator(
                    value: e.gmv / maxGmv,
                    backgroundColor: t.bgElev2,
                    valueColor: AlwaysStoppedAnimation(t.primary),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: LlSpacing.md),
          Text(
            'R\$ ${(e.gmv / 1000).toStringAsFixed(1)}k',
            style: TextStyle(
              color: t.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
