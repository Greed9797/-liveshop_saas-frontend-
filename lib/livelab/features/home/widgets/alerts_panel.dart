import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';
import '../../../theme/livelab_theme.dart';
import '../../../widgets/ll_card.dart';
import '../home_models.dart';

class AlertsPanel extends StatelessWidget {
  const AlertsPanel({super.key, required this.alerts});
  final List<HomeAlert> alerts;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    return LlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Alertas', style: TextStyle(color: t.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: LlSpacing.md),
          ...alerts.map((a) => _row(t, a)),
        ],
      ),
    );
  }

  Widget _row(LlTokens t, HomeAlert a) {
    final (bg, fg, icon) = switch (a.severity) {
      HomeAlertSeverity.danger => (t.dangerSoft, t.danger, Icons.error_outline),
      HomeAlertSeverity.warning => (t.warningSoft, t.warning, Icons.warning_amber_outlined),
      HomeAlertSeverity.info => (t.infoSoft, t.info, Icons.info_outline),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: LlSpacing.sm),
      padding: const EdgeInsets.all(LlSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(LlRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: LlSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(a.subtitle, style: TextStyle(color: t.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
