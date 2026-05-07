import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../core/ll_theme.dart';
import '../widgets/ll_components.dart';

class CRMClientesScreen extends StatefulWidget {
  const CRMClientesScreen({super.key});

  @override
  State<CRMClientesScreen> createState() => _CRMClientesScreenState();
}

class _CRMClientesScreenState extends State<CRMClientesScreen> {
  final search = TextEditingController();
  Client? selectedClient;
  String query = '';

  final clients = <Client>[];

  final columns = const [
    _ColumnData('onboarding', 'Onboarding', LL.info),
    _ColumnData('satisfeito', 'Ativo · Satisfeito', LL.success),
    _ColumnData('alerta', 'Ativo · Alerta', LL.warning),
    _ColumnData('churn', 'Risco de Churn', LL.live),
    _ColumnData('cancelado', 'Inadimplente/Cancelado', LL.textMuted),
  ];

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = clients
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Expanded(
                        child: LLScreenHeader(
                            label: 'Carteira Convertida',
                            italic: 'Clientes',
                            subtitle:
                                'Apenas clientes convertidos: ativos, inadimplentes e cancelados')),
                    LLButton(
                        label: 'Novo cliente',
                        icon: Icons.add_rounded,
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.usuarios)),
                  ]),
                  const SizedBox(height: 18),
                  LayoutBuilder(builder: (context, constraints) {
                    final compact = constraints.maxWidth < 900;
                    return GridView.count(
                      shrinkWrap: true,
                      primary: false,
                      crossAxisCount: compact ? 1 : 3,
                      childAspectRatio: compact ? 5.2 : 3.3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: const [
                        _TopKpi(
                            label: 'Ativos',
                            value: '0',
                            sub: 'com contrato em operação',
                            color: LL.success,
                            icon: Icons.check_rounded),
                        _TopKpi(
                            label: 'Inadimplentes',
                            value: '0',
                            sub: 'cobranças na carteira',
                            color: LL.warning,
                            icon: Icons.notifications_none_rounded),
                        _TopKpi(
                            label: 'Cancelados',
                            value: '0',
                            sub: 'histórico encerrado',
                            color: LL.live,
                            icon: Icons.close_rounded),
                      ],
                    );
                  }),
                  const SizedBox(height: 10),
                  LayoutBuilder(builder: (context, constraints) {
                    final compact = constraints.maxWidth < 900;
                    final items = const [
                      _MetricCard(
                          label: 'LTV Total', value: 'R\$ 0', delta: ''),
                      _MetricCard(
                          label: 'Faturamento Acumulado',
                          value: 'R\$ 0',
                          delta: ''),
                      _MetricCard(
                          label: 'Total de Lives', value: '0', delta: ''),
                      _MetricCard(
                          label: 'Comissão Paga', value: 'R\$ 0', delta: ''),
                    ];
                    return GridView.count(
                      shrinkWrap: true,
                      primary: false,
                      crossAxisCount: compact ? 2 : 4,
                      childAspectRatio: compact ? 2.5 : 2.8,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: items,
                    );
                  }),
                  const SizedBox(height: 16),
                  TextField(
                    controller: search,
                    onChanged: (v) => setState(() => query = v),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded,
                            size: 18, color: LL.textMuted),
                        hintText: 'Buscar por nome ou telefone...'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final col in columns)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _KanbanColumn(
                          column: col,
                          clients:
                              filtered.where((c) => c.col == col.id).toList(),
                          onClientTap: (client) =>
                              setState(() => selectedClient = client),
                          onMove: (client) => _cycleClient(client),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (selectedClient != null)
          ClientDrawer(
              client: selectedClient!,
              onClose: () => setState(() => selectedClient = null)),
      ],
    );
  }

  void _cycleClient(Client client) {
    final idx = columns.indexWhere((c) => c.id == client.col);
    setState(() => client.col = columns[(idx + 1) % columns.length].id);
  }
}

class _TopKpi extends StatelessWidget {
  const _TopKpi(
      {required this.label,
      required this.value,
      required this.sub,
      required this.color,
      required this.icon});
  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LLCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      leftBorderColor: color,
      child: Row(children: [
        Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: color.llOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 19, color: color)),
        const SizedBox(width: 16),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text(label.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: LL.textMuted,
                      letterSpacing: 0.7)),
              Text(value,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: color,
                      height: 1,
                      letterSpacing: -1)),
              Text(sub,
                  overflow: TextOverflow.ellipsis,
                  style: LL.caption.copyWith(fontSize: 11)),
            ])),
      ]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.label, required this.value, required this.delta});
  final String label;
  final String value;
  final String delta;

  @override
  Widget build(BuildContext context) {
    return LLCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      radius: 10,
      child: Row(children: [
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 10,
                      color: LL.textMuted,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: LL.textPrimary,
                      letterSpacing: -0.5)),
            ])),
        LLDelta(value: delta, up: true),
      ]),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn(
      {required this.column,
      required this.clients,
      required this.onClientTap,
      required this.onMove});
  final _ColumnData column;
  final List<Client> clients;
  final ValueChanged<Client> onClientTap;
  final ValueChanged<Client> onMove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      constraints: const BoxConstraints(minHeight: 400),
      decoration: BoxDecoration(
          color: LL.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LL.border)),
      clipBehavior: Clip.hardEdge,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: LL.border))),
          child: Row(children: [
            Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                    color: column.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: column.color.llOpacity(0.45), blurRadius: 8)
                    ])),
            const SizedBox(width: 8),
            Expanded(
                child: Text(column.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: LL.textSecond))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                  color: column.id == 'churn'
                      ? LL.liveSoft
                      : column.id == 'satisfeito'
                          ? LL.successSoft
                          : LL.surface3,
                  borderRadius: BorderRadius.circular(12)),
              child: Text('${clients.length}',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: column.id == 'churn'
                          ? LL.live
                          : column.id == 'satisfeito'
                              ? LL.success
                              : LL.textMuted)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              children: clients.isEmpty
                  ? [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: LL.border)),
                        child: const Center(
                            child: Text('Nenhum cliente',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: LL.textMuted,
                                    fontStyle: FontStyle.italic))),
                      )
                    ]
                  : clients
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ClientCard(
                                client: c,
                                colColor: column.color,
                                onTap: () => onClientTap(c),
                                onMove: () => onMove(c)),
                          ))
                      .toList()),
        ),
      ]),
    );
  }
}

class ClientCard extends StatelessWidget {
  const ClientCard(
      {super.key,
      required this.client,
      required this.colColor,
      required this.onTap,
      required this.onMove});
  final Client client;
  final Color colColor;
  final VoidCallback onTap;
  final VoidCallback onMove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: LL.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: LL.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: colColor.llOpacity(0.18),
                  border: Border.all(color: colColor.llOpacity(0.28))),
              child: Text(_initials(client.name),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: colColor)),
            ),
            const SizedBox(width: 8),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(client.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: LL.textPrimary)),
                  if (client.presenter != null)
                    Text(client.presenter!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LL.caption.copyWith(fontSize: 10)),
                ])),
            const LLBadge(
                label: 'ATIVO', color: LL.success, background: LL.successSoft),
          ]),
          if (client.faturamento != '—') ...[
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: _MiniStat(
                      label: 'Fat.',
                      value: client.faturamento,
                      color: LL.success)),
              const SizedBox(width: 8),
              SizedBox(
                  width: 58,
                  child: _MiniStat(
                      label: 'Lives',
                      value: '${client.lives}',
                      color: LL.textPrimary)),
            ]),
          ],
          if (client.score != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              Text('SCORE', style: LL.label.copyWith(fontSize: 9)),
              const SizedBox(width: 8),
              Expanded(
                  child: LLProgressBar(
                      value: client.score! / 10,
                      color: _scoreColor(client.score!),
                      height: 4)),
              const SizedBox(width: 8),
              Text('${client.score}',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: _scoreColor(client.score!))),
            ]),
          ],
          if (client.lastLive != '—') ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.tv_outlined, size: 11, color: LL.textMuted),
              const SizedBox(width: 5),
              Text('Última live: ', style: LL.caption.copyWith(fontSize: 10)),
              Text(client.lastLive,
                  style: const TextStyle(
                      fontSize: 10,
                      color: LL.textSecond,
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              InkWell(
                  onTap: onMove,
                  child: const Icon(Icons.arrow_forward_rounded,
                      size: 14, color: LL.textMuted)),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
          color: LL.surface2, borderRadius: BorderRadius.circular(7)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: LL.label.copyWith(fontSize: 9)),
        Text(value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w900, color: color)),
      ]),
    );
  }
}

class ClientDrawer extends StatefulWidget {
  const ClientDrawer({super.key, required this.client, required this.onClose});
  final Client client;
  final VoidCallback onClose;

  @override
  State<ClientDrawer> createState() => _ClientDrawerState();
}

class _ClientDrawerState extends State<ClientDrawer> {
  String tab = 'overview';

  @override
  Widget build(BuildContext context) {
    final c = widget.client;
    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black.llOpacity(0.62),
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 440,
              height: double.infinity,
              decoration: const BoxDecoration(
                  color: LL.surface,
                  border: Border(left: BorderSide(color: LL.borderMid))),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  decoration: const BoxDecoration(
                      color: LL.surface,
                      border: Border(bottom: BorderSide(color: LL.border))),
                  child: Column(children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: LL.accent.llOpacity(0.18),
                                border: Border.all(
                                    color: LL.accent.llOpacity(0.35),
                                    width: 2)),
                            child: Text(_initials(c.name),
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: LL.accent)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(c.name,
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: LL.textPrimary,
                                        letterSpacing: -0.4)),
                                const SizedBox(height: 5),
                                Row(children: [
                                  const LLBadge(
                                      label: 'ATIVO',
                                      color: LL.success,
                                      background: LL.successSoft),
                                  if (c.presenter != null) ...[
                                    const SizedBox(width: 8),
                                    Text(c.presenter!,
                                        style:
                                            LL.caption.copyWith(fontSize: 11)),
                                  ],
                                ]),
                              ])),
                          IconButton(
                              onPressed: widget.onClose,
                              icon: const Icon(Icons.close_rounded,
                                  size: 18, color: LL.textMuted)),
                        ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      _DrawerTab(
                          id: 'overview',
                          label: 'Visão geral',
                          value: tab,
                          onTap: (v) => setState(() => tab = v)),
                      _DrawerTab(
                          id: 'lives',
                          label: 'Lives',
                          value: tab,
                          onTap: (v) => setState(() => tab = v)),
                      _DrawerTab(
                          id: 'financeiro',
                          label: 'Financeiro',
                          value: tab,
                          onTap: (v) => setState(() => tab = v)),
                    ]),
                  ]),
                ),
                Expanded(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: _drawerBody(c))),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerBody(Client c) {
    if (tab == 'lives') {
      final lives = const <(String, String, String, int, int)>[];
      return Column(children: [
        if (lives.isEmpty)
          Text('Sem lives registradas para este cliente.', style: LL.caption)
        else
          for (final l in lives)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LLCard(
                padding: const EdgeInsets.all(14),
                radius: 10,
                child: Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(l.$2,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: LL.textPrimary)),
                        const SizedBox(height: 2),
                        Text('${l.$1} · ${l.$3}',
                            style: LL.caption.copyWith(fontSize: 11)),
                      ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(llMoney(l.$4),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: LL.success)),
                    Text('${l.$5} viewers',
                        style: LL.caption.copyWith(fontSize: 10)),
                  ]),
                ]),
              ),
            ),
      ]);
    }

    if (tab == 'financeiro') {
      final rows = [
        ('LTV acumulado', c.faturamento, LL.success),
        ('Comissão gerada', 'R\$ 0', LL.accent),
        ('Plano ativo', 'Sem plano ativo', LL.textPrimary),
        ('Próximo vencimento', 'Sem vencimento', LL.warning),
      ];
      return Column(children: [
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LLCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              radius: 10,
              child: Row(children: [
                Expanded(
                    child: Text(r.$1,
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: LL.textMuted,
                            fontWeight: FontWeight.w600))),
                Text(r.$2,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: r.$3)),
              ]),
            ),
          ),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      GridView.count(
        shrinkWrap: true,
        primary: false,
        crossAxisCount: 2,
        childAspectRatio: 1.65,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          _DrawerStat(
              label: 'Faturamento', value: c.faturamento, color: LL.success),
          _DrawerStat(
              label: 'Lives realizadas', value: '${c.lives}', color: LL.accent),
          _DrawerStat(label: 'Ticket médio', value: c.ticket, color: LL.info),
          _DrawerStat(
              label: 'Última live', value: c.lastLive, color: LL.textSecond),
        ],
      ),
      if (c.score != null) ...[
        const SizedBox(height: 14),
        LLCard(
          padding: const EdgeInsets.all(16),
          radius: 10,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(
                  child: Text('Health Score',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: LL.textPrimary))),
              Text('${c.score}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _scoreColor(c.score!))),
              const Text('/10',
                  style: TextStyle(
                      fontSize: 12,
                      color: LL.textMuted,
                      fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 10),
            LLProgressBar(
                value: c.score! / 10, color: _scoreColor(c.score!), height: 8),
            const SizedBox(height: 8),
            Text(
                c.score! >= 8
                    ? '✓ Cliente satisfeito — engajamento alto'
                    : c.score! >= 5
                        ? '⚠ Atenção — engajamento em queda'
                        : '! Risco elevado de churn — ação necessária',
                style: LL.caption.copyWith(fontSize: 11.5)),
          ]),
        ),
      ],
      const SizedBox(height: 14),
      LLButton(
          label: 'Solicitar nova live',
          icon: Icons.bolt_rounded,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.solicitacoes),
          expanded: true),
      const SizedBox(height: 8),
      const LLButton(
          label: 'Enviar mensagem',
          icon: Icons.chat_bubble_outline_rounded,
          variant: LLButtonVariant.whatsapp,
          expanded: true),
      const SizedBox(height: 8),
      const LLButton(
          label: 'Ver contrato',
          icon: Icons.credit_card_outlined,
          variant: LLButtonVariant.ghost,
          expanded: true),
    ]);
  }
}

class _DrawerTab extends StatelessWidget {
  const _DrawerTab(
      {required this.id,
      required this.label,
      required this.value,
      required this.onTap});
  final String id;
  final String label;
  final String value;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final active = id == value;
    return InkWell(
      onTap: () => onTap(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: active ? LL.accent : Colors.transparent, width: 2))),
        child: Text(label,
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? LL.accent : LL.textMuted)),
      ),
    );
  }
}

class _DrawerStat extends StatelessWidget {
  const _DrawerStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LLCard(
      padding: const EdgeInsets.all(14),
      radius: 10,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label.toUpperCase(), style: LL.label.copyWith(fontSize: 10)),
            const SizedBox(height: 4),
            Text(value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: -0.5)),
          ]),
    );
  }
}

class Client {
  Client(this.id, this.name, this.col, this.status, this.score, this.presenter,
      this.faturamento, this.lives, this.ticket, this.lastLive);
  final int id;
  final String name;
  String col;
  final String status;
  final int? score;
  final String? presenter;
  final String faturamento;
  final int lives;
  final String ticket;
  final String lastLive;
}

class _ColumnData {
  const _ColumnData(this.id, this.label, this.color);
  final String id;
  final String label;
  final Color color;
}

String _initials(String name) => name
    .split(' ')
    .where((e) => e.isNotEmpty)
    .take(2)
    .map((w) => w[0].toUpperCase())
    .join();

Color _scoreColor(int s) => s >= 8
    ? LL.success
    : s >= 5
        ? LL.warning
        : LL.live;
