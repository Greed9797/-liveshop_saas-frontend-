import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/metric_card.dart';
import '../../providers/cliente_dashboard_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Painel do cliente parceiro com métricas e live em andamento
class ClienteScreen extends ConsumerWidget {
  const ClienteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(clienteDashboardProvider);

    return AppScaffold(
      currentRoute: AppRoutes.cliente,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: dashAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Erro: $e'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(clienteDashboardProvider.notifier).refresh(),
                child: const Text('Tentar novamente'),
              ),
            ]),
          ),
          data: (dashboard) => _ClienteContent(dashboard: dashboard),
        ),
      ),
    );
  }
}

class _ClienteContent extends StatelessWidget {
  final ClienteDashboard dashboard;
  const _ClienteContent({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final fatStr =
        'R\$ ${dashboard.faturamentoMes.toStringAsFixed(2).replaceAll('.', ',')}';
    final comissaoStr =
        'R\$ ${dashboard.lucroEstimado.toStringAsFixed(2).replaceAll('.', ',')}';
    final crescendo = dashboard.crescimentoPct >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.store, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Minha Loja',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                const Text('Visão Geral do Parceiro',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // --- Painel AO VIVO ---
        if (dashboard.liveAtiva != null) ...[
          _LivePanel(live: dashboard.liveAtiva!),
          const SizedBox(height: 24),
        ],

        // --- Grid de Métricas ---
        const Text('RESULTADOS DO MÊS',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
                width: 180,
                child: MetricCard(
                  label: 'CRESCIMENTO',
                  value: '${crescendo ? '+' : ''}${dashboard.crescimentoPct}%',
                  icon: crescendo ? Icons.trending_up : Icons.trending_down,
                  iconColor: crescendo ? AppColors.success : AppColors.danger,
                )),
            SizedBox(
                width: 180,
                child: MetricCard(
                  label: 'VENDAS DO MÊS',
                  value: fatStr,
                  icon: Icons.attach_money,
                  iconColor: AppColors.primary,
                )),
            SizedBox(
                width: 180,
                child: MetricCard(
                  label: 'MEU LUCRO ESTIMADO',
                  value: comissaoStr,
                  icon: Icons.percent,
                  iconColor: AppColors.lilac,
                )),
            SizedBox(
                width: 180,
                child: MetricCard(
                  label: 'ITENS VENDIDOS',
                  value: '${dashboard.volumeVendas}',
                  icon: Icons.inventory_2_outlined,
                  iconColor: Colors.blue,
                )),
          ],
        ),

        const SizedBox(height: 32),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ranking do Dia
            if (dashboard.rankingDia != null)
              Expanded(
                  flex: 1, child: _RankingCard(ranking: dashboard.rankingDia!)),

            if (dashboard.rankingDia != null) const SizedBox(width: 16),

            // Mais Vendidos
            Expanded(
                flex: 2,
                child: _MaisVendidosCard(produtos: dashboard.maisVendidos)),
          ],
        )
      ],
    );
  }
}

/// Painel Detalhado quando o Cliente Parceiro está em Live
class _LivePanel extends StatefulWidget {
  final LiveAtiva live;
  const _LivePanel({required this.live});

  @override
  State<_LivePanel> createState() => _LivePanelState();
}

class _LivePanelState extends State<_LivePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.success, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                FadeTransition(
                  opacity: _ctrl,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.live_tv, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('AO VIVO AGORA',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Cabine ${widget.live.cabineNumero}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                const Icon(Icons.timer_outlined, color: Colors.grey, size: 18),
                const SizedBox(width: 4),
                Text('${widget.live.duracaoMin} min',
                    style: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLiveMetric(Icons.visibility, Colors.blue, 'Espectadores',
                    '${widget.live.viewerCount}'),
                _buildLiveMetric(
                    Icons.shopping_cart,
                    Colors.orange,
                    'GMV Atual',
                    'R\$ ${widget.live.gmvAtual.toStringAsFixed(2)}'),
                _buildLiveMetric(
                    Icons.savings,
                    AppColors.success,
                    'Sua Comissão',
                    'R\$ ${widget.live.comissaoProjetada.toStringAsFixed(2)}'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMetric(
      IconData icon, Color color, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _MaisVendidosCard extends StatelessWidget {
  final List<ProdutoVendido> produtos;
  const _MaisVendidosCard({required this.produtos});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PRODUTOS MAIS VENDIDOS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Divider(),
            if (produtos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Nenhuma venda registrada neste mês.',
                    style: TextStyle(color: Colors.grey)),
              ),
            ...produtos.map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('${p.qty}x',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(p.produto,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500))),
                      Text('R\$ ${p.valor.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final RankingDia ranking;
  const _RankingCard({required this.ranking});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.warning.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('RANKING DE HOJE',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('#${ranking.posicao}',
                    style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800])),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 4),
                  child: Text('/ ${ranking.totalParticipantes}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text('Você gerou R\$ ${ranking.gmvDia.toStringAsFixed(2)} hoje',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
