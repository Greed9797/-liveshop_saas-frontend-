import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/excelencia_provider.dart';
import '../models/excelencia.dart';
import '../theme/theme.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class ExcelenciaCard extends ConsumerWidget {
  const ExcelenciaCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final excelenciaAsync = ref.watch(excelenciaProvider);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: excelenciaAsync.when(
          loading: () => const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Erro ao carregar métricas',
                    style: AppTypography.labelSmall
                        .copyWith(color: context.colors.textSecondary)),
                TextButton(
                  onPressed: () =>
                      ref.read(excelenciaProvider.notifier).refresh(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
          data: (data) => _CardContent(data: data),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final ExcelenciaData data;
  const _CardContent({required this.data});

  int _starsContratos() => (data.ativos / 10).ceil().clamp(0, 5);

  int _starsProdutividade() {
    final g = data.crescimentoPct;
    if (g < 0) return 1;
    if (g < 10) return 2;
    if (g < 30) return 3;
    if (g < 60) return 4;
    return 5;
  }

  int _starsChurn() {
    final churn = 100 - data.taxaRetencao;
    if (churn < 5) return 5;
    if (churn < 15) return 4;
    if (churn < 30) return 3;
    if (churn < 50) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROGRAMA DE EXCELÊNCIA',
          style: AppTypography.h3.copyWith(fontSize: 16),
        ),
        const Divider(height: 24),
        _buildRatingRow(context, 'BASE DE CONTRATOS', _starsContratos()),
        _buildRatingRow(context, 'PRODUTIVIDADE', _starsProdutividade()),
        _buildRatingRow(context, 'CHURN', _starsChurn()),
        const SizedBox(height: 20),
        _buildProgressBar(
          context,
          'ÍNDICE DE FIDELIDADE',
          (data.taxaRetencao / 100).clamp(0.0, 1.0),
          '${data.taxaRetencao}%',
        ),
        const SizedBox(height: 12),
        _buildProgressBar(
          context,
          'SCORE DE EXCELÊNCIA',
          (data.score / 100).clamp(0.0, 1.0),
          '${data.score}/100',
        ),
      ],
    );
  }

  Widget _buildRatingRow(BuildContext context, String label, int stars) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold, color: context.colors.textSecondary)),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < stars ? Icons.star : Icons.star_border,
                size: 16,
                color: index < stars ? context.colors.primary : context.colors.progressBg,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, String label, double value, String percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold, color: context.colors.textSecondary)),
            Text(percentage,
                style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 12,
            backgroundColor: context.colors.progressBg,
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.success),
          ),
        ),
      ],
    );
  }
}
