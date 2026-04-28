import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';
import '../../../theme/livelab_theme.dart';
import '../../../widgets/ll_card.dart';
import '../home_models.dart';

class UpcomingPanel extends StatelessWidget {
  const UpcomingPanel({super.key, required this.upcoming});
  final List<UpcomingLive> upcoming;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    return LlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Próximas lives do dia', style: TextStyle(color: t.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Agendadas até o fim do dia', style: TextStyle(color: t.textMuted, fontSize: 11)),
          const SizedBox(height: LlSpacing.md),
          ...upcoming.map((u) => Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.hairline))),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.time,
                            style: TextStyle(
                              color: t.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          if (u.duration != null)
                            Text(u.duration!, style: TextStyle(color: t.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.client, style: TextStyle(color: t.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            'CABINE ${u.cabin.toString().padLeft(2, "0")} · ${u.presenter}',
                            style: TextStyle(color: t.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
