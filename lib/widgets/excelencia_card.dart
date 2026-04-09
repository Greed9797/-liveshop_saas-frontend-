import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class ExcelenciaCard extends StatelessWidget {
  const ExcelenciaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PROGRAMA DE EXCELÊNCIA',
              style: AppTypography.h3.copyWith(fontSize: 16),
            ),
            const Divider(height: 24),
            _buildRatingRow('BASE DE CONTRATOS', 0),
            _buildRatingRow('PRODUTIVIDADE', 3),
            _buildRatingRow('CHURN', 0),
            const SizedBox(height: 20),
            _buildProgressBar('ÍNDICE DE FIDELIDADE', 0.92, '92,0%'),
            const SizedBox(height: 12),
            _buildProgressBar('RETORNO DE INVESTIMENTO', 0.051, '5,122%'),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(String label, int stars) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold, color: AppColors.gray500)),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < stars ? Icons.star : Icons.star_border,
                size: 16,
                color: index < stars ? AppColors.primary : AppColors.gray200,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, String percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.gray500)),
            Text(percentage,
                style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.gray700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 12,
            backgroundColor: AppColors.gray200,
            valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.successGreen),
          ),
        ),
      ],
    );
  }
}
