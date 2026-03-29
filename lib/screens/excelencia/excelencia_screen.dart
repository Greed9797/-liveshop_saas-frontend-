import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/metric_card.dart';
import '../../providers/excelencia_provider.dart';
import '../../models/excelencia.dart' show ExcelenciaData;
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Programa de excelência com métricas e cálculo de ROI
class ExcelenciaScreen extends ConsumerWidget {
  const ExcelenciaScreen({super.key});

  static const _taxaFranquia = 29000.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final excelenciaAsync = ref.watch(excelenciaProvider);

    return AppScaffold(
      currentRoute: AppRoutes.excelencia,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Programa de Excelência',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(excelenciaProvider.notifier).refresh(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            excelenciaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Erro: $e'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.read(excelenciaProvider.notifier).refresh(),
                    child: const Text('Tentar novamente'),
                  ),
                ]),
              ),
              data: (data) => _ExcelenciaContent(data: data, taxaFranquia: _taxaFranquia),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExcelenciaContent extends StatelessWidget {
  final ExcelenciaData data;
  final double taxaFranquia;
  const _ExcelenciaContent({required this.data, required this.taxaFranquia});

  @override
  Widget build(BuildContext context) {
    final mesesROI = data.fatMesAtual > 0 ? taxaFranquia / data.fatMesAtual : 0.0;
    final crescendo = data.crescimentoPct >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score bar
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Score de Excelência',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Text('${data.score}/100',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: data.score / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      data.score >= 80
                          ? AppColors.success
                          : data.score >= 50
                              ? AppColors.warning
                              : AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            SizedBox(width: 220, child: MetricCard(
              label: 'RETENÇÃO DE CLIENTES',
              value: '${data.taxaRetencao}%',
              icon: Icons.favorite_border,
              iconColor: AppColors.success,
              subtitle: '${data.ativos} ativos / ${data.cancelados} cancelados',
            )),
            SizedBox(width: 220, child: MetricCard(
              label: 'CRESCIMENTO',
              value: '${crescendo ? '+' : ''}${data.crescimentoPct}%',
              icon: crescendo ? Icons.trending_up : Icons.trending_down,
              iconColor: crescendo ? AppColors.success : AppColors.danger,
              subtitle: 'vs. mês anterior',
            )),
            SizedBox(width: 220, child: MetricCard(
              label: 'PRODUTIVIDADE',
              value: '${data.ativos} clientes',
              icon: Icons.bolt_outlined,
              iconColor: AppColors.primary,
              subtitle: 'carteira ativa',
            )),
            SizedBox(width: 220, child: MetricCard(
              label: 'CHURN',
              value: '${100 - data.taxaRetencao}%',
              icon: Icons.remove_circle_outline,
              iconColor: AppColors.danger,
              subtitle: '${data.cancelados} cancelamento${data.cancelados == 1 ? '' : 's'}',
            )),
          ],
        ),
        const SizedBox(height: 28),
        Card(
          color: const Color(0xFF2D2860),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Icon(Icons.savings_outlined, color: AppColors.lilac, size: 40),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RETORNO SOBRE INVESTIMENTO (ROI)',
                          style: TextStyle(color: AppColors.lilac, fontSize: 12, letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      Text(
                        '${mesesROI.toStringAsFixed(1)} meses',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Taxa de franquia R\$ ${taxaFranquia.toStringAsFixed(0)} ÷ Fat. líq. R\$ ${data.fatMesAtual.toStringAsFixed(0)}/mês',
                        style: TextStyle(
                            color: AppColors.lilac.withValues(alpha: 0.8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
