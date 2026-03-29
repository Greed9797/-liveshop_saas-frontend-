import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ExcelenciaCard extends StatelessWidget {
  const ExcelenciaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PROGRAMA DE EXCELÊNCIA',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54)),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < stars ? Icons.star : Icons.star_border,
                size: 16,
                color: index < stars ? AppColors.primary : Colors.black12,
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
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)),
            Text(percentage,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF10B981)), // Green from reference
          ),
        ),
      ],
    );
  }
}
