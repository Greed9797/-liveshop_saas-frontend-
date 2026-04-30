import 'package:flutter/material.dart';
import '../core/ll_theme.dart';
import '../widgets/ll_components.dart';
import '../widgets/ll_admin_widgets.dart';

class AdminMasterScreen extends StatelessWidget {
  const AdminMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kpis = const [
      AdminKpiCard(label: 'Unidades ativas', value: '1', sub: '1 franquia operando', icon: Icons.apartment_rounded, color: LL.accent),
      AdminKpiCard(label: 'Clientes ativos', value: '12', sub: 'contratos faturando', icon: Icons.groups_2_rounded, color: LL.info),
      AdminKpiCard(label: 'Faturamento da rede', value: 'R\$ 66.500,30', sub: 'vs mês anterior', icon: Icons.live_tv_rounded, color: LL.success, delta: '+12,4%'),
      AdminKpiCard(label: 'Receita franqueadora', value: 'R\$ 75,00', sub: 'líquida no período', icon: Icons.account_balance_wallet_rounded, color: LL.accent, delta: '+8,1%'),
      AdminKpiCard(label: 'Contratos pendentes', value: '12', sub: 'aguardando assinatura', icon: Icons.pending_actions_rounded, color: LL.warning),
      AdminKpiCard(label: 'Crescimento', value: '+100,0%', sub: 'vs mês anterior', icon: Icons.trending_up_rounded, color: LL.success, delta: 'MoM'),
      AdminKpiCard(label: 'Inadimplência', value: 'R\$ 75,00', sub: '1 unidade em atraso', icon: Icons.warning_amber_rounded, color: LL.live, delta: '+100,0%', deltaUp: false),
      AdminKpiCard(label: 'Ticket médio / unidade', value: 'R\$ 66.500,30', sub: 'receita por franquia ativa', icon: Icons.sell_rounded, color: LL.info),
    ];

    const rankItems = [
      RankItem(name: 'Franquia Te4535ste Paulista 2.0', value: 'R\$ 66.500,30', delta: '+100,0%'),
      RankItem(name: 'Franquia Demo Centro', value: 'R\$ 0,00', delta: '—', up: false),
      RankItem(name: 'Franquia Beta', value: 'R\$ 0,00', delta: '—', up: false),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminPageToolbar(
            italic: 'Painel',
            bold: 'Master',
            subtitle: 'Leitura executiva da rede em poucos segundos, sem ruído operacional.',
            filters: [AdminFilterChip(label: 'Período', value: 'abril 2026')],
          ),
          const SizedBox(height: 16),
          _ExecutiveSummary(),
          const SizedBox(height: 14),
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
          const AdminSectionHeader(title: 'Ranking de unidades', subtitle: 'desempenho consolidado da rede no mês atual', actionLabel: 'Ver detalhado'),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final cards = const [
                RankCard(title: 'Por faturamento', items: rankItems),
                RankCard(title: 'Por crescimento', items: rankItems),
              ];
              if (compact) {
                return const Column(children: [RankCard(title: 'Por faturamento', items: rankItems), SizedBox(height: 10), RankCard(title: 'Por crescimento', items: rankItems)]);
              }
              return Row(children: [for (final card in cards) Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: card))]);
            },
          ),
          const AdminSectionHeader(title: 'Alertas críticos', subtitle: 'situações que pedem ação direta da franqueadora', actionLabel: 'Ver todos (7)'),
          const LLCard(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                AdminAlertRow(kind: AdminAlertKind.danger, title: 'Inadimplência na unidade', body: 'Franquia Te4535ste Paulista 2.0 tem R\$ 75,00 em aberto com a franqueadora.', action: 'Resolver'),
                AdminAlertRow(kind: AdminAlertKind.warning, title: 'Contrato parado na pipeline', body: '321312 está em rascunho há mais de 7 dias.', action: 'Abrir'),
                AdminAlertRow(kind: AdminAlertKind.warning, title: 'Contrato parado na pipeline', body: 'fafas está em análise há mais de 7 dias.', action: 'Abrir'),
                AdminAlertRow(kind: AdminAlertKind.warning, title: 'Contrato parado na pipeline', body: 'rdferwc está em rascunho há mais de 7 dias.', action: 'Abrir'),
                AdminAlertRow(kind: AdminAlertKind.warning, title: 'Contrato parado na pipeline', body: 'Teste Cliente Novo está em análise há mais de 7 dias.', action: 'Abrir'),
                AdminAlertRow(kind: AdminAlertKind.warning, title: 'Contrato parado na pipeline', body: 'fas/as está em análise há mais de 7 dias.', action: 'Abrir'),
              ],
            ),
          ),
          const AdminSectionHeader(title: 'Performance da rede', subtitle: 'tendências que importam — sem ruído'),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 840;
              final chartA = const AdminChartCard(
                title: 'Receita consolidada da rede',
                subtitle: 'últimos 6 meses · faturamento bruto e receita da franqueadora',
                child: AdminLineChart(
                  labels: ['Nov/25', 'Dez/25', 'Jan/26', 'Fev/26', 'Mar/26', 'Abr/26'],
                  data: [0, 0, 0, 0, 0, 66.5],
                  secondaryData: [0, 0, 0, 0, 0, 0.075],
                  maxY: 70,
                ),
              );
              final chartB = const AdminChartCard(
                title: 'Crescimento por unidade',
                subtitle: 'comparativo com o mês anterior, por franquia',
                child: AdminGrowthChart(),
              );
              if (compact) return Column(children: [chartA, const SizedBox(height: 10), chartB]);
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: chartA), const SizedBox(width: 10), Expanded(flex: 2, child: chartB)]);
            },
          ),
          const AdminSectionHeader(title: 'Comercial & financeiro', subtitle: 'leitura direta do pipeline e do caixa da franqueadora'),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              if (compact) {
                return const Column(children: [_PipelineCard(), SizedBox(height: 10), _CommissionCard()]);
              }
              return const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: _PipelineCard()), SizedBox(width: 10), Expanded(child: _CommissionCard())]);
            },
          ),
        ],
      ),
    );
  }
}

class _ExecutiveSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LLCard(
      padding: const EdgeInsets.all(16),
      color: LL.accentSoft,
      borderColor: LL.accent.llOpacity(0.24),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: LL.accent.llOpacity(0.16), borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.trending_up_rounded, color: LL.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RESUMO EXECUTIVO', style: LL.label.copyWith(color: LL.accent, fontSize: 9.5)),
                const SizedBox(height: 4),
                Text(
                  '1 unidade, 12 clientes e R\$ 66.500,30 faturados na rede. Receita líquida da franqueadora de R\$ 75,00, com 12 contratos pendentes e 1 alerta crítico em andamento.',
                  style: LL.body.copyWith(color: LL.textPrimary, fontSize: 13.2, height: 1.38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineCard extends StatelessWidget {
  const _PipelineCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      _PipeItem('Lead captado', 0, LL.info),
      _PipeItem('Qualificação', 0, LL.info),
      _PipeItem('Reunião agendada', 0, LL.info),
      _PipeItem('Negociação', 0, LL.accent),
      _PipeItem('Contrato enviado', 0, LL.accent),
      _PipeItem('Contrato pendente', 12, LL.warning),
      _PipeItem('Fechado ganho', 1, LL.success),
      _PipeItem('Fechado perdido', 0, LL.textMuted),
    ];

    return AdminChartCard(
      title: 'Pipeline do CRM',
      subtitle: 'estrutura pronta para expansão comercial global',
      child: Column(children: [for (final item in items) _PipeRow(item)]),
    );
  }
}

class _PipeItem {
  const _PipeItem(this.name, this.value, this.color);
  final String name;
  final int value;
  final Color color;
}

class _PipeRow extends StatelessWidget {
  const _PipeRow(this.item);
  final _PipeItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: LL.border))),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)),
          const SizedBox(width: 9),
          Expanded(child: Text(item.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: LL.textSecond))),
          Text('${item.value}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: item.value > 0 ? LL.textPrimary : LL.textMuted)),
        ],
      ),
    );
  }
}

class _CommissionCard extends StatelessWidget {
  const _CommissionCard();

  @override
  Widget build(BuildContext context) {
    return AdminChartCard(
      title: 'Comissionamento da franqueadora',
      subtitle: 'leitura direta do caixa da franqueadora no período',
      child: Column(
        children: const [
          _MoneyStatus(label: 'Previsto', value: 'R\$ 75,00', color: LL.accent),
          _MoneyStatus(label: 'Recebido', value: 'R\$ 0,00', color: LL.success),
          _MoneyStatus(label: 'Pendente', value: 'R\$ 0,00', color: LL.warning),
          _MoneyStatus(label: 'Inadimplente', value: 'R\$ 75,00', color: LL.live),
          SizedBox(height: 12),
          Divider(color: LL.border, height: 1),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text('Taxa de recebimento', style: TextStyle(fontSize: 11, color: LL.textMuted, fontWeight: FontWeight.w600))),
              Text('0% / 100%', style: TextStyle(fontSize: 14, color: LL.live, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoneyStatus extends StatelessWidget {
  const _MoneyStatus({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: LL.border))),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 9),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: LL.textSecond))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: LL.textPrimary)),
        ],
      ),
    );
  }
}
