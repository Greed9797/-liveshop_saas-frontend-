import 'package:flutter/material.dart';
import '../core/ll_theme.dart';
import '../widgets/ll_components.dart';
import '../widgets/ll_admin_widgets.dart';

class UnidadesScreen extends StatelessWidget {
  const UnidadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kpis = const [
      AdminKpiCard(
          label: 'Unidades',
          value: '1',
          sub: 'rede ativa',
          icon: Icons.apartment_rounded,
          color: LL.accent),
      AdminKpiCard(
          label: 'Clientes ativos',
          value: '12',
          sub: 'contratos faturando',
          icon: Icons.groups_2_rounded,
          color: LL.info),
      AdminKpiCard(
          label: 'Faturamento bruto',
          value: 'R\$ 66.500,30',
          sub: 'rede consolidada',
          icon: Icons.live_tv_rounded,
          color: LL.success),
      AdminKpiCard(
          label: 'Receita franqueadora',
          value: 'R\$ 75,00',
          sub: 'líquida no período',
          icon: Icons.account_balance_wallet_rounded,
          color: LL.accent),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminPageToolbar(
            italic: 'Unidades',
            subtitle:
                'Cada unidade como uma mini-DRE operacional da rede, com drill-down por cliente final.',
            filters: [
              AdminFilterChip(label: 'Período', value: 'abril 2026'),
              AdminFilterChip(label: 'Status', value: 'Todos'),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width < 680
                  ? 1
                  : width < 1040
                      ? 2
                      : 4;
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
          const UnitDrillDownCard(initiallyOpen: true),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            decoration: BoxDecoration(
                border:
                    Border.all(color: LL.borderMid, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_rounded, size: 17, color: LL.textMuted),
                SizedBox(width: 6),
                Text('Adicionar nova unidade à rede',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: LL.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UnitDrillDownCard extends StatefulWidget {
  const UnitDrillDownCard({super.key, this.initiallyOpen = false});
  final bool initiallyOpen;

  @override
  State<UnitDrillDownCard> createState() => _UnitDrillDownCardState();
}

class _UnitDrillDownCardState extends State<UnitDrillDownCard> {
  late bool open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    return LLCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => open = !open),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: const [
                            Text('Franquia Te4535ste Paulista 2.0',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: LL.textPrimary)),
                            AdminStatusPill(
                                label: 'Inadimplente', color: LL.live),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Região não informada', style: LL.caption),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? .5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 22, color: LL.textMuted),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _UnitChip(label: 'Clientes', value: '12'),
                _UnitChip(label: 'Faturamento bruto', value: 'R\$ 66.500,30'),
                _UnitChip(
                    label: 'Receita líquida unidade', value: 'R\$ 66.425,30'),
                _UnitChip(label: 'Receita franqueadora', value: 'R\$ 75,00'),
                _UnitChip(
                    label: 'Crescimento', value: '+100,0%', color: LL.success),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: const _UnitExpandedContent(),
            crossFadeState:
                open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
          color:
              (color ?? LL.textSecond).llOpacity(color == null ? 0.06 : 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color?.llOpacity(0.22) ?? LL.border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: LL.caption.copyWith(fontSize: 10.5)),
          const SizedBox(width: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: color ?? LL.textPrimary)),
        ],
      ),
    );
  }
}

class _UnitExpandedContent extends StatelessWidget {
  const _UnitExpandedContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: LL.surface3,
          border: Border(top: BorderSide(color: LL.border))),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final dre = const _MiniDreCard();
          final clients = const _TopClientsCard();
          if (compact)
            return Column(children: [dre, const SizedBox(height: 12), clients]);
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: dre),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: clients)
          ]);
        },
      ),
    );
  }
}

class _MiniDreCard extends StatelessWidget {
  const _MiniDreCard();

  @override
  Widget build(BuildContext context) {
    return LLCard(
      color: LL.surface2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('MINI-DRE DA UNIDADE',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: LL.textSecond,
                  letterSpacing: 0.7)),
          SizedBox(height: 10),
          _DreRow(
              label: 'Receita bruta', value: 'R\$ 66.500,30', positive: true),
          _DreRow(label: '(–) Impostos', value: '– R\$ 0,00', negative: true),
          _DreRow(
              label: '(–) Comissão franqueadora',
              value: '– R\$ 75,00',
              negative: true),
          _DreRow(
              label: '(–) Custos operacionais',
              value: '– R\$ 0,00',
              negative: true),
          Divider(color: LL.border),
          _DreRow(
              label: 'Receita líquida',
              value: 'R\$ 66.425,30',
              positive: true,
              total: true),
        ],
      ),
    );
  }
}

class _TopClientsCard extends StatelessWidget {
  const _TopClientsCard();

  @override
  Widget build(BuildContext context) {
    return LLCard(
      color: LL.surface2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('TOP 3 CLIENTES FINAIS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: LL.textSecond,
                  letterSpacing: 0.7)),
          SizedBox(height: 10),
          Text('Sem clientes com faturamento no período.',
              style: TextStyle(color: LL.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _DreRow extends StatelessWidget {
  const _DreRow(
      {required this.label,
      required this.value,
      this.positive = false,
      this.negative = false,
      this.total = false});
  final String label;
  final String value;
  final bool positive;
  final bool negative;
  final bool total;

  @override
  Widget build(BuildContext context) {
    final color = positive
        ? LL.success
        : negative
            ? LL.live
            : LL.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: total ? 13 : 12,
                      fontWeight: total ? FontWeight.w900 : FontWeight.w600,
                      color: total ? LL.textPrimary : LL.textSecond))),
          Text(value,
              style: TextStyle(
                  fontSize: total ? 13 : 12,
                  fontWeight: FontWeight.w900,
                  color: color)),
        ],
      ),
    );
  }
}
