import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';
import '../../../theme/livelab_theme.dart';
import '../../../core/format.dart';
import '../../../widgets/ll_card.dart';
import '../home_models.dart';

class LiveNowPanel extends StatelessWidget {
  const LiveNowPanel({super.key, required this.lives});
  final List<LiveNow> lives;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    return LlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: t.primary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('Lives ao vivo', style: TextStyle(color: t.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${lives.length} transmitindo', style: TextStyle(color: t.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: LlSpacing.md),
          ...lives.map((l) => _row(t, l)),
        ],
      ),
    );
  }

  Widget _row(LlTokens t, LiveNow l) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.hairline))),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: t.primarySoft,
              borderRadius: BorderRadius.circular(LlRadius.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              l.cabin.toString().padLeft(2, '0'),
              style: TextStyle(color: t.primary, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: LlSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.client, style: TextStyle(color: t.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${l.presenter} · ${l.duration}', style: TextStyle(color: t.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${(l.gmv / 1000).toStringAsFixed(1)}k',
                style: TextStyle(color: t.primary, fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text('${LlFormat.compactInt(l.viewers)} esp.', style: TextStyle(color: t.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
