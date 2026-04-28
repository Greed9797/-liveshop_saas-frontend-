import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';
import '../../../theme/livelab_theme.dart';
import '../../../widgets/ll_card.dart';
import '../../../widgets/ll_sparkline.dart';
import '../home_models.dart';

class PulseStrip extends StatelessWidget {
  const PulseStrip({super.key, required this.kpis});
  final List<HomeKpi> kpis;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (c, box) {
      final cols = box.maxWidth < 720 ? 2 : 4;
      return GridView.count(
        crossAxisCount: cols,
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: LlSpacing.md,
        crossAxisSpacing: LlSpacing.md,
        childAspectRatio: 1.7,
        children: kpis.map((k) => _kpiCard(context, k)).toList(),
      );
    });
  }

  Widget _kpiCard(BuildContext context, HomeKpi k) {
    final t = context.llTokens;
    return LlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            k.label.toUpperCase(),
            style: TextStyle(color: t.textMuted, fontSize: 10, letterSpacing: 0.6, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            k.value,
            style: TextStyle(
              color: t.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const Spacer(),
          if (k.spark.isNotEmpty)
            LlSparkline(values: k.spark, color: k.deltaPositive ? t.primary : t.danger, height: 28),
          const SizedBox(height: 6),
          Text(
            k.delta,
            style: TextStyle(
              color: k.deltaPositive ? t.success : t.danger,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
