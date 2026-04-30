import 'package:flutter/material.dart';
import '../core/ll_theme.dart';
import '../widgets/ll_components.dart';
import '../widgets/ll_admin_widgets.dart';

class ConsolidadoScreen extends StatelessWidget {
  const ConsolidadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kpis = const [
      AdminKpiCard(label: 'Faturamento bruto', value: 'R\$ 66.500,30', sub: 'rede consolidada', icon: Icons.live_tv_rounded, color: LL.success),
      AdminKpiCard(label: 'Receita franqueadora', value: 'R\$ 75,00', sub: 'líquida no período', icon: Icons.apartment_rounded, color: LL.accent),
      AdminKpiCard(label: 'MRR da rede', value: 'R\$ 47.840,00', sub: 'recorrente mensal', icon: Icons.attach_money_rounded, color: LL.info),
      AdminKpiCard(label: 'Take rate médio', value: '+0,1%', sub: 'bruto vs comissão', icon: Icons.local_offer_rounded, color: Color(0xFFAF7BFF)),
      AdminKpiCard(label: 'Previsão de recebimento', value: 'R\$ 75,00', sub: 'próximos 30 dias', icon: Icons.refresh_rounded, color: LL.success),
      AdminKpiCard(label: 'Inadimplência', value: 'R\$ 75,00', sub: '1 unidade em atraso', icon: Icons.warning_amber_rounded, color: LL.live, delta: '+100,0%', deltaUp: false),
      AdminKpiCard(label: 'Crescimento mensal', value: '+100,0%', sub: 'vs mês anterior', icon: Icons.trending_up_rounded, color: LL.success, delta: 'MoM'),
      AdminKpiCard(label: 'Comparativo MoM', value: 'R\$ 66.500,30', sub: 'diferença absoluta', icon: Icons.bar_chart_rounded, color: LL.accent),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminPageToolbar(
            italic: 'Consolidado',
            subtitle: 'Leitura financeira da rede: bruto, receita da franqueadora, mix de receitas e risco.',
            filters: [
              AdminFilterChip(label: 'Período', value: 'abril 2026'),
              AdminFilterChip(label: 'Status', value: 'Todos'),
              AdminFilterChip(label: 'Ordenar por', value: 'Maior faturamento'),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width < 680 ? 1 : width < 1040 ? 2 : 4;
              return GridView.count(
                shrinkWrap: true,
                primary: false,
                crossAxisCount: columns,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: columns == 1 ? 4.2 : 2.05,
                children: kpis,
              );
            },
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 840;
              final chartA = const AdminChartCard(
                title: 'Evolução da rede',
                subtitle: 'histórico consolidado para comparar tendência e sazonalidade',
                child: AdminLineChart(
                  labels: ['Nov/24', 'Dez/24', 'Jan/25', 'Fev/25', 'Mar/25', 'Abr/25', 'Mai/25', 'Jun/25', 'Jul/25', 'Ago/25', 'Set/25', 'Out/25', 'Nov/25', 'Dez/25', 'Jan/26', 'Fev/26', 'Mar/26', 'Abr/26'],
                  data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 66.5],
                  maxY: 70,
                ),
              );
              final chartB = const AdminChartCard(
                title: 'Mix de receita',
                subtitle: 'separação do que é mensalidade, comissão e outros componentes',
                child: RevenueMixWidget(),
              );
              if (compact) return Column(children: [chartA, const SizedBox(height: 10), chartB]);
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: chartA), const SizedBox(width: 10), Expanded(flex: 2, child: chartB)]);
            },
          ),
          const AdminSectionHeader(title: 'Tabela consolidada por unidade', subtitle: 'bruto, mensal/contratual, receita da franqueadora, crescimento e status', actionLabel: 'Exportar CSV'),
          const ConsolidatedUnitTable(),
        ],
      ),
    );
  }
}

class RevenueMixWidget extends StatelessWidget {
  const RevenueMixWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _MixItem(label: 'Mensalidades', value: 'R\$ 47.840,00', pct: 0.719, color: LL.info),
      _MixItem(label: 'Comissão', value: 'R\$ 18.660,30', pct: 0.281, color: LL.accent),
      _MixItem(label: 'Outros', value: 'R\$ 0,00', pct: 0.0, color: LL.textMuted),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items) Padding(padding: const EdgeInsets.only(bottom: 16), child: _MixBar(item: item)),
        const Divider(color: LL.border),
        const SizedBox(height: 8),
        const _MixFooter(label: 'Receita franqueadora', value: 'R\$ 75,00'),
        const SizedBox(height: 8),
        const _MixFooter(label: 'Take rate médio', value: '+0,1%', color: LL.success),
      ],
    );
  }
}

class _MixItem {
  const _MixItem({required this.label, required this.value, required this.pct, required this.color});
  final String label;
  final String value;
  final double pct;
  final Color color;
}

class _MixBar extends StatelessWidget {
  const _MixBar({required this.item});
  final _MixItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(item.label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: LL.textPrimary))),
            Text(item.value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: LL.textPrimary)),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 10,
            color: LL.surface3,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(widthFactor: item.pct.clamp(0.0, 1.0), child: Container(color: item.color)),
          ),
        ),
        const SizedBox(height: 4),
        Text('${(item.pct * 100).toStringAsFixed(1).replaceAll('.', ',')}% do consolidado', style: LL.caption.copyWith(fontSize: 10.5)),
      ],
    );
  }
}

class _MixFooter extends StatelessWidget {
  const _MixFooter({required this.label, required this.value, this.color = LL.textPrimary});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: LL.textSecond, fontWeight: FontWeight.w700))),
        Text(value, style: TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class ConsolidatedUnitTable extends StatelessWidget {
  const ConsolidatedUnitTable({super.key});

  @override
  Widget build(BuildContext context) {
    return LLCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 920),
          child: Column(
            children: const [
              _TableHeader(),
              _TableRowData(
                unit: 'Franquia Te4535ste Paulista 2.0',
                gross: 'R\$ 66.500,30',
                contract: '+5,9%',
                franchisor: 'R\$ 75,00',
                takeRate: '+0,1%',
                growth: '+100,0%',
                status: 'INADIMPLENTE',
              ),
              _TableRowData(
                unit: 'Total da rede',
                gross: 'R\$ 66.500,30',
                contract: '+5,9%',
                franchisor: 'R\$ 75,00',
                takeRate: '+0,1%',
                growth: '+100,0%',
                status: '1 unidade',
                total: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    const headers = ['Unidade', 'Faturamento bruto', '% contratual', 'Receita franqueadora', 'Take rate', 'Crescimento', 'Status'];
    const flexes = [3, 2, 1, 2, 1, 1, 2];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: const BoxDecoration(color: LL.surface3, border: Border(bottom: BorderSide(color: LL.border))),
      child: Row(children: [
        for (var i = 0; i < headers.length; i++) Expanded(flex: flexes[i], child: Text(headers[i].toUpperCase(), style: LL.label.copyWith(fontSize: 9))),
      ]),
    );
  }
}

class _TableRowData extends StatelessWidget {
  const _TableRowData({required this.unit, required this.gross, required this.contract, required this.franchisor, required this.takeRate, required this.growth, required this.status, this.total = false});
  final String unit;
  final String gross;
  final String contract;
  final String franchisor;
  final String takeRate;
  final String growth;
  final String status;
  final bool total;

  @override
  Widget build(BuildContext context) {
    const flexes = [3, 2, 1, 2, 1, 1, 2];
    final style = TextStyle(fontSize: 12.5, fontWeight: total ? FontWeight.w900 : FontWeight.w700, color: total ? LL.textPrimary : LL.textSecond);
    final values = [unit, gross, contract, franchisor, takeRate, growth];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: LL.border))),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              flex: flexes[i],
              child: Text(values[i], overflow: TextOverflow.ellipsis, style: i == 5 ? style.copyWith(color: LL.success) : style),
            ),
          Expanded(
            flex: flexes[6],
            child: total ? Text(status, style: LL.caption.copyWith(fontWeight: FontWeight.w800)) : const AdminStatusPill(label: 'Inadimplente', color: LL.live),
          ),
        ],
      ),
    );
  }
}
