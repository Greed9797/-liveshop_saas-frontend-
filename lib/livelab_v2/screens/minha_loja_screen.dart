import 'package:flutter/material.dart';
import '../core/ll_theme.dart';
import '../widgets/ll_components.dart';

class MinhaLojaScreen extends StatefulWidget {
  const MinhaLojaScreen({super.key});

  @override
  State<MinhaLojaScreen> createState() => _MinhaLojaScreenState();
}

class _MinhaLojaScreenState extends State<MinhaLojaScreen> {
  String period = 'mes';

  @override
  Widget build(BuildContext context) {
    final periods = const [
      LLSegmentItem('hoje', 'Hoje'),
      LLSegmentItem('7d', '7 dias'),
      LLSegmentItem('30d', '30 dias'),
      LLSegmentItem('mes', 'Mês atual'),
      LLSegmentItem('custom', 'Personalizado'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 14,
                children: [
                  const LLScreenHeader(label: 'Painel do Parceiro', italic: 'Minha', bold: 'Loja', subtitle: 'Visão geral da performance de lives'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LLSegmented(items: periods, value: period, onChanged: (v) => setState(() => period = v)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                        decoration: BoxDecoration(color: context.llSurface2, borderRadius: BorderRadius.circular(8), border: Border.all(color: context.llBorder)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chevron_left_rounded, size: 15, color: context.llTextSecond),
                            const SizedBox(width: 4),
                            Text('abril 2026', style: TextStyle(fontSize: 12.5, color: context.llTextPrimary, fontWeight: FontWeight.w800)),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded, size: 15, color: context.llTextSecond),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _KpiGrid(compact: compact),
              const SizedBox(height: 16),
              compact
                  ? const Column(children: [
                      _GoalCard(),
                      SizedBox(height: 12),
                      _UpcomingLivesCard(),
                    ])
                  : const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 6, child: _GoalCard()),
                      SizedBox(width: 12),
                      Expanded(flex: 5, child: _UpcomingLivesCard()),
                    ]),
              const SizedBox(height: 12),
              compact
                  ? const Column(children: [
                      _BestHoursCard(),
                      SizedBox(height: 12),
                      _MonthlyEvolutionCard(),
                    ])
                  : const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 5, child: _BestHoursCard()),
                      SizedBox(width: 12),
                      Expanded(flex: 6, child: _MonthlyEvolutionCard()),
                    ]),
            ],
          ),
        );
      },
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final kpis = [
      _Kpi('Faturamento', 'R\$ 142.840', null, '+18%', true, LL.success, const [12, 18, 14, 22, 26, 31, 28, 34, 42, 38, 46, 52]),
      _Kpi('Lives realizadas', '24', 'de 30 planejadas', '+4', true, LL.accent, const [8, 12, 10, 18, 22, 24, 28, 32, 30, 36, 40, 44]),
      _Kpi('Horas no ar', '52,4h', 'média 2h 11min', '+12%', true, LL.info, const [10, 14, 18, 16, 22, 28, 34, 30, 38, 44, 48, 52]),
      _Kpi('Ticket médio', 'R\$ 184', '1.842 pedidos', '-3%', false, LL.textSecond, const [42, 44, 40, 46, 48, 44, 42, 40, 38, 42, 44, 40]),
    ];

    return GridView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: kpis.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: compact ? 2 : 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 158,
      ),
      itemBuilder: (context, index) {
        final k = kpis[index];
        return LLCard(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(k.label, style: TextStyle(fontSize: 11, color: context.llTextMuted, fontWeight: FontWeight.w600))),
                  LLDelta(value: k.delta, up: k.up),
                ],
              ),
              const SizedBox(height: 12),
              Text(k.value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: context.llTextPrimary, letterSpacing: -0.8, height: 1)),
              if (k.sub != null) ...[
                const SizedBox(height: 4),
                Text(k.sub!, style: LL.caption),
              ],
              const Spacer(),
              LLSparkline(data: k.spark, color: k.color, width: 220, height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard();

  @override
  Widget build(BuildContext context) {
    const metaPct = 0.72;
    return LLCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          LLCircularProgress(
            value: metaPct,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('72%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.llTextPrimary, height: 1)),
                const SizedBox(height: 2),
                Text('DA META', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: context.llTextMuted, letterSpacing: 0.6)),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Meta do Mês', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: context.llTextPrimary))),
                    Text('Editar', style: TextStyle(fontSize: 11, color: context.llTextMuted, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    Icon(Icons.bolt_rounded, size: 12, color: context.llTextMuted),
                  ],
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: 'R\$ 142.840', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.llTextPrimary, letterSpacing: -0.6)),
                    TextSpan(text: ' / R\$ 200.000', style: LL.caption.copyWith(fontSize: 12)),
                  ]),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const LLBadge(label: 'No ritmo', color: LL.success, background: LL.successSoft),
                    Text('R\$ 57.160 restantes · 12 dias', style: TextStyle(fontSize: 11, color: context.llTextMuted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingLivesCard extends StatelessWidget {
  const _UpcomingLivesCard();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('15:00', 'Beauty Trend', 3, 'Rafael T.', '2h'),
      ('17:00', 'Moda Express', 2, 'Ana Lima', '90min'),
      ('19:30', 'Urban Co · prime', 7, 'Camila M.', '2h'),
    ];

    return LLCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.tv_outlined, size: 15, color: LL.accent),
            const SizedBox(width: 8),
            Expanded(child: Text('Próximas Lives', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: context.llTextPrimary))),
            Text('3 hoje', style: TextStyle(fontSize: 11, color: context.llTextMuted, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 14),
          for (final item in items) Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(width: 46, child: Text(item.$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: context.llTextPrimary))),
                Container(width: 4, height: 4, decoration: const BoxDecoration(color: LL.accent, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.$2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: context.llTextPrimary)),
                    Text('Cab. ${llPad2(item.$3)} · ${item.$4} · ${item.$5}', style: LL.caption.copyWith(fontSize: 10.5)),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BestHoursCard extends StatelessWidget {
  const _BestHoursCard();

  @override
  Widget build(BuildContext context) {
    final hours = [
      ('19:00 - 21:00', 'R\$ 38.420', 0.92, 'Prime time'),
      ('13:00 - 15:00', 'R\$ 24.180', 0.64, 'Pico almoço'),
      ('09:00 - 11:00', 'R\$ 18.640', 0.48, 'Início manhã'),
      ('16:00 - 18:00', 'R\$ 12.380', 0.32, 'Tarde'),
    ];

    return LLCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.star_border_rounded, size: 16, color: LL.warning),
            const SizedBox(width: 8),
            Text('Melhores horários', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: context.llTextPrimary)),
          ]),
          const SizedBox(height: 4),
          Text('Faixas com maior GMV no período', style: LL.caption),
          const SizedBox(height: 16),
          for (final h in hours) Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(text: h.$1, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: context.llTextPrimary)),
                        TextSpan(text: '  ${h.$4.toUpperCase()}', style: LL.caption.copyWith(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
                      ])),
                    ),
                    Text(h.$2, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: LL.success)),
                  ],
                ),
                const SizedBox(height: 6),
                LLProgressBar(value: h.$3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyEvolutionCard extends StatelessWidget {
  const _MonthlyEvolutionCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      LLBarItem(label: 'Out', value: 84200, secondary: 18, topLabel: '84k'),
      LLBarItem(label: 'Nov', value: 96400, secondary: 22, topLabel: '96k'),
      LLBarItem(label: 'Dez', value: 128900, secondary: 26, topLabel: '129k'),
      LLBarItem(label: 'Jan', value: 110200, secondary: 21, topLabel: '110k'),
      LLBarItem(label: 'Fev', value: 132400, secondary: 25, topLabel: '132k'),
      LLBarItem(label: 'Mar', value: 118600, secondary: 23, topLabel: '119k'),
      LLBarItem(label: 'Abr', value: 142840, secondary: 24, topLabel: '143k', highlight: true),
    ];

    return LLCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.trending_up_rounded, size: 16, color: LL.info),
            const SizedBox(width: 8),
            Expanded(child: Text('Evolução mensal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: context.llTextPrimary))),
            const _Legend(color: LL.accent, label: 'GMV'),
            const SizedBox(width: 12),
            const _Legend(color: LL.info, label: 'Lives'),
          ]),
          const SizedBox(height: 4),
          Text('Últimos 7 meses', style: LL.caption),
          const SizedBox(height: 12),
          const LLBarChart(items: items),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: LL.caption.copyWith(fontSize: 10)),
    ]);
  }
}

class _Kpi {
  const _Kpi(this.label, this.value, this.sub, this.delta, this.up, this.color, this.spark);
  final String label;
  final String value;
  final String? sub;
  final String delta;
  final bool up;
  final Color color;
  final List<double> spark;
}
