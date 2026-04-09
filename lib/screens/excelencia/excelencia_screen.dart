import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/metric_card.dart';
import '../../providers/excelencia_provider.dart';
import '../../models/excelencia.dart' show ExcelenciaData;
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../widgets/app_card.dart';

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
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Programa de Excelência',
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.w500)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      ref.read(excelenciaProvider.notifier).refresh(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            excelenciaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Erro: $e'),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(excelenciaProvider.notifier).refresh(),
                    child: const Text('Tentar novamente'),
                  ),
                ]),
              ),
              data: (data) => _ExcelenciaContent(
                  data: data, taxaFranquia: _taxaFranquia),
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
    final mesesROI =
        data.fatMesAtual > 0 ? taxaFranquia / data.fatMesAtual : 0.0;
    final crescendo = data.crescimentoPct >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score bar
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.compactPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Score de Excelência',
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w500)),
                    Text('${data.score}/100',
                        style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  child: LinearProgressIndicator(
                    value: data.score / 100,
                    minHeight: 10,
                    backgroundColor: AppColors.gray200,
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
            SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'RETENÇÃO DE CLIENTES',
                  value: '${data.taxaRetencao}%',
                  icon: Icons.favorite_border,
                  iconColor: AppColors.success,
                  subtitle:
                      '${data.ativos} ativos / ${data.cancelados} cancelados',
                )),
            SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'CRESCIMENTO',
                  value: '${crescendo ? '+' : ''}${data.crescimentoPct}%',
                  icon: crescendo ? Icons.trending_up : Icons.trending_down,
                  iconColor: crescendo ? AppColors.success : AppColors.danger,
                  subtitle: 'vs. mês anterior',
                )),
            SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'PRODUTIVIDADE',
                  value: '${data.ativos} clientes',
                  icon: Icons.bolt_outlined,
                  iconColor: AppColors.primary,
                  subtitle: 'carteira ativa',
                )),
            SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'CHURN',
                  value: '${100 - data.taxaRetencao}%',
                  icon: Icons.remove_circle_outline,
                  iconColor: AppColors.danger,
                  subtitle:
                      '${data.cancelados} cancelamento${data.cancelados == 1 ? '' : 's'}',
                )),
          ],
        ),
        const SizedBox(height: AppSpacing.x3l),
        AppCard(
          backgroundColor: AppColors.infoPurple,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Row(
              children: [
                const Icon(Icons.savings_outlined,
                    color: AppColors.lilac, size: 40),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RETORNO SOBRE INVESTIMENTO (ROI)',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.lilac, letterSpacing: 0.8)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${mesesROI.toStringAsFixed(1)} meses',
                        style: AppTypography.h1.copyWith(
                            fontSize: 32,
                            color: AppColors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Taxa de franquia R\$ ${taxaFranquia.toStringAsFixed(0)} ÷ Fat. líq. R\$ ${data.fatMesAtual.toStringAsFixed(0)}/mês',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.lilac.withValues(alpha: 0.8)),
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
