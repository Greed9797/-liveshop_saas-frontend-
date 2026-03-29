import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cabines/cabine_detail_provider.dart';
import '../../theme/app_colors.dart';

class CabineDetailScreen extends ConsumerWidget {
  final String cabineId;
  final int cabineNumero;

  const CabineDetailScreen({
    super.key,
    required this.cabineId,
    required this.cabineNumero,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escutamos o provider injetando a String do cabineId (Family)
    final detailState = ref.watch(cabineDetailProvider(cabineId));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Cabine $cabineNumero',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(cabineDetailProvider(cabineId).notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: detailState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar dados da cabine: $err',
                  textAlign: TextAlign.center),
              TextButton(
                onPressed: () =>
                    ref.read(cabineDetailProvider(cabineId).notifier).refresh(),
                child: const Text('Tentar novamente'),
              )
            ],
          ),
        ),
        data: (data) {
          final isAoVivo = data.liveAtual != null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- SEÇÃO 1: LIVE ATUAL (Visível apenas se ao vivo) ---
                if (isAoVivo) _buildLiveAtualSection(context, data.liveAtual!),

                if (isAoVivo) const SizedBox(height: 32),

                // --- SEÇÃO 2: HISTÓRICO DA CABINE (Sempre visível) ---
                _buildHistoricoSection(context, data.historico!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveAtualSection(BuildContext context, dynamic liveAtual) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
            color: Colors.green, width: 2), // Borda verde indicando "AO VIVO"
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Cabine 3 * AO VIVO * 1h 23min
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 12),
                      const SizedBox(width: 8),
                      Text(
                        'AO VIVO AGORA',
                        style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.timer_outlined, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${liveAtual.duracaoMinutos} min',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(height: 32),

            // Grid 2x2 com dados principais
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.visibility,
                    iconColor: Colors.blue,
                    value: liveAtual.viewerCount.toString(),
                    label: 'Espectadores',
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.attach_money,
                    iconColor: Colors.green,
                    value: 'R\$ ${liveAtual.gmvAtual.toStringAsFixed(2)}',
                    label: 'GMV da live',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.shopping_cart,
                    iconColor: Colors.orange,
                    value: liveAtual.totalOrders.toString(),
                    label: 'Pedidos na live',
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.inventory_2,
                    iconColor: Colors.purple,
                    value: liveAtual.topProduto != null
                        ? '${liveAtual.topProduto['quantidade']} un'
                        : 'Nenhum',
                    label: liveAtual.topProduto != null
                        ? liveAtual.topProduto['nome']
                        : 'Produto mais vendido',
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // Rodapé: Cliente e Apresentador
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cliente: ${liveAtual.clienteNome}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('Apresentador: ${liveAtual.apresentadorNome}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
      {required IconData icon,
      required Color iconColor,
      required String value,
      required String label}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoricoSection(BuildContext context, dynamic historico) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HISTÓRICO DA CABINE (Últimos 90 dias)',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Esquerda: Top Clientes e Melhores Horários
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildTopClientesCard(historico.topClientes),
                  const SizedBox(height: 16),
                  _buildHorariosCard(historico.melhoresHorarios),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Direita: Desempenho Mensal
            Expanded(
              flex: 1,
              child: _buildDesempenhoMensalCard(
                  historico.desempenhoMensal, historico.totais),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopClientesCard(List<dynamic> clientes) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Clientes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            if (clientes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Nenhum dado disponível ainda.',
                    style: TextStyle(color: Colors.grey)),
              ),
            ...clientes.map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c['nome'],
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          Text('R\$ ${c['fat_total'].toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.green)),
                          const SizedBox(width: 16),
                          Text('${c['total_lives']} lives',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildHorariosCard(List<dynamic> horarios) {
    // Calculando o max GMV para fazer as barras horizontais proporcionais
    double maxGmv = 0;
    for (var h in horarios) {
      if (h['gmv_medio'] > maxGmv) maxGmv = h['gmv_medio'];
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Melhores Horários (GMV Médio)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            if (horarios.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Nenhum dado disponível ainda.',
                    style: TextStyle(color: Colors.grey)),
              ),
            ...horarios.take(4).map((h) {
              final gmvMedio = (h['gmv_medio'] as num).toDouble();
              final pct = maxGmv > 0 ? (gmvMedio / maxGmv) : 0.0;
              final int flexValue = (pct * 100).toInt().clamp(1, 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                        width: 80,
                        child: Text(h['hora'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: flexValue,
                            child: Container(
                                height: 12,
                                color: AppColors
                                    .primary), // Cor roxa definida no AppTheme
                          ),
                          Expanded(
                            flex: 100 - flexValue,
                            child:
                                Container(height: 12, color: Colors.grey[200]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 100,
                      child: Text('R\$ ${gmvMedio.toStringAsFixed(0)}',
                          textAlign: TextAlign.right),
                    )
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDesempenhoMensalCard(
      Map<String, dynamic> desempenho, Map<String, dynamic> totais) {
    final meses = desempenho['meses'] as List<dynamic>? ?? [];
    final crescimento = desempenho['crescimento_pct'] ?? 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Desempenho Mensal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),

            // Crescimento Badge
            if (meses.length >= 2)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: crescimento >= 0
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      crescimento >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: crescimento >= 0 ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${crescimento >= 0 ? '+' : ''}${crescimento.toStringAsFixed(1)}% vs último mês',
                      style: TextStyle(
                        color: crescimento >= 0
                            ? Colors.green[700]
                            : Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),

            // Mês a Mês
            ...meses.take(3).map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m['mes']),
                      Text(
                          'R\$ ${m['fat_total'].toStringAsFixed(0)} (${m['total_lives']} lives)'),
                    ],
                  ),
                )),

            const Divider(height: 32),
            const Text('Total Histórico',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Lives: ${totais['total_lives'] ?? 0}'),
            Text(
                'Faturamento: R\$ ${(totais['gmv_total'] ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
